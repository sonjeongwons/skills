#!/usr/bin/env bash
# Cofa Probe 응시 키트 설치 스크립트
# 사용법: 과제 작업 폴더에서  bash ~/kit/setup.sh  [대상 폴더]
# - 기존 파일은 절대 덮어쓰지 않는다.
# - 커밋하지 않는다. git 저장소가 아니면 git init만 한다.
set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$(cd "${1:-$PWD}" && pwd)"

if [ "$TARGET" = "$KIT_DIR" ] || [[ "$TARGET" == "$KIT_DIR"/* ]]; then
  echo "[중단] 키트 폴더 안에서 실행했습니다. 과제 작업 폴더로 이동한 뒤 다시 실행하세요." >&2
  echo "       예) cd ~/workspace && bash $KIT_DIR/setup.sh" >&2
  exit 1
fi

if [[ "$KIT_DIR" == "$TARGET"/* ]]; then
  echo "[경고] 키트가 작업 폴더 안에 있습니다: $KIT_DIR"
  echo "       제출물에 키트가 섞이지 않도록 작업 폴더 밖(예: ~/kit)에 다시 clone하는 것을 권장합니다."
fi

cd "$TARGET"
copied=()
skipped=()

render() { # $1=src $2=dst
  sed "s#__KIT_DIR__#${KIT_DIR}#g" "$1" > "$2"
}

for f in AGENTS.md AGREEMENT.md INTERVIEW.md DECISIONS.md VERIFICATION.md HANDOFF.md; do
  src="$KIT_DIR/templates/$f"
  if [ ! -e "$f" ]; then
    render "$src" "$f"; copied+=("$f")
  elif [ "$f" = "AGENTS.md" ] && [ ! -e "AGENTS.kit.md" ]; then
    render "$src" "AGENTS.kit.md"; copied+=("AGENTS.kit.md (기존 AGENTS.md 보존)")
  else
    skipped+=("$f")
  fi
done

if [ ! -d .git ]; then
  if command -v git >/dev/null 2>&1; then
    git init -q && echo "[git] 저장소가 없어 git init 했습니다 (커밋은 하지 않음)."
  else
    echo "[git] git이 없어 init을 건너뜁니다."
  fi
fi

echo
echo "== 키트 설치 완료: $TARGET"
for c in "${copied[@]:-}"; do [ -n "$c" ] && echo "  + $c"; done
for s in "${skipped[@]:-}"; do [ -n "$s" ] && echo "  = $s (이미 있어 건너뜀)"; done
echo
echo "다음 할 일"
echo "  1. README.md(과제 지시서)에서 필수 제출 문서·파일명을 확인한다. 이름이 정해져 있으면 템플릿 내용을 그 파일로 옮긴다."
echo "  2. AGENTS.kit.md가 생겼다면 과제의 AGENTS.md 끝에 필요한 규칙만 붙여 넣는다."
echo "  3. codex 실행 → /status, /model 확인 → 첫 프롬프트: $KIT_DIR/prompts/codex-prompts.md"
echo "  4. 담당자 인터뷰 질문: $KIT_DIR/prompts/interviewer-questions.md"
