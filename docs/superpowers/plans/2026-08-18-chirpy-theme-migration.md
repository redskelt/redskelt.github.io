# Chirpy 테마 마이그레이션 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `redskelt.github.io`의 커스텀 Jekyll 테마(Bootstrap 3 + jQuery 1.11 +
Super Search)를 [jekyll-theme-chirpy](https://github.com/cotes2020/jekyll-theme-chirpy)
Starter 방식(gem 기반)으로 완전히 교체한다.

**Architecture:** 기존 저장소를 그대로 재구성한다. `Gemfile`에
`jekyll-theme-chirpy` gem을 추가하고, `_config.yml`/`.github/workflows/*`를
Chirpy Starter 표준 파일로 교체하며, 구 테마의 `_layouts`/`_includes`/`_sass`
및 관련 static 자산을 삭제한다. 콘텐츠(포스트 8개, About, Projects)는
Chirpy의 포맷(`_tabs/`, front matter 옵션)에 맞춰 이관한다.

**Tech Stack:** Jekyll 4.x (선행 작업에서 이미 적용됨), Ruby 3.3.0,
jekyll-theme-chirpy (~> 7.6), GitHub Actions (Pages 배포), Giscus (댓글)

**Spec:** `docs/superpowers/specs/2026-08-18-chirpy-theme-migration-design.md`

## Global Constraints

- Ruby 3.3.0 사용 (선행 작업에서 `.ruby-version`에 이미 고정됨). 이 값을
  절대 낮추지 않는다.
- 브랜치는 `theme/chirpy-migration` (이미 체크아웃된 상태, 스펙 커밋 포함됨).
  이 플랜의 모든 커밋은 이 브랜치 위에서 이어간다.
- `jekyll-theme-chirpy`는 `~> 7.6` 버전 고정 (Chirpy Starter 공식 Gemfile 기준).
- 기존 카테고리 기반 permalink(`/junit/mockito/2017/...`)는 전부 폐기하고
  Chirpy 기본 permalink(`/posts/:title/`)로 통일한다. 리다이렉트는 만들지
  않는다 (스펙의 Out of Scope 항목).
- Google Analytics는 이 플랜 범위에서 다루지 않는다 (스펙에서 제거 결정됨).
- Giscus의 `repo_id`/`category_id`는 GitHub 저장소 쪽 설정(Discussions 활성화,
  giscus 앱 설치) 이후에만 발급되므로, 이 플랜에서는 `_config.yml`에 빈 값으로
  남겨둔다. 실제 값 채우기는 플랜 범위 밖.
- `_config.yml`의 `social.name`은 `redskelt`, `social.email`은 빈 값으로 둔다
  (사용자 확인 완료).

---

### Task 1: Gemfile을 Chirpy용으로 교체

**Files:**
- Modify: `Gemfile`
- Modify (재생성): `Gemfile.lock`

**Interfaces:**
- Produces: `bundle exec jekyll` 커맨드가 Chirpy gem을 인식하는 상태.
  이후 모든 태스크가 이 Gemfile 기준으로 빌드된다.

- [ ] **Step 1: Gemfile을 Chirpy Starter 공식 내용으로 교체**

`Gemfile` 전체를 다음 내용으로 덮어쓴다:

```ruby
source "https://rubygems.org"

# Hello! This is where you manage which Jekyll version is used to run.
# When you want to use a different version, change it below, save the
# file and run `bundle install`.
gem "jekyll-theme-chirpy", "~> 7.6"

group :test do
  gem "html-proofer", "~> 5.0"
end

platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end

gem "wdm", "~> 0.2.0", :platforms => [:mingw, :x64_mingw]
```

- [ ] **Step 2: 기존 `Gemfile.lock` 삭제 후 재생성**

```bash
export PATH="$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
rm -f Gemfile.lock
bundle install
```

Expected: `Bundle complete!` 메시지, `jekyll-theme-chirpy` 및 그 의존 gem
(jekyll-paginate, jekyll-archives, jekyll-sitemap, jekyll-feed,
jekyll-seo-tag, jekyll-redirect-from 등)이 설치 로그에 나열됨.

- [ ] **Step 3: 커밋**

```bash
git add Gemfile Gemfile.lock
git commit -m "chore: switch Gemfile to jekyll-theme-chirpy"
```

---

### Task 2: Chirpy 뼈대 도입 + 구 테마 전체 제거

**Files:**
- Modify: `_config.yml` (전면 교체)
- Modify: `index.html` (전면 교체)
- Create: `_plugins/posts-lastmod-hook.rb`
- Create: `_tabs/categories.md`
- Create: `_tabs/tags.md`
- Create: `_tabs/archives.md`
- Create: `.github/workflows/pages-deploy.yml`
- Delete: `.github/workflows/jekyll.yml` (선행 작업에서 만든 임시 워크플로우)
- Delete: `_layouts/` (디렉토리 전체)
- Delete: `_includes/` (디렉토리 전체)
- Delete: `_sass/` (디렉토리 전체)
- Delete: `category/` (디렉토리 전체 — 수동 카테고리 페이지)
- Delete: `feed.xml`
- Delete: `sitemap.xml`
- Delete: `static/js/super-search.js`
- Delete: `static/js/thickbox-compressed.js`
- Delete: `static/js/bootstrap.min.js`
- Delete: `static/css/bootstrap.min.css`
- Delete: `static/css/thickbox.css`
- Delete: `static/css/super-search.css`
- Delete: `static/css/projects.css`
- Delete: `static/css/main.css`
- Delete: `static/css/syntax.css`
- Delete: `projects.md`
- Delete: `_project/` (디렉토리 전체)
- Delete: `_data/projects.json`

**Interfaces:**
- Consumes: Task 1에서 설치된 `jekyll-theme-chirpy` gem
- Produces: `bundle exec jekyll build`가 Chirpy 기본 홈페이지를 생성하는
  상태. `_tabs/about.md`, `_tabs/projects.md`는 아직 없으므로 이 태스크
  단계에서는 사이드바에 Categories/Tags/Archives만 보이면 된다 (About/
  Projects는 Task 3에서 추가).

- [ ] **Step 1: 구 테마 파일/디렉토리 삭제**

```bash
cd /Users/mingyeongho/Documents/git-repositories/redskelt.github.io
rm -rf _layouts _includes _sass category
rm -f feed.xml sitemap.xml
rm -f static/js/super-search.js static/js/thickbox-compressed.js static/js/bootstrap.min.js
rm -f static/css/bootstrap.min.css static/css/thickbox.css static/css/super-search.css \
      static/css/projects.css static/css/main.css static/css/syntax.css
rm -f projects.md
rm -rf _project
rm -f _data/projects.json
```

- [ ] **Step 2: `_config.yml`을 Chirpy 포맷으로 전면 교체**

`_config.yml` 전체를 다음 내용으로 덮어쓴다:

```yaml
theme: jekyll-theme-chirpy

lang: ko-KR

timezone: Asia/Seoul

title: redskelt's Blog

tagline: My Personal Articles

description: >-
  redskelt's personal blog and articles.

url: "https://redskelt.github.io"

github:
  username: redskelt

social:
  name: redskelt
  email:
  links:
    - https://github.com/redskelt

theme_mode:

avatar: /assets/img/avatar.jpg

toc: true

comments:
  provider: giscus
  giscus:
    repo: redskelt/redskelt.github.io
    repo_id:
    category:
    category_id:

paginate: 10

baseurl: ""

kramdown:
  footnote_backlink: "&#8617;&#xfe0e;"
  syntax_highlighter: rouge
  syntax_highlighter_opts:
    css_class: highlight
    span:
      line_numbers: false
    block:
      line_numbers: true
      start_line: 1

collections:
  tabs:
    output: true
    sort_by: order

defaults:
  - scope:
      path: ""
      type: posts
    values:
      layout: post
      comments: true
      toc: true
      permalink: /posts/:title/
  - scope:
      path: _drafts
    values:
      comments: false
  - scope:
      path: ""
      type: tabs
    values:
      layout: page
      permalink: /:title/

sass:
  style: compressed

compress_html:
  clippings: all
  comments: all
  endings: all
  profile: false
  blanklines: false
  ignore:
    envs: [development]

exclude:
  - "*.gem"
  - "*.gemspec"
  - docs
  - tools
  - README.md
  - LICENSE

jekyll-archives:
  enabled: [categories, tags]
  layouts:
    category: category
    tag: tag
  permalinks:
    tag: /tags/:name/
    category: /categories/:name/
```

- [ ] **Step 3: `index.html`을 Chirpy 홈 레이아웃으로 교체**

`index.html` 전체를 다음 내용으로 덮어쓴다:

```html
---
layout: home
# Index page
---
```

- [ ] **Step 4: post 수정일 추적 훅 추가**

`_plugins/posts-lastmod-hook.rb` 새로 생성:

```ruby
#!/usr/bin/env ruby
#
# Check for changed posts

Jekyll::Hooks.register :posts, :post_init do |post|

  commit_num = `git rev-list --count HEAD "#{ post.path }"`

  if commit_num.to_i > 1
    lastmod_date = `git log -1 --pretty="%ad" --date=iso "#{ post.path }"`
    post.data['last_modified_at'] = lastmod_date
  end

end
```

- [ ] **Step 5: 네비게이션 탭(Categories/Tags/Archives) 스캐폴드 추가**

`_tabs/categories.md` 새로 생성:

```markdown
---
layout: categories
icon: fas fa-stream
order: 1
---
```

`_tabs/tags.md` 새로 생성:

```markdown
---
layout: tags
icon: fas fa-tags
order: 2
---
```

`_tabs/archives.md` 새로 생성:

```markdown
---
layout: archives
icon: fas fa-archive
order: 3
---
```

- [ ] **Step 6: GitHub Actions 배포 워크플로우를 Chirpy 공식 버전으로 교체**

기존 `.github/workflows/jekyll.yml` 삭제:

```bash
rm -f .github/workflows/jekyll.yml
```

`.github/workflows/pages-deploy.yml` 새로 생성:

```yaml
name: "Build and Deploy"
on:
  push:
    branches:
      - main
      - master
    paths-ignore:
      - .gitignore
      - README.md
      - LICENSE

  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: true

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v7
        with:
          fetch-depth: 0

      - name: Setup Pages
        id: pages
        uses: actions/configure-pages@v6

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.4
          bundler-cache: true

      - name: Build site
        run: bundle exec jekyll b -d "_site${{ steps.pages.outputs.base_path }}"
        env:
          JEKYLL_ENV: "production"

      - name: Test site
        run: |
          bundle exec htmlproofer _site \
            \-\-disable-external \
            \-\-ignore-urls "/^http:\/\/127.0.0.1/,/^http:\/\/0.0.0.0/,/^http:\/\/localhost/"

      - name: Upload site artifact
        uses: actions/upload-pages-artifact@v5
        with:
          path: "_site${{ steps.pages.outputs.base_path }}"

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v5
```

- [ ] **Step 7: avatar 이미지를 새 경로로 이전**

```bash
mkdir -p assets/img
git mv static/img/avatar.jpg assets/img/avatar.jpg
git mv static/img/favicon.ico assets/img/favicon.ico
```

- [ ] **Step 8: 로컬 빌드로 확인**

```bash
export PATH="$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
bundle exec jekyll build --trace
```

Expected: 에러 없이 `_site/` 생성. `_site/index.html`에 Chirpy 기본
홈 레이아웃(사이드바, Categories/Tags/Archives 링크)이 들어있어야 한다.
(About/Projects 탭은 아직 없어 정상, Task 3에서 추가)

- [ ] **Step 9: 커밋**

```bash
git add -A
git commit -m "chore: replace legacy theme with Chirpy scaffold"
```

---

### Task 3: About / Projects 탭 마이그레이션

**Files:**
- Create: `_tabs/about.md`
- Delete: `about.md` (루트, 내용은 `_tabs/about.md`로 이관됨)
- Create: `_tabs/projects.md`

**Interfaces:**
- Consumes: Task 2에서 만든 `_tabs/` 컬렉션 구조 (`collections.tabs`,
  `defaults`의 `type: tabs` scope)
- Produces: 사이드바에 About, Projects 탭이 표시되는 상태

- [ ] **Step 1: About 페이지 내용을 `_tabs/about.md`로 이관**

`_tabs/about.md` 새로 생성 (기존 `about.md` 본문 유지, front matter만
Chirpy 탭 포맷으로 교체):

```markdown
---
icon: fas fa-info-circle
order: 4
---

초급개발자 / 남자

### **사용중인 언어와 프레임워크**
- JAVA
- ASP
- SPRING

### **좋아하는거**
- 음악 / 통기타
- 게임
- 드라마
- 만화 / 영화 / 소설
- 잠
```

기존 루트 `about.md` 삭제:

```bash
rm -f about.md
```

- [ ] **Step 2: Projects 페이지를 `_tabs/projects.md`로 재작성**

기존 `_data/projects.json`(Task 2에서 이미 삭제됨)에 있던 항목은 원본
테마의 데모용 placeholder 데이터였고 사용자가 실제로 채운 적 없는
내용이었다. Chirpy 탭 형식으로 동일한 placeholder 구조만 유지해
마크다운 표로 옮긴다 (실제 프로젝트 내용은 추후 사용자가 직접 수정):

```markdown
---
icon: fas fa-diagram-project
order: 5
---

Few of my projects.

| Project | Date | Tags | Link |
|---|---|---|---|
| Cool project 1 | Jan 2014 | Angular JS, API | [link](https://www.google.com) |
| Cool project 2 | May 2014 | Python, Django | - |
| Cool project 3 | June 2014 | HTML, JQuery, Django | - |
| Cool project 4 | Oct 2016 | Python, nodejs | - |
| Cool project 5 | Oct 2016 | Python, nodejs | - |
| Cool project 6 | Oct 2016 | Python, nodejs | - |
```

- [ ] **Step 3: 로컬 빌드로 확인**

```bash
export PATH="$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
bundle exec jekyll build --trace
```

Expected: 에러 없음. `_site/about/index.html`, `_site/projects/index.html`
생성 확인.

```bash
find _site/about _site/projects -name "index.html"
```

- [ ] **Step 4: 커밋**

```bash
git add -A
git commit -m "content: migrate About and Projects pages to Chirpy tabs"
```

---

### Task 4: 포스트 8개 front matter 마이그레이션

**Files:**
- Modify: `_posts/2017/2017-06-17-workblog.md`
- Modify: `_posts/2017/2017-06-19-junit01.md`
- Modify: `_posts/2017/2017-06-20-junit02.md`
- Modify: `_posts/2017/2017-06-21-junit03.md`
- Modify: `_posts/2017/2017-06-22-junit04.md`
- Modify: `_posts/2017/2017-06-23-junit05.md`
- Modify: `_posts/2017/2017-07-06-mathJax.md`
- Modify: `_posts/2021/2021-07-31-gruntImageSprite.md`

**Interfaces:**
- Consumes: Task 2의 `_config.yml` `defaults` scope (posts에 자동으로
  `layout: post`, `permalink: /posts/:title/` 적용됨 — front matter에서
  `layout:`, `permalink:`을 별도로 안 써도 됨)
- Produces: Chirpy 아카이브/카테고리/태그 페이지에서 정상 인식되는
  front matter

- [ ] **Step 1: `categories` 배열 표기를 콤마+공백 형식으로 표준화**

각 포스트 파일의 `categories: [...]` 줄을 다음과 같이 수정한다
(front matter 나머지는 그대로 유지):

`_posts/2017/2017-06-17-workblog.md`:
```yaml
categories: [Life]
```
(변경 없음 — 원래도 단일 항목)

`_posts/2017/2017-06-19-junit01.md`, `2017-06-20-junit02.md`,
`2017-06-21-junit03.md`, `2017-06-22-junit04.md`,
`2017-06-23-junit05.md` 5개 파일 전부 동일하게:
```yaml
categories: [JUnit, Mockito]
```
(기존 `categories: [JUnit,mockito]`에서 공백 추가 + `Mockito` 대문자
통일)

`_posts/2017/2017-07-06-mathJax.md`:
```yaml
categories: [MathJax]
```
(변경 없음 — 원래도 단일 항목)

`_posts/2021/2021-07-31-gruntImageSprite.md`:
```yaml
categories: [CSS]
```
(기존 `categories: [css]`에서 대문자 통일)

- [ ] **Step 2: MathJax 포스트에 `math: true` 추가**

`_posts/2017/2017-07-06-mathJax.md`의 front matter를 다음과 같이 수정:

```yaml
---
title:  "수식 표현 MathJax"
date:   2017-07-02 23:50:02 +0900
categories: [MathJax]
math: true
---
```

(`layout: post`는 `_config.yml`의 `defaults`가 자동 적용하므로 제거)

- [ ] **Step 3: 나머지 7개 포스트에서 `layout: post` 줄 제거**

`defaults` scope가 모든 `_posts` 파일에 `layout: post`를 자동
주입하므로 개별 front matter의 `layout: post` 줄은 중복이라 삭제한다.
예 (`_posts/2017/2017-06-17-workblog.md`):

```yaml
---
title:  "블로그 작업 완료"
date:   2017-06-17 23:19:02 +0900
categories: [Life]
---
```

동일한 방식으로 나머지 6개 포스트(`junit01`~`junit05`,
`gruntImageSprite`)에서도 `layout: post` 줄만 제거하고 `title`/`date`/
`categories`는 유지한다.

- [ ] **Step 4: 로컬 빌드 + 개별 포스트 렌더링 확인**

```bash
export PATH="$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
bundle exec jekyll build --trace
find _site/posts -maxdepth 1 -name "index.html" -o -name "*.html" | wc -l
```

Expected: 에러 없음, `_site/posts/` 하위에 8개 포스트 각각의
디렉토리(`_site/posts/<slug>/index.html`)가 생성됨.

- [ ] **Step 5: 커밋**

```bash
git add _posts
git commit -m "content: migrate post front matter to Chirpy conventions"
```

---

### Task 5: 최종 통합 검증

**Files:** 없음 (검증 전용 태스크)

**Interfaces:**
- Consumes: Task 1~4에서 완성된 전체 사이트

- [ ] **Step 1: 클린 빌드**

```bash
export PATH="$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
rm -rf _site .jekyll-cache
bundle exec jekyll build --trace
```

Expected: 에러 없음.

- [ ] **Step 2: 로컬 서버 구동 후 페이지별 HTTP 상태 확인**

```bash
nohup bundle exec jekyll serve --port 4000 > /tmp/jekyll_chirpy_serve.log 2>&1 &
sleep 4
curl -s -o /dev/null -w "home: %{http_code}\n" http://localhost:4000/
curl -s -o /dev/null -w "about: %{http_code}\n" http://localhost:4000/about/
curl -s -o /dev/null -w "projects: %{http_code}\n" http://localhost:4000/projects/
curl -s -o /dev/null -w "categories: %{http_code}\n" http://localhost:4000/categories/
curl -s -o /dev/null -w "tags: %{http_code}\n" http://localhost:4000/tags/
curl -s -o /dev/null -w "archives: %{http_code}\n" http://localhost:4000/archives/
curl -s -o /dev/null -w "mathjax-post: %{http_code}\n" http://localhost:4000/posts/mathJax/
curl -s -o /dev/null -w "post-image: %{http_code}\n" http://localhost:4000/static/img/posts/2017/20170619_firstBug.jpg
kill %1 2>/dev/null
```

Expected: 전부 `200`. `post-image` 체크는 포스트 본문이 참조하는
`/static/img/posts/...` 경로(Task 2에서 `static/img/`는 삭제 대상이
아니었으므로 그대로 서빙되어야 함)가 여전히 살아있는지 확인하는
용도다.

(위 mathjax-post URL의 실제 slug는 build 결과의
`_site/posts/` 디렉토리명을 먼저 `ls _site/posts/`로 확인하고 그
이름을 사용한다. 파일명이 `2017-07-06-mathJax.md`이므로 slug는
`mathJax`가 된다.)

- [ ] **Step 3: 검색 기능 동작 확인**

```bash
curl -s http://localhost:4000/assets/js/data/search.json -o /dev/null -w "search-index: %{http_code}\n" 2>/dev/null || true
```
(서버가 아직 떠 있어야 하므로, Step 2와 합쳐서 kill 하기 전에 실행하거나
서버를 다시 띄워서 확인한다.)

Expected: `200`. Chirpy는 `assets/js/data/search.json`을 빌드 시 자동
생성해 lunr.js 검색에 사용한다.

- [ ] **Step 4: 남은 레거시 흔적 스캔**

```bash
grep -ril "super-search\|thickbox\|bootstrap.min\|disqus" _config.yml _tabs/ _posts/ 2>/dev/null
```

Expected: 아무 결과 없음 (전부 제거 확인).

- [ ] **Step 5: 최종 커밋 (필요 시)**

검증 중 사소한 수정이 있었다면:

```bash
git add -A
git commit -m "fix: address issues found during final Chirpy migration verification"
```

없다면 이 태스크는 커밋 없이 종료.

---

## 완료 후 사용자가 직접 해야 하는 작업 (플랜 범위 밖)

- GitHub 저장소 Settings에서 Discussions 활성화 + [giscus 앱](https://github.com/apps/giscus)
  설치 → 발급받은 `repo_id`/`category`/`category_id`를 `_config.yml`의
  `comments.giscus`에 채워 넣기
- Settings → Pages → Source를 "GitHub Actions"로 전환 (아직 안 했다면)
- PR 생성 후 Actions 워크플로우(`pages-deploy.yml`) 1회 성공 확인 후 merge
