#!/usr/bin/env bash
# Cofa Probe 응시 키트 설치 스크립트
#
# 사용법: 과제 작업 폴더에서   bash ~/kit/setup.sh [--update-skills] [대상 폴더]
#
# 하는 일 (대상 폴더 = 실행한 위치, 또는 인자로 준 폴더)
#   1) 살아 있는 문서 6개(AGENTS.md 등)를 대상 폴더에 복사 — 기존 파일은 덮어쓰지 않음
#   2) 스킬을 대상 폴더의 skills/ 한 곳에 모아서 설치
#      - .agents/skills -> ../skills 링크를 만들어 Codex가 자동으로 찾게 함
#      - 이미 있는 스킬은 보존 (Codex가 과제 중에 고친 내용을 지키기 위해)
#        키트 최신본으로 덮어쓰려면 --update-skills
#   3) 예전 버전이 ~/.agents/skills 에 깔아 둔 키트 스킬은 중복을 막기 위해 제거
#   4) 대상 폴더가 git 저장소가 아니면 git init (커밋은 하지 않음)
set -euo pipefail

UPDATE_SKILLS=0
ARGS=()
for a in "$@"; do
  case "$a" in
    --update-skills) UPDATE_SKILLS=1 ;;
    -h|--help) sed -n '2,15p' "$0"; exit 0 ;;
    *) ARGS+=("$a") ;;
  esac
done

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$(cd "${ARGS[0]:-$PWD}" && pwd)"
SKILLS_DIR="$TARGET/skills"
MANIFEST="$SKILLS_DIR/.cofa-kit"           # 키트가 설치한 스킬 목록
LEGACY_DIR="$HOME/.agents/skills"
LEGACY_MARKER=".installed-by-cofa-kit"

if [ "$TARGET" = "$KIT_DIR" ] || [[ "$TARGET" == "$KIT_DIR"/* ]]; then
  echo "[중단] 키트 폴더 안에서 실행했습니다. 과제 작업 폴더로 이동한 뒤 다시 실행하세요." >&2
  echo "       예) cd ~/workspace && bash $KIT_DIR/setup.sh" >&2
  exit 1
fi

if [[ "$KIT_DIR" == "$TARGET"/* ]]; then
  echo "[알림] 키트가 작업 폴더 안에 있습니다: $KIT_DIR"
  echo "       제출물에 키트 원본까지 섞이지 않게 하려면 작업 폴더 밖(예: ~/kit)에 clone하세요."
fi

render() { # $1=src $2=dst : __KIT_DIR__ 를 실제 키트 경로로 바꿔 복사
  sed "s#__KIT_DIR__#${KIT_DIR}#g" "$1" > "$2"
}

cd "$TARGET"

# ---------------------------------------------------------------- 1) 문서 템플릿
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

# ---------------------------------------------------------------- 2) 스킬 → ./skills
mkdir -p "$SKILLS_DIR"
touch "$MANIFEST"
s_new=(); s_upd=(); s_keep=(); s_conflict=()
for dir in "$KIT_DIR"/skills/*/; do
  name="$(basename "$dir")"
  dest="$SKILLS_DIR/$name"
  ours=0; grep -qx "$name" "$MANIFEST" && ours=1
  if [ -e "$dest" ] && [ "$ours" = 0 ]; then
    s_conflict+=("$name"); continue               # 과제가 원래 갖고 있던 같은 이름 스킬은 건드리지 않음
  fi
  if [ -e "$dest" ] && [ "$UPDATE_SKILLS" = 0 ]; then
    s_keep+=("$name"); continue                   # 과제 중 고친 내용 보존
  fi
  [ -e "$dest" ] && existed=1 || existed=0
  rm -rf "$dest"; mkdir -p "$dest"
  for file in "$dir"*; do
    [ -f "$file" ] || continue
    case "$file" in
      *.md) render "$file" "$dest/$(basename "$file")" ;;
      *)    cp "$file" "$dest/" ;;
    esac
  done
  grep -qx "$name" "$MANIFEST" || echo "$name" >> "$MANIFEST"
  if [ "$existed" = 1 ]; then s_upd+=("$name"); else s_new+=("$name"); fi
done

# Codex 자동 탐색 경로(.agents/skills)가 ./skills 를 가리키게 한다
link_msg=""
if [ -L .agents/skills ]; then
  link_msg=".agents/skills -> $(readlink .agents/skills) (이미 있음)"
elif [ -e .agents/skills ]; then
  link_msg="[주의] .agents/skills 가 이미 실제 폴더로 있어 링크를 만들지 않았습니다. Codex는 AGENTS.md에 적힌 skills/ 경로로 스킬을 읽습니다."
else
  mkdir -p .agents && ln -s ../skills .agents/skills && link_msg=".agents/skills -> ../skills (Codex 자동 탐색용 링크)"
fi

# ---------------------------------------------------------------- 3) 예전 설치분 정리
legacy_removed=()
if [ -d "$LEGACY_DIR" ]; then
  for d in "$LEGACY_DIR"/*/; do
    [ -e "$d$LEGACY_MARKER" ] || continue
    rm -rf "$d"; legacy_removed+=("$(basename "$d")")
  done
fi

# ---------------------------------------------------------------- 4) git
if [ ! -d .git ]; then
  if command -v git >/dev/null 2>&1; then
    git init -q && echo "[git] 저장소가 없어 git init 했습니다 (커밋은 하지 않음)."
  else
    echo "[git] git이 없어 init을 건너뜁니다."
  fi
fi

# ---------------------------------------------------------------- 결과
set +u   # 빈 배열 출력 시 오래된 bash에서 unbound 오류가 나지 않게
p() { for x in "$@"; do [ -n "$x" ] && echo "$x"; done; }
echo
echo "== 문서: $TARGET"
p "${copied[@]/#/  + }"  "${skipped[@]/#/  = }"
[ "${#skipped[@]}" -gt 0 ] && echo "    (= 는 이미 있어 건너뜀)"
echo
echo "== 스킬: $SKILLS_DIR"
p "${s_new[@]/#/  + }" "${s_upd[@]/#/  ~ }" "${s_keep[@]/#/  = }" "${s_conflict[@]/#/  ! }"
[ "${#s_upd[@]}" -gt 0 ]      && echo "    (~ 는 키트 최신본으로 덮어씀)"
[ "${#s_keep[@]}" -gt 0 ]     && echo "    (= 는 이미 있어 보존. 키트 최신본으로 바꾸려면 --update-skills)"
[ "${#s_conflict[@]}" -gt 0 ] && echo "    (! 는 과제에 같은 이름의 스킬이 있어 건너뜀)"
echo "  $link_msg"
[ "${#legacy_removed[@]}" -gt 0 ] && echo "  예전 위치(~/.agents/skills)의 키트 스킬 ${#legacy_removed[@]}개를 중복 방지를 위해 정리했습니다."
echo
echo "다음 할 일"
echo "  1. README.md(과제 지시서)에서 필수 제출 문서·파일명을 확인한다."
echo "  2. AGENTS.kit.md가 생겼다면 과제의 AGENTS.md 끝에 필요한 규칙만 붙여 넣는다."
echo "  3. codex 실행 → /status, /model → /skills 로 스킬 $(ls -d "$KIT_DIR"/skills/*/ | wc -l | tr -d ' ')개가 보이는지 확인"
echo "     (안 보이면 Codex를 다시 시작. 그래도 안 보이면 'skills/<이름>/SKILL.md 읽고 따라줘')"
echo "  4. 단계별 프롬프트: $KIT_DIR/prompts/STEP-BY-STEP.md"
