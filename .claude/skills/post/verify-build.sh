#!/usr/bin/env bash
# 발행 전 로컬 빌드 검증: verify-build.sh [--skip-proofer] <slug>
#
# 빌드와 검사는 CI 와 같은 .github/scripts/build-site.sh 로 한다(check-posts →
# production 빌드 --baseurl "" → htmlproofer). 여기서는 그 앞뒤로 포스트 파일이 있는지,
# 빌드 결과에 그 포스트의 <slug>/index.html 이 실제로 생겼는지만 더 본다 — Jekyll 은
# published: false 등으로 빠진 포스트를 빌드 성공(exit 0)인 채로 조용히 뺀다.
# (미래 date 는 _config.yml 의 future: true 로 발행되므로 따로 검사하지 않는다.)
#
# 건너뛰기는 --skip-proofer 또는 VERIFY_SKIP_PROOFER=1 로만 한다(WARN 을 남긴다).
# ruby 는 .ruby-version(CI 와 같은 버전)을 rbenv 로 쓴다.
set -euo pipefail

skip_proofer="${VERIFY_SKIP_PROOFER:-0}"
if [[ "${1:-}" == "--skip-proofer" ]]; then
  skip_proofer=1
  shift
fi

slug="${1:-}"
if [[ -z "$slug" || $# -gt 1 ]]; then
  echo "사용법: $0 [--skip-proofer] <slug>   (파일명 YYYY-MM-DD-<slug>.md 의 slug 부분)" >&2
  exit 2
fi

cd "$(git rev-parse --show-toplevel)"

# 시스템 ruby(2.6)로는 bundler 가 안 맞는다 → rbenv(.ruby-version)를 앞에 둔다.
export PATH="$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"

# 1) 포스트 파일 확인 (slug 중복은 build-site.sh 의 check-posts 가 잡는다)
shopt -s nullglob
files=(_posts/*/*-"$slug".md)
if (( ${#files[@]} == 0 )); then
  echo "FAIL: _posts/*/*-$slug.md 가 없다 (slug 오타? 파일 미생성?)" >&2
  exit 1
fi
post="${files[0]}"

# 2) CI 와 같은 빌드 + 검사. 전용 폴더(_site-verify, .gitignore 의 `_site*`)에 새로 빌드한다.
out="_site-verify"
proofer_args=()
[[ "$skip_proofer" == "1" ]] && proofer_args=(--skip-proofer)
if ! .github/scripts/build-site.sh ${proofer_args[@]+"${proofer_args[@]}"} "$out"; then
  echo "FAIL: build-site.sh 실패(위 출력). CI 도 같은 스크립트라 같은 이유로 배포를 막는다." >&2
  echo "      htmlproofer 목록의 경로가 /<루트 파일 이름>/ 이면 _config.yml exclude 에 그 파일이 빠졌는지 본다." >&2
  exit 1
fi

# 3) 산출물 확인: permalink(/:categories/:title/)의 카테고리 경로를 계산하지 않고 찾는다.
hits="$(find "$out" -path "*/$slug/index.html" 2>/dev/null || true)"
if [[ -z "$hits" ]]; then
  echo "FAIL: 빌드는 성공했지만 $out 에 <...>/$slug/index.html 이 없다." >&2
  echo "      published: false, categories 표기를 확인해라." >&2
  exit 1
fi

echo "OK: $post"
echo "$hits" | sed 's/^/  생성됨: /'
if [[ "$skip_proofer" == "1" ]]; then echo "  (htmlproofer 건너뜀)"; fi
echo "(CI 와 같은 스크립트로 통과했다. push 후에는 push-verify 로 CI 와 sitemap 을 확인)"
