# 블로그(redskelt.github.io) 팀 흐름

herdr-team 플러그인의 프로젝트 흐름 파일이다. 이 저장소에서 팀으로 일할 때는 일반 흐름 대신 이 파일을 따른다.

## 적용 범위
- 이 저장소(GitHub Pages 블로그, Jekyll) 전용이다. 공개 저장소이므로 사내 · 비공개 자료, 비밀번호 · 토큰을 파일 · 커밋 · 요청문에 넣지 않는다.

## 포스트 규칙 위임 (필수)
포스트(`_posts/`) 작성 · 수정 · 삭제를 팀원(pi · agy · claude 등)에게 맡길 때, 팀장은 요청문에 아래를 반드시 넣는다. pi · agy 는 스스로 스킬을 읽지 않으므로 경로와 행동을 명시한다.
1. 첫 행동으로 `.claude/skills/post/SKILL.md` 전체를 읽는다(작성 · 수정 · 삭제 절차 포함).
2. 같은 파일의 "공통: 발행 전 체크리스트"를 모두 따르고, 결과를 보고에 항목별로 적는다.
3. 마친 뒤 `bash .claude/skills/post/verify-build.sh <slug>`(slug = 파일명 `YYYY-MM-DD-<slug>.md` 의 slug 부분)로 로컬 빌드를 검증하고 결과를 보고에 붙인다.
4. 사내 · 비공개 자료가 의심되면 쓰지 말고 결정 요청 파일로 올린다(기본값 거부).
5. 영상 기반 수치 · 순위 · 비율은 근거(타임스탬프 · 공식 문서 링크)가 없으면 본문에 쓰지 않는다.

팀장은 팀원 결과를 받으면 위 2 · 3 의 출력을 직접 확인한 뒤에만 병합한다(보고만 믿지 않는다).

## 이슈와 브랜치
- 기준 브랜치: `master`.
- 이슈 브랜치: `team/<주제>`(예: `team/post-hardening-1104`). 역할 브랜치: `team/<역할>-<런타임>-<주제>`.
- worktree 는 `teamctl wt-create` 로 만든다(역할 worktree 는 이슈 브랜치에서 갈라낸다).
- 팀원이 같은 파일(`post/SKILL.md` 등)을 동시에 고칠 때는 서로 다른 절만 맡겨 충돌을 피한다.

## 단계
1. 이슈 worktree 에서 팀장이 작업을 쪼갠다. 짧은 일은 팀장이 직접 한다.
2. 구현 팀원은 자기 역할 worktree 에서 커밋한다(push 금지).
3. 병합은 팀장이 한다: `git -C <이슈 worktree> merge --no-ff '<역할 브랜치>'`. 충돌이 나면 `merge --abort` 후 구현 팀원이 자기 worktree 에서 이슈 브랜치를 병합해 해결한다.
4. 로컬 검증: `bash .claude/skills/post/verify-build.sh <slug>`.
5. 교차 리뷰는 병합 뒤 이슈 worktree 에서 읽기 전용으로 받는다.
6. push · master 병합 · 사이트 반영은 **사용자 결정 뒤** 팀장이 한다.

## 주의
- `.claude/` 는 기기별 설정이라 `.gitignore` 에 걸려 있고(`settings*.json`, `rules/`, `audit/`, `verify-blog-evidence/` 포함), `.claude/skills/` 만 추적 대상이다. 새 스킬도 `git add -f` 없이 그냥 스테이징한다. 예외로 `verify-blog` 스킬은 사용자 결정(2026-11-08)으로 로컬 전용이라 `.gitignore` 에 따로 걸려 있다.
- 저장소 루트의 팀 문서(`TEAM.md`)는 `_config.yml` 의 `exclude` 에 넣어 사이트 페이지로 빌드되지 않게 한다(빠지면 htmlproofer 가 `/TEAM/` 페이지에서 실패한다).
- `scripts/` · `var/` 도 `.gitignore` 에 걸려 추적되지 않는다. 그 안의 스크립트가 필요하면 원래 저장소 폴더에서 읽기만 한다.
- 커밋 메시지에는 변경 설명만 쓴다(AI 공동저자 줄을 넣지 않는다).

## 규칙과 그것을 막는 것
같은 실수가 두 번 나온 규칙만 적는다. "막는 것"이 비어 있는 규칙은 어겨도 아무것도 실패하지 않으니 반복되면 더 높은 수준(구조 → 린트 → 시험 → 문서)에서 막는다. 실수가 더 일어날 수 없게 되면 그 줄을 지운다.

| 규칙(막으려는 실수) | 막는 것 | 근거 커밋 |
|---|---|---|
| 카테고리는 `_data/category_hierarchy.yml` 의 leaf 만, `Trending` 은 주간 roundup 전용 | `.github/scripts/check-posts.rb` (CI · 로컬 공통) + `test-check-posts.sh` | b5baf93, 73c2415 |
| 시리즈 포스트는 `series` · `series_index` · `_data/series.yml` 등록, 편 수 일치 | 같은 `check-posts.rb` + 시험 | 3dc802a, 6057f33 |
| slug(파일명에서 날짜를 뺀 부분)는 저장소 전체에서 하나 | 같은 `check-posts.rb` + 시험 | 352f757, 5e35b5f |
| 영상 제목 · 채널 이름 속 세로 막대 글자가 헤더 없는 표를 만들지 않게 역슬래시로 이스케이프한다 | 같은 `check-posts.rb` + 시험 | 7f8393f, 12e0250 |
| 미래 date 포스트가 조용히 빠지지 않는다 | 구조: `_config.yml` 의 `future: true`. `check-posts.rb` 가 그 줄이 있는지 확인 + 시험 | 093f2da, 1c05811, 0c867e2 |
| 유튜브 영상은 링크만 걸지 않고 `{% include video %}` 로 임베드한다(주간 roundup 은 링크만 나열하는 형식이라 예외) | 같은 `check-posts.rb` + 시험 | 44fa571 |
| 커밋 작성자 · 커미터 이메일은 GitHub noreply 형식만(회사 · 개인 메일이 공개 이력에 남지 않게). 이 저장소에서 `git config user.email` 을 noreply 로 둔다 | `.github/scripts/check-commit-identity.sh` + `test-check-commit-identity.sh` (`build-site.sh` 가 CI · 로컬 공통, 위반 주소는 공개 로그라 출력하지 않음) | 2026-11-10 감사에서 179개 커밋(이력 재작성) |
| 포스트(주간 roundup 제외)에는 스크린샷이 한 장은 있다. 텍스트만 있는 포스트를 올리지 않는다 | **미강제.** 기계 검사는 제약이 커서 두지 않기로 했다(사용자 결정 2026-11-16). `post/SKILL.md` 의 '스크린샷 필수' 규칙뿐. 이미지 없는 포스트가 8개 올라가 있다 | aef14d2, e72c5b3 |
| 스크린샷 PNG 는 가로 1342px 이상이다(작게 찍고 키우면 클릭 확대가 뿌옇다) | **미강제.** 위와 같은 결정. `post/SKILL.md` 의 '캡처 해상도' 문서뿐. 1342px 미만이 3장 남아 있다 | fe6ca4b |
| 사내 코드 · 업무 화면 · 계정 · 사용자명 · 회사 이름이 포스트 · 이미지 · 문서에 들어가지 않게 한다 | **미강제.** 이미지 내용과 코드의 의미는 기계가 못 읽는다. `post/SKILL.md` 의 "비공개 자료" 질문 절차뿐. 한 번 push 하면 이력 · 캐시에 남으니 올리기 전에 사용자에게 묻는다 | cd36aaf(3편 사내 코드 되돌림), f127893(스크린샷 사용자명 · 문서 회사명) |
| 로컬 빌드와 CI 빌드가 다르지 않다 | 구조: `.github/scripts/build-site.sh` 하나를 CI 와 `verify-build.sh` 가 같이 부른다 | 53f12f1, 3d6553b, e21ef9d |
| CI 가 저절로 바뀌는 환경에 기대지 않는다: 러너는 `ubuntu-latest` 대신 버전이 든 이미지, setup-ruby 는 `ruby-version: .ruby-version` | `.github/scripts/check-workflows.rb` + `test-check-workflows.sh` (`build-site.sh` 가 CI · 로컬 공통) | 3d7dfad, 08c614d |
| 깨진 링크 · 이미지, 사이트에 노출되면 안 되는 루트 `.md` | `build-site.sh` 의 htmlproofer. 루트 `.md` 는 `_config.yml` `exclude` | e21ef9d |
| 영상 기반 포스트에 근거 없는 서술을 쓰지 않는다(채널 오기재, 수치 오독, 근거 없는 비율, 자동 요약을 설명란으로 착각, 협찬 추정, 잘린 설명만 보고 쓴 챕터 부재 주장) | **미강제.** `post/SKILL.md` 의 수치 근거 메모 + 다른 모델 교차 리뷰(수동). 의미 판단이라 린트로 막지 못한다 | 535cada, e72c5b3, 8806567, 1f0e477, bc11d5b |
| 추적되는 문서 · 스킬이 로컬 전용 스킬 · 경로(`push-verify`, `wiki/`, `docs/superpowers` 등)를 "이걸 쓰라"고 안내하지 않는다. 쓰려면 "(로컬)" 표시와 함께 실제 명령을 적는다 | **미강제.** 구조로는 이미 막았다(추적 중단 2b4252e, 스킬별 ignore 56dc65f). 남은 건 문장이 독자에게 없는 것을 쓰라고 하는지의 판단이라 린트가 못 가른다(`wiki-ingest` 처럼 로컬 폴더를 설명하는 정당한 언급이 많아 오탐이 크다). 2026-11-16 점검에서 남은 언급은 모두 "(로컬)" 표시가 있거나 아래 `scripts/` 행에 기록됨 | 2b4252e, 56dc65f, 0ae4aff |
| `docs/handoff` 상태 문서가 코드 · 결정 변경을 따라간다(낡은 "커밋 안 함", "병합 안 함", "5개뿐"을 남기지 않는다) | **미강제.** `docs/` 가 로컬 전용이라 CI 가 볼 수 없다. 작업을 끝낼 때 해당 문서의 해시 · 경로를 `git cat-file` · `git check-ignore` 로 대조한다(2026-11-16 에 3개 문서의 낡은 주장 3건을 이렇게 찾아 고침) | 이력 없음(로컬 문서) |
| 수집 스크립트(`scripts/`)가 worktree · 다른 컴퓨터에서 보여야 한다 | **미강제.** 위 "주의"의 문장뿐. `.gitignore` 의 `/scripts/` 때문에 추적되지 않는다(추적 전환은 사용자 결정 대기) | 2026-11-04, 2026-11-09 팀 작업에서 확인 |
