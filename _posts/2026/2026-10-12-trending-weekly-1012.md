---
title: "이번 주 AI 에이전트 트렌드 — 2026-10-12"
date: 2026-10-12 12:00:00 +0900
categories: [Trending]
tags: [AI에이전트, 트렌드, ClaudeCode]
---

이번 주(10-06~10-12)는 **Claude Code Mods**가 유튜브를 채운 주간이었다. 10월 초부터 해외 채널이 앞다퉈 소개했고(공식 소개 영상은 10-05), 국내 채널이 이번 주에 사용법과 주의점을 정리했다. 같은 시기 OpenAI가 수학 결과를 대량 공개하며 일으킨 논란도 mods와 비슷한 규모(약 57만 회)로 퍼졌다. 조회수는 10-12 기준이다.

### Claude Code Mods, 한 주 내내 같은 주제

Anthropic 공식 채널의 ["Mods in Claude Code: change how Claude Code works"](https://youtu.be/yUuFvL1lK4k)(10-05, 약 39만 회)가 출발점이다. 공식 문서는 mod를 "이벤트 핸들러로 이루어진 플러그인"으로 설명한다. 도구 호출이나 프롬프트 같은 이벤트에 끼어들 수 있고, 프롬프트 위 띠나 옆 패널 같은 화면도 직접 그린다. 터미널은 Claude Code 2.1.287 이상(데스크톱 앱은 2.1.286 이상)에서 기본으로 켜진다.

이 소식을 가장 크게 퍼뜨린 건 RoboNuggets의 ["9 NEW Claude Mods that can truly change how you work"](https://youtu.be/lDrAZ1wAyVs)(10-08, 약 57만 회)다. 설명란에 Savvy Progress, Claude Skins, Filetree, Cache Tax, Reflect, Terminal Browser 같은 커뮤니티 mod의 저장소가 나열돼 있고, Anthropic의 샘플인 Blast Radius와 Replay Theater도 들어 있다. Nate Herk의 ["Claude Code Mods Are Game Changers. Set Up These 5 NOW."](https://youtu.be/9hetShMMp2s)(10-02, 약 23만 회)는 Next Steps, Cache Keeper, Recording Mode, Goal Meter, Collision Guard 5개를 챕터로 짚는다. Chase AI는 ["Claude Mods Is The Biggest Claude Code Upgrade Since Skills"](https://youtu.be/Rn4nmFRPe0s)(10-02, 약 21만 회)라는 제목으로 스킬 이후 가장 큰 업그레이드라고 평가한다. Tristen O'Brien의 ["Claude Code Just Dropped MODS. (Master it in 10 Minutes)."](https://youtu.be/LDn7rQKIFro)(10-05, 약 21만 회)는 Clean View, Agent Dock 같은 mod 5개를 10분에 훑는다.

기술 쪽 배경은 Latent Space의 ["Claude Code's Bitter Lesson: Prompts, Harnesses, Mods, and Agents"](https://youtu.be/IZAlq-V19U8)(09-29, 약 13만 회)다. 설명란에 "Anthropic's Thariq Shihipar"가 나와 파워 유저의 Claude Code 사용법과 하네스가 어디로 가는지를 이야기한다고 적혀 있다. 제목에 Mods가 들어간 이 영상은 10월 초 소개 영상들보다 앞선 9월 말에 올라왔다.

### 국내: "모드가 뭔지, 뭘 조심해야 하는지"

국내 채널은 사용법과 주의점에 무게를 뒀다. 성공지식백과의 ["클로드코드 \"모드\"는 혁신입니다.. ㄷㄷ 미친 신기능 /mods"](https://youtu.be/KtquxqP2YnM)(10-03, 약 9.3만 회)는 Token Weather, Blast Radius, Replay Theater, Cache Watch를 차례로 보여준다. 코드팩토리의 ["Claude Code Mods 설명, 10가지 사용 사례"](https://youtu.be/z-GwTV_qID8)(10-06, 약 3.1만 회)는 8분 37초로 사용 사례를 묶었다. 김플립의 ["클로드 코드 Mods, 실제 예시로 처음부터 끝까지"](https://youtu.be/N-djs9BCIyE)(10-09, 약 1.8만 회)는 스크립트와 무엇이 다른지, 이벤트와 훅이 어떻게 끼어드는지, 화면에 어떻게 그리는지를 7분 52초에 정리한다.

김플립 영상의 설명란이 이번 주 mod 영상들 중 주의점을 가장 구체적으로 적었다. 모드는 샌드박스 없이 내 권한으로 돌아가니 모르는 사람이 만든 모드는 함부로 깔지 말 것, 설치 전에 `claude plugin validate [모드 폴더]`를 돌릴 것, Claude가 만든 모드는 세션 임시 폴더에 저장되고 `cleanupPeriodDays`(기본 30일)가 지나면 지워지니 계속 쓸 거면 꺼내 둘 것이다. 이 부분과 샌드박스 경고는 Anthropic 공식 문서에도 같은 설명이 있다. mod는 사용자 권한으로 실행되고, 파일 읽기·쓰기와 프로세스 시작, 네트워크 요청이 가능하며, 환경변수와 API 키도 읽을 수 있다고 경고한다. 인기 영상 대부분이 "깔아 보라"에 초점을 맞춘 만큼, 어디서 받을지를 먼저 따져야 하는 기능이다.

### OpenAI가 수학 결과를 쏟아냈다

조회수 57만 회로 mods 소개 영상과 어깨를 나란히 한 건 Wes Roth의 ["OpenAI's \"Alien Math\" Is Freaking People Out"](https://youtu.be/rxpV3QLV-pg)(10-09)이다. 설명란에 따르면 OpenAI가 수백 건의 수학 결과를 공개했고, 일군의 수학자가 보이콧을 촉구했으며, Scott Aaronson은 이를 "Mathocalypse"라 불렀다. Vitalik Buterin과 Justin Drake는 AI가 주도하는 발견이 비트코인·이더리움·암호화에 뜻하는 바를 경고한다. 앞선 ["OpenAI's secret model just BROKE math..."](https://youtu.be/fTGIV3e8dTU)(10-07, 약 14만 회)는 공개 규모를 "미출시 모델이 쓴 수학 논문 722편"으로 소개한다.

영상 밖에서 확인되는 건 이렇다. Scott Aaronson의 블로그 글 ["The Mathocalypse"](https://scottaaronson.blog/?p=10169)는 OpenAI가 전날 공개한 "372개의 대형 결과" 중에 Unique Games Conjecture의 증명이 있었다고 쓴다. 수학자 단체 AHM(Association for Human Mathematics)은 10-06 공개를 두고 [성명](https://www.ahmath.org/statements)을 내어, 수학자들이 요청하지 않은 작업이라며 수학자들에게 OpenAI와의 작업을 중단하라고 촉구했다. 다만 영상의 "722편"과 Aaronson의 "372개"는 세는 단위가 다른 것으로 보이는데, 어떻게 대응하는지는 확인하지 못했다. OpenAI의 공개 글은 접속이 막혀 직접 읽지 못했고, Vitalik Buterin과 Justin Drake의 발언은 영상 설명란을 인용한 것이다.

### 과학과 모델 쪽

Two Minute Papers의 ["DeepSeek Solved AI's Memory Problem"](https://youtu.be/4fLVq6HJsKc)(10-11, 약 17만 회)는 DeepSeek-OCR 논문을 5분 38초로 소개한다. Latent Space의 ["Why AlphaFold Didn't Solve Protein Folding"](https://youtu.be/NufiHZfMwaw)(10-10, 약 8천 회)에서는 Google DeepMind의 Pushmeet Kohli와 Biohub의 Sal Candido가 패널로 나와, AlphaFold의 돌파가 시작일 뿐인 이유와 연산·데이터를 키우는 것만으로는 생물학이 풀리지 않는 이유를 이야기한다고 설명란이 소개한다.

### Laya가 고른 단독 포스트감 (실험)

[교사 증류로 학습한 Laya 선별기]({% post_url 2026/2026-10-06-laya-teacher-distillation %})가 이번 주 후보 25개 중 꼽은 상위 5개다. 조회수가 아니라 "따라 해볼 만한 내용인가"로 고른 순위다.

1. [Claude Code Mods 설명, 10가지 사용 사례](https://youtu.be/z-GwTV_qID8) — 코드팩토리 (10-06)
2. [제 영상 속 모션그래픽, 드디어 공개합니다](https://youtu.be/TzDlXg8Cg8o) — Jay Choi | 인디해커 라이프 (10-08). 설명란을 보면 모션그래픽 키트 Blueprint를 "출시가"로 파는 영상이다
3. [클로드 코드 Mods, 실제 예시로 처음부터 끝까지](https://youtu.be/N-djs9BCIyE) — 김플립 (10-09)
4. [Shadcn Lint 써서 AI로 디자인 박살내지 않기](https://youtu.be/2_2M0DlHD1Y) — 코드팩토리 (10-05)
5. [DeepSeek Solved AI's Memory Problem](https://youtu.be/4fLVq6HJsKc) — Two Minute Papers (10-11)

상위 3개 중 2개가 mod 영상이고, 2위는 설명란을 보면 모션그래픽 키트를 파는 영상이다. 광고를 거르는 규칙은 설명란의 광고 문구를 기준으로 하는데, 이 영상은 규칙에 걸리지 않았다.
