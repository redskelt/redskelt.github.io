---
title: "이번 주 깃허브 트렌딩 TOP 10 — 민둥이 결산 영상 정리 (10-28)"
date: 2026-10-29 10:40:00 +0900
categories: [AI]
tags: [깃허브트렌딩, 오픈소스, AI에이전트, 코딩스킬, 민둥이]
---

민둥이(쉽게 배우는 AI) 채널이 10월 28일에 올린 7분짜리 영상이다. 이번 주 깃허브에서 별을 가장 많이 받은 오픈소스 10개를 10위부터 차례로 소개한다. 별 개수와 증가량은 영상에서 말한 수치를 그대로 옮겼다. 저장소 링크는 영상 고정 댓글에 있다.

{% include video id="N0H6Pru8Iis" provider="youtube" %}

영상의 결론은 한 줄이다. **이번 주에는 AI에게 일을 맡기는 방식을 다듬는 도구들이 특히 많이 올라왔다.** 10개 중 7개가 스킬, 플러그인, 지휘 도구 같은 에이전트 주변 도구다.

## 10위 안드로이드 스킬 — 별 9,900개

저장소: [android/skills](https://github.com/android/skills)

![안드로이드 스킬 소개 장면](/assets/img/posts/github-trending-top10-mindung-1028/10-android-skills.png)

구글 안드로이드 팀이 AI 코딩 에이전트용으로 만든 작업 설명서 모음이다. AI는 학습 시점의 지식으로 코드를 짜기 때문에 해마다 바뀌는 안드로이드에서는 옛날 방식으로 짜는 일이 잦다. 그래서 구글이 직접 평가해 AI가 자주 틀리는 작업만 골라 공식 순서를 **36개 스킬**로 정리했다. 화면 구성과 앱 용량 최적화부터 워치·TV 앱 지침까지 담겼고, 이번 주에만 세 번 업데이트됐다.

## 9위 오르카 — 별 10만 7,000개 (이번 주 +9,000)

저장소: [stablyai/orca](https://github.com/stablyai/orca)

![오르카 소개 장면](/assets/img/posts/github-trending-top10-mindung-1028/09-orca.png)

터미널, 코드 편집기, 브라우저를 오가는 번거로움을 앱 하나에 모은 데스크톱 앱이다. 앱 안 브라우저에서 버튼 하나를 클릭하면 그 부분의 코드와 캡처가 에이전트에게 넘어가고, 에이전트가 고친 코드에 줄마다 코멘트를 달아 돌려보낼 수 있다. Claude와 Codex 사용량을 계정별로 보여주며, 앱은 무료다.

## 8위 오픈코드 — 별 22만 2,000개

저장소: [anomalyco/opencode](https://github.com/anomalyco/opencode)

![오픈코드 소개 장면](/assets/img/posts/github-trending-top10-mindung-1028/08-opencode.png)

오픈소스로 만든 AI 코딩 에이전트다. Claude, GPT, Gemini는 물론 75곳이 넘는 회사의 모델과 로컬 모델까지 골라 쓸 수 있고, ChatGPT나 GitHub Copilot 구독으로 로그인해도 된다. 계정 없이 쓰는 무료 모델도 들어 있어 지금은 DeepSeek V4.2 Flash와 GLM을 기간 한정으로 무료로 쓸 수 있다. 오늘 나온 2.2 버전부터는 데스크톱 앱 플러그인을 직접 만들어 공유할 수 있다.

## 7위 루플로 — 별 8만 개

저장소: [ruvnet/ruflo](https://github.com/ruvnet/ruflo)

![루플로 README 장면](/assets/img/posts/github-trending-top10-mindung-1028/07-ruflo.png)

Claude Code와 Codex 위에 얹는 에이전트 지휘 도구다. 코딩, 테스트, 보안, 문서를 맡은 에이전트로 팀을 꾸려 일을 나누고, 지난 작업에서 배운 것을 기억해 다음 작업에 쓴다. 토큰과 비용은 대시보드에서 볼 수 있다. 다만 이번 주에 이틀 동안 업데이트가 다섯 번 나왔고 대부분이 보안 구멍을 막는 수정이었다는 점은 알아 둘 만하다.

## 6위 그래피파이 — 별 13만 7,000개 (이번 주 +7,000)

저장소: [Graphify-Labs/graphify](https://github.com/Graphify-Labs/graphify)

![그래피파이 README 장면](/assets/img/posts/github-trending-top10-mindung-1028/06-graphify.png)

코드, 문서, PDF, 이미지, 영상까지 프로젝트 전체를 하나의 **연결 지도**로 엮어 두는 도구다. AI는 파일을 뒤지는 대신 이 지도에서 필요한 연결만 찾아 답한다. 코드 지도는 AI 모델 없이 내 컴퓨터 안에서 만들어 비용이 들지 않고, 20개 넘는 도구에서 쓸 수 있다. 만든 쪽이 100만 줄짜리 프로젝트에 질문 여섯 개를 던져 보니 핵심 사실을 찾아내는 비율이 71%에서 82%로 올랐다고 한다.

## 5위 트레이딩 에이전츠 — 별 11만 7,000개

저장소: [TauricResearch/TradingAgents](https://github.com/TauricResearch/TradingAgents)

![트레이딩 에이전츠 README 장면](/assets/img/posts/github-trending-top10-mindung-1028/05-tradingagents.png)

여러 AI가 투자 회사처럼 역할을 나눠 종목을 분석하는 프로그램이다. 재무제표, 뉴스, 커뮤니티 반응, 차트를 맡은 분석가가 보고서를 내면, 오른다는 쪽과 떨어진다는 쪽 연구원이 토론하고, 트레이더와 위험 관리 팀을 거쳐 최종 결정이 나온다. 과정은 보고서로 남고 지난 결정은 실제 수익률과 비교해 다음 분석에 반영한다. 프로젝트 스스로 연구용이라고 밝히고 있다.

## 4위 카파시 스킬 — 별 22만 5,000개

저장소: [multica-ai/andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills)

![카파시 스킬 소개 장면](/assets/img/posts/github-trending-top10-mindung-1028/04-karpathy-skills.png)

별은 많은데 열어 보면 파일이 한 장뿐이다. Claude Code가 일을 시작하기 전에 읽는 설정 파일 `CLAUDE.md`다. 출발점은 안드레 카파시가 X에 올린 글로, AI가 멋대로 짐작하고, 100줄이면 될 코드를 1,000줄로 짜고, 시키지 않은 코드까지 고친다는 지적이었다. 파일은 이를 네 가지 원칙으로 막는다. **짜기 전에 먼저 묻고, 단순하게 짜고, 요청한 곳만 고치고, 끝났는지 확인할 기준부터 정한다.** Claude Code 플러그인으로 바로 깔 수 있고 Cursor용 규칙도 들어 있다.

## 3위 클로드 SEO — 별 22,000개

저장소: [AgriciDaniel/claude-seo](https://github.com/AgriciDaniel/claude-seo)

![클로드 SEO 소개 장면](/assets/img/posts/github-trending-top10-mindung-1028/03-claude-seo.png)

내 사이트가 검색에 잘 걸리는지 주소 하나로 점검해 주는 Claude Code용 무료 플러그인이다. 최대 17개 에이전트가 사이트를 나눠 훑으며 속도, 구조, 콘텐츠 신뢰도를 보고, ChatGPT나 Perplexity 같은 AI 검색에 인용되기 쉬운지도 따진다. 10~15분이면 먼저 고칠 순서를 정리한 보고서가 나오고 API 키는 필요 없다.

## 2위 지식 노동 플러그인 — 별 33,000개

저장소: [anthropics/knowledge-work-plugins](https://github.com/anthropics/knowledge-work-plugins)

![지식 노동 플러그인 README 장면](/assets/img/posts/github-trending-top10-mindung-1028/02-knowledge-work-plugins.png)

Anthropic이 직접 만든 플러그인 모음으로, Claude를 영업·재무·법무·마케팅 같은 직무별 전문가로 바꿔 준다. Claude Cowork와 Claude Code 양쪽에서 쓴다. 영업 플러그인은 이번 주 업데이트로 문장마다 출처 링크가 붙었고, 소상공인 플러그인은 메일 발송이나 결제를 내가 허락해야만 진행한다. 외부 회사가 만든 것까지 합치면 120개가 넘고, 코드 없이 문서로만 되어 있어 내 방식대로 고치기 쉽다.

## 1위 클라우드플레어 시큐리티 오딧 스킬 — 별 4만 9,000개 (이번 주 +16,000)

저장소: [cloudflare/security-audit-skill](https://github.com/cloudflare/security-audit-skill)

![시큐리티 오딧 스킬 장면](/assets/img/posts/github-trending-top10-mindung-1028/01-security-audit-skill.png)

이번 주에 늘어난 별이 2위보다 다섯 배 넘게 많다. AI 코딩 에이전트를 보안 감사 담당으로 바꿔 주는 스킬인데, 여러 에이전트가 구역을 나눠 취약점을 찾는 데서 끝나지 않는다. **의심되는 것을 찾으면, 찾은 에이전트가 아닌 다른 에이전트가 정말 공격할 수 있는지 반박하며 다시 검증한다.** 메모리 오류, 로그인, 프롬프트 인젝션, 클라우드 설정 실수까지 보고, 코드를 직접 돌려야 할 때는 인터넷이 막힌 격리 공간에서만 돌린다. 결과는 확인된 것과 더 확인할 것을 나눈 보고서로 나온다.

## 정리

| 순위 | 저장소 | 한 줄 요약 |
|---|---|---|
| 1 | [cloudflare/security-audit-skill](https://github.com/cloudflare/security-audit-skill) | 에이전트끼리 반박하며 검증하는 보안 감사 스킬 |
| 2 | [anthropics/knowledge-work-plugins](https://github.com/anthropics/knowledge-work-plugins) | 직무별 Claude 플러그인 모음 (Anthropic) |
| 3 | [AgriciDaniel/claude-seo](https://github.com/AgriciDaniel/claude-seo) | 주소 하나로 하는 SEO·AI 검색 점검 |
| 4 | [multica-ai/andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills) | 4가지 원칙이 담긴 `CLAUDE.md` 한 장 |
| 5 | [TauricResearch/TradingAgents](https://github.com/TauricResearch/TradingAgents) | 투자 회사처럼 역할을 나눈 종목 분석 |
| 6 | [Graphify-Labs/graphify](https://github.com/Graphify-Labs/graphify) | 프로젝트 전체를 연결 지도로 |
| 7 | [ruvnet/ruflo](https://github.com/ruvnet/ruflo) | 에이전트 팀 지휘 도구 |
| 8 | [anomalyco/opencode](https://github.com/anomalyco/opencode) | 오픈소스 AI 코딩 에이전트 |
| 9 | [stablyai/orca](https://github.com/stablyai/orca) | 터미널·편집기·브라우저를 한 앱에 |
| 10 | [android/skills](https://github.com/android/skills) | 안드로이드 공식 작업 설명서 36개 |

개인적으로 눈에 띄는 건 1위와 4위다. 둘 다 대부분이 **지시문과 절차를 담은 문서**인데, 1위는 이번 주 별이 가장 많이 늘었고 4위는 별 총합이 22만 개를 넘는다. 에이전트를 더 똑똑하게 만드는 것보다, 에이전트가 어떻게 일하게 할지 정하는 쪽에 관심이 몰리고 있다는 뜻으로 읽힌다.
