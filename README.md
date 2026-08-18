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

## 페이지 구조

- `_tabs/` — 사이드바에 뜨는 네비게이션 탭(About, Projects, Categories, Tags, Archives)
- `_data/contact.yml` — 사이드바 하단 GitHub/RSS 아이콘
- `assets/img/` — 아바타, 파비콘 등 사이트 전역 이미지
- `static/img/posts/` — 개별 포스트 본문에서 참조하는 이미지 (경로 유지 목적, 옮기지 말 것)

## 참고

- 테마 문서: [jekyll-theme-chirpy 위키](https://github.com/cotes2020/jekyll-theme-chirpy/wiki)
- 마이그레이션 배경(2026-08, 구 커스텀 테마 → Chirpy 전환) 기록: `docs/superpowers/specs/`, `docs/superpowers/plans/`
