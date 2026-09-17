---
title: "Orca 파헤치기 6편(완) - GitHub 연동, CLI, 그리고 Orchestration"
date: 2026-09-17 11:25:00 +0900
categories: [AI, Trending]
tags: [Orca, GitHub, OrcaCLI, Orchestration, SSH]
series: orca
series_index: 6
---

시리즈 마지막 편입니다. [5편](/ai/trending/orca-05-mobile/)까지 UI 안에서 손으로 조작하는 기능들을 봤다면, 이번엔 Orca를 **저장소·터미널·여러 에이전트를 잇는 배선**으로 쓰는 세 가지 — GitHub 연동, Orca CLI, Orchestration — 를 묶어서 봅니다.

![Orca 공식 문서 — Hosted reviews, issues & Actions 페이지](/assets/img/posts/orca-ide-review/docs-github-review.png)
_"GitHub integration — open PRs, watch checks, and triage issues without leaving the worktree."_

### GitHub 연동 — 호스팅 리뷰가 worktree의 1급 시민

설정 → 통합에서 GitHub(가장 깊은 지원), GitLab, Bitbucket, Azure DevOps, Gitea를 연결할 수 있습니다. worktree를 푸시하면 소스 제어 패널에서 곧바로 호스팅된 리뷰(PR/MR)를 열 수 있고, 그 리뷰의 상태(열림/병합됨/닫힘)가 사이드바에 실시간으로 붙어 있습니다.

- PR 링크 복사, 닫기, 다시 열기를 Orca 안에서 처리
- PR 댓글에 👍 👎 😄 😕 ❤️ 🎉 🚀 👀 반응 추가
- 필수 체크·필수 리뷰가 통과되면 GitHub 쪽 자동 병합 그대로 연동
- 기존 PR 위에 쌓는 **스택 PR**을 컴포저에서 구성하고, 스택 맵에서 전체 상태를 한 번에 확인·병합
- GitHub 이슈/PR에서 바로 worktree를 만드는 대화형 컴포저 — 이슈의 코멘트·타임라인 이벤트(할당, 상태 변경)까지 같이 표시
- 실패한 GitHub Actions는 빨간 칩으로 표시되고, 로그를 인라인으로 바로 확인
- GitHub Projects 뷰로 여러 프로젝트 카드를 한 화면에서 관리

한마디로 "PR을 열기 위해 브라우저 탭을 새로 띄울 필요가 없다"는 게 이 기능의 존재 이유입니다.

### Orca CLI — 셸에서 Orca를 원격 조종

Orca CLI는 "스크립트로 실행 중인 Orca 에디터를 제어하는 터미널 인터페이스"입니다. GUI를 손으로 클릭하는 대신, 다른 스크립트나 CI 파이프라인에서 Orca를 조작하고 싶을 때 씁니다.

```bash
# worktree 관리
orca worktree create --repo id:<repoId> --name my-task --issue 123
orca worktree ps --json

# 터미널 제어
orca terminal send --text "continue" --enter
orca terminal split --direction vertical --command "npm run dev"
```

이 밖에도 파일/diff 열기, 브라우저 자동화(URL 이동, 스크린샷, 요소 클릭, 폼 입력, 반응형 프로필 전환), iOS 시뮬레이터 제어, 예약 자동화·아티팩트(HTML/마크다운 공유 링크) 생성까지 CLI 하나로 다룰 수 있습니다. **1편의 worktree 생성, 4편의 Computer Use**도 결국 이 CLI가 내부적으로 쓰는 것과 같은 명령 체계 위에 있습니다.

### Orchestration — 에이전트 팀을 작업 단위로 조율

여러 에이전트를 그냥 병렬로 띄우는 것과, 그 에이전트들이 **서로 의존하는 작업을 순서대로/조건부로** 처리하게 하는 것은 다른 문제입니다. Orchestration은 후자를 위한 레이어로, 다음 개념으로 구성됩니다.

- **Run**: 지속되는 네임스페이스이자 조율자(Orchestrator)의 홈 인박스. 그 자체로 작업자를 배치하지는 않음
- **Task**: 명세·의존성·상태(`pending` → `ready` → `dispatched` → `completed`/`failed`/`blocked`)를 가진 작업 항목
- **Dispatch**: 터미널에서의 단일 작업 시도 — 작업자 완료와 하트비트 메시지의 생명주기를 관리
- **Message**: 상태·디스패치·완료·에스컬레이션·질문·하트비트 등을 담는 인박스 메일
- **Decision gate**: 조율자가 소유한 질문으로, 답이 기록될 때까지 후속 작업을 막음

흐름은 이렇습니다 — Task를 만들고 `worker-start`로 특정 에이전트를 배치하면, 그 워커는 작업을 마쳤을 때 **정확히 한 번** `worker_done`을 `--outcome`과 함께 보내야 합니다. 조율자는 이 완료 신호들을 모아 추적하고, 애매한 지점에서는 Decision gate로 질문을 던져 사람이나 상위 에이전트의 판단을 기다립니다.

### 보너스: 원격에서 돌리기 (SSH worktrees)

노트북 팬이 돌아가는 무거운 빌드나 GPU가 필요한 작업이라면, worktree 자체를 원격 머신에 둘 수도 있습니다.

- 에이전트는 **원격 호스트**에서 실행되지만, 편집기·diff 뷰는 로컬 그대로 — 파일 이벤트 동기화로 로컬처럼 느껴짐
- Settings → SSH에서 호스트 추가, OpenSSH config 파일에서 자동 가져오기 가능
- 원격 호스트에서 릴레이를 통해 세션이 유지되므로, 랩탑에서 Orca를 꺼도 **원격 세션은 계속 살아있음**
- VS Code Remote-SSH 연동, 포트 포워딩(Ports 탭) 지원

원격 Linux 호스트에는 `build-essential`, `python3` 등 최소한의 빌드 도구가 필요합니다.

### 시리즈를 마치며

1편 worktree부터 6편 Orchestration까지 훑어보면, Orca의 설계 철학이 한 줄로 요약됩니다 — **"에이전트 하나를 잘 쓰는 도구"가 아니라 "이미 잘 쓰고 있는 에이전트 여러 개를, 격리된 worktree 단위로 병렬 운영·검토·조율하는 도구."** 아직 에이전트 한 개도 제대로 안 써봤다면 이 순서보다 클로드 코드나 코덱스부터 먼저 익히는 쪽이 낫고, 반대로 이미 여러 개를 굴리다 손이 모자란 사람에게는 이 시리즈에서 다룬 기능들이 그대로 해답이 됩니다.

시리즈 전체는 [이전 글들](/ai/trending/orca-01-worktree/)에서 이어볼 수 있습니다.
