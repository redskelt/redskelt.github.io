---
title: "이번 주 AI 에이전트 트렌드 — 2026-10-19"
date: 2026-10-19 13:50:00 +0900
categories: [Trending]
tags: [AI에이전트, 트렌드, 결정모델]
---

이번 주(10-12~10-18)는 두 흐름이 겹쳤다. 하나는 **Jev 이후 쏟아진 "결정 모델"**이다. Microsoft Decision-1과 OpenAI Decisions API가 잇따라 나오면서, 국내 채널들이 Jev와 비교하는 영상을 냈다. 다른 하나는 **"소프트웨어를 AI로 복제하는" 이야기**다. REA(Reverse Engineer Anything)가 퍼진 뒤 해외 채널들이 그 파장을 다뤘다. 조회수는 10-19 기준이다. 이번 주부터 한국 화이트리스트에 편집자P와 잔재미코딩(DaveLee)을 추가했다.

### 결정 모델 경쟁: Jev 다음은 Decision-1

조회수 1위는 잔재미코딩(DaveLee)의 ["Jev 벌써 끝? MS Decision-1 미쳤다"](https://youtu.be/EtWkF5Ocr8E)(10-12, 2분 13초, 약 7.1만 회)다. 설명란이 흐름을 요약한다. Jev가 나온 지 한 달도 안 돼 Cloudflare Clef, OpenAI Decisions API, Microsoft Decision-1이 차례로 나왔다는 것이다. 설명란에 적힌 비교는 이렇다.

| 비교 | 설명란의 수치 |
|---|---|
| Decision-1 vs OpenAI Decisions API (36개 벤치마크) | 정확도 83.5% vs 79.4%, 속도 3.5배 |
| Decision-1 vs Jev | 정확도 83.5% vs 82.3%로 거의 같음, 속도는 Decision-1이 약 2.8배 |
| 가격 | Jev와 같음. 입력 100만 토큰에 0.042달러, 출력 무료 |

설명란은 "처음 발표한 비교표에는 Jev 정확도가 빠져 있다가 나중에 추가됐다"는 점, 그리고 Microsoft가 내세운 "GPT-6 Sol보다 35배 빠르다"는 비교 대상이 결정 모델이 아닌 글 쓰는 일반 모델이라는 점도 짚는다.

영상 밖에서 확인한 내용이다. [InfoWorld](https://www.infoworld.com/article/4234290/microsoft-separates-decision-making-from-generative-ai-with-a-new-model.html) 보도에 따르면 Decision-1은 10월 초 공개됐고, 자유 형식 글 대신 **정해진 선택지에 확률을 매기는** 모델이다. Microsoft Foundry와 OpenRouter에서 쓸 수 있고, Alibaba의 공개 모델 Qwen3.5-9B를 추가 학습해 만들었다. 다만 36개 벤치마크 결과는 **회사가 발표한 수치**이고 독립 평가는 아직 없다는 점을 같은 보도가 지적한다.

노마드 코더의 ["200배 빠르고 400배 저렴한 AI⚡️직접 써본 결과?"](https://youtu.be/6oZC4Ed2vnY)(10-18, 약 1.8만 회)는 같은 분야를 반대쪽에서 다룬다. 제목만 보면 새 모델 같지만, 실은 Jev 소개 영상이다. 파이썬 코드로 GPT와 Jev를 비교하고, 속도·비용과 활용 사례를 본 뒤, 마지막 챕터에서 "OpenAI Decisions API와의 차이"를 짚는다. 조코딩의 주간 뉴스 ["AI뉴스 - 수학 끝났다, 챗GPT 대화형 UI, Claude Motion, Haiku 5.5…"](https://youtu.be/-gww2TryXkE)(10-12, 약 6.7만 회)에도 "Decision API", "Microsoft Decision-1", "JEV 생존할 수 있을까" 챕터가 연달아 있다. 해외에서는 Latent Space의 ["High Taste Testers"](https://youtu.be/ZOH8Q401vt0)(10-16)가 "Decision models, Jev, and predictive interfaces"라는 11분짜리 챕터를 따로 뒀다.

이 블로그의 [Jev 시리즈]({% post_url 2026/2026-09-22-jev-ai-intro %})를 쓸 때만 해도 Jev는 거의 유일한 결정 모델이었다. 한 달 만에 큰 회사들이 같은 범주에 들어왔고, 비교 기준은 정확도보다 **속도와 가격**으로 옮겨 가는 모양새다.

### 소프트웨어를 AI로 복제한다는 것

해외 조회수 1위는 Wes Roth의 ["AI just BROKE all of the software industry..."](https://youtu.be/EmaXeEdlJkI)(10-15, 약 17만 회)다. 엘든 링에 마리오를, GTA에 마인크래프트를 넣는 게임 개조부터, 소프트웨어 회사가 자기 고객과 경쟁하게 되는 상황까지 다룬다. 설명란의 출처 목록에 Reverse Engineer Anything(REA), 오픈소스 이미지·영상 편집기 PhotoCraft와 FilmCraft, SRE-Bench 논문, Snowboard Kids 디컴파일 프로젝트가 나란히 있다. "Adobe Alternatives", "Training Data" 챕터도 있다.

AI Explained의 ["AI Labs Warn Race Makes Breach 'Inevitable'"](https://youtu.be/C4Sq3Rot8FU)(10-12, 약 15만 회)는 설명란 첫 문장을 "소프트웨어가 리버스 엔지니어링된 주에(In the week that software got reverse engineered)"로 연다. 본론은 연구소들의 경쟁이 사고 위험을 키운다는 경고다. 설명란에 Sam Altman의 Vanity Fair 인터뷰, Dario Amodei의 글, OpenAI의 수학 발표와 이에 대한 AHM(인간 수학자 협회) 성명, Claude Opus 5.5 시스템 카드가 출처로 걸려 있다. 지난주의 수학 논란이 이번 주에도 이어진 셈이다.

가장 구체적인 사례는 Latent Space의 ["How to kill your SaaS: what we learned replacing a $43K/yr tool with AI agents"](https://youtu.be/zlD-CkLVKtU)(10-13, 약 2.4만 회)다. 컨퍼런스 연사 관리 도구에 연 4만 3천 달러 견적을 받고, 코딩 에이전트로 이걸 복제하는 공개 대회를 열었다. 설명란에 따르면 72팀이 제출했다. 다만 다른 요약은 제출 수를 66건으로 적고 있어 숫자는 확인하지 못했다. 영상이 소개하는 교훈이 흥미롭다.

- 우승작이 **자기들이 만든 AI 심사위원 기준으로는 19위**였다. 실제 사용자인 행사 운영팀의 평가와 달랐다.
- 상위권 참가자들이 Claude Code와 Codex에 일을 어떻게 나눴는지
- 거의 모든 복제본이 놓친 세 가지
- 소프트웨어를 "소유하는 일"은 "만드는 일"과 다르다는 결론("own vs rent")

이 블로그의 [REA 실전 가이드]({% post_url 2026/2026-10-19-rea-guide-1-install-setup %})에서 정리한 영상의 결론과 같은 방향이다. 복제 자체보다 **기능을 이해하고, 운영하고, 검증하는 쪽**이 남는 일이라는 것이다.

### 에이전트를 업무에 쓰는 법

국내 채널은 실제 사용법에 무게를 뒀다. 조코딩의 ["AI 리터러시 특강 3강 : 2026, AI 에이전트가 바꾼 우리의 업무"](https://youtu.be/Y3Xz4C3kgBA)(10-15, 약 2만 회)는 챗봇 → 추론 모델 → 에이전트로 이어지는 3단계를 설명한 뒤, 사례 다섯 가지(광고 집행, 블렌더를 열지 않은 3D 모델링, 메일 195통과 계산서 21건 처리, 매출 분석, AI 인플루언서)를 보여 준다. 마지막 챕터 제목은 "사람에게 남는 일 – 지시와 검토"다. 이 강의와 2강은 유료 강의(6시간)의 일부를 공개한 것이다.

새로 화이트리스트에 넣은 두 채널의 영상도 실용적이다. 편집자P의 ["[시즌 4] 편집자P와 똑같은 실습 환경을 세팅하고 싶다면?"](https://youtu.be/PWTlxNAgHOQ)(10-18, 25분)은 "이 방식으로 80% 이상 에이전트를 사용한다"는 본인의 작업 환경을 그대로 보여 준다. 잔재미코딩의 ["EmbeddingGemma 2 설치부터 사용법까지"](https://youtu.be/OtQW4s7DJ1Y)(10-14, 약 1.4만 회)는 구글의 무료 멀티모달 임베딩 모델을 클로드 코드로 설치하고, 영상 150개에서 장면을 찾는 검색 앱을 만든다. Qwen3 임베딩, Jina v5 Omni와 한국어 문서·사진·영상·말소리·코드 검색을 직접 비교하고, 구글 발표 수치와 나란히 정리한 점이 돋보인다.

조코딩의 ["Manus 2.0, 나만의 AI 팀부터 게임, 영상 제작까지 된다고?"](https://youtu.be/qoK6X-l7Tgk)(10-13, 1분 32초)는 설명란에 "Manus의 지원을 받아 제작"이라고 밝힌 협찬 영상이다.

### 로봇 쪽

Latent Space의 ["Robots That Predict the Future: Dyna-2 & Physical AI"](https://youtu.be/BHiYomkfoGQ)(10-13, 1시간 21분)에서는 Dyna Robotics의 Jason Ma가 사람 영상 100만 시간 이상으로 학습한 세계-행동 모델 Dyna-2를 설명한다. 설명란에 따르면 45분 분량의 시연만으로 새 작업을 배우고, 딘타이펑 매장에서 하루 수천 장의 냅킨을 접는 데 실제로 쓰이고 있다.

### Laya가 고른 단독 포스트감 (실험)

[교사 증류로 학습한 Laya 선별기]({% post_url 2026/2026-10-06-laya-teacher-distillation %})가 이번 주 후보 42개 중 꼽은 상위 5개다. 조회수가 아니라 "따라 해볼 만한 내용인가"로 고른 순위다.

1. [조코딩의 AI 리터러시 특강 3강 : 2026, AI 에이전트가 바꾼 우리의 업무](https://youtu.be/Y3Xz4C3kgBA) — 조코딩 JoCoding (10-15)
2. [조코딩의 AI 리터러시 특강 2강 : AI는 모든 형태의 콘텐츠를 다룬다](https://youtu.be/lN1IOA6evoQ) — 조코딩 JoCoding (10-14)
3. [[시즌 4] 편집자P와 똑같은 실습 환경을 세팅하고 싶다면?](https://youtu.be/PWTlxNAgHOQ) — 편집자P (10-18)
4. [EmbeddingGemma 2 설치부터 사용법까지 깔끔 정리](https://youtu.be/OtQW4s7DJ1Y) — 잔재미코딩(DaveLee) (10-14)
5. [매번 가장 효율적인 LLM을 선택하는법](https://youtu.be/6vabSapGFqE) — 코드팩토리 (10-15). 설명란 첫 줄이 ChatLLM by Abacus AI 링크로, 이 서비스를 소개하는 영상이다

상위 2개가 모두 유료 강의의 공개분이고, 5위는 특정 서비스 소개 영상이다. 지난주처럼 광고 규칙에 걸리지 않은 홍보성 영상이 상위권에 섞였다. 반면 이번 주에 직접 따라 해볼 만한 영상을 꼽자면 3위와 4위가 가장 가깝다. 실제 설치와 사용 과정을 처음부터 보여 주기 때문이다.
