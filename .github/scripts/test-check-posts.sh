#!/usr/bin/env bash
# check-posts 회귀 시험: .github/scripts/test-check-posts.sh
#
# check-posts.rb 가 실제로 있었던 실수를 계속 잡는지 확인한다. 각 줄은 고치기 직전 커밋(<sha>^)의
# _posts · _data · _config.yml 을 꺼내 현재 check-posts.rb 에 넣고, exit 1 이면서 기대한 오류
# 문구가 나오는지 본다. 검사를 느슨하게 고치다가 과거 실수를 놓치게 되면 여기서 실패한다
# (12e0250 처럼 검사 자체를 고칠 때를 막는다).
#
# build-site.sh 가 CI 와 로컬에서 같이 부른다. 과거 커밋이 필요하므로 CI 는 fetch-depth: 0 이어야 한다.
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

# "<고친 커밋>@@<기대하는 오류 문구>@@<그 실수>" (오류 문구에 | 가 들어가서 구분자는 @@)
cases=(
  "d2d9793@@future: true 가 없다@@미래 date 포스트 누락 (093f2da, 1c05811, 0c867e2)"
  "b5baf93@@카테고리 'Backend'@@그룹 이름을 카테고리로 씀"
  "73c2415@@Trending 은 주간 roundup@@개별 리뷰에 Trending 을 붙임"
  "352f757@@slug 'trending-weekly' 가 중복@@주간 roundup slug 충돌"
  "3dc802a@@제목에 편 번호('[1/3]')가 있는데 series 가 없다@@시리즈 등록 누락 (Jev)"
  "6057f33@@제목에 편 번호('1일차')가 있는데 series 가 없다@@시리즈 등록 누락 (JUnit)"
  "7f8393f@@문장 속 | 때문에 헤더 없는 표가 됐다@@영상 제목의 | 가 표가 됨"
  "44fa571@@를 링크로만 걸었다@@유튜브 영상을 임베드하지 않고 링크로만 걺"
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
  git archive "$sha^" _posts _data _config.yml | tar -x -C "$dir"
  set +e
  out="$(bundle exec ruby .github/scripts/check-posts.rb "$dir" 2>&1)"
  code=$?
  set -e
  if [[ $code -ne 1 || "$out" != *"$want"* ]]; then
    echo "FAIL: $label — $sha^ 를 check-posts 가 못 잡는다 (exit $code, 기대 문구: '$want')" >&2
    failed=1
  fi
done

if [[ $failed -ne 0 ]]; then
  echo "check-posts 가 과거 실수를 놓친다. 검사를 고쳤다면 위 실수를 계속 잡도록 되돌린다." >&2
  exit 1
fi
echo "OK: test-check-posts (${#cases[@]} cases)"
