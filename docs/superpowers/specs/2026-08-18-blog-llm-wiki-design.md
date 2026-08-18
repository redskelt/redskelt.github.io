# 블로그 LLM 위키 + 자동 포스트 변환 설계

- 날짜: 2026-08-18
- 상태: 승인 대기 (writing-plans 이전 단계)
- 대상 저장소: redskelt.github.io

## 배경

[Karpathy의 LLM Wiki 패턴](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
(RAG 대신 소스를 읽을 때마다 지식을 위키에 누적시키는 방식)을 참고해, 이
블로그 저장소 안에 개인 학습/지식 위키를 만든다. 사용자는 이미
`ai-docs/llm-wiki`에 이 패턴을 적용한 실제 위키를 운영 중이며(회사
프로젝트용), 그 스키마(`CLAUDE.md`, 3계층 구조, ingest/query/lint 워크플로우)를
참고해 이 저장소 전용으로 축소·적용한다.

이번 작업의 차별점은 위키 페이지가 쌓이면 그걸 **블로그 포스트로 변환하는
경로**를 추가하는 것 — 위키는 지식 축적 창고, 포스트는 그중 발행할 만한
것의 블로그 톤 재구성본.

## 결정 사항 (사용자 승인 완료)

| 항목 | 결정 |
|---|---|
| 위키 주제 범위 | 일반 개인 지식/학습 (특정 회사/프로젝트 종속 아님) |
| Ingest 방식 | 사용자가 자료/링크/메모를 주면 Claude가 정리해서 위키 페이지 생성 |
| 포스트 변환 시점 | ingest 끝날 때마다 "포스트로도 만들까?" 확인 |
| 포스트 문체 | 위키 페이지(구조화된 메모)를 블로그 톤(구어체 설명조)으로 다시 씀 |
| 포스트 카테고리 | 새 카테고리 `Wiki` 하나로 통일, 세부 주제는 `tags`로 구분 |
| 접근법 | Karpathy 패턴 온전히 이식 (`ai-docs/llm-wiki`의 `projects/` 계층은 제외 — 이 저장소는 단일 주제 개인 위키라 불필요) |

## 디렉토리 구조

```
redskelt.github.io/
├── wiki/
│   ├── index.md          — 전체 페이지 카탈로그
│   ├── log.md             — append-only 작업 로그
│   ├── raw/               — 원본 소스 (사용자가 준 텍스트/링크 사본). 읽기 전용
│   │   └── assets/        — 원본 첨부 이미지 등
│   ├── concepts/          — 기술/지식 개념 페이지
│   └── decisions/         — 개인적 결정/회고 기록 (선택적으로 사용, ADR 형식 아님)
└── .claude/skills/
    └── wiki-ingest/
        └── SKILL.md       — ingest/query/lint 워크플로우 + 포스트 변환 핸드오프
```

`ai-docs/llm-wiki`의 3계층 구조(`raw/`, `wiki/`, 스키마 문서) 그대로 가져오되:
- `projects/<name>/` 계층 없음 — 이 저장소는 처음부터 단일 주제 위키
- `wiki/prd/`(기능 단위 요구사항) 없음 — 제품을 만드는 게 아니라 개인 학습
  기록이라 PRD 개념이 안 맞음. 대신 `concepts/`만 주로 쓰고, 학습 과정에서
  내린 판단/의견 정리가 필요하면 `decisions/`에 가볍게 남긴다 (ADR 포맷을
  강제하지 않음)
- 스키마 문서는 별도 `CLAUDE.md` 파일 대신 `.claude/skills/wiki-ingest/SKILL.md`
  안에 통합 — 이 저장소는 이미 `.claude/skills/post/SKILL.md` 컨벤션을 쓰고
  있어서 일관성 유지

## Jekyll 빌드 설정 변경

`_config.yml`의 `exclude:` 목록에 `wiki` 추가 — 이 디렉토리는 사이트로 빌드되면
안 되는 소스 자료다 (`docs`가 이미 같은 이유로 제외돼있는 것과 동일 패턴).

## 워크플로우

### Ingest

**트리거:** 사용자가 자료(텍스트 붙여넣기, 링크, 메모)를 주며 "이거 위키에
정리해줘" 류로 요청할 때.

**절차:**
1. 원본을 `wiki/raw/<날짜>-<slug>.md`로 저장 (읽기 전용 취급, 이후 수정 안 함)
2. 핵심 내용 파악 후 사용자에게 주요 takeaway 3~5개 요약
3. `wiki/concepts/<concept-name>.md` 생성 또는 기존 페이지 업데이트 (파일명
   kebab-case)
4. 기존 페이지와 내용이 모순되면 임의로 덮어쓰지 않고 모순을 명시한 뒤
   사용자에게 확인
5. `wiki/index.md`, `wiki/log.md` 갱신 (log 형식은 `ai-docs/llm-wiki`와 동일:
   `## [YYYY-MM-DD] ingest | <제목>`)
6. **여기서 사용자에게 확인:** "이거 블로그 포스트로도 만들까?"
   - yes → "Wiki → Post 변환" 절차로 진행
   - no → ingest 종료

**개념 페이지 포맷** (`ai-docs/llm-wiki`와 동일):
```markdown
---
title: 개념 이름
sources: [wiki/raw/파일명.md]
updated: YYYY-MM-DD
---

## 개요

## 동작 원리

## 이 블로그에서의 활용 (선택)
```

### Wiki → Post 변환

**트리거:** ingest 직후 사용자가 "포스트로 만들까?"에 yes로 답했을 때, 또는
사용자가 특정 위키 페이지를 지목하며 "이거 포스트로 만들어줘" 요청할 때.

**절차:**
1. 대상 위키 페이지(`wiki/concepts/*.md` 또는 `wiki/decisions/*.md`) 내용을
   읽는다
2. 구조화된 메모 문체를 블로그 톤(기존 `_posts/`의 구어체 설명조 — 예:
   "~했다", "~인 것 같다" 식 1인칭 서술)으로 다시 쓴다. 위키 페이지의
   섹션 구조(개요/동작원리 등)를 그대로 헤딩으로 옮기지 말고, 자연스러운
   글 흐름으로 재구성한다
3. 이후는 기존 `.claude/skills/post/SKILL.md`의 "작성" 절차를 그대로
   따른다 — 단, **카테고리는 항상 `Wiki`로 고정**하고, 위키 페이지의
   주제에 맞는 `tags`를 붙인다 (`post` 스킬의 "공통: 기존 카테고리 확인"
   절차는 카테고리가 고정이므로 생략, "공통: 본문에 링크가 있으면 링크
   확인" 절차는 그대로 적용)
4. 생성된 포스트의 front matter에 위키 페이지로 돌아가는 참조는 넣지
   않는다 (위키는 `wiki/`가 빌드 제외 대상이라 링크해도 죽은 링크가 됨) —
   대신 위키 페이지 쪽에 "포스트화됨: `_posts/...` 참고" 정도만 `log.md`에
   기록
5. `wiki/log.md`에 항목 추가: `## [YYYY-MM-DD] post | <위키 페이지> → <포스트 slug>`

### Query (선택적, 유지)

`ai-docs/llm-wiki`와 동일 — 사용자가 위키 관련 질문을 하면 `wiki/index.md`로
관련 페이지 파악 후 답변 합성, 출처는 `[[wikilink]]`로 명시. 답변 자체가
독립적 가치가 있으면 새 위키 페이지로 저장 제안.

### Lint (선택적, 유지)

`ai-docs/llm-wiki`와 동일 — 모순, 깨진 wikilink, 고아 페이지, 오래된 내용
점검. `log.md`에 `## [YYYY-MM-DD] lint | <요약>` 기록.

## 크로스레퍼런스 규칙

`ai-docs/llm-wiki`와 동일하게 Obsidian wikilink 문법(`[[concepts/concept-name]]`)
사용. 이 위키는 `wiki/`가 Jekyll 빌드에서 제외되므로 wikilink는 순수하게
Claude Code/Obsidian에서 탐색용으로만 쓰이고, 실제 사이트에는 아무 영향
없다.

## 에러 처리 / 리스크

- **회사/업무 자료 유입 방지**: 이 위키는 "일반 개인 지식"만 다루기로
  결정했으므로, ingest 요청 내용이 특정 회사·비공개 프로젝트에 종속된
  자료로 보이면 (예: 사내 시스템 이름, DB 스키마, 회원/직원 정보 등)
  ingest 전에 사용자에게 "이거 공개 저장소에 들어가도 되는 내용이 맞냐"고
  먼저 확인한다. (이번 브레인스토밍 자체가 `ai-docs/llm-wiki`의 EDUCO
  자료를 실수로 옮길 뻔한 경험에서 나온 안전장치)
- **포스트 변환 시 민감정보 재검토**: 위키 페이지 자체는 안전해도, 포스트로
  재구성하는 과정에서 사용자가 준 원본 자료(`wiki/raw/`)의 세부 내용이
  과도하게 노출되지 않도록 요약 수준을 유지한다
- **wiki/ 디렉토리 build 제외 누락 시**: `_config.yml` exclude 설정이 안
  먹으면 위키 원본 메모가 그대로 사이트에 노출될 수 있음 — 구현 후 반드시
  로컬 빌드로 `_site/wiki/`가 생성 안 되는지 확인

## 테스트 계획

1. `.claude/skills/wiki-ingest/SKILL.md` 작성 후, 실제로 짧은 샘플 자료
   하나를 ingest 시켜서 `wiki/concepts/*.md`, `wiki/index.md`, `wiki/log.md`가
   스펙대로 생성/갱신되는지 확인
2. 그 위키 페이지를 포스트로 변환해서 `_posts/`에 카테고리 `Wiki`로 생성되고,
   문체가 블로그 톤으로 바뀌었는지 확인
3. `_config.yml`에 `wiki` exclude 추가 후 `bundle exec jekyll build` (또는
   Actions CI)로 `_site/wiki/`가 생성 안 됨을 확인
4. 전체 사이트 빌드가 여전히 정상인지(htmlproofer 포함) 확인

## 범위 밖 (Out of Scope)

- `projects/<name>/` 같은 다중 프로젝트 위키 구조 (이 저장소는 단일 주제)
- ADR 포맷 강제 (`decisions/`는 자유 형식)
- 위키 페이지 자체를 사이트에 공개하는 기능 (위키는 항상 비공개 소스 자료,
  발행되는 건 변환된 포스트뿐)
- 포스트 변환 자동 커밋/푸시 (기존 `post` 스킬과 동일하게 파일 생성까지만,
  커밋은 사용자가 직접)
