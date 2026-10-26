---
title: "pstack 입문 가이드 — 커서 개발자가 매일 쓰는 코딩 스킬, Claude Code에서 쓰기"
date: 2026-10-26 15:10:00 +0900
categories: [AI]
tags: [pstack, ClaudeCode, Cursor, 에이전트스킬, 코딩에이전트]
---

pstack은 Cursor 개발자 로렌 탄(Lauren Tan, 온라인 이름 poteto)이 **자기가 매일 쓰는 코딩 에이전트 스킬을 묶어 공개한 플러그인**이다. 민둥이 채널의 5분짜리 소개 영상을 따라가면서, 공식 저장소의 README와 가이드 문서(`docs/guide/`)로 내용을 확인하고 처음 쓰는 사람이 바로 따라 할 수 있게 정리했다.

> 민둥이 | 쉽게 배우는 AI, "실제 Cursor 개발에 쓰이는 고품질 코딩 스킬, /Pstack 사용법" (2026-10-15, 5분 7초)

{% include video id="gAt_rRweR7Q" provider="youtube" %}

## 한 줄 요약

**작업 앞에 `/poteto-mode`를 붙이고, "다 됐는지 확인할 방법"을 한 줄 덧붙인다.** 그러면 에이전트가 작업 종류에 맞는 절차를 골라, 이해 → 설계 → 구현 → 검증 순서로 일하고 증거와 함께 보고한다. 나머지 스킬은 대부분 이 모드가 알아서 불러 쓴다.

## pstack은 무엇인가

![cursor/plugins 저장소의 pstack 폴더](/assets/img/posts/pstack-guide/repo.png)

공식 위치는 Cursor의 플러그인 저장소 안 [`cursor/plugins/pstack`](https://github.com/cursor/plugins/tree/main/pstack)이다. README에서 로렌 탄은 Meta, Netflix, Cursor에서 수백만 줄의 코드를 다뤄 왔고, React 코어 팀에서 React Compiler를 만든다고 자신을 소개한다(영상은 그를 "스페이스X 수석 엔지니어"라고 소개한다).

README가 밝힌 목표는 세 가지다.

1. **적게, 하지만 높은 품질로.** "허술한 개발자 스무 명이 만든 것처럼 내보내고 싶지 않다." 코드 줄 수를 늘리는 게 아니라 줄이는 것이 목표다.
2. **두려움 없는 병렬 작업.** 에이전트 하나를 믿을 수 있게 만들면, 여러 에이전트를 같은 원칙으로 동시에 돌려도 안심할 수 있다.
3. **모델마다 잘하는 일을 나눈다.** 여러 스킬이 서로 다른 모델을 함께 쓰는 방식으로 만들어져 있다.

구성은 이렇다.

| 묶음 | 개수 | 설명 |
|---|---|---|
| `/poteto-mode` | 1 | 입구. 작업을 읽고 알맞은 플레이북을 고른다 |
| 플레이북 | 23개 | 버그 수정, 기능 개발, 리팩터링, 성능, 조사, 밤샘 실행 등 작업별 절차 |
| 스킬 | 34개 (`/poteto-mode` 포함) | how, why, architect, arena, swarm, interrogate, no-comments 등 |
| 원칙 | 24개 | "가장 작은 변경", "근본 원인을 고쳐라", "실제로 돌려 확인하라" 같은 한 줄 규칙 |

## 설치하기

![README의 install 부분. Cursor와 Claude Code 설치 명령](/assets/img/posts/pstack-guide/install.png)

### Cursor

Cursor 채팅창에서 실행한다.

```text
/add-plugin pstack
/setup-pstack
```

### Claude Code (공식 방법)

영상은 Claude Code용으로 커뮤니티 포팅판을 안내했지만, **영상이 올라온 다음 날(10-16) 공식 저장소에 Claude Code 설치가 추가됐다.** 지금은 공식 방법을 쓰면 된다. 터미널이 아니라 **Claude Code를 실행한 뒤 대화창에** 한 줄씩 입력한다.

```text
/plugin marketplace add cursor/plugins
/plugin install pstack@cursor-plugins
/pstack:setup-pstack
```

Claude Code에서 알아 둘 차이는 세 가지다.

- **명령 앞에 `pstack:`이 붙는다.** `/poteto-mode`는 `/pstack:poteto-mode`, `/setup-pstack`은 `/pstack:setup-pstack`이다. **이 글의 예시는 Cursor 기준으로 적었으니, Claude Code에서는 `/why` → `/pstack:why`처럼 모두 `pstack:`을 붙여 입력한다.**
- **자동 업데이트가 꺼져 있다.** 외부 마켓플레이스라서 설치한 버전에 머문다. 켜려면 Claude Code 대화창에서 `/plugin` → marketplaces 탭 → `cursor-plugins` → enable auto-update를 고른다. 한 번만 올리려면 일반 터미널에서 `claude plugin update pstack@cursor-plugins`를 실행한다.
- **Cursor 전용 기능은 바꾸거나 건너뛴다.** 예약·자동 실행(Cursor Automations)이 필요한 단계는 `Skipped in Claude Code: <단계>. <이유>.` 한 줄을 남기고 넘어간다. PR 자동 리뷰 봇(Bugbot)의 댓글은 일반 PR 리뷰로 처리하고, Cursor 클라우드 에이전트에 맡기는 일은 로컬 git worktree에서 돌린다. 클라우드 에이전트 자체가 꼭 필요한 단계만 건너뛴다.

### Codex, Pi, Copilot 등 (커뮤니티 포팅판)

영상이 소개한 [michael-denyer/pstack-claude](https://github.com/michael-denyer/pstack-claude)는 공식 pstack을 따라가며 Claude Code, Codex, Pi, GitHub Copilot 등으로 옮긴 커뮤니티 버전이다. Codex라면 이렇게 설치한다.

```shell
codex plugin marketplace add michael-denyer/pstack-claude
codex plugin add pstack@pstack-claude
```

Claude Code에는 공식 방법과 포팅판 중 **하나만** 설치하자. 둘 다 깔면 같은 스킬이 두 번 들어간다.

### 첫 설정: setup-pstack

`/setup-pstack`(Claude Code는 `/pstack:setup-pstack`)은 내가 쓸 수 있는 모델을 찾아 **역할마다 어떤 모델을 쓸지** 정해 준다. 묻는 것은 두 가지다. **추론 예산**(small, medium, large, unlimited)은 모델이 얼마나 깊이 생각할지, 즉 토큰을 얼마나 쓸지의 단계다. 기본은 large에 해당한다. 그리고 **역할별 모델**이다. 기본값은 이렇다.

| 역할 | 기본 모델 |
|---|---|
| 코드 작업 (기능, 리팩터링, 버그 수정, 성능, 지표 개선) | Grok |
| 가장 어려운 변경, 글, 판단 | Claude Opus 5.5 |
| 검토 패널 (같은 코드를 따로 검토하는 모델 묶음) | Opus 5.5 + Grok |

결과는 Cursor에서 `~/.cursor/rules/pstack-models.mdc`, Claude Code에서 `~/.claude/rules/pstack-models.md`에 저장된다. pstack은 일을 나눠 맡기려고 **하위 에이전트**(메인 에이전트가 띄우는 보조 에이전트)를 자주 띄운다. Claude Code는 하위 에이전트에 Claude 모델(opus, sonnet, haiku, fable)만 지정할 수 있다. 그래서 Claude Code의 setup-pstack은 Grok 기본값을 `inherit-parent`로 바꿔 저장하고, 그 역할은 **따로 손대지 않아도 지금 세션 모델로 돌아간다.** 설정이 끝나면 새 채팅을 연다. 모델 규칙은 새 세션부터 적용된다.

설정 마지막에 프로젝트에 아직 없으면 두 가지를 한 번씩 묻는다.

- **검증 스킬을 만들까?** 공식 가이드는 처음이라면 **예**라고 답하라고 권한다. 자기 일을 확인할 수 있는 에이전트는 통과할 때까지 계속 일하지만, 확인할 수 없는 에이전트는 결과를 매번 사람에게 넘기기 때문이다(아래 "4. 실제로 돌려서 확인하기").
- **정형 검증(formal verification) 스킬을 만들까?** "같은 작업이 동시에 두 번 돌지 않는다" 같은 성질 하나를 모든 경우에 대해 증명하는 스킬이다. 동시성, 재시도, 상태 기계, 파서처럼 테스트로 잡기 어려운 코드가 있을 때만 예, 아니면 아니요로 넘어가면 된다.

## 기본 사용법: /poteto-mode

![poteto-mode 뒤에 원하는 작업과 done means(끝났다고 볼 기준)를 적는 장면](/assets/img/posts/pstack-guide/done-means.png)

쓰는 법은 단순하다. `/poteto-mode` 뒤에 하고 싶은 일을 동료에게 말하듯 쓰고, **다 됐는지 확인할 방법**을 한 줄 붙인다.

```text
/poteto-mode 재시도한 뒤 사용자에게 알림이 두 번 간다. 먼저 재현하고, 고치고, 검증해.
```

에이전트는 요청을 읽고 23개 플레이북 중 하나(여기서는 버그 수정)를 고른 뒤, 그 절차를 에이전트 화면의 할 일(Todo) 목록 맨 위에 그대로 옮겨 적는다. 건너뛴 단계도 `skip: <이유>`로 목록에 남아서, 무엇을 안 했는지 볼 수 있다.

![버그 수정 플레이북의 흐름. 재현 → 원인 → 수정 → 재확인](/assets/img/posts/pstack-guide/bug-fix-flow.png)

버그 수정이라면 먼저 문제를 직접 재현하고, 로그 같은 증거로 원인을 찾고, 필요한 부분만 고친 뒤, 같은 조건에서 다시 확인한다. 마지막 보고에는 실패했던 결과와 고친 뒤 결과가 함께 들어간다.

### 좋은 요청에 들어가는 다섯 가지

공식 가이드(`02-poteto-mode.md`)는 요청에 다음 다섯 가지를 한 문장씩 넣으라고 한다.

| 넣을 것 | 예 |
|---|---|
| 목표 | "CSV 내보내기에서 마지막 행이 빠진다" |
| 끝났다고 볼 기준 (통과/실패가 갈리는 것) | "6만 행 테스트 데이터가 전부 나오면 끝" |
| 보고 싶은 증거 | "수정 전후 행 수를 보여 줘" |
| 이미 아는 것 | "어제 배포 이후부터, 실패한 작업 번호 4812" |
| 진짜 제약 | "먼저 재현해", "코드는 아직 고치지 마", "동작은 하나도 바꾸지 마" |

반대로 **빼면 좋은 것**도 두 가지다. "어떻게 하라"는 방법(에이전트가 더 나은 길을 찾을 여지를 남긴다)과, 처음부터 원인을 짐작해 말하는 것(그쪽으로만 찾게 된다)이다. "더 좋게 해 줘", "한 시간 동안 해 봐"는 통과/실패가 갈리지 않아서 기준이 될 수 없다.

### 대화 내내 켜 두기 (Cursor)

Cursor에서 `/` 메뉴로 `/poteto-mode`를 고른 뒤 Enter 대신 **Option+Enter**(Windows는 Alt+Enter)를 누르면 커스텀 모드가 되어, 나갈 때까지 매 턴 적용된다. 그냥 Enter는 그 메시지 한 번에만 붙는다.

## 처음 써 보는 순서

1. 설치하고 `setup-pstack`으로 모델을 고른다. 검증 스킬을 만들겠냐고 물으면 예.
2. 새 채팅을 연다.
3. 실제로 할 작은 일 하나를 고른다. 공식 가이드의 첫 예제는 이렇다.

   ```text
   /poteto-mode 이 명령에 --json 옵션을 추가해. 기존 텍스트 출력은 한 글자도 바뀌면 안 돼. 둘 다 검증해.
   ```

4. 할 일 목록에 어떤 플레이북이 붙었는지, 어떤 단계를 건너뛰었는지 본다.
5. 막히거나 어떤 스킬을 써야 할지 모르겠으면 `/poteto-help`에게 묻는다.

## 영상에 나온 핵심 스킬

`/poteto-mode`가 단계마다 알아서 부르지만, 직접 부를 수도 있다. 영상은 일하는 순서대로 소개한다.

### 1. 고치기 전에 이해하기: how, why

![why 스킬 문서. 재시도 제한은 왜 5번일까, 그 이유가 아직 유효할까](/assets/img/posts/pstack-guide/why.png)

- **`/how`**: 코드가 **지금 어떻게** 돌아가는지 설명한다. "이건 어디에 두는 게 맞나" 같은 위치·계층 질문도 여기서 다룬다.
- **`/why`**: **왜** 이렇게 만들었는지 찾는다. 연결된 도구(MCP)를 찾아 커밋 기록, 이슈, 문서, 팀 채팅 등을 동시에 뒤지고, 근거를 붙여 답한다. 확인된 사실과 추측을 나눠 보여 주고, 아무도 이유를 적어 두지 않았다면 그것도 답으로 알려 준다.

```text
/why 재시도 횟수는 왜 다섯 번으로 정했지? 그 이유가 아직 유효해?
```

영상의 설명대로, 이해 없이 고치기 시작하면 처음 그럴듯해 보이는 곳에서 겉으로 드러난 증상만 고치기 쉽다.

### 2. 첫 설계에 갇히지 않기: architect, arena

![arena 화면. 같은 프롬프트로 설계안 A, B, C를 동시에 받는다](/assets/img/posts/pstack-guide/arena.png)

- **`/architect`**: 여러 함수에 걸친 변경이면 코드보다 **타입, 함수 모양, 모듈 구조**를 먼저 잡는다. 설계안마다 이 코드를 가져다 쓰는 쪽이 어떻게 쓰게 될지를 먼저 적는 것이 특징이다. 구현하다 같은 땜질이 여기저기 생기면 설계가 틀렸다는 증거로 보고 다시 짠다.
- **`/arena`**: 같은 과제를 여러 에이전트가 각자의 작업 폴더에서 동시에 풀게 한다. 다른 계열 모델이 심사위원이 되어 기준표로 각 안에 점수를 매기고, 가장 나은 안을 바탕으로 나머지 안의 좋은 부분을 옮겨 붙인 뒤 결과를 검증한다. 한 번에 나온 설계는 모델이 처음 떠올린 모양에 갇히기 쉽기 때문이다.

### 3. 주석까지 정리하기: no-comments

![AI가 남긴 땜질 주석을 다른 AI가 따라 하며 복사되는 그림](/assets/img/posts/pstack-guide/no-comments.png)

**`/no-comments`**는 주석을 쓴 AI가 아니라 처음 보는 검토 에이전트(Comment Sicko)에게 코드를 넘겨, 꼭 필요한 주석만 남기고 나머지를 지운다. 영상에 따르면 로렌 탄이 Cursor 코드에서 본 문제 때문이다. AI가 주석을 핑계로 진짜 문제를 고치지 않고 임시방편으로 덮었고, 그 주석을 다른 AI가 따라 하면서 땜질이 퍼졌다는 것이다. "이건 지우지 마" 같은 주석이 있으면, 그 조건을 타입·테스트·규칙으로 바꾸자고 제안한다.

### 4. 실제로 돌려서 확인하기: create-verification-skill

![검증 스킬의 구조. 실행 방법, 상태 확인, 조작·테스트, 결과 증거 기록, 정리](/assets/img/posts/pstack-guide/verify-skill.png)

**`/create-verification-skill`**은 저장소를 살펴보고, 내 프로젝트 전용 검증 스킬(`verify-<앱 이름>`)을 만든다. 앱 실행(Launch), 상태 점검(Doctor), 기능을 사용자처럼 조작하기(Drive), 증거 남기기(Evidence), 뒷정리(Cleanup) 절차와 앱 기능 목록(feature map)이 담긴다. 넘겨주기 전에 이 절차를 한 번 끝까지 직접 돌려 보고, 실패하면 쓰지 말라고 한다. 그 뒤로 에이전트들은 이 지침대로 직접 확인한다. 영상에 따르면 로렌 탄이 Cursor에 와서 처음 만든 것도 이런 검증 스킬이었다. 매번 직접 성능을 재는 대신 AI가 앱을 실행해 성능 기록을 모으게 했다는 것이다.

### 5. 다른 모델에게 검토받기: interrogate

![interrogate 화면. Opus 5.5와 Grok이 같은 변경을 따로 검토한다](/assets/img/posts/pstack-guide/interrogate.png)

**`/interrogate`**는 같은 변경을 **서로 다른 계열의 모델**에게 따로 검토시킨다. 모델마다 놓치는 곳이 달라서, 두 모델이 따로 같은 문제를 짚으면 확실한 신호로 본다. 결과는 네 칸으로 나뉜다.

| 칸 | 뜻 |
|---|---|
| Act on (바로 고칠 것) | 정확성, 보안, 유지보수에 실제로 문제가 되는 것 |
| Consider (고려할 것) | 타당하지만 지금 고칠 가치가 있는지 애매한 것 |
| Noted (참고) | 맞는 말이지만 지금 손댈 일은 아닌 것 |
| Dismissed (기각) | 틀렸거나 사소한 것. 기각 이유를 붙인다 |

자동으로 고치지는 않는다. 판단은 사람이 한다.

```text
/interrogate 이 PR 검토해 줘.
```

### 6. 여럿에게, 밤새 맡기기: swarm, show-me-your-work

![swarm 문서. 패키지마다 에이전트 하나, 보고서는 하나](/assets/img/posts/pstack-guide/swarm.png)

- **`/swarm`**: 일을 여러 조각으로 나눠 에이전트를 동시에 돌리고, 결과를 **보고서 하나**로 모은다. 각 에이전트는 `PASS`(통과), `ISSUES`(문제), `BLOCKED`(막힘) 중 하나로 증거와 함께 보고한다.

  ```text
  /swarm packages/ 아래 모든 패키지를 각자의 check.sh로 확인해. 패키지마다 에이전트 하나, 보고서는 하나.
  ```

- **밤샘 실행**: README의 예시 문장이 유명하다. 맡기기 전에 완료 조건을 먼저 정하게 한다.

  ```text
  /poteto-mode i'm going to bed. land the stack even if ci flakes. i want everything merged by morning.
  ```

  ("나 자러 간다. CI가 좀 흔들려도 연달아 쌓아 올린 PR 묶음(스택)을 머지해. 아침까지 전부 머지돼 있으면 좋겠어.")

- **`/show-me-your-work`**: 사람이 자리를 비운 동안 내린 결정을 한 줄씩(시각, 단계, 결정, 이유, 근거, 결과) `decisions.tsv` 파일로 남긴다. 요약을 돌려주기 전에 다른 계열 모델이 이 기록을 검토해 "주의해서 볼 것(Attention)" 목록을 붙여 준다. 아침에는 그 목록부터 읽으면 된다.

영상에 따르면 로렌 탄은 이런 방식으로 지난달 풀 리퀘스트 2,000개를 프로덕션에 내보냈다고 한다.

## 비용은 미리 알고 쓰자

pstack은 하위 에이전트와 검토 패널을 많이 띄워서 **토큰을 더 쓴다.** 공식 가이드는 그게 꼼꼼함의 값이라고 말하면서 줄이는 방법도 적어 두었다.

- `setup-pstack`을 다시 돌려 추론 예산을 낮추거나 싼 모델을 고른다. 메인 채팅은 강한 모델, 코드 역할은 싸고 빠른 모델로 나누는 게 좋은 조합이다.
- `setup-pstack`에서 역할의 모델을 `auto`나 `inherit-parent`로 고르면 따로 모델을 띄우지 않고 지금 채팅 모델을 그대로 쓴다. 두 값은 뜻이 같다.
- 검토 패널의 모델 수를 줄인다. 하나당 하위 에이전트가 하나씩 뜬다.
- 작고 뻔한 수정에는 `/poteto-mode`를 쓰지 않는다.

## 정리

pstack의 핵심은 스킬 목록이 아니라 **"이해하고, 설계하고, 적게 쓰고, 실제로 돌려서 확인하고, 다른 눈으로 검토한다"**는 작업 습관을 에이전트에게 강제하는 데 있다. 처음에는 스킬을 외울 필요 없이 `/poteto-mode` + 확인 기준 한 줄로 시작하면 된다.

더 깊이 보려면 공식 [pstack 가이드](https://github.com/cursor/plugins/tree/main/pstack/docs/guide)가 설치부터 밤샘 실행, 자기만의 모드 만들기(`/automate-me`)까지 10개 장으로 정리돼 있다.
