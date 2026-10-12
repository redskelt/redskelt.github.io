---
title: "Claude Code Mods로 무엇을 만들 수 있나 — 코드팩토리 영상 10가지 사례 정리"
date: 2026-10-12 12:30:00 +0900
categories: [AI]
tags: [ClaudeCode, mods, 코드팩토리]
---

코드팩토리의 ["Claude Code Mods 설명, 10가지 사용 사례"](https://youtu.be/z-GwTV_qID8)(10-06, 8분 37초)를 정리한다. [이번 주 트렌드]({% post_url 2026/2026-10-12-trending-weekly-1012 %})에서 국내 mods 영상 중 가장 압축된 소개로 꼽은 영상이다. 영상의 설명을 자동 자막으로 옮겨 읽고, 화면에 나온 장면을 직접 캡처하고, 기술적인 주장은 Claude Code 공식 문서와 대조했다.

{% include video id="z-GwTV_qID8" provider="youtube" %}

### 영상이 설명하는 mod의 원리

영상의 첫 장면은 이렇게 요약된다. Claude Code의 화면을 직접 바꿀 수 있게 됐고, 입력창 위에 원하는 정보를 붙이거나 옆에 에이전트 패널을 띄우거나 응답 속 이메일을 가릴 수 있다. 이를 가능하게 하는 것이 TypeScript 코드를 미들웨어 방식으로 붙이는 "모드" 시스템이다.

구조는 세 단계다.

1. mod는 Claude Code **플러그인**이다. 플러그인 이름과 버전을 적고, `hooks.json`의 `modules`에 실행할 코드 파일 경로를 연결한다.
2. Claude Code는 프롬프트를 보낼 때, 도구를 호출할 때, 응답을 화면에 표시할 때 각각 **이벤트**를 발생시킨다. 원하는 이벤트에 함수를 등록한다.
3. 함수는 **`$`(Claude Code 기능), 이벤트, `next`** 세 인자를 받는다. `next`에 이벤트를 그대로 넘기면 기존 동작이 유지되고, 고친 이벤트를 넘기면 다음 처리가 그 값을 쓴다. `next`를 호출하지 않고 값을 반환하면 그 값이 결과가 된다.

영상은 웹 개발자에게 익숙한 미들웨어 구조라고 비유한다. 이 세 가지는 공식 문서(`create`, `events`)의 설명과 일치했다. 문서도 "hook은 이벤트와 Claude Code 동작 사이에 놓여 이벤트를 관찰하거나 고치거나 직접 답할 수 있다"고 쓰고, 인자 세 개를 같은 이름으로 소개한다.

### 데모: 이메일 가리기

영상의 핵심 예제는 응답 속 이메일 주소를 가리는 mod다. 메일 초안 응답에서 수신자 이메일이 `<[이메일 가림]>`으로 바뀌어 보이고, 입력창 위 띠에는 "촬영 모드 · 이메일 가림 ON · 표시하기" 버튼이 붙는다.

![이메일 주소가 [이메일 가림]으로 바뀐 응답과 입력창 위 띠](/assets/img/posts/claude-code-mods-codefactory/01-email-mask-on.png)

버튼을 누르면 이메일이 보이고, 띠의 문구는 "이메일 표시 중 · 다시 가리기"로 바뀐다.

![표시하기를 누르자 이메일이 드러나고 버튼이 다시 가리기로 바뀐 화면](/assets/img/posts/claude-code-mods-codefactory/02-email-mask-toggle.png)

만드는 순서는 이렇다. 어시스턴트 메시지를 그리는 `ui.render` 이벤트에 함수를 등록하고, 이벤트의 `props`에서 표시할 텍스트를 읽어 `mask` 함수로 이메일을 `[이메일 가림]`으로 바꾼 뒤 `next`에 넘긴다. 가릴지 말지는 `hidden` 값으로 정한다. 사용자가 바꿀 수 있도록 입력창 위(`AbovePrompt`)에 텍스트와 버튼을 그리고, 버튼의 `onPress`에서 `hidden`을 뒤집은 다음 `$.ui.invalidate`로 화면을 다시 그리게 한다. 화면의 코드가 이 설명과 맞는다. 이메일을 찾는 정규식과 `mask` 함수가 보인다.

![이메일 정규식과 mask 함수가 보이는 codefactory-email-mask의 register.js](/assets/img/posts/claude-code-mods-codefactory/03-email-mask-code.png)

영상은 이 과정에서 **화면에 표시되는 내용만 바꾼다**고 강조한다. 모델은 원래 이메일 주소로 메일 초안을 쓰고, mod는 결과를 화면에 보여줄 때만 동작하니 원본 결과값과 Claude가 읽는 내용은 그대로라는 설명이다. 공식 문서에는 이 문장과 똑같은 서술은 찾지 못했다. 다만 구조는 맞아 보인다. 문서가 화면을 그리는 이벤트(`ui.render`)와 저장되는 대화 행을 고치는 이벤트(`session.append`: "저장되기 전에 각 행의 텍스트 블록을 다시 쓸 수 있다")를 따로 둔다. 가림 mod가 앞쪽 이벤트에만 연결돼 있는 한 모델이 읽는 값은 바뀌지 않는다고 보는 게 합리적이지만, 영상에 나온 mod의 전체 소스를 확인한 것은 아니다.

### 10가지 사례

영상이 꼽은 열 가지를 화면과 함께 본다. 사례별 mod 이름은 영상 속 mod 목록(사례 4의 이미지 왼쪽에 잠깐 나온다)에서 읽을 수 있는 것만 적었다.

**1. PR 상태 확인.** 입력창 위에서 리뷰와 검사 상태를 바로 본다. 화면에는 `claude-code#99540 blocked · review required · ✓0 (+1 optional ✗)` 같은 한 줄이 떠 있다. 띠의 뒷부분에는 `sec-default: an organization's ceiling on a tool…` 같은 PR 제목이 이어진다. 영상 속 mod 목록(사례 4의 이미지 왼쪽)에는 "Cc pr tracker"(Seza Akgün)가 있고, 설명은 "Claude Code 세션에서 GitHub PR의 병합 상태와 리뷰를 본다"다.

![입력창 위에 PR의 병합 상태, 리뷰 필요, 검사 결과가 표시된 띠](/assets/img/posts/claude-code-mods-codefactory/04-pr-status.png)

**2. Linear 연결.** Claude Code 안에서 이슈를 검색하고 선택한 이슈를 작업 요청으로 넘긴다. 작업을 마치면 결과를 댓글 초안으로 정리해 올릴 수도 있다. 화면에는 Linear 이슈 225개 중 검색과 선택을 하는 모달이 뜬다. 같은 목록(사례 4의 이미지)에 "Codefactory linear workflow"(Code Factory)가 있어, 영상 제작자가 만든 mod로 보인다.

![Linear 이슈를 검색하고 고르는 모달 화면](/assets/img/posts/claude-code-mods-codefactory/05-linear.png)

**3. 문단 직접 선택해 수정.** 옆 패널에서 고칠 문단의 연필 버튼을 누르고 어떻게 바꿀지 코멘트를 적으면, Claude가 그 문맥으로 문단을 고치고 패널도 수정된 내용을 보여준다. 화면에는 문서 문단 옆의 입력칸에 "what to change in lines 9-…"와 "send" 버튼이 있다.

![문단의 연필 버튼으로 수정 요청을 적는 입력칸](/assets/img/posts/claude-code-mods-codefactory/06-paragraph-edit.png)

**4. 브라우저.** 지원하는 터미널에서 Claude Code 옆에 브라우저를 붙여 대화와 웹페이지를 한 화면에 놓는다. 화면은 terminal-browser mod의 `hooks/register.tsx`로, 터미널이 아니면 빈 `Box`를 돌려주는 분기가 보인다. 이 사례는 공식 문서가 아니라 zenbu-labs의 커뮤니티 mod다. 해당 mod의 README는 별도 프로그램 설치(`curl ... | bash`)와 지원 터미널 조건을 적는다.

![terminal-browser mod의 register.tsx와 왼쪽의 mod 목록](/assets/img/posts/claude-code-mods-codefactory/07-browser.png)

**5. 다이어그램.** 응답의 Mermaid 코드가 문자로만 보이던 자리에 문자로 그린 도식을 보여준다. 로그인 분기나 결제 흐름을 표현할 때 호환되는 프로그램을 따로 실행할 필요가 없다. 화면은 `AssistantMessage`에 `ui.render`를 건 `codefactory-mermaid`의 코드와 주문→결제→배송 도식이다. 같은 목록에는 "Mermaid diagrams in Claude Code"(Gal Elmalah)가 있다.

![Mermaid 블록을 문자 도식으로 바꾸는 mod의 코드와 주문-결제 도식](/assets/img/posts/claude-code-mods-codefactory/08-mermaid.png)

**6. 게임.** 응답을 기다리는 동안 게임을 한다. 화면에는 입력창 위에서 테트리스가 돌아간다. 같은 목록의 "Cc arcade"(Seza Akgün) 설명은 "Claude Code 프롬프트 위의 게임(스네이크, 테트리스, 2048, 지뢰찾기…)"이다.

![입력창 위에서 실행되는 테트리스 미니 게임](/assets/img/posts/claude-code-mods-codefactory/09-game.png)

**7. 한국어 UI.** 슬래시 명령 설명과 설정 항목을 한국어로 보여준다. 영상은 한국어에 한정되지 않고 다른 언어도 같다고 말한다. 화면은 `/config`의 설정 항목이 한글로 나온 모습이고, 같은 목록의 "Ko ui"(moduvoice) 설명은 "Claude Code의 슬래시 커맨드 설명과 /config 항목, 일부 화면 문구를 한국어로 보여준다"다. 영상은 "전부 바꿀 수 있다"고 하지만, 화면에서 바뀐 것은 "일부"로 보인다.

![/config 설정 항목이 한국어로 표시된 화면](/assets/img/posts/claude-code-mods-codefactory/10-korean-ui.png)

**8. 특정 문자 가리기.** 앞의 이메일 가림의 확장이다. 촬영하거나 화면을 공유할 때 이메일, Base64로 인코딩된 값, JWT 토큰처럼 출력되면 안 되는 문자를 가리고, 필요할 때만 버튼으로 확인한다.

**9. 컨텍스트 사용량.** 입력창 위에 현재 컨텍스트 사용량과 최근 턴에서 늘어난 양을 보여준다. 화면에는 `Clear 9% of context 87.4k / 1M last turns`가 떠 있다. 같은 목록의 "Token weather"는 "Claude Code DevRel"의 mod로 표시돼 있다. 공식 문서가 소개하는 Anthropic의 샘플 token-weather가 같은 이름이다.

![입력창 위의 Clear 9% of context 87.4k/1M 표시](/assets/img/posts/claude-code-mods-codefactory/11-context-usage.png)

**10. 에이전트 관제.** 현재 세션에서 실행 중인 에이전트를 옆 패널에 모아 보여준다. 각 에이전트를 눌러 대화와 도구 사용 내역을 보고 어떤 작업을 맡았는지도 확인한다. 영상은 dynamic workflow를 쓸 때 유용하다고 말한다. 화면에는 `Agents · 2 running`과 각 에이전트의 모델과 입출력 토큰이 보인다.

![Agents 패널에 실행 중인 에이전트 두 개와 모델·토큰 정보가 나온 화면](/assets/img/posts/claude-code-mods-codefactory/12-agents-panel.png)

### 공식 문서와 맞춰 본 결과

영상의 기술적 주장 14개를 공식 문서(overview, create, reference, interface, events, api)와 대조했다. 대조표의 인용문 중 일부가 문서 원문과 달라서 원문을 다시 찾아 고쳤다.

| 판정 | 개수 | 내용 |
|---|---|---|
| 일치 | 9 | 플러그인 구조, 이벤트와 함수 등록, `$`·이벤트·`next` 세 인자, `next`로 넘기기와 직접 반환, `$`로 쓰는 기능, `ui.render` 사용, `AbovePrompt`, `$.ui.invalidate` |
| 부분 일치 | 3 | 화면만 바꾸고 모델 입력은 그대로(명시 문장 없음, 구조는 일치), 다이어그램(문서에는 문자 도식 요소만 있고 Mermaid 변환은 커뮤니티 mod), 한국어 UI(문서에는 명령 설명을 바꿀 수 있는 지점만 있음) |
| 공식 문서에 없음 | 2 | 대기 중 게임, 터미널 옆 브라우저(둘 다 커뮤니티 mod의 사례) |

불일치로 판정된 주장은 없었다. 다만 브라우저·다이어그램·게임·한국어 UI(사례 4~7)처럼 영상이 "할 수 있다"고 소개한 것 상당수가 공식 기능이 아니라 커뮤니티 mod라는 점은 구분해서 읽는 게 좋다.

### 영상이 다루지 않은 것: 신뢰와 보안

자막을 끝까지 읽어도 설치 위험이나 검증 방법에 대한 언급은 없다. "보안 때문에 가리고 싶다"는 말은 가림 기능의 이유로 나올 뿐이다. 공식 문서는 반대쪽을 분명히 경고한다.

- mod는 **사용자 권한으로 실행되는 코드**다. 파일 읽기·쓰기, 프로세스 시작, 네트워크 요청이 가능하고, 환경변수와 설정 파일(API 키 포함)도 읽을 수 있다.
- 세션의 **모든 프롬프트와 도구 호출을 볼 수 있다.**
- **샌드박스가 없다.** 샌드박스를 켜도 mod가 시작한 프로세스는 그 밖에서 실행된다.
- 설치 전에 `claude plugin validate`로 mod가 처리하는 이벤트(`hooks:`)와 요청하는 동작(`calls:`)을 실행 없이 볼 수 있다.

영상 사례 중 "정보 가리기"처럼 민감한 화면을 다루는 mod일수록, 화면은 가리지만 mod 자체는 원문을 모두 볼 수 있다는 점을 알아야 한다. 어디서 받는지, 소스를 읽었는지가 중요하다.

### 시작하는 방법

영상의 마지막 조언은 직접 만들어 보라는 것이다. 입력창 위에 현재 git 브랜치를 보여주는 mod를 만들어 달라고 Claude에게 말하면 알아서 코드를 짜 준다. 같은 예시(`make a mod that shows the current git branch above the prompt`)가 공식 문서의 "Ask Claude for a mod" 안내에도 있다. 공식 문서의 "Ask Claude for a mod"와 설정 참조(`cleanupPeriodDays`)에 따르면 이렇게 만든 mod는 `~/.claude/dev-mods/` 아래 세션 폴더에 저장되고 그 세션에서만 로드되며, `cleanupPeriodDays`(기본 30일)가 지나면 지워진다. 계속 쓰려면 폴더를 복사해 두고 `claude --plugin-dir <폴더>`로 로드한다.

### 정리

이 영상은 mod가 무엇이고 어디에 쓰이는지를 8분에 빠르게 보여주는 입문용이다. 이벤트·`next`·화면 위치(`ui.render`, `AbovePrompt`)라는 핵심 개념은 공식 문서와 맞고, 열 가지 사례의 화면도 실제로 동작하는 mod를 보여준다. 다만 사례 대부분이 커뮤니티 mod이고, 설치 전 확인할 점은 영상에 없다. 이 글의 확인 방법의 한계도 적어 둔다. 자막은 자동 생성이라 일부 단어가 틀려 있고, 영상에 나온 mod의 전체 소스는 보지 않았으며, 사례별 mod 이름과 설명은 영상 화면의 목록에서 읽을 수 있는 것만 적었다.
