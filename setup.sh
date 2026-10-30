#!/usr/bin/env bash
# Cofa Probe 응시 키트 설치 스크립트
#
# 사용법: 과제 작업 폴더에서   bash ~/kit/setup.sh [대상 폴더]
#
# 하는 일
#   1) templates/의 살아 있는 문서 6개를 작업 폴더에 복사 (기존 파일은 덮어쓰지 않음)
#   2) skills/를 Codex가 자동으로 찾는 사용자 스킬 폴더(~/.agents/skills)에 설치
#      - 작업 폴더 밖이라 제출물에 섞이지 않는다
#      - 키트가 설치한 스킬만 갱신하고, 같은 이름의 다른 스킬은 건드리지 않는다
#   3) 작업 폴더가 git 저장소가 아니면 git init (커밋은 하지 않음)
#
# 환경 변수
#   CODEX_SKILLS_DIR  스킬 설치 위치 (기본: $HOME/.agents/skills)
set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$(cd "${1:-$PWD}" && pwd)"
SKILLS_DEST="${CODEX_SKILLS_DIR:-$HOME/.agents/skills}"
MARKER=".installed-by-cofa-kit"

if [ "$TARGET" = "$KIT_DIR" ] || [[ "$TARGET" == "$KIT_DIR"/* ]]; then
  echo "[중단] 키트 폴더 안에서 실행했습니다. 과제 작업 폴더로 이동한 뒤 다시 실행하세요." >&2
  echo "       예) cd ~/workspace && bash $KIT_DIR/setup.sh" >&2
  exit 1
fi

if [[ "$KIT_DIR" == "$TARGET"/* ]]; then
  echo "[경고] 키트가 작업 폴더 안에 있습니다: $KIT_DIR"
  echo "       제출물에 키트가 섞이지 않도록 작업 폴더 밖(예: ~/kit)에 다시 clone하는 것을 권장합니다."
fi

render() { # $1=src $2=dst : __KIT_DIR__ 를 실제 키트 경로로 바꿔 복사
  sed "s#__KIT_DIR__#${KIT_DIR}#g" "$1" > "$2"
}

# ---------------------------------------------------------------- 1) 문서 템플릿
cd "$TARGET"
copied=(); skipped=()
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

# ---------------------------------------------------------------- 2) 스킬 설치
installed=(); updated=(); conflicts=()
if mkdir -p "$SKILLS_DEST" 2>/dev/null && [ -w "$SKILLS_DEST" ]; then
  for dir in "$KIT_DIR"/skills/*/; do
    name="$(basename "$dir")"
    dest="$SKILLS_DEST/$name"
    if [ -e "$dest" ] && [ ! -e "$dest/$MARKER" ]; then
      conflicts+=("$name"); continue           # 키트가 만든 게 아닌 같은 이름 스킬은 보존
    fi
    [ -e "$dest" ] && was_there=1 || was_there=0
    rm -rf "$dest"; mkdir -p "$dest"
    for file in "$dir"*; do
      [ -f "$file" ] || continue
      case "$file" in
        *.md) render "$file" "$dest/$(basename "$file")" ;;
        *)    cp "$file" "$dest/" ;;
      esac
    done
    echo "$KIT_DIR" > "$dest/$MARKER"
    if [ "$was_there" = 1 ]; then updated+=("$name"); else installed+=("$name"); fi
  done
  skills_ok=1
else
  skills_ok=0
fi

# ---------------------------------------------------------------- 3) git
if [ ! -d .git ]; then
  if command -v git >/dev/null 2>&1; then
    git init -q && echo "[git] 저장소가 없어 git init 했습니다 (커밋은 하지 않음)."
  else
    echo "[git] git이 없어 init을 건너뜁니다."
  fi
fi

# ---------------------------------------------------------------- 결과
echo
echo "== 작업 폴더: $TARGET"
for c in "${copied[@]:-}";  do [ -n "$c" ] && echo "  + $c"; done
for s in "${skipped[@]:-}"; do [ -n "$s" ] && echo "  = $s (이미 있어 건너뜀)"; done
echo
if [ "$skills_ok" = 1 ]; then
  echo "== 스킬: $SKILLS_DEST"
  for n in "${installed[@]:-}"; do [ -n "$n" ] && echo "  + $n"; done
  for n in "${updated[@]:-}";   do [ -n "$n" ] && echo "  ~ $n (키트 최신 내용으로 갱신)"; done
  for n in "${conflicts[@]:-}"; do [ -n "$n" ] && echo "  ! $n (같은 이름의 다른 스킬이 있어 건너뜀)"; done
else
  echo "[경고] 스킬 폴더에 쓸 수 없습니다: $SKILLS_DEST"
  echo "       CODEX_SKILLS_DIR=<쓸 수 있는 경로> bash $KIT_DIR/setup.sh 로 다시 실행하거나,"
  echo "       Codex에게 '$KIT_DIR/skills/<이름>/SKILL.md 를 읽고 따라줘'라고 직접 요청하세요."
fi
echo
echo "다음 할 일"
echo "  1. README.md(과제 지시서)에서 필수 제출 문서·파일명을 확인한다."
echo "  2. AGENTS.kit.md가 생겼다면 과제의 AGENTS.md 끝에 필요한 규칙만 붙여 넣는다."
echo "  3. codex 실행 → /status, /model → /skills 로 스킬 9개가 보이는지 확인"
echo "     (안 보이면 Codex를 다시 시작. AGENTS.md는 세션 시작 때만 읽힌다)"
echo "  4. 첫 프롬프트: $KIT_DIR/prompts/codex-prompts.md §1"
