멱등성(Idempotency)이란 같은 요청을 여러 번 보내도 결과가 한 번 보낸 것과 같은 성질이다. HTTP에서 GET/PUT/DELETE는 멱등해야 하고 POST는 아니다. 분산 시스템에서 재시도 로직을 안전하게 만들려면 멱등키(idempotency key)를 써서 중복 처리를 막는다.
