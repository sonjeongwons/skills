# Cofa Probe 응시 키트

SK하이닉스 AI 해커톤 2026 2차 예선(크래프톤 Cofa Probe)에서 쓰는 개인 작업 키트입니다.
과제 결과물 코드는 들어 있지 않습니다. 작업 규칙, 문서 템플릿, 단계별 플레이북, 프롬프트, 평가 기준 체크리스트, 절차 스킬만 담았습니다.

## 시험장 1분 세팅

```bash
# 1) 키트는 과제 작업 폴더 "밖"에 받는다 (작업 폴더 안에 받으면 제출물에 섞인다)
git clone https://github.com/sonjeongwons/skills ~/kit
#    이미 받아 두었다면: git -C ~/kit pull

# 2) 과제 작업 폴더로 이동해서 템플릿 복사 (기존 파일은 절대 덮어쓰지 않음)
cd ~/workspace
bash ~/kit/setup.sh

# 3) Codex 실행 → /status, /model 확인
codex
```

`setup.sh`가 하는 일은 세 가지입니다.

1. `templates/`의 문서 6개를 작업 폴더로 복사합니다. 같은 이름의 파일이 이미 있으면 건너뛰고, `AGENTS.md`가 이미 있으면 `AGENTS.kit.md`로 따로 만듭니다.
2. `AGENTS.md` 안의 스킬 경로를 실제 키트 위치로 바꿉니다.
3. 작업 폴더가 git 저장소가 아니면 `git init`만 합니다. 커밋은 하지 않습니다.

## 무엇이 어디 있나

| 경로 | 내용 | 언제 |
| --- | --- | --- |
| `STRATEGY.md` | 전략 전문: 평가 구조, 공식 조건, 플레이북, 대화법, 서술형 대비 | 시험 전날 정독 |
| `checklists/pre-exam.md` | 준비물, 사전 체험 15분 점검표, 당일 타임라인 | 전날·당일 아침 |
| `playbook/` | 180분을 단계별로 나눈 규칙. 단계마다 목표·할 일·프롬프트·남길 증거·금지 행동 | 시험 중 단계 전환 때 |
| `prompts/codex-prompts.md` | 단계별 Codex 프롬프트 | 시험 중 |
| `prompts/interviewer-questions.md` | 업무 담당자 에이전트 인터뷰 7단계 질문 | 문제 발굴 단계 |
| `rubric/evaluation-checklist.md` | 기술·의도·인지 9개 기준별로 무엇을 남겨야 하는지 | 제출 전 자가 점검 |
| `rubric/followup-qa.md` | 서술형 6문항 × 5분 대비 | 150분 이후 |
| `rubric/cost-control.md` | 토큰 비용 줄이는 습관 | 수시 |
| `templates/` | AGENTS.md, AGREEMENT.md, INTERVIEW.md, DECISIONS.md, VERIFICATION.md, HANDOFF.md | setup.sh가 복사 |
| `skills/` | Codex에게 읽힐 절차 스킬 7개 (SKILL.md 형식) | 필요할 때 경로를 알려주고 읽게 함 |

## 읽는 순서

- **시험 전날**: `STRATEGY.md` → `playbook/00-timeline.md` → `rubric/evaluation-checklist.md`
- **당일 아침**: `checklists/pre-exam.md`, `prompts/interviewer-questions.md`
- **시험 중**: 단계가 바뀔 때마다 해당 `playbook/0N-*.md`의 "종료 조건"만 확인

## 스킬 쓰는 법

Codex에게 경로를 알려주고 읽게 합니다. 예:

```
~/kit/skills/handoff/SKILL.md 를 읽고 그 절차대로 HANDOFF.md를 갱신해줘.
```

`setup.sh`가 만든 `AGENTS.md`에도 스킬 경로 목록이 들어 있어서, Codex가 필요할 때 스스로 찾아 읽을 수 있습니다.

## 지켜야 할 규칙

- 키트는 작업 폴더 밖에 받습니다. 제출물에는 내가 과제 중에 쓴 것만 들어가야 합니다.
- 이 저장소에는 결과물 코드가 없습니다. 공개 코드로 결과물을 통째로 대체하는 것은 금지입니다.
- 가이드상 "일반적으로 공개된 Skill과 공개 GitHub 저장소"는 쓸 수 있습니다. 본인이 만든 공개 저장소가 여기에 해당하는지는 Cofa 팀 확인을 권장합니다.
- 키·토큰·비밀번호는 이 저장소에 없고, 넣지도 않습니다. Git Push는 시험 환경에서 불가합니다(이 키트는 clone/pull만).
- 서술형 30분은 AI·복사·붙여넣기 금지입니다. 이 키트도 그때는 쓸 수 없습니다.
