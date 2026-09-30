# AskData

AskData is a governed natural-language analytics application for the Olist commerce dataset. Phase 0 establishes the repository and Python quality toolchain; application implementation begins in later phases.

**Active phase:** P0 — Repository and Project Foundation. See the [implementation plan](askdata-impl-plan.md) and [session handoff](codex.md) for scope and progress.

## Setup

Install Python 3.12, `uv`, and GNU Make, then run `uv sync --extra dev`.

## Quality checks

```sh
make lint
make typecheck
make test
```
