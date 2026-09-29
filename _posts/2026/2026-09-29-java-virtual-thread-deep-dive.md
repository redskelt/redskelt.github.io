---
title: "자바 Virtual Thread 완전 정리: 원리, 성능, 그리고 2026년 현재 상태 [1/2]"
date: 2026-09-29 09:30:00 +0900
categories: [Backend, Java]
tags: [Java, VirtualThread, JVM, 동시성]
series: java-virtual-thread
series_index: 1
---

우아한형제들 회원 프로덕트 팀 김태현 님의 우아한테크세미나 발표 ["Java의 미래, Virtual Thread"](https://www.youtube.com/watch?v=BZMZIM-n4C0)를 보고 정리했습니다. 2024년 4월 발표라 JDK 21 기준 내용인데, 뒷부분에 2026년 9월 현재(JDK 25/26) 기준으로 뭐가 달라졌는지도 최신 OpenJDK 문서로 확인해서 덧붙였습니다. 실무 도입 관점의 장단점 심층분석·실제 장애 사례·동시성 모델 비교·체크리스트는 [2편]({% post_url 2026/2026-09-29-java-virtual-thread-production-guide %})에서 이어집니다.

{% include video id="BZMZIM-n4C0" provider="youtube" %}

## 왜 Virtual Thread를 딥다이브했나

발표팀은 2021년 전사 게이트웨이 시스템을 개발하면서 높은 트래픽을 처리할 경량 동시성 모델이 필요했습니다. 당시 선택지는 코틀린 코루틴과 자바 프로젝트 룸(Virtual Thread의 전신) 두 가지였는데, 프로젝트 룸은 정식 기능도 아니고 레퍼런스도 없어서 코틀린 코루틴을 선택했습니다. 그러다 2023년 9월 JDK 21에서 Virtual Thread가 정식 기능(JEP 444)으로 들어오면서 본격적으로 딥다이브를 시작했다고 합니다.

## Virtual Thread의 3가지 장점

1. **쓰레드 생성·스케줄링 비용이 저렴하다** — 기존 플랫폼 쓰레드는 최대 2MB 메모리를 쓰고 OS 스케줄링을 거치지만, Virtual Thread는 수십 KB만 쓰고 JVM 내부에서 스케줄링된다.
2. **논블로킹 IO를 지원한다** — 스프링 웹플럭스와는 방식이 다르지만, 스레드 스케줄링과 컨티뉴에이션을 활용해 결과적으로 논블로킹처럼 동작한다.
3. **기존 `Thread` 클래스를 상속해서 완벽하게 호환된다** — 코드에서 쓰레드를 쓰는 부분을 그대로 Virtual Thread로 바꿔도 동작한다.

![Thread vs Virtual Thread 비교표 — 메모리 2MB→50KB, 생성시간 1ms→10µs, 컨텍스트 스위칭 100µs→10µs](/assets/img/posts/java-virtual-thread/01-thread-comparison-table.png)

## 실험으로 검증한 장점

발표자는 주장을 그대로 믿지 않고 직접 두 가지 실험을 했습니다.

**실험 1 — 생성·시작 속도.** 아무 작업도 하지 않는 쓰레드 100만 개를 생성·실행. 일반 쓰레드는 31.632초, Virtual Thread는 375ms — 기존 대비 **98.8% 단축**됐습니다.

![실험1 결론 — 기존 쓰레드 대비 -98.8%, 쓰레드 생성 속도 향상](/assets/img/posts/java-virtual-thread/02-experiment1-result.png)

**실험 2 — 논블로킹 IO 여부.** 쓰레드 10개짜리 톰캣 서버에서 10초 걸리는 API를 100회 동시 호출. 이론상 블로킹 방식이면 100초가 걸려야 하는데(실측 130초), Virtual Thread 서버는 **10.1초**만에 끝났습니다 — 100개 요청을 동시에 처리한다는 뜻입니다.

![실험2 결론 — 기존 쓰레드 대비 -92.2%, I/O blocking 요청을 동시에 처리해 사실상 Nonblocking I/O](/assets/img/posts/java-virtual-thread/03-experiment2-result.png)

## 동작 원리 — JVM 스케줄링과 컨티뉴에이션

기존 플랫폼 쓰레드는 생성·스케줄링 때마다 JNI를 통해 커널 영역과 통신하고(시스템 콜 발생), OS 커널 쓰레드와 1:1로 매핑됩니다. Virtual Thread는 이 과정을 통째로 JVM 안에서 처리합니다.

- **스케줄러**: 기본값은 `ForkJoinPool` (워크 스틸링 방식), 워커 스레드 수는 CPU 프로세서 수만큼. 모든 Virtual Thread가 이 스케줄러 하나를 공유합니다.
- **작업 단위**: `Runnable`이 아니라 **Continuation**이라는 개념을 씁니다. 컨티뉴에이션은 코틀린 코루틴에도 쓰이는 오래된 패러다임으로, "중단 가능하고, 중단 지점을 기록했다가 그 지점부터 재실행 가능한 작업 흐름"입니다.
- **블로킹 처리**: 기존에는 `LockSupport.park()`가 호출되면 `Unsafe.park()`로 실제 커널 쓰레드를 블로킹했습니다. JDK 21부터는 현재 쓰레드가 Virtual Thread면 분기해서 컨티뉴에이션의 `yield`를 호출하도록 리팩터링됐습니다 — 실제 쓰레드를 막지 않고 컨티뉴에이션만 대기 큐에서 빼내고, 캐리어 쓰레드는 다른 작업을 계속 처리합니다. 이게 시스템 콜 없이 논블로킹처럼 동작하는 핵심 메커니즘입니다.

톰캣 서버를 Virtual Thread 모드로 바꾸는 건 프로토콜 핸들러의 익스큐터를 Virtual Thread용으로 바꾸는 한 줄이면 충분합니다. 그러면 요청마다 플랫폼 쓰레드 대신 Virtual Thread가 생성되고, IO를 만나면 컨티뉴에이션을 yield하고 캐리어 쓰레드에서 분리 — 그 캐리어 쓰레드는 곧바로 다음 요청을 처리합니다.

## 성능 테스트 결과

최소 사양(AWS t2, 힙 256MB)에서 스프링 MVC 기준으로 측정한 결과:

- **IO 바운드 작업**: 일반 쓰레드 모델 대비 **51% 높은 TPS**
- **CPU 바운드 작업**: 오히려 **7% 낮은 성능** — CPU 바운드는 결국 캐리어(플랫폼) 쓰레드 위에서 돌기 때문에, Virtual Thread를 스케줄링/생성하는 오버헤드만 추가되는 셈입니다.

![성능테스트 결과 — I/O Bound 151%(TPS 92.1→139.7), CPU Bound 93%(91.5→85.3)](/assets/img/posts/java-virtual-thread/04-performance-test-result.png)

웹플럭스와 비교한 실험도 있었는데, 극단적으로 낮은 사양에서는 웹플럭스의 컨텍스트 스위칭 비용이 병목이 되어 Virtual Thread가 훨씬 앞서는 결과가 나왔습니다. 다만 발표자도 "실제로는 이렇게까지 차이나지 않는다, 극한 상황을 가정한 것"이라고 못박았습니다.

## 실무 적용 시 주의사항

1. **핀(Pin) 현상** — `synchronized`, parallel stream, native 메서드 안에서 블로킹이 발생하면 Virtual Thread가 캐리어 쓰레드에서 분리되지 못하고 고정(pin)됩니다. 이러면 성능 이점이 사라집니다. (→ 2026년 현재는 아래 업데이트 참고)
2. **풀링 금지** — Virtual Thread는 생성 비용이 저렴하도록 설계됐기 때문에, 쓰레드풀처럼 개수를 제한하면 오히려 병목이 됩니다.
3. **CPU 바운드 작업에는 쓰지 말 것** — 스케줄링/생성 오버헤드만 추가되고 이득이 없습니다.
4. **가볍게 유지할 것** — `ThreadLocal`에 무거운 객체를 담으면 매번 생성·파괴되는 Virtual Thread 특성상 이점이 사라집니다.
5. **배압(backpressure) 조절이 없다** — 무제한 생성·처리를 시도하기 때문에 DB 커넥션 풀, 파일 핸들 같은 유한 리소스는 세마포어 등으로 애플리케이션 코드에서 직접 배압을 조절해야 합니다.

![핀(pinning) 현상 — 블로킹된 캐리어 쓰레드에 Virtual Thread가 고정되는 문제](/assets/img/posts/java-virtual-thread/05-pinning-issue.png)

## 2026년 9월 현재 — 뭐가 달라졌나

영상은 JDK 21(2023.09) 기준이라 이 부분 설명은 이제 더 정확하게 업데이트할 수 있습니다. OpenJDK 공식 문서 기준입니다.

- **핀 현상, 사실상 해결됨.** [JEP 491 "Synchronize Virtual Threads without Pinning"](https://openjdk.org/jeps/491)이 **JDK 24**(2025.03)에 들어가면서, `synchronized` 블록 안에서 모니터가 캐리어가 아닌 Virtual Thread 자체에 연결되도록 바뀌었습니다. 그 결과 `synchronized` 블록 안에서 IO 블로킹이나 `Thread.sleep()`을 만나도 캐리어 쓰레드가 풀려납니다. JEP 저자들도 이제 "`synchronized`를 `ReentrantLock`으로 바꿀 필요 없다"고 명시했습니다 — 영상이 강조했던 "핀 이슈 때문에 synchronized를 리엔트런트 락으로 바꿔라"는 조언은 JDK 24+ 환경에선 대부분 낡은 조언이 된 셈입니다.
- **ThreadLocal 대체재 `Scoped Value`, 정식 기능으로 확정.** 영상에서 "프리뷰 기능이라 지켜봐야 한다"고 했던 Scoped Value가 [JEP 506](https://openjdk.org/jeps/506)으로 **JDK 25**(2025.09, LTS)에서 finalize됐습니다. Virtual Thread의 가벼움을 해치지 않으면서 요청 범위 컨텍스트를 공유하고 싶다면 이제 표준으로 쓸 수 있습니다.
- **Structured Concurrency는 아직 프리뷰.** JDK 26 기준 6번째 프리뷰(JEP 525)이고, Scoped Value와 자연스럽게 통합되어 하위 작업이 부모의 스코프 값을 자동 상속받는 방향으로 다듬어지는 중입니다. 업계에서는 2026년 안, 늦어도 JDK 27에서 finalize를 기대하고 있습니다.
- **MySQL JDBC 드라이버 핀 이슈**도 영상 당시엔 미해결 PR 상태였는데, Connector/J 쪽에서 `synchronized` 의존을 줄이는 작업이 계속 진행되어 왔습니다. JDK 24의 근본 해결 덕분에 이 이슈의 실질적 영향은 크게 줄었습니다.

정리하면, 영상이 소개한 "장점은 확실하지만 pinning 때문에 조심해야 한다"는 결론에서, **pinning 부분은 JDK 24부터 사실상 해소**됐고, ThreadLocal 대체재도 정식 기능이 됐습니다. Virtual Thread를 실무에 적용하려는 시점이라면 최소 JDK 24, 가능하면 LTS인 JDK 25 이상을 기준으로 검토하는 걸 추천합니다.

## 시나리오별 실전 예제

영상엔 개념·실험만 나오고 실무 코드는 없어서, OpenJDK 공식 문서와 관련 블로그를 참고해 시나리오별로 정리했습니다. (JDK 24+ 기준)

### 1. Spring Boot 서버를 통째로 Virtual Thread로 돌리기

가장 간단한 적용 — 설정 한 줄이면 모든 `@RestController`/`@Service`가 Virtual Thread 위에서 실행됩니다. 기존 블로킹 코드를 한 줄도 안 고쳐도 됩니다.

```yaml
# application.yml (Spring Boot 3.2+, JDK 21+)
spring:
  threads:
    virtual:
      enabled: true
```

Tomcat과 Jetty의 요청 처리 쓰레드, `applicationTaskExecutor`(비동기 작업), Kafka/RabbitMQ/Redis 컨슈머 쓰레드까지 한 번에 Virtual Thread로 바뀝니다.

### 2. 여러 API를 병렬 호출하고 전부 성공해야 결과를 쓴다 (Fan-out/Fan-in)

주문 상세 화면처럼 "상품 정보 + 재고 + 리뷰"를 병렬로 조회해서 한 번에 합쳐야 하는 경우, JDK 25+의 `StructuredTaskScope`를 쓰면 서브태스크의 생명주기가 부모 스코프에 묶여서 한쪽이 실패하면 나머지도 자동으로 취소됩니다.

```java
// JDK 25+, --enable-preview 필요 (Structured Concurrency는 아직 프리뷰)
try (var scope = StructuredTaskScope.open(Joiner.<Object>awaitAllSuccessfulOrThrow())) {
    var product = scope.fork(() -> productClient.fetch(productId));
    var stock   = scope.fork(() -> stockClient.fetch(productId));
    var reviews = scope.fork(() -> reviewClient.fetchTop(productId, 5));

    scope.join(); // 셋 중 하나라도 실패하면 나머지는 즉시 취소되고 예외가 던져진다

    return new ProductDetail(product.get(), stock.get(), reviews.get());
} // try-with-resources가 스코프를 닫으면서 남은 서브태스크도 정리
```

기존에는 `ExecutorService` + `CompletableFuture.allOf()`로 짜야 했던 패턴인데, 실패 시 나머지 작업을 명시적으로 취소하는 코드를 직접 안 써도 됩니다.

### 3. 요청 범위 컨텍스트 전파 — `ThreadLocal` 대신 `ScopedValue`

인증된 사용자 ID, 트레이스 ID처럼 요청 전체에서 읽기만 하는 값은 JDK 25에서 finalize된 `ScopedValue`로 옮기는 게 권장됩니다. `ThreadLocal`은 값을 언제든 재할당할 수 있어 Virtual Thread처럼 매번 생성·소멸되는 환경에서 정리(clean-up)를 놓치기 쉬운데, `ScopedValue`는 바인딩된 블록 안에서만 유효하고 자동으로 해제됩니다.

```java
private static final ScopedValue<String> CURRENT_USER_ID = ScopedValue.newInstance();

// 요청 진입점 — 필터/인터셉터에서
ScopedValue.where(CURRENT_USER_ID, userId)
           .run(() -> handler.handle(request));

// 호출 스택 어디서든 읽기만 가능 (재할당 불가)
public void logAccess() {
    String userId = CURRENT_USER_ID.orElse("anonymous");
    log.info("access by {}", userId);
}
```

### 4. 유한 리소스(DB 커넥션) 배압 조절 — `Semaphore`

Virtual Thread는 수만 개를 만들어도 되지만, DB 커넥션 풀은 여전히 유한합니다. 커넥션 풀 크기만큼 `Semaphore`로 동시 진입을 제한해서 풀 고갈을 막습니다.

```java
private final Semaphore dbPermits = new Semaphore(20); // 커넥션 풀 크기와 맞춘다

public Order fetchOrder(long id) throws InterruptedException {
    dbPermits.acquire();
    try {
        return orderRepository.findById(id); // 블로킹 JDBC 호출 — Virtual Thread라 캐리어는 안 막힘
    } finally {
        dbPermits.release();
    }
}
```

### 5. 핀(pinning) 여부 확인하기 — JFR로 진단

JDK 24부터 `-Djdk.tracePinnedThreads`는 제거됐습니다. `synchronized`로 인한 pinning 자체가 대부분 사라졌기 때문인데, 그래도 native 메서드 등으로 인한 pinning이 남아있는지 확인하려면 JFR의 `jdk.VirtualThreadPinned` 이벤트를 씁니다(기본적으로 20ms 이상 걸리는 pinning만 기록).

```bash
java -XX:StartFlightRecording=filename=recording.jfr,settings=profile \
     -jar my-app.jar
# 이후 jfr print --events jdk.VirtualThreadPinned recording.jfr 로 확인
```

## 결론

Virtual Thread는 가볍고, 빠르고, (결과적으로) 논블로킹인 경량 쓰레드입니다. IO 블로킹이 병목인 쓰레드퍼 리퀘스트 방식 서버에 적용하면 이점이 크고, 리액티브나 코루틴을 배우기 부담스러운 팀이 가장 낮은 러닝커브로 적용할 수 있는 대안입니다. 다만 무조건 좋은 기술은 아니라는 발표자의 첫 당부처럼, CPU 바운드 작업이거나 배압 조절이 중요한 시스템이라면 상황에 맞게 선택해야 합니다.
