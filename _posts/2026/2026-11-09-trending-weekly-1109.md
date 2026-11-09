---
title: "이번 주 AI 에이전트 트렌드 — 2026-11-09"
date: 2026-11-09 13:45:00 +0900
categories: [Trending]
tags: [AI에이전트, 트렌드, 클로드코드, 에이전트도구]
---

이번 주(11-02~11-08)는 두 흐름이 보였다. 해외에서는 **Anthropic의 AI 연구 자동화를 평가한 METR 글**을 다룬 영상이 두 편(Wes Roth, Matthew Berman) 상위에 올랐다. 국내에서는 **Claude Code 기본기와 신기능을 정리한 영상**이 연달아 나왔고, 여러 에이전트를 한 화면에서 굴리는 도구(Orca) 영상도 눈에 띄었다. 조회수는 11-09 13시 기준이고, 날짜는 수집 목록 기준이라 유튜브 페이지 표기와 하루 차이 나는 영상이 있다. 영상 소개는 모두 설명란과 챕터(목차)를 열어 확인한 내용만 적었고, 영상 안의 주장이 사실인지까지는 검증하지 않았다. 지난주 글은 [여기]({% post_url 2026/2026-10-26-trending-weekly-1026 %})다.

### 해외: Anthropic 평가와 모델 안전 이야기

- [Anthropic just built it...](https://youtu.be/2lt4P_xGFL8)(Wes Roth, 11-06, 약 18.4만 회): 해외 1위다. 설명란이 METR의 11-05 글 두 편(Anthropic AI R&D 가속화 평가, 2026년 8월 위험 보고서 R&D 부문 검토)과 Anthropic Institute 글 두 편을 출처로 건다. 챕터는 "Redacted Audit"(0:00)로 시작해 "Model 4"(6:53), "2x Safety Line"(9:12), "AECI Benchmarks"(15:12), "Trend Inflection"(23:47), "Researcher Interviews"(28:58), "Compute Allocation"(32:42), "30,000 AI Agents"(36:43)로 이어진다. 출처 원문은 이 글에서 직접 열어 확인하지 못했다.
- [12 months to the singularity](https://youtu.be/lVbQqjAJpkE)(Matthew Berman, 11-07, 약 13.1만 회): 같은 METR 글을 출처로 건 영상이다. 설명란 첫 줄이 IntelliJ IDEA 링크이고 챕터는 없다. 협찬이라는 표기는 따로 없다.
- [‘We may release models we can’t control’: Amodei, Altman … and Gemini Carbon](https://youtu.be/0Kw6_DTZPrY)(AI Explained, 11-02, 약 14만 회): 챕터가 "Anthropic Staff Survey"(1:26), "Amodei's Five Rationalisations"(4:32), "Altman: Only Alignment Will Work"(11:43), "Gemini 4 Carbon and Why Models Keep Impressing"(18:41)이다. 설명란에 Anthropic, OpenAI, Google 공식 글과 여러 사람의 X 글을 길게 걸어 두었다. 설명란에 유료 구독 서비스(AI Insiders) 링크가 있다.
- [this might be HUGE...](https://youtu.be/DJjK6LAIouM)(Wes Roth, 11-05, 약 10.1만 회): 챕터는 "AI Brain Surgery"(0:00), "Fang League"(4:35), "OpenAI’s Model Sabotage"(10:05), "Weight-Space Programming"(19:40)이다. 출처로 OpenAI의 은밀한 성능 저하(covert underperformance) 보고서, MIT CSAIL의 weight-space programming 실험 글 등을 걸었다. 설명란 첫 줄이 Grok Bot 소개 링크이고 해시태그에 `#spacexaipartner`가 붙어 있어 협찬 영상으로 보이지만, 협찬이라는 표기는 따로 없다.
- [Does AI Deserve Rights? Only If It Can Suffer](https://youtu.be/c4OK-RjCk_U)(David Shapiro, 11-07, 약 2만 회): 챕터가 없고, 설명란에는 본인 책(Labor Zero)의 아마존 예약 판매 안내와 링크만 있다.

이번 주 해외 상위 5개 중 두 편이 같은 METR 글을 출처로 걸었다. 지난주에는 에이전트가 실제 공격에 쓰였다는 사건이 중심이었다면, 이번 주는 연구소 내부 평가와 안전 논의 쪽이다.

### 국내: Claude Code와 에이전트 도구

- [오늘 깃허브 트렌딩 TOP 9 총정리 (11월 3일)](https://youtu.be/HVe256dh9Ls)(민둥이 \| 쉽게 배우는 AI, 11-03, 약 4.9만 회): 국내 1위다. 설명란 목차 기준으로 1위 agent-desktop(vercel-labs, "AI가 내 앱을 직접 누른다"), 3위 Scrapling(알아서 다시 찾는 크롤러), 12위 Worktrunk(코딩 AI 여러 개 동시에)를 포함해 9개 저장소를 15위부터 1위까지 소개한다. 저장소 링크가 설명란에 모두 달려 있다. 같은 채널의 지난 깃허브 트렌딩 영상은 [이 블로그에서 정리]({% post_url 2026/2026-10-29-github-trending-top10-mindung-1028 %})한 적이 있다.
- [피클 핵심 가이드: 쿠팡, KTX, 정부24까지 맡기는 AI 에이전트](https://youtu.be/Gbj_dWfvprM)(Jay Choi \| 인디해커 라이프, 11-05, 약 3만 회): 한국 팀이 만든 AI 에이전트 피클([pickle.com/ko](https://pickle.com/ko))을 소개한다. 챕터가 쇼핑·식사, 교통·영화, 행정, 전화, 예약 실행, 피클끼리 대화 순이고 마지막 챕터(7:02)가 "주의사항"이다. 협찬 표기는 설명란에 없다.
- [ego lite 드디어 윈도즈 버전 출시!](https://youtu.be/TxnVTk72a3E)(코드팩토리, 11-02, 약 2.9만 회): 설명란은 ego lite 링크(link.ego.app/codefactory2)와 자사 강의·오픈톡방 링크 위주이고 챕터가 없다. ego lite는 이 블로그에서 [직접 써 본 적]({% post_url 2026/2026-09-16-ego-browser-review %})이 있는 도구다.
- [Orca로 LLM 오케스트레이션 액기스 모음](https://youtu.be/d893Vei2Ll4)(코드팩토리, 11-05, 약 2.4만 회): 설명란 타임스탬프가 "Orca와 Herdr 사용 경험 비교"(00:00)로 시작해 Orca 설치(01:10), "Claude 5개 실행하고 프롬프트 보내기"(04:45), SSH로 다른 컴퓨터 연결(14:55), Tailscale(15:43), 모바일 앱 연결(16:08), 반복 지시를 스킬로 정리(17:09)까지 이어진다. 이 블로그의 [Orca 리뷰]({% post_url 2026/2026-09-17-orca-ide-review %})와 [Herdr 가이드]({% post_url 2026/2026-09-18-herdr-guide %})와 겹치는 주제다.
- [최신 클로드코드 신기능 정리, 이 6가지만 알면 됩니다](https://youtu.be/F15aMeaHOII)(잔재미코딩(DaveLee), 11-05, 약 2만 회): 챕터가 Mods(00:33), MCP Tasks(01:36), 엘리시테이션(02:48), ultrathink(03:30), advisor(04:26), 서브에이전트 effort(05:30), 에이전트 뷰(06:09), 쉬는 동안 자동 정리(07:21), /usage(07:58)다. 설명란에 Claude Code 공식 문서 링크가 기능별로 달려 있다. 문서 내용까지는 이 글에서 확인하지 않았다. 설명란에 본인 강의 사이트 링크가 있다.

### Laya가 고른 단독 포스트감 (실험)

[교사 증류로 학습한 Laya 선별기]({% post_url 2026/2026-10-06-laya-teacher-distillation %})가 이번 주 후보 47개 중 꼽은 상위 5개다. 조회수가 아니라 "따라 해볼 만한 내용인가"로 고른 순위다.

1. [클로드코드로 AI 인플루언서 만드는 방법 깔끔 정리](https://youtu.be/cc4b0HL_vuo) — 잔재미코딩(DaveLee) (11-08). 설명란이 Higgsfield 가입 링크로 시작하는 서비스 소개 영상이다. 챕터에 Higgsfield MCP 연결(01:51)과 크레딧 비용(05:29)이 있다
2. [2,900만 조회수 애니 쇼츠, 이제 무료 AI로 딸깍 한 번에 만듭니다](https://youtu.be/vHEZkJidjLc) — 민둥이 \| 쉽게 배우는 AI (11-03). 스킬 저장소 링크 두 개를 AI에게 주고 설치시키는 방식이고, 준비물로 ElevenLabs API 키가 필요하다고 안내한다
3. [클로드 코드 공식 교과서, 앤트로픽이 직접 공개한 기본기 12가지](https://youtu.be/2g6j_JX-n_o) — 민둥이 \| 쉽게 배우는 AI (11-08). 설명란이 Claude Code 공식 문서를 바탕으로 했다고 밝히고, 12가지 기본기를 챕터(00:34~08:07)로 나눈다
4. [[시즌 4] 무료로 배우는 AI 영상 생성 프로그램](https://youtu.be/qc2Lqn0HBSI) — 편집자P (11-05). 설명란에 Typeless 링크가 있고 "(저에게 도움이 됩니다)"라고 적혀 있다
5. [Figma Agent로 완벽한 디자인 만들기](https://youtu.be/9t4yOJ7yfF0) — 코드팩토리 (11-06). 설명란에 Figma 링크가 있고 챕터는 없다

이번 주도 상위 5개 중 1위, 4위, 5위의 설명란에 특정 서비스 링크가 걸려 있다. 협찬이라는 표기가 있는 것은 아니니 어디까지나 링크가 있다는 사실만 적는다. 직접 따라 해볼 만한 영상을 꼽자면, 공식 문서 기반으로 기본기를 챕터별로 나눈 3위가 가장 가깝다. 3위는 이번 주 국내 목록에 오른 DaveLee의 신기능 영상과 함께 보면 기본기와 새 기능을 한 번에 훑을 수 있다.
