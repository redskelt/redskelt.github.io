# Minimal Mistakes 테마 마이그레이션 설계

- 날짜: 2026-08-27
- 상태: 승인 대기 (writing-plans 이전 단계)
- 대상 저장소: redskelt.github.io
- 참조 저장소/사이트: https://github.com/whdrns2013/whdrns2013.github.io ,
  https://whdrns2013.github.io/

## 배경

현재 사이트는 `jekyll-theme-chirpy` gem 기반으로 운영 중이다
(`docs/superpowers/specs/2026-08-18-chirpy-theme-migration-design.md`로
이미 완료된 마이그레이션). 이번 작업은 그 위에서 테마 패밀리 자체를
`whdrns2013/whdrns2013.github.io`가 사용하는 **Minimal Mistakes 기반
fork-and-customize 테마**로 다시 교체하는 것이다.

대상 저장소는 mmistakes/minimal-mistakes를 gem/remote_theme으로
쓰는 게 아니라, 테마 저장소 자체를 fork하여 `_layouts`, `_includes`,
`_sass/minimal-mistakes/` 원본을 저장소 안에 직접 보유하고, 그 위에
`_sass/custom/` 14개 scss와 orbit/series/category-hierarchy/
post-neighborhood-map 등 자체 기능을 얹은 구조다.

## 결정 사항 (사용자 승인 완료)

| 항목 | 결정 |
|---|---|
| 적용 목표 수위 | 시각/구조 완전 동일 재현 (최대공수 경로) |
| 이식 방식 | 대상 저장소(whdrns2013.github.io) 파일을 직접 소스로 삼아 복사 후 개인화 |
| 댓글 시스템 | giscus 유지 (Utterances로 바꾸지 않음) |
| 검색 엔진 | Lunr로 교체 (대상과 동일) |
| 확장 기능(orbit/series/category-hierarchy/neighborhood-map) | 전부 이식, 카테고리 체계까지 대상과 동일한 계층 구조 적용 |
| 퍼머링크 | 대상과 동일하게 변경 (`/:categories/:title/`) — 기존 giscus 댓글 스레드 연결 유실 감수 |

## 아키텍처

기존 저장소(`redskelt.github.io`)를 그대로 재구성한다. 별도 저장소를
새로 만들지 않는다.

- **테마 코어 이식**: 대상 저장소의 `_layouts/`(14개), `_includes/`(44개
  항목), `_sass/minimal-mistakes/` 전체를 복사.
- **커스텀 레이어 이식**: `_sass/custom/*.scss` 14개
  (`_home.scss`, `_masthead-terminal.scss`, `_sidebar-terminal.scss`,
  `_orbit.scss`, `_series.scss`, `_category-hierarchy.scss`,
  `_post-neighborhood-map.scss`, `_tag-archive.scss`, `_accordion.scss`,
  `_search-overlay.scss`, `_toc-toggle.scss`, `_readability.scss`,
  `_theme.scss`, `customImport.scss`, `customOverride.scss`) 및
  `assets/css/main.scss`의 import 체계 복사.
- **커스텀 콘텐츠 타입 페이지**: `orbit.md`, `diary.md`,
  `series-archive.md`, `category-archive.md`, `tag-archive.md`,
  `year-archive.md`, `banner.js` 복사 후 redskelt 콘텐츠 기준 재구성.
- **`Gemfile`**: `jekyll-theme-chirpy` 제거, 대상과 동일하게
  `github-pages`, `jekyll`(3.9.3 고정 여부는 GitHub Pages 빌드 환경
  호환성 확인 후 결정), `kramdown-parser-gfm`, `webrick`,
  `jekyll-paginate`, `jekyll-sitemap`, `jekyll-gist`, `jekyll-feed`,
  `jekyll-include-cache` 추가.
- **`_config.yml`**: minimal-mistakes 스펙 + 대상 커스텀 설정
  전면 재작성 (`remote_theme` 항목은 유지하되 실질적으로는 로컬
  vendored 파일이 우선 적용됨 — 대상 저장소와 동일 패턴).
  `minimal_mistakes_skin`, 검색(Lunr), 페이지네이션, 타임존, 퍼머링크,
  kramdown/rouge 옵션 포함.
- **네비게이션 전환**: 현재 `_tabs/*.md`(chirpy 방식) →
  minimal-mistakes `_pages/` + `_data/navigation.yml` 방식으로 전환.
  Home / Categories / Archive / Series / Orbit / Diary 등 대상과
  동일한 계층형 메뉴 구성.
- **삭제 대상**: chirpy 전용 `_tabs/`, chirpy가 자동 생성하던
  categories/tags/archives 페이지, chirpy 전용 assets/js·css.

## 개인화 (대상 콘텐츠 → redskelt 콘텐츠 치환)

- 사이드바 프로필: 아바타, 이름, 직함, GitHub/이메일 링크 → redskelt
  정보로 교체 (Instagram 등 대상 고유 링크는 제외).
- Google Analytics ID(`G-5QP1LRJHWJ`)는 대상 고유 값이므로 제거,
  필요 시 redskelt 소유 GA 속성으로 별도 교체.
- 댓글: Utterances 관련 코드/설정은 제거하지 않고 giscus로 대체
  연결 (기존 giscus repo/repo_id/category 값 재사용).
- Docs 계층(LLM/RAG/MCP/Chat UI/LangChain 등)은 대상 고유 주제이므로
  redskelt 기존 카테고리(JUnit, Mockito, CSS, MathJax, Life, Wiki 등)
  기준으로 계층 재설계.

## 콘텐츠 마이그레이션

### 기존 포스트 (`_posts/` 전체, 2017/2021/2026)

- flat `categories: [JUnit, Mockito]` 형태 front matter →
  minimal-mistakes 계층 카테고리 체계로 재작성. 카테고리 계층
  설계(예: `개발 > 테스트 > JUnit/Mockito`, `개발 > 프론트엔드 > CSS`
  등)는 구현 단계에서 기존 12개 포스트 주제를 검토해 확정.
- `layout: post` → minimal-mistakes 표준(`layout: single` +
  `classes: wide` 등 필요 시)으로 교체.
- chirpy 전용 필드(`pin`, `math`, `toc` 등) 중 minimal-mistakes에서도
  유효한 것은 유지, 무효한 것은 제거하거나 동등 옵션으로 치환.
- `wiki-ingest` 스킬로 생성된 최근 포스트(`2026-08-18-idempotency.md`
  등)의 front matter 규칙도 함께 갱신 필요 — 스킬 쪽 템플릿도 후속
  점검 대상 (범위 밖, 별도 이슈로 기록).

### 퍼머링크

`permalink: /:categories/:title/`로 변경. 기존 giscus 댓글은 URL
기준 매핑이므로 연결이 끊길 수 있음 — 사용자 승인에 따라 감수한다.

## 에러 처리 / 리스크

- **퍼머링크 변경 → giscus 댓글 스레드 유실**: 사용자 승인하에 감수.
  배포 후 필요 시 discussion 재연결은 수동으로 처리.
- **chirpy 전용 front matter가 minimal-mistakes에서 무시/에러 유발**:
  마이그레이션 스크립트 또는 수동 점검으로 일괄 정리.
- **jekyll 버전 차이**: 대상은 `github-pages 228`/`jekyll 3.9.3` 고정,
  현재 저장소는 최신 Jekyll 4.x 사용 중. 다운그레이드 여부는
  GitHub Pages 빌드 호환성과 기존 플러그인(`_plugins/`) 동작 여부를
  구현 단계에서 확인 후 결정.
- **`_plugins/`, `_data/` 커스텀 코드**: 현재 저장소의 기존
  `_plugins/`, `_data/` 내용이 새 테마와 충돌하는지 구현 착수 전
  점검 필요.
- **wiki-ingest 스킬과의 연동**: wiki-to-post 변환 스킬이 chirpy
  front matter 포맷을 가정하고 있다면 함께 갱신 필요.

## 테스트 계획

로컬에서 순서대로 확인:

1. `bundle install` (Gemfile 교체 후 `Gemfile.lock` 재생성)
2. `bundle exec jekyll build` — 에러 없이 `_site/` 생성 확인
3. `bundle exec jekyll serve`로 다음 확인:
   - 홈/사이드바(프로필, 다크모드 토글, 검색)
   - 기존 포스트 전부 정상 렌더링 (URL, 카테고리, 태그)
   - Categories/Archive/Series/Orbit/Diary 등 커스텀 페이지 동작
   - Lunr 검색 동작
   - giscus 댓글 위젯 로드 여부 (실제 스레드 연결은 배포 후 확인)
4. 반응형/모바일 레이아웃 육안 확인

## 작업 범위 / 브랜치 전략

- 새 브랜치 `theme/minimal-mistakes-migration`에서 진행
- 커밋은 논리 단위로 분리 (예시, 구현 단계에서 세분화):
  1. Gemfile/`_config.yml`/테마 코어 파일 이식
  2. 커스텀 scss/콘텐츠 타입/네비게이션 이식 및 개인화
  3. 기존 포스트 front matter 마이그레이션
  4. 레거시(chirpy) 파일 삭제

## 범위 밖 (Out of Scope)

- Google Analytics 재설정
- wiki-ingest 스킬 템플릿 자체의 리팩터링 (front matter 호환성
  이슈만 이번에 확인, 스킬 내용 수정은 별도 작업)
- 대상 사이트의 Docs 카테고리(LLM/RAG/MCP 등) 콘텐츠 자체 이식 —
  구조/기능만 가져오고 콘텐츠는 redskelt 고유 주제 유지
