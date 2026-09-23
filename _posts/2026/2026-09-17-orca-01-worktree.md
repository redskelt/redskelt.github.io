---
title: "Orca 파헤치기 1편 - Worktree 네이티브 구조와 설치"
date: 2026-09-17 09:00:00 +0900
categories: [AI]
tags: [Orca, git worktree, AI에이전트, 개발환경]
series: orca
series_index: 1
---

[지난 리뷰 글](/ai/orca-ide-review/)에서 Orca를 "클로드 코드·코덱스 같은 에이전트를 병렬로 굴리는 IDE"로 소개했습니다. 이번 시리즈에서는 [공식 문서](https://www.onorca.dev/docs)를 기준으로 기능 하나하나를 깊게 파고듭니다. 1편은 Orca 전체를 떠받치는 뼈대인 **worktree**입니다.

![Orca 메인 화면 — 왼쪽 사이드바에 worktree별로 프로젝트가 나뉘어 있다](/assets/img/posts/orca-ide-review/main-ui-worktrees.png)
_왼쪽 사이드바의 `debug-w1`, `debug-w2`처럼 같은 저장소 안에서도 작업마다 별도 worktree가 생성된다._

### 왜 worktree인가

일반적인 IDE에서 AI 에이전트 여러 개를 동시에 돌리려면 브랜치를 계속 갈아타거나 `git stash`를 반복해야 합니다. 저장소 디렉토리 자체가 하나뿐이라 "지금 어느 브랜치 상태인지"가 항상 하나로 고정되기 때문입니다.

Orca는 이 문제를 **worktree 네이티브** 구조로 풉니다. 문서의 표현을 그대로 옮기면:

> 각 저장소는 기본 참조(보통 `origin/main`)를 가지고, 각 worktree는 자신의 브랜치·파일·에이전트 터미널을 독립적으로 보유한다. worktree를 삭제하면 디렉토리와 브랜치가 함께 제거된다.

즉 작업(Task) 하나 = `git worktree add`로 만든 디스크상의 별도 복사본 하나. 에이전트 세 개를 동시에 돌려도 서로의 파일을 건드릴 일이 없습니다.

### worktree의 생애주기 5단계

문서는 worktree 하나의 일생을 다섯 단계로 정리합니다.

1. **생성** — 작업명, 시작점(기본 참조/다른 브랜치/특정 커밋 SHA/원격 브랜치)을 고르고, 필요하면 GitHub·Linear·Jira 이슈를 바로 연결
2. **작업** — 에이전트 터미널, 편집기, 브라우저 탭이 모두 이 worktree 범위로 스코프됨
3. **검토** — diff 보기, AI diff 주석, 귀속(Attribution) 추적 (→ 3편에서 자세히)
4. **배포** — 커밋, 푸시, PR 오픈, CI 체크 대기
5. **아카이브/삭제** — 클릭 한 번으로 worktree와 브랜치를 함께 정리

생성 다이얼로그를 제출하면 백그라운드에서 `git fetch`와 `git worktree add`가 실행되고, 사이드바에 진행 상황이 표시됩니다. 생성 도중 중단도 가능합니다.

### node_modules까지 매번 새로 깔 필요는 없다

worktree마다 완전히 독립된 디렉토리라는 게 장점이자 단점이 될 수 있습니다 — 매번 `node_modules`를 새로 설치해야 한다면 배보다 배꼽이 큽니다. Orca는 gitignore된 디렉토리를 공유하는 세 가지 방법을 제공합니다.

1. **Worktree Shared Paths** (설정 → 저장소): macOS에서는 APFS clone-copy, 그 외에는 심볼릭 링크
2. **`orca.yaml`의 `worktree.sharedDirectories`**

   ```yaml
   worktree:
     sharedDirectories:
       - node_modules
       - .cache
   ```

3. **저장소 루트의 `.worktreeinclude`** — `.env`, `.env.local`처럼 각 worktree가 **자기 복사본을 소유**해야 하는 파일 목록 (심볼릭 링크가 아니라 복사, glob 미지원)

### 사이드바 관리 — 필터와 단축키

worktree가 10개, 20개로 늘어나면 사이드바 정리가 관건입니다. 기본은 프로젝트별 그룹화이고, 다음 조건으로 필터링할 수 있습니다.

- Sleeping 워크스페이스 숨기기 / 기본 브랜치 제외 / Automation·CLI로 생성된 워크스페이스만 보기 / Detached HEAD 워크스페이스

macOS에서는 `Cmd-Shift-Backspace`로 worktree를 바로 삭제할 수 있고, `Cmd`/`Shift` 클릭으로 다중 선택도 지원합니다. 삭제하려는 브랜치에 아직 병합되지 않은 커밋이 있으면 **Preserved Branches**로 자동 보존되고 "Review N Branches" 토스트로 나중에 검토할 수 있어, 실수로 작업물을 날릴 위험이 낮습니다.

한 가지 확인해둘 점: 모든 Orca worktree는 **진짜 git worktree**라서 터미널에서 `git status`, `git rebase` 등을 그대로 써도 되고 Orca가 변경 사항을 자동으로 감지합니다. 락인(lock-in) 걱정 없이 평소 쓰던 git 습관을 그대로 유지할 수 있다는 뜻입니다.

### 설치

- **직접 다운로드**: macOS(Apple Silicon/Intel DMG), Windows 설치 파일, Linux(AppImage/.deb/.rpm) — [onorca.dev/download](https://www.onorca.dev/download)
- **Homebrew (macOS)**:

  ```bash
  brew install --cask stablyai/orca/orca
  # 업데이트
  brew upgrade --cask orca
  ```

- 무료·오픈소스(MIT), GitHub 스타 70k+. 첫 실행 시 홈 디렉토리 접근 권한과 기존 설정 파일 가져오기 여부를 물어봅니다.

다음 2편에서는 Orca가 지원하는 에이전트 목록과, 그 에이전트들이 남긴 세션을 어떻게 되짚어보는지(Agent Session History)를 다룹니다.
