# redskelt's Blog

[redskelt.github.io](https://redskelt.github.io) — [Minimal Mistakes](https://github.com/mmistakes/minimal-mistakes) 테마를 fork-and-customize(vendored) 방식으로 커스터마이징한 개인 블로그.

## Credits

이 저장소의 사이드바 터미널 UI, orbit/series/category-hierarchy 뷰, "reading
compass"(관련 글 추천) 등 `_sass/custom/`·`assets/js/custom/`의 커스텀
레이어는 [whdrns2013/whdrns2013.github.io](https://github.com/whdrns2013/whdrns2013.github.io)의
커스터마이징을 그대로 가져와 콘텐츠만 이 블로그에 맞게 바꾼 것이다.

## 스택

- Jekyll 4.x (Ruby 3.3.0)
- [Minimal Mistakes](https://github.com/mmistakes/minimal-mistakes) (`remote_theme`으로 버전 고정, `_layouts`/`_includes`/`_sass`는 로컬에 vendor해서 커스터마이징)
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
---
```

`layout`(single), `permalink`, `author_profile`, `comments`, `toc` 등은 `_config.yml`의 `defaults`가 자동으로 지정하므로 front matter에 따로 안 써도 된다. 수식(MathJax)은 전역으로 항상 로드되므로(`_includes/scripts.html`) 옵트인 필드가 필요 없다.

`categories:`에 쓰는 이름은 `_data/category_hierarchy.yml`에 leaf로 등록되어 있어야 `/categories/` 페이지 그룹 뷰에 나타난다 — 등록 안 된 이름을 써도 포스트 자체는 정상 렌더링되지만 그 페이지에서는 조용히 빠지므로, 새 카테고리를 쓸 땐 이 파일에도 함께 추가해야 한다.

## 포스트 수정

기존 포스트는 `_posts/` 안의 해당 파일을 그냥 열어서 고치고 커밋하면 된다 — front matter에 수정일을 따로 안 넣어도 된다.

`_plugins/posts-lastmod-hook.rb`가 빌드 시 각 포스트 파일의 git 커밋 이력을 확인해서(`git log`), 최초 작성 이후 커밋이 2개 이상이면 마지막 커밋 날짜를 `last_modified_at`으로 자동 채워준다. 이 값이 있으면 포스트 상단에 "Updated: ..."가 자동으로 표시된다(`_includes/page__date.html`).

주의할 점:
- 이 훅은 **git 커밋 시각**을 기준으로 하므로, 로컬에서 여러 번 고치고 한 번에 커밋하면 그 시점이 수정일로 잡힌다.
- `date:` 필드(최초 작성일)는 그대로 두고 바꾸지 않는다 — 바꾸면 카테고리/아카이브 정렬 순서가 틀어진다.
- 카테고리를 바꾸는 경우 `_data/category_hierarchy.yml`에 등록된 이름과 대소문자/표기까지 일치해야 같은 그룹으로 묶인다.

## 페이지 구조

- `category-archive.md`, `year-archive.md`, `series-archive.md`, `tag-archive.md`, `orbit.md`, `diary.md`, `ddocs/00_doc_intro.md` — 루트 커스텀 콘텐츠 페이지 (사이드바 상단 네비게이션에서 연결)
- `_data/navigation.yml` — 상단 네비게이션 메뉴 구성
- `_data/category_hierarchy.yml` — `/categories/` 그룹핑 정의 (그룹 key/main_title/sub_title + leaf `categories[].name`)
- `_data/docs.yml` — Docs 아코디언 메타데이터 (`meta:` 현재 비어있음 — 콘텐츠 미채움)
- `assets/img/` — 아바타, 파비콘 등 사이트 전역 이미지
- `assets/css/main.scss` — Minimal Mistakes 스킨 + `_sass/custom/*` 커스텀 레이어(터미널 사이드바, orbit, series, category-hierarchy 등) import 진입점
- `static/img/posts/` — 개별 포스트 본문에서 참조하는 이미지 (경로 유지 목적, 옮기지 말 것)
- `wiki/` — 개인 학습 위키 ([Karpathy LLM Wiki 패턴](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)), Jekyll 빌드에서 제외됨. `.claude/skills/wiki-ingest/SKILL.md` 참고

## 참고

- 테마 문서: [Minimal Mistakes 문서](https://mmistakes.github.io/minimal-mistakes/docs/quick-start-guide/)
- 마이그레이션 기록: `docs/superpowers/specs/`, `docs/superpowers/plans/` (2026-08 chirpy 도입 → 2026-08 Minimal Mistakes 전환, 총 2건)
