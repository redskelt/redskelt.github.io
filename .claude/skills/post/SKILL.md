---
name: post
description: 이 블로그(_posts/)의 포스트를 새로 작성하거나, 기존 포스트를 찾아서 수정/삭제할 때 사용. "새 포스트 써줘", "이 글 고쳐줘", "그 포스트 지워줘" 같은 요청에 사용.
---

# 포스트 작성 / 수정 / 삭제

이 저장소는 Minimal Mistakes 기반(vendored) Jekyll 블로그다. 포스트는
`_posts/<year>/YYYY-MM-DD-slug.md` 형식으로 저장된다. 자세한 컨벤션은
`README.md`의 "포스트 작성"/"포스트 수정" 섹션 참고.

먼저 사용자 요청이 **작성 / 수정 / 삭제** 중 어느 쪽인지 판단한다. 애매하면
물어본다.

## 공통: 카테고리는 `_data/category_hierarchy.yml`의 leaf여야 함

이 테마의 `/categories/` 페이지는 `categories:` 배열 순서가 아니라
`_data/category_hierarchy.yml`(그룹 key/main_title/sub_title + 그 안의
`categories[].name`)로 그룹핑한다. **`categories:`에 이 파일에 없는
이름을 쓰면 포스트 자체는 정상 렌더링되지만 `/categories/` 그룹 뷰에서는
조용히 빠진다** — 에러 없이 그냥 안 보이므로 놓치기 쉽다.

먼저 기존에 쓰이는 카테고리 목록을 확인한다:

```bash
grep -rhoP '(?<=^categories: \[)[^\]]+' _posts/ | tr ',' '\n' | sed 's/^ *//;s/ *$//' | sort -u
```

사용자가 입력한 카테고리가 이 목록에 있는 것과 대소문자/표기만 다르면
(예: 목록엔 `JUnit`이 있는데 사용자가 `junit`이라고 입력) 그대로 새로 만들지,
기존 표기에 맞출지 물어본다.

완전히 새로운 카테고리면 `_data/category_hierarchy.yml`을 열어서 그 이름이
`categories[].name`으로 이미 있는지 확인한다:

```bash
grep -n "name:" _data/category_hierarchy.yml
```

없으면 **반드시** 이 파일에도 leaf를 추가해야 한다 — 어느 그룹(`key`)에
넣을지 사용자에게 물어보거나(기존 그룹: `testing`/`web`/`wiki`/`life`),
어느 그룹에도 안 맞으면 새 그룹을 만들지 물어본다. 이 파일 수정도 포스트
파일과 함께 커밋 대상에 포함시킨다(수정만 하고 알려주면 됨 — 커밋은
"작성"/"수정" 절차의 마지막 단계와 동일하게 사용자가 직접 한다).

## 공통: 본문에 링크가 있으면 링크 확인

본문(사용자가 붙여넣은 내용 포함)에 마크다운 링크 `[텍스트](경로)`가 있으면
파일을 쓰기 전에 다음을 확인한다:

- `http(s)://`로 시작하는 외부 링크는 그냥 둔다 (CI가 `--disable-external`로
  외부 링크는 검사 안 함).
- 상대 경로 링크(`(01-foo.md)`, `(../bar.md)` 같은 것)는 실제로 저장소 안에
  그 파일이 존재하는지 확인한다:

  ```bash
  ls <링크에 적힌 경로>
  ```

  파일이 없으면 CI의 htmlproofer가 배포를 막는다 (`build` job 실패,
  `Test site` 단계). 없는 파일을 가리키는 링크는 쓰지 말고, 사용자에게
  알려주거나 텍스트/코드블록으로 바꿔서 넣는다. 다른 프로젝트 문서에서
  복붙한 내용일수록 이 문제가 잘 생긴다.
- 이 확인은 "작성" 6번, "수정"에서 본문에 링크를 추가/유지할 때 항상
  거친다.

## 공통: 스크린샷 필수, 유튜브는 임베드

**포스트 작성 시 관련 스크린샷은 항상 넣는다.** 텍스트만 있는 포스트는 안 됨 — 설치 화면, 공식 문서, UI, 비교표 등 본문에서 언급하는 대상마다 최소 1장은 스크린샷으로 보여준다. 캡처는 `/ego-browser` 스킬로 직접 뜬다.

- **캡처 해상도: 최소 1342×751**. 사이트 전역에 이미지 클릭 확대(lightbox, `assets/js/custom/image-zoom.js`)가 붙어 있어서, 이보다 작게 찍으면 확대했을 때 뿌옇게 나온다. CDP `Emulation.setDeviceMetricsOverride`로 뷰포트를 `{ width: 1342, height: 751 }` 이상(세로로 긴 내용이면 height만 키움)으로 설정한 뒤 캡처한다. 작게 찍고 나중에 리사이즈로 키우지 말 것 — 원본 해상도 이상은 절대 못 올라간다.
- **저장 위치**: `assets/img/posts/<post-slug>/<name>.png`, 마크다운은 `![대체텍스트](/assets/img/posts/<slug>/<name>.png)` 형식.
- **개인정보/계정 노출 주의**: 가능하면 로그인 없는 공개 페이지(공식 문서, GitHub 저장소, 마케팅 페이지)를 캡처한다. 로그인된 자신의 계정 화면(이메일, 개인 도메인 등)이 찍히는 건 피한다.
- **참고 영상이 있으면 실제 화면을 프레임으로 뜬다**: 그냥 문서 스샷보다, 언급하는 장면이 담긴 유튜브 영상의 실제 프레임을 캡처하는 게 더 정확하다. 방법:
  1. `page.evaluate()`로 `document.getElementById('movie_player').setPlaybackQualityRange('hd1080','hd1080')` 호출해서 720p가 아니라 1080p 소스로 강제.
  2. 영상 자막(vtt)을 `yt-dlp --write-auto-sub`로 받아서 원하는 장면의 정확한 타임스탬프를 먼저 찾는다 (없이 감으로 초를 찍으면 광고/다른 장면이 걸릴 수 있음).
  3. `video.currentTime = t` 후 `pause()`, `video.getBoundingClientRect()`로 clip 영역 잡아서 스크린샷.
  4. 화면 하단에 자막이 타서 들어가 있으면(재생바+캡션) 그 부분만 잘라내고 저장.
- **유튜브 영상은 링크가 아니라 임베드로 넣는다.** `[제목](https://youtube.com/watch?v=ID)` 식 마크다운 링크 금지. 이 테마의 임베드 문법을 쓴다:

  ```
  {% include video id="VIDEO_ID" provider="youtube" %}
  ```

  영상 소개 문구는 그 위에 인용구(`>`)나 평문으로 짧게 남기고, 링크 자체는 임베드가 대신한다.

## 공통: 시리즈 여부, 유튜브 리뷰면 Trending 카테고리

**여러 편으로 나눠 쓰는 포스트(1/N, 2/N ... 같은 제목, 또는 사용자가 "시리즈로
만들자"고 한 경우)는 `post_url` 상호 링크만으로는 부족하다.** `/series/`
페이지와 관련 글 추천(orbit)은 `series`/`series_index` front matter와
`_data/series.yml` 등록 여부로만 시리즈를 인식한다 — 이 필드가 없으면 카테고리
페이지엔 잡혀도 시리즈 페이지엔 조용히 빠진다.

- front matter에 추가:

  ```yaml
  series: <series-id>       # kebab-case, 시리즈 전체가 공유하는 고유 id
  series_index: <N>          # 1부터 시작하는 편 번호
  ```

- `_data/series.yml`에 그 `<series-id>`가 없으면 새로 추가한다:

  ```yaml
  <series-id>:
    title: "<시리즈 전체 제목>"
    description: "<한 줄 소개 — 몇 부작인지, 무엇을 다루는지>"
  ```

- 시리즈로 묶을지 애매하면(예: 편이 하나뿐이거나 사용자가 명시하지 않음)
  사용자에게 물어본다.

**유튜브 영상을 보고 정리/리뷰하는 포스트**는 이 블로그에서 관례적으로
`categories: [AI, Trending]`을 함께 쓴다(`Trending`은 `/trending/` — 유튜브
AI 채널 큐레이션 페이지). 상단 nav에는 더 이상 링크가 없지만 페이지 자체는
살아있고 `_data/category_hierarchy.yml`에도 등록돼 있다. 유튜브 리뷰/정리
포스트를 쓸 때는 `Trending`을 포함할지 사용자에게 물어본다 — 무조건 넣지는
않는다(주간 큐레이션 성격이 아닌 글도 있을 수 있음).

## 공통: 상단 메뉴 전체 점검

상단 nav는 `Home / Categories / Posts / Docs / Series / Tags / AI / Orbit /
Diary`다. 포스트를 쓰거나 고친 뒤에는 이 메뉴들에 의도한 대로 반영되는지
훑어본다. 대부분은 front matter만 맞으면 자동으로 반영되지만, 자동으로 안
되는 것과 아예 대상이 아닌 것을 구분해야 한다.

| 메뉴 | 무엇으로 채워지나 | 확인할 것 |
|---|---|---|
| Categories | `_data/category_hierarchy.yml`의 leaf | 위 "카테고리는 leaf여야 함" 절차 |
| Posts | `site.posts` 전체 | 자동, 별도 조치 없음 |
| Series | front matter `series`/`series_index` + `_data/series.yml` 등록 | 위 "시리즈 여부" 절차 |
| Tags | front matter `tags` | 자동, 별도 조치 없음 |
| AI | `categories`에 정확히 `AI`가 있으면 `/posts/?category=ai`에서 슬러그 매칭(`slugify`)으로 자동 필터링 | `AI`가 카테고리 배열에 있는지만 확인, 별도 필드 없음 |
| Orbit | 저장된 `categories`/`tags`/`series` 메타데이터를 그래프로 재사용(`assets/js/custom/orbit.js`) | 위 세 가지가 맞으면 자동, 별도 조치 없음 |
| Diary | `categories`에 `Life`(또는 `diary`/`Diary`)가 있는 글만 (`diary.md`) | 기술 포스트는 대상 아님 — 넣지 않는다 |
| Docs | `_docs` 컬렉션 전용(`_data/docs.yml`), `_posts`와 무관 | 블로그 포스트 작성 시 이 메뉴는 건드릴 일 없음 |

즉 새 글에서 실제로 사람이 챙겨야 하는 건 **카테고리 leaf 등록**과
**시리즈 등록**뿐이고, 나머지(Tags/AI/Orbit)는 그 두 가지 front matter가
정확하면 저절로 맞는다. Diary/Docs는 애초에 이 스킬이 다루는 일반 기술
포스트의 대상이 아니므로 신경 쓰지 않는다.

## 작성

1. 제목을 물어본다 (필수).
2. 카테고리를 물어본다 — 위 "공통: 카테고리는 `_data/category_hierarchy.yml`의
   leaf여야 함" 절차를 거친다. 유튜브 리뷰/정리 글이면 위 "공통: 시리즈 여부,
   유튜브 리뷰면 Trending 카테고리"에 따라 `Trending` 포함 여부도 물어본다.
2-1. 여러 편으로 나눠 쓰는 글이면 위 "공통: 시리즈 여부, 유튜브 리뷰면
   Trending 카테고리" 절차대로 `series`/`series_index`와
   `_data/series.yml` 등록을 함께 처리한다.
3. 태그(선택)를 물어본다. LaTeX 수식(`$...$`, `$$...$$`)을 쓰는 글이면
   front matter에 `mathjax: true`를 추가한다 — MathJax는 모든 페이지
   로딩 시 순간 노출되는 메시지 문제 때문에 전역 로드가 아니라
   `mathjax: true`가 있는 글에서만 로드되도록 되어 있다
   (`_includes/scripts.html`). 수식을 안 쓰면 이 필드 자체를 넣지 않는다.
4. 파일명용 slug를 정한다:
   - 제목이 영문이면 kebab-case로 자동 생성해서 제안하고 확인만 받는다.
   - 제목이 한글이거나 특수문자가 많으면 영문 slug를 따로 물어본다.
5. 날짜는 오늘 날짜(로컬 타임존, `+0900`)를 기본값으로 쓰고, 다른 날짜를
   원하면 물어본다.
6. `_posts/<올해 연도>/YYYY-MM-DD-slug.md` 파일을 다음 형식으로 생성한다
   (본문은 비워둔다 — 사용자가 직접 쓴다):

   ```yaml
   ---
   title: "<제목>"
   date: YYYY-MM-DD HH:MM:SS +0900
   categories: [Category, Subcategory]
   tags: [tag1, tag2]   # 태그 없으면 이 줄 생략
   mathjax: true        # LaTeX 수식 쓸 때만, 아니면 이 줄 생략
   ---
   ```

   `layout`(single), `permalink`, `author_profile`, `comments`, `toc`,
   `toc_sticky`, `read_time`, `share`, `related` 등은 `_config.yml`의
   `defaults`가 자동으로 채우므로 넣지 않는다. 사용자가 본문 내용을 미리
   줬으면 그대로 채우되, 위 "공통: 본문에 링크가 있으면 링크 확인",
   "공통: 스크린샷 필수, 유튜브는 임베드" 절차를 거친다.
7. 마무리하기 전에 위 "공통: 상단 메뉴 전체 점검" 표대로 훑는다 — 특히
   카테고리 leaf와(시리즈 글이면) `series`/`series_index`+`_data/series.yml`
   등록이 빠지지 않았는지.
8. 생성한 파일 경로를 알려주고, `_data/category_hierarchy.yml`이나
   `_data/series.yml`을 새로 고쳤다면 그것도 함께 알려주고 끝낸다.
   git add/commit/push는 하지 않는다 — 사용자가 본문을 쓰고 나서 직접
   커밋한다.

## 수정

1. 제목 일부나 키워드를 물어본다.
2. `_posts/` 전체에서 `title:` 필드와 파일명을 기준으로 검색한다:

   ```bash
   grep -rl "<키워드>" _posts/
   grep -rln "title:.*<키워드>" _posts/
   ```

3. 매치가 1개면 그 파일을 바로 열어서 사용자가 원하는 수정을 진행한다
   (Edit 툴 사용). 여러 개면 후보 목록(파일 경로 + title)을 보여주고
   어느 걸 수정할지 물어본다.
4. 수정 시 주의사항 (필요할 때만 언급):
   - `date:` (최초 작성일)는 바꾸지 않는다 — 바꾸면 아카이브/정렬 순서가
     틀어진다. 수정일은 `_plugins/posts-lastmod-hook.rb`가 git 커밋
     이력으로 자동 계산해서 "Updated" 표시를 만들어준다.
   - 카테고리를 바꾸는 경우 위 "공통: 카테고리는 `_data/category_hierarchy.yml`의
     leaf여야 함" 절차를 거친다.
   - 본문에 링크를 추가하거나 유지하는 경우 위 "공통: 본문에 링크가
     있으면 링크 확인" 절차를 거친다.
5. 수정 후 git commit/push는 자동으로 하지 않는다 — 사용자가 직접
   커밋한다 (원하면 커밋 메시지 제안 정도만 한다).

## 삭제

1. 제목 일부나 키워드를 물어본다.
2. "수정" 절의 2번과 동일한 방식으로 검색한다.
3. 매치가 1개면 파일 경로와 title을 보여주고 **"이 파일을 삭제해도
   될까?"**라고 명시적으로 확인받는다. 여러 개면 후보 목록을 보여주고
   먼저 어느 걸 지울지 고르게 한 다음, 고른 파일에 대해서도 다시 한번
   삭제 확인을 받는다.
4. 확인을 받기 전에는 절대 삭제하지 않는다. 확인받으면 `rm`으로 파일만
   지운다 (git rm이 아니어도 됨 — 어차피 커밋은 사용자가 직접 함).
5. 삭제 후 git commit/push는 자동으로 하지 않는다.
