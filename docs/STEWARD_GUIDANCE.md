# Project Steward Guidance

Reviewed project through: `aec062f90ea73e9452a14fdc9b151cb186a2be92`

Steward role contract: `roles/PROJECT_STEWARD.md`

## Current assessment

The Elastic Resident AI remains the correct primary experimental baseline.

The repository continues to express the intended maximal-first philosophy clearly: begin with the strongest plausibly useful resident system, measure actual workstation interference and UX failures, introduce only the narrowest evidence-driven compromises, and restore capability when constraints disappear.

The prior governance inconsistency between the primary architect role and the independent Project Steward role has been resolved. No new architectural, experimental, local-only, authority-boundary, or workstation-coexistence finding is introduced by the reviewed delta.

## Open findings

None.

## Watch items

### STEW-W001 - Maximal resident baseline remains unmeasured

The project correctly prefers maximal useful residency, but no target-machine measurement yet establishes the strongest practical resident model, quantization, backend, context, or VRAM envelope.

Preserve this as an open experimental question. Do not convert the current approximately 9B examples into a fixed architecture before Gate 2 evidence exists.

### STEW-W002 - ROCm/HIP versus Vulkan remains unresolved

ROCm/HIP is a serious first-class candidate and Vulkan is a serious first-class candidate. No target-machine qualification result currently establishes a preferred backend.

Do not let package choice, community evidence, or official support tables silently settle this question.

### STEW-W003 - Workstation coexistence limits remain unmeasured

No evidence yet establishes how AI residency affects representative programming, 3D game development, digital-art, rendering, or daily-driver workloads on the target machine.

Do not reserve fixed VRAM, CPU, RAM, or context headroom before mixed-workload measurements require it.

## Cleared findings

### STEW-001 - Cleared at `aec062f90ea73e9452a14fdc9b151cb186a2be92`

`PROJECT_PROMPT.md` now assigns the primary assistant the architect, research, experimental-design, and implementation roles while explicitly recognizing the independent Project Steward defined by `roles/PROJECT_STEWARD.md`.

The conflicting stewardship claim has been removed without weakening the project prompt or the independent review contract.

## Steward posture for the next gate

The next implementation work should establish measurement capability and Gate 0 workstation baselines without preemptively constraining the Elastic Resident design.

The Steward should specifically challenge any attempt to encode fixed resource reserves, a permanent backend preference, or a fixed 9B model ceiling before target-machine evidence exists.
