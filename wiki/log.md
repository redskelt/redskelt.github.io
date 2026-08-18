# Wiki Log

append-only 작업 로그. 항목을 삭제하거나 수정하지 않는다.

각 항목 형식: `## [YYYY-MM-DD] <action> | <제목>`
- action: `ingest` | `query` | `lint` | `post`

grep 사용법: `grep "^## \[" wiki/log.md | tail -5`

---

## [2026-08-18] init | 위키 초기화
디렉토리 구조, wiki-ingest 스킬, index.md, log.md 생성

## [2026-08-18] ingest | 멱등성(Idempotency)
wiki/raw/2026-08-18-idempotency.md 저장, wiki/concepts/idempotency.md 생성, index.md 반영

## [2026-08-18] post | wiki/concepts/idempotency.md → idempotency
_posts/2026/2026-08-18-idempotency.md 생성, 카테고리 Wiki, 태그 HTTP/분산시스템
