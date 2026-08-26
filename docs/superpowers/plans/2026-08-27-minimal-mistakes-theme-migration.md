# Minimal Mistakes 테마 마이그레이션 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** redskelt.github.io를 `jekyll-theme-chirpy` gem 기반에서, `whdrns2013/whdrns2013.github.io`가 쓰는 Minimal Mistakes fork-and-customize 테마(레이아웃/사이드바/orbit/series/category-hierarchy 등 확장 기능 포함)로 완전히 교체한다.

**Architecture:** 대상 저장소(`whdrns2013/whdrns2013.github.io`)를 임시 클론해 테마 코어(`_layouts`, `_includes`, `_sass/minimal-mistakes`)와 커스텀 레이어(`_sass/custom/*`, `assets/js/custom/*`, 루트 커스텀 콘텐츠 페이지)를 vendor 방식으로 이 저장소에 복사한 뒤, `_config.yml`/`Gemfile`/사이드바 정보를 redskelt 값으로 재작성하고, 기존 포스트 front matter를 새 카테고리 계층 체계로 마이그레이션한다. chirpy 전용 파일은 마지막에 제거한다.

**Tech Stack:** Jekyll(github-pages gem 스택), Sass, Minimal Mistakes(vendored), giscus, Lunr 검색, GitHub Actions(`pages-deploy.yml` 유지)

**Spec:** `docs/superpowers/specs/2026-08-27-minimal-mistakes-theme-migration-design.md`

## Global Constraints

- 댓글 시스템은 giscus 유지 (repo/repo_id/category/category_id 값 기존 그대로 재사용).
- 검색 엔진은 Lunr로 교체.
- orbit/series-archive/category-hierarchy/post-neighborhood-map 기능은 전부 이식하되, 콘텐츠(카테고리 계층)는 redskelt 기존 주제(JUnit/Mockito/CSS/MathJax/Life/Wiki) 기준으로 재설계 — 대상의 Docs(LLM/RAG/MCP 등) 콘텐츠/네비게이션은 가져오지 않는다.
- 퍼머링크는 대상과 동일하게 `/:categories/:title/`로 변경 — 기존 giscus 댓글 스레드 연결 유실은 감수한다(사용자 승인 완료).
- Google Analytics ID는 대상 고유 값이므로 가져오지 않는다(제거 상태로 둔다).
- `_plugins/posts-lastmod-hook.rb`는 테마와 무관한 범용 Jekyll 훅이므로 그대로 유지한다.
- `.github/workflows/pages-deploy.yml`은 Ruby/Jekyll 빌드 방식 자체는 테마에 종속적이지 않으므로 원칙적으로 유지하되, Task 11에서 실제 빌드가 통과하는지 검증한다.

---

## File Structure

```
Gemfile                              [수정] chirpy gem → github-pages 스택
_config.yml                          [수정] 전면 재작성
assets/css/main.scss                 [생성] chirpy scss 대체, minimal-mistakes import 체계
_layouts/*.14개                       [생성] 대상에서 vendor
_includes/*.44개                      [생성] 대상에서 vendor
_sass/minimal-mistakes/*             [생성] 대상에서 vendor
_sass/custom/*.scss (15개)            [생성] 대상에서 vendor + 필요시 콘텐츠 조정
assets/js/custom/*.js                [생성] 대상에서 vendor
_data/navigation.yml                 [생성] redskelt 메뉴 구성
_data/contact.yml                    [삭제] chirpy _tabs 전용 → author.links로 대체
category-archive.md                  [생성] 루트 커스텀 페이지, redskelt 카테고리 계층 반영
year-archive.md                      [생성] 루트 커스텀 페이지
series-archive.md                    [생성] 루트 커스텀 페이지
tag-archive.md                       [생성] 루트 커스텀 페이지
orbit.md                             [생성] 루트 커스텀 페이지
diary.md                             [생성] 루트 커스텀 페이지
index.html                           [수정] layout: home → layout: home (minimal-mistakes 방식 유지 확인)
_data/category_hierarchy.yml         [생성] redskelt 카테고리 그룹 정의 (Task 9, Task 7 조사 결과 반영)
_posts/2017/2017-07-06-mathJax.md    [수정] chirpy 전용 math: true 필드 제거 (그 외 8개 포스트는 변경 없음)
_tabs/*                              [삭제] chirpy 전용 네비게이션
assets/css/jekyll-theme-chirpy.scss  [삭제]
```

---

### Task 1: 브랜치 생성 + 대상 저장소 vendor 소스 확보

**Files:**
- Create: `/tmp/mm-vendor/` (임시 클론, 저장소에 커밋되지 않음)

**Interfaces:**
- Produces: `/tmp/mm-vendor/whdrns2013.github.io/` — 이후 모든 태스크가 이 경로에서 파일을 복사해온다.

- [x] **Step 1: 새 브랜치 생성**

```bash
git checkout -b theme/minimal-mistakes-migration
```

- [x] **Step 2: 대상 저장소 얕은 클론**

```bash
rm -rf /tmp/mm-vendor && mkdir -p /tmp/mm-vendor
git clone --depth 1 https://github.com/whdrns2013/whdrns2013.github.io.git /tmp/mm-vendor/whdrns2013.github.io
```

- [x] **Step 3: 클론 확인**

Run: `ls /tmp/mm-vendor/whdrns2013.github.io/_layouts | wc -l`
Expected: `14` 근처 숫자 출력 (레이아웃 파일 존재 확인)

- [x] **Step 4: 커밋 불필요 (임시 파일이므로 스킵)**

`/tmp/mm-vendor`는 작업 저장소 밖이므로 git 상태에 영향 없음. 다음 태스크로 진행.

---

### Task 2: 테마 코어 파일 이식 (`_layouts`, `_includes`, `_sass/minimal-mistakes`)

**Files:**
- Create: `_layouts/*` (대상의 `_layouts/` 전체)
- Create: `_includes/*` (대상의 `_includes/` 전체)
- Create: `_sass/minimal-mistakes/*` (대상의 `_sass/minimal-mistakes/` 전체)

**Interfaces:**
- Consumes: Task 1의 `/tmp/mm-vendor/whdrns2013.github.io/`
- Produces: 이후 태스크(3~9)가 참조하는 minimal-mistakes 표준 레이아웃/인클루드/사스 트리

- [x] **Step 1: 디렉토리 복사**

```bash
SRC=/tmp/mm-vendor/whdrns2013.github.io
cp -R "$SRC/_layouts" ./_layouts
cp -R "$SRC/_includes" ./_includes
mkdir -p _sass
cp -R "$SRC/_sass/minimal-mistakes" ./_sass/minimal-mistakes
```

- [x] **Step 2: 복사 결과 확인**

Run: `find _layouts _includes _sass/minimal-mistakes -type f | wc -l`
Expected: 대상 저장소와 동일한 파일 개수(대략 `_layouts` 14 + `_includes` 44 + `_sass/minimal-mistakes` 내부 파일 수 합계)가 0보다 큰 값으로 출력됨. `find _layouts -type f | wc -l`이 `14`, `find _includes -type f | wc -l`이 `44` 근처인지 개별 확인.

- [x] **Step 3: 커밋**

```bash
git add _layouts _includes _sass/minimal-mistakes
git commit -m "feat: vendor minimal-mistakes theme core (layouts/includes/sass)"
```

---

### Task 3: 커스텀 scss 레이어 + `assets/css/main.scss` 이식

**Files:**
- Create: `_sass/custom/*.scss` (15개: `_home.scss`, `_masthead-terminal.scss`, `_sidebar-terminal.scss`, `_orbit.scss`, `_series.scss`, `_category-hierarchy.scss`, `_post-neighborhood-map.scss`, `_tag-archive.scss`, `_accordion.scss`, `_search-overlay.scss`, `_toc-toggle.scss`, `_readability.scss`, `_theme.scss`, `customImport.scss`, `customOverride.scss`)
- Create: `assets/css/main.scss`
- Delete: `assets/css/jekyll-theme-chirpy.scss`

**Interfaces:**
- Consumes: Task 2의 `_sass/minimal-mistakes`
- Produces: 사이트 전체 스타일 진입점 `assets/css/main.scss`

- [x] **Step 1: 커스텀 scss 디렉토리 복사**

```bash
SRC=/tmp/mm-vendor/whdrns2013.github.io
mkdir -p _sass/custom
cp -R "$SRC/_sass/custom/." ./_sass/custom/
```

- [x] **Step 2: `assets/css/main.scss` 작성**

```bash
mkdir -p assets/css
cat > assets/css/main.scss << 'EOF'
---
# Only the main Sass file needs front matter (the dashes are enough)
search: false
---

@charset "utf-8";

@import "minimal-mistakes/skins/{{ site.minimal_mistakes_skin | default: 'default' }}"; // skin
@import "minimal-mistakes"; // main partials

@import "custom/theme";
@import "custom/customImport";
@import "custom/customOverride";
@import "custom/masthead-terminal";
@import "custom/sidebar-terminal";
@import "custom/accordion";
@import "custom/search-overlay";
@import "custom/category-hierarchy";
@import "custom/tag-archive";
@import "custom/series";
@import "custom/orbit";
@import "custom/post-neighborhood-map";
@import "custom/toc-toggle";
@import "custom/readability";
@import "custom/home";
EOF
```

- [x] **Step 3: chirpy 전용 scss 삭제**

```bash
rm -f assets/css/jekyll-theme-chirpy.scss
```

- [x] **Step 4: 파일 존재 확인**

Run: `find _sass/custom -name "*.scss" | wc -l`
Expected: `15`

- [x] **Step 5: 커밋**

```bash
git add _sass/custom assets/css/main.scss
git rm --cached assets/css/jekyll-theme-chirpy.scss 2>/dev/null || true
rm -f assets/css/jekyll-theme-chirpy.scss
git add -A assets/css
git commit -m "feat: vendor custom scss layer, replace chirpy stylesheet entrypoint"
```

---

### Task 4: 커스텀 JS 이식

**Files:**
- Create: `assets/js/custom/theme-toggle.js`
- Create: `assets/js/custom/copy-code.js`
- Create: `assets/js/custom/toc-toggle.js`
- Create: `assets/js/custom/sidebar-toggle.js`
- Create: `assets/js/custom/archive-filter.js`
- Create: `assets/js/custom/doc-chip-color.js`
- Create: `assets/js/custom/toc-scrollspy.js`
- Create: `assets/js/custom/search-overlay.js`

**Interfaces:**
- Consumes: Task 1의 vendor 소스
- Produces: `_config.yml`의 `after_footer_scripts`(Task 6)가 참조하는 스크립트 경로

- [x] **Step 1: 디렉토리 복사**

```bash
SRC=/tmp/mm-vendor/whdrns2013.github.io
mkdir -p assets/js/custom
cp -R "$SRC/assets/js/custom/." ./assets/js/custom/
```

`docs-deeplink.js`는 대상의 Docs(LLM/RAG/MCP) 전용 기능이라 이번 이식 범위(Global Constraints)에서 제외한다 — 복사되어 있으면 삭제:

```bash
rm -f assets/js/custom/docs-deeplink.js
```

- [x] **Step 2: 확인**

Run: `ls assets/js/custom/`
Expected: `archive-filter.js  copy-code.js  search-overlay.js  sidebar-toggle.js  theme-toggle.js  toc-scrollspy.js  toc-toggle.js` (그리고 `doc-chip-color.js`가 있으면 유지, 없으면 생략 — Task 6에서 `after_footer_scripts` 목록을 실제 존재하는 파일에 맞춘다)

- [x] **Step 3: 커밋**

```bash
git add assets/js/custom
git commit -m "feat: vendor custom js (theme toggle, toc, sidebar, search overlay)"
```

---

### Task 5: `Gemfile` 교체

**Files:**
- Modify: `Gemfile`

**Interfaces:**
- Consumes: 없음
- Produces: `bundle install`이 설치할 gem 목록 (Task 11에서 사용)

- [x] **Step 1: `Gemfile` 전체 재작성**

```ruby
source "https://rubygems.org"

# 대상(whdrns2013.github.io)과 동일한 github-pages 빌드 스택.
# 이 저장소는 테마 gem 자체가 아니라 vendored 파일을 쓰므로
# "gemspec"(자기 자신을 gem으로 등록하는 줄)은 사용하지 않는다.
gem "github-pages", "228", group: :jekyll_plugins
gem "jekyll-paginate"
gem "jekyll-sitemap"
gem "jekyll-gist"
gem "jekyll-feed"
gem "jekyll-include-cache"
gem "kramdown-parser-gfm"
gem "webrick", "~> 1.8"

group :test do
  gem "html-proofer", "~> 5.0"
end

platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end
```

- [x] **Step 2: `bundle install` 실행**

```bash
bundle install
```

Expected: 에러 없이 `Gemfile.lock` 갱신됨. `jekyll (3.9.3)` 라인이 `Gemfile.lock`에 포함되는지 확인.

만약 `github-pages 228`이 현재 로컬 Ruby 버전(`.ruby-version` 확인)과 충돌해 resolve 실패하면, Task 11에서 다시 다룬다 — 이번 Step은 `bundle install` 결과를 있는 그대로 기록해두고 다음 태스크로 진행.

- [x] **Step 3: 커밋**

```bash
git add Gemfile Gemfile.lock
git commit -m "feat: switch Gemfile from jekyll-theme-chirpy to github-pages stack"
```

---

### Task 6: `_config.yml` 재작성

**Files:**
- Modify: `_config.yml`

**Interfaces:**
- Consumes: Task 4의 `after_footer_scripts` 파일 목록, Task 7의 `_data/navigation.yml`(아직 생성 전이지만 이 태스크에서 참조 경로만 지정)
- Produces: `site.author`, `site.comments`, `site.search_provider` 등 이후 레이아웃/인클루드가 참조하는 사이트 변수

- [x] **Step 1: `_config.yml` 전체 재작성**

```yaml
# 로컬 vendored _layouts/_includes/_sass가 우선 적용되지만,
# _data/ui-text.yml 등 vendor하지 않은 gem 기본 제공 파일은
# remote_theme을 통해 fallback으로 공급받는다 (대상 저장소와 동일 패턴).
remote_theme              : "mmistakes/minimal-mistakes"
minimal_mistakes_skin    : "default"

locale                   : "ko-KR"
title                    : "redskelt's Blog"
title_separator          : "-"
subtitle                  : "redskelt's personal blog and articles."
name                      : "redskelt"
description               : "redskelt's personal blog and articles."
url                       : "https://redskelt.github.io"
baseurl                   :
repository                : "redskelt/redskelt.github.io"
teaser                    :
logo                      :
masthead_title            :
words_per_minute          : 200

comments:
  provider               : "giscus"
  giscus:
    repo                 : "redskelt/redskelt.github.io"
    repo_id              : "MDEwOlJlcG9zaXRvcnk5NDQyNzE0NQ=="
    category              : "Announcements"
    category_id           : "DIC_kwDOBaDYCc4DDn9v"

search                   : true
search_full_content      : false
search_provider          : "lunr"
lunr:
  search_within_pages    : true

analytics:
  provider               : false

author:
  name             : "redskelt"
  avatar           : "/assets/img/avatar.jpg"
  bio              : "redskelt's personal blog and articles."
  location         :
  email            :
  links:
    - label: "GitHub"
      icon: "fab fa-fw fa-github"
      url: "https://github.com/redskelt"

footer:
  links:
    - label: "GitHub"
      icon: "fab fa-fw fa-github"
      url: "https://github.com/redskelt"

include:
  - .htaccess
exclude:
  - "*.gem"
  - "*.gemspec"
  - docs
  - tools
  - README.md
  - LICENSE
  - wiki
  - vendor
  - .asset-cache
  - .bundle
  - .jekyll-assets-cache
  - .sass-cache
  - assets/js/plugins
  - assets/js/_main.js
  - assets/js/vendor
  - Gemfile
  - node_modules
  - package.json
  - package-lock.json
keep_files:
  - .git
  - .svn
encoding: "utf-8"
markdown_ext: "markdown,mkdown,mkdn,mkd,md"

markdown: kramdown
highlighter: rouge
lsi: false
excerpt_separator: "\n\n"
incremental: false

kramdown:
  input: GFM
  hard_wrap: false
  auto_ids: true
  footnote_nr: 1
  entity_output: as_char
  toc_levels: 1..6
  smart_quotes: lsquo,rsquo,ldquo,rdquo
  enable_coderay: false
  syntax_highlighter: rouge
  syntax_highlighter_opts:
    block:
      line_numbers: true

sass:
  sass_dir: _sass
  style: compressed
  cache: false

permalink: /:categories/:title/
paginate: 12
paginate_path: /page:num/
timezone: Asia/Seoul

plugins:
  - jekyll-paginate
  - jekyll-sitemap
  - jekyll-gist
  - jekyll-feed
  - jekyll-include-cache
  - jekyll-remote-theme

whitelist:
  - jekyll-paginate
  - jekyll-sitemap
  - jekyll-gist
  - jekyll-feed
  - jekyll-include-cache
  - jekyll-remote-theme

category_archive:
  type: liquid
  path: /categories/
tag_archive:
  type: liquid
  path: /tags/

compress_html:
  clippings: all
  ignore:
    envs: development

defaults:
  - scope:
      path: ""
      type: posts
    values:
      layout: single
      show_date: true
      author_profile: true
      read_time: true
      comments: true
      share: true
      related: true
      toc: true
      toc_sticky: true

dark_theme_toggle        : true
after_footer_scripts:
  - /assets/js/custom/theme-toggle.js
  - /assets/js/custom/copy-code.js
  - /assets/js/custom/toc-toggle.js
  - /assets/js/custom/sidebar-toggle.js
  - /assets/js/custom/archive-filter.js
  - /assets/js/custom/doc-chip-color.js
  - /assets/js/custom/toc-scrollspy.js
  - /assets/js/custom/search-overlay.js
```

`remote_theme`은 위 블록 맨 위에 유지한다 — vendored된 `_layouts`/`_includes`/`_sass`는 로컬 파일이 우선 적용되지만, vendor하지 않은 `_data/ui-text.yml` 등 gem 기본 제공 파일은 이 fallback을 통해 정상 로드된다(대상 저장소도 동일 패턴 사용).

- [x] **Step 2: `after_footer_scripts` 목록을 Task 4 결과와 맞춤**

Task 4에서 `docs-deeplink.js`를 삭제했으니 위 목록에는 원래부터 포함하지 않았다. Task 4에서 `doc-chip-color.js`가 실제로 존재하지 않는 것으로 확인됐다면 이 목록에서도 해당 줄을 제거한다.

```bash
for f in theme-toggle copy-code toc-toggle sidebar-toggle archive-filter doc-chip-color toc-scrollspy search-overlay; do
  [ -f "assets/js/custom/$f.js" ] || echo "MISSING: $f.js — _config.yml에서 제거할 것"
done
```

- [x] **Step 3: 커밋**

```bash
git add _config.yml
git commit -m "feat: rewrite _config.yml for minimal-mistakes (redskelt values, giscus, lunr)"
```

---

### Task 7: 커스텀 콘텐츠 타입 페이지 + 내비게이션 이식

**Files:**
- Create: `category-archive.md`
- Create: `year-archive.md`
- Create: `series-archive.md`
- Create: `tag-archive.md`
- Create: `orbit.md`
- Create: `diary.md`
- Create: `_data/navigation.yml`
- Modify: `index.html`

**Interfaces:**
- Consumes: Task 6의 `_config.yml`(permalink 구조), Task 3의 category-hierarchy/series/orbit scss
- Produces: 최상위 내비게이션이 가리키는 실제 페이지들

- [x] **Step 1: 루트 커스텀 페이지 복사**

```bash
SRC=/tmp/mm-vendor/whdrns2013.github.io
for f in category-archive.md year-archive.md series-archive.md tag-archive.md orbit.md diary.md; do
  cp "$SRC/$f" "./$f"
done
```

- [x] **Step 2: `_data/navigation.yml` 작성 (Docs 항목 제외)**

```yaml
main:
  - title: "Home"
    url: /
  - title: "Categories"
    url: /categories/
  - title: "Archive"
    url: /year-archive/
  - title: "Series"
    url: /series/
  - title: "Orbit"
    url: /orbit/
  - title: "Diary"
    url: /diary/
```

- [x] **Step 3: `index.html` 확인/수정**

```bash
cat > index.html << 'EOF'
---
layout: home
author_profile: true
---
EOF
```

- [x] **Step 4: 각 페이지의 front matter가 새 permalink/레이아웃과 맞는지 확인**

Run: `head -n 10 category-archive.md year-archive.md series-archive.md tag-archive.md orbit.md diary.md`
Expected: 각 파일에 `layout:`, `permalink:` front matter가 있고 대상 고유 문구(예: "Jongya") 없이 구조만 담겨 있는지 확인. 만약 본문에 대상 고유 소개 문구가 있으면 이 Step에서 지운다(레이아웃/기능 코드는 그대로 두고 텍스트만 제거).

- [x] **Step 5: 커밋**

```bash
git add category-archive.md year-archive.md series-archive.md tag-archive.md orbit.md diary.md _data/navigation.yml index.html
git commit -m "feat: add minimal-mistakes custom content pages and navigation"
```

---

### Task 8: 사이드바/프로필 개인화

**Files:**
- Modify: `_config.yml` (Task 6에서 이미 author 블록 redskelt화 완료 — 이 태스크는 아바타 이미지 파일 자체를 다룸)
- Delete: `_data/contact.yml`

**Interfaces:**
- Consumes: Task 6의 `_config.yml` author 블록
- Produces: 없음 (터미널 사이드바 include가 `site.author`를 그대로 참조하므로 별도 산출물 없음)

- [x] **Step 1: 아바타 경로 확인**

`_config.yml`의 `author.avatar`는 `/assets/img/avatar.jpg`로 이미 지정했다(Task 6). 기존 파일이 그대로 있는지 확인:

Run: `ls assets/img/avatar.jpg`
Expected: 파일 존재 (기존 chirpy 시절 파일 그대로 재사용)

- [x] **Step 2: chirpy 전용 `_data/contact.yml` 삭제**

minimal-mistakes 사이드바는 `site.author.links`(Task 6에서 이미 설정)를 쓰므로 chirpy 전용 `_data/contact.yml`은 더 이상 필요 없다.

```bash
git rm _data/contact.yml
```

- [x] **Step 3: 커밋**

```bash
git commit -m "chore: remove chirpy-only contact data, confirm avatar asset reuse"
```

---

### Task 9: 카테고리 계층 데이터 생성 + 기존 포스트 front matter 정리

> **PLAN REVISION (Task 7 조사 결과 반영, 원래 계획 대체):** Task 7 구현자가 실제 vendor 소스를 조사한 결과, minimal-mistakes의 카테고리 계층은 `categories:` 배열의 순서/개수로 표현되는 게 아니라 **`_data/category_hierarchy.yml`이라는 별도 데이터 파일**이 "그룹(key/main_title/sub_title) → 그 그룹에 속한 leaf 카테고리 이름 목록"을 정의하고, `_layouts/categories.html`/`_includes/category-list.html`이 포스트의 flat `categories:` 이름을 이 파일과 문자열 매칭해서 그룹핑한다(근거: `_layouts/categories.html:7-41`, `_includes/category-list.html:14-30`, Task 7 보고서). 이 파일은 vendor 대상에도 있었지만(대상 고유 주제인 Language/AI/Database 등) Task 7의 Files 목록엔 없어서 아직 이 저장소에 없다. 아래는 그 사실을 반영한 새 설계이며, 원래 있던 "categories 배열을 `[개발, 테스트]`처럼 2단계로 바꾸는" 설계는 틀린 전제였으므로 폐기한다.

**Files:**
- Create: `_data/category_hierarchy.yml` (redskelt 카테고리 그룹 정의, 신규)
- Modify: `_posts/2017/2017-07-06-mathJax.md` (chirpy 전용 `math: true` 필드 제거)

다른 8개 포스트(`_posts/2017/2017-06-19-junit01.md` ~ `2017-06-23-junit05.md`, `2017-06-17-workblog.md`, `2021-07-31-gruntImageSprite.md`, `2026-08-18-idempotency.md`)는 **front matter 변경 불필요** — `layout:` 필드가 애초에 없어 Task 6의 `defaults`(layout: single)가 그대로 적용되고, 기존 `categories:`/`tags:` 값(`JUnit`, `Mockito`, `Life`, `CSS`, `Wiki`, `HTTP`, `분산시스템`)이 그대로 leaf 카테고리 이름으로 쓰인다.

**Interfaces:**
- Consumes: Task 6의 `defaults`(layout: single 등), Task 7의 `category-archive.md`/`_layouts/categories.html`이 참조하는 `site.data.category_hierarchy` 구조
- Produces: `/categories/`, `/:categories/:title/` 퍼머링크에서 정상적으로 그룹핑되어 보이는 카테고리 뷰 (Task 11 빌드 검증에서 사용)

**카테고리 그룹 설계** (redskelt 기존 9개 포스트의 실제 `categories:` 값 기준 — 값 자체는 바꾸지 않고, 이 값들을 leaf로 갖는 그룹만 새로 정의):

| 그룹 `key`/`main_title` | 포함 leaf 카테고리 (기존 포스트 `categories:` 값 그대로) |
|---|---|
| `testing` / Testing | `JUnit`, `Mockito` |
| `web` / Web | `CSS`, `MathJax` |
| `wiki` / Wiki | `Wiki` |
| `life` / Life | `Life` |

- [x] **Step 1: `_data/category_hierarchy.yml` 작성**

대상 저장소의 스키마(`key`/`main_title`/`sub_title` + `categories[].name`/`sub_title`)를 그대로 따르되, 그룹과 leaf는 redskelt 콘텐츠 기준으로 새로 구성한다:

```yaml
- key: testing
  main_title: Testing
  sub_title: 테스트
  categories:
    - name: JUnit
      sub_title: 단위 테스트 프레임워크
    - name: Mockito
      sub_title: 모킹 프레임워크

- key: web
  main_title: Web
  sub_title: 웹 개발
  categories:
    - name: CSS
      sub_title: 스타일시트
    - name: MathJax
      sub_title: 수식 렌더링

- key: wiki
  main_title: Wiki
  sub_title: 기술 위키 노트
  categories:
    - name: Wiki
      sub_title: 위키 정리 노트

- key: life
  main_title: Life
  sub_title: 일상
  categories:
    - name: Life
      sub_title: 일상 기록
```

- [x] **Step 2: 모든 포스트의 `categories:` 값이 이 파일의 leaf 이름과 정확히 일치하는지 확인**

Run: `grep -h "^categories:" _posts/**/*.md | sort -u`
Expected: `[CSS]`, `[JUnit, Mockito]`, `[Life]`, `[MathJax]`, `[Wiki]` — 5개 라인. 이 중 어떤 이름도 Step 1의 `_data/category_hierarchy.yml`에 없는 이름이면 안 된다(문자열 정확히 일치, 대소문자 구분). 불일치가 있으면 `_data/category_hierarchy.yml` 쪽을 실제 포스트 값에 맞게 고쳐라(포스트 파일은 되도록 건드리지 않는다 — 기존 URL/데이터 보존 우선).

- [x] **Step 3: `mathJax.md`의 chirpy 전용 필드 제거**

`math: true`는 chirpy의 MathJax 옵트인 필드로 minimal-mistakes에서는 아무 효과가 없는 죽은 키다. 제거한다:

```yaml
---
title:  "수식 표현 MathJax"
date:   2017-07-02 23:50:02 +0900
categories: [MathJax]
---
```

(MathJax 실제 렌더링 스크립트 삽입 여부는 이번 계획 범위 밖 — Task 11에서 수식이 깨지는지만 육안 확인하고, 깨지면 별도 이슈로 기록)

- [x] **Step 4: 커밋**

```bash
git add _data/category_hierarchy.yml _posts/2017/2017-07-06-mathJax.md
git commit -m "content: add redskelt category hierarchy data, drop chirpy-only math field"
```

---

### Task 10: chirpy 레거시 파일 정리

**Files:**
- Delete: `_tabs/about.md`
- Delete: `_tabs/archives.md`
- Delete: `_tabs/categories.md`
- Delete: `_tabs/projects.md`
- Delete: `_tabs/tags.md`

**Interfaces:**
- Consumes: 없음
- Produces: 없음 (정리 태스크)

- [x] **Step 1: `_tabs/` 삭제**

minimal-mistakes는 `_tabs`를 쓰지 않고 루트 커스텀 페이지(Task 7)+`_data/navigation.yml`로 대체했으므로 전체 삭제:

```bash
git rm -r _tabs
```

`_tabs/about.md`, `_tabs/projects.md`의 본문 내용(소개글, 프로젝트 목록)이 필요하면 이 Step 전에 내용을 확인해 `diary.md`나 별도 페이지로 옮길지 판단한다 — 이번 계획 범위에서는 about/projects 본문 이관은 포함하지 않는다(범위 밖, 스펙에 명시 없음).

- [x] **Step 2: 확인**

Run: `ls _tabs 2>&1`
Expected: `No such file or directory`

- [x] **Step 3: 커밋**

```bash
git commit -m "chore: remove chirpy _tabs (superseded by minimal-mistakes navigation)"
```

---

### Task 11: 빌드 및 수동 검증

**Files:**
- (검증 태스크 — 파일 변경 없음, 문제 발견 시 이전 태스크로 돌아가 수정)

**Interfaces:**
- Consumes: Task 1~10의 전체 산출물

- [x] **Step 1: 클린 빌드**

```bash
bundle exec jekyll build
```

Expected: `_site/` 생성, 에러 없음. `Liquid Exception`이나 `Sass::SyntaxError`가 나오면 해당 include/scss 파일명을 확인해 Task 2~4로 돌아가 누락된 vendor 파일이 없는지 재확인.

- [x] **Step 2: 로컬 서버 기동**

```bash
bundle exec jekyll serve
```

- [x] **Step 3: 육안 확인 체크리스트**

다음을 브라우저에서 직접 확인:
- [x] 홈(`/`) — 사이드바(아바타, redskelt, GitHub 링크), 다크모드 토글, 검색 아이콘 표시
- [x] 포스트 9개 전부 `/:categories/:title/` 형태 URL로 정상 렌더링 (예: `/JUnit/jUnit과-Mockito를-이용한-단위테스트-기초-1일차/` 형태 — 한글 제목이 URL 인코딩되어도 404 없이 열리는지)
- [x] `mathJax.md` 포스트에서 수식이 깨지지 않는지 (깨지면 별도 이슈로 기록, 이번 계획 범위 밖 처리 가능)
- [x] `/categories/` — Testing(JUnit/Mockito) / Web(CSS/MathJax) / Wiki / Life 그룹 정상 표시
- [x] `/year-archive/`, `/series/`, `/orbit/`, `/diary/` — 에러 없이 로드(콘텐츠가 비어 있어도 404만 아니면 통과)
- [x] 검색창에 "JUnit" 입력 시 Lunr 검색 결과에 junit 포스트들이 뜨는지
- [x] giscus 댓글 위젯이 포스트 하단에 로드되는지 (실제 스레드 연결 여부는 배포 후 확인 — 로컬에서는 위젯 로드만 확인)

- [x] **Step 4: htmlproofer 실행**

```bash
bundle exec htmlproofer _site --disable-external --ignore-urls "/^http:\/\/127.0.0.1/,/^http:\/\/0.0.0.0/,/^http:\/\/localhost/"
```

Expected: 에러 없음. 깨진 내부 링크(특히 `_tabs` 삭제로 인한 잔여 링크)가 있으면 원인 파일 찾아 수정.

- [x] **Step 5: `.ruby-version` / Ruby 호환성 확인**

```bash
cat .ruby-version
ruby -v
```

`github-pages 228`이 요구하는 Ruby 버전과 로컬 `.ruby-version`이 맞는지 확인. `bundle install`(Task 5)이나 `jekyll build`(Step 1)에서 이미 에러가 없었다면 이 Step은 기록용으로만 확인.

- [x] **Step 6: 최종 커밋 (필요시)**

Step 1~5에서 수정한 내용이 있다면:

```bash
git add -A
git commit -m "fix: resolve build/verification issues found during migration testing"
```

없다면 이 Step은 스킵.

---

## 완료 후 남은 작업 (이 계획 범위 밖, 스펙의 Out of Scope와 동일)

- Google Analytics 재설정
- wiki-ingest 스킬 템플릿의 front matter 포맷 갱신 (Task 9의 카테고리 계층 규칙 반영 필요 — 별도 이슈)
- 배포 후 giscus 댓글 스레드 연결 상태 확인
