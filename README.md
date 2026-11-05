# Cofa Probe 응시 키트

> **시험 중에는 [prompts/STEP-BY-STEP.md](prompts/STEP-BY-STEP.md) 하나만 열어 두고 위에서부터 따라간다.**

SK하이닉스 AI 해커톤 2026 2차 예선(크래프톤 Cofa Probe)에서 쓰는 개인 작업 키트입니다.
과제 결과물 코드는 들어 있지 않습니다. 작업 규칙, 살아 있는 문서 템플릿, 단계별 플레이북, 프롬프트, 평가 기준 체크리스트, Codex 스킬만 담았습니다.

## 시험장 1분 세팅

```bash
# 1) 키트는 과제 작업 폴더 "밖"에 받는다 (작업 폴더 안에 받으면 제출물에 섞인다)
git clone https://github.com/sonjeongwons/skills ~/kit
#    이미 받아 두었다면: git -C ~/kit pull

# 2) 과제 작업 폴더에서 설치 (기존 파일은 덮어쓰지 않음)
cd ~/workspace
bash ~/kit/setup.sh

# 3) Codex 실행 → /status, /model, /skills 확인
codex
```

설치 후 작업 폴더는 이렇게 된다. 스킬은 전부 `skills/` 한 폴더에 모인다.

```
~/workspace/
├── AGENTS.md  AGREEMENT.md  INTERVIEW.md  DECISIONS.md  VERIFICATION.md  HANDOFF.md
├── skills/                      ← 스킬 10개 (과제 중 Codex가 고치고 새로 만든다)
│   ├── requirements-discovery/SKILL.md
│   ├── …
│   └── .cofa-kit                ← 키트가 설치한 스킬 목록
└── .agents/skills -> ../skills  ← Codex 자동 탐색용 링크
```

- 다시 실행해도 이미 있는 스킬은 보존한다(과제 중 고친 내용 보호). 키트 최신본으로 덮어쓰려면 `bash ~/kit/setup.sh --update-skills`
- 예전 버전이 `~/.agents/skills`에 설치한 키트 스킬은 중복을 막기 위해 자동으로 정리한다.

## 설치 후 Codex가 알아서 하는 것과 아닌 것

| 대상 | 어떻게 쓰이나 | 자동 여부 |
| --- | --- | --- |
| 작업 폴더의 `AGENTS.md` | Codex가 **세션 시작 때 한 번** 자동으로 읽는다. 언제 어떤 문서를 고치고 어떤 스킬을 쓸지 여기 적혀 있다 | 자동 (세션 시작 시) |
| 살아 있는 문서 5개 (INTERVIEW, AGREEMENT, DECISIONS, VERIFICATION, HANDOFF) | AGENTS.md의 "사건 → 고칠 문서" 표에 따라 Codex가 작업하면서 계속 고친다 | 자동 (규칙 기반) |
| 스킬 10개 (작업 폴더 `skills/`) | `.agents/skills` 링크로 Codex가 자동 발견하고, 설명을 보고 상황에 맞으면 스스로 골라 읽는다. `$이름`으로 직접 부를 수도 있다. AGENTS.md에도 목록과 경로가 있어 자동 목록에 안 떠도 읽을 수 있다 | 자동 선택 + 수동 호출 |
| 스킬 수정·추가 | 과제와 절차가 안 맞으면 Codex가 해당 SKILL.md를 고치고, 반복되는 절차는 새 스킬로 제안해 `skills/`에 만든다. 고친 이유는 DECISIONS.md에 남긴다 | 자동 (AGENTS.md 규칙) |
| `playbook/`, `rubric/` | 스킬(`exam-stage`, `rubric-self-check`, `followup-qa-prep`)과 AGENTS.md가 필요할 때 이 경로를 읽게 한다 | 간접 |
| `STRATEGY.md`, `prompts/`, `checklists/` | 사람이 읽는 자료. Codex에 넣지 않는다 | 사람용 |

### 알아 둘 동작 방식 (Codex 공식 문서 기준)

- **AGENTS.md는 세션 시작 때만 읽힌다.** 진행 중에 AGENTS.md를 고치면(예: 6절에 과제별 규칙 추가) 다음 세션부터 적용된다. 바로 적용하려면 "AGENTS.md 6절을 다시 읽어"라고 말한다.
- **스킬은 설명(description)을 보고 Codex가 고른다.** 자동 선택은 보장되지 않으니, 중요한 순간에는 `$handoff`처럼 직접 부르는 것이 확실하다. 스킬 파일이 바뀌면 Codex가 자동으로 감지하고, 안 보이면 Codex를 다시 시작한다.
- 스킬은 작업 폴더의 `skills/`에 있으므로 **제출물에 함께 들어간다.** 과제에 맞게 고친 작업 도구로 남는 것이고, 결과물 코드는 아니다. 넣고 싶지 않으면 제출 전에 `skills/`와 `.agents/`를 지우거나 README가 정한 제출 범위를 따른다.

## 순간별로 부를 스킬

| 순간 | 입력 예 |
| --- | --- |
| 과제 시작 직후 | `$requirements-discovery README를 구조화하고 담당자에게 물을 질문 초안 만들어줘` |
| 지금 어디쯤인지, 다음 단계로 가도 되는지 | `$exam-stage 지금 경과 55분이야` |
| 기능 하나 맡길 때 | `$delegate-and-verify [기능] / 범위 [파일] / 완료 조건 [명령→결과]` |
| 무언가를 정했을 때 | `$decision-log A안으로 간다. 이유는 …` |
| 이전 단계로 돌아가거나 갈아엎을 때 | `$stage-rollback 담당자가 v0를 보고 핵심이 다르다고 함. 지금 82분. 재인터뷰하자` |
| 대화가 길어졌을 때, 큰 단계가 끝났을 때 | `$handoff` → 새 세션에서 돌려받은 시작 문구 입력 |
| 125분 무렵 | `$rubric-self-check`, `$security-review` |
| 150분 무렵 | `$followup-qa-prep` (질문만 받고 답은 직접 쓴다) |
| 170분 | `$pre-submit-check` |

## 무엇이 어디 있나

| 경로 | 내용 | 언제 |
| --- | --- | --- |
| `STRATEGY.md` | 전략 전문: 평가 구조, 공식 조건, 플레이북, 대화법, 서술형 대비 | 시험 전날 정독 |
| `checklists/pre-exam.md` | 준비물, 사전 체험 15분 점검표, 당일 타임라인 | 전날·당일 아침 |
| `playbook/` | 180분을 단계별로 나눈 규칙. 단계마다 목표·할 일·종료 조건·되돌아가는 신호·금지 행동, `09-rollback.md`는 롤백 규칙 | `exam-stage`, `stage-rollback`이 읽음 |
| `prompts/codex-prompts.md` | 단계별 Codex 프롬프트 | 시험 중 |
| `prompts/interviewer-questions.md` | 업무 담당자 에이전트 인터뷰 7단계 질문 | 문제 발굴 단계 |
| `rubric/` | 평가 기준 점검표, 서술형 대비, 비용 습관 | 스킬이 읽음 |
| `templates/` | AGENTS.md와 살아 있는 문서 5개 | setup.sh가 복사 |
| `skills/` | Codex 스킬 10개 (SKILL.md) | setup.sh가 작업 폴더 `skills/`에 설치 |

## 문서가 바뀌는 방식

- **작업 폴더의 문서**(AGENTS.md 포함)는 과제 내내 Codex와 사람이 함께 고친다. 템플릿 모양보다 내용이 정확한 게 중요하며, 칸이나 섹션을 새로 만들어도 된다.
- **단계는 앞뒤로 움직인다.** 구현 중 재인터뷰, 재합의, 재설계, 기능 되돌리기, 갈아엎기가 모두 정식 흐름이다(`playbook/09-rollback.md`). 롤백 전에는 커밋과 `rollback-N-before` 태그로 보존하고, 문서는 지우지 않고 버전을 올려 쌓는다(합의 v1→v2, 인터뷰 2회차, 검증 "재검증 필요"). 125분 이후에는 기능 되돌리기만 한다.
- **작업 폴더의 스킬**(`skills/<이름>/SKILL.md`)은 Codex가 과제에 맞게 고치고, 반복되는 절차는 새 스킬로 추가한다. `setup.sh`를 다시 실행해도 보존되며, `--update-skills`를 줄 때만 키트 원본으로 덮어쓴다.
- **키트 원본**(`~/kit`)은 시험 중에 고쳐도 push할 수 없다(Git Push 금지). 원본 개선은 시험 전에 한다.

## 지켜야 할 규칙

- 키트 원본은 작업 폴더 밖(`~/kit`)에 받습니다. 작업 폴더에는 결과물, 살아 있는 문서, `skills/`만 둡니다.
- 이 저장소에는 결과물 코드가 없습니다. 공개 코드로 결과물을 통째로 대체하는 것은 금지입니다.
- 가이드상 "일반적으로 공개된 Skill과 공개 GitHub 저장소"는 쓸 수 있습니다. 본인이 만든 공개 저장소가 여기에 해당하는지는 Cofa 팀 확인을 권장합니다.
- 키·토큰·비밀번호는 이 저장소에 없고, 넣지도 않습니다.
- 서술형 30분은 AI·복사·붙여넣기 금지입니다. 이 키트도 그때는 쓸 수 없습니다.
