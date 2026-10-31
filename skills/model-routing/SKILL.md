---
name: model-routing
description: Codex 에서 6.1 Sol, 5.6 Terra, 6.0 Luna 중 어떤 모델과 reasoning effort 로 작업할지 정할 때 사용. 작업 유형별 추천 모델, 전환 시점, 토큰 절약 요령.
---

# Model Routing (Sol / Terra / Luna)

사용량이 평가에 참고되므로 "어려운 판단은 큰 모델, 양 많은 단순 작업은 작은 모델"로 나눈다.
Codex 안에서 `/model` 로 바꾼다.

## 티어 요약
| 모델 | 체급 | Claude 대응 | 언제 |
|---|---|---|---|
| **6.1 Sol** | 플래그십 | Opus 급 | 설계, 전략, 원인 모를 버그, 최종 리뷰 |
| **5.6 Terra** | 균형형 | Sonnet 급 | 대부분의 구현 (기본값) |
| **6.0 Luna** | 경량·고속 | Haiku 급 | 반복·단순·대량 작업 |

## 작업별 매칭
| 작업 | 모델 | effort |
|---|---|---|
| 과제 해부, PLAN.md, 검증 전략 설계 (`$hackathon-kickoff`) | Sol | high |
| 모델링 방향 결정, 피처 아이디어, 리크 의심 점검 | Sol | high |
| EDA 스크립트, baseline, 피처 코드, 학습 루프 | Terra | medium |
| 웹앱/API 구현, UI 연결 | Terra | medium |
| 테스트 작성, 일반 버그 수정 | Terra | medium |
| 2번 이상 실패한 버그 (`$systematic-debugging`) | Sol | high |
| README, 주석, docstring, 포맷, 변수명 정리 | Luna | low |
| 로그/에러 메시지 요약, 단순 grep·파일 탐색 | Luna | low |
| 결과 표 정리, 커밋 메시지 | Luna | low |
| 최종 제출 점검 (`$submission-check`) | Sol | medium |

## 전환 규칙
- 기본은 Terra. Terra 가 같은 문제에 두 번 틀리면 Sol 로 올린다.
- Sol 로 방향을 정했으면 구현은 다시 Terra 로 내려서 한다.
- 결과 예측이 쉬운 기계적 작업은 Luna. 결과를 한 번 훑어보고 이상하면 Terra 로 다시.
- effort 를 max/ultra 로 올리는 건 정말 막혔을 때 한 번만.

## 토큰 절약
- 데이터·로그는 `head`, `wc -l`, `describe()` 결과만 보여준다.
- "전체 파일 다시 써줘" 대신 "이 함수만 고쳐줘"처럼 범위를 좁혀 요청한다.
- 긴 대화가 산으로 가면 PLAN.md 를 갱신하고 새 세션에서 이어간다.
