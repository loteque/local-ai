# Voice-to-Repo Phase One Implementation Plan

## Status

This document is the implementation plan for **Phase One** of `docs/VOICE_TO_REPO_INTERFACE_DESIGN.md`.

It is an implementation plan inside the existing **Elastic Resident AI** architecture. It does not introduce a competing topology, change the project's current experimental gate, or authorize repository mutation.

Phase One remains strictly **explicit, authenticated, read-only repository observation**.

## What will be built

Build the smallest workstation-side service that can expose accurate local repository state through a narrow authenticated API and produce structured audit evidence for each request.

The Phase One service will provide:

- a FastAPI process running on the workstation;
- explicit repository registration/configuration;
- application-level authentication;
- `GET /api/v1/health`;
- `GET /api/v1/repos`;
- `GET /api/v1/repos/{repo_id}/overview`;
- a deterministic read-only Git adapter;
- structured audit logging;
- tests proving the API cannot mutate repositories through its exposed operation set.

The Android client, speech-to-text, text-to-speech, Tailscale remote access, GitHub API integration, and model-based natural-language interpretation are deliberately deferred until the deterministic repository-observation spine is working and measured.

## Why this is the next step

The voice-interface design depends on a trustworthy workstation service. Building Android, speech, remote networking, or model interpretation before that service exists would add multiple failure domains before the core authority boundary has been tested.

The smallest useful experiment is therefore:

```text
local authenticated request
        -> deterministic API
        -> read-only Git observation
        -> structured result
        -> audit event
```

This isolates the essential question before voice or networking complexity enters the loop.

## Question this phase resolves

> Can the workstation expose accurate, current repository state through a narrow authenticated interface while failing closed, recording useful evidence, and providing no repository mutation path?

## Success condition

Phase One succeeds when all of the following are demonstrated on the target workstation:

1. The service starts locally and reports healthy state.
2. Only explicitly configured repositories are visible.
3. Repository overview responses reflect actual Git state at request time.
4. Every meaningful request produces a structured audit event.
5. Authentication failures are rejected and logged appropriately.
6. Missing, invalid, or inaccessible repositories fail clearly rather than producing guessed state.
7. The exposed Phase One operation set contains no repository mutation capability.
8. Automated tests verify the core read-only and fail-closed behavior.
9. A documented target-machine run report captures the result.

## Non-goals

Phase One does not implement:

- Android UI;
- speech recognition;
- speech synthesis;
- Tailscale configuration;
- public or remote service exposure;
- GitHub API calls;
- natural-language model interpretation;
- arbitrary shell execution;
- repository writes;
- branch creation;
- commits;
- pushes;
- pull-request creation or modification;
- autonomous background work.

These are later experiments and must not leak into the Phase One authority surface.

## Implementation principles

### Deterministic observation first

Git state should be collected through deterministic software, not inferred by a model.

Use a narrow Git adapter with explicit read-only operations. Avoid exposing a generic shell-command endpoint.

### Repository allowlist

The service must not accept arbitrary filesystem paths from the client.

Repositories should be configured server-side with stable IDs mapped to canonical local paths.

Example conceptual configuration:

```yaml
repositories:
  local-ai:
    path: /absolute/path/to/local-ai
```

The exact configuration format is an implementation detail, but the server-owned mapping is a requirement.

### Local-only by default

The first service binds only to loopback unless a later documented remote-access experiment explicitly changes that configuration.

No cloud service is required for Phase One operation.

### Explicit authority boundary

The API may request only predefined observation operations.

The implementation must not transform client text into unrestricted Git or shell commands.

### Structured evidence

API responses and audit records should use structured data so correctness can be tested directly.

## Proposed repository layout

The implementation may use a compact layout such as:

```text
voice_repo/
  __init__.py
  app.py
  config.py
  auth.py
  models.py
  git_reader.py
  audit.py
  routes/
    __init__.py
    health.py
    repos.py

tests/
  test_health.py
  test_auth.py
  test_repo_listing.py
  test_repo_overview.py
  test_read_only_boundary.py
```

This layout is a candidate, not a permanent contract. Keep the implementation small enough that abstraction layers exist only where they protect an actual boundary.

## API contract for Phase One

### `GET /api/v1/health`

Purpose: prove the service process is reachable and internally ready.

Candidate response:

```json
{
  "status": "ok",
  "api_version": "v1"
}
```

The health endpoint should not expose sensitive machine or repository information.

### `GET /api/v1/repos`

Purpose: list only repositories explicitly exposed by workstation configuration.

Candidate response:

```json
{
  "repositories": [
    {
      "id": "local-ai"
    }
  ]
}
```

Do not return arbitrary local paths to clients unless a later requirement establishes a need.

### `GET /api/v1/repos/{repo_id}/overview`

Purpose: return current structured Git state for one configured repository.

Candidate response shape:

```json
{
  "repo_id": "local-ai",
  "head": {
    "branch": "main",
    "commit": "<full-commit-sha>"
  },
  "working_tree": {
    "clean": true,
    "changes": []
  },
  "upstream": {
    "name": "origin/main",
    "ahead": 0,
    "behind": 0,
    "available": true
  },
  "recent_commits": [
    {
      "sha": "<full-commit-sha>",
      "subject": "..."
    }
  ],
  "observed_at": "<timestamp>"
}
```

Fields that cannot be established should be represented explicitly as unavailable rather than guessed.

## Git observation adapter

The Git adapter is the most important deterministic boundary in Phase One.

It should support only the observations needed by the API, such as:

- resolve repository validity;
- resolve exact `HEAD` commit;
- resolve current branch or detached-HEAD state;
- read working-tree status;
- resolve configured upstream where available;
- compute ahead/behind counts without fetching;
- read a small bounded recent-commit history.

Candidate Git commands may include read-only forms of:

```text
git rev-parse --is-inside-work-tree
git rev-parse HEAD
git symbolic-ref --short -q HEAD
git status --porcelain=v1
git rev-parse --abbrev-ref --symbolic-full-name @{upstream}
git rev-list --left-right --count HEAD...@{upstream}
git log -n <bounded-count> --format=...
```

These commands are examples for implementation planning. The resulting implementation should call them with fixed argument arrays, controlled working directories, bounded outputs, and no shell interpolation.

No Git operation in Phase One should write refs, index state, working-tree content, configuration, remotes, or object data.

## Authentication

Implement a minimal application-level authentication mechanism suitable for the prototype while preserving a replaceable interface.

Requirements:

- unauthenticated repository endpoints are rejected;
- credentials are supplied through runtime configuration, not committed to the repository;
- authentication comparison avoids obvious timing-sensitive string comparison where practical;
- failed authentication does not reveal repository information;
- authentication outcomes produce suitable audit metadata without logging secret values.

A static bearer token is acceptable for this phase if implemented cleanly and documented as a prototype mechanism rather than a permanent identity architecture.

## Audit logging

Each meaningful request should emit one structured local audit event.

Minimum candidate fields:

```json
{
  "timestamp": "...",
  "request_id": "...",
  "client": "...",
  "operation": "repo.overview",
  "repo_id": "local-ai",
  "auth_result": "allowed",
  "policy_result": "allowed",
  "result": "success",
  "duration_ms": 0
}
```

Do not log authentication secrets or unnecessary repository contents.

For the first implementation, newline-delimited JSON in a local file is sufficient if it remains reliable and testable. A database is not required merely for architectural neatness.

## Failure semantics

The service must distinguish at least these cases:

- unauthenticated request;
- unknown `repo_id`;
- configured path missing;
- configured path is not a Git repository;
- Git command failure;
- upstream not configured;
- detached `HEAD`;
- permission failure;
- audit write failure;
- unexpected internal failure.

A failure must not be converted into a fabricated repository state.

For partial observations, return established fields and mark unavailable fields explicitly when the API contract permits partial results.

Audit failure deserves special treatment: if the system cannot produce required audit evidence for an authenticated repository observation, the initial implementation should fail closed rather than silently serving unaudited observations. This behavior should be tested and reconsidered only if measurement shows a concrete reliability or UX problem.

## Read-only enforcement strategy

Phase One should enforce read-only behavior through several layers rather than relying on instruction text.

### Layer 1: API surface

Expose only observation endpoints.

### Layer 2: adapter surface

The Git adapter contains only named read operations and no generic `run_git(args)` method exposed outside its implementation boundary unless the allowed argument set is internally constrained.

### Layer 3: command construction

Use fixed executable and argument arrays. Do not invoke a shell for Git observation.

### Layer 4: tests

Tests should snapshot repository state before and after API calls and verify that no tracked files, untracked files, refs, index state, Git config, or relevant repository metadata changed.

### Layer 5: later optional OS hardening

Filesystem or service-user restrictions may later provide defense in depth, but Phase One should not invent an elaborate sandbox before the narrow deterministic service has been tested.

## Implementation sequence

### Step 1: service skeleton

Create the minimal Python package and FastAPI application.

Implement:

- app startup;
- versioned router;
- `GET /api/v1/health`;
- test client coverage.

Exit criterion: health endpoint passes automated tests without repository access.

### Step 2: configuration and repository registry

Implement server-owned repository ID to canonical path mapping.

Validate configuration at startup or first use with explicit errors.

Exit criterion: configured repositories can be listed while arbitrary client paths cannot be requested.

### Step 3: authentication

Add authentication middleware/dependency for repository endpoints.

Keep health behavior intentionally minimal and decide whether health requires authentication based on information exposure, not convenience.

Exit criterion: unauthorized repository requests fail and authorized requests succeed in tests.

### Step 4: deterministic Git reader

Implement the smallest observation adapter required for repository overview.

Do not add model inference or GitHub access.

Exit criterion: adapter tests establish exact HEAD, branch state, working-tree state, upstream state, and bounded recent history across representative fixture repositories.

### Step 5: repository overview endpoint

Connect the Git reader to:

```text
GET /api/v1/repos/{repo_id}/overview
```

Exit criterion: API output matches independently inspected fixture state.

### Step 6: audit trail

Add structured request IDs, timings, authentication outcome metadata, operation metadata, and result state.

Exit criterion: successful and failed repository observations produce expected audit entries with no secrets.

### Step 7: read-only boundary tests

Construct tests that invoke every Phase One endpoint against disposable Git repositories and compare state before and after requests.

Include malformed IDs, suspicious path-like IDs, repeated requests, detached HEAD, dirty worktree, no upstream, and Git failure cases.

Exit criterion: no tested request mutates repository state and path traversal cannot escape the configured registry.

### Step 8: target-workstation validation protocol

Before asking the user to run the service on the target workstation, add a repository-tracked validation protocol and any helper script required by that protocol.

The protocol must identify:

- exact project revision;
- prerequisites;
- installation/setup commands;
- service-start command;
- test commands;
- expected output;
- raw output location;
- structured run-report location;
- failure-preservation instructions;
- secret-redaction requirements.

Exit criterion: the target-machine procedure is fully repository-mediated before execution.

### Step 9: target-workstation run

Run the documented protocol on the actual workstation and commit/push the resulting report and raw evidence back to the repository.

Do not treat implementation tests on another environment as target-machine evidence.

Exit criterion: repository evidence records whether Phase One works on the target machine and identifies any observed failures or interference.

## Test matrix

At minimum, automated tests should cover:

| Area | Cases |
| --- | --- |
| Health | service ready; stable version response |
| Authentication | missing token; wrong token; valid token |
| Repository registry | known ID; unknown ID; traversal-like ID; missing configured path |
| Git validity | valid repository; non-repository directory |
| HEAD | normal branch; detached HEAD |
| Worktree | clean; modified tracked file; untracked file; staged change |
| Upstream | configured; absent; ahead; behind; diverged |
| History | bounded commit count; unusual commit subject text |
| Audit | success; auth failure; repo failure; audit-write failure |
| Read-only boundary | repeated overview requests leave repository state unchanged |

## Measurement plan

Phase One is primarily a correctness and authority-boundary experiment, but basic performance should be measured so later voice work has a baseline.

Record at least:

- service startup time;
- health endpoint latency;
- repository overview latency;
- Git observation component timings where useful;
- audit-write latency;
- CPU and memory footprint at idle and during repeated overview requests;
- any noticeable workstation interference during the validation run.

Do not optimize prematurely. These measurements establish a baseline for deciding whether FastAPI/Python or the observation strategy creates a real problem.

## Evidence classification

When evaluating the implementation, preserve these distinctions:

- **documented fact:** behavior required by repository contracts or upstream tool documentation;
- **implementation fact:** behavior established by automated tests for a specific revision;
- **target-machine measurement:** behavior recorded by the documented workstation protocol;
- **estimate:** expected behavior not yet measured;
- **architectural judgment:** a design choice made to preserve boundaries or reduce experimental complexity;
- **assumption:** an unverified condition that must not be promoted into a project conclusion.

## Dependencies

Keep Phase One dependencies intentionally small.

Likely direct Python dependencies:

- FastAPI;
- an ASGI server such as Uvicorn;
- Pydantic as required by the FastAPI version;
- pytest and test support dependencies.

Prefer the Python standard library for configuration, subprocess execution, timestamps, JSON-lines logging, and token handling where practical.

Do not add a Git library, ORM, distributed queue, agent framework, vector database, or model-serving dependency unless an observed need appears.

## Security posture for the prototype

This phase is not a complete security architecture, but it must preserve the core trust boundary.

Required posture:

- bind locally by default;
- no arbitrary path access;
- no shell interpolation;
- no arbitrary Git arguments from clients;
- no mutation endpoints;
- no secrets in source control or logs;
- bounded command output and timeouts where practical;
- clear error responses without unnecessary local path disclosure;
- fail closed for authentication and policy uncertainty.

Remote threat modeling should occur before the service is exposed over Tailscale in a later phase.

## Exit review

At the end of Phase One, review the evidence before expanding scope.

Ask:

1. Is repository state accurate enough to trust conversational reports built on top of it?
2. Is the deterministic observation layer simple and maintainable?
3. Did any request or error path mutate repository state?
4. Is the audit evidence sufficient to reconstruct what the service observed and did?
5. Is FastAPI/Python latency or workstation interference actually problematic?
6. Did the target workstation reveal assumptions not represented in tests?
7. What is the smallest next capability needed to reach a spoken end-to-end prototype?

Only after that review should the project select the next experiment among natural-language interpretation, Android client work, speech placement, Tailscale access, or optional GitHub state.

## Phase One deliverables

The implementation phase is complete when the repository contains:

- workstation service source code;
- explicit configuration example without secrets;
- automated tests;
- read-only boundary tests;
- local audit implementation;
- target-machine validation protocol;
- any required validation helper scripts;
- raw target-machine validation output;
- structured target-machine run report;
- a concise result interpretation tied to the exact tested revision.

## Governing rule

The goal is not to build the whole voice assistant in one pass.

The goal is to earn the next layer by proving the foundation:

**Observe exactly. Authorize deterministically. Change nothing. Record what happened.**
