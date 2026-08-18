# 블로그 LLM 위키 + 자동 포스트 변환 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** [Karpathy LLM Wiki 패턴](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)을
이 저장소(`redskelt.github.io`) 안에 개인 학습 위키로 이식하고, 위키 페이지를
블로그 포스트로 변환하는 경로를 추가한다.

**Architecture:** `wiki/` 디렉토리(Jekyll 빌드 제외)에 원본 자료(`raw/`)와
Claude가 관리하는 위키 페이지(`concepts/`, `decisions/`)를 두고, `index.md`/
`log.md`로 카탈로그·이력을 관리한다. `.claude/skills/wiki-ingest/SKILL.md`가
ingest/query/lint 워크플로우와 "위키 → 포스트" 변환 절차를 정의하며, 변환
단계는 기존 `.claude/skills/post/SKILL.md`의 "작성" 절차를 그대로 재사용한다.

**Tech Stack:** Jekyll 4.x/jekyll-theme-chirpy (기존), Claude Code 스킬
(`.claude/skills/`)

**Spec:** `docs/superpowers/specs/2026-08-18-blog-llm-wiki-design.md`

## Global Constraints

- `wiki/` 디렉토리는 반드시 `_config.yml`의 `exclude`에 등록해 사이트로
  빌드되지 않아야 한다.
- 위키는 "일반 개인 지식/학습"만 다룬다 — 회사/업무 종속 자료 유입 금지
  (스펙의 리스크 섹션 참고).
- 위키 출신 포스트의 카테고리는 항상 `Wiki`로 고정한다.
- 위키 → 포스트 변환은 기존 `.claude/skills/post/SKILL.md`의 "작성" 절차를
  재사용한다 (git add/commit/push는 여전히 자동으로 하지 않는다).
- `projects/<name>/` 계층, `wiki/prd/`, ADR 강제 포맷은 이번 범위에 없다
  (스펙의 Out of Scope 참고).

---

### Task 1: 위키 디렉토리 스캐폴드 + Jekyll 빌드 제외 설정

**Files:**
- Modify: `_config.yml`
- Create: `wiki/index.md`
- Create: `wiki/log.md`
- Create: `wiki/raw/.gitkeep`
- Create: `wiki/raw/assets/.gitkeep`
- Create: `wiki/concepts/.gitkeep`
- Create: `wiki/decisions/.gitkeep`

**Interfaces:**
- Produces: `wiki/` 디렉토리 구조와, Jekyll이 이 디렉토리를 빌드에서
  제외하는 상태. Task 2의 스킬이 이 경로들을 전제로 동작한다.

- [x] **Step 1: `_config.yml`의 `exclude` 목록에 `wiki` 추가**

`_config.yml`에서 다음 블록을 찾는다:

```yaml
exclude:
  - "*.gem"
  - "*.gemspec"
  - docs
  - tools
  - README.md
  - LICENSE
```

`wiki` 항목을 추가해 다음으로 수정한다:

```yaml
exclude:
  - "*.gem"
  - "*.gemspec"
  - docs
  - tools
  - README.md
  - LICENSE
  - wiki
```

- [x] **Step 2: `wiki/index.md` 생성**

```markdown
# Wiki Index

위키의 모든 페이지 카탈로그. ingest할 때마다 업데이트한다.

---

## 개념

<!-- 형식: - [[concepts/concept-name]] — 한줄 요약 -->

*(아직 페이지 없음)*

---

## 결정/회고

<!-- 형식: - [[decisions/topic-name]] — 한줄 요약 -->

*(아직 페이지 없음)*

---

_마지막 업데이트: 2026-08-18 (초기화)_
```

- [x] **Step 3: `wiki/log.md` 생성**

```markdown
# Wiki Log

append-only 작업 로그. 항목을 삭제하거나 수정하지 않는다.

각 항목 형식: `## [YYYY-MM-DD] <action> | <제목>`
- action: `ingest` | `query` | `lint` | `post`

grep 사용법: `grep "^## \[" wiki/log.md | tail -5`

---

## [2026-08-18] init | 위키 초기화
디렉토리 구조, wiki-ingest 스킬, index.md, log.md 생성
```

- [x] **Step 4: 빈 디렉토리 유지용 `.gitkeep` 생성**

```bash
mkdir -p wiki/raw/assets wiki/concepts wiki/decisions
touch wiki/raw/.gitkeep wiki/raw/assets/.gitkeep wiki/concepts/.gitkeep wiki/decisions/.gitkeep
```

- [x] **Step 5: 로컬 빌드로 제외 확인**

로컬에 Ruby/rbenv가 없다면 이 Step은 GitHub Actions 결과로 대체 확인한다
(아래 참고). 로컬 환경이 있다면:

```bash
export PATH="$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
bundle exec jekyll build
ls _site/wiki 2>&1   # "No such file or directory" 나와야 정상
```

로컬 환경이 없다면 이 커밋을 push한 뒤 GitHub Actions의 "Build and Deploy"
워크플로우 성공 여부와, 배포된 사이트에 `https://redskelt.github.io/wiki/`가
404인지로 대체 검증한다:

```bash
curl -s -o /dev/null -w "%{http_code}\n" https://redskelt.github.io/wiki/index.html
```

Expected: `404` (exclude가 제대로 먹었다면 이 경로 자체가 존재하지 않음)

- [x] **Step 6: 커밋**

```bash
git add _config.yml wiki/
git commit -m "chore: scaffold personal wiki directory (excluded from Jekyll build)"
```

---

### Task 2: `wiki-ingest` 스킬 작성

**Files:**
- Create: `.claude/skills/wiki-ingest/SKILL.md`

**Interfaces:**
- Consumes: Task 1의 `wiki/` 디렉토리 구조
- Produces: `/wiki-ingest` 커맨드(또는 "이거 위키에 정리해줘" 같은 자연어
  트리거)로 호출 가능한 ingest/query/lint/post-변환 워크플로우. 포스트
  변환 단계는 기존 `.claude/skills/post/SKILL.md`의 "작성" 절차를 그대로
  호출한다.

- [x] **Step 1: `.claude/skills/wiki-ingest/SKILL.md` 생성**

```markdown
---
name: wiki-ingest
description: 자료/링크/메모를 개인 학습 위키(wiki/)에 정리해 넣거나(ingest), 위키 페이지를 찾아보거나(query), 위키 상태를 점검하고(lint), 위키 페이지를 블로그 포스트로 변환할 때 사용. "이거 위키에 정리해줘", "위키 점검해줘", "이 위키 페이지 포스트로 만들어줘" 같은 요청에 사용.
---

# 개인 학습 위키 (Ingest / Query / Lint / Post 변환)

이 저장소의 `wiki/` 디렉토리는 [Karpathy의 LLM Wiki 패턴](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)을
따르는 개인 학습/지식 위키다. RAG처럼 매번 원본에서 다시 찾지 않고, 자료를
읽을 때마다 위키 자체를 갱신해 지식이 누적되게 한다. `wiki/`는 `_config.yml`의
`exclude`에 등록돼있어 사이트로는 빌드되지 않는다 — 순수 소스 자료 저장소다.

## 디렉토리 구조

- `wiki/raw/` — 원본 소스(사용자가 준 텍스트/링크 사본). **읽기 전용, 절대
  수정하지 않는다.**
- `wiki/raw/assets/` — 원본 첨부 이미지 등.
- `wiki/concepts/` — 기술/지식 개념 페이지.
- `wiki/decisions/` — 개인적 판단/회고 기록 (자유 형식, ADR 아님).
- `wiki/index.md` — 전체 페이지 카탈로그. ingest할 때마다 갱신.
- `wiki/log.md` — append-only 작업 로그. 항목을 삭제/수정하지 않는다.

## 크로스레퍼런스 규칙

페이지 간 링크는 Obsidian wikilink 문법 사용: `[[concepts/concept-name]]`,
`[[decisions/topic-name]]`.

## 회사/업무 자료 유입 방지

이 위키는 **일반 개인 지식만** 다룬다. ingest 요청 내용이 특정 회사·비공개
프로젝트에 종속된 자료로 보이면(사내 시스템 이름, DB 스키마, 회원/직원
정보 등) ingest 전에 반드시 사용자에게 "이거 공개 저장소에 들어가도 되는
내용이 맞냐"고 먼저 확인한다.

## Workflow: Ingest

**트리거:** 사용자가 자료(텍스트, 링크, 메모)를 주며 위키에 정리해달라고
요청할 때.

**절차:**
1. 위 "회사/업무 자료 유입 방지" 확인
2. 원본을 `wiki/raw/<오늘날짜>-<slug>.md`로 저장 (이후 수정 안 함)
3. 핵심 내용 파악 후 사용자에게 주요 takeaway 3~5개 요약
4. `wiki/concepts/<concept-name>.md` 생성 또는 기존 페이지 업데이트
   (파일명 kebab-case), 아래 포맷 사용
5. 기존 페이지와 내용이 모순되면 임의로 덮어쓰지 않고 모순을 명시한 뒤
   사용자에게 확인
6. `wiki/index.md`의 "개념" 섹션에 새/갱신 페이지 반영
7. `wiki/log.md`에 항목 추가:
   ```
   ## [YYYY-MM-DD] ingest | <제목>
   처리 내용 한 줄 요약
   ```
8. **사용자에게 확인:** "이거 블로그 포스트로도 만들까?"
   - yes → "Workflow: Wiki → Post 변환"으로 진행
   - no → ingest 종료

**개념 페이지 포맷:**

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

## Workflow: Wiki → Post 변환

**트리거:** ingest 직후 "포스트로 만들까?"에 yes로 답했을 때, 또는 사용자가
특정 위키 페이지를 지목하며 포스트로 만들어달라고 요청할 때.

**절차:**
1. 대상 위키 페이지(`wiki/concepts/*.md` 또는 `wiki/decisions/*.md`) 읽기
2. 구조화된 메모 문체를 블로그 톤(기존 `_posts/`의 구어체 설명조 —
   1인칭 서술, "~했다"/"~인 것 같다")으로 다시 쓴다. 위키 페이지의 섹션
   구조(개요/동작원리)를 그대로 헤딩으로 옮기지 말고 자연스러운 글 흐름으로
   재구성
3. 이후는 `.claude/skills/post/SKILL.md`의 "작성" 절차를 그대로 따른다.
   단:
   - **카테고리는 항상 `Wiki`로 고정** (post 스킬의 "공통: 기존 카테고리
     확인" 절차는 생략)
   - 위키 페이지 주제에 맞는 `tags`를 붙인다
   - "공통: 본문에 링크가 있으면 링크 확인" 절차는 그대로 적용
   - 생성된 포스트에 위키 페이지로 돌아가는 링크는 넣지 않는다 (`wiki/`는
     빌드 제외 대상이라 죽은 링크가 됨)
4. `wiki/log.md`에 항목 추가:
   ```
   ## [YYYY-MM-DD] post | <위키 페이지 경로> → <포스트 slug>
   ```

## Workflow: Query

**트리거:** 사용자가 위키 관련 질문을 하거나 특정 주제 설명을 요청할 때.

**절차:**
1. `wiki/index.md`를 읽어 관련 페이지 파악
2. 관련 페이지들을 읽고 답변 합성, 출처는 `[[wikilink]]`로 명시
3. 답변이 독립적 가치를 가지면(비교표, 분석, 발견한 연결관계 등) 새 위키
   페이지로 저장 제안

## Workflow: Lint

**트리거:** 사용자가 "위키 점검해줘" 요청 시.

**점검 항목:**
1. 모순되는 내용 (페이지 간 상충되는 설명)
2. 깨진 `[[wikilink]]` (존재하지 않는 페이지 참조)
3. 고아 페이지 (인바운드 링크 없는 페이지)
4. 오래된 내용 (원본 갱신 후 반영 안 된 페이지)
5. 중요 개념이 언급됐으나 전용 페이지가 없는 경우

**결과:** lint 리포트 출력, 수정 여부 확인. `wiki/log.md`에 항목 추가:

```
## [YYYY-MM-DD] lint | 점검 결과 요약
발견된 이슈 수, 수정된 이슈 수
```

---

이 스키마는 [Karpathy의 LLM Wiki 패턴](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)을
따른다. 회사 프로젝트용 위키는 별도로 `~/Documents/ai-docs/llm-wiki`에서
운영 중이며 이 저장소 위키와는 무관하다.
```

- [x] **Step 2: 커밋**

```bash
git add .claude/skills/wiki-ingest/SKILL.md
git commit -m "feat: add wiki-ingest skill (ingest/query/lint + wiki-to-post conversion)"
```

---

### Task 3: 엔드투엔드 검증 (샘플 ingest → 포스트 변환 → 전체 빌드)

**Files:**
- Create (검증용, 최종적으로 남김): `wiki/raw/2026-08-18-sample-topic.md`,
  `wiki/concepts/<샘플-개념>.md`
- Modify: `wiki/index.md`, `wiki/log.md`
- Create (검증용): `_posts/2026/2026-08-18-<샘플-슬러그>.md`

**Interfaces:**
- Consumes: Task 1의 디렉토리 구조, Task 2의 `wiki-ingest` 스킬 절차
- Produces: 스킬이 실제로 스펙대로 동작한다는 증거 (위키 페이지 생성,
  index/log 갱신, 포스트 변환, 전체 사이트 빌드 성공)

- [x] **Step 1: 샘플 자료로 ingest 실행**

`wiki-ingest` 스킬의 "Workflow: Ingest" 절차를 다음 샘플 입력으로 직접
실행한다 (실제 사용자 자료 아님, 스킬 동작 검증용):

> 주제: "멱등성(Idempotency)이란 같은 요청을 여러 번 보내도 결과가
> 한 번 보낸 것과 같은 성질이다. HTTP에서 GET/PUT/DELETE는 멱등해야
> 하고 POST는 아니다. 분산 시스템에서 재시도 로직을 안전하게 만들려면
> 멱등키(idempotency key)를 써서 중복 처리를 막는다."

절차대로:
1. `wiki/raw/2026-08-18-idempotency.md`에 위 텍스트 그대로 저장
2. takeaway 3~5개 요약 (예: HTTP 메서드별 멱등성 여부, 멱등키를 통한
   재시도 안전성 확보, 분산 시스템에서의 필요성)
3. `wiki/concepts/idempotency.md` 생성 (스킬 문서의 개념 페이지 포맷 사용)
4. `wiki/index.md`의 "개념" 섹션에 `- [[concepts/idempotency]] — HTTP
   멱등성 정의와 분산 시스템에서의 활용` 한 줄 추가
5. `wiki/log.md`에 `## [2026-08-18] ingest | 멱등성(Idempotency)` 항목 추가

Expected: 4개 파일이 스킬 문서에 정의된 포맷대로 생성/갱신됨. `wiki/raw/`
파일은 원본 그대로, `wiki/concepts/idempotency.md`는 front matter(`title`,
`sources`, `updated`) + 개요/동작원리 섹션을 갖춤.

- [x] **Step 2: 위키 페이지 확인**

```bash
cat wiki/concepts/idempotency.md
cat wiki/index.md
tail -5 wiki/log.md
```

Expected: front matter 3개 필드 모두 채워짐, `index.md`에 새 항목 반영,
`log.md`에 append된 한 줄이 기존 `init` 항목을 지우지 않고 그 아래 추가됨.

- [x] **Step 3: "Workflow: Wiki → Post 변환" 실행**

`wiki/concepts/idempotency.md`를 대상으로 변환 절차 실행:
1. 위키 페이지 내용을 블로그 톤으로 재구성
2. `.claude/skills/post/SKILL.md`의 "작성" 절차 진행 — 카테고리
   `[Wiki]` 고정, 태그는 `[HTTP, 분산시스템]` 정도로 위키 페이지 주제에
   맞춰 정함, slug는 `idempotency`
3. `_posts/2026/2026-08-18-idempotency.md` 생성 (front matter:
   `title`, `date`, `categories: [Wiki]`, `tags: [HTTP, 분산시스템]`)
4. `wiki/log.md`에 `## [2026-08-18] post | wiki/concepts/idempotency.md →
   idempotency` 항목 추가

- [x] **Step 4: 생성된 포스트 확인**

```bash
cat _posts/2026/2026-08-18-idempotency.md
```

Expected: 위키 페이지의 "개요/동작 원리" 헤딩 구조 그대로가 아니라
자연스러운 문단 흐름으로 재구성돼있음. 카테고리 `Wiki`, front matter에
`layout`/`permalink` 없음(defaults가 자동 적용).

- [x] **Step 5: 전체 사이트 빌드 + 링크 검증**

로컬 Ruby 환경이 있다면:

```bash
export PATH="$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
bundle exec jekyll build
bundle exec htmlproofer _site --disable-external \
  --ignore-urls "/^http:\/\/127.0.0.1/,/^http:\/\/0.0.0.0/,/^http:\/\/localhost/"
ls _site/wiki 2>&1   # 여전히 없어야 함
find _site/posts -iname "*idempotency*"
```

로컬 환경이 없다면 커밋 후 push해서 GitHub Actions "Build and Deploy"
워크플로우 성공 여부로 대체 확인하고, 배포 후:

```bash
curl -s -o /dev/null -w "%{http_code}\n" https://redskelt.github.io/posts/idempotency/
curl -s -o /dev/null -w "%{http_code}\n" https://redskelt.github.io/wiki/index.html
```

Expected: 첫 번째 `200`, 두 번째 `404`.

- [x] **Step 6: 검증용 샘플 콘텐츠 처리 결정**

이 샘플(`wiki/concepts/idempotency.md`, `_posts/.../idempotency.md`)은
실제로 쓸만한 내용이라 그대로 남겨도 되고, 순수 검증용이라 지우고 싶으면
`.claude/skills/post/SKILL.md`의 "삭제" 절차로 포스트를 지우고 위키 쪽은
`wiki/index.md`/`log.md`에서 해당 항목만 정리한다. **어느 쪽으로 할지는
사용자에게 물어보고 결정한다** — 이 스텝 자체는 플랜에 결과를 강제하지
않는다.

- [x] **Step 7: 커밋**

Step 6에서 남기기로 했다면:

```bash
git add wiki/ _posts/
git commit -m "content: sample wiki-to-post conversion (idempotency) — validates wiki-ingest skill"
```

지우기로 했다면 삭제 반영 후:

```bash
git add -A
git commit -m "chore: remove wiki-ingest skill validation sample"
```

둘 다 아니라면(검증만 하고 그대로 두되 커밋은 나중에) 이 스텝은 생략하고
다음 세션에서 사용자가 직접 커밋하게 남겨둔다.

---

## 완료 후 사용자가 직접 해야 하는 작업 (플랜 범위 밖)

- 실제 학습 자료를 `wiki-ingest` 스킬로 ingest 시작 (`/wiki-ingest` 호출
  또는 "이거 위키에 정리해줘" 식 자연어 트리거)
- 위키가 어느 정도 쌓이면 주기적으로 "위키 점검해줘"(lint) 요청
