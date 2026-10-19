---
title: "Hopper·Ghidra와 REA MCP 도구 — REA 리버스 엔지니어링 실전 가이드 [2/3]"
date: 2026-10-19 12:10:02 +0900
categories: [AI]
tags: [REA, ReverseEngineering, ClaudeCode, MCP, Ghidra, Hopper]
series: rea-guide
series_index: 2
---

[1편]({% post_url 2026/2026-10-19-rea-guide-1-install-setup %})에서 REA를 설치하고 Claude 앱 설정을 마쳤습니다. 이번 편은 영상의 13분 04초부터 24분 24초까지입니다. REA가 쓰는 두 분석 엔진(Hopper, Ghidra)의 차이, 엔진이 있을 때와 없을 때 REA가 읽을 수 있는 범위, 그리고 설치한 REA 도구가 Claude 어디에 나타나는지를 정리합니다.

{% include video id="fCSNcSHLyWc" provider="youtube" %}

## 왜 분석 엔진이 필요한가

영상은 이 부분을 Claude에게 표로 설명해 달라고 해서 보여 줍니다. 핵심은 한 문장입니다. 우리가 내려받는 앱은 **컴파일된 기계어**, 즉 CPU가 실행하는 숫자 덩어리라서 사람도 AI도 그대로는 읽을 수 없습니다. Hopper와 Ghidra는 **디스어셈블러·디컴파일러**로, 이 기계어를 읽을 수 있는 코드에 가까운 형태로 되돌립니다.

![Claude가 정리한 역할 표. 질문은 사용자, 도구 선택과 실행은 REA, 바이너리를 열어 읽을 수 있는 코드로 바꾸는 건 Hopper/Ghidra, 쉬운 말로 설명하는 건 Claude](/assets/img/posts/rea-guide-2-tools-first-run/02-hopper-ghidra-role.jpg)

화면의 표를 옮기면 이렇습니다. 예시 질문은 "Apple 메모 앱의 검색은 어떻게 동작하나?"입니다.

| 단계 | 누가 | 예시 |
|---|---|---|
| 질문한다 | 나 | "메모 검색은 어떻게 동작해?" |
| 도구를 골라 실행하고 근거를 모은다 | **REA** | 메모 앱의 바이너리를 찾아 Hopper로 보냄 |
| 바이너리를 열어 읽을 수 있는 코드로 되돌린다 | **Hopper / Ghidra** | `0x4009a5…` 같은 기계어를 `searchNotes(query)` 같은 함수로 |
| 쉬운 말로 설명한다 | Claude | "입력하는 대로 단어를 색인하고 접두어로 맞춰 본다…" |

REA는 이 과정의 **중개자**입니다. Claude가 REA에 질문하면, REA가 Hopper나 Ghidra로 앱을 열고, Claude는 그 출력을 읽습니다.

## Hopper vs Ghidra

![Claude가 정리한 Hopper와 Ghidra 비교표](/assets/img/posts/rea-guide-2-tools-first-run/03-hopper-vs-ghidra.jpg)

영상 화면의 비교표입니다.

| | Hopper | Ghidra |
|---|---|---|
| 만든 곳 | 프랑스의 작은 독립 회사 | 미국 NSA, 오픈소스 |
| 비용 | 데모 무료, 정식 라이선스 $99 | 무료, 제한 없음 |
| 데모 제한 | 세션당 약 30분, 저장 불가 | 없음 |
| 설치 크기 | 약 100MB | 약 500MB, Java 필요 |
| 속도 | 파일을 빨리 엶 | 느리고 메모리를 많이 씀 |
| 강한 분야 | 맥·아이폰 앱(Objective-C, Swift) | 윈도우, 리눅스, 펌웨어, 특이한 CPU까지 전부 |
| 디컴파일 품질 | 좋음 | 대체로 더 좋고 자세함 |
| 비유 | 빠르고 간편한 주머니칼 | 모든 공구를 갖춘 작업장 |

Claude의 추천은 **"빠른 맥 앱 확인은 Hopper, 긴 세션과 맥 이외의 대상은 Ghidra를 추가"**였습니다. 영상에서는 실제로 Hopper 데모가 작업 도중 만료되어 Ghidra로 바꾸게 됩니다(3편).

공식 문서로 보충할 점이 있습니다.

- **Ghidra 버전과 Java**: REA는 **Ghidra 12.1.x**와, 그 Ghidra가 요구하는 64비트 전체 JDK를 받아들입니다. 현재 12.1은 **JDK 21 이상**이 필요합니다. 애플 실리콘 맥에서 Rosetta로 돌아가는 x86_64 JDK는 진단에서 실패하므로 `JAVA_HOME`으로 맞는 JDK를 지정해야 합니다.
- **Hopper 첫 실행**: 맥에서 Hopper를 처음 열면 데모 모드를 고르거나 라이선스를 넣는 창이 뜹니다. 공식 FAQ는 **첫 REA 작업 전에 같은 사용자 세션에서 이 창을 끝내 두라**고 안내합니다.
- **IDA**도 세 번째 선택지로 지원됩니다.

![Hopper Disassembler의 라이선스 창. Try the Demo, Purchase a License, Offline Activation 버튼](/assets/img/posts/rea-guide-2-tools-first-run/05-hopper-license.jpg)

영상에서도 이 창(Try the Demo / Purchase a License / Offline Activation / Validate License)이 뜨고, Try the Demo를 눌러 진행합니다.

## REA가 읽을 수 있는 것: 엔진이 없을 때와 있을 때

![Claude가 정리한 Before vs after 표. Electron, .NET, 웹사이트는 엔진 없이도 되고, 네이티브 맥 앱, 윈도우 exe, 게임 엔진·펌웨어·CLI 도구는 엔진이 있어야 실제 로직을 읽을 수 있다](/assets/img/posts/rea-guide-2-tools-first-run/04-before-after.jpg)

1편에서 "네이티브 분석 엔진 없이도 일부는 분석할 수 있다"고 했는데, 그 범위를 정리한 표입니다.

| 대상 | Hopper/Ghidra 없이 | 있으면 |
|---|---|---|
| Electron 앱(Slack, VS Code, Notion) | ✅ 됨. JavaScript라서 | ✅ 같음 |
| .NET 앱(많은 윈도우 도구) | ✅ 됨 | ✅ 같음 |
| 웹사이트 | ✅ 됨 | ✅ 같음 |
| 네이티브 맥 앱(메모, Safari, Final Cut) | ❌ 파일 이름과 문자열만 보임 | ✅ 실제 로직을 읽음 |
| 윈도우 `.exe`, 리눅스 프로그램 | ❌ 같은 한계 | ✅ 읽을 수 있는 코드 |
| 게임 엔진, 펌웨어, CLI 도구 | ❌ | ✅ 특히 Ghidra가 강함 |

같은 질문("메모 검색은 어떻게 동작하나?")에 대한 차이도 보여 줍니다.

- **엔진 없이**: "`ICSearchIndexer`라는 함수가 있다." 이름은 알지만 어떻게 동작하는지는 모릅니다.
- **엔진이 있으면**: "텍스트를 단어로 쪼개 로컬 색인에 저장하고, 일치 유형에 따라 결과 순위를 매긴다. 근거로 디컴파일한 함수를 첨부한다."

공식 README의 "분석할 수 있는 대상" 표는 이보다 훨씬 넓습니다. Android APK(JADX 필요), WASM, SQLite, 네트워크 캡처(HAR), 펌웨어(Binwalk), Go·Rust 바이너리의 빌드 정보 등 20가지 이상을 다룹니다. 영상이 다룬 것은 그중 데스크톱 앱 쪽입니다.

![REA 공식 사이트의 가이드 목록 페이지](/assets/img/posts/rea-guide-2-tools-first-run/01-rea-guides.png)

대상별 자세한 절차는 공식 사이트의 [실습 가이드](https://rea.tools/ko/guides/)에 정리되어 있습니다.

## 첫 실행: Obsidian 분석

영상은 20분 19초에 "REA를 한 번 돌려 줘"라고만 요청합니다. Claude는 컴퓨터에 설치되어 있던 **Obsidian**(Electron 앱)을 골라 분석했고, 백그라운드 작업자, 메인 화면에서 처리하는 무거운 작업, 함수 호출 수 같은 내용을 정리해 보여 줍니다. 결과는 작업 폴더의 `rea-output/obsidian-analysis.json`으로 저장됩니다.

Obsidian은 Electron 앱이라 위 표대로 **분석 엔진 없이도** 됩니다. 처음 써 볼 때는 이렇게 Electron 앱이나 웹사이트로 시작하면 Hopper·Ghidra 설치 문제와 섞이지 않아 좋습니다. 공식 README의 터미널 예시도 같은 종류입니다.

```bash
# 압축을 푼 JavaScript/Electron 앱 폴더나 ASAR를 분석
npx -y rea-agents@latest analyze-javascript-application /absolute/path/to/app --json
```

## REA 도구는 Claude 어디에 나타나나

설치 직후 영상 속 세션에서는 REA 도구가 보이지 않았습니다. 그래서 "REA의 MCP 도구가 데스크톱 MCP 설정에 보이나? Claude를 껐다 켜야 하나?"라고 묻는데, 이 답이 처음 쓰는 사람에게 가장 헷갈리는 부분을 정확히 짚어 줍니다.

![Claude의 답변. Connectors, Claude Code config, Claude Desktop config 세 곳 중 REA는 ~/.claude.json(Code 탭)에만 있고, Code 탭은 새 세션만 열면 되며 Chat 탭은 앱을 끄고 별도 설정이 필요하다는 표](/assets/img/posts/rea-guide-2-tools-first-run/06-where-mcp-tools.jpg)

| 위치 | 들어 있는 것 | REA가 있나 |
|---|---|---|
| Connectors(claude.ai 설정) | Gmail, Slack 같은 클라우드 서비스 | ❌ REA는 클라우드가 아니라 내 맥에서 돈다 |
| Claude Code 설정(`~/.claude.json`) | **Code 탭**의 로컬 MCP 서버 | ✅ 설정 과정이 여기에 넣었다 |
| Claude Desktop 설정(`claude_desktop_config.json`) | **Chat 탭**의 로컬 MCP 서버 | ❌ Claude Code만 설정했다 |

지금 세션에서 안 보인 이유도 설명합니다. **MCP 서버는 세션이 시작될 때 로드되는데, 이 세션은 REA를 설치하기 전에 시작됐기 때문**입니다.

| 쓰고 싶은 곳 | 할 일 | Claude를 꺼야 하나 |
|---|---|---|
| Code 탭 | **새 Code 세션**을 연다. MCP 서버 목록에 REA가 도구 약 170개와 함께 나타난다 | ❌ 아니요 |
| Chat 탭 | Claude를 완전히 끄고(Cmd+Q) `npx rea-agents@latest setup --client claude_desktop` 실행 후 다시 연다 | ✅ 예. 실행 중인 앱이 새 설정을 덮어쓸 수 있다 |

그리고 "**Code 탭만으로 충분하다**"고 권합니다. REA는 Claude가 명령을 실행하고 파일을 읽을 수 있는 곳에서 가장 잘 동작하기 때문입니다.

![새 Code 세션에서 REA를 쓸 수 있는지 묻자, 네이티브 바이너리, 관리 코드와 JavaScript, Electron과 브라우저, Android까지 할 수 있는 일을 나열한 답](/assets/img/posts/rea-guide-2-tools-first-run/07-new-session-rea.jpg)

새 세션에서 "REA를 쓸 수 있어?"라고 묻자 Claude는 REA가 연결되어 도구가 로드됐다고 답하고, 할 수 있는 일을 분야별로 나열합니다(네이티브 바이너리, 관리 코드와 JavaScript, Electron·브라우저, Android·모바일).

공식 문서에는 세션 안에서 지금 쓸 수 있는 작업을 확인하는 방법도 있습니다. MCP 도구 `binary_session`을 `{}`로 호출하면 대상을 열기 전에도 작업별 사용 가능 여부와 이유(`tool_availability`)를 돌려줍니다.

### 작은 함정: 도구 이름을 정확히

24분 즈음 영상에서 "Girdhara를 쓰고 싶다"고 입력하자, Claude는 그런 도구를 찾지 못했다며 무엇을 뜻하는지 되묻습니다. 발음을 그대로 적은 오타 때문입니다. 결국 "REA를 먼저 이해하고 지금은 Hopper를 쓰자"로 다시 지시합니다. **엔진 이름(Hopper, Ghidra, IDA)은 정확히 적는 것**이 시간을 아끼는 길입니다.

## 2편 정리

- Hopper와 Ghidra는 기계어를 읽을 수 있는 코드로 되돌리는 엔진이고, REA는 그 사이를 잇는 중개자입니다.
- **Hopper**는 빠르고 맥 앱에 강하지만 데모가 30분으로 제한되고, **Ghidra**는 무료·무제한이지만 무겁고 Java(JDK 21+)가 필요합니다.
- Electron 앱, .NET, 웹사이트는 엔진 없이도 분석할 수 있어 **첫 시험 대상으로 적당**합니다.
- 설치 후에는 **새 Code 세션**을 열어야 REA 도구(약 170개)가 보입니다. Chat 탭까지 쓰려면 앱을 끄고 별도로 설정합니다.

[3편: MindNode 복제 실전과 현실적인 평가]({% post_url 2026/2026-10-19-rea-guide-3-mindnode-clone %})에서는 실제 복제 프롬프트, 서브에이전트 구성, 타임아웃과 사용량, 그리고 결과물을 봅니다.
