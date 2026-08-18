# Wiki Log

append-only 작업 로그. 항목을 삭제하거나 수정하지 않는다.

각 항목 형식: `## [YYYY-MM-DD] <action> | <제목>`
- action: `ingest` | `query` | `lint` | `post`

grep 사용법: `grep "^## \[" wiki/log.md | tail -5`

---

## [2026-08-18] init | 위키 초기화
디렉토리 구조, wiki-ingest 스킬, index.md, log.md 생성
