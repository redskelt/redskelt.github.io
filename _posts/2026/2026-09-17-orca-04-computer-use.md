---
title: "Orca 파헤치기 4편 - Computer Use, 데스크톱 앱까지 만지는 에이전트"
date: 2026-09-17 11:15:00 +0900
categories: [AI, Trending]
tags: [Orca, ComputerUse, 데스크톱자동화, AI에이전트]
series: orca
series_index: 4
---

[3편](/ai/trending/orca-03-diff-attribution/)까지는 코드와 diff 이야기였습니다. 이번 4편은 코드 바깥, 즉 **로컬에 설치된 다른 데스크톱 앱**까지 에이전트가 건드리는 **Computer Use** 기능입니다.

![설정 > Computer Use — Accessibility, Screenshots 권한이 모두 허용된 상태](/assets/img/posts/orca-ide-review/computer-use-settings.png)
_영상 데모 — 설정에서 Accessibility·Screenshots 권한을 켜는 화면._

### 동작 원리 — "Snapshot → Act → Snapshot" 루프

문서가 설명하는 핵심 루프는 세 단계로 반복됩니다.

1. **Snapshot**: `get-app-state`로 접근성 트리(accessibility tree)와 스크린샷을 함께 획득해서 "지금 화면에 뭐가 있는지" 읽는다
2. **Act**: `click`, `set-value`, `type-text` 같은 명령으로 특정 요소를 조작한다
3. **Snapshot**: 상태를 다시 읽어서 방금 한 행동이 의도한 결과를 냈는지 검증한다

기본 워크플로우 예시:

```bash
orca computer list-apps          # 실행 중인 앱 목록
orca computer get-app-state ...  # 접근성 트리 + 스크린샷 획득
orca computer click ...          # 특정 요소 클릭
orca computer get-app-state ...  # 결과 재확인
```

브라우저 자동화와 결이 비슷하지만 대상이 웹 페이지가 아니라 **네이티브 윈도우**라는 점이 다릅니다. Spotify, Safari 같은 일반 macOS 앱은 물론, OS 차원의 조작이 필요한 작업, 터미널·브라우저가 아닌 서드파티 앱, 멀티윈도우 애플리케이션까지 대상이 됩니다.

### 필요 권한

Computer Use는 시스템 권한에 직접 걸쳐 있는 기능이라 다음이 필요합니다.

- **Accessibility(접근성)** 권한 — 필수
- **macOS**: Screen Recording(화면 녹화) 권한 추가

```bash
orca computer permissions --json
```

로 현재 권한 상태를 확인할 수 있고, 시스템 설정에서 **Orca Computer Use** 항목에 권한을 부여해야 합니다. 스크린샷에서 "Accessibility"와 "Screenshots"가 모두 `GRANTED`로 표시된 상태가 바로 이 권한이 정상 허용된 화면입니다.

### 아직은 베타

문서는 이 기능이 **베타 상태**이며 "명령어 구조는 안정적이지만 향후 바뀔 수 있다"고 명시합니다. 로컬 데스크톱 앱의 UI 요소를 접근성 API로 읽고 조작하는 방식이라, 앱마다 접근성 트리 품질 차이로 동작이 들쭉날쭉할 수 있다는 뜻으로 읽으면 됩니다.

### 왜 필요한가

브라우저 자동화(다음 시리즈에서 다룰 예정인 Per-worktree browser)만으로는 커버되지 않는 영역이 있습니다 — 웹이 아닌 네이티브 데스크톱 앱, 특히 API도 없고 웹도 아닌 오래된 사내 툴이나 디자인 앱 같은 것들입니다. Computer Use는 "브라우저 자동화의 사각지대"를 접근성 API 레벨에서 메우는 기능으로 보면 됩니다.

다음 5편은 랩탑을 떠나서도 worktree 상태를 확인할 수 있게 해주는 **모바일 컴패니언 앱**입니다.
