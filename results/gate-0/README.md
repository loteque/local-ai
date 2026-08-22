# Gate 0 Results

This directory contains target-machine evidence produced by the versioned Gate 0 protocols under `experiments/gate-0/`.

## Evidence contract

Each run must identify the exact project commit and collector/protocol revision that produced it.

Generated raw outputs should be preserved unchanged once a safe run is pushed. Operator observations belong in the run's `notes.md` or in later analysis artifacts, not by rewriting raw command output.

Failed or partial runs are evidence when they are safe to retain. If a collector itself captures a secret or irrelevant identifying information, do not push that run. Correct the protocol and repeat it instead.

A run report records what the target machine actually exposed at the time of collection. It does not establish that later machine state is identical.

## Layout

The initial bootstrap collector writes:

```text
results/gate-0/system-state/<run-id>/
  manifest.txt
  notes.md
  raw/
    ...command outputs...
```

Later Gate 0 workload protocols may add separate result families beneath this directory rather than mixing unlike experiments into one run format.

## Repository handoff

Follow the push procedure documented by the corresponding experiment protocol. Result branches are preferred for initial handoff so target-machine evidence does not race unrelated changes to `main`.
