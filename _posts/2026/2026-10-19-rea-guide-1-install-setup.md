---
title: "REA 설치와 Claude Code 설정 — REA 리버스 엔지니어링 실전 가이드 [1/3]"
date: 2026-10-19 12:10:01 +0900
categories: [AI]
tags: [REA, ReverseEngineering, ClaudeCode, MCP, Ghidra, Hopper]
series: rea-guide
series_index: 1
---

GitHub에서 별 30만 개를 넘긴 [REA(Reverse Engineer Anything)](https://github.com/morluto/rea)의 설치법과 사용법을 3편에 걸쳐 정리합니다. 바탕으로 삼은 영상은 Vivek Mishra의 "REA: Reverse Engineer Anything Explained (Unfiltered)"(2026-10-15, 44분 39초)입니다. 설치부터 실제 맥 앱(MindNode)을 복제해 보는 데까지 편집 없이 보여 주는 영상입니다.

{% include video id="fCSNcSHLyWc" provider="youtube" %}

| 편 | 다루는 내용 | 영상 구간 |
|---|---|---|
| **1편 (이 글)** | REA가 하는 일, 설치, Claude 앱 설정 | 0:00 ~ 13:04 |
| 2편 | Hopper·Ghidra의 역할, REA가 읽을 수 있는 것, MCP 도구 확인 | 13:04 ~ 24:24 |
| 3편 | MindNode 복제 실전, 시간·사용량·한계, 평가 | 24:24 ~ 44:39 |

> 영상은 영어가 섞인 **힌디어**입니다. YouTube 자막을 받을 수 없어서 오디오를 로컬 음성 인식(whisper.cpp medium 모델, 힌디어 → 영어 번역)으로 받아 적어 읽었습니다. 기계 번역이라 표현이 거친 곳이 있고, 그래서 이 글은 대사를 그대로 옮기기보다 **화면에 실제로 나온 내용과 공식 문서**를 근거로 삼았습니다.

## REA는 무엇인가

![GitHub의 morluto/rea 저장소 첫 화면](/assets/img/posts/rea-guide-1-install-setup/01-github-repo.png)

REA는 코딩 에이전트(Claude Code, Codex, Cursor 등)에 **분석 도구를 연결해 주는 MCP 서버이자 CLI**입니다. 공식 한국어 README의 첫 문장이 핵심을 잘 요약합니다.

> REA는 에이전트를 분석 도구에 연결해 네이티브 바이너리, JavaScript와 Electron 앱, .NET 어셈블리, 웹사이트를 검사할 수 있게 합니다. (…) 분석은 로컬에서 실행되며, 결과에는 각 결론의 근거와 한계가 포함됩니다.

즉 REA 자체가 코드를 "복제"하는 것이 아니라, 에이전트가 **소스 코드가 없는 앱의 동작 원리를 근거와 함께 조사**할 수 있게 도구를 쥐여 주는 역할입니다. 복제나 재구현은 그 근거를 받은 에이전트가 합니다.

### 영상이 보여 준 결과물부터

영상은 결과부터 보여 줍니다. 맥 앱 MindNode를 REA로 분석해 웹으로 다시 만든 것으로, 노드 추가, 굵게·기울임, 가지 색, 테마 변경이 실제로 동작합니다.

![REA로 다시 만든 MindNode 복제본. Mindnode Test 1에서 가지가 뻗은 마인드맵](/assets/img/posts/rea-guide-1-install-setup/04-mindnode-clone.jpg)

다만 이 결과는 3편에서 보듯 **수십 분 동안 서브에이전트 여러 개를 돌려 얻은 것이고, 영상 촬영이 끝날 때까지도 완성되지 않았습니다.** "프롬프트 한 줄로 앱을 복제한다"는 SNS 분위기와는 거리가 있다는 점을 먼저 짚고 갑니다.

### 동작 방식: 4단계 조사 루프

영상은 4분 28초부터 REA 저장소의 조사 흐름 그림으로 원리를 설명합니다.

![REA investigation flow 그림. 1 Ask, 2 Inspect & trace(REA), 3 Read the evidence, 4 Use what you learn과 Analysis tools](/assets/img/posts/rea-guide-1-install-setup/05-investigation-flow.jpg)

1. **질문(Ask)**: 내가 에이전트에게 대상(앱, 바이너리, 브라우저)에 대해 묻습니다.
2. **조사·추적(Inspect & trace)**: 에이전트가 REA(MCP 또는 CLI)를 부르고, REA는 Hopper·Ghidra 같은 로컬 분석 도구로 대상을 엽니다.
3. **근거 읽기(Read the evidence)**: 코드, 참조, 그리고 "확인하지 못한 것"이 돌아옵니다.
4. **활용(Use what you learn)**: 에이전트가 설명하고, 구현하고, 테스트합니다. 모자라면 다시 1번으로 돌아가 추가 질문을 합니다.

영상은 이 루프 때문에 **작업이 길어지고 토큰을 많이 쓴다**고 강조합니다. Max 요금제가 아니면 한도에 금방 걸린다는 경고도 이 지점에서 나옵니다.

### 시작 전에: 영상과 공식 문서가 공통으로 하는 경고

영상은 시작하자마자 경고부터 합니다. 연구·학습 목적으로만 쓰고, 복제해서 팔거나 사업으로 삼지 말라는 것입니다. 그리고 "당신의 해자(moat)는 코드가 아니다"라고 말합니다. 진짜 경쟁력은 배포, 고객 지원, 문제를 푸는 방식, 마케팅, UI/UX, 온보딩이라는 주장입니다.

공식 문서도 같은 선을 긋습니다. README의 면책 조항은 REA를 "법을 준수하는 연구, 교육, 상호운용성 확보, 소프트웨어 보존, 그리고 본인이 소유하거나 조사 권한을 가진 소프트웨어의 분석을 위한 도구"로 정의합니다. 남의 앱을 분석할 때는 그 앱의 이용약관(리버스 엔지니어링 금지 조항)을 먼저 확인하세요.

참고로 영상은 6분 53초에 비교 대상으로 ArtCraft를 언급합니다. ArtCraft는 Adobe 제품 기능을 **관찰만 하고 처음부터 새로 만든(clean-room)** 프로젝트로, 코드를 직접 가져오는 REA 방식과 다르다는 설명입니다.

## 설치하기

### 요구 사항

공식 README 기준입니다.

| 항목 | 요구 사항 |
|---|---|
| Node.js | 22.x(22.19 이상), 24.x(24.11 이상) 또는 26 이상, 그리고 npm |
| 에이전트 | Claude Code, Codex, Cursor, Gemini CLI, Grok Build 등 로컬 MCP를 지원하는 에이전트 |
| 네이티브 분석 엔진 | Hopper, Ghidra, IDA 중 하나 (JavaScript/Electron·.NET 정적 분석에는 필요 없음) |

### 설치 명령은 한 줄

![rea.tools 한국어 첫 화면. 코딩 에이전트에 붙여 넣을 설정 프롬프트와 터미널 명령 npx rea-agents@latest setup](/assets/img/posts/rea-guide-1-install-setup/02-rea-tools-home.png)

공식 사이트([rea.tools](https://rea.tools/ko/))는 두 가지 방법을 안내합니다.

**방법 1: 터미널에서 직접 실행**

```bash
npx rea-agents@latest setup
```

**방법 2: 코딩 에이전트에게 맡기기** (공식 사이트가 제시하는 프롬프트 그대로)

```text
npx rea-agents@latest setup을 사용해 REA를 설치하고 이 코딩 에이전트에 연결해 줘.
먼저 설정 변경 계획을 보여 주고 내 승인을 받은 뒤 실행해 줘. 마지막으로 설치를 확인해 줘.
```

설정 과정은 다음 순서로 진행됩니다(공식 설치 문서).

1. 설정할 에이전트를 고릅니다(여러 개 선택 가능).
2. REA가 바꿀 **경로와 변경 내용 전체를 계획으로 보여 줍니다.** 확인 후 승인합니다. 거절하거나 Ctrl-C를 누르면 아무것도 바뀌지 않습니다.
3. 기존 설정을 백업한 뒤 MCP 서버와 버전에 맞는 워크플로 지침(스킬)을 추가합니다.
4. Hopper 설치는 **별도로 한 번 더** 승인을 받습니다.
5. 끝나면 에이전트를 다시 시작합니다.

![GitHub의 한국어 README 상단. npx rea-agents setup 명령이 보인다](/assets/img/posts/rea-guide-1-install-setup/03-readme-ko.png)

**Claude Desktop 앱을 쓴다면 승인 전에 앱을 완전히 종료하세요.** 공식 문서는 "실행 중인 앱이 등록 내용을 덮어쓸 수 있다"고 경고합니다. 영상에서도 Claude가 같은 문서를 근거로 "Chat 탭까지 쓰려면 Cmd+Q로 완전히 끄고 설치하라"고 안내합니다(2편).
{: .notice--warning}

### 영상에서는: Claude 앱의 Code 탭에서 설치

영상은 터미널 대신 **Claude 데스크톱 앱의 Code 탭**에서 진행합니다. `rea-testing` 폴더를 새로 만들어 연 뒤, GitHub 저장소 주소를 붙여 넣고 설치를 맡깁니다. 영상 속 모델은 Opus 5.5였는데, 본인도 "설치만 할 거면 Haiku로도 충분하다"고 말합니다.

설치가 끝나자 Claude가 정리해 준 결과 화면이 이 영상에서 가장 유용한 장면입니다.

![Claude Code가 보고한 REA 설치 결과. MCP 서버가 ~/.claude.json에 등록되고 스킬이 ~/.claude/skills/reverse-engineer-anything에 설치됐으며 170개 도구가 포함됐다는 내용](/assets/img/posts/rea-guide-1-install-setup/06-install-result.jpg)

화면에 나온 내용을 옮기면 다음과 같습니다.

| 항목 | 결과 |
|---|---|
| MCP 서버 | `rea`가 사용자 수준 설정 `~/.claude.json`에 등록되어 모든 프로젝트에서 사용 가능. 기존 설정은 `~/.claude.json.rea.backup`에 백업 |
| 스킬 | `reverse-engineer-anything`이 `~/.claude/skills/reverse-engineer-anything`에 설치. 도구 **170개** 포함 |
| 사용 시작 | 새 Claude Code 세션을 열어야 REA 도구가 로드됨 |
| 네이티브 분석 엔진 | 설정되지 않음. 이것 없이도 JavaScript/Electron 앱, .NET, 웹사이트는 분석 가능 |
| 다른 에이전트 | Claude Desktop, Codex, Cursor 등도 발견했지만 Claude Code만 설정함 |

여기서 눈여겨볼 점은 **Hopper가 자동으로 설치되지 않았다**는 것입니다. 앞에서 본 대로 Hopper 설치는 별도 승인이 필요하기 때문입니다. 화면에는 Hopper까지 설치하는 명령이 따로 안내됩니다.

```bash
npx rea-agents@latest setup --client claude_code --install-hopper
```

영상에서는 "Hopper도 설치해 줘"라고 다시 요청했고, Claude는 hopperapp.com에서 공식 DMG를 받아 코드 서명을 확인한 뒤 Homebrew나 관리자 권한 없이 설치했습니다. 이 동작은 공식 문서의 설명(공식 DMG를 받아 크기와 다이제스트를 검사하고 `~/Applications/Hopper Disassembler.app`에 설치)과 일치합니다.

### 설치 확인과 업데이트·제거

영상에는 나오지 않지만 공식 문서에 있는 관리 명령입니다. `rea` 명령은 `npm install --global rea-agents`로 설치했을 때 쓸 수 있습니다.

```bash
rea doctor --json                       # 읽기 전용 점검. 아무것도 바꾸지 않음
rea doctor --provider ghidra --json     # 분석 엔진 하나만 점검 (hopper, ida도 가능)
rea doctor --client claude_code --json  # 에이전트 등록 하나만 점검
npx rea-agents@latest setup             # npx로 설치했다면 이것으로 갱신
rea uninstall                           # REA가 추가한 등록과 스킬만 제거
```

`rea uninstall`은 Hopper, Node.js, 다른 MCP 서버는 건드리지 않습니다. `--purge-data`를 붙이면 `~/.rea` 아래 캐시와 상태까지 지웁니다.

## Claude 앱 설정하기

영상은 9분 59초부터 Claude 앱 설정을 하나씩 켭니다. REA는 분석 도구를 실행하고, 대상 앱을 직접 열어 화면을 보며 비교해야 하기 때문에 권한이 많이 필요합니다.

### 1. 권한 우회 모드 허용 (Settings → Claude Code → Sessions)

![Claude 앱 설정의 Claude Code 화면. Sessions의 Allow bypass permissions mode가 켜져 있다](/assets/img/posts/rea-guide-1-install-setup/07-bypass-permissions.jpg)

**Allow bypass permissions mode**를 켭니다. 분석 중 승인 요청이 끝없이 나오기 때문입니다. 영상도 "본인 책임으로(at your own risk)"라고 분명히 말합니다.

권한 우회 모드에서는 Claude가 묻지 않고 명령을 실행합니다. **REA 전용 폴더**에서만 쓰고, 회사 저장소나 민감한 파일이 있는 폴더에서는 켜지 마세요.
{: .notice--danger}

### 2. 컴퓨터 깨어 있게 유지

![같은 화면의 아래쪽. Keep this computer awake while Claude works가 켜져 있다](/assets/img/posts/rea-guide-1-install-setup/08-keep-awake.jpg)

작업이 수십 분에서 한 시간 이상 걸리므로 **Keep computer awake while Claude works**를 켭니다. 원격 조종용 **Keep this computer awake for Remote Control**도 함께 켭니다. 같은 화면의 **Folders**에서 Claude Code가 접근할 수 있는 폴더 목록(다운로드 폴더 등)도 확인합니다.

### 3. Computer Use 켜기 (Settings → System)

![Claude 앱 설정의 System 화면. Computer use의 Enable computer use와 Unhide apps when Claude finishes가 켜져 있고, How Claude uses the apps you allow는 Background로 선택됨](/assets/img/posts/rea-guide-1-install-setup/09-computer-use.jpg)

REA로 분석한 뒤 Claude가 **실제 앱을 열어 화면을 보며 결과를 비교**하려면 Computer Use가 필요합니다.

| 설정 | 영상의 선택 | 이유 |
|---|---|---|
| Enable computer use | 켬 | 앱 조작과 화면 확인에 필요 |
| Unhide apps when Claude finishes | 켬 | 작업 후 숨긴 앱을 다시 보이게 함 |
| How Claude uses the apps you allow | **Background** | 내가 다른 작업을 하는 동안 화면을 빼앗지 않도록. Full control도 고를 수 있음 |
| Denied apps | 필요하면 추가 | 건드리면 안 되는 앱을 막아 둠 |
| Accessibility, Screen recording | Granted | macOS 권한. 화면 캡처와 조작에 필요 |

같은 화면의 **Browser use**(브라우저 도구)도 켜 둡니다. 웹사이트를 분석하거나 만든 결과물을 브라우저에서 시험할 때 씁니다. 휴대폰에서 조종하고 싶다면 **Dispatch**를 켜라는 안내도 있습니다.

## 1편 정리

- REA는 코딩 에이전트에 Hopper·Ghidra 같은 분석 도구를 붙여 주는 **MCP 서버 겸 CLI**입니다. 결과마다 근거와 한계를 함께 돌려줍니다.
- 설치는 `npx rea-agents@latest setup` 한 줄이고, 변경 계획을 보여 준 뒤 승인을 받습니다. **Hopper는 별도 승인**(`--install-hopper`)이 필요합니다.
- Claude 앱에서 쓴다면 권한 우회, 깨어 있게 유지, Computer Use, Browser use를 켜야 매끄럽게 돌아갑니다. 다만 권한이 매우 넓어지니 **전용 폴더에서만** 쓰세요.

[2편: Hopper·Ghidra와 REA MCP 도구]({% post_url 2026/2026-10-19-rea-guide-2-tools-first-run %})에서는 분석 엔진 두 가지의 차이와 REA가 실제로 무엇을 읽을 수 있는지, 그리고 설치한 도구가 Claude 어디에 나타나는지를 봅니다.
