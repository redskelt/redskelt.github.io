#!/usr/bin/env bash
# 사이트 빌드 + 검사: .github/scripts/build-site.sh [--skip-proofer] <출력 폴더>
#
# CI(.github/workflows/pages-deploy.yml)와 로컬(.claude/skills/post/verify-build.sh)이
# 같은 이 스크립트를 부른다. 빌드 옵션·검사 옵션은 여기서만 바꾼다 — 로컬과 CI 가
# 따로 빌드하다가 로컬 그린 · CI 레드가 반복됐다(53f12f1 ruby 버전, 3d6553b baseurl).
# ruby 버전은 .ruby-version 하나로 정한다(CI 의 setup-ruby 도 그 파일을 읽는다).
#
# --skip-proofer 는 로컬 전용 비상구다. CI 는 이 옵션 없이 부른다.
set -euo pipefail

skip_proofer=0
if [[ "${1:-}" == "--skip-proofer" ]]; then
  skip_proofer=1
  shift
fi
out="${1:?사용법: $0 [--skip-proofer] <출력 폴더>}"

cd "$(git rev-parse --show-toplevel)"

# 1) front matter 검사(카테고리 · 시리즈 · slug · 표 · future 설정)
bundle exec ruby .github/scripts/check-posts.rb
#    그 검사가 과거 실수를 계속 잡는지 다시 확인한다(검사를 고치다 느슨해지는 것을 막는다).
.github/scripts/test-check-posts.sh
#    커밋 이메일이 모두 GitHub noreply 인지(공개 이력에 회사 · 개인 메일이 남지 않게)와 그 검사의 시험
.github/scripts/check-commit-identity.sh
.github/scripts/test-check-commit-identity.sh

# 2) 빌드 — 배포와 같은 production 환경. user page 라 항상 루트(/)에서 서빙되므로
#    --baseurl "" 로 강제한다(configure-pages 의 base_path 가 예상 밖 값을 낼 때 대비).
rm -rf "$out"
JEKYLL_ENV=production bundle exec jekyll build --destination "$out" --baseurl ""

# 3) htmlproofer — 외부 링크는 검사하지 않는다(네트워크를 타지 않음).
if [[ "$skip_proofer" == "1" ]]; then
  echo "WARN: htmlproofer 를 건너뛴다(--skip-proofer). CI 에서는 그대로 검사한다." >&2
  exit 0
fi
bundle exec htmlproofer "$out" \
  --disable-external \
  --ignore-urls "/^http:\/\/127.0.0.1/,/^http:\/\/0.0.0.0/,/^http:\/\/localhost/"
