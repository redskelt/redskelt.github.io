---
title: "이번 주 AI 에이전트 트렌드 — 2026-11-16"
date: 2026-11-16 11:05:00 +0900
categories: [Trending]
tags: [AI에이전트, 트렌드, 페이블5.2, 제미나이4카본]
---

이번 주(11-09~11-15)는 **새 모델 두 개가 연달아 나온 주**였다. 11-10에 Anthropic이 Claude Fable 5.2와 Mythos 5.2를 공개했고, 11-11에는 Google이 Gemini 4 Carbon 정식 출시를 알렸다. 해외 상위 3개와 국내 상위 5개 중 3개가 이 두 모델을 다룬 영상이다. 한편 국내에서는 아이폰을 Claude Code로 조작하는 오픈소스(phone-harness)와, 지난주에 이어 깃허브 트렌딩 정리 영상도 올라왔다. 조회수는 11-16 오전 기준이고, 날짜는 수집 목록(UTC) 기준이라 유튜브 페이지 표기와 하루 차이 나는 영상이 있다. 영상 소개는 모두 설명란과 챕터(목차)를 열어 확인한 내용만 적었고, 영상 안의 주장이 사실인지까지는 검증하지 않았다. 지난주 글은 [여기]({% post_url 2026/2026-11-09-trending-weekly-1109 %})다.

### 해외: Fable 5.2와 Gemini 4

- [NOTHING will be smarter than Fable 5.2...](https://youtu.be/h76wUNmRqxc)(Wes Roth, 11-10, 약 21.9만 회): 해외 1위다. 설명란이 Anthropic 공개 글, 264쪽 시스템 카드, METR의 Anthropic AI R&D 가속 평가 글을 출처로 건다. 설명란 요약에 따르면 Anthropic이 가속기 커널 최적화와 LLM 구조 연구 능력을 학습 중에 Opus 5.5 수준으로 일부러 제한했다고 밝혔다는 내용이 영상의 핵심 주제다. 챕터는 "METR Report"(02:51), "Training Limits"(05:47), "Secret Scaffold"(08:37), "Game Benchmark"(15:25), "Usage Limits"(17:12) 등이다. 출처 원문은 이 글에서 직접 열어 확인하지 못했다.
- [Fable 5.2: The Self-Improvement Loop Keeps Loopin’ … (plus Gemini Carbon)](https://youtu.be/583ThJIqQ7k)(AI Explained, 11-10, 약 21.4만 회): 챕터가 "how good are Fable 5.2 and Carbon?"(0:49), "smarter, but still missing some common sense"(9:01), "how fast is AI improving itself?"(15:49), "small gains, big consequences"(23:51), "it knows when you're watching"(26:33)이다. 설명란에 Anthropic 공개 글, 시스템 카드, METR 글, Epoch AI·SemiAnalysis의 X 글이 달려 있다. 설명란 상단에 AssemblyAI 링크와 유료 후원(Patreon) 링크가 있다.
- [Gemini 4 Swarm is out of control...](https://youtu.be/Sc6TriRAGnI)(Wes Roth, 11-13, 약 16.7만 회): 설명란이 Google의 Gemini 4 Carbon, Gemini 4 Hydrogen, Gemini Decision-1, AlphaProof Code, Antigravity /swarm 발표를 한꺼번에 다뤘다고 소개하고, Gemini 4 Carbon이 이 30분짜리 영상을 직접 편집했다고 적는다. 챕터에 "AI Edited This Video"(05:08), "Factorio AI Speedrun"(08:05), "Antigravity Swarm Verdict"(27:11)가 있다.
- [What Frontier Labs Buy: A Data Deep Dive with Handshake AI — Garrett Lord & Team](https://youtu.be/v5IJwVnTxzg)(Latent Space, 11-09, 약 5.1만 회): 프런티어 연구소가 사는 학습 데이터를 다룬 인터뷰다. 설명란에 따르면 Handshake AI가 출시 약 1년 만에 연환산 매출 총액 약 10억 달러에 이르렀다고 한다. 챕터에 "How to build a banking environment for an agent"(5:15), "How frontier labs buy data"(13:07), "How a lab evaluates a new dataset"(15:51)가 있다. 협찬이라는 표기는 따로 없다.
- [Designing for Agents — Zeno Rocha, Resend](https://youtu.be/bdIoODXsu8k)(Latent Space, 11-10, 약 4천 회): 설명란이 Claude Code가 어떤 이메일 서비스를 추천하는지 모델 버전별로 살펴보고, 에이전트에게 이름 붙은 MCP 도구 80개 이상을 주는 설계까지 다룬다고 소개한다. 챕터에 "When agents pick the API"(05:02), "Designing the MCP"(37:54), "Mail for agents"(52:40), "Winning recommendations"(1:05:59)가 있다. 조회수는 상위 5개 중 가장 낮다.

해외 상위 5개 중 세 편이 11-10 전후의 모델 발표를 다뤘다. 지난주가 METR 평가와 모델 안전 논의였다면, 이번 주는 그 논의의 대상인 모델이 실제로 공개된 주다. Wes Roth의 두 영상이 모두 Fable 5.2와 Gemini 4를 각각 하나씩 맡았다.

### 국내: 모델 공개 정리와 phone-harness

- [클로드 미친 신모델.. 오퍼스 5.5 넘어선 페이블 5.2.. ㄷㄷ](https://youtu.be/jrlm0fGHEug)(성공지식백과, 11-10, 약 15.8만 회): 국내 1위다. 설명란이 Anthropic 공식 발표와 모델 문서(가격 포함)를 출처로 건다. 설명란에 적힌 표준 API 가격은 백만 토큰당 입력 8달러, 출력 40달러이고, 페이블 5.1보다 20% 낮아졌다고 한다. 설명란은 벤치마크가 Anthropic이 공개한 평가이고 모든 항목에서 페이블이 가장 높은 것은 아니라고 따로 밝힌다. 챕터는 "오퍼스 5.5와 코딩 성능 비교"(00:47), "페이블과 미토스의 차이"(05:38), "API 가격과 오퍼스 대비 비용"(06:17), "Astra와 원소 3D 결과물 비교"(07:52) 등이다. 협찬 표기는 없다.
- [앤트로픽·메타·YC 대표가 전부 풀었다..오늘 깃허브에 풀어 버린 오픈소스 TOP 11 (11.10 트렌딩)](https://youtu.be/QMDi_8YV_Hs)(민둥이 \| 쉽게 배우는 AI, 11-10, 약 9.9만 회): 설명란 목차 기준으로 1위 anthropics/skills, 2위 meta/astryx, 4위 MuJoCo, 7위 agent-browser, 10위 ha-mcp 등 11개 저장소를 1위부터 소개한다. 이 영상은 이 블로그에서 [따로 정리]({% post_url 2026/2026-11-11-github-trending-top11-1110 %})했다.
- [해외에서 난리난 phone-harness 직접 사용해봤습니다](https://youtu.be/-7akHqSkpzE)(개발동생, 11-09, 약 5.9만 회): Claude Code가 아이폰 미러링 화면을 글자(OCR)로 읽고 탭과 스와이프로 폰을 대신 쓰는 오픈소스를 직접 연결해 본 영상이다. 설명란에 같은 배달 심부름을 Haiku, Sonnet, Opus로 돌린 시간(Sonnet 3분 46초, Opus 4분 18초, Haiku 7분 48초)이 적혀 있고, AI가 보는 것이 화면이 아니라 글자 목록이라 한글 오독과 글자 없는 버튼 문제가 있다고 한계도 밝힌다. 설치 후 사용 통계를 끄는 명령이 설명란에 있다. "이 영상은 협찬이 아닙니다"라는 문구가 있고, 영상 중 한 발언을 바로잡는 정정 항목도 달려 있다.
- [AI뉴스 - METR 리포트, 죽음은 선택사항, GPT Images 2.6, 젠슨황 불륜, 신경망 가중치 업데이트, GPT 6.2 Astra, Fable 5.5 곧 출시 등](https://youtu.be/Ni0gE4LeSlc)(조코딩 JoCoding, 11-09, 약 5.7만 회): 주간 AI 뉴스 모음이다. 챕터가 약 40개이고, 이 중 "METR 리포트, AI 자기개선 가속"(00:00), "폰 하네스 MCP"(15:25), "Siri AI 개발자 공개"(14:14)처럼 이번 주 다른 영상과 겹치는 항목이 있다. 설명란에 본인 강의·컨설팅 링크가 있고, 출처로 X 글과 검색 링크를 길게 걸었다.
- [드디어 풀렸습니다.. 구글 최강 모델 제미나이 4 카본 정식 출시.. ㄷㄷ](https://youtu.be/v65FQ_za4fM)(성공지식백과, 11-11, 약 4.8만 회): 설명란이 구글코리아 블로그, 구글 공식 블로그, 모델 카드를 출처로 건다. 설명란에 따르면 종합 지능 지수(AA Index)가 Argon 50점에서 Carbon 59점으로 올랐고 터미널 벤치 4.0은 65.2%다. 같은 설명란이 이 벤치마크는 구글이 공개한 평가이고 구글 비교표에 Fable 5.2가 들어 있지 않다고 밝힌다. 챕터에 "안티그래비티 스웜 기능"(01:47), "페이블과 픽셀아트 비교, 18달러 대 6.2달러"(04:18)가 있고, 이 비용 비교는 X 사용자가 공개한 수치라고 적혀 있다. 제미나이 웹과 안티그래비티는 Google AI Ultra 구독자에게 제공된다고 안내한다.

국내 상위 5개 중 두 편이 성공지식백과의 모델 정리 영상이다. 같은 모델 발표를 두고 해외 영상은 METR 평가와 자기개선 쪽으로, 국내 영상은 가격과 결과물 비교 쪽으로 풀어 간 점이 다르다. 모델 발표 사이에서 phone-harness 영상은 도구 하나를 직접 써 본 실측과 한계를 함께 보여 줘서 눈에 띈다.

### Laya가 고른 단독 포스트감 (실험)

[교사 증류로 학습한 Laya 선별기]({% post_url 2026/2026-10-06-laya-teacher-distillation %})가 이번 주 후보 64개 중 꼽은 상위 5개다. 조회수가 아니라 "따라 해볼 만한 내용인가"로 고른 순위다.

1. [AI 요금 폭탄? 코드 3줄로 막는다고? 심지어 무료 👀](https://youtu.be/f1quywzT-a8) — 노마드 코더 Nomad Coders (11-15, 약 8.8천 회). Cloudflare AI Gateway에 코드 3줄로 연결하는 영상이다. 챕터에 "비용 제한, 캐싱, Rate Limiting"(01:40), "스마트 Routing & Auto Router"(02:45), "AI 보안 강화 Guardrails"(04:09)가 있다. 설명란에 자사 강의 두 개의 링크가 걸려 있다
2. [깃허브 트렌드 1위, 해외에서 난리 난 Craft Anything 직접 써보니 놀라운 결과 \| 뭐든지 복제하는 AI 사용법 완벽 정리 #REA #Craft Anything](https://youtu.be/EJGfWxTT__E) — 문외인 Layperson (11-09, 약 6만 회). 주소 하나를 넣으면 원본과 비교하며 화면을 다시 만들어 주는 도구 Craft Anything를 소개한다. 설명란에 깃허브 저장소와 최신 릴리스 링크가 있고, 원본과 닮은 정도가 90%에 닿을 때까지 최대 6번 스스로 고친다는 설명이 있다. 챕터에 "설치와 쓰는 화면부터 원본 비교해 스스로 고치기"(01:19), "클린룸 방식이 기본인 이유와 분석 도구 확인하기"(02:43)가 있다. 설명란에 오픈카톡방 링크가 있다
3. [AI생성 영상으로 구독자 모아보기](https://youtu.be/eTM3zIVFkp4) — 코드깎는노인 (11-12, 약 2.5천 회). Higgsfield에서 GPT Image로 진행자 캐릭터를 만들고 Seedance로 움직이는 과정을 보여 준다. 챕터에 "캐릭터 시트는 어떻게 캐릭터를 늘 같은 모습으로 지켜 줄까?"(3:04)가 있고 사용한 프롬프트도 설명란에 있다. 설명란 첫 줄이 Higgsfield 가입 할인 링크다
4. [[시즌 4] 스레드 자동화를 가장 쉽게 하는 비밀, -p](https://youtu.be/JBtOUPvLY1k) — 편집자P (11-15, 약 1.9천 회). Claude Code의 `-p`(헤드리스) 실행 모드로 구독 안에서 프리셋 프롬프트를 넘겨 자동화하는 방법을 스레드 자동화 예시로 다룬다. 챕터는 없고, 설명란에 Typeless 링크가 있으며 "(저에게 도움이 됩니다)"라고 적혀 있다
5. [화제의 REA VIDEO 직접 써 봤습니다 \| 클로드로 Higgsfield 괴담 채널 자동화까지 with ego lite](https://youtu.be/g2EWLpclbiw) — 민둥이 \| 쉽게 배우는 AI (11-15, 약 8.4천 회). ego lite 브라우저로 Claude가 Higgsfield 웹사이트를 조종해 괴담 쇼츠와 음료 광고를 만드는 과정이다. 설명란 마지막에 "이 영상은 Higgsfield의 지원을 받아 제작되었습니다"라는 문구가 있다

이번 주 5개 중 3위와 5위는 영상 생성 도구(Higgsfield)를 쓰고, 2위는 기존 화면을 복제해 다시 만드는 도구이며, 1위와 4위는 API 비용과 `-p` 모드처럼 에이전트를 실제로 굴릴 때의 운영 쪽이다. 협찬이 명시된 것은 5위뿐이고, 3위와 4위는 가입 링크나 제휴로 보이는 링크가 있을 뿐 협찬이라는 표기는 없다. 직접 따라 해볼 만한 영상을 꼽자면, 이 블로그의 [REA 가이드]({% post_url 2026/2026-10-19-rea-guide-1-install-setup %})와 이어서 볼 수 있는 2위가 가장 가깝고, 비용을 먼저 걱정하는 사람에게는 챕터가 5개로 짧게 나뉜 1위가 부담이 적다.
