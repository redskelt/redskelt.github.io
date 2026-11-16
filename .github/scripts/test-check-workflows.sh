#!/usr/bin/env bash
# check-workflows.rb 가 과거에 CI 를 깨뜨린 워크플로를 계속 잡는지 확인한다:
#   .github/scripts/test-check-workflows.sh
# build-site.sh 가 CI · 로컬 공통으로 부른다. 전체 이력이 필요하다(CI 는 fetch-depth: 0).
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

# "<고친 커밋>@@<기대하는 오류 문구>@@<그 실수>"
cases=(
  "08c614d@@runs-on 'ubuntu-latest'@@러너가 ubuntu-latest 로 떠서 26.04 에 Ruby 3.3.0 이 없음"
  "3d7dfad@@ruby-version '3.4'@@CI ruby 를 .ruby-version 과 따로 적음"
)

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

failed=0
for c in "${cases[@]}"; do
  sha="${c%%@@*}"
  rest="${c#*@@}"
  want="${rest%%@@*}"
  label="${rest#*@@}"
  if ! git cat-file -e "$sha^" 2>/dev/null; then
    echo "FAIL: 커밋 $sha^ 가 없다. 전체 이력이 필요하다(git fetch --unshallow, CI 는 fetch-depth: 0)." >&2
    exit 1
  fi
  dir="$tmp/$sha"
  mkdir -p "$dir"
  git archive "$sha^" .github/workflows | tar -x -C "$dir"
  set +e
  out="$(bundle exec ruby .github/scripts/check-workflows.rb "$dir" 2>&1)"
  code=$?
  set -e
  if [[ $code -ne 1 || "$out" != *"$want"* ]]; then
    echo "FAIL: $label — $sha^ 를 check-workflows 가 못 잡는다 (exit $code, 기대 문구: '$want')" >&2
    failed=1
  fi
done

if [[ $failed -ne 0 ]]; then
  echo "check-workflows 가 과거 실수를 놓친다. 검사를 고쳤다면 위 실수를 계속 잡도록 되돌린다." >&2
  exit 1
fi
echo "OK: test-check-workflows (${#cases[@]} cases)"
