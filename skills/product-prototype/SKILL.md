---
name: product-prototype
description: 해커톤에서 새 서비스, 웹 데모, AI 에이전트, LLM 기반 도구, 대시보드를 짧은 시간 안에 만들 때 사용. 범위 자르기, 스택 선택, 폴더 구조, 데모 검증 순서를 정한다. 순수 데이터 분석 과제에는 data-task-playbook 을 쓴다.
---

# Product Prototype

원칙: **핵심 시나리오 1개가 끝까지 동작하는 것**이 기능 5개가 반쯤 되는 것보다 낫다.

## 1. 범위 자르기 (10분)
`BRIEF.md` 아래에 적는다.
- 사용자: 누가 (예: 공정 엔지니어, 설비 담당자)
- 핵심 시나리오 1개: "사용자가 X 를 넣으면 Y 를 보고 Z 를 결정한다"
- Must (데모에 반드시) 3개 이하 / Nice (시간 남으면) / Won't (이번엔 안 함)

## 2. 스택 (익숙한 것, 설치 적은 것)
| 목적 | 1순위 | 대안 |
|---|---|---|
| 데이터 데모/대시보드 | Streamlit | Gradio |
| API | FastAPI | Flask |
| 화면이 중요한 웹 | 단일 HTML + JS (빌드 없음) | Vite + React |
| LLM 호출 | 과제에서 제공한 SDK/엔드포인트 | - |
| 저장 | 파일(json/csv) 또는 SQLite | - |

DB 서버, 인증, Docker 는 과제가 요구할 때만.

## 3. 구조
```
app/
  main.py        # 진입점 (streamlit run app/main.py 또는 uvicorn)
  core.py        # 로직 (UI 와 분리 → 테스트 가능)
  prompts.py     # LLM 프롬프트 상수
tests/test_core.py
README.md        # 문제, 해결, 실행법, 스크린샷, 한계
```
로직은 `core.py` 에 두고 UI 는 얇게. LLM 호출은 함수 하나로 감싸고 실패 시 재시도 1회 + 명확한 에러 메시지.

## 4. 개발 순서
1. `core.py` 핵심 함수를 하드코딩 입력으로 실행해 출력 확인
2. 최소 UI 연결 → 실제로 띄워서 핵심 시나리오 1회 통과
3. 예외 입력(빈 값, 큰 파일, 이상한 형식) 처리
4. 화면 다듬기 (`$frontend-design`), 시간 남으면 Nice 기능

## 5. 검증
- 서버를 실제로 띄우고 핵심 시나리오를 끝까지 눌러본다. 웹이면 `$webapp-testing` 또는 `$playwright` 로 스크린샷을 남긴다
- `pytest -q` 로 core 테스트 통과 확인
- README 의 실행 명령을 새 터미널에서 그대로 복사해 실행해본다

## 6. 데모 스토리 (README 상단)
문제 1줄 → 누가 쓰나 → 화면 흐름 3단계 → 결과/효과 → 한계와 다음 단계.
