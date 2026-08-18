# redskelt's Blog

[redskelt.github.io](https://redskelt.github.io) — [jekyll-theme-chirpy](https://github.com/cotes2020/jekyll-theme-chirpy) 기반 개인 블로그.

## 스택

- Jekyll 4.x (Ruby 3.3.0)
- [jekyll-theme-chirpy](https://github.com/cotes2020/jekyll-theme-chirpy) (gem 기반, `Gemfile`에서 버전 관리)
- GitHub Actions로 빌드 & 배포 (`.github/workflows/pages-deploy.yml`), Pages Source는 "GitHub Actions"
- 댓글: [Giscus](https://giscus.app) (GitHub Discussions 기반)

## 로컬에서 실행하기

Ruby는 `.ruby-version`(3.3.0)에 맞춰 [rbenv](https://github.com/rbenv/rbenv) 등으로 설치해서 쓴다.

```bash
bundle install
bundle exec jekyll serve
```

`http://localhost:4000`에서 확인.

빌드/링크 검증은 CI와 동일하게:

```bash
bundle exec jekyll build
bundle exec htmlproofer _site --disable-external \
  --ignore-urls "/^http:\/\/127.0.0.1/,/^http:\/\/0.0.0.0/,/^http:\/\/localhost/"
```

## 포스트 작성

`_posts/<year>/YYYY-MM-DD-slug.md` 형식으로 추가. front matter 예시:

```yaml
---
title: "제목"
date: 2026-08-18 12:00:00 +0900
categories: [Category, Subcategory]
tags: [tag1, tag2]
math: true   # 수식(MathJax) 쓸 때만
---
```

`layout`, `permalink`은 `_config.yml`의 `defaults`가 자동으로 지정하므로 front matter에 따로 안 써도 된다.

## 포스트 수정

기존 포스트는 `_posts/` 안의 해당 파일을 그냥 열어서 고치고 커밋하면 된다 — front matter에 수정일을 따로 안 넣어도 된다.

`_plugins/posts-lastmod-hook.rb`가 빌드 시 각 포스트 파일의 git 커밋 이력을 확인해서(`git log`), 최초 작성 이후 커밋이 2개 이상이면 마지막 커밋 날짜를 `last_modified_at`으로 자동 채워준다. Chirpy는 이 값이 있으면 포스트 상단에 "Updated: ..."를 자동으로 표시한다.

주의할 점:
- 이 훅은 **git 커밋 시각**을 기준으로 하므로, 로컬에서 여러 번 고치고 한 번에 커밋하면 그 시점이 수정일로 잡힌다.
- `date:` 필드(최초 작성일)는 그대로 두고 바꾸지 않는다 — 바꾸면 카테고리/아카이브 정렬 순서가 틀어진다.
- 카테고리를 바꾸는 경우 `categories:` 값이 이미 존재하는 카테고리와 대소문자/표기까지 일치해야 같은 카테고리로 묶인다.

## 페이지 구조

- `_tabs/` — 사이드바에 뜨는 네비게이션 탭(About, Projects, Categories, Tags, Archives)
- `_data/contact.yml` — 사이드바 하단 GitHub/RSS 아이콘
- `assets/img/` — 아바타, 파비콘 등 사이트 전역 이미지
- `assets/css/jekyll-theme-chirpy.scss` — Chirpy 기본 폰트(`$font-family-base`/`$font-family-heading`)를 [Pretendard](https://github.com/orioncactus/pretendard)로 오버라이드 (jsDelivr CDN 사용, 버전 고정)
- `static/img/posts/` — 개별 포스트 본문에서 참조하는 이미지 (경로 유지 목적, 옮기지 말 것)
- `wiki/` — 개인 학습 위키 ([Karpathy LLM Wiki 패턴](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)), Jekyll 빌드에서 제외됨. `.claude/skills/wiki-ingest/SKILL.md` 참고

## 참고

- 테마 문서: [jekyll-theme-chirpy 위키](https://github.com/cotes2020/jekyll-theme-chirpy/wiki)
- 마이그레이션 배경(2026-08, 구 커스텀 테마 → Chirpy 전환) 기록: `docs/superpowers/specs/`, `docs/superpowers/plans/`
