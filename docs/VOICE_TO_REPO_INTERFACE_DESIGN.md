# Voice-to-Repo Interface Design

## Status and relationship to the primary architecture

This document defines an interface and integration experiment within the **Elastic Resident AI** architecture described in `docs/ELASTIC_RESIDENT_AI_DESIGN.md`.

It does not define a competing model topology, weaken the maximal-resident baseline, or change the project's current experimental gate. The workstation remains the authoritative local AI environment. The Android device is an external interaction surface for reaching that environment.

The design follows the project rule:

> Start maximal. Measure reality. Compromise narrowly. Restore capability whenever possible.

## Summary

This experiment creates a voice-driven interface that lets a user speak to an Android device and have the trusted workstation inspect repository state, interpret the request, and return a concise spoken or textual response.

The first phase is deliberately narrow and read-only. Its initial end-to-end loop is:

```text
voice -> text -> intent -> repository observation -> report
```

Later phases may expand this path into planning, code generation, repository modification, and other governed actions, but only through explicit deterministic authorization and verification boundaries.

## Purpose and motivation

The purpose of this system is to reduce the physical interface between thought and software work.

Many repository-level decisions do not inherently require sitting at a keyboard. Architecture, implementation direction, issue triage, commit history, branch state, and project planning can often be reasoned about while walking, traveling, or otherwise away from the workstation.

The desired interaction is conversational:

> "What's the current state of the repository?"

> "What changed on main?"

> "What pull requests are open?"

A later governed system might support requests such as:

> "Create a branch for that idea and implement the first part."

The first experiment asks a much smaller question:

> Can a low-friction voice interface provide accurate repository awareness from anywhere while preserving explicit authority boundaries and making no repository changes?

Voice is therefore an interface to the larger resident-AI system, not a separate cognitive architecture.

## Overall architecture

```text
+------------------------------+
|        Android Phone         |
|                              |
|  Microphone / Speech Input   |
|  Minimal UI                  |
|  Response Playback           |
+--------------+---------------+
               |
               | authenticated request
               | over private connectivity
               |
+--------------v---------------+
|       Local Workstation      |
|                              |
|  API Service                 |
|  Authentication              |
|  Intent Interpretation       |
|  Policy / Authorization      |
|  Repository Observer         |
|  Git / GitHub Tools          |
|  Local Model(s)              |
|  Audit Log                   |
|  Speech Services as needed   |
+--------------+---------------+
               |
        +------+------+
        |             |
        v             v
   Local Git       GitHub API
   Repository      (optional)
```

The phone is primarily an **I/O endpoint**.

The workstation is the **trusted execution and reasoning environment**.

Repository access, policy enforcement, models, tools, and authoritative project observations stay on the workstation. The Android application does not become authoritative project state.

## Local-only boundary and remote use

Normal local operation must remain capable of functioning without outbound networking.

Local repository inspection, local inference, local speech processing where configured, policy enforcement, and audit logging must not silently depend on cloud services.

Remote use is an explicitly network-dependent interaction mode. Tailscale is the initial candidate for privately reaching the workstation while away from the local network. GitHub API access is likewise an optional external integration for GitHub-specific state.

If external connectivity is unavailable:

- the system must not silently fall back to another cloud service;
- local repository observations may continue when the workstation is reachable;
- GitHub-specific information must be reported as unavailable or incomplete;
- the user should be told which evidence was and was not obtained.

The private-network layer should remain replaceable. Future experiments may evaluate Headscale, direct WireGuard, or other approaches without changing the core repository-observation contract.

## Technology stack

### Android client

Initial candidate stack:

- **Kotlin** for application code;
- **Jetpack Compose** for UI;
- Android platform audio and speech facilities where useful;
- HTTPS communication with the workstation service;
- Tailscale connectivity for the first remote prototype.

The Android application should remain deliberately small.

Its primary responsibilities are:

1. capture explicit user input;
2. optionally perform speech-to-text;
3. send authenticated requests to the workstation;
4. display responses;
5. play spoken responses when appropriate;
6. present connection, authentication, and error state.

It should not own repository authority, policy decisions, or durable project state.

### Workstation service

Initial candidate stack:

- **Python**;
- **FastAPI**;
- local `git` commands or a narrow deterministic Git adapter for repository inspection;
- GitHub REST API where GitHub-specific state is required;
- modular interfaces for local model inference;
- structured local audit logging.

Python and FastAPI are implementation candidates for rapid experimentation, not permanent architectural requirements. Replace them if measurement shows a better implementation without changing the governing interface and authority contracts.

### Connectivity

Use **Tailscale** for the first remote prototype because it can provide private reachability without directly exposing the workstation service to the public Internet.

This is an implementation choice for rapid experimentation, not a permanent architectural dependency.

## Voice and bandwidth strategy

Two initial arrangements are plausible.

### Workstation speech-to-text

The phone records or streams compressed audio to the workstation, which performs speech recognition.

Potential advantages:

- extremely thin Android client;
- access to workstation compute;
- easy comparison among local speech models.

Potential costs:

- higher network bandwidth;
- additional network-sensitive latency;
- transmitting voice data over the remote link.

### On-device speech-to-text

Speech recognition occurs on Android and only text is sent to the workstation.

Potential advantages:

- very low transport bandwidth;
- reduced voice-data exposure over the network;
- improved resilience under weak cellular connections.

Potential costs:

- phone CPU, memory, battery, and thermal use;
- potentially different recognition quality;
- additional Android implementation complexity.

The architecture should not decide this by assumption.

Internally, **text should be the canonical representation of a user request after speech recognition**. This keeps speech recognition placement independent from repository interpretation and execution.

The prototype should measure both arrangements if they remain plausible after the first working loop.

## API topology

The initial API should be small, explicit, versioned, deterministic where possible, and easy to audit.

Example base path:

```text
/api/v1/
```

### Health

```text
GET /api/v1/health
```

Reports whether the workstation service is reachable and ready to accept authenticated requests.

### Repository list

```text
GET /api/v1/repos
```

Returns repositories currently exposed to the interface.

The server, not the phone, controls which repositories are exposed.

### Repository overview

```text
GET /api/v1/repos/{repo_id}/overview
```

Returns a structured, read-only overview of repository state.

Candidate fields include:

- current branch;
- exact current commit;
- working-tree status;
- upstream/ahead/behind state where available;
- recent commits;
- relevant remote state when explicitly requested and available.

This is the **first substantive endpoint to implement**.

### Natural-language request

```text
POST /api/v1/voice/text
```

Example request:

```json
{
  "repo_id": "local-ai",
  "text": "What's going on with the repository?"
}
```

The workstation should:

1. authenticate the request;
2. interpret the requested observation;
3. produce a structured proposed operation;
4. validate that operation against deterministic Phase One policy;
5. perform only permitted read-only observations;
6. produce a grounded response;
7. write an audit event.

The endpoint name can change later if voice becomes one of several interaction surfaces.

### Recent audit events

```text
GET /api/v1/audit/recent
```

Returns recent audit events available to the authenticated user.

### Future action endpoints

Endpoints that plan or perform repository mutations are intentionally excluded from Phase One.

They should be designed only after the read-only interaction loop has been measured and after explicit authority and confirmation semantics are specified.

## Trust and authority model

The Android application is **not authoritative**. It is an interface.

The workstation owns:

- repository access;
- interpretation;
- authorization;
- policy;
- tool execution;
- model execution;
- audit state.

Git and the repository remain authoritative for repository state.

Models reason over state. Models are not state.

Consequential actions must preserve the project authority pattern:

```text
model proposes structured operation
  -> deterministic validation / authorization
  -> execution
  -> deterministic verification where practical
  -> report
```

Phase One only permits the observation subset of this pattern.

The workstation should obtain relevant repository state as close as practical to request time rather than relying on conversational memory.

## Authentication

Private-network membership should not automatically imply application authorization.

Phase One should therefore include application-level authentication between the Android client and workstation service.

The first implementation may be deliberately simple, provided that:

- unauthenticated requests are rejected;
- credentials are not committed to source control;
- secrets are stored using appropriate platform facilities;
- authentication failures are logged without logging secret material;
- the mechanism can later be replaced without redesigning repository APIs.

## Audit logging

Every meaningful request should produce a structured audit event.

At minimum, record:

- timestamp;
- client or session identity;
- original textual request or a privacy-preserving reference to it;
- interpreted intent;
- target repository;
- requested structured operation;
- policy decision;
- observations or tools invoked;
- success or failure;
- concise result metadata.

The audit trail serves two purposes:

1. make system behavior inspectable;
2. provide experimental evidence about real usage and failure modes.

Sensitive content should not be logged merely because it is available.

## Phase One boundaries and non-goals

Phase One is intentionally constrained to **explicit, user-initiated, read-only repository observation**.

Phase One does **not**:

- create or modify files;
- create commits;
- create branches;
- push repository changes;
- merge changes;
- create or modify pull requests;
- execute arbitrary model-generated shell commands;
- perform autonomous background repository work;
- continuously listen to the microphone;
- take repository actions without an explicit user request;
- silently use cloud inference or another cloud execution path.

These are Phase One experimental boundaries, not permanent limitations of the larger resident-AI architecture.

Later phases may expand authority only through explicit design and measurement.

## Failure behavior

The system should fail safely and explain failures conversationally.

### Workstation unreachable

The Android client reports that the workstation cannot currently be reached.

No alternative cloud execution path silently takes over.

### Repository unavailable

The service reports that the requested repository is unavailable rather than inventing or recalling repository state.

### GitHub unavailable

Operations that depend only on the local repository may continue.

GitHub-specific information should be reported as unavailable or incomplete.

### Ambiguous speech or intent

The system should request clarification when ambiguity could materially change the observation or target repository.

### Authentication failure

The request is rejected and recorded appropriately without exposing credential material.

### Tool or model failure

The system should distinguish among:

- state successfully observed;
- conclusions inferred from that state;
- information it could not obtain.

A partial failure must not become a confident fabricated answer.

## Development and experimental phases

These phases describe development of the interface itself. They do not replace or advance the repository's governing Elastic Resident AI experimental gates.

### Interface Phase 1: local read-only repository observation

Build the smallest reliable repository-observation service on the workstation.

Initial target:

```text
User:
"Give me repo status."

System:
Observes repository state and returns a concise report.
```

No repository mutation is possible through this interface.

### Interface Phase 2: expanded read-only intelligence

Expand the kinds of repository questions the service can answer.

Candidates include:

- recent changes;
- branch state;
- commit history;
- GitHub issues;
- pull requests;
- CI status;
- comparisons between branches.

This phase should also gather evidence about which observations users actually request.

### Interface Phase 3: Android voice I/O

Add the thin Android interaction surface and measure realistic speech-to-text and text-to-speech arrangements.

Do not assume that speech processing belongs permanently on either the phone or workstation.

### Interface Phase 4: remote operation

Validate the complete interaction loop through private remote connectivity while away from the local network.

Test realistic cellular latency, bandwidth variability, connection loss, Wi-Fi/cellular transitions, and workstation availability.

### Interface Phase 5: policy and audit hardening

Use evidence from the prototype to strengthen:

- authorization;
- policy enforcement;
- auditability;
- request confirmation semantics;
- error recovery;
- privacy boundaries.

### Later interface phases: governed actions

Only after the read-only system has proven useful should repository mutation be introduced.

A plausible governed progression is:

```text
Observe
   |
   v
Explain
   |
   v
Propose
   |
   v
Preview
   |
   v
Confirm
   |
   v
Execute
   |
   v
Verify
   |
   v
Report
```

The exact progression should be determined experimentally rather than assumed now.

## Initial prototype target

The smallest useful prototype does not require the entire architecture.

### Request

```text
"Give me repo status."
```

### Flow

```text
Android or simple test client
   |
   | authenticated text request
   v
FastAPI service
   |
   v
Authentication
   |
   v
Deterministic read-only policy
   |
   v
Repository observer
   |
   v
git status / related observations
   |
   v
Structured repository state
   |
   v
Response generation
   |
   v
Client
```

The request generates an audit entry.

No component exposed through the Phase One API is authorized to mutate the repository.

## Phase One success criteria

Phase One succeeds when a user can reliably request repository information conversationally and receive an accurate response without interacting directly with the workstation.

At minimum:

1. the client can securely reach the workstation in the tested mode;
2. the workstation can identify the requested repository;
3. repository state is observed at request time;
4. the response accurately reflects that observed state;
5. every meaningful request produces an appropriate audit event;
6. no request through the Phase One interface can mutate repository state;
7. failures produce useful explanations rather than fabricated answers;
8. local operation remains possible without outbound networking;
9. remote or GitHub-dependent functionality fails explicitly when its network dependency is unavailable.

## Open questions and measurements

The prototype exists to answer questions, not merely demonstrate that the architecture can be implemented.

### End-to-end latency

Measure time from the end of the user's spoken request to the beginning of a useful response.

Break this down where practical into:

```text
speech recognition
      +
network transport
      +
intent interpretation
      +
repository observation
      +
response generation
      +
speech synthesis
```

This identifies where optimization actually matters.

### Recognition and interpretation accuracy

Track failures caused by:

- incorrect speech recognition;
- incorrect intent interpretation;
- incorrect repository selection;
- incorrect observation/tool selection;
- incomplete repository observations.

Speech-recognition failures and reasoning failures should be measured separately.

### Repository accuracy

For repeatable test requests, compare the spoken or textual report against actual repository state.

Evaluate correctness, not merely whether responses sound plausible.

### Cellular network behavior

Test:

- normal cellular connections;
- weak connections;
- temporary connection loss;
- switching between Wi-Fi and cellular;
- reconnecting after interruption.

### Audio versus text transport

If both remain plausible, compare workstation-based speech recognition with on-device recognition.

Measure:

- end-to-end latency;
- bandwidth;
- recognition accuracy;
- phone battery impact;
- workstation load;
- implementation complexity;
- privacy characteristics;
- behavior under poor connectivity.

### Workstation interference

Because the workstation is shared with normal development and creative workloads, measure whether the service noticeably interferes with:

- programming;
- compilation and testing;
- game-engine work;
- 3D workloads;
- digital-art workloads;
- ordinary desktop use.

This interface experiment must coexist with the larger Elastic Resident AI resource frontier rather than treating the workstation as a dedicated server.

### Subjective utility

The most important measurement is whether the interface changes how useful the resident AI feels in real work.

Ask after realistic use:

- Did this avoid trips back to the workstation?
- Did it preserve a train of thought?
- Were responses fast enough to feel conversational?
- Was speaking easier than opening a traditional interface?
- Which questions did the user naturally begin asking once the capability existed?
- Which missing capability most often interrupted the interaction?

Those observations should guide the next interface phase.

## Experimental principle

The first version should optimize for **learning**, not architectural perfection.

Start with the most capable and responsive plausible implementation that can be assembled without weakening project contracts.

Measure behavior on the actual phone, cellular connection, workstation, repositories, and real workflows.

Then optimize, relocate components, or expand authority only when evidence demonstrates a reason to do so.

The first milestone remains deliberately small:

> Speak a repository question, receive an accurate answer from the workstation, and change nothing.
