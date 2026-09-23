---
title: "SKILL.md 8줄로 끝나는 플러그인 — eli5 뜯어보기"
date: 2026-09-17 15:00:00 +0900
categories: [AI]
tags: [ClaudeCode, 플러그인, Skill, Artifact]
---

[anthropics/claude-plugins-community](https://github.com/anthropics/claude-plugins-community) 저장소는 Claude Code/Claude Cowork용 커뮤니티 플러그인을 모아놓은 마켓플레이스입니다. 그 안에서 가장 작고 인상적인 플러그인 하나를 골라 직접 돌려봤습니다 — **eli5**.

### eli5가 뭔가

`/eli5 <주제>`라고 치면, 그 주제를 **아무것도 모르는 사람도 알아볼 수 있는 HTML 그림 설명**으로 만들어주는 플러그인입니다. 이름 그대로 "explain like I'm 5"(다섯 살짜리도 알아듣게 설명해줘)입니다. 저장소의 `plugin.json`이 정의를 한 줄로 요약합니다.

```json
{
  "name": "eli5",
  "version": "1.0.0",
  "description": "Explain any topic like I'm 5: a dead-simple HTML picture explainer with big visuals and few words. Use /eli5 <topic>.",
  "author": { "name": "Thariq Shihipar" },
  "license": "MIT",
  "keywords": ["explain", "eli5", "learning", "explainer", "html"]
}
```

### SKILL.md 전문 — 진짜 이게 다입니다

`eli5/skills/eli5/SKILL.md` 파일을 열어보면 허무할 정도로 짧습니다. 주석, 예외 처리, few-shot 예시 하나 없이 딱 이만큼입니다.

```markdown
---
name: eli5
description: Explain a topic like I'm a 5 year old. Use when the user types /eli5 <topic> or asks for a dead-simple picture explainer of how something works.
---

# eli5

Explain like I'm someone who knows nothing about this topic, using a HTML artifact with big pictures and few words.

Topic: $ARGUMENTS
```

front matter의 `description`이 "언제 이 스킬을 써야 하는가"를 정의하고, 본문은 "무엇을 하라"는 지시 딱 한 문장, 그리고 `$ARGUMENTS`로 사용자가 입력한 주제를 그대로 꽂아 넣습니다. 별도의 HTML 템플릿도, 색상 팔레트 지정도, 레이아웃 규칙도 이 파일 안에는 없습니다.

### 그런데 왜 결과물은 허접하지 않을까

이 스킬만 보면 "그냥 HTML 아무렇게나 만들어주는 거 아냐?" 싶은데, 실제로 실행해보면 완성도 있는 그림 설명이 나옵니다. 비밀은 **eli5 스킬이 직접 디자인 규칙을 갖고 있지 않다**는 데 있습니다 — Artifact를 만드는 순간 Claude Code가 자체적으로 로드하는 **artifact-design** 스킬(폰트 페어링, 라이트/다크 테마 토큰, 반응형 여백, AI 특유의 뻔한 디자인 피하기 같은 규칙 뭉치)이 대신 품질을 책임집니다.

즉 eli5는 "무엇을(설명 대상), 어떤 형식으로(그림 위주, 적은 글자)"만 정의하고, "어떻게 잘 만들 것인가"는 플랫폼의 다른 스킬에 위임하는 구조입니다. 작은 플러그인 하나가 커봐야 할 이유가 없는 이유이기도 합니다.

### 직접 돌려본 결과 — "DNS는 어떻게 동작할까?"

`/eli5 DNS는 어떻게 동작할까?`를 그대로 실행해서 나온 설명입니다. 편지 심부름 비유로 4단계 그림을 만들어줬습니다.

![DNS를 편지 심부름에 비유한 eli5 데모 결과 — 4단계 그림 설명](/assets/img/posts/eli5-plugin-review/dns-demo.png)
_이름만 알아도 집을 찾아가는 이야기로 "도메인 이름 → DNS → IP 주소" 흐름을 설명한다._

프롬프트 한 줄, 지시문 8줄짜리 스킬치고는 결과물이 꽤 그럴듯합니다. 텍스트보다 그림 비중이 훨씬 크고, 전문 용어(리졸버, 네임서버 등) 없이 "전화번호부" 하나의 비유로 끝까지 밀고 나가는 점이 원본 스킬이 요구한 "few words, big pictures"를 정확히 지킵니다.

### 설치

```bash
claude plugin marketplace add anthropics/claude-plugins-community
claude plugin install eli5@claude-community
```

설치하면 `/eli5` 슬래시 커맨드가 바로 생깁니다. Claude Cowork를 쓴다면 [claude.com/plugins](https://claude.com/plugins/)에서 클릭 한 번으로도 설치할 수 있습니다.

### 느낀 점

이 플러그인이 재미있는 이유는 기능 자체보다 **스킬을 얼마나 작게 쪼갤 수 있는지 보여주는 예시**라는 점입니다. "언제 쓸지"만 정확히 정의하고 "어떻게 잘 만들지"는 플랫폼(Artifact + artifact-design)에 맡기면, 플러그인 저자는 단 8줄로도 하나의 완결된 기능을 배포할 수 있습니다. 새 스킬을 만들 때 참고할 만한 최소 구성 사례입니다.
