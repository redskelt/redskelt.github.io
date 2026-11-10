#!/usr/bin/env bash
# check-commit-identity 회귀 시험: .github/scripts/test-check-commit-identity.sh
#
# 실제 실수(전역 git 설정의 회사 메일이 179개 커밋에 남음)는 이력을 다시 쓸 때 지워져서 그 커밋으로는
# 재생할 수 없다. 대신 같은 모양의 커밋을 임시 저장소에 만들어 검사가 잡는지 본다.
# 주소는 example.org 로 쓴다. 검사를 느슨하게 고치면 여기서 실패한다.
# build-site.sh 가 CI 와 로컬에서 같이 부른다.
set -euo pipefail

check="$(cd "$(dirname "$0")" && pwd)/check-commit-identity.sh"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

NOREPLY='1+someone@users.noreply.github.com'
failed=0

# "<이름>@@<작성자 이메일>@@<커미터 이메일>@@<기대 exit>@@<출력에 있어야 하는 문구(없으면 -)>"
cases=(
  "noreply 작성자·커미터@@$NOREPLY@@$NOREPLY@@0@@-"
  "GitHub 웹 커미터@@$NOREPLY@@noreply@github.com@@0@@-"
  "작성자만 일반 메일@@dev@example.org@@$NOREPLY@@1@@작성자"
  "커미터만 일반 메일@@$NOREPLY@@dev@example.org@@1@@커미터"
  "둘 다 일반 메일@@dev@example.org@@dev@example.org@@1@@작성자·커미터"
)

for c in "${cases[@]}"; do
  name="${c%%@@*}"; rest="${c#*@@}"
  author="${rest%%@@*}"; rest="${rest#*@@}"
  committer="${rest%%@@*}"; rest="${rest#*@@}"
  want_code="${rest%%@@*}"; want_text="${rest#*@@}"

  repo="$tmp/r$RANDOM"
  git init -q "$repo"
  (cd "$repo" && echo x > f && git add f &&
    GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL="$author" GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL="$committer" \
      git commit -q -m t)
  set +e
  out="$("$check" "$repo" 2>&1)"
  code=$?
  set -e

  if [[ "$code" != "$want_code" ]]; then
    echo "FAIL: $name — exit $code (기대 $want_code)" >&2; failed=1; continue
  fi
  if [[ "$want_text" != "-" && "$out" != *"$want_text"* ]]; then
    echo "FAIL: $name — 출력에 '$want_text' 가 없다" >&2; failed=1; continue
  fi
  if [[ "$out" == *"example.org"* ]]; then
    echo "FAIL: $name — 위반한 주소가 출력됐다(공개 CI 로그로 새어 나간다)" >&2; failed=1
  fi
done

if [[ $failed -ne 0 ]]; then
  echo "check-commit-identity 시험 실패. 검사를 고쳤다면 위 경우를 계속 잡도록 되돌린다." >&2
  exit 1
fi
echo "OK: test-check-commit-identity (${#cases[@]} cases)"
