#!/usr/bin/env bash
# 해커톤 키트 설치 스크립트
#   기본: core + data + product 외부 스킬 + 이 레포의 자체 스킬을 ~/.agents/skills 에 설치
#
# 사용법:
#   bash scripts/install.sh                      # 기본 (core,data,product)
#   bash scripts/install.sh --profile core,data  # 프로필 골라서
#   bash scripts/install.sh --profile all        # extra 포함 전부
#   bash scripts/install.sh --project .          # 현재 프로젝트의 ./.agents/skills 에 설치
#   bash scripts/install.sh --legacy             # ~/.codex/skills 에도 복사 (구버전 Codex 대비)
#   bash scripts/install.sh --agents             # AGENTS.md 를 ~/.codex/AGENTS.md 로 설치
#   bash scripts/install.sh --mcp                # mcp/config.toml 을 ~/.codex/config.toml 에 추가
#   bash scripts/install.sh --dry-run            # 무엇을 설치할지만 출력
set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILES="core,data,product"
DEST="${HOME}/.agents/skills"
LEGACY=0; DO_AGENTS=0; DO_MCP=0; DRY=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile) PROFILES="$2"; shift 2;;
    --project) DEST="$(cd "$2" && pwd)/.agents/skills"; shift 2;;
    --legacy)  LEGACY=1; shift;;
    --agents)  DO_AGENTS=1; shift;;
    --mcp)     DO_MCP=1; shift;;
    --dry-run) DRY=1; shift;;
    -h|--help) sed -n '2,14p' "$0"; exit 0;;
    *) echo "알 수 없는 옵션: $1"; exit 1;;
  esac
done
[[ "$PROFILES" == "all" ]] && PROFILES="core,data,product,extra"

command -v git >/dev/null || { echo "git 이 필요합니다"; exit 1; }
CACHE="${KIT_DIR}/.cache"
mkdir -p "$CACHE"
[[ $DRY -eq 0 ]] && mkdir -p "$DEST"

want() { [[ ",${PROFILES}," == *",$1,"* ]]; }

fetch_repo() {  # owner/repo sha -> 로컬 경로 출력
  local repo="$1" sha="$2" dir="${CACHE}/${1//\//__}@${2:0:12}"
  if [[ ! -d "$dir/.git" ]]; then
    git init -q "$dir"
    git -C "$dir" remote add origin "https://github.com/${repo}.git"
    if ! git -C "$dir" fetch -q --depth 1 origin "$sha" 2>/dev/null; then
      # SHA 직접 fetch 가 막힌 환경이면 기본 브랜치를 받는다
      echo "  ! ${repo}@${sha:0:7} 고정 커밋을 받지 못해 최신 기본 브랜치로 대체" >&2
      git -C "$dir" fetch -q --depth 1 origin HEAD
      sha="FETCH_HEAD"
    fi
    git -C "$dir" -c advice.detachedHead=false checkout -q "$sha"
  fi
  echo "$dir"
}

install_dir() {  # src name
  local src="$1" name="$2"
  if [[ $DRY -eq 1 ]]; then echo "  [dry] $name"; return; fi
  rm -rf "${DEST:?}/${name}"
  cp -R "$src" "${DEST}/${name}"
  if [[ $LEGACY -eq 1 ]]; then
    mkdir -p "${HOME}/.codex/skills"
    rm -rf "${HOME}/.codex/skills/${name}"
    cp -R "$src" "${HOME}/.codex/skills/${name}"
  fi
  echo "  + $name"
}

echo "설치 위치: $DEST"
echo "프로필: $PROFILES"
echo
echo "[1/2] 외부 공개 저장소 스킬"
while read -r prof repo sha path; do
  [[ -z "${prof:-}" || "$prof" == \#* ]] && continue
  want "$prof" || continue
  dir="$(fetch_repo "$repo" "$sha")"
  if [[ -f "${dir}/${path}/SKILL.md" ]]; then
    install_dir "${dir}/${path}" "$(basename "$path")"
  else
    echo "  ! ${repo}/${path} 에 SKILL.md 없음, 건너뜀"
  fi
done < "${KIT_DIR}/sources.lock"

echo
echo "[2/2] 이 레포의 자체 스킬"
for d in "${KIT_DIR}"/skills/*/; do
  [[ -f "${d}SKILL.md" ]] && install_dir "${d%/}" "$(basename "$d")"
done

if [[ $DO_AGENTS -eq 1 && $DRY -eq 0 ]]; then
  mkdir -p "${HOME}/.codex"
  if [[ -f "${HOME}/.codex/AGENTS.md" ]]; then
    cp "${HOME}/.codex/AGENTS.md" "${HOME}/.codex/AGENTS.md.bak"
    echo; echo "기존 ~/.codex/AGENTS.md 를 AGENTS.md.bak 으로 백업"
  fi
  cp "${KIT_DIR}/AGENTS.md" "${HOME}/.codex/AGENTS.md"
  echo "AGENTS.md -> ~/.codex/AGENTS.md"
fi

if [[ $DO_MCP -eq 1 && $DRY -eq 0 ]]; then
  CFG="${HOME}/.codex/config.toml"
  mkdir -p "${HOME}/.codex"; touch "$CFG"
  if grep -q "hakathon-toolkit MCP" "$CFG"; then
    echo "MCP 설정이 이미 config.toml 에 있음"
  else
    cp "$CFG" "${CFG}.bak"
    { echo; cat "${KIT_DIR}/mcp/config.toml"; } >> "$CFG"
    echo "MCP 설정을 ~/.codex/config.toml 에 추가 (백업: config.toml.bak)"
  fi
fi

echo
echo "완료. Codex 를 재시작한 뒤 /skills 로 목록을 확인하세요."
