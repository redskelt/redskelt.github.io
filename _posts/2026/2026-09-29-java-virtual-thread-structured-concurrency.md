---
title: "CompletableFuture, StructuredTaskScope로 바꿔도 될까? 사내 프로젝트로 검토해봤다 [3/3]"
date: 2026-09-29 09:32:00 +0900
categories: [Java]
tags: [Java, VirtualThread, StructuredConcurrency, 실무]
series: java-virtual-thread
series_index: 3
---

[1편]({% post_url 2026/2026-09-29-java-virtual-thread-deep-dive %})·[2편]({% post_url 2026/2026-09-29-java-virtual-thread-production-guide %})에서 Virtual Thread 자체를 다뤘다면, 이번 편은 실제로 맡고 있는 사내 프로젝트 코드를 놓고 "이거 `StructuredTaskScope`로 바꾸면 더 나아지나?"를 검토한 기록입니다. 실제 클래스명·도메인 로직은 회사 코드라 그대로 쓰지 않고, 같은 구조를 일반적인 "주문 상세 조회" 시나리오로 바꿔서 정리했습니다.

## 왜 이 검토를 하게 됐나

맡고 있는 프로젝트는 Spring Boot 4 + JDK 25 기반이고, 여러 화면에서 "메인 데이터 하나 + 연관 데이터 여러 개를 병렬로 긁어와서 합치는" 패턴을 `CompletableFuture.supplyAsync()` + `CompletableFuture.allOf()`로 짜고 있었습니다. 그리고 이걸 실행하는 `TaskExecutor`는 이미 `SimpleAsyncTaskExecutor`에 `setVirtualThreads(true)`를 걸어둔 상태 — 즉 **Virtual Thread 자체는 이미 도입돼 있었습니다.**

그래서 질문이 바뀝니다. "Virtual Thread를 써야 하나"가 아니라 "이 위에서 `CompletableFuture`로 짠 코드를, JDK 25가 지원하는(다만 아직 프리뷰인) `StructuredTaskScope`로 바꿀 가치가 있나"입니다.

## 기존 패턴 — 2단계 fan-out/fan-in

실제 코드의 구조를 그대로 살리되 도메인만 바꿔서 옮기면 이런 모양입니다. 1차로 주문 목록과 공통 코드를 병렬 조회하고, 그 결과로 만든 ID 목록을 가지고 2차로 상품·결제로그·회원정보를 다시 병렬 조회합니다.

```java
// Phase 1: 주문 목록 + 공통 코드
CompletableFuture<List<OrderItem>> orderItemsFuture =
    CompletableFuture.supplyAsync(() -> orderItemQueryPort.findAllByUserId(userId), queryExecutor)
        .exceptionally(ex -> { log.error("주문조회오류", ex); throw new AppException("주문조회오류"); });

CompletableFuture<List<CommonCode>> commonCodeFuture =
    CompletableFuture.supplyAsync(commonCodeQueryPort::findAll, queryExecutor)
        .exceptionally(ex -> { log.error("공통코드조회오류", ex); throw new AppException("공통코드조회오류"); });

CompletableFuture.allOf(orderItemsFuture, commonCodeFuture).join();

List<OrderItem> orderItems = orderItemsFuture.getNow(null);
List<String> productCodes = orderItems.stream().map(OrderItem::productCode).distinct().toList();
List<Long> orderIds = orderItems.stream().map(OrderItem::orderId).distinct().toList();

// Phase 2: 1차 결과로 만든 ID 목록으로 다시 병렬 조회
CompletableFuture<List<Product>> productFuture =
    CompletableFuture.supplyAsync(() -> productQueryPort.findByCodes(productCodes), queryExecutor)
        .exceptionally(ex -> { log.error("상품조회오류", ex); throw new AppException("상품조회오류"); });

CompletableFuture<List<PayLog>> payLogFuture =
    CompletableFuture.supplyAsync(() -> payLogQueryPort.findByOrderIds(orderIds), queryExecutor)
        .exceptionally(ex -> { log.error("결제로그조회오류", ex); throw new AppException("결제로그조회오류"); });

CompletableFuture<Member> memberFuture =
    CompletableFuture.supplyAsync(() -> memberQueryPort.findById(userId), queryExecutor)
        .exceptionally(ex -> { log.error("회원조회오류", ex); throw new AppException("회원조회오류"); });

CompletableFuture.allOf(productFuture, payLogFuture, memberFuture).join();
```

## StructuredTaskScope로 바꾸면

JDK 25의 새 `Joiner` 기반 API(`open(Joiner.awaitAllSuccessfulOrThrow())`)로 같은 Phase 1을 옮기면:

```java
// --enable-preview 필요 (JDK 25 기준 Structured Concurrency는 5th preview)
try (var scope = StructuredTaskScope.open(Joiner.<Object>awaitAllSuccessfulOrThrow())) {
    var orderItems  = scope.fork(() -> orderItemQueryPort.findAllByUserId(userId));
    var commonCodes = scope.fork(commonCodeQueryPort::findAll);

    scope.join(); // 하나라도 실패하면 나머지는 자동 취소되고 예외가 던져진다

    List<String> productCodes = orderItems.get().stream()
        .map(OrderItem::productCode).distinct().toList();
    // ...
}
```

**달라지는 점 3가지:**

1. `.exceptionally()`로 개별 예외를 감싸고 `CompletableFuture.allOf().join()`으로 뭉쳐서 기다리던 코드가, `scope.join()` 한 줄로 줄어듭니다. 실패 시 나머지 서브태스크가 **자동으로 취소**되는 것도 `CompletableFuture.allOf()`엔 없던 동작입니다 — 취소 로직을 직접 안 짜도 됩니다.
2. try-with-resources 스코프를 벗어나는 순간 남은 서브태스크가 확실히 정리됩니다. `CompletableFuture`는 `join()`을 안 걸어두면 백그라운드에서 계속 실행되는 게 가능하지만, `StructuredTaskScope`는 구조적으로 그런 누수가 불가능합니다.
3. 반대로 **코드량이 크게 줄지는 않습니다.** 이미 `CompletableFuture.allOf().join()`으로 짧게 짜여 있던 패턴이라, 얻는 이득은 "취소 자동화"와 "누수 방지"지 "가독성 대폭 개선"은 아니었습니다.

## 안 맞는 패턴 — 순차 의존관계가 있는 체이닝

반면 원본 코드에는 `thenCompose()`를 3단계로 중첩해서 "이 조회 결과로 다음 조회 조건을 만들고, 그 결과로 또 다음 조회를 하는" 체이닝 패턴도 있었습니다.

```java
// 1차 조회 결과로 2차 조회 조건을 만들고, 2차 결과로 3차 조회 조건을 만드는 순차 체이닝
CompletableFuture<Map<String, Carrier>> resultFuture =
    CompletableFuture.supplyAsync(() -> deliveryQueryPort.findByOrderIds(orderIds), queryExecutor)
        .thenCompose(deliveries -> {
            List<Long> warehouseIds = deliveries.stream().map(Delivery::warehouseId).toList();
            return CompletableFuture.supplyAsync(() -> warehouseQueryPort.findByIds(warehouseIds), queryExecutor)
                .thenCompose(warehouses -> {
                    List<Long> carrierIds = warehouses.stream().map(Warehouse::carrierId).toList();
                    return CompletableFuture.supplyAsync(() -> carrierQueryPort.findByIds(carrierIds), queryExecutor)
                        .thenApply(carriers -> mapToResult(deliveries, warehouses, carriers));
                });
        });
```

이건 애초에 **병렬화 대상이 아니라 순차 의존 파이프라인**입니다. `StructuredTaskScope`는 "여러 서브태스크를 동시에 fork하고 함께 join"하는 데 특화된 도구라, 이렇게 각 단계가 이전 단계 결과에 의존하는 체이닝에는 이점이 없습니다. `scope.fork()`를 걸 병렬 작업 자체가 없으니까요. 이 패턴은 그냥 순차 블로킹 호출(Virtual Thread 덕분에 어차피 캐리어를 안 막으니 순차로 짜도 손해가 없음)로 단순화하는 게 오히려 더 읽기 쉽습니다.

단, 전제가 두 가지 있습니다. 첫째, 이 코드를 호출하는 스레드 자체가 Virtual Thread여야 합니다 — 요청 스레드가 플랫폼 스레드(`spring.threads.virtual.enabled=false`)라면 순차 블로킹 호출이 그 스레드를 그대로 붙잡습니다. 둘째, 원래 `resultFuture`가 다른 future와 `allOf()`로 묶여 **병렬로** 돌고 있었다면, 순차 블로킹으로 바꾸는 순간 그 병렬성이 사라져 응답 시간이 늘어납니다. 이 경우엔 체이닝 전체를 하나의 서브태스크로 감싸서 다른 조회와 함께 fork하는 게 맞습니다.

```java
// Virtual Thread 환경에서는 순차 블로킹 호출이 더 단순하고 손해도 없다
List<Delivery> deliveries = deliveryQueryPort.findByOrderIds(orderIds);
List<Warehouse> warehouses = warehouseQueryPort.findByIds(deliveries.stream().map(Delivery::warehouseId).toList());
List<Carrier> carriers = carrierQueryPort.findByIds(warehouses.stream().map(Warehouse::carrierId).toList());
Map<String, Carrier> result = mapToResult(deliveries, warehouses, carriers);
```

## 실전 도입의 걸림돌

![JEP 525 "Structured Concurrency (Sixth Preview)" — JDK 25(JEP 505)에서 StructuredTaskScope의 public 생성자가 정적 팩토리 메서드로 전면 교체된 이력이 명시돼 있다](/assets/img/posts/java-virtual-thread/08-jep525-structured-concurrency.png)

1. **여전히 프리뷰다.** JDK 19(JEP 428) 인큐베이팅부터 JDK 26(JEP 525, 6th preview), 그리고 이달 나온 JDK 27(JEP 533, 7th preview)까지 계속 API가 바뀌고 있습니다. JDK 27에서도 `join()`이 던지는 예외 타입에 타입 파라미터가 추가되는 변경이 있었습니다. 특히 JDK 25(JEP 505)에서 `new StructuredTaskScope.ShutdownOnFailure()` 같은 public 생성자가 통째로 제거되고 `open(Joiner)` 정적 팩토리로 교체됐습니다 — 즉 인터넷에 떠도는 JDK 21~24 기준 예제 코드는 JDK 25+에서 그대로 컴파일되지 않습니다. 빌드 전체에 `--enable-preview` 플래그를 걸어야 컴파일·실행이 되는 것도 여전한 부담이라, 프로덕션 코드베이스 전체의 컴파일 옵션을 바꾸는 일이라 팀 합의가 필요합니다.
2. **Spring Boot 4도 아직 자동 연동은 없다.** `@Async`나 요청 처리 파이프라인에 `StructuredTaskScope`를 자동으로 엮어주는 기능은 없고, 직접 `try (var scope = ...)` 블록으로 작성해야 합니다.
3. **트랜잭션·MDC·SecurityContext 전파는 어느 쪽이든 안 된다.** Spring의 트랜잭션 동기화(`TransactionSynchronizationManager`)는 `ThreadLocal` 기반이라, `scope.fork()`로 만든 서브태스크는 부모 트랜잭션을 이어받지 못합니다. 다만 이건 새로 생기는 문제가 아닙니다 — 지금 `CompletableFuture.supplyAsync(..., queryExecutor)` 코드도 이미 다른 스레드에서 돌기 때문에 똑같이 트랜잭션 밖에서 실행되고 있습니다. 즉 교체 여부와 무관하게 "병렬 조회는 트랜잭션 밖에서 돈다"는 전제로 짜야 합니다. (Structured Concurrency는 `ScopedValue` 바인딩은 서브태스크에 자동 상속하지만, Spring의 컨텍스트들은 아직 `ThreadLocal` 기반이라 이 혜택을 못 받습니다.)

## 결론 — 지금 당장 전면 교체는 안 한다

검토 결과는 이렇습니다.

- **Virtual Thread는 이미 잘 쓰고 있다.** `SimpleAsyncTaskExecutor.setVirtualThreads(true)`로 충분하고, 여기서 더 얻을 이득은 크지 않다.
- **단순 fan-out/fan-in 패턴(1~2단계, `allOf().join()`으로 짧게 끝나는 코드)** 은 `StructuredTaskScope`로 바꿔도 이득(자동 취소·누수 방지)이 있지만, 지금 있는 코드는 애초에 짧아서 체감 효과가 크지 않다.
- **순차 의존 체이닝(`thenCompose` 다단계)** 은 `StructuredTaskScope` 대상이 아니고, 오히려 Virtual Thread 위에서 그냥 순차 블로킹 코드로 단순화하는 게 낫다.
- **JDK 27까지도 프리뷰**라 버전마다 API가 바뀌고 `--enable-preview`를 빌드 전체에 걸어야 한다는 리스크가, 지금 얻는 이득 대비 너무 크다. (트랜잭션 전파는 지금 코드도 안 되고 있으니 교체의 리스크가 아니다.)

그래서 지금은 전면 교체 대신, 새로 짜는 코드 중 **트랜잭션 없이 순수 조회만 병렬로 fan-out하는 단순한 케이스 하나만 시범 적용**해보고, Structured Concurrency finalize가 제안돼 있는 JDK 28 시점에 맞춰 재검토하기로 했습니다. Virtual Thread 도입은 "당장 해도 되는 선택"이었지만, Structured Concurrency는 "지금은 지켜볼 시점"이라는 게 실제 코드로 검토해본 결론입니다.
