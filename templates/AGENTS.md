# 작업 규칙

이 파일은 코딩 에이전트(Codex)가 이 작업 폴더에서 따르는 규칙이다.

## 기준 문서

- 목표·성공 기준·범위: `AGREEMENT.md`. 여기에 없는 기능은 만들지 말고 제안만 한다.
- 담당자 인터뷰 기록: `INTERVIEW.md`
- 설계 결정 기록: `DECISIONS.md` (결정할 때마다 한 줄 추가)
- 검증 기록: `VERIFICATION.md`
- 인계 문서: `HANDOFF.md`
- 과제 지시서(README)가 필수 문서·파일명을 정하면 그것이 우선한다.

## 작업 방식

- 한 번에 기능 하나만 한다. 요청 범위 밖의 파일은 건드리지 않는다.
- 끝나면 다음 네 가지를 보고한다: 바꾼 파일, 실행한 명령, 실제 출력, 남은 문제. "완료"라고만 말하지 않는다.
- 판정·계산·규칙은 고정 코드로 만든다. LLM 호출은 해석·초안·요약에만 쓴다.
- 확실하지 않으면 추측하지 말고 멈춰서 질문한다.
- 합의된 요구에 없는 캐시, 큐, 인증, 부하 대비 장치는 넣지 않는다. 필요해 보이면 `DECISIONS.md`의 "보류" 항목에 적는다.
- 같은 실패를 두 번 반복하면 멈추고, 원인 가설 2개와 확인 방법을 보고한다.

## 실행 환경

- 웹 서버는 `0.0.0.0`에 바인딩하고 실제 실행 포트를 보고한다.
- 의존성은 최소로 한다. 새 패키지를 추가하면 이유를 `DECISIONS.md`에 적는다.
- 실행·테스트 명령은 README에 적고 실제로 실행한 결과를 `VERIFICATION.md`에 남긴다.

## 보안

- 키·토큰·비밀번호는 코드에 쓰지 않고 환경 변수로 받는다. `.env`는 커밋하지 않는다.
- 개인정보는 필요한 필드만 다루고 로그에 남기지 않는다. 입력값은 검증한다.
- 과제가 요구하지 않는 외부 전송 코드는 넣지 않는다.

## git

- 기능 하나가 검증되면 커밋한다. 메시지 형식: `feat: <무엇> (검증: <명령>)`
- 문서 갱신은 `docs: <무엇>`으로 따로 커밋한다.

## 필요할 때 읽을 절차

- 요구 발굴과 합의: `__KIT_DIR__/skills/requirements-discovery/SKILL.md`
- 위임과 검증 루프: `__KIT_DIR__/skills/delegate-and-verify/SKILL.md`
- 결정 기록: `__KIT_DIR__/skills/decision-log/SKILL.md`
- 보안 점검: `__KIT_DIR__/skills/security-review/SKILL.md`
- 인계 문서: `__KIT_DIR__/skills/handoff/SKILL.md`
- 서술형 대비: `__KIT_DIR__/skills/followup-qa-prep/SKILL.md`
- 제출 전 점검: `__KIT_DIR__/skills/pre-submit-check/SKILL.md`
