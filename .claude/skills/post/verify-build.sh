#!/usr/bin/env bash
# 발행 전 로컬 빌드 검증: verify-build.sh <slug>
#
# Jekyll 은 date 가 빌드 시각보다 미래인 포스트를 빌드 성공(exit 0)인 채로 조용히
# 발행 목록에서 뺀다. 그래서 "빌드 성공"만 믿지 않고 _site 에 그 포스트의
# <slug>/index.html 이 실제로 생겼는지까지 확인한다.
#
# 주의: 로컬 그린 ≠ CI 그린. CI 는 ruby 3.4 + htmlproofer 라 로컬(ruby 3.3)에서
# 재현 안 되는 문제가 있었다. 이 스크립트는 push 전 사전 점검일 뿐이다.
set -euo pipefail

slug="${1:-}"
if [[ -z "$slug" ]]; then
  echo "사용법: $0 <slug>   (파일명 YYYY-MM-DD-<slug>.md 의 slug 부분)" >&2
  exit 2
fi

cd "$(git rev-parse --show-toplevel)"

# 시스템 ruby(2.6)로는 bundler 가 안 맞는다 → rbenv 의 ruby 3.3+ 를 앞에 둔다.
export PATH="$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"

# 1) 포스트 파일 확인 (없음 / slug 중복)
shopt -s nullglob
files=(_posts/*/*-"$slug".md)
if (( ${#files[@]} == 0 )); then
  echo "FAIL: _posts/*/*-$slug.md 가 없다 (slug 오타? 파일 미생성?)" >&2
  exit 1
fi
if (( ${#files[@]} > 1 )); then
  echo "FAIL: slug '$slug' 가 중복이다 — permalink 가 충돌해 한쪽이 덮어써진다:" >&2
  printf '  %s\n' "${files[@]}" >&2
  exit 1
fi
post="${files[0]}"

# 2) date 가 지금보다 과거인지 (front matter 의 첫 date: 줄)
date_line="$(awk '/^---[[:space:]]*$/{n++; next} n==1 && /^date:/{sub(/^date:[[:space:]]*/,""); print; exit}' "$post")"
if [[ -z "$date_line" ]]; then
  echo "FAIL: $post front matter 에 date: 가 없다" >&2
  exit 1
fi
if ! ruby -rtime -e 'exit(Time.parse(ARGV[0]) <= Time.now ? 0 : 1)' "$date_line"; then
  echo "FAIL: date '$date_line' 가 현재 시각($(date '+%Y-%m-%d %H:%M:%S %z'))보다 미래다." >&2
  echo "      Jekyll 이 이 포스트를 조용히 발행에서 뺀다. 지금 시각 이전으로 고쳐라." >&2
  exit 1
fi

# 3) 빌드 — 예전 _site 가 남아 있어 오판하지 않도록 전용 폴더(_site-verify, .gitignore 의
#    `_site*` 에 걸린다)를 비우고 새로 빌드한다.
out="_site-verify"
rm -rf "$out"
bundle exec jekyll build --destination "$out"

# 4) 산출물 확인: permalink(/:categories/:title/)의 카테고리 경로를 계산하지 않고 찾는다.
hits="$(find "$out" -path "*/$slug/index.html" 2>/dev/null || true)"
if [[ -z "$hits" ]]; then
  echo "FAIL: 빌드는 성공했지만 $out 에 <...>/$slug/index.html 이 없다." >&2
  echo "      date(미래 여부·타임존), published: false, categories 표기를 확인해라." >&2
  exit 1
fi

echo "OK: $post"
echo "$hits" | sed 's/^/  생성됨: /'
echo "(로컬 통과일 뿐 CI 통과는 아니다 — push 후 push-verify 로 CI 와 sitemap 을 확인)"
