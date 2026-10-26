---
title: "맷 포콕 AI 코딩 스킬 1.3 업데이트 정리 — implement-spec, pr, retro"
date: 2026-10-26 14:40:00 +0900
categories: [AI]
tags: [ClaudeCode, 에이전트스킬, mattpocock-skills, 코딩에이전트]
---

맷 포콕(Matt Pocock)의 코딩 에이전트 스킬 모음 [mattpocock/skills](https://github.com/mattpocock/skills)가 1.3 버전으로 올라가며 새 스킬이 여럿 들어왔다. 민둥이 채널이 이 업데이트를 5분 분량으로 정리한 영상을 기준으로, 각 스킬이 실제로 어떻게 동작하는지는 공식 레포의 문서(`docs/`)와 `CHANGELOG.md`로 확인해 덧붙였다.

> 민둥이 | 쉽게 배우는 AI, "SNS에서 난리났다는데.. 맷 포콕 AI코딩 스킬 업데이트 완벽 정리" (2026-10-22, 4분 41초). 영상 속 화면은 맷 포콕 본인 채널의 영상 2편을 인용한 것이다.

{% include video id="ZE4hmiGglTM" provider="youtube" %}

## mattpocock/skills는 어떤 레포인가

![mattpocock/skills GitHub 저장소 첫 화면](/assets/img/posts/matt-pocock-skills-update/repo.png)

README 첫 문장은 "바이브 코딩이 아니라 실제 엔지니어링에 매일 쓰는 에이전트 스킬"이다. GSD, BMAD, Spec-Kit 같은 도구가 개발 절차 전체를 쥐는 것과 달리, 이 스킬들은 **작고, 고쳐 쓰기 쉽고, 조합할 수 있게** 만들었다고 설명한다. 캡처 시점(10-26) 기준 스타 약 30.3만 개, 최신 릴리스는 v1.3.1이다.

레포의 스킬은 용도별 폴더로 나뉜다.

| 폴더 | 주요 스킬 |
|---|---|
| `skills/productivity` | grill-me, grilling, wait-what, handoff, teach, writing-for-agents |
| `skills/engineering` | grill-with-docs, to-spec, to-tickets, implement, **implement-spec**, **pr**, **retro**, code-review, tdd, diagnosing-bugs, triage, setup-matt-pocock-skills 등 |
| `skills/in-progress` | 아직 다듬는 중인 스킬 (chief-of-staff, loop-me 등) |

굵게 표시한 세 개가 이번 1.3.0에서 정식(engineering) 폴더로 올라온 스킬이다. `CHANGELOG.md`에는 implement-spec, pr, retro를 "Graduate"한다고 적혀 있다.

## 설치

![README의 설치 안내 부분](/assets/img/posts/matt-pocock-skills-update/install.png)

Claude Code에서는 공식 플러그인 마켓플레이스로 설치한다. 플러그인으로 깔면 스스로 업데이트된다.

```bash
claude plugin install mattpocock-skills@claude-plugins-official
```

그다음 **저장소마다 한 번** 설정 스킬을 실행한다.

```
/setup-matt-pocock-skills
```

이 스킬은 세 가지를 묻는다. 어떤 이슈 트래커를 쓸지(GitHub, GitLab, 로컬 파일 등), 티켓을 분류할 때 붙이는 라벨은 무엇인지(`/triage`가 쓴다), 스킬이 만드는 문서를 어디에 저장할지다. Codex, GitHub Copilot, Gemini CLI용 설치 명령도 README에 따로 있다. README는 플러그인과 `npx skills` 방식 중 **하나만** 고르라고 강조한다. 둘 다 깔면 모든 스킬이 두 번씩 들어가기 때문이다.

영상은 AI에게 일을 맡기는 순서대로 스킬을 소개한다. 원하는 것 정리 → 설명 다시 듣기 → 구현 → 검토 → 돌아보기 순이다.

## 1. 원하는 것 정리하기: grill-me / grill-with-docs

![grilling 질문에 추천 답이 붙고, "1번, 2번 좋아"로 답하는 장면](/assets/img/posts/matt-pocock-skills-update/grill.png)

grill-me와 grill-with-docs는 AI가 질문을 던져서 내가 원하는 것과 빠뜨린 조건을 정리하게 하는 스킬이다. README가 "가장 인기 있는 스킬"이라고 부르는 것이고, 변경을 시작할 때마다 쓰라고 권한다. 둘의 차이는 grill-with-docs가 작업 폴더 안에서 돌면서 용어집(`GLOSSARY.md`)과 설계 결정 기록(ADR)을 함께 써 준다는 점이다.

이번에 바뀐 것은 **질문을 묶는 방식**이다. 영상 설명대로, 함께 답할 수 있는 질문은 한 번에 묻고, 앞의 답에 따라 달라지는 질문은 다음 차례로 넘긴다. 질문마다 추천 답도 붙어 있어서 "1번, 2번은 좋아, 3번은 이렇게 바꿔 줘"처럼 답하면 된다.

공식 문서(`docs/productivity/grilling.md`)는 이를 **설계 트리와 프론티어**로 설명한다. 결정 하나하나가 그에 딸린 결정으로 가지를 치는데, 매 라운드에는 "선행 결정이 모두 정해진 질문"만 묻는다. 서로 의존하는 두 질문은 같은 라운드에 나오지 않는다. 문서에 따르면 이렇게 하면 질문 13개가 보통 13번이 아니라 3라운드 정도에 끝난다.

## 2. 설명이 어려울 때: wait-what

![에이전트가 "예약 요청의 멱등성을 보장해야 합니다"라고 말해 사람이 이해하지 못하는 장면](/assets/img/posts/matt-pocock-skills-update/wait-what.png)

에이전트 설명을 따라가지 못했을 때 `/wait-what`을 입력하면, 빠진 맥락을 보충해 쉽게 다시 설명해 준다. 영상의 예는 "예약 요청의 멱등성을 보장해야 합니다"라는 말을 "사용자가 예약 버튼을 두 번 눌러도 예약은 하나만 만들어지게 하자는 뜻"으로 풀어 주는 것이다.

공식 문서의 설명이 흥미롭다. 이 스킬은 **세 줄짜리**이고, 그게 설계라고 한다. 간결하게 말하라는 스킬은 길어질수록 실패하는데, 모델이 요청이 아니라 스킬의 길이를 따라 하기 때문이라는 것이다. 또 "간결하게 해"는 출력에 대한 지시라서 모델이 단어만 잘라 내 더 알아듣기 어려워지는 반면, **"wait"는 듣는 사람의 상태**("여기서 놓쳤다")를 말하므로 에이전트가 되돌아가 설명한다는 게 이름에 담긴 아이디어다. 사용자가 직접 입력하는 스킬이고, 에이전트가 스스로 부르지 않는다.

## 3. 구현 맡기기: implement-spec

![예약 저장, 예약받기, 예약 취소하기 작업이 순서대로 진행되는 그림](/assets/img/posts/matt-pocock-skills-update/implement-spec.png)

`/implement-spec`은 명세서(spec)와 그것을 나눈 티켓들을 받아 **한 번에 구현까지** 끝내는 스킬이다. 명세서는 `/to-spec`, 티켓은 `/to-tickets`로 미리 만든다.

영상의 예약 서비스 예로 보면, "예약 정보 저장"이 있어야 "예약받기"와 "예약 취소"를 만들 수 있다. implement-spec은 티켓을 목록이 아니라 **작업 그래프**로 읽어서, 막고 있는 작업이 다 끝난 티켓(프론티어)을 동시에 여러 하위 에이전트에게 맡긴다. 공식 문서와 CHANGELOG에 적힌 동작은 이렇다.

- 하위 에이전트마다 **자기 git worktree**에서 일하고, 티켓을 `tdd` 스킬로 한 조각씩 빨강→초록으로 만든다.
- 끝난 브랜치는 하나의 **통합 브랜치**로 합친다. 각 에이전트가 보고 전에 통합 브랜치 끝을 먼저 자기 브랜치에 합쳐 두기 때문에, 합칠 때는 fast-forward가 된다.
- 마지막에 `code-review`로 전체를 검토하고 티켓을 닫는다.
- 목표는 PR이 아니라 통합 브랜치다. 이슈 트래커가 PR로 일을 닫는 방식이거나 사용자가 요청할 때만 초안 PR을 연다.
- 이슈 트래커 설정이 없으면 추측하지 않고 `/setup-matt-pocock-skills`부터 하라고 멈춘다.

티켓을 하나씩 자기 대화창에서 처리하고 싶으면 기존 `/implement`를 쓰면 된다고 문서가 구분해 둔다.

## 4. 검토하기 쉽게: pr

![pr 스킬의 PR 본문 템플릿. Summary, Evidence(Before/After), Door](/assets/img/posts/matt-pocock-skills-update/pr.png)

`pr`은 PR 본문의 모양을 정하는 스킬이다. 브랜치를 올리거나 PR을 여는 일은 하지 않고, 본문을 어떻게 쓸지만 정한다. 사용자가 `/pr`로 부를 수도 있고, 에이전트가 PR 본문을 쓸 때 알아서 불러 쓰기도 한다. 본문은 세 부분이다.

| 부분 | 내용 |
|---|---|
| **Summary** | 변경을 보여 주는 가장 작은 그림. 의사 코드, 호출 트리, 컴포넌트 트리, 파일 트리, Mermaid 다이어그램, 모양만 잡은 diff 중에서 고른다 |
| **Evidence** | 수정 전후 비교. 화면이 바뀌면 스크린샷, 아니면 실패하다 통과하게 된 테스트나 바뀐 콘솔 출력 |
| **Merge Danger** | 되돌리기 쉬운 변경(two-way door)인지 어려운 변경(one-way door)인지, 그리고 잘못됐을 때 영향 범위(blast radius) |

영상의 예는 "예약 정원을 넘겨도 예약이 들어가는 버그"다. 저장 전에 남은 자리를 확인하는 흐름을 그림으로 보여 주고, 수정 전에는 통과하던 초과 예약이 수정 후 막히는 테스트를 붙이고, 다른 기능에 줄 영향과 되돌릴 수 있는지를 정리한다.

## 5. 실수를 경험으로: retro

![retro 결과 화면. 가장 심각한 발견부터 나열하고 자동 검사 추가를 제안한다](/assets/img/posts/matt-pocock-skills-update/retro.png)

영상이 이번 업데이트에서 가장 화제가 된 기능, 맷 포콕이 직접 "SNS에서 난리가 났다"고 말한 기능으로 소개한 스킬이다. `/retro`는 지금 세션(또는 지정한 이전 세션)의 기록을 읽고, 에이전트가 헤맨 순간을 찾아 **다음에는 무엇을 바꾸면 좋을지** 심각한 것부터 제안한다. 위 화면에서는 "에이전트가 사용자가 고르기 전에 되돌릴 수 없는 공개 작업(태그 push)을 실행했다"는 발견에 "git push 전에 묻는 PreToolUse 훅을 추가하자"는 수정안이 붙어 있다. 영상에 따르면 맷 포콕이 자기 작업에 돌려 봤더니 "검사 스크립트를 만들어 놓고 아무도 실행하지 않고 있다"는 지적이 나왔다고 한다. 화면의 두 번째 발견("`pnpm check`는 있는데 그것을 돌리는 CI도 git 훅도 없다")이 바로 그런 경우다.

공식 문서(`docs/engineering/retro.md`)에서 눈여겨볼 점은 **코드가 아니라 에이전트가 일하는 환경을 고친다**는 것이다. 발견의 종류에 따라 고칠 곳이 정해져 있다.

| 세션에서 생긴 문제 | 고치는 방법 |
|---|---|
| 파일이나 사실을 찾는 데 오래 걸렸다 | 에이전트가 이미 읽는 파일에 위치 안내를 넣는다 |
| 도구가 잡을 수 있는 실수를 했다 | 자동 검사(린트 규칙, 타입, 테스트, pre-commit 훅, CI 작업)를 넣는다 |
| 리뷰어가 판단이 필요한 실수를 놓쳤다 | 리뷰어 에이전트가 읽는 `CODING_STANDARDS.md`에 규칙을 넣는다 |
| `AGENTS.md`나 `CLAUDE.md`가 너무 크다 | 그 안의 지시를 표준 문서나 검사로 옮긴다 |
| 도구 호출 비용에 비해 얻는 게 적었다 | 도구를 다듬거나 다른 도구로 바꾼다 |
| 지시 파일에 아무 효과 없는 줄이 많다 | 그 줄을 지운다 |
| 필요한 정보에 접근하지 못했다 | 접근 범위를 넓힌다 (개발 서버 로그를 파일로 남기기, 서비스 읽기 전용 권한 등) |

기계적으로 판별할 수 있는 위반이면 문장이 아니라 **실패하는 검사**로 만든다. 판단이 필요한 것만 글로 남긴다. 그리고 `CLAUDE.md`에 줄을 늘리는 것을 가장 경계한다. 모든 세션에 매번 읽혀서 다른 내용의 비중을 줄이고, 코드가 바뀌면 낡기 때문이다.

retro는 **제안만** 한다. 사용자가 후보를 고르기 전에는 아무것도 바꾸지 않고 훅도 자동으로 설치하지 않는다. 영상에서도 맷 포콕이 이것을 자동으로 돌리지 말라고 했다고 전한다. 문서도 매 세션마다 돌리면 필요 없는 규칙만 쌓인다며, 에이전트가 유난히 헤맨 세션을 골라 돌리라고 권한다.

## 기존 사용자 주의: CONTEXT.md → GLOSSARY.md

![domain-modeling 스킬 문서에서 CONTEXT.md가 GLOSSARY.md로 바뀌는 장면](/assets/img/posts/matt-pocock-skills-update/glossary.png)

이미 이 스킬을 쓰고 있었다면 꼭 챙길 부분이다. 1.3.0부터 용어집 파일 이름이 `CONTEXT.md`/`CONTEXT-MAP.md`에서 `GLOSSARY.md`/`GLOSSARY-MAP.md`로 바뀌었다. 1.3.0 이후로는 기존 스킬까지 모두 새 이름만 찾는다. CHANGELOG는 기존 파일을 `git mv`로 옮기라고 안내한다.

```bash
git mv CONTEXT.md GLOSSARY.md
git mv CONTEXT-MAP.md GLOSSARY-MAP.md   # 쓰고 있었다면
```

같은 릴리스에서 `resolving-merge-conflicts` 스킬은 대체 없이 빠졌다. 에이전트가 별도 스킬 없이도 병합·리베이스 충돌을 처리할 수 있게 됐다는 이유다.

## 정리

| 단계 | 스킬 | 누가 부르나 |
|---|---|---|
| 원하는 것 정리 | grill-me, grill-with-docs (질문 묶음 + 추천 답) | 사용자 |
| 설명 다시 듣기 | wait-what | 사용자 |
| 한 번에 구현 | implement-spec (작업 그래프, worktree 병렬, 통합 브랜치) | 사용자 |
| PR 본문 | pr (Summary, Evidence, Merge Danger) | 사용자 또는 에이전트 |
| 돌아보기 | retro (환경을 고치는 제안만) | 사용자 |

영상의 마지막 조언처럼 처음부터 모든 스킬을 쓸 필요는 없다. 에이전트와 일하면서 가장 불편했던 지점에 맞는 스킬 하나부터 써 보면 된다. 개인적으로는 retro의 방향이 가장 와닿는다. 에이전트가 같은 실수를 반복할 때 `CLAUDE.md`에 한 줄씩 덧붙이기 쉬운데, retro는 그 습관을 정면으로 반대하고 실패하는 검사로 바꾸라고 한다.
