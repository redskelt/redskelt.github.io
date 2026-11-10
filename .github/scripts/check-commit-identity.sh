#!/usr/bin/env bash
# 커밋 신원 검사: .github/scripts/check-commit-identity.sh [저장소 루트]
#
# 이 저장소는 공개라서 모든 커밋의 작성자 · 커미터 이메일이 그대로 공개된다
# (github.com/<repo>/commit/<sha>.patch 의 From 줄). 회사 · 개인 메일이 179개 커밋에 남은 것을
# 2026-11-10 에 발견해 이력을 다시 썼다. 전역 git 설정의 메일이 그대로 쓰인 것이 원인이다.
# 그래서 모든 커밋의 이메일이 GitHub noreply 형식이어야 한다.
#   허용: <id>+<user>@users.noreply.github.com, <user>@users.noreply.github.com,
#         noreply@github.com (GitHub 웹에서 만든 커밋의 커미터)
#
# CI 로그도 공개이므로 위반한 주소는 출력하지 않는다. 커밋 해시와 필드만 낸다.
# build-site.sh 가 CI 와 로컬에서 같이 부른다. 전체 이력이 필요하다(CI 는 fetch-depth: 0).
set -euo pipefail

cd "${1:-$(git rev-parse --show-toplevel)}"

bad="$(git log --all --format='%h %ae %ce' | awk '
  function ok(e) { return e ~ /@users\.noreply\.github\.com$/ || e == "noreply@github.com" }
  { f = ""; if (!ok($2)) f = "작성자"; if (!ok($3)) f = f (f == "" ? "" : "·") "커미터"; if (f != "") print $1 " " f }
')"

if [[ -n "$bad" ]]; then
  n="$(printf '%s\n' "$bad" | wc -l | tr -d ' ')"
  echo "FAIL: check-commit-identity — noreply 가 아닌 이메일이 든 커밋 ${n}건 (주소는 공개 로그라 출력하지 않는다)" >&2
  printf '%s\n' "$bad" | head -10 | sed 's/^/  /' >&2
  echo "  고치기: 이 저장소에서 git config user.email '<id>+<user>@users.noreply.github.com' 로 바꾸고," >&2
  echo "  아직 push 하지 않은 커밋이면 git commit --amend --reset-author 로 다시 만든다." >&2
  echo "  이미 push 했다면 이력 재작성이 필요하니 혼자 고치지 말고 사용자에게 알린다." >&2
  exit 1
fi
echo "OK: check-commit-identity ($(git rev-list --all --count) commits)"
