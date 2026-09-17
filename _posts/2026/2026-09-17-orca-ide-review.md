---
title: "Orca IDE 리뷰 — 클로드 코드·코덱스 병렬로 굴리는 에이전트 IDE"
date: 2026-09-17 10:00:00 +0900
categories: [AI, Trending]
tags: [Orca, AI에이전트, 코딩에이전트, ClaudeCode, Codex]
---

유튜브 채널 [코드팩토리](https://www.youtube.com/@codefactory_official)의 영상 ["Orca IDE 기~모~링!"](https://www.youtube.com/watch?v=1x5T88dcDEw)을 보고, 공식 사이트 [onorca.dev](https://www.onorca.dev/)와 [공식 문서](https://www.onorca.dev/docs), 해외 리뷰를 함께 참고해 정리한 **Orca** 리뷰입니다.

{% include video id="1x5T88dcDEw" provider="youtube" %}

### Orca가 뭔가

Orca는 **클로드 코드, 코덱스, 커서 CLI 같은 터미널형 AI 코딩 에이전트를 여러 개 동시에 돌리기 위한 데스크톱 IDE**입니다. 자체 모델을 내놓는 제품이 아니라, 이미 쓰고 있는 에이전트 구독(클로드 맥스, 코덱스 등)을 그대로 가져와서 **오케스트레이션 레이어**로 얹는 방식입니다.

공식 문서의 "What is Orca?" 페이지가 정의하는 핵심은 세 가지입니다.

- 작업(Task) 하나마다 **자기 것인 git worktree**, **자기 것인 에이전트 터미널**, **자기 것인 브라우저 탭**이 배정된다
- 그래서 브랜치 갈아타기, `git stash` 없이 여러 에이전트를 동시에 굴릴 수 있다
- git worktree/터미널/코드 리뷰에 이미 익숙한 개발자를 대상으로 하며, "AI가 다 알아서 해주는 노코드 툴"은 명시적으로 지향점이 아니다

![공식 문서 What is Orca 페이지 — worktree 사이드바, 에이전트 터미널, diff 뷰가 한 화면에 있다](/assets/img/posts/orca-ide-review/onorca-docs-whatis.png)
_onorca.dev/docs — "Orca is a desktop IDE for running multiple AI coding agents side by side" 라는 한 줄 정의._

### 영상 데모: worktree 사이드바 + 에이전트 세션 히스토리

영상에서 실제로 켜서 보여주는 화면은 왼쪽에 프로젝트별 worktree 목록(`orca-demo`, `debug-w1`, `debug-w2`...), 가운데에 코드 diff와 클로드 코드 터미널, 오른쪽에 **Agent Session History**가 나란히 떠 있는 구조입니다.

![Orca 메인 화면 — 왼쪽 worktree 사이드바, 가운데 코드/터미널, 오른쪽 에이전트 세션 히스토리](/assets/img/posts/orca-ide-review/main-ui-worktrees.png)
_영상 약 0:15(광고 제외 실제 재생 기준) — `Friction.tsx` 수정 내역과 `claude` 셸 명령 실행 로그가 동시에 보인다._

같은 프로젝트 안에서 `debug-w1`, `debug-w2`처럼 worktree를 분기해 같은 버그를 여러 에이전트에게 동시에 맡기고, 오른쪽 세션 히스토리에서 각 세션이 몇 %의 토큰/시간을 썼는지, 어떤 파일을 건드렸는지 되짚어볼 수 있습니다. 공식 문서의 "Race three agents on the same task"(같은 작업에 에이전트 세 개를 붙이고 이긴 놈 고르기) 레시피가 바로 이 화면입니다.

### AI가 diff를 미리 요약해준다 — Attribution

코드 수정이 끝나면 Orca가 diff 옆에 **"Fixed 1 defect", "Cogitated for 5m 19s"** 식으로 AI가 만든 작업 요약을 붙여줍니다. 사람이 diff를 한 줄씩 읽기 전에 "이 커밋에서 실제로 뭘 고쳤는지"를 먼저 훑을 수 있게 해주는 기능으로, 문서에는 **Attribution**이라는 이름으로 따로 페이지가 있습니다.

![diff 옆에 AI가 붙인 수정 요약 — Fixed 1 defect, Cogitated for 5m 19s](/assets/img/posts/orca-ide-review/diff-ai-summary.png)
_영상 약 3:20 — `Attribution.tsx` diff에 대한 AI 요약과, 검증 완료(verified) 표시가 함께 나온다._

### 클로드 코드가 Orca 터미널 안에서 그대로 돈다

Orca는 별도 클로드 코드 CLI를 껍데기만 씌운 게 아니라, 실제 터미널 패널 안에서 `claude` 명령을 그대로 실행합니다. 영상에서는 **클로드 코드 v2.1.220, Opus 5(1M 컨텍스트), medium effort** 조합으로 구동되는 모습을 보여주면서 "이제 코덱스 앱을 따로 열 필요가 없다"고 말합니다.

![Orca 터미널 안에서 실행 중인 클로드 코드 v2.1.220 — Opus 5, 1M 컨텍스트](/assets/img/posts/orca-ide-review/claude-code-opus5-terminal.png)
_영상 약 6:00 — `/model`로 바로 전환 가능하다는 안내와 함께 Opus 5가 medium effort로 붙어 있다._

### Computer Use — 데스크톱 앱까지 에이전트가 조작

설정의 **Computer Use** 패널에서 접근성(Accessibility)과 스크린샷 권한을 허용하면, 에이전트가 브라우저뿐 아니라 로컬에 설치된 다른 데스크톱 앱의 창까지 열고 조작할 수 있습니다. 영상에서는 이 권한을 켜는 과정을 그대로 보여줍니다.

![설정 > Computer Use — Accessibility, Screenshots 권한이 모두 허용된 상태](/assets/img/posts/orca-ide-review/computer-use-settings.png)
_영상 약 4:40 — 권한을 켜면 에이전트가 로컬 앱 창을 인식하고 조작할 수 있게 된다._

### 모바일에서도 worktree를 지켜본다 — Work on-the-go

랩탑을 떠나 있어도 **Orca Mobile**(iOS/Android)로 실행 중인 worktree와 에이전트 상태를 확인할 수 있습니다. 영상에서는 맥북 화면 옆에 아이폰 목업이 뜨면서 `feature/mobile-pp` 같은 worktree 목록과 각 에이전트의 진행 상태가 동기화되는 걸 보여줍니다.

![맥북 옆에 뜬 아이폰 — 실행 중인 worktree 목록과 에이전트 상태가 모바일에서도 보인다](/assets/img/posts/orca-ide-review/mobile-work-on-the-go.png)
_영상 약 2:00 — GitHub 체크 실패를 고치는 세션을 모바일에서 그대로 확인하는 장면._

리뷰 사이트들이 공통으로 지적하는 약점도 이 모바일 컴패니언입니다. [Volanea 리뷰](https://www.volanea.com/blog/orca-ai-coding-agents)와 [aiidelist 리뷰](https://aiidelist.com/ide/orca-ai)는 모바일 앱이 "가끔 버그가 있다(occasionally buggy)"고 언급합니다.

### 설치 & 가격

- **무료, 오픈소스(MIT), 로컬 우선(local-first)**. macOS·Windows·Linux 지원, GitHub 스타 70k+.
- Orca 자체는 모델을 제공하지 않으므로, 클로드 코드/코덱스/커서 CLI 등 **기존에 쓰던 에이전트 구독이나 API 키가 그대로 필요**합니다.
- 공식 다운로드: [onorca.dev/download](https://www.onorca.dev/download) 또는 [GitHub](https://github.com/stablyai/orca)에서 소스로 빌드.

### 해외 반응 정리

검색해본 해외 리뷰들의 논조는 거의 일치합니다.

- [dev.to 리뷰](https://dev.to/andrew-ooo/orca-review-the-ide-built-for-parallel-coding-agents-15df): "병렬 에이전트를 부가 기능이 아니라 기본 워크플로로 진지하게 다룬 첫 에이전트 IDE"
- [Margrop 블로그](https://blog.margrop.net/en/post/orca-parallel-ai-agent-ide-review/): "5개의 AI 코더를 병렬로 돌려도 더 이상 서로 싸우지 않는다"
- [vibecodinghub 리뷰](https://vibecodinghub.org/blog/orca-review): "이미 진지한 AI 코딩 에이전트를 쓰고 있고, 병목이 '여러 개를 동시에 감독하는 것'이라면 평가해볼 가치가 있다. 에디터 자동완성 정도의 간단한 도구를 찾는 거라면 첫 선택지는 아니다."

즉, **AI가 코드를 대신 짜주는 도구**가 아니라 **이미 에이전트를 여러 개 굴리고 있는데 그걸 감독·비교·리뷰하는 게 병목이 된 사람**을 위한 오케스트레이션 IDE라는 평가로 수렴합니다.

### 정리

Orca는 "한 화면에서 worktree별로 에이전트를 병렬로 띄우고, diff에 AI 요약까지 붙여서 리뷰 부담을 줄여주는" 방향의 도구입니다. 클로드 코드나 코덱스를 이미 매일 쓰면서 "터미널 여러 개, 브랜치 여러 개를 손으로 오가는 게 피곤하다"고 느꼈다면 시도해볼 만하고, 반대로 아직 에이전트 하나도 제대로 안 써봤다면 이 툴보다 클로드 코드나 코덱스 자체부터 익히는 게 순서상 맞습니다.

각 기능을 공식 문서 기준으로 더 깊게 파고든 시리즈를 이어서 씁니다 — [1편: Worktree 네이티브 구조와 설치](/ai/trending/orca-01-worktree/)부터 시작합니다.
