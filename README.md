# hakathon-toolkit

AI 해커톤 2026 2차 예선용 Codex 스킬·MCP·코딩 규칙 모음.
외부 스킬은 **공개 저장소에서 커밋 SHA 를 고정해서** 설치 시점에 받아온다 (복사본을 이 레포에 넣지 않음).

## 시험 시작 직후 (복붙용)

```bash
git clone https://github.com/devDavidLee/hakathon-toolkit.git ~/kit
bash ~/kit/scripts/install.sh --agents        # 스킬 + AGENTS.md 설치
# 선택: MCP 도 쓰려면
bash ~/kit/scripts/install.sh --mcp
# Codex 재시작 후
/skills                                      # 목록 확인
$hackathon-kickoff 과제 문서 읽고 시작해줘    # 첫 호출
```

- 스킬이 `/skills` 에 안 보이면: `bash ~/kit/scripts/install.sh --legacy` (구버전 경로 `~/.codex/skills` 에도 설치)
- 과제 폴더 안에만 설치하려면: `bash ~/kit/scripts/install.sh --project .`
- 필요한 것만: `--profile core,data` / 전부: `--profile all`
- 설치될 목록만 보기: `--dry-run`
- **Codex 자체는 업데이트하지 않는다** (대회 규칙). 이 스크립트는 Codex 를 건드리지 않는다.

## 작업 흐름

```
과제 받음 ─▶ $hackathon-kickoff (Sol) ─┬─▶ 데이터 과제 ─▶ $data-task-playbook (Terra)
                                      └─▶ 제품/데모 ─▶ $product-prototype (Terra)
         막히면 $systematic-debugging (Sol)   ·   종료 25분 전 $submission-check (Sol)
```

## 모델 매칭 (Codex `/model`)

| 모델 | 체급 | 주 용도 |
|---|---|---|
| **6.1 Sol** | 플래그십 (Opus 급) | 과제 해부, 설계·전략, 원인 모를 버그, 최종 점검 |
| **5.6 Terra** | 균형형 (Sonnet 급) | 대부분의 구현: EDA, 모델링, 웹앱, 테스트 — **기본값** |
| **6.0 Luna** | 경량 (Haiku 급) | README·주석·포맷, 로그 요약, 단순 반복 수정 |

세부 규칙은 [`skills/model-routing`](skills/model-routing/SKILL.md).

## 스킬 카탈로그

### 자체 스킬 (이 레포, `skills/`)
| 스킬 | 언제 | 모델 |
|---|---|---|
| `hackathon-kickoff` | 과제 받자마자: BRIEF.md, PLAN.md, 4시간 타임라인 | Sol |
| `data-task-playbook` | 표·센서·시계열·공정 데이터 예측/분류/이상탐지 | Terra |
| `product-prototype` | 서비스·웹 데모·에이전트·대시보드 만들기 | Terra |
| `model-routing` | 어떤 모델로 바꿀지 헷갈릴 때 | - |
| `submission-check` | 종료 20–30분 전 최종 점검 | Sol |

### core — 코딩 원칙·계획·디버깅 (항상 설치)
| 스킬 | 출처 | 용도 | 모델 |
|---|---|---|---|
| `karpathy-guidelines` | [forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) | 과잉 구현 방지, 가정 명시, 최소 diff | 전체 |
| `brainstorming` | [obra/superpowers](https://github.com/obra/superpowers) | 구현 전 요구사항·설계 정리 | Sol |
| `writing-plans` / `executing-plans` | obra/superpowers | 계획 작성 → 단계별 실행 | Sol / Terra |
| `systematic-debugging` | obra/superpowers | 근본 원인부터 찾는 디버깅 | Sol |
| `verification-before-completion` | obra/superpowers | "됐다" 전에 실제 실행 확인 | Terra |
| `define-goal` | [openai/skills](https://github.com/openai/skills) | 목표·완료 조건 정의 | Sol |

### data — 데이터 분석·ML
| 스킬 | 출처 | 용도 | 모델 |
|---|---|---|---|
| `exploratory-data-analysis` | [K-Dense-AI/claude-scientific-skills](https://github.com/K-Dense-AI/claude-scientific-skills) | EDA 절차 | Terra |
| `statistical-analysis` | K-Dense | 가설검정, 효과크기 | Terra |
| `scikit-learn` | K-Dense | 전처리·파이프라인·CV·튜닝 | Terra |
| `polars` | K-Dense | 대용량 표 데이터 빠른 처리 | Terra |
| `matplotlib` / `seaborn` | K-Dense | 시각화 | Terra / Luna |
| `shap` | K-Dense | 모델 해석 | Terra |
| `jupyter-notebook` | openai/skills | 노트북 생성·정리 | Terra |

### product — 앱·UI·테스트·보안
| 스킬 | 출처 | 용도 | 모델 |
|---|---|---|---|
| `frontend-design` | [anthropics/skills](https://github.com/anthropics/skills) | 템플릿 티 안 나는 UI | Terra |
| `webapp-testing` | anthropics/skills | Playwright 로 로컬 웹앱 검증 | Terra |
| `playwright` | openai/skills | 브라우저 자동화·스크린샷 | Terra |
| `test-driven-development` | obra/superpowers | 테스트 먼저 | Terra |
| `security-best-practices` | openai/skills | 키 노출·입력 검증 점검 | Sol |

### extra — 문제 보고 필요할 때 (`--profile extra`)
`statsmodels`, `timesfm-forecasting`(시계열 예측), `transformers`, `pytorch-lightning`, `umap-learn` (K-Dense) · `mcp-builder` (anthropics) · `pdf` (openai)

## MCP ([`mcp/config.toml`](mcp/config.toml), 버전 고정)
| 서버 | 출처 | 용도 | 기본 |
|---|---|---|---|
| context7 | [upstash/context7](https://github.com/upstash/context7) | 라이브러리 최신 문서 조회 | on |
| sequential-thinking | [modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers) | 단계적 문제 분해 | on |
| fetch | modelcontextprotocol/servers | 웹 페이지 본문 읽기 | on |
| playwright | [microsoft/playwright-mcp](https://github.com/microsoft/playwright-mcp) | 웹 데모 브라우저 검증 | off |

npm/pypi 접근이 막힌 환경이면 MCP 는 건너뛴다. 스킬과 AGENTS.md 만으로도 동작한다.

## 규칙 준수 메모
- 이 레포와 `sources.lock` 의 모든 출처는 공개 저장소다. **이 레포는 2차 예선 결과 통지 전까지 Public 유지.**
- 출처는 대형 조직/인기 저장소로 골랐고 커밋 SHA 를 고정했다 (`sources.lock`).
- anthropics/skills 의 docx·xlsx·pptx·pdf 는 오픈소스 라이선스가 아니라서 제외했다.
- 스킬은 작업 방식 가이드다. 결과물은 과제에 맞게 직접 만든다.

## 구조
```
AGENTS.md            Codex 전역 작업 규칙
sources.lock         외부 스킬 목록 (profile, repo, SHA, path)
skills/              자체 스킬 5종
mcp/config.toml      MCP 설정 조각
scripts/install.sh   설치 스크립트
```
