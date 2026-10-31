---
name: data-task-playbook
description: 표 형식·센서·시계열·공정 로그 데이터로 예측, 분류, 회귀, 이상탐지, 원인 분석을 할 때 사용. EDA부터 검증 설계, baseline, 개선, 결과 보고까지의 순서와 함정 체크리스트. 반도체 공정 데이터(웨이퍼, 로트, 장비, 수율, 결함) 특유의 주의점 포함.
---

# Data Task Playbook

원칙: **검증 설계가 모델보다 먼저다.** 잘못 나눈 validation 위의 좋은 점수는 의미가 없다.

## 0. 환경
```bash
python -c "import pandas, sklearn, numpy; print(pandas.__version__, sklearn.__version__)"
```
없는 것만 설치. lightgbm/xgboost 는 import 실패하면 sklearn `HistGradientBoosting*` 으로 대체한다.

## 1. 빠른 EDA (출력은 짧게)
`eda.py` 하나로 아래를 출력하고 결과를 `outputs/eda.txt` 에 저장한다. 데이터 전체를 화면에 찍지 않는다.
- shape, dtypes, 결측률 상위 20개, 중복 행 수
- 타깃 분포 (분류면 클래스 비율, 회귀면 describe + 왜도)
- ID성 컬럼(고유값 비율 > 0.95), 상수 컬럼, 고상관 쌍(|r| > 0.95)
- 시간 컬럼이 있으면 기간, 간격, 시간대별 타깃 추이
- 그룹 컬럼(wafer_id, lot_id, equipment, chamber, recipe 등) 후보와 그룹별 행 수

자세한 기법은 `$exploratory-data-analysis`, 시각화는 `$seaborn` / `$matplotlib` 참고.

## 2. 검증 설계 (가장 중요)
| 데이터 특징 | 분할 방법 |
|---|---|
| 독립 행 | StratifiedKFold(5) |
| 같은 웨이퍼/로트/장비가 여러 행 | GroupKFold — 그룹 단위로 분리 |
| 시간 순서가 의미 있음 (센서, 공정 이력) | TimeSeriesSplit 또는 마지막 구간 holdout |
| test 가 미래 기간/새 장비 | valid 도 똑같이 "미래/미지" 조건으로 |

리크 체크: 타깃 생성 후에야 알 수 있는 컬럼(검사 결과, 사후 판정), 타깃과 상관이 비정상적으로 높은 컬럼, ID에 순서 정보가 들어간 경우.

## 3. Baseline (45분 안에 제출 가능 상태)
1. 더미 baseline (최빈값/평균) 점수 기록
2. GBDT 하나 (LightGBM → 없으면 HistGradientBoosting), 기본 파라미터
3. 과제 지정 지표로 CV 점수 기록 → `outputs/results.md` 표에 누적
4. 제출 파일 형식으로 저장하고 형식 검증까지 한다

## 4. 개선 (효과 큰 순서)
1. 피처: 그룹 집계(mean/std/min/max), 시계열 lag·rolling·diff, 센서 간 비율/차이, 공정 단계별 통계
2. 불균형: class_weight, 임계값 튜닝(PR 곡선), 필요 시 under-sampling. SMOTE 는 CV 안에서만
3. 하이퍼파라미터: 시간 남을 때만, n_trials 작게
4. 앙상블: 서로 다른 모델 2–3개 평균. 마지막 30분엔 하지 않는다

실험마다 `results.md` 에 한 줄: `| 실험 | CV 평균 ± std | 변경점 | 시간 |`. 점수가 안 오르면 되돌린다.

## 5. 이상탐지 (라벨 없음/적음)
- 먼저 규칙 기반: 관리한계(mean ± 3σ), IQR, 장비/레시피별 기준 따로
- 다음 IsolationForest / LOF, 피처는 스케일링 후
- 라벨이 조금 있으면 그걸로 임계값과 precision@k 를 검증한다

## 6. 해석·보고
- 피처 중요도 + `$shap` 요약 플롯 1장
- "무엇을 바꾸면 결과가 좋아지는가"를 도메인 언어(공정 단계, 장비, 파라미터)로 3줄 요약
- 숫자는 실제 실행 결과만. 실행 안 한 개선 효과를 추정해서 쓰지 않는다

## 반도체 데이터 주의점
- 웨이퍼 맵: 좌표(x, y) → 반경 r, 각도 θ, edge 여부 피처가 효과적. 패턴(center/edge/ring/scratch) 분류는 CNN 보다 집계 피처 + GBDT 가 4시간 안에 안전하다
- 장비/챔버 간 offset 이 크면 그룹별 정규화(그룹 평균 빼기)를 검토
- 수율·결함은 대개 강한 불균형 → PR-AUC, F1, recall@고정 precision
- FDC 센서 시계열은 step 단위로 잘라 step별 통계를 낸다
