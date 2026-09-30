# AskData — Codex Session Handoff

**Last updated:** 2026-09-30
**Project status:** P0 foundation implementation in progress; application implementation has not started.
**Active implementation phase:** P0 — Repository and Project Foundation
**Phase status:** In progress.

## Purpose

This file is the compact, living handoff for new Codex sessions. It records what has actually happened, the current implementation phase, the actionable plan for that phase, and the evidence required to move forward. It does not replace the full specification or roadmap.

## Sources of truth

Use these sources in this order when they address different concerns:

1. The working repository is the truth for what exists and what passes.
2. `SPEC.md` defines the approved product, data, security, model, and release contracts.
3. `askdata-impl-plan.md` defines phase ordering, dependencies, detailed implementation requirements, and acceptance criteria.
4. This file summarizes current state and the active phase for fast session startup.

If the files disagree, do not silently choose one. Inspect the repository, preserve the approved contracts in `SPEC.md`, reconcile the plan and this file in the same change, and record the decision below.

## Session startup procedure

1. Read this file before substantive project work.
2. Read only the parts of `SPEC.md` relevant to the requested work.
3. Read the active phase in `askdata-impl-plan.md`; consult other phases only for dependencies or explicit cross-phase questions.
4. Inspect the current filesystem and verification evidence. Never assume a checklist item is complete because it is documented here.
5. Continue only the active phase unless the user explicitly requests a documentation-only change or approves advancement after the active phase passes.

## Current state

### Completed project work

- Reconciled `SPEC.md` with the resolved v1 contracts in `askdata-impl-plan.md`.
- The aligned contracts include delivered-order gross revenue, unsupported net revenue, BRL and `America/Sao_Paulo`, the fixed 2026-08-31 date-shift target, the 2026-09-01 `data_as_of`, category entitlements, prohibited data exposure, Auth0/session/retention rules, pinned OpenAI model and embeddings, token budget, and the 190-case release suite.
- Added this living handoff and the root `AGENTS.md` instruction entry point.

### Implementation baseline

| Item | Current evidence |
|---|---|
| Application code | None |
| Active phase | P0 — Repository and Project Foundation |
| Phase status | In progress |
| Implemented phase paths | `pyproject.toml`, `.gitignore`, `README.md`, `Makefile` |
| Phase verification | Python 3.12.14, uv 0.12.9, Git 2.53.0.windows.2, GNU Make 4.4.1 verified; `uv sync --extra dev`, `make lint`, `make typecheck`, `make test`, ignore probes, and staged `git diff --check` passed. Root commit `fce3de2` created; remote push pending. |
| Repository metadata | Git `main`, root commit `fce3de2`, verification commit `15cc772`; `origin` is `https://github.com/GuptaJiHardik/AskData.git`; remote `main` absent on read-only check |
| Available tools | Git `2.53.0.windows.2`; `uv 0.12.9`; managed Python 3.12.14; GNU Make 4.4.1 (refresh PATH in shells launched before installation) |
| Local data | Nine supplied Olist CSVs under `data/`; preserve locally and exclude from Git |
| Existing project documents | `SPEC.md`, `askdata-impl-plan.md`, `AGENTS.md`, `codex.md` |

Documentation and agent-governance files are not evidence that Phase 0 implementation has begun.

## Active phase plan — P0 Repository and Project Foundation

### Objective and boundaries

Establish the minimal Python project, repository metadata, and quality toolchain needed for controlled development. Do not create application packages, frontend code, infrastructure, CI jobs, migrations, runtime configuration, tests, or placeholders for later phases.

Phase 0 adds exactly four tracked project files: `pyproject.toml`, `.gitignore`, `README.md`, and `Makefile`. The existing `AGENTS.md`, `SPEC.md`, `askdata-impl-plan.md`, and `codex.md` remain project documentation rather than Phase 0 implementation scaffolding.

The nine supplied Olist CSVs under `data/` remain untouched local inputs and are not included in Git. Phase 2 will introduce any required data manifest or acquisition workflow.

### Verified baseline and prerequisites

The latest read-only inspection found:

- Git `2.53.0.windows.2` and `uv 0.12.9` are available.
- No Git repository or remote exists in `Z:\AskData`.
- No installed Python runtime is available through `python` or the Python launcher.
- GNU Make is not installed or available on `PATH`.
- Global Git author configuration is present.

When the user authorizes Phase 0 implementation:

1. Install managed Python 3.12 with `uv python install 3.12` and verify it with `uv run python --version`.
2. Install GNU Make with `winget install --id GnuWin32.Make --exact` and verify it with `make --version`.
3. Re-verify `uv --version` and `git --version`.
4. Initialize the repository on `main` with `git init -b main`.

Do not mark a prerequisite satisfied without recording its command output.

### Phase 0 files and interfaces

- `pyproject.toml` — define project `askdata` version `0.1.0`, Python `>=3.12`, no runtime dependencies, development dependencies `pytest`, `ruff`, and `mypy`, and Ruff line length 100.
- `.gitignore` — ignore `.env` and local variants while allowing a future `.env.example`; ignore virtual environments, Python bytecode and tool caches, coverage and generated reports, frontend build artifacts, `/data/`, and the Phase 0-generated `/uv.lock`.
- `README.md` — provide one concise purpose paragraph, identify P0 as active, link to `askdata-impl-plan.md` and this handoff, and document setup plus the three quality commands.
- `Makefile` — expose only `lint`, `typecheck`, and `test`.
  - `lint` runs `uv run ruff check .`.
  - `typecheck` runs Mypy against `.` and converts only Mypy's specific no-Python-files result to success; any other Mypy result remains authoritative.
  - `test` runs Pytest and converts only `NO_TESTS_COLLECTED` to success; collection errors and test failures remain failures.

The adapted `typecheck` and `test` recipes preserve the four-file boundary while the repository contains no Python source or tests. Record this as an approved P0 deviation from the literal roadmap recipes. Replace the adaptations with ordinary repository-wide commands when a later authorized phase adds Python sources and tests.

`uv sync --extra dev` may generate `.venv` and `uv.lock`, but both remain ignored and untracked in P0 so the four-file tracked-project boundary is preserved.

### Execution sequence

1. Verify and prepare the prerequisites above, then initialize Git on `main`.
2. Create the four Phase 0 project files without future-facing stubs or runtime dependencies.
3. After each implementation patch, synchronize the status, actual paths, decisions, deviations, and evidence in `askdata-impl-plan.md` and this file.
4. Run `uv sync --extra dev`, followed by `make lint`, `make typecheck`, and `make test`.
5. Verify ignore behavior with `git check-ignore -v` probes for `.env.local`, `.venv`, Python/tool caches, generated reports, frontend artifacts, `uv.lock`, and an existing `data/*.csv`.
6. Inspect the repository inventory and `git status --short --ignored`; confirm no later-phase paths exist and all generated/local artifacts are ignored.
7. Record the exact commands and exit results in both living ledgers.
8. Stage explicit paths only: the four P0 project files and the existing project/governance documents. Do not use broad staging that could capture the CSV inputs.
9. Create the initial commit on `main`.
10. Obtain the user-supplied remote URL and explicit push authorization, configure `origin`, run `git push -u origin main`, and verify the remote branch and a clean working tree.

### Acceptance checklist

- [x] Managed Python 3.12, `uv`, Git, and GNU Make are available and their versions are recorded.
- [x] Git is initialized on `main`.
- [x] Only the four Phase 0 project files are added; no later-phase directories or empty stubs are created.
- [x] `uv sync --extra dev` completes successfully.
- [x] `make lint` passes.
- [x] `make typecheck` passes, accepting only the expected no-Python-files condition while the project is empty.
- [x] `make test` passes, accepting only Pytest's expected no-tests-collected condition while the project is empty.
- [x] `.gitignore` covers `.env.local`, `.venv`, caches, reports, frontend artifacts, `uv.lock`, and `/data/`.
- [x] The supplied CSV files remain untouched and untracked.
- [x] `README.md` identifies Phase 0 as active and points to the living plan and handoff.
- [x] `askdata-impl-plan.md` and this file record actual paths, approved deviations, and exact verification results.
- [x] The initial commit contains only the intended project and governance files.
- [ ] The user-confirmed Git remote is configured and the initial commit is pushed. `origin` is configured; explicit push authorization and push verification remain.

Do not mark P0 complete until every item passes. If the remote URL or push authorization is still absent, leave P0 in progress and record the exact blocker. Do not start P1 until P0 is complete and the user explicitly asks to continue.

## Progress history

| Date | Phase | Change | Paths | Verification |
|---|---|---|---|---|
| 2026-09-29 | Pre-implementation | Synchronized the specification with the resolved implementation-plan contracts | `SPEC.md` | Contract-term consistency check passed; documentation-only change |
| 2026-09-29 | Pre-implementation | Added persistent Codex session guidance and active-phase tracking | `AGENTS.md`, `codex.md` | Session handoff validation passed; required sources, P0 plan, commands, checklist, update protocol, and decision log are present |
| 2026-09-29 | P0 planning | Refined the active-phase snapshot with the verified tool baseline, strict four-file boundary, empty-project quality-gate behavior, local-data policy, and remote completion checkpoint | `codex.md` | PowerShell required-marker validation passed: all 9 Phase 0 plan markers present |
| 2026-09-30 | P0 | Installed managed Python, initialized Git on `main`, and created the four P0 project files | `pyproject.toml`, `.gitignore`, `README.md`, `Makefile`, `.git/` | `uv python install 3.12`: exit 0, installed 3.12.14; `git init -b main`: exit 0; `uv --version`: 0.12.9; `git --version`: 2.53.0.windows.2. `uv run python --version` blocked by user-cache access in the sandbox; retry with approved elevation pending. |
| 2026-09-30 | P0 | Installed GNU Make from `ezwinports.make`, synced dependencies under Python 3.12, and corrected the empty-project Mypy match | `Makefile` | `winget install --id GnuWin32.Make --exact`: failed, SourceForge timeout; `winget install --id ezwinports.make --exact --accept-package-agreements --accept-source-agreements`: exit 0; `make --version`: GNU Make 4.4.1; `uv run --python 3.12 python --version`: 3.12.14; `uv sync --extra dev --python 3.12`: exit 0; `make lint`: passed; `make test`: passed, zero tests; first `make typecheck`: exit 2 because Mypy omitted the assumed `mypy: error:` prefix. Corrected recipe; rerun pending. |
| 2026-09-30 | P0 | Verified the corrected P0 foundation and ignore boundary | `pyproject.toml`, `.gitignore`, `README.md`, `Makefile`, `askdata-impl-plan.md`, `codex.md` | `uv run python --version`: Python 3.12.14; `uv sync --extra dev`: exit 0; `make lint`: exit 0, all checks passed; `make typecheck`: exit 0, only exact `There are no .py[i] files in directory '.'` message accepted; `make test`: exit 0, zero collected, Pytest exit 5 accepted; `git check-ignore -v` probes: exit 0 for `.env.local`, `.venv`, Python/tool caches, generated reports, frontend artifacts, `uv.lock`, and existing `data/olist_customers_dataset.csv`; `git check-ignore -q .env.example`: exit 1 (not ignored); `git status --short --ignored`: eight intended files untracked, `.pytest_cache/`, `.ruff_cache/`, `.venv/`, `data/`, and `uv.lock` ignored; nine CSVs present; `git diff --check`: exit 0. |
| 2026-09-30 | P0 | Created and inspected the initial commit | `.git/`, eight intended tracked files | `git diff --cached --check`: exit 0 after removing whitespace from governance files; `git diff --cached --name-only`: exactly `.gitignore`, `AGENTS.md`, `Makefile`, `README.md`, `SPEC.md`, `askdata-impl-plan.md`, `codex.md`, `pyproject.toml`; `git commit -m "Initialize P0 repository foundation"`: exit 0, root commit `fce3de2`; `git show --format=fuller --stat --oneline HEAD`: eight files, no CSV or generated artifacts; `git status --short --ignored`: only `.pytest_cache/`, `.ruff_cache/`, `.venv/`, `data/`, and `uv.lock` ignored. |
| 2026-09-30 | P0 | Configured the user-supplied GitHub remote and inspected its `main` branch | `.git/config`, `askdata-impl-plan.md`, `codex.md` | `git remote add origin https://github.com/GuptaJiHardik/AskData.git`: exit 0; `git remote -v`: fetch and push URL both match; `git ls-remote --heads origin main`: exit 0 with no branch; `git status --short --branch`: `## main` with clean tree before these ledger updates. |

## Update protocol

After every implementation change, update this file in the same task:

1. Set the active phase status to `Not started`, `In progress`, `Blocked`, or `Complete` based on evidence.
2. Update the implementation baseline with the exact paths created or changed.
3. Check acceptance items only after their verification succeeds.
4. Record exact commands and concise results in the progress history.
5. Record material decisions, deviations, blockers, and user approvals in the decision log.
6. Synchronize the living progress record in `askdata-impl-plan.md`.
7. When a phase is complete and the user asks to continue, preserve its history, change the active phase, and replace the active-phase plan above with the next phase's objective, prerequisites, files, sequence, and acceptance checklist from `askdata-impl-plan.md`.

## Decision and blocker log

| Date | Phase | Type | Record |
|---|---|---|---|
| 2026-09-29 | Pre-implementation | Decision | Use `AGENTS.md` as the automatically discovered Codex instruction file and `codex.md` as the detailed living session handoff. |
| 2026-09-29 | P0 | Blocker | Git repository and remote are not currently present or verified. This does not block documentation work, but P0 cannot pass until Git is initialized, a remote is confirmed, and the initial commit is pushed. |
| 2026-09-29 | P0 | Decision | Preserve the four-file P0 project boundary; adapt the Make recipes so only Mypy's no-Python-files result and Pytest's no-tests-collected result are accepted while the repository is empty. |
| 2026-09-29 | P0 | Decision | Install GNU Make for the mandated Make targets and install a managed Python 3.12 runtime through `uv`. |
| 2026-09-29 | P0 | Decision | Keep the supplied `data/` CSV files untouched and untracked; ignore generated `.venv` and `uv.lock` during P0. |
| 2026-09-29 | P0 | Decision | The user will supply the Git remote URL; request explicit authorization immediately before the external push. |
| 2026-09-30 | P0 | Decision | Created only the four P0 project files. The Make recipes contain temporary empty-project handling for Mypy's exact no-source message and Pytest's exit 5; replace them when a later authorized phase adds code and tests. |
| 2026-09-30 | P0 | Decision | `GnuWin32.Make` download timed out, so installed GNU Make 4.4.1 from winget package `ezwinports.make`. User PATH was refreshed for verification. |
| 2026-09-30 | P0 | Blocker | Initial commit remains to be created. The Git remote URL and explicit push authorization have been requested; P0 remains in progress until the commit is pushed and verified. |
| 2026-09-30 | P0 | Decision | Root commit `fce3de2` contains only the eight intended files. A follow-up documentation commit records its verified result; both commits require a remote push before P0 completion. |
| 2026-09-30 | P0 | Blocker | The user supplied `https://github.com/GuptaJiHardik/AskData` and it is configured as `origin`. Explicit authorization to push was requested separately, as required by this P0 snapshot; do not push until received. |
