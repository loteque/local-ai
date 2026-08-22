# Project Steward Guidance

Reviewed project through: `7bb979c42b05278c569636069abbecd4d1fe7b40`

Steward role contract: `roles/PROJECT_STEWARD.md`

## Current assessment

The Elastic Resident AI remains the correct primary experimental baseline.

The repository continues to express the intended maximal-first philosophy clearly: begin with the strongest plausibly useful resident system, measure actual workstation interference and UX failures, introduce only the narrowest evidence-driven compromises, and restore capability when constraints disappear.

The reviewed delta adds a project README that accurately summarizes most of the governing architecture, local-only boundary, staged experimental program, workstation-coexistence requirement, and evidence-first posture. It does not lock in a backend, model size, quantization, topology, resource reserve, or compromise envelope.

One issue should be corrected before the README is allowed to act as a durable summary of project decision policy: its optimization-priority pie chart assigns exact percentage weights that do not exist in the governing prompt or design. The governing source provides an approximate ordinal priority and explicitly cautions against prematurely reducing tradeoffs to a scalar score. The README text repeats the Pareto requirement, but the invented percentages can still be mistaken for quantitative decision weights.

No new local-only, authority-boundary, workstation-coexistence, backend-coupling, or maximal-residency regression is otherwise introduced by the reviewed delta.

## Open findings

### STEW-002 - S3 - README invents quantitative optimization weights

**Repository fact:** `README.md` presents an "Optimization priorities" pie chart assigning exact weights of 25, 18, 16, 14, 10, 7, 5, and 5 percent to the project's optimization priorities.

**Risk:** Those numbers are not established by `PROJECT_PROMPT.md` or `docs/ELASTIC_RESIDENT_AI_DESIGN.md`. The prompt instead gives an approximate ordering and explicitly says not to reduce the tradeoff immediately to one scalar score. Because the README is a high-visibility orientation document, illustrative percentages could be reused later as if they were project-approved quantitative weights, creating unsupported optimization policy and potentially distorting Pareto decisions.

**Why evidence is insufficient:** No measurement, user decision, design record, or governing requirement derives or approves those percentages.

**Smallest corrective step:** Replace the weighted pie with a non-quantitative visualization or an explicitly ordinal representation that mirrors the governing priority order without invented numeric magnitudes.

**Resolution condition:** Clear this finding when the README no longer presents unsupported quantitative weights as project optimization priorities, or when a separately approved project decision establishes such weights with a justified method.

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

Gate 0 should continue using repository-mediated protocols and target-machine evidence to establish authoritative machine state and representative workload baselines. The bootstrap result should not be treated as a workstation-performance baseline, and later Gate 0 workload protocols should remain driven by observed target-machine tooling and state rather than assumptions.

The Steward should specifically challenge any attempt to encode fixed resource reserves, a permanent backend preference, a fixed 9B model ceiling, or unsupported quantitative optimization weights before evidence or an explicit governing decision exists.
