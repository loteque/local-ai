# Project Steward Guidance

Reviewed project through: `02e1ec9d7c62c36456cb2b80b9c8a6e97dbcc8e6`

Steward role contract: `roles/PROJECT_STEWARD.md`

## Current assessment

The Elastic Resident AI remains the correct primary experimental baseline.

The repository continues to express the intended maximal-first philosophy clearly: begin with the strongest plausibly useful resident system, measure actual workstation interference and UX failures, introduce only the narrowest evidence-driven compromises, and restore capability when constraints disappear.

The reviewed substantive delta adds `docs/VOICE_TO_REPO_PHASE1_IMPLEMENTATION_PLAN.md`, implementing the first deterministic slice of the existing voice-to-repository interface experiment. The plan remains inside Elastic Resident AI, does not advance or replace the governing model-topology gates, and keeps Phase One explicitly authenticated and read-only. It defers Android, speech, remote networking, GitHub integration, and model interpretation until the workstation-side observation spine is established, which is a sequencing choice to isolate correctness and authority-boundary evidence rather than a permanent architectural reduction.

The Phase One plan preserves the important boundaries established by the interface design: repositories are server-registered rather than client-selected by arbitrary path, Git observations use fixed read-only operations without shell interpolation, unavailable state must be represented explicitly rather than guessed, audit failures fail closed for the initial experiment, and target-workstation validation must be repository-mediated before execution. FastAPI, Python, bearer-token authentication, JSONL audit storage, and the proposed package layout are labeled as prototype or replaceable implementation choices. The plan also records basic latency, CPU, memory, and workstation-interference measurements so convenience does not silently promote those choices into permanent requirements.

The existing README optimization-weight finding and Cognitive Cascade framing finding remain open and unchanged. No new local-only, authority-boundary, backend/model/topology coupling, workstation-coexistence, premature-compromise, unfair-experiment, unsupported-conclusion, or unnecessary-complexity finding is warranted by the reviewed substantive delta.

## Open findings

### STEW-002 - S3 - README invents quantitative optimization weights

**Repository fact:** `README.md` presents an "Optimization priorities" pie chart assigning exact weights of 25, 18, 16, 14, 10, 7, 5, and 5 percent to the project's optimization priorities.

**Risk:** Those numbers are not established by `PROJECT_PROMPT.md` or `docs/ELASTIC_RESIDENT_AI_DESIGN.md`. The prompt instead gives an approximate ordering and explicitly says not to reduce the tradeoff immediately to one scalar score. Because the README is a high-visibility orientation document, illustrative percentages could be reused later as if they were project-approved quantitative weights, creating unsupported optimization policy and potentially distorting Pareto decisions.

**Why evidence is insufficient:** No measurement, user decision, design record, or governing requirement derives or approves those percentages.

**Smallest corrective step:** Replace the weighted pie with a non-quantitative visualization or an explicitly ordinal representation that mirrors the governing priority order without invented numeric magnitudes.

**Resolution condition:** Clear this finding when the README no longer presents unsupported quantitative weights as project optimization priorities, or when a separately approved project decision establishes such weights with a justified method.

### STEW-003 - S3 - Cognitive Cascade is framed as a peer path before evidence earns the departure

**Repository fact:** `docs/COGNITIVE_CASCADE_DESIGN.md` defines Cognitive Cascade as an "alternative architectural path" whose common path uses a small or modest persistent cognitive front-end and selectively recruits larger reasoning systems. `README.md` likewise presents it as a "second architectural path" and an "experimental alternative" alongside Elastic Resident AI. The design correctly labels the idea as a hypothesis and says Elastic Resident AI remains primary.

**Risk:** The governing prompt says new distinct designs should target a real limitation not already represented by the elastic architecture, and that other architectures remain primarily compromise envelopes unless evidence demonstrates a superior frontier. A small-front-end-first topology deliberately gives up always-resident generalist capability before Gate 2 has established the maximal resident baseline or mixed-workload evidence has shown that such a retreat is needed. Calling the hypothesis a peer architectural path now may later allow implementation convenience, edge-oriented intuition, or orchestration enthusiasm to bypass the maximal-first experiment.

**Why evidence is insufficient:** No target-machine measurement currently shows that the strongest practical resident generalist causes unacceptable latency or workstation interference, and no controlled comparison shows that the Cognitive Cascade topology provides a better capability/latency/correctness/coexistence frontier. The new design itself schedules those comparisons as future experiments.

**Smallest corrective step:** Preserve the Cognitive Cascade document and experiments, but treat the topology as an experimental interpretation or candidate envelope inside Elastic Resident AI until a controlled comparison establishes that the distinct small-front-end-first organization solves a measured limitation or provides a superior frontier. Do not use the alternative-path label as implementation authority to start from a weaker resident model.

**Resolution condition:** Clear this finding when either (a) the repository framing makes Cognitive Cascade explicitly subordinate to the maximal resident baseline until comparative evidence exists, or (b) reproducible target-machine evidence establishes a real limitation in the baseline and demonstrates that the Cognitive Cascade topology materially improves the relevant frontier without unacceptable correctness, latency, complexity, or coexistence cost.

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

The Steward should specifically challenge any attempt to encode fixed resource reserves, a permanent backend preference, a fixed 9B model ceiling, unsupported quantitative optimization weights, or a small-front-end-first implementation default before evidence or an explicit governing decision exists.

If Cognitive Cascade experiments are prepared, require a fair controlled comparison against the strongest practical resident-generalist baseline, including end-to-end usefulness, escalation errors, retrieval quality, orchestration overhead, workstation interference, and the cost of missed or unnecessary escalation. Preserve the research direction without allowing it to become a premature compromise.

Treat Domain Crystallization as deferred research until durable-memory provenance, correction semantics, stable evaluation tasks, and representative accumulated domain evidence exist. If specialist experiments eventually begin, preserve the document's controlled comparisons against an equivalently sized generalist, the stronger teacher/general model, and deterministic-plus-retrieval baselines, and reject specialist complexity when it does not improve the measured practical frontier.

Treat the Voice-to-Repo work as an interface experiment orthogonal to the model-topology gates. Preserve Phase One's read-only authority boundary, re-observation of repository state, explicit network-dependency reporting, replaceable transport/runtime choices, and workstation-interference measurements. The Phase One implementation plan should remain a narrow deterministic validation spine rather than authority to freeze FastAPI, Python, token authentication, audit storage, or service topology before target-machine evidence exists. Do not allow remote convenience or future mutation features to grant semantic authority to the phone, network layer, model, or orchestration lifecycle.