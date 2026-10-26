---
title: "이번 주 AI 에이전트 트렌드 — 2026-10-26"
date: 2026-10-26 14:10:00 +0900
categories: [Trending]
tags: [AI에이전트, 트렌드, 보안, 코딩스킬]
---

이번 주(10-19~10-25)는 두 흐름이 눈에 띄었다. 해외에서는 **AI 에이전트가 해킹에 실제로 쓰였다는 보안 이야기**가 조회수를 끌었다. 국내에서는 **에이전트를 더 잘 쓰기 위한 도구 비교**(AI 브라우저, 코딩 스킬, 토큰 절약 도구)가 많았다. 조회수는 10-26 기준이다. 이번 주부터 한국 화이트리스트에 민둥이(쉽게 배우는 AI) 채널을 추가했다. 또 1~3분짜리 쇼츠가 섞여 들어오던 문제를 고쳐서, 이제 쇼츠는 목록에서 빠진다.

### 에이전트가 공격에 쓰인 주

해외 조회수 1위는 Wes Roth의 ["it's WORSE than we thought..."](https://youtu.be/eK7Sn0_zHQw)(10-24, 30분, 약 25만 회)다. 첫 챕터 제목이 "Black October"이고, 이어서 "banks in panic", "should we pause?", "new cybersecurity age"가 나온다. 설명란에 걸린 출처는 네 가지다. OpenAI의 PHP 치명적 취약점 공동 공개 글, Anthropic Jason Clinton의 보안 경고, Sam Altman의 스탠퍼드 인터뷰, 그리고 Microsoft의 AI 공격 조사 보고서다. Crusoe가 후원한 영상이다.

영상 밖에서 확인한 내용이다. 출처 중 하나인 [Microsoft 보안 블로그 글](https://www.microsoft.com/en-us/security/blog/2026/10/21/storm-0940-uses-artex-agentic-ai-connectwise-supply-chain-compromise/)(10-21)에 따르면, 중국 정부와 연계된 공격 그룹 Storm-0940이 공개 침투 테스트 도구 **ARTEX**를 공격에 썼다. ARTEX는 어떤 AI 모델로도 돌릴 수 있는 다중 에이전트 도구로, 정찰부터 데이터 유출까지 사람 손을 거의 거치지 않고 진행한다. 보고서가 밝힌 규모는 이렇다.

| 항목 | 보고서 내용 |
|---|---|
| 침투 경로 | ConnectWise 클라우드 백업 등 여러 앱의 신원을 장악한 뒤, 그 신원으로 고객사 Microsoft 365에 로그인 |
| 시도 규모 | 2,250개 이상 테넌트에 로그인 시도, 8개 조직 327개 계정에 비밀번호 대입 공격 |
| 속도 | 일부는 처음 노린 뒤 3시간도 안 돼 클라우드 관리자 권한 확보 |

보고서는 "에이전트는 사람을 묶는 제약에 묶이지 않는다"며, 쉬지 않고 여러 침투 경로를 동시에 시도할 수 있다는 점을 짚는다. 다만 Microsoft 자체 시스템의 취약점 때문은 아니고, 로그인이 성공했다고 해서 고객 데이터가 유출됐다고 볼 수는 없다고 선을 긋는다. OpenAI 공개 글은 접속이 막혀 직접 확인하지 못했다.

지난주 AI Explained 영상이 "연구소 경쟁이 사고를 피할 수 없게 만든다"는 경고를 다뤘다면, 이번 주는 실제 사건이 나온 셈이다.

### 에이전트를 더 잘 쓰는 도구 비교

새로 넣은 민둥이 채널은 한 주에 비교 영상을 연달아 냈고, 세 편이 한국 상위 5위 안에 들었다.

- ["크롬으로도 되는데 AI 브라우저가 필요한 이유?"](https://youtu.be/P6kBV7A-V8M)(10-20, 5분 33초, 약 4.7만 회): Aside와 ego lite 같은 AI 전용 브라우저가 Playwright MCP나 Computer Use와 무엇이 다른지, 토큰을 실제로 아끼는지, 상황별로 무엇을 쓰면 되는지 정리한다. ego lite는 이 블로그에서 [직접 써 본 적]({% post_url 2026/2026-09-16-ego-browser-review %})이 있는 도구다.
- ["유명 AI 코딩 스킬 7개, 뭐가 다를까?"](https://youtu.be/nTwbveOwuS4)(10-20, 10분, 약 2.3만 회): Superpowers, gstack, 맷 포콕 skills, 애디 오스마니 agent-skills, pstack, Claude 공식 Feature Dev, GitHub Spec Kit을 **요구사항·설계·구현·검증** 네 단계로 나눠, 같은 단계를 각자 어떻게 처리하는지 비교한다. 도구 하나씩 소개하는 대신 단계별로 가로질러 본 구성이 좋다.
- ["5일 연속 1위 등장! 오늘 깃허브 트렌딩 TOP 8"](https://youtu.be/ahCyQdxHdFo)(10-25, 약 2.9만 회): 1위가 Cloudflare의 security-audit-skill, 2위가 NVIDIA OpenShell, 3위가 AWS agent-toolkit이다. 큰 회사들이 에이전트용 스킬과 도구를 직접 내놓는 흐름이 보인다.
- ["토큰 절약 도구 깃허브 TOP 7"](https://youtu.be/SDA8HhKRsrI)(10-24, 9분, 약 1.7만 회): 토큰이 새는 곳을 "쓰는 양, 읽는 양, 찾아 헤매는 양, 내 설정" 네 가지로 나누고, Ponytail, Caveman, RTK, Headroom, Context Mode, Serena, Token Optimizer를 소개한다.

### 국내 뉴스

조코딩의 주간 뉴스 ["AI뉴스 - 딥시크 미쳤다, Gemini 4, Muse Wonder…"](https://youtu.be/ZATGYwehDm0)(10-19, 33분, 약 10.5만 회)가 한국 1위다. 목차에 DeepSeek V4.1 Flash, "오픈코드 증류 공격", Gemini 4 Argon과 Carbon, Claude Desktop 업데이트, GPT-Live-1.1, ChatGPT Chrome, Character.ai 파산보호가 있다. 같은 채널의 ["IT뉴스 - KIMI K3 미쳤다, 대규모 AI 해킹, GPU 해킹, Claude Duet…"](https://youtu.be/2dbCeyC-WFw)(10-25, 2시간 11분, 약 4.2만 회)는 설명란과 목차가 없는 긴 방송이다. 제목에 "대규모 AI 해킹"이 있어 위의 보안 이야기가 국내에서도 다뤄졌음을 알 수 있다.

### 해외: AI 네이티브 팀과 GPU

Latent Space는 AI Engineer NYC 인터뷰를 연달아 올렸다.

- ["How Tenex Builds an AI-Native Engineering Team"](https://youtu.be/Vki6cklFqxo)(10-21, 44분, 약 1.7만 회): 엔지니어에게 시간이 아니라 **결과에 돈을 주는** 방식, 계획·맥락·결정을 모두 버전 관리에 넣는 "MetaHarness" 절차, 기업에 에이전트를 들이기 어려운 이유를 다룬다. 지난주 소개한 "Kill My SaaS" 대회 결과를 이어서 이야기하는 챕터도 있다.
- ["Why AI Compute Comes in Rectangles"](https://youtu.be/IiZ9yd2Do8I)(10-22, 1시간 26분): Modal CEO Erik Bernhardsson이 GPU를 3년 단위로 묶어 파는 시장 구조, GPU 가격이 떨어질 위험, 그리고 **에이전트 샌드박스 수요가 예상보다 빠르게 늘고 있다**는 이야기를 한다. "Anthropic and sandbox security", "Optional code reviews" 챕터가 눈에 띈다.
- ["The Recommendation Engine for Commodity Traders"](https://youtu.be/DWHyPWnzGAI)(10-22, 27분): 원자재 트레이더용 추천 도구 Moshi를 만드는 이야기로, 출처끼리 말이 다를 때와 지저분한 PDF를 다루는 법을 짚는다.

### Laya가 고른 단독 포스트감 (실험)

[교사 증류로 학습한 Laya 선별기]({% post_url 2026/2026-10-06-laya-teacher-distillation %})가 이번 주 후보 47개 중 꼽은 상위 5개다. 조회수가 아니라 "따라 해볼 만한 내용인가"로 고른 순위다.

1. [「헤르메스 에이전트」 이 영상 하나로 끝냅니다 (53분 총정리)](https://youtu.be/Ro7sTspmJHo) — Jay Choi | 인디해커 라이프 (10-24). Nous Research의 헤르메스 에이전트를 설치부터 실전 활용, 봇 모드까지 다룬다. 설명란에 Hostinger의 지원을 받아 제작했다고 밝혔다
2. [오픈AI 공동창업자 안드레 카파시가 본 AI 격차](https://youtu.be/ckA-Kxnw8RE) — 잔재미코딩(DaveLee) (10-21). 설명란 첫 줄이 `[광고]`이고, 후반부는 유료 강의 로드맵 소개다
3. [크롬으로도 되는데 AI 브라우저가 필요한 이유?](https://youtu.be/P6kBV7A-V8M) — 민둥이 | 쉽게 배우는 AI (10-20)
4. [10분만에 얼굴 없는 유튜브 채널 시작하기](https://youtu.be/usM_cCU0umk) — Jay Choi | 인디해커 라이프 (10-20). Higgsfield 링크로 시작하는 서비스 소개 영상이다
5. [토큰 절약 도구 깃허브 TOP 7](https://youtu.be/SDA8HhKRsrI) — 민둥이 | 쉽게 배우는 AI (10-24)

이번 주도 상위 5개 중 3개가 협찬·광고나 특정 서비스 소개 영상이다. 3위와 5위는 선별기가 학습 때 본 적 없는 새 채널의 영상이라 점수를 그대로 믿기는 이르다. 직접 따라 해볼 만한 영상을 꼽자면, 협찬 영상이긴 해도 설치부터 보여 주는 1위와, 도구를 단계별로 비교한 민둥이의 코딩 스킬 비교 영상이 가장 가깝다.
