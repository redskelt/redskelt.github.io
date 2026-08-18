---
title: "신규 API 만들기 — 스킬 4개 통합 가이드"
date: 2026-08-18 16:19:30 +0900
categories: [Dev]
tags: [API, CQRS, JPA]
---

새 테이블 하나로 동작하는 API 엔드포인트 하나를 처음부터 끝까지 만드는 흐름. 스킬 4개를 순서대로 씀.

```
SQL Server DDL (Extended Properties 포함)
    │
    ▼
[1] /convert-ddl-to-comment          ← SQL Server만, 필요할 때만
    │  sp_addextendedproperty → COMMENT 형식으로 정규화
    ▼
[2] /generate-entity-from-ddl
    │  Domain 모델 + Port + JPA Entity + Repository + Mapper (7개 파일)
    ▼
[3] /generating-cqrs-endpoints
    │  Controller + Request/Response DTO + UseCase 껍데기
    ▼
[4] /generating-pipeline-steps
    │  UseCase 껍데기 안을 loader/assembler/... 단계로 채움
    ▼
동작하는 API 엔드포인트 완성
```

## 각 단계 한 줄 요약

| 단계 | 스킬 | 하는 일 | 자세히 |
|---|---|---|---|
| 1 | `/convert-ddl-to-comment` | Extended Properties → COMMENT 변환 (SQL Server, 필요시만) | [가이드](01-ddl-comment-변환.md) |
| 2 | `/generate-entity-from-ddl` | DDL → Domain/Infrastructure 계층 7개 파일 | [가이드](02-ddl-엔티티-생성.md) |
| 3 | `/generating-cqrs-endpoints` | Controller + DTO + UseCase 껍데기 | [가이드](03-cqrs-엔드포인트-생성.md) |
| 4 | `/generating-pipeline-steps` | UseCase 로직을 단계별 구현체로 채움 | [가이드](04-파이프라인-스텝-생성.md) |

## 어디까지가 자동, 어디부터 사람 몫인가

- **자동 생성**: Domain 모델, Port, JPA Entity, Repository, Mapper, Controller, DTO, UseCase 뼈대, 각 단계 구현체 스켈레톤
- **사람이 채워야 하는 부분**: 각 step 구현체 안의 실제 비즈니스 규칙(어떤 조건으로 필터링할지, 어떤 필드를 조합할지 등) — 스킬은 정해진 패턴(재조회 방지, 병렬 조회, VineException 코드 등)만 강제하고 세부 로직까지 알아서 채우진 않음
- **매 단계 끝나면 `./gradlew compileJava`로 확인** — 타입 체인 안 맞으면 여기서 바로 드러남

## 한 번에 여러 개 만들고 싶다면

테이블/엔드포인트가 여러 개면 매번 손으로 반복하는 대신 `api-scaffold-batch` 스킬 사용. `.claude/skills/api-scaffold-batch/specs/*.yaml`에 spec 파일들(도메인, DDL, endpoint, flow 단계)을 넣어두면 2·3·4번 단계(엔티티 생성 → sealed interface+엔드포인트 → 파이프라인 스텝 구현)를 배치로 돌리고 컴파일 결과까지 리포트로 정리해줌. 1번(`convert-ddl-to-comment`)은 별도 단계로 부르지 않아도 됨 — DDL이 Extended Properties 형식이면 엔티티 생성 단계 안에서 알아서 먼저 변환하고 넘어감. 스펙 예시는 그 폴더의 `example-*.yaml` 참고.

## 막힐 때

| 상황 | 봐야 할 문서 |
|---|---|
| Extended Properties 파싱 실패 | [1번 가이드 "안 될 때"](01-ddl-comment-변환.md#안-될-때) |
| 새 도메인인데 엔티티가 DB에서 안 읽힘 | [2번 가이드 "알아둘 것"](02-ddl-엔티티-생성.md#알아둘-것) — 엔티티/레포지토리 스캔 패키지 등록 누락 |
| Controller 타입/제너릭 헷갈림 | [3번 가이드 "자주 하는 실수"](03-cqrs-엔드포인트-생성.md#자주-하는-실수) |
| Pipeline 컴파일 에러 | [4번 가이드 "핵심 규칙"](04-파이프라인-스텝-생성.md#핵심-규칙-안-지키면-버그남) — step 순서/타입 불일치 |
