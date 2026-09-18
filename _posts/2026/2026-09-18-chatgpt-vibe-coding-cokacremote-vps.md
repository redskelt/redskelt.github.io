---
title: "ChatGPT로 바이브 코딩하기 (1): VPS + cokacremote MCP로 코딩 에이전트처럼 쓰기"
date: 2026-09-18 09:30:00 +0900
categories: [AI]
tags: [ChatGPT, MCP, cokacremote, 바이브코딩]
---

## 이 글은 뭘 다루나

Codex 같은 AI 코딩 에이전트는 내 컴퓨터에서 직접 실행되기 때문에 코드를 읽고, 고치고, 실행해가며 개발할 수 있다. 반면 ChatGPT는 기본적으로 웹 브라우저에서 쓰는 범용 도구라서, 별다른 조치 없이는 내가 작업 중인 코드에 접근할 수 없다.

그런데 ChatGPT에는 **MCP(Model Context Protocol)** 연결 기능이 있다. 코딩 에이전트가 하는 일 — 명령어 실행, 파일 읽기/쓰기, 시스템 상태 확인 — 을 그대로 해주는 MCP 서버를 클라우드 컴퓨터(VPS)에 띄워두고 ChatGPT에 연결하면, ChatGPT도 사실상 코딩 에이전트처럼 동작한다.

이 시리즈는 [cokacremote](https://github.com/kstost/cokacremote)라는 오픈소스 MCP 서버를 이용해서 이 환경을 구성하는 방법을 다룬다.

- **1편(이 글)**: VPS 같은 클라우드 컴퓨터에 cokacremote를 설치하고 ChatGPT와 연결해서 실제로 바이브 코딩을 해본다.
- **2편**: 클라우드 컴퓨터 대신 **내가 쓰는 PC**를 Docker + Cloudflare Tunnel로 안전하게 열어서 같은 걸 해본다.

> 참고 영상: [챗GPT 알뜰하게 본전 뽑는 방법 | 바이브코딩](https://www.youtube.com/watch?v=dKQQs-z_E64) (코드 깎는 노인)

## 왜 굳이 이렇게까지 하나

Codex는 개발 전용이다 보니 사용량 제한이 ChatGPT 채팅보다 훨씬 빡빡하다. 개발자라면 Codex 사용량은 금방 소진되는데, 반대로 ChatGPT 채팅 사용량은 상대적으로 널널하게 남는 경우가 많다. 이 놀고 있는 ChatGPT 사용량으로 코딩을 해볼 수 없을까 하는 아이디어에서 출발한다.

ChatGPT에 GitHub 플러그인을 연결하면 저장소 코드를 읽고 고치는 것까지는 가능하지만, 실행해보면서 검증하는 게 어렵다. ChatGPT 내장 임시 가상머신은 인터넷 연결이 끊겨 있어서 배포된 결과를 확인할 수도 없다. MCP로 인터넷에 연결된 컴퓨터를 붙여주면 이 한계가 사라진다.

## 무엇을 준비해야 하나

1. **작업용 컴퓨터**: VPS(호스팅거, AWS EC2/Lightsail 등) 하나. 개인 PC를 바로 노출하는 것보다 VPS를 쓰는 편이 안전하고 부담이 적다. (개인 PC로 하고 싶다면 2편의 Docker + Tunnel 방식을 권장한다.)
2. **cokacremote MCP 서버**: 이 VPS에 설치할 도구. GitHub 저장소를 코딩 에이전트에게 클론/설치까지 맡기면 된다.
3. **도메인 주소** (선택이지만 권장): VPS의 IP를 직접 쓸 수도 있지만, 나중에 웹 서비스를 만들어서 확인하려면 도메인이 있는 편이 편하다.
4. **ChatGPT 개발자 모드**: MCP 연결 기능을 쓰려면 활성화해야 한다.

## cokacremote란

![kstost/cokacremote GitHub 저장소 메인 화면](/assets/img/posts/chatgpt-vibe-coding-cokacremote/cokacremote-github-repo.png)

[cokacremote](https://github.com/kstost/cokacremote) 저장소 설명에 따르면, "ChatGPT나 다른 MCP 클라이언트가 원격 Linux 서버에서 직접 작업할 수 있게 해준다"는 도구다. SSH로 서버를 만지는 걸 AI가 대신 하는 셈이다.

제공하는 MCP 도구는 20개 정도이며, 크게 세 갈래로 나뉜다.

| 분류 | 대표 도구 | 하는 일 |
|---|---|---|
| 실행 | `exec_command`, `run_script`, `read_process` | 명령어/스크립트 실행, 실행 중인 프로세스에 입출력 |
| 파일 | `read_file`, `write_file`, `upload_file`, `apply_patch` | 파일 읽기/쓰기/업로드, 대용량은 base64 청크 전송 |
| 관리 | `list_directory`, `make_directory`, `chmod_path` | 디렉터리 탐색, 권한 변경 등 서버 관리 작업 |

인증은 고정 Bearer 토큰(`MCP_AUTH_TOKEN`) 또는 OAuth 2.1을 지원한다.

> ⚠️ **보안 주의**: 저장소 README가 명시적으로 경고한다 — "cokacremote는 의도적으로 강력하다. 샌드박스도, 명령어 허용목록도, 실행 승인 절차도, 경로 제한도 없다." 즉 이 MCP 서버에 접근할 수 있는 사람/AI는 그 서버 안에서 뭐든 할 수 있다. 그래서 **반드시 HTTPS + 강력한 인증 토큰**으로 보호하고, 신뢰할 수 있는 클라이언트만 연결해야 한다. root 권한으로 돌리면 서버의 모든 자산에 접근 가능해지니 가능하면 권한을 제한한 계정으로 운용하자.

## 1단계: MCP 서버 설치를 코딩 에이전트에게 맡기기

cokacremote를 직접 손으로 설치할 수도 있지만(README의 Quick Start 참고), 이미 Codex 같은 코딩 에이전트를 쓰고 있다면 그 에이전트에게 맡기는 게 더 쉽다.

VPS의 접속 정보(IP, SSH 키 또는 비밀번호)를 코딩 에이전트에게 알려주고 다음과 같이 요청하면 된다.

> "이 VPS(IP: xxx.xxx.xxx.xxx)에 SSH로 접속해서 https://github.com/kstost/cokacremote 를 설치하고, systemd 서비스로 등록해서 항상 실행되도록 해줘. HTTPS로 접근할 수 있게 Nginx 리버스 프록시도 구성하고, MCP_AUTH_TOKEN 인증 토큰을 생성해줘."

직접 설치하려면 README의 로컬 빠른 시작 명령을 VPS에서 그대로 실행하면 된다.

```bash
git clone https://github.com/kstost/cokacremote.git
cd cokacremote
npm install
npm run build
export MCP_AUTH_TOKEN="$(openssl rand -hex 32)"
npm start
```

Node.js 22 이상이 필요하고, 기본 포트는 3000이다. 프로덕션에서는 `/opt/remote-dev-mcp` 같은 경로에 두고 systemd로 관리하며, Nginx로 HTTPS를 앞단에 씌우는 걸 권장한다.

설치가 끝나면 다음 두 가지를 꼭 챙겨둔다.

- **MCP 서버 URL** (예: `https://mcp.내도메인.com`)
- **인증 토큰** (`MCP_AUTH_TOKEN` 값)

## 2단계: ChatGPT에 MCP 서버 연결하기

![OpenAI 공식 도움말의 "Apps in ChatGPT" 문서 — 외부 도구/커넥터를 ChatGPT에 연결하는 방법을 안내한다](/assets/img/posts/chatgpt-vibe-coding-cokacremote/chatgpt-apps-connectors.png)

1. ChatGPT **설정 → 보안 및 로그인**에서 **개발자 모드**를 켠다.
2. 왼쪽 메뉴의 **플러그인(커넥터)** 페이지로 들어가서 **+** 버튼을 누른다.
3. MCP 서버 이름을 적당히 입력한다 (예: `cokacremote`).
4. **연결(URL)** 항목에 1단계에서 확인한 MCP 서버 URL을 입력한다.
5. **만들기**를 누르면 인증 과정으로 넘어간다. 여기서 앞서 발급받은 인증 토큰을 붙여넣고 승인한다.
6. ChatGPT 화면으로 돌아오면 연결이 끝난 것이다.

## 3단계: 실제로 써보기

연결한 MCP 서버 이름을 언급하면서 요청하면 된다.

**시스템 정보 확인해보기**

> "cokacremote를 이용해서 이 서버의 저장 공간, 램 크기, OS 종류 같은 시스템 정보를 확인해줘."

MCP 도구를 통해 실제로 서버에 명령을 내려서 정보를 가져온다. 램이 부족하다면 "메모리 좀 늘려줘"라는 요청도 (VPS 콘솔 API 등을 통해) 처리 가능한 경우가 있다.

**블로그 사이트 만들어보기**

> "마크다운으로 글을 쓸 수 있는 블로그를 만들어줘. 글 데이터는 MySQL에 저장하고, 프론트엔드는 OO 스택을 써줘."

이 요청 하나로 ChatGPT가 실제로 하게 되는 일:

1. VPS에 MySQL 설치 및 설정
2. 테이블 생성, 데이터 저장/조회 코드 작성
3. 마크다운 에디터 화면 구현
4. 빌드 및 실행
5. (추가 요청 시) Nginx 설정으로 외부 접속 가능하게 배포
6. (추가 요청 시) 미리 연결해둔 도메인으로 접속되게 설정

이 모든 과정이 VPS 안에서 실제로 일어나기 때문에, 완료 후 브라우저로 도메인에 접속하면 진짜 동작하는 블로그를 볼 수 있다.

**MCP 도구 사용에는 안전장치가 있다**

ChatGPT는 MCP 도구를 실행하기 전에 "이 작업을 해도 되는지" 판단하는 단계를 거친다. 예를 들어 "관리자 비밀번호를 보여줘"라고 요청하면 민감 정보 노출로 판단해 차단한다. "비밀번호를 1234로 바꿔줘"처럼 너무 단순한 값으로 바꾸는 요청도 보안상 취약하다는 이유로 거부되고, 대신 복잡한 비밀번호를 쓰라는 안내가 나온다. 즉 MCP로 강력한 권한을 줬다고 해서 ChatGPT가 무조건 시키는 대로만 하는 건 아니다.

**화면 확인 → 수정 반복하기**

Playwright 같은 브라우저 자동화 도구를 VPS에 설치해달라고 요청하면, ChatGPT가 직접 웹페이지를 열어보고 디자인 문제나 버그를 스스로 찾아 고칠 수 있다. 스크린샷을 찍어 채팅에 첨부하면서 "여기 이 부분이 이상해, 고쳐줘"라고 요청하는 것도 가능하다.

**스케줄 기능으로 자동화하기**

ChatGPT의 스케줄 기능을 이용하면, 예를 들어 "매시간 해커뉴스 인기글을 확인해서 요약하고 블로그에 자동으로 글을 등록해줘" 같은 반복 작업도 만들 수 있다. 이렇게 등록해두면 정해진 주기마다 MCP를 통해 서버에 접속 → 콘텐츠 생성 → 블로그 등록까지 자동으로 처리된다.

## 정리

- ChatGPT + MCP + cokacremote 조합이면, 클라우드 컴퓨터 한 대를 준비하는 것만으로 ChatGPT를 코딩 에이전트처럼 쓸 수 있다.
- cokacremote는 강력한 만큼 샌드박스가 없다는 걸 항상 기억하고, HTTPS와 강한 인증 토큰으로 반드시 보호해야 한다.
- 코드 작성 → 실행 → 결과 확인 → 문제 수정을 ChatGPT 안에서 계속 반복할 수 있다는 게 핵심이다. 단순히 코드를 "받아쓰는" 것과는 경험이 다르다.

VPS 없이 **내 컴퓨터**로 똑같은 걸 해보고 싶다면, [2편](/ai/chatgpt-vibe-coding-cokacremote-docker-tunnel/)에서 Docker와 Cloudflare Tunnel을 이용해 안전하게 구성하는 방법을 다룬다.
