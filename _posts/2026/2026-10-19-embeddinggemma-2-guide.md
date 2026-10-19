---
title: "EmbeddingGemma 2 설치부터 한국어 비교까지 — 내 PC에서 사진·영상·소리까지 찾는 무료 임베딩 모델"
date: 2026-10-19 14:20:00 +0900
categories: [AI]
tags: [EmbeddingGemma, Gemma, 임베딩, RAG, ClaudeCode, 멀티모달]
---

Google DeepMind가 10월 6일 공개한 멀티모달 임베딩 모델 **EmbeddingGemma 2**를 정리합니다. 바탕으로 삼은 영상은 잔재미코딩(DaveLee)의 "미친 구글 무료 AI, 임베딩 모델 EmbeddingGemma 2 설치부터 사용법까지 깔끔 정리"(2026-10-14, 13분 50초)입니다. 클로드 코드(Anthropic의 터미널용 AI 코딩 도구)로 설치·색인·검색을 처음부터 해 보고, 경쟁 모델들과 **한국어로** 직접 비교한 영상입니다. 영상 내용을 따라가면서, 숫자와 사양은 공식 모델 카드·Google 블로그·Ollama·DigUp 저장소와 하나씩 대조했습니다.

{% include video id="OtQW4s7DJ1Y" provider="youtube" %}

## 영상의 첫 장면: 내 영상 150개에서 장면 찾기

![DigUp 검색 창에 '슈퍼마리오 게임을 AI가 하는 장면'을 입력하자 영상 파일과 1분 57초 지점을 찾아 준 화면](/assets/img/posts/embeddinggemma-2-guide/05-digup-demo.jpg)

영상은 결과부터 보여 줍니다. 맥에 설치한 검색 앱에 "AI가 슈퍼마리오를 하는 장면"이라고 한국어로 쓰자, 본인이 만든 영상 150개 가운데 그 장면이 나오는 영상과 **시각(1분 57초)**까지 찾아 줍니다. 파일 이름이 아니라 영상 속 화면을 보고 찾은 것입니다. 이 앱(DigUp)이 돌리는 모델이 EmbeddingGemma 2입니다.

### 임베딩 모델이 하는 일

임베딩 모델은 글이나 사진의 **뜻을 숫자 목록(벡터)으로 바꿉니다.** 뜻이 비슷하면 숫자도 가까워지므로, 단어가 달라도 뜻으로 찾을 수 있습니다. 1세대 EmbeddingGemma는 글만 이해했는데, 2세대는 **사진·영상·소리까지 같은 숫자 공간에** 넣습니다. 그래서 "기린이 나뭇잎을 먹는 장면"이라는 글로 영상 속 장면을 찾을 수 있습니다.

## EmbeddingGemma 2 사양 (공식 문서 기준)

![Google 블로그의 EmbeddingGemma 2 발표 글](/assets/img/posts/embeddinggemma-2-guide/01-launch-blog.png)

[Google 발표 블로그](https://blog.google/innovation-and-ai/technology/developers-tools/embeddinggemma-2)와 [Hugging Face 모델 카드](https://huggingface.co/google/embeddinggemma-2)의 내용을 정리했습니다.

![Hugging Face 모델 카드의 Model Overview 표. 전체 740M, 백본 130M, 임베더 140M, 시각 170M, 오디오 300M, 컨텍스트 8,192 토큰](/assets/img/posts/embeddinggemma-2-guide/02-hf-model-card.png)

| 항목 | 내용 |
|---|---|
| 다루는 자료 | 글(코드 포함), 사진, 영상, 소리. 섞어서 한 번에 넣을 수도 있음 |
| 파라미터 | 전체 **740M** = 글 모델 270M(트랜스포머 130M + 임베더 140M) + 시각 인코더 170M + 오디오 인코더 300M |
| 출력 | 768차원. 앞쪽 512·256·128차원만 잘라 써도 됨(Matryoshka 표현 학습. 중요한 정보가 앞쪽 차원에 몰리도록 학습해서, 잘라도 품질이 크게 떨어지지 않음. 저장 공간 최대 6분의 1) |
| 입력 한도 | 8,192 토큰 공유. 글만이면 8,192토큰, 사진만이면 약 29장, 영상만이면 약 58프레임, 소리만이면 약 327초 |
| 언어 | 100개 이상 |
| 라이선스 | **Apache 2.0**(상업적 이용 가능) |
| 기반 | Gemma 4 아키텍처 |

필요한 것만 골라 올릴 수 있다는 점이 실용적입니다. 모델 카드의 표대로, 쓰는 자료에 따라 실제 크기가 달라집니다.

| 켜는 기능 | 실제 크기 |
|---|---|
| 글만 | 270M |
| 글 + 사진 | 440M |
| 글 + 소리 | 570M |
| 전부 | 740M |

## 설치 방법 ①: Ollama

![Ollama의 embeddinggemma-2 페이지. latest와 740m은 1.3GB에 Text, Image, 270m은 Text, 440m은 Text, Image, 570m은 Text로 표시](/assets/img/posts/embeddinggemma-2-guide/03-ollama-tags.png)

[Ollama](https://ollama.com/library/embeddinggemma-2)를 설치했다면 한 줄이면 됩니다. 이름에 하이픈이 들어갑니다. `embeddinggemma`(하이픈 없음)는 1세대 모델입니다.

```bash
ollama pull embeddinggemma-2          # 기본(740m, 1.3GB)
ollama pull embeddinggemma-2:270m     # 글만 쓸 때(304~378MB)
```

다만 영상의 지적대로 **Ollama판은 현재 글과 사진만 받습니다.** Ollama 페이지의 표에도 오디오가 포함된 570m과 740m 태그의 입력 칸이 "Text" 또는 "Text, Image"로만 나옵니다. 영상과 소리까지 쓰려면 다음 방법이 필요합니다.

## 설치 방법 ②: 클로드 코드에 맡기기

영상이 "가장 쉬운 방법"으로 권하는 길입니다. 새 폴더를 만들고 그 안에서 클로드 코드를 실행합니다.

```bash
mkdir embeddinggemma2-demo && cd embeddinggemma2-demo
claude --dangerously-skip-permissions
```

`--dangerously-skip-permissions`는 클로드 코드가 중간에 허락을 묻지 않고 끝까지 진행하게 하는 옵션입니다. 편하지만 위험하므로 **이렇게 새로 만든 전용 폴더에서만** 쓰세요.

그리고 이렇게 요청합니다.

```text
EmbeddingGemma 2를 이 폴더에 내 맥에 맞게 설치해 줘
```

![클로드 코드가 설치 확인 스크립트(check_install.py)를 작성하고 실행하는 장면. 아래에 칩·메모리 확인, 공식 설치법 검색, 폴더 안 가상 환경, 모델 1.4GB 순서가 표시됨](/assets/img/posts/embeddinggemma-2-guide/06-claude-install.jpg)

클로드 코드가 한 일은 다음과 같습니다.

1. 맥의 칩과 메모리를 확인합니다.
2. Google의 공식 설치 방법을 찾아봅니다.
3. 폴더 안에 파이썬 가상 환경을 만들고 필요한 프로그램을 설치합니다.
4. 모델 파일 **1.4GB**를 로그인 없이 내려받습니다.
5. 글·사진·녹음·영상이 맥 GPU(애플 실리콘의 GPU 가속 기능인 MPS)에서 실제로 처리되는지 시험합니다.

프롬프트 한 줄로 여기까지 **약 5분**이 걸렸습니다.

### 직접 설치한다면: 공식 빠른 시작

클로드 코드 없이 파이썬으로 쓴다면, 모델 카드의 빠른 시작이 가장 짧은 경로입니다.

```bash
pip install -U sentence-transformers transformers
```

```python
from sentence_transformers import SentenceTransformer

model = SentenceTransformer("google/embeddinggemma-2")

query = "What causes the northern lights?"
document = "The northern lights are caused by charged particles from the sun."

query_emb = model.encode(query, prompt_name="SearchQuery")
doc_emb = model.encode(document, prompt_name="Document")
print(model.similarity(query_emb, doc_emb))
```

공식 문서가 강조하는 주의 사항 세 가지입니다.

- **float16을 쓰지 마세요.** 모델 카드는 "float16에서는 오류 대신 NaN(계산할 수 없는 값)이나 품질이 떨어진 임베딩을 조용히 돌려준다"고 경고합니다. `bfloat16`이나 `float32`를 씁니다.
- **글에는 작업 접두어를 붙입니다.** 검색 질문에는 `task: search result | query: {질문}`, 문서에는 `title: {제목} | text: {내용}` 형식입니다. 위 코드의 `prompt_name`이 이것을 자동으로 붙여 줍니다. 사진·영상·소리에는 붙이지 않습니다.
- **안 쓰는 인코더는 끕니다.** 글만 쓴다면 `config_kwargs={"vision_config": None, "audio_config": None}`으로 글 모델(270M)만 메모리에 올라와 가볍게 돌아갑니다.

## 색인: 검색하기 전에 해 둘 일

![색인 설명 그림. PDF 쪽, 사진, 녹음, 영상이 각각 숫자 목록으로 바뀌어 저장되고, 질문도 숫자로 바뀌어 비교된다](/assets/img/posts/embeddinggemma-2-guide/07-index-concept.jpg)

설치했다고 바로 검색할 수 있는 건 아닙니다. 먼저 **색인**을 해야 합니다. 파일마다 내용을 숫자로 바꿔 저장해 두는 일입니다. 이렇게 해 두면 검색할 때마다 파일을 다시 열 필요 없이, 질문과 뜻이 가까운 숫자만 골라내면 됩니다.

![시험용 자료 폴더. PDF 64개, 사진 43장, 스크린샷 13장, 녹음 27개에 영상과 메모까지 모두 158개가 섞여 있다](/assets/img/posts/embeddinggemma-2-guide/08-sample-folder.jpg)

시험용 자료 폴더에는 PDF, 사진, 스크린샷, 녹음, 영상, 메모 **158개**를 섞어 두었습니다. PDF를 뺀 나머지는 `IMG_1001`이나 `memo_01`처럼 **이름만 봐서는 내용을 알 수 없게** 바꿔 두었습니다. 파일 이름이 아니라 내용으로 찾는지 시험하려는 것입니다.

![클로드 코드에 '내자료 폴더에 있는 파일을 모두 EmbeddingGemma 2로 색인해 줘. 문서, 사진, 영상, 녹음이 섞여 있어'라고 요청하는 장면](/assets/img/posts/embeddinggemma-2-guide/09-index-prompt.jpg)

색인도 클로드 코드에 맡겼고, 클로드 코드는 색인 프로그램을 직접 짜서 돌렸습니다. 자료 종류마다 넣는 방식이 다릅니다.

| 자료 | 넣는 방식 |
|---|---|
| PDF | 쪽마다 글을 뽑아 넣음. 글자가 거의 없는 스캔 페이지는 **페이지를 통째로 이미지로** 넣음 |
| 녹음 | **30초씩 겹쳐 가며** 잘라서 넣음 |
| 영상 | 30초씩 자르고, **화면과 소리를 따로** 넣음 |
| 사진·스크린샷 | 그대로 넣음 |

녹음을 30초씩 자른 이유가 흥미롭습니다. 클로드 코드가 **녹음을 통째로 넣으면 앞 30초만 반영된다는 것을 직접 시험해 보고** 정한 방식이라고 합니다. 공식 모델 카드는 오디오를 "초당 25토큰, 최대 약 327초"까지 받는다고 적고 있어 얼핏 다릅니다. 하지만 같은 모델로 만든 DigUp의 README도 "모델은 한 번에 30초씩 듣는다(the model listens to 30 seconds at a time)"며 30초 단위로 겹쳐 자른다고 설명합니다. 입력 한도와 실제로 한 번에 반영되는 길이는 다를 수 있으니, **긴 녹음은 30초 단위로 자르는 것**이 안전합니다.

클로드 코드는 중간에 영상 하나가 오류로 빠지자 원인을 찾아 그 파일만 다시 색인했고, 정답을 아는 질문 25개를 만들어 검색 품질까지 스스로 점검했습니다. 색인 자체는 약 9분, 프로그램을 짜고 점검하는 시간까지 합치면 약 20분이 걸렸습니다.

## 검색: 말로 물으면 된다

![클로드 코드가 '나뭇잎을 먹는 기린이 나오는 장면'을 찾아 video_01.mp4의 2분 37초부터 2분 51초 구간을 확인한 결과](/assets/img/posts/embeddinggemma-2-guide/10-giraffe-search.jpg)

찾을 때도 클로드 코드에 말로 묻습니다. 영상의 예시들입니다.

| 질문 | 결과 |
|---|---|
| "나뭇잎을 먹는 기린이 나오는 장면" | 3분 54초짜리 영상에서 **2분 37초** 장면. 검색으로 근처 30초 구간을 찾은 뒤, 클로드 코드가 화면을 직접 뽑아 정확한 시각까지 확인 |
| "AI가 항공권 검색을 끝낸 이야기가 나오는 녹음" | 녹음 `memo_07`을 1위로 찾고, 같은 내용을 적은 메모도 함께 찾음. 둘 다 파일 이름에는 단서가 없음 |
| "결제가 거절된 오류 화면" | 이미지만 놓고 찾으면 1위. 종류를 정하지 않고 전체에서 찾으면 PDF에 밀려 **11위** |
| "대장암 예방을 위해 무엇을 먹어야 하는지 나온 문서" | PDF 64개 가운데 대장암 책자 17쪽을 1위로 찾음 |

세 번째 예가 실전 팁입니다. 클로드 코드는 "**화면이나 사진은 종류를 정해서 찾으라**"고 먼저 짚어 줬습니다. 여러 종류의 자료가 섞인 색인에서는 종류를 거르면 정확도가 크게 올라갑니다. 검색 한 번은 약 5초면 끝납니다.

## 더 쉬운 길: DigUp 앱

![GitHub의 ARahim3/DigUp 저장소. 사진, PDF, 녹음, 영상, 코드를 내용으로 찾는 앱으로 EmbeddingGemma 2 기반](/assets/img/posts/embeddinggemma-2-guide/04-digup-github.png)

설치와 색인이 번거롭다면 [DigUp](https://github.com/ARahim3/DigUp)을 쓰면 됩니다. 영상 첫 장면의 검색 앱이 바로 이것입니다. 한 개발자가 이 모델로 만들어 무료(MIT 라이선스)로 공개했고, 영상은 "공개 일주일 만에 별 2,000개를 넘었다"고 소개합니다. 이 글을 쓰는 시점(10-19)에는 4,800개를 넘었습니다.

![DigUp에서 '해바라기'를 검색하자 사진 종류 결과에 해바라기 사진들이 나온 화면](/assets/img/posts/embeddinggemma-2-guide/11-digup-search.jpg)

DigUp README와 영상의 내용을 합치면 이렇습니다.

| 항목 | 내용 |
|---|---|
| 사용법 | 폴더만 고르면 색인과 검색을 앱이 알아서 함 |
| 모델 | 처음 한 번 **865MB** 내려받음. 원본(1.4GB)을 8비트로 줄인 빌드를 llama.cpp로 돌리기 때문(글 310MB + 이미지·오디오 인코더 555MB) |
| 단축키 | 아무 앱에서나 맥은 **⇧⌘Space**, Windows·Linux는 **Ctrl+Shift+Space** |
| 정확도 | 사진·영상·소리처럼 종류 탭을 고르면 더 정확 |
| 개인정보 | 색인한 내용은 컴퓨터 밖으로 나가지 않음. 인터넷은 모델 내려받기와 하루 한 번 업데이트 확인에만 씀(끌 수 있음) |
| 지원 환경 | 맥은 애플 실리콘 + macOS 14 이상. **Windows와 Linux는 베타** |

영상(10-14)은 "DigUp은 애플 실리콘 맥 전용이라 윈도우에서는 아직 쓸 수 없다"고 했지만, 지금은 **Windows와 Linux 베타 버전**이 나와 있습니다. README에 따르면 키, 인증서, 비밀번호 파일, `.ssh` 같은 숨김 폴더는 읽지 않습니다.

## 성능: Google 발표 수치

![영상이 보여 준 Google 발표 성능표. EmbeddingGemma 2, 1세대 EmbeddingGemma, Jina v5 Omni-Nano, Qwen3-Embedding-0.6B, SigLIP, CLAP을 비교](/assets/img/posts/embeddinggemma-2-guide/12-google-table.jpg)

영상은 Google이 발표한 성능표로 시작합니다. 표의 MTEB(글·코드), MIEB(사진), MMEB(사진·문서 이미지·영상), MAEB(소리)는 모두 임베딩 모델의 검색·분류 성능을 재는 공개 벤치마크 이름입니다. EmbeddingGemma 2의 점수는 모델 카드와 모두 일치합니다(카드는 소수 둘째 자리까지 표기). 경쟁 모델 점수는 영상의 표에서 옮겼으며, 모델 카드 본문에는 없어 따로 확인하지 못했습니다.

| 분야(벤치마크) | EmbeddingGemma 2 | 비교 |
|---|---|---|
| 코드 검색(MTEB Code v1) | **78.7** | 1세대 68.8(+9.92), Qwen3-Embedding-0.6B 75.4 |
| 글 검색(MTEB 다국어 v2) | 61.4 | **Qwen3-Embedding-0.6B 64.3**이 더 높음 |
| 사진(MIEB lite) | **64.6** | SigLIP 53.5, Jina 49.4 |
| 문서 이미지(MMEB VisDoc) | 67.8 | **Jina 71.4**가 더 높음 |
| 영상(MMEB Video) | **50.7** | Jina 31.2 |
| 생활 소리(MAEB) | 49.4 | **Jina 50.1**이 조금 더 높음 |

코드 9.92점 상승은 [Google 블로그](https://blog.google/innovation-and-ai/technology/developers-tools/embeddinggemma-2)도 같은 숫자(68.76 → 78.68)로 밝힙니다. 다만 **글 검색은 Qwen3가 더 높다**는 점이 눈에 띕니다. 그리고 이 시험들은 영어 위주라서, 영상은 한국어로 직접 다시 시험했습니다.

## 한국어로 직접 비교한 결과

비교 대상은 Google 표에 나온 Qwen3 임베딩 0.6B, Jina v5 Omni, SigLIP, CLAP에 더해, Qwen3 임베딩 4B·8B(영상에는 8B 결과만 나옵니다), 사진과 영상까지 다루는 Qwen3-VL 임베딩 2B, 다국어판 SigLIP 2, 한국어 검색에 많이 쓰는 bge-m3와 KURE입니다. 모델을 내려받고 시험 코드를 짜서 돌리는 일은 모두 클로드 코드에 맡겼습니다. 그리고 **각 시험마다 그 자료를 다룰 수 있는 모델끼리만** 비교했습니다.

### ① 한국어 문서 검색 (RAG)

RAG(검색 증강 생성)는 질문과 관련된 문서를 먼저 찾아서 AI의 답변 근거로 넣는 방식입니다. 임베딩 모델은 이 "찾는" 단계를 맡습니다.

![한국어 문서 300문항 결과 막대그래프. EmbeddingGemma 2 77%, Qwen3 0.6B 75%, Jina 77%, bge-m3 76%, Qwen3-VL 2B 77%](/assets/img/posts/embeddinggemma-2-guide/13-korean-docs.jpg)

금융·공공·의료·법률·커머스 분야의 PDF 64개(1,450쪽)에 질문 300개를 던져, 정답 쪽이 **상위 5개 안에** 드는 비율을 쟀습니다.

| 모델 | 정답 비율 |
|---|---|
| **KURE**(한국어 전용), **Qwen3 임베딩 8B** | 79% |
| EmbeddingGemma 2, Jina v5 Omni, Qwen3-VL 임베딩 2B | 77% |
| bge-m3 | 76% |
| Qwen3 임베딩 0.6B | 75% |

Google 표에서는 Qwen3 0.6B가 3점 가까이 앞섰지만, 한국어 문서에서는 **EmbeddingGemma 2가 조금 높았습니다.** 크기가 10배쯤 되는 Qwen3 8B는 79%로 조금 더 높았는데, 같은 1,450쪽을 색인하는 데 **EmbeddingGemma 2는 1분 남짓, Qwen3 8B는 1시간 가까이** 걸렸습니다.

글자를 뽑기 어려운 스캔 문서라면 쪽을 그림으로 통째로 넣을 수도 있습니다.

![같은 1,450쪽을 그림으로만 넣었을 때 결과. EmbeddingGemma 2 72%, Qwen3-VL 2B 62%, Jina 32%. Google 표에서는 Jina 71.4, EmbeddingGemma 2 67.8로 반대](/assets/img/posts/embeddinggemma-2-guide/14-page-as-image.jpg)

같은 1,450쪽을 그림으로만 넣었더니 EmbeddingGemma 2는 해상도를 높였을 때 **72%**까지 찾았습니다. Qwen3-VL 2B는 62%, Jina는 32%였습니다. Google 표에서는 이 분야에서 Jina(71.4)가 EmbeddingGemma 2(67.8)보다 높았지만, **한국어 페이지에서는 결과가 반대**였습니다. 모델 카드에 따르면 사진 한 장의 토큰 수를 70~1,120 사이로 조절할 수 있어서, 해상도를 높이면 세밀한 글자를 더 잘 읽습니다.

### ② 사진

Google이 공개한 다국어 사진 평가 자료에서 사진 3,600장과 사람이 쓴 한국어 설명을 가져와, 설명만 보고 맞는 사진을 **1등으로** 찾는 비율을 쟀습니다.

| 모델 | 1등 비율 |
|---|---|
| Qwen3-VL 임베딩 2B (크기 약 3배) | 63% |
| **EmbeddingGemma 2** | **62%** |
| SigLIP 2 (다국어) | 57% |
| Jina v5 Omni | 27% |
| SigLIP (영어 위주) | 영어로 물으면 53%, **한국어로 물으면 4%** |

### ③ 영상 장면

![영상 장면 검색 결과. 48개 장면 중 1등으로 찾은 수 EmbeddingGemma 2 41개, Qwen3-VL 2B 35개, Jina 30개, SigLIP 2 25개](/assets/img/posts/embeddinggemma-2-guide/15-video-scenes.jpg)

본인 채널의 롱폼 3편과 쇼츠 21편(합쳐서 1시간 남짓)에서 2초마다 화면을 뽑아 두고, 장면 48개를 한국어로 물었습니다. **EmbeddingGemma 2가 41개**를 1등으로 찾았고, Qwen3-VL 2B 35개, Jina 30개, SigLIP 2 25개였습니다. Google 표(50.7 vs Jina 31.2)와 비슷한 차이가 한국어에서도 났습니다.

### ④ 말소리와 생활 소리

| 시험 | EmbeddingGemma 2 | 비교 |
|---|---|---|
| 한국어 문장 녹음 382개를 그 문장으로 찾기(1등) | **98%** | Jina 93% |
| 10분 안팎 내레이션에서 특정 30초 구간 찾기 | 60% | Jina 60%. 같은 녹음을 **받아쓴 글로 찾으면 85%** |

긴 녹음은 **받아쓰기 글도 함께 색인**해 두면 더 잘 찾는다는 실용적인 결론입니다.

![생활 소리 검색 결과. 상위 10개 중 맞는 소리 평균 EmbeddingGemma 2 2.6개, CLAP 영어 9.5개, CLAP 한국어 0.4개, Jina 6.1개](/assets/img/posts/embeddinggemma-2-guide/16-env-sound.jpg)

개 짖는 소리나 빗소리 같은 **생활 소리는 아쉬웠습니다.** 소리 50종류 2,000개를 한국어 설명으로 찾게 했더니, 상위 10개 중 맞는 소리가 평균 **2.6개**였습니다. 소리 전용 모델 CLAP은 영어로 물으면 9.5개였지만 한국어로 물으면 0.4개로 떨어졌고, 한국어로는 **Jina가 6.1개**로 가장 잘 찾았습니다.

### ⑤ 코드

본인이 영상 작업에 쓰는 파이썬 도구 130개를 "녹음에서 긴 무음을 줄이는 코드"처럼 50번 물어 찾았습니다.

| 질문 언어 | EmbeddingGemma 2 | 1세대 EmbeddingGemma | Qwen3 임베딩 0.6B | bge-m3 |
|---|---|---|---|---|
| 영어 | 90% | - | 92% | 90% |
| 한국어 | **66%** | 82% | 80% | - |

코드 검색은 **영어로 물어보는 편이 훨씬 정확**했고, 한국어 질문에서는 오히려 1세대가 더 나았습니다. Google이 내세운 코드 점수 상승은 영어 질문 기준이라는 점을 기억해 둘 만합니다.

### ⑥ 종류가 섞인 폴더

앞에서 색인한 파일 158개 폴더에서, 앱처럼 종류를 고른 뒤 한국어로 64번 물었습니다. 네 종류(글·사진·영상·소리)를 모두 다루는 모델은 EmbeddingGemma 2와 Jina뿐인데, **EmbeddingGemma 2 84%, Jina 69%**였습니다.

## 정리

영상의 결론을 공식 문서와 함께 정리하면 이렇습니다.

| 관점 | 결론 |
|---|---|
| 한국어 글 | 모델마다 큰 차이가 없음. 10배 큰 Qwen3 8B도 조금 더 정확한 정도이고, 색인 속도는 EmbeddingGemma 2가 압도적 |
| 사진·영상·말소리 | **한 모델로 모두 고르게 잘함.** 이것이 EmbeddingGemma 2의 가장 큰 장점 |
| 모델 파일 | 1.4GB. 약 4GB인 Qwen3-VL 임베딩 2B의 3분의 1 정도 |
| 생활 소리 | Jina v5 Omni가 가장 잘 찾았지만 **비상업용 라이선스**(CC-BY-NC-4.0)라 회사 일이나 수익 서비스에는 쓸 수 없음 |
| 코드 | 영어로 물을 것 |

**시작하는 순서를 제안하면:**

1. 그냥 써 보고 싶다면 **DigUp**을 설치하고 폴더를 고릅니다(맥은 정식, Windows·Linux는 베타).
2. 글과 사진만 다룬다면 **Ollama**의 `embeddinggemma-2`가 가장 간단합니다.
3. 영상과 소리까지 직접 다루려면 **sentence-transformers**로 씁니다. 클로드 코드에 "내 PC에 맞게 설치해 줘"라고 맡기면 5분이면 됩니다. `float16`은 피하고, 긴 녹음은 30초 단위로 자르세요.
4. 한국어 문서 RAG만 필요하다면 KURE나 bge-m3도 충분히 좋은 선택이고, 사진·영상까지 한 색인에 넣고 싶을 때 EmbeddingGemma 2가 빛납니다.

---

**이 글의 확인 방법**: 영상의 대사는 로컬 음성 인식(whisper.cpp)으로 받아 적었고, 한국어 시험 수치는 대사와 영상 화면의 그래프를 대조해 옮겼습니다. 모델 사양, 입력 한도, 사용법 주의 사항은 Hugging Face 모델 카드와 Google 발표 블로그 원문으로, Ollama 태그와 입력 종류는 Ollama 페이지로, DigUp의 지원 환경·단축키·개인정보 처리는 DigUp README로, 라이선스는 Hugging Face의 모델 정보로 확인했습니다. 한국어 비교는 영상 제작자 한 사람이 직접 만든 시험이므로, 자기 자료로 다시 확인해 보는 것을 권합니다.
