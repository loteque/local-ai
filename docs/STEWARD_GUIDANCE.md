# Project Steward Guidance

Reviewed project through: `e9595371bd217e17c9d8fa54ebe86c7c24bfe6a4`

Steward role contract: `roles/PROJECT_STEWARD.md`

## Current assessment

The Elastic Resident AI remains the correct primary experimental baseline.

The repository currently expresses the intended maximal-first philosophy clearly: begin with the strongest plausibly useful resident system, measure actual workstation interference and UX failures, introduce only the narrowest evidence-driven compromises, and restore capability when constraints disappear.

One governance inconsistency should be corrected before implementation work advances.

## Open findings

### STEW-001 - S1 Contract risk - Primary role still claims stewardship

**Evidence**

`PROJECT_PROMPT.md` currently defines the primary assistant as the technical architect, research partner, experimental designer, implementation assistant, **and project steward**.

`roles/PROJECT_STEWARD.md` now defines the Project Steward as an independent adversarial reviewer whose purpose is to check the work of the primary architect and implementer, and explicitly states that the primary architect may not impersonate the independent Steward when evaluating its own work.

These statements conflict.

**Failure mode**

If the primary implementation role is also treated as the Steward, the independence check collapses. Architectural assumptions could be proposed, implemented, and self-cleared by the same role.

**Recommendation**

Update `PROJECT_PROMPT.md` so the primary role is the technical architect, research partner, experimental designer, and implementation assistant, while the independent Project Steward role is defined by `roles/PROJECT_STEWARD.md` and its current guidance is consulted before consequential project work.

Do not otherwise weaken or rewrite the project prompt merely to resolve this finding.

**Resolution condition**

Clear this finding when the governing prompt no longer assigns independent stewardship to the primary implementation role and the two role contracts are semantically consistent.

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

None.

## Steward posture for the next gate

The next implementation work should establish measurement capability and Gate 0 workstation baselines without preemptively constraining the Elastic Resident design.

The Steward should specifically challenge any attempt to encode fixed resource reserves, a permanent backend preference, or a fixed 9B model ceiling before target-machine evidence exists.
