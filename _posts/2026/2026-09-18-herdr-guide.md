---
title: "herdr 완벽 가이드 — tmux·cmux 대신 AI 에이전트 전용 터미널 멀티플렉서 쓰기"
date: 2026-09-18 12:02:00 +0900
categories: [AI]
tags: [herdr, tmux, AI에이전트, ClaudeCode, Codex, 터미널]
---

Claude Code 하나만 쓸 때는 터미널 하나면 충분하다. 그런데 Codex, OpenCode, Kimi Code까지 같이 쓰기 시작하고 에이전트별로 몇 개씩 띄우다 보면, 어느새 터미널 창이 6개, 7개, 8개가 되어 있다. 문제는 개수만이 아니다 — **지금 어떤 에이전트가 일하고 있고, 어떤 에이전트가 내 승인을 기다리며 멈춰 있는지 한눈에 알 수 없다는 것**이 더 크다.

[herdr](https://herdr.dev)는 이 문제를 풀기 위해 태생부터 AI 에이전트 중심으로 설계된 터미널 멀티플렉서다. 이 글은 다음 영상을 보고 herdr 공식 문서까지 함께 확인해서 구조, 설치, 실제 사용법, tmux·cmux·Orca와의 차이까지 정리한 상세 가이드다.

> 참고 영상: [tmux·cmux 대체] herdr 완벽 가이드 | 태생부터 AI 에이전트를 위한 터미널 멀티플렉서 (김플립 - LLM 코딩)

{% include video id="rSHizW6dI3c" provider="youtube" %}

## herdr가 해결하는 네 가지

영상이 짚는 문제는 tmux, Zellij, cmux 같은 기존 도구를 하루 이상 써본 사람이라면 익숙하다. herdr는 이걸 네 가지로 정리해서 해결한다.

1. **정리(Organization)** — 터미널 탭이 데스크톱 곳곳에 흩어져 있는 대신, 에이전트 중심으로 설계된 한 화면에서 작업한다. 왼쪽에 에이전트가 목록으로 뜨고, 패널 분할·스페이스 추가·탭 생성이 전부 쉽다.
2. **모니터링(Monitoring)** — 각 에이전트가 지금 작업 중인지, 다 끝났는지, 아니면 막혀서 내 입력을 기다리는지를 정확히 보여준다. 사운드 알림도 있다.
3. **지속성(Persistence)** — 진짜 킬러 기능. 에이전트가 작업 중인 상태에서 herdr를 완전히 종료해도 작업은 멈추지 않는다. herdr가 서버처럼 동작하기 때문에 창을 닫아도 프로세스는 백그라운드에서 계속 돈다.
4. **마우스 친화성** — CLI 도구인데도 모든 기능이 마우스로 되게끔 설계됐다. 단축키를 몰라도 상관없다.

herdr는 오픈소스이고 무료이며, macOS·Linux·Windows 모두에서 동작한다.

## herdr는 정확히 어떤 도구인가

먼저 용어 정리부터. herdr는 **터미널 멀티플렉서**다. 여러 터미널 창을 하나의 화면 안에서 실행하고 관리하는 도구라는 뜻이다. 같은 부류로 tmux가 있고, tmux에 GUI를 얹은 계열로 cmux나 Orca 같은 도구들이 있다.

![herdr.dev 홈페이지 — "Run them anywhere. Leave them running." 슬로건과 설치 명령어, 39,264 GitHub 스타](/assets/img/posts/herdr-guide/home.png)

herdr 공식 사이트의 [Compare 페이지](https://herdr.dev/compare)는 herdr의 정체성을 이렇게 정의한다.

> Apps manage the herd. Herdr **runs** it.
>
> Most tools Herdr gets compared to are apps: a window you open to manage coding agents, and a window the work depends on. Herdr is a different kind of thing: **a runtime**. A server holds real terminals open on the machine, the agents live in those, and every UI, ours included, is just a client that attaches.

즉 herdr는 "관리하는 앱"이 아니라 "에이전트가 실제로 돌아가는 런타임"이라는 게 핵심 차별점이다. 두 가지를 반드시 짚어야 한다.

- **herdr는 Ghostty, iTerm, Windows Terminal 같은 터미널 에뮬레이터를 대체하지 않는다.** 평소 쓰던 터미널을 그대로 열고 그 안에서 herdr를 실행하는 구조다. Ghostty를 쓰든 PowerShell을 쓰든 iTerm을 쓰든 상관없다. 기존 환경 위에 한 겹 얹는 도구다. (영상에서는 Ghostty를 추천한다.)
- **herdr는 클라이언트-서버 구조다.** herdr를 실행하면 클라이언트가 서버에 접속한다. 서버가 아직 떠 있지 않으면 자동으로 시작된다. 우리가 여는 세션은 전부 이 서버 위에서 돌아간다. 이 구조 하나 때문에 뒤에서 설명할 지속성 기능 대부분이 가능해진다.

## 설치와 첫 실행

설치는 명령어 한 줄이면 끝난다.

```bash
curl -fsSL https://herdr.dev/install.sh | sh
```

macOS·Linux는 이 명령어 하나, Windows는 별도 Windows용 명령어가 [herdr.dev](https://herdr.dev)에 안내되어 있다. Windows는 homebrew, nix, 수동 설치 방법도 지원한다.

설치가 끝났으면 터미널에서 `herdr`를 실행한다. 실행하면 화면이 크게 세 영역으로 나뉜다.

- 왼쪽 위: **스페이스(Workspace)** 목록
- 왼쪽 아래: **에이전트(Agents)** 목록
- 오른쪽: 실제 터미널 영역 (평범한 터미널과 똑같이 동작한다)

여기서 바로 Claude Code를 실행해보면, 실행하자마자 왼쪽 에이전트 영역에 클로드가 자동으로 잡힌다. 별도 설정이나 등록 과정이 없다. 이게 herdr의 가장 좋은 첫인상이자 가장 큰 매력이다.

## 화면 구조: Workspace · Tab · Pane

herdr에서 가장 먼저 이해해야 하는 건 화면 구조다. 세 단계로 나뉜다. 폴더에 비유하면 이렇다.

![herdr 공식 문서 Concepts 페이지 — Workspace, Tab, Pane 개념 설명](/assets/img/posts/herdr-guide/concepts.png)

| 단계 | 폴더 비유 | 설명 |
|---|---|---|
| **Workspace** | 가장 바깥 폴더 | 프로젝트 단위. 저장소 하나, 작업 하나, 조사 하나당 워크스페이스 하나를 쓴다. 사이드바 상태는 그 안의 에이전트 상태를 그대로 끌어올려 보여준다. |
| **Tab** | 하위 폴더 | 워크스페이스 안의 레이아웃. `agents`, `logs`, `server`, `review`처럼 용도별로 탭을 나눈다. CLI와 소켓 API에서 직접 주소를 지정할 수 있다. |
| **Pane** | 폴더 안 파일 | 탭 안에서 화면을 나눠 띄우는 개별 창. 에이전트나 dev 서버를 여기 띄운다. |

영상에서 보여준 실사용 예시: 첫 번째 탭 이름을 "리서치"로 바꿔서 클로드와 코덱스에게 조사 작업을 맡기고, 두 번째 탭은 "DEV 서버"로 이름 붙여 개발 서버만 띄워둔다. 정리하면 이렇다 — **워크스페이스로 프로젝트를 나누고, 탭으로 그 하위 작업을 나누고, 페인으로 에이전트나 서버를 원하는 만큼 띄운다.** 터미널 창을 여러 개 열어놓고 기억에 의존하던 방식과 비교하면 확실히 정리가 잘된다.

## Agents 사이드바 — 자동 감지와 실시간 상태

herdr를 실제로 쓰는 가장 큰 이유가 이 사이드바다. herdr는 Claude Code, Codex, OpenCode, Grok, Kimi 같은 주요 코딩 에이전트를 **자동으로 감지**한다. herdr 안에서 에이전트 프로세스를 시작하면 알아서 사이드바에 추가된다. 혹시 쓰는 에이전트가 자동으로 안 잡히면 [Integrations 문서](https://herdr.dev/docs/integrations/)에서 한 줄짜리 통합 명령어를 찾아 설치하면 된다.

![herdr 공식 문서 Agents 페이지 — 지원 에이전트별 상태 감지(idle/working/blocked) 방식과 Integration role 표](/assets/img/posts/herdr-guide/agents.png)

공식 문서 기준으로 자동 감지가 되는 에이전트 목록은 이 정도다: **Pi, OMP, Claude Code, Codex, GitHub Copilot CLI, Devin CLI, Kimi Code CLI, Droid, OpenCode, Kilo Code CLI, Hermes Agent, Qoder CLI, Qwen Code, Letta Code, Cursor Agent CLI, MastraCode, Antigravity CLI, Grok CLI**. 상태는 `idle`(대기) · `working`(작업 중) · `blocked`(막힘) 세 가지로 표시되고, 각 에이전트마다 이 상태를 판단하는 신호(라이프사이클 훅, 화면 매니페스트 등)가 다르다는 것까지 문서에 정리되어 있다.

왼쪽에서 작은 노란색 움직임만 보면 해당 에이전트가 아직 일하는 중이라는 걸 알 수 있다. 이게 왜 중요하냐면, 에이전트를 돌려놓고 다른 일을 하다 보면 어느 세션이 한참 전부터 승인을 기다리며 멈춰 있는 경우가 꼭 생기기 때문이다. 에이전트 하나만 쓸 때는 별것 아닌 기능처럼 보이지만, 두세 개를 넘어 화면에 보이지도 않는 다섯 개를 돌리기 시작하면 이 사이드바 하나가 작업 속도를 바꾼다. tmux가 기본 상태에서는 절대 해주지 않는 부분이다.

## 세션 지속성 — 창을 닫아도 계속 돈다

클라이언트-서버 구조 덕분에 가능한 기능이다. 세션은 herdr 서버 위에서 돌아가기 때문에, 페인을 닫거나 세션에서 분리하거나 심지어 herdr를 완전히 종료해도 서버는 계속 살아있다.

영상에서 실제로 시연한 과정: 두 에이전트가 모두 작업 중인 상태에서 터미널을 통째로 닫는다. 그리고 Ghostty를 새로 실행하고 `herdr`를 입력하면, 아까 그 에이전트들이 그대로 작업 중인 화면이 돌아온다. 이건 코딩 에이전트에만 해당하는 게 아니라 herdr의 각 페인에서 실행한 모든 프로세스(dev 서버, 빌드 등)에 똑같이 적용된다. 컴퓨터가 켜져 있는 한 세션은 계속 유지되므로, 노트북 덮개를 닫아도 절전 모드로 들어가지 않게 설정해두면 에이전트를 원하는 만큼 오래 돌려둘 수 있다.

세션을 진짜로 끝내고 싶을 때는 페인을 우클릭해서 "Close Pane", 워크스페이스 전체는 우클릭 후 "Close"를 선택하면 된다. 작업 중인 터미널을 실수로 닫아본 경험이 있다면 이 지속성 기능 하나만으로도 써볼 가치가 있다.

## 마우스로 다 되고, 단축키도 있다

herdr가 터미널 기반 도구인데도 진입 장벽이 낮은 이유가 여기 있다. 페인을 우클릭하면 이름 바꾸기, 상하좌우 분할, 확대·축소 같은 작업을 전부 마우스로 메뉴에서 처리할 수 있다. 워크스페이스나 탭도 클릭으로 전환하고 우클릭으로 이름을 바꾼다.

물론 단축키도 있다. 메뉴의 키바인딩 항목에서 사용 가능한 단축키를 전부 볼 수 있다. 방식은 tmux와 거의 비슷해서, 프리픽스 키를 누른 다음 원하는 키를 누르는 식이다 (예: 프리픽스 + V로 수직 분할). 단축키를 다 외우지 않아도 마우스로 시작할 수 있고, 익숙해지면 단축키로 빠르게 갈 수도 있는 구조다.

## herdr 스킬 — 에이전트가 herdr를 직접 조작

여기서부터가 herdr가 단순한 tmux 대체제가 아닌 이유다. herdr에는 **에이전트에게 herdr 사용법을 알려주는 스킬 파일**이 있다.

![herdr 공식 문서 — Agent skill file 페이지. skills/herdr/SKILL.md 위치와 스킬이 하는 일 설명](/assets/img/posts/herdr-guide/agent-skill.png)

공식 문서에 따르면 herdr는 `skills/herdr/SKILL.md`에 재사용 가능한 스킬 파일을 내장하고 있고, 이 파일을 재사용 스킬이나 커스텀 지침을 지원하는 아무 코딩 에이전트에나 설치할 수 있다. `HERDR_ENV=1`이 설정된 herdr 관리 페인 안에서 에이전트가 `herdr` CLI를 쓰도록 알려주는 방식이다. 이 스킬이 설치되면 에이전트는 다음을 할 수 있다.

- 워크스페이스·탭·페인, 옆에 있는 다른 에이전트 상태 조회
- 포커스를 뺏지 않고 페인을 나누거나 명령 실행
- 페인 출력과 최근 로그 읽기
- 서버, 테스트, 다른 에이전트가 끝날 때까지 대기

설치 역시 터미널에 명령어 한 줄 붙여넣으면 끝난다. 이걸 설치하면 에이전트가 herdr 안에서 직접 새 페인을 만들고, 필요하면 새 워크스페이스도 만든다. 사용자가 화면 구조를 일일이 관리하지 않아도 에이전트가 알아서 자리를 잡는다는 뜻이다.

## 플러그인 마켓플레이스

![herdr.dev 플러그인 마켓플레이스 — GitHub의 herdr-plugin 토픽에서 자동으로 발견되는 커뮤니티 플러그인 1,208개](/assets/img/posts/herdr-guide/plugins.png)

[herdr.dev/plugins](https://herdr.dev/plugins)에는 사람들이 만들어 올린 부가 기능이 모여 있다. GitHub의 `herdr-plugin` 토픽에서 자동으로 수집되고, `herdr plugin install` 명령으로 아무거나 설치할 수 있다 (공식 검수는 없으므로 설치는 각자 판단).

영상에서 실제로 쓴다고 소개한 건 **File Viewer 플러그인**이다. 에이전트가 작업을 마치면 코드를 한번 봐야 하는데, 그때마다 VS Code를 여는 게 번거로울 때가 있다. 이 플러그인을 설치하면 단축키 하나로 herdr 안에서 파일뷰를 열고 변경된 부분을 강조된 상태로 바로 확인할 수 있다. 커밋 단위로 열어서 뭐가 바뀌었는지 보고 곧바로 피드백을 줄 수 있다.

원하는 플러그인이 없으면 herdr 안에서 돌아가는 에이전트한테 직접 만들어달라고 하면 된다. herdr 안의 에이전트가 herdr 자체를 확장하는 구조, 즉 스스로 개선되는 소프트웨어인 셈이다. 영상에서도 이 부분을 "가장 재미있는 지점"으로 꼽는다.

## 숨어 있던 헤드리스 작업을 화면에 띄우기

이건 herdr를 쓰면서 생각지도 못했던 장점이라고 영상이 짚는 부분이다. 요즘 Claude가 Codex를 호출해서 서로 계획을 검토하게 만드는 워크플로를 많이 쓰는데, 문제는 이런 작업이 대부분 **헤드리스**로 돌아간다는 것이다. Claude가 보이지 않는 Codex 인스턴스를 만들어 내용을 주고받기 때문에 실제로 무슨 대화가 오가는지 알기 어렵다.

herdr를 쓰면 이 과정을 그대로 화면에 띄울 수 있다. 영상 데모에서는 Claude Code에게 "계획을 세우고 Codex한테 검토받아라"는 프롬프트를 실행하자, Claude Code가 오른쪽에 새 페인을 열고 그 안에서 Codex CLI가 돌아가는 게 그대로 보인다. Claude가 계획을 만들어 Codex에 보내고, Codex가 문제점을 정리해서 돌려주고, Claude가 계획을 수정하는 과정이 최종 계획이 나올 때까지 반복된다. 숨어서 돌던 과정을 실시간으로 볼 수 있다는 것 자체가 유용하다 — 두 에이전트가 엉뚱한 방향으로 합의하고 있으면 중간에 바로 끊을 수 있기 때문이다.

## 원격(VPS)에서 쓰기

VPS에서 에이전트를 돌린다면, 로컬 설정 그대로 원격 세션에 붙일 수 있다. 공식 문서의 Compare 표에서도 herdr는 "detach, reattach, SSH in" 항목에 **"yes, any tty"**로 표시된다 — SSH로 붙는 어떤 터미널에서도 동일하게 이어서 쓸 수 있다는 뜻이다.

## tmux · cmux · Orca와 뭐가 다른가

![herdr.dev Compare 페이지 — herdr vs tmux/Zellij, cmux/Warp, Solo, Conductor/Emdash/Superset 9종 비교표](/assets/img/posts/herdr-guide/compare.png)

공식 [Compare 페이지](https://herdr.dev/compare)가 9개 도구와 herdr를 항목별로 비교한다. 핵심만 추리면 이렇다.

| 항목 | herdr | tmux · Zellij | cmux · Warp | Conductor · Emdash · Superset |
|---|---|---|---|---|
| 종류 | 런타임 + 클라이언트 | 터미널 멀티플렉서 | 터미널 앱 | 매니저 앱 |
| UI를 꺼도 작업 유지 | O (서버가 터미널을 소유) | O (detach) | 앱이 켜져 있는 동안만 | 앱이 켜져 있는 동안만 |
| 기존 터미널 안에서 실행 | O | O | X (터미널 자체를 대체) | X (별도 데스크톱 앱) |
| 에이전트 상태(작업중/대기/완료) | O | 없음 | 알림 정도 | 워크스페이스 상태 |
| 에이전트가 API로 직접 조작 | O (읽기·전송·대기·분할·붙기) | 터미널 스크립팅 | 앱 API | 워크플로 API |

- **tmux·Zellij 대비**: 기본 동작(한 화면에서 여러 터미널 제어)은 같지만, tmux는 훨씬 오래된 도구고 에이전트 상태를 보여주지 않는다. herdr는 왼쪽 에이전트 탭에서 어떤 에이전트가 실행 중이고 어떤 게 입력을 기다리며 어떤 게 끝났는지 바로 보여준다 — 화면에 보이지 않는 5번째, 6번째 터미널까지 관리된다.
- **cmux(Warp 계열) 대비**: 가장 큰 차이는 지속성과 윈도우 지원이다. herdr는 종료해도 백그라운드에서 계속 돌고, Windows·Linux 모두에서 안정적으로 쓸 수 있다.
- **Orca 대비**: 비교 기준 자체가 다르다. Orca는 터미널뿐 아니라 파일 탐색기·코드 편집기·브라우저까지 한 앱에 넣은 IDE형 도구다. VS Code와 터미널을 계속 오가는 사람이라면 Orca가 더 편할 수 있다. 반대로 대부분의 작업을 에이전트에게 맡기고 정말 깊게 리뷰할 때만 편집기를 여는 사람이라면, herdr처럼 터미널을 중심에 두고 관리 기능만 더한 쪽이 훨씬 가볍다.

## 결론: 이런 사람에게 추천

프로젝트 하나에서 에이전트 하나만 돌린다면 그냥 쓰던 터미널로 충분하다. herdr의 진짜 가치는 **서로 다른 코딩 하네스의 에이전트 여러 개를 동시에 돌릴 때** 드러난다 — Claude Code 두 개, Codex 하나, Kimi 하나, Grok 하나, OpenCode 하나 정도부터 체감이 확 달라진다.

기존 터미널 환경에 불편함이 없다면 굳이 바꿀 필요는 없다. 터미널이 어렵게 느껴지는 비개발자라면 억지로 쓸 필요도 없다. 하지만 다음에 해당한다면 한 번쯤 써볼 만하다.

- 지금 터미널 탭을 대여섯 개씩 열어두고 어느 에이전트가 나를 기다리는지 매번 확인하고 있다
- 작업 중이던 터미널을 실수로 닫아본 적이 있다
- 여러 에이전트를 정말 빠르게 오가며 작업하고 싶다
- 원격(VPS) 작업을 자주 한다

오픈소스이고 무료이며, 설치는 명령어 한 줄이다.

```bash
curl -fsSL https://herdr.dev/install.sh | sh
```

## 참고 링크

- [herdr 공식 사이트](https://herdr.dev)
- [herdr 문서](https://herdr.dev/docs)
- [에이전트 인테그레이션 문서](https://herdr.dev/docs/integrations/)
- [herdr 스킬(에이전트용) 문서](https://herdr.dev/docs/agent-skill/)
- [플러그인 마켓플레이스](https://herdr.dev/plugins)
