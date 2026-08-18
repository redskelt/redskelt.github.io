# Chirpy 테마 마이그레이션 설계

- 날짜: 2026-08-18
- 상태: 승인 대기 (writing-plans 이전 단계)
- 대상 저장소: redskelt.github.io

## 배경

현재 사이트는 2016~2017년 무렵 forked된 커스텀 Jekyll 테마(base: simplygrey-jekyll,
Bootstrap 3.1.1 + jQuery 1.11 + 커스텀 Super Search/Thickbox)로 운영 중이었다.
선행 작업(`chore/jekyll-upgrade` 브랜치)으로 빌드 인프라를 GitHub Actions +
Jekyll 4.x로 이미 전환해두었다. 이번 작업은 그 위에서 프론트엔드/테마 자체를
[jekyll-theme-chirpy](https://github.com/cotes2020/jekyll-theme-chirpy)로
완전히 교체하는 것이다.

## 결정 사항 (사용자 승인 완료)

| 항목 | 결정 |
|---|---|
| 설치 방식 | Chirpy Starter (gem 기반) |
| Projects 페이지 | Chirpy 커스텀 탭 페이지로 재구현 |
| 포스트 URL 구조 | 기존 카테고리 기반 permalink 폐기, Chirpy 기본 구조(`/posts/:title/`)로 변경 |
| 댓글 시스템 | Disqus → Giscus로 교체 |
| Google Analytics | 이번 마이그레이션에서 제거 (기존 UA 속성은 2023년 만료된 구버전이라 이관 대상 아님) |

## 아키텍처

기존 저장소(`redskelt.github.io`)를 그대로 재구성한다. 별도 저장소를 새로
만들지 않는다.

- `Gemfile`: `jekyll-theme-chirpy` gem 추가. 선행 작업에서 넣은
  `jekyll-theme-architect`, `jekyll-paginate` 등은 제거.
- `_config.yml`: Chirpy 스펙에 맞게 전면 재작성 (title, tagline, avatar,
  theme_mode, comments.giscus, timezone 등).
- Chirpy Starter 표준 파일 도입:
  - `_tabs/` (about, archives, categories, tags, projects — 네비게이션 탭)
  - `.github/workflows/pages-deploy.yml` (Chirpy 공식 배포 워크플로우로
    선행 작업의 `.github/workflows/jekyll.yml`을 대체)
- 삭제 대상 (Chirpy가 자체 제공하므로 불필요):
  - `_layouts/*`, `_includes/*`, `_sass/*` (커스텀 테마 전체)
  - `static/js/super-search.js`, `static/js/thickbox-compressed.js`,
    `static/js/bootstrap.min.js`
  - `static/css/bootstrap.min.css`, `static/css/thickbox.css`,
    `static/css/super-search.css`, `static/css/projects.css`,
    `static/css/main.css`, `static/css/syntax.css`
  - `category/*.html` (수동 카테고리 페이지 — Chirpy가 자동 생성)
  - `feed.xml`, `sitemap.xml` (커스텀 Liquid 템플릿 — Chirpy/jekyll-feed,
    jekyll-sitemap이 자동 생성)

## 콘텐츠 마이그레이션

### 포스트 (8개)

`_posts/2017/*.md`(7개), `_posts/2021/*.md`(1개) 전부 유지하되 front matter
조정:

- `categories: [JUnit,mockito]` 같은 콤마 뒤 공백 없는 표기 →
  `categories: [JUnit, Mockito]` 형식으로 표준화 (Chirpy는 카테고리 계층
  최대 2단계 지원, 대소문자/표기 일관성 정리)
- `2017-07-06-mathJax.md` 포스트에 `math: true` 필드 추가 (Chirpy는 옵트인
  방식으로 MathJax 렌더링 — 안 넣으면 수식이 안 그려짐)
- `layout: post`는 Chirpy에서도 그대로 유효하므로 유지
- 날짜 기반 카테고리 URL(`/junit/mockito/2017/06/19/junit01.html`)은
  Chirpy 기본 URL(`/posts/junit01/`)로 대체됨 — 리다이렉트 설정 없음
  (포스트 8개, 외부 유입 미미 판단)

### About 페이지

`about.md` → `_tabs/about.md`로 이동, Chirpy 탭 front matter
(`icon:`, `order:`)로 교체. 본문 내용은 그대로 유지.

### Projects 페이지

`projects.md` + `_project/` 컬렉션 + `_data/projects.json` →
`_tabs/projects.md` 단일 커스텀 탭 페이지로 통합 재작성. Chirpy에
프로젝트 전용 기능이 없으므로 Markdown 표 또는 카드 나열 형식으로
직접 구성한다. 기존 프로젝트 상세 페이지(`_project/*` 개별 URL)는
유지하지 않고 탭 페이지 하나로 축약한다.

### 이미지/정적 자산

`static/img/` 중 실사용 확인된 것만 `assets/img/`로 이전:

- `avatar.jpg` (프로필 이미지)
- `favicon.ico`
- `_posts` 본문에서 참조하는 이미지 (있는 경우)

미사용 확인된 것(스크린샷, thickbox 리소스, `loadingAnimation.gif`,
`subtle_dots.png`, `macFFBgHack.png` 등)은 폐기.

## 설정 이전 매핑

| 기존 (`_config.yml`) | Chirpy 대응 |
|---|---|
| `title` | `title` |
| `description` | `tagline` |
| `avatar_url` | `avatar` |
| `disqus_shortname` | `comments.provider: giscus` + `comments.giscus.*` (repo, repo_id, category, category_id — Giscus 앱 설치 후 발급값 필요) |
| `google_analytics` | 제거 (이번 범위 아님) |
| `social` (github 아이콘) | `_data/contact.yml` |
| `urls` (커스텀 네비게이션) | `_tabs/*.md` 개별 파일로 대체 |
| `gems:` (구식 키) | 사용 안 함 — Gemfile의 `jekyll-theme-chirpy` 및 부속 플러그인이 처리 |

⚠️ Giscus는 저장소 소유자가 GitHub에서 Discussions 기능 활성화 +
[giscus 앱](https://github.com/apps/giscus) 설치 후 발급되는
`data-repo-id`, `data-category-id` 값을 받아와야 실제 동작한다. 이 값은
로컬 빌드로는 확인 불가하고 배포 후 실제 저장소에서 설정해야 한다.

## 에러 처리 / 리스크

- **URL 변경으로 인한 기존 링크 깨짐**: 리다이렉트 미설정. 포스트 8개,
  개인 블로그 특성상 외부 백링크 거의 없다고 판단해 감수.
- **Giscus 미설정 상태로 배포될 경우**: 댓글 위젯이 로드 실패하거나
  표시되지 않을 수 있음. 배포 직후 저장소 Discussions 활성화 +
  giscus 앱 설치를 우선 처리해야 함.
- **테마 gem 버전 고정**: Chirpy는 gem 자체 버전 업데이트만으로 테마
  갱신 가능 (Gemfile.lock의 `jekyll-theme-chirpy` 버전만 올리면 됨) —
  향후 유지보수 부담 낮음.

## 테스트 계획

로컬에서 순서대로 확인:

1. `bundle install` (Gemfile 교체 후 `Gemfile.lock` 재생성)
2. `bundle exec jekyll build` — 에러 없이 `_site/` 생성 확인
3. `bundle exec jekyll serve` 로 다음 페이지 육안 확인:
   - 홈 (포스트 목록)
   - 포스트 8개 전부 (특히 mathJax 포스트 수식 렌더링, junit 시리즈 5개
     연속 링크)
   - About 탭
   - Projects 탭 (재구성된 내용)
   - Archives, Categories, Tags (Chirpy 자동 생성 페이지)
   - 검색 기능 (lunr.js)
   - 다크모드 토글
4. Giscus 위젯은 로컬에서 로드 여부만 확인, 실제 댓글 동작은 배포 +
   저장소 설정 완료 후 별도 확인

## 작업 범위 / 브랜치 전략

- 새 브랜치 `theme/chirpy-migration`에서 진행
- `chore/jekyll-upgrade`의 Gemfile 작업은 이번 마이그레이션에 흡수됨
  (Chirpy gem으로 다시 교체하므로)
- 커밋은 논리 단위로 분리:
  1. Gemfile/`_config.yml`/워크플로우 교체
  2. 콘텐츠 마이그레이션 (포스트 front matter, about, projects)
  3. 레거시 파일 삭제 (구 테마, static 리소스, category 페이지, feed/sitemap)

## 범위 밖 (Out of Scope)

- Google Analytics 재설정 (필요 시 별도 작업)
- 기존 URL에 대한 리다이렉트 규칙
- Giscus 저장소 측 설정 (Discussions 활성화, 앱 설치) — 이건 코드 변경이
  아니라 GitHub 저장소 설정이므로 사용자가 직접 처리
