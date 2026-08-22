# Gate 0: Workstation Baseline

## Current step: system-state bootstrap

This is the first Gate 0 experiment. It does **not** yet measure the representative workload baselines themselves.

Its purpose is to prove the repository handoff and capture enough authoritative target-machine state to design the later idle, browser, development, 3D, rendering, and image-editing measurements without guessing about the machine configuration.

### Question

Can the project reproducibly capture enough target-machine state to interpret later Gate 0 measurements while avoiding unnecessary sensitive or identifying data?

### Success condition

A successful run:

- is tied to an exact project commit and exact collector revision;
- produces a structured result directory under `results/gate-0/system-state/`;
- records the relevant CPU, memory, storage, kernel, graphics, driver, display-topology, and already-installed measurement/runtime tooling state;
- records unavailable optional commands rather than requiring installation;
- requires no root privileges and makes no machine-configuration changes;
- can be pushed to the repository and interpreted without copying terminal output through chat.

## Safety and privacy boundary

The collector is observational. It writes only its result directory in the repository.

It does not use `sudo`, install packages, change configuration, or make network requests.

The protocol intentionally avoids collecting:

- hostname;
- username or home-directory path;
- hardware serial numbers;
- monitor EDID data;
- network configuration or credentials;
- SSH material;
- browser data;
- process command lines;
- a wholesale environment-variable dump.

Optional commands such as `vulkaninfo` or `glxinfo` are used only when they are already installed. Their absence is recorded as part of the run.

## Prerequisites

Use a local checkout of `loteque/local-ai` with no intentional tracked-file modifications.

`git` and `bash` are required. No additional package installation is required for this bootstrap run.

## Exact run procedure

From the repository checkout:

```bash
git switch main
git pull --ff-only
bash experiments/gate-0/collect-system-state.sh
```

The collector prints a run ID and result path similar to:

```text
results/gate-0/system-state/20260822T020000Z-0123456789ab
```

Do not rename or combine run directories.

## Inspect before pushing

Inspect the generated result directory before committing it.

If a generated file unexpectedly contains a secret or irrelevant identifying information, do **not** edit the raw evidence into a cleaner-looking run. Remove that entire unpushed run directory, report the collection problem, and let the protocol be corrected before repeating the run.

The generated `notes.md` may be used for operator observations. Raw files under `raw/` should otherwise remain unchanged.

## Push procedure

Use the run ID printed by the collector. The result should first be pushed on a result branch so concurrent `main` updates, including Project Steward bookkeeping, cannot invalidate or block the handoff.

```bash
run_id='<run-id printed by the collector>'
git switch -c "results/gate0-system-state-${run_id}"
git add -- "results/gate-0/system-state/${run_id}"
git commit -m "Add Gate 0 system-state run ${run_id}"
git push -u origin HEAD
```

After the branch is pushed, provide the run ID or branch name in chat. The architect will read the repository artifact directly and determine the next Gate 0 measurement step.

## Evidence interpretation

A run from this protocol is **target-machine measurement evidence** for the state actually captured at that time. It is not evidence that a later configuration is identical, and it is not yet a workstation-performance baseline.

The next Gate 0 protocol should be chosen from the captured state rather than assuming which telemetry tools, display topology, driver stack, or workload instrumentation are available.
