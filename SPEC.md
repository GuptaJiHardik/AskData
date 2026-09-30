# AskData — Project Specification

**Status:** Proposed MVP specification; no implementation or benchmark is claimed.
**Source:** The resolved v1 contracts and delivery requirements in `askdata-impl-plan.md`.
**Scope:** A four-week, release-tested analytics copilot over the supplied Olist CSVs. Forecasting and automated reports are a later phase.

## 1. Purpose and users

AskData lets a marketplace manager or an explicitly entitled category manager ask approved business questions in plain English. Each supported answer must be accurate, explainable, and traceable to the query, policy, semantic, and dataset versions that produced it.

### User outcomes

- Ask about orders and revenue without writing SQL.
- Receive the approved gross-revenue answer or a clear `unsupported_metric` response when a requested metric, such as net revenue, cannot be defended from the source data.
- Inspect the answer, chart or table, exact SQL, parameters, metric definition, and provenance.
- Keep separate conversations and explicitly saved display preferences.
- Prevent users from viewing categories or sensitive columns outside their current access.

## 2. Scope and decisions

### MVP includes

- Reproducible Olist load, date shift, analytical model, and governed semantic layer.
- Authenticated Next.js chat and FastAPI API.
- LangGraph workflow with semantic retrieval, governed text-to-SQL, clarification, result grounding, and persistent chat state.
- Restricted PostgreSQL execution, Redis exact caches, durable requests, recovery, and append-only audit.
- Browser, correctness, security, accessibility, cost, and latency evaluation.

### Deferred

- Twelve-week category forecasts, anomaly detection and alerts, scheduled email reports, and a semantic editing UI.
- Net revenue until an authoritative refund, chargeback, tax, marketplace-fee, and cost ledger is governed and published under a new semantic version.
- Direct access to raw tables, arbitrary SQL, streaming ingestion, multi-tenant billing, and a mobile app.

### Resolved design decisions

| ID | Resolved design |
|---|---|
| D-01 | Gross revenue is `SUM(order_items.price)` at order-item grain for parent orders whose status is `delivered`. It excludes freight, taxes, discounts, vouchers, fees, and payment amounts. Net revenue is unsupported in v1 because Olist lacks the authoritative ledgers needed to calculate it defensibly. |
| D-02 | The business timezone is `America/Sao_Paulo` and the only reporting currency is BRL. Source timestamps are interpreted in business time, stored as UTC `TIMESTAMPTZ`, and converted to business time for grouping and display. The fixed date shift maps the maximum source purchase date to 2026-08-31 and sets `data_as_of` to 2026-09-01 00:00:00 in the business timezone. |
| D-03 | Approved categories are normalized translated keys with at least one mapped product. A marketplace manager may access all approved categories. A category manager requires a non-empty explicit list and may access only its intersection with the published allowlist—never wildcards, parent expansion, marketplace totals, hidden-category denominators, or cross-category comparisons. The LLM never authorizes access. |
| D-04 | Authentication uses Auth0 Universal Login with OIDC Authorization Code Flow and PKCE (`S256`), scopes `openid profile email`, and no MVP refresh token. Application sessions have an eight-hour idle and 24-hour absolute lifetime and are immediately revocable. Callback, logout-return, forwarding, and retention policies are fixed below. |
| D-05 | Model calls use the OpenAI Responses API with strict Structured Outputs. The LLM is pinned to `gpt-5.4-mini-2026-03-17`; embeddings use `text-embedding-3-small` at 1,536 dimensions with cosine distance. There is no automatic fallback model. |

Changing a resolved contract requires a semantic or policy version bump, regenerated scoped views and retrieval documents, and a complete evaluation run. The semantic registry must publish these decisions with the five reconciliation results, fixed time/currency policy, approved-category list, access policy, metric definitions, and model/index versions. Undefined meaning outside these definitions results in clarification, refusal, or `unsupported_metric`; the system does not invent a formula.

## 3. Data and semantic contract

| ID | Requirement | Verification |
|---|---|---|
| DATA-01 | Preserve original Olist CSVs and record checksums, row counts, source dates, code version, and license caveat. | Dataset manifest matches inputs. |
| DATA-02 | Derive one whole-day offset that maps the maximum source purchase date to 2026-08-31 and apply it exactly once to every business timestamp. Never derive the offset from wall-clock time. | Repeated loads yield identical shifted data, offset, and version. |
| DATA-03 | Interpret source timestamps in `America/Sao_Paulo`, store them as UTC `TIMESTAMPTZ`, and validate keys, references, category mapping, timestamps, non-negative prices, and exact decimal money values. | Loader checks pass; money is serialized without floating-point rounding. |
| DATA-04 | Publish a new dataset version only after validation and five independent gates reconcile: all-time delivered gross revenue; monthly totals to that total; category totals to the approved-category total; distinct-order counts without item/payment fan-out; and `SUM(price + freight_value)` against order-level payments to BRL 0.01. Any unexplained variance blocks publication. | Reconciliation results are stored in the dataset manifest; failed publication leaves the prior version available. |
| DATA-05 | Model order, order-item, payment aggregate, product, category, and date grains. | Tests catch join fan-out and incorrect distinct-order counts. |
| DATA-06 | Set `data_as_of` to 2026-09-01 00:00:00 `America/Sao_Paulo`. Resolve relative dates against it with local calendar boundaries and persist UTC half-open intervals; never use wall-clock time. Serialize money as `NUMERIC(12,2)` in BRL and return `currency: "BRL"` in answer metadata. | Frozen-date tests cover `last month` = `[2026-08-01, 2026-09-01)`, `yesterday` = `[2026-08-31, 2026-09-01)`, and `last N days` ending at `data_as_of`. |
| SEM-01 | Version approved metrics, dimensions, join paths, units, precision, status rules, and scope policies in YAML. | Invalid definitions fail publication. |
| SEM-02 | Publish semantic views, SQL allowlist, retrieval documents, and one active version manifest together. | API refuses readiness on version mismatch. |
| SEM-03 | Exclude raw rows, raw free text, and prohibited identifiers or location fields from retrieval documents and chat results. `order_id` may be used internally only for approved aggregates such as `COUNT(DISTINCT ...)`; it cannot be projected. | Corpus inspection, projection-denial, and scope-filter tests pass. |
| SEM-04 | Publish only normalized category keys backed by the source translation table and at least one mapped product. Exclude null, blank, unmapped, and `unknown` categories until explicitly approved in `semantic/categories.yaml`. | Category manifest, scoped views, retrieval filters, policy rewriting, and authorization tests agree. |
| SEM-05 | Define `gross_revenue` as the sum of item prices for delivered orders, with item grain, BRL unit, two-decimal display precision, and freight excluded. Financial metrics must not treat any non-delivered status as revenue. | Semantic metric cards and reference queries use the identical formula and status policy. |
| SEM-06 | Publish `net_revenue` as unsupported in v1. A net-revenue request returns `unsupported_metric` with the missing-source-data explanation and executes no invented formula. | Unsupported-metric tests execute no analytical SQL. |

The prohibited exposure set includes customer, seller, order, product, review, identity-provider, session, and token identifiers; customer/seller ZIP, city, state, latitude, and longitude; review title/body; email; OIDC subject; cookies; CSRF values; and raw free text. The Olist dataset is for a non-commercial demonstration; its precise license terms must be confirmed before client-facing reuse. The date shift must be disclosed with original and shifted ranges.

## 4. Identity and access

| ID | Requirement | Verification |
|---|---|---|
| AUTH-01 | Use Auth0 Universal Login with OIDC Authorization Code Flow, PKCE (`S256`), state, and nonce. Request only `openid profile email`, request no `offline_access`, store no refresh token, and validate issuer, audience, signature, expiry, nonce, and state before binding the identity to an active local user. | Invalid claim/flow, expired session, and logout tests pass. |
| AUTH-02 | Store only a hash of the opaque application-session token in PostgreSQL. Use a Secure, HttpOnly, SameSite cookie and protect mutations with Origin and CSRF checks. | Cookie, token-storage, and CSRF tests pass. |
| AUTH-03 | Derive role and category scope on the server; reload current entitlements for every request, including history, results, cache hits, and resumed work. Revocation takes effect immediately on logout or entitlement removal. | Revocation immediately removes access. |
| AUTH-04 | Check ownership of every chat, request, clarification, result, checkpoint, and memory item. | Guessed cross-user IDs reveal nothing. |
| AUTH-05 | Query logins have SELECT access only to matching governed views; they cannot read raw, app, audit, or other scopes. | Direct database bypass tests fail. |
| AUTH-06 | Allow only `https://localhost/auth/callback` in development and `https://<production-host>/auth/callback` in production. Allow the corresponding `/login` logout returns. Post-login forwarding is limited to `/chat` and `/chat/<owned-session-uuid>`; absolute and protocol-relative `return_to` values are rejected. | Exact callback/logout allowlists and open-redirect tests pass. |
| AUTH-07 | Enforce an eight-hour idle and 24-hour absolute application-session timeout. Retain expired auth-session rows for 30 days. | Idle, absolute-expiry, immediate-revocation, and retention tests pass. |

## 5. Question and answer workflow

| ID | Requirement | Verification |
|---|---|---|
| QA-01 | Resolve metric, dimensions, filters, and absolute UTC half-open date boundaries from the question and approved same-chat context. Relative dates use the active dataset's `data_as_of` and `America/Sao_Paulo`, never wall-clock time. | Fixed-anchor relative-date and follow-up cases pass. |
| QA-02 | Ask one focused clarifying question when required metric meaning, scope, date range, or an ambiguous fiscal period is unresolved. Return `unsupported_metric` instead of clarification when the requested metric is explicitly unsupported. | Ambiguous cases do not execute SQL; unsupported cases do not invent formulas. |
| QA-03 | Retrieve only current-version, scope-approved metric, dimension, join, policy, and curated example documents; add mandatory contracts regardless of vector rank. | Retrieval IDs, versions, scope, and mandatory contracts are audited. |
| QA-04 | Generate structured SQL from approved context. Treat user and retrieved text as untrusted data. | Prompt-injection cases cannot bypass policy. |
| QA-05 | Parse the full candidate with SQLGlot; accept only approved SELECT/CTE shapes, relations, columns, joins, functions, and a bounded LIMIT. | AST adversarial suite passes. |
| QA-06 | Apply category policy at each relevant relation, use bound parameters, then reparse and validate the final SQL. | Nested-query and policy-bypass cases pass. |
| QA-07 | Run only a validated query through a read-only PostgreSQL login with an eight-second statement timeout. | Write, raw-table, and cross-scope attempts execute zero SQL. |
| QA-08 | Allow at most one initial SQL candidate plus two corrections for recoverable mistakes; forbidden access is terminal. | Attempt count never exceeds three. |
| QA-09 | Check returned types, nulls, plausibility, date/category scope, and empty results. Do not widen scope to obtain rows. | Empty results become `no_data`. |
| QA-10 | Ground every narrative number in typed result cells; use a deterministic factual template if grounding fails. | No delivered numerical claim lacks a source cell. |
| QA-11 | Select line, bar, KPI, or table from approved result shape; preserve an exact-value table if chart rendering fails. | Chart fields match returned columns. |
| QA-12 | Show final executed SQL and parameters, metric meaning, resolved period, `data_as_of`, `currency: "BRL"`, and dataset/semantic/policy/model versions. | Every answer can be traced to a result snapshot. |

## 6. Chat, API, and memory

| ID | Requirement | Verification |
|---|---|---|
| CHAT-01 | Support multiple owned chats with persistent, paginated history. Use one PostgreSQL LangGraph checkpoint thread per chat. | Chats remain independent after refresh and restart. |
| CHAT-02 | Keep recent context bounded; summaries may help wording but cannot authorize access or define metrics. | Long-chat and revocation tests pass. |
| CHAT-03 | Store only explicitly approved, non-sensitive cross-chat preferences in a user-namespaced PostgreSQL store. | Other users and chats cannot read transient context. |
| CHAT-04 | Let users list and delete saved memories. Cross-chat preferences remain until user deletion or 365 days of inactivity; no other memory kind may exceed its applicable retention policy. | Deleted or expired items do not reappear. |
| API-01 | Expose auth, current-user, chat, request, memory, and health endpoints under `/api/v1`. | OpenAPI and generated TypeScript contracts agree. |
| API-02 | Persist an uncached request before returning `202`; poll by owned request ID. A durable audited response-cache hit may return `200`. | Refresh and disconnect do not duplicate work. |
| API-03 | Require an idempotency key for submission; identical retries return the same request, conflicting payloads return `409`. | Duplicate-click and uncertain-POST tests pass. |
| API-04 | Return safe terminal states: `answered`, `needs_clarification`, `no_data`, `refused`, or `failed`. Use a safe `unsupported_metric` reason/response for explicitly unsupported metrics without adding an unhandled UI state. | UI renders each state and the unsupported-metric response without internal errors. |
| UI-01 | Provide accessible login, chat list, composer, status, clarification, answer, SQL, provenance, and memory controls. | Keyboard, contrast, responsive, and browser tests pass. |

## 7. Cache, audit, and recovery

| ID | Requirement | Verification |
|---|---|---|
| OPS-01 | Key complete-response cache by exact question, structured context, actual scope, time anchor, and data/semantic/policy/model versions. | A revoked or changed scope cannot read a prior hit. |
| OPS-02 | Key SQL-result cache by validated final SQL, bound values, scope, and versions. Treat Redis as disposable. | Redis outage cannot change correctness. |
| OPS-03 | Audit every accepted request, SQL attempt, cache hit, LLM call/cost, result snapshot, and terminal outcome. | Delivered answers have durable audit records. |
| OPS-04 | Use durable request IDs, worker claims, and checkpoint reconciliation for restart recovery. | One logical request has one visible terminal outcome. |
| OPS-05 | Queue supported outages only after identity/ownership and durable acceptance are verified; otherwise return `503`. | Outage tests prove no false acceptance. |
| OPS-06 | Record safe structured logs and versioned cost estimates; exclude secrets and sensitive rows. | Logs and cost report pass inspection. |
| OPS-07 | Retain chat sessions, messages, and requests for 90 days after last activity; result snapshots for 30 days; audit events and query-attempt metadata for 365 days; successfully replayed recovery-journal records for seven days; and Redis entries for at most one hour. Never retain raw prompts, model reasoning, provider tokens, cookies, or unrestricted result rows. | Daily retention tests verify deletion windows and audit only deletion counts, not deleted content. |

## 8. Model and retrieval contract

| ID | Requirement | Verification |
|---|---|---|
| AI-01 | Use the OpenAI Responses API with strict Structured Outputs rather than JSON mode for intent and SQL schemas. Use low reasoning effort for intent and SQL generation and none for grounded composition. | Schema-conformance, refusal, and malformed-output tests pass. |
| AI-02 | Pin `gpt-5.4-mini-2026-03-17`. Record model and prompt versions on every call and in cache/provenance material. The pinned model supports Responses and Structured Outputs; its documented token prices are $0.75 per million input tokens and $4.50 per million output tokens. | Configuration rejects an unqualified alias or silent model substitution. |
| AI-03 | Use `text-embedding-3-small` with 1,536 dimensions and cosine distance. Store the model name and dimension in the index manifest; the documented input price is $0.02 per million tokens. | Index publication rejects a model/dimension/version mismatch. |
| AI-04 | Limit each question to 20,000 input tokens and 3,000 output/reasoning tokens across model calls, plus embedding input. Stop with a safe error before exceeding the budget. | Worst-case model-token spend is capped at approximately $0.0285 before the embedding charge. |
| AI-05 | Permit no automatic fallback model. A model alias or version change requires a new baseline of the exact model, prompts, semantic version, and embedding index against the complete qualification suite. | Failover and version-change tests cannot bypass qualification. |

The OpenAI-specific capabilities and prices above are pinned project inputs backed by the official [GPT-5.4 Mini model page](https://developers.openai.com/api/docs/models/gpt-5.4-mini), [Structured Outputs guide](https://developers.openai.com/api/docs/guides/structured-outputs), [text-embedding-3-small model page](https://developers.openai.com/api/docs/models/text-embedding-3-small), and [embeddings guide](https://developers.openai.com/api/docs/guides/embeddings). Reconfirm pricing before budgeting a deployment; a price-only change updates the cost sheet, while a model or behavioral contract change requires requalification.

## 9. Release gates

Qualification uses exactly 190 cases: 100 golden, 30 ambiguous, 30 adversarial, and 30 PII-focused cases. The pinned model, prompts, semantic version, policy version, dataset version, and embedding index are recorded with the run.

| Gate | Target | Evidence |
|---|---|---|
| Accuracy | At least 80% correct values on 100 independently reviewed golden questions. | Versioned evaluation report |
| Clarification | At least 80% appropriate clarification on 30 ambiguous questions. | Evaluation report |
| Security | Zero unauthorized-data disclosures, zero prohibited PII disclosures, and zero executed writes across 30 adversarial and 30 PII-focused cases. | Evaluation and database-grant tests |
| Grounding | Every delivered number maps to an authorized result value. | Grounding checks and result snapshots |
| Latency | Browser-visible p95 below 10 seconds uncached and below one second for complete-response hits. | Measured cohort report |
| Cost | Mean total cost below $0.03 per question. | Provider usage plus compute allocation |
| Reliability | Idempotency, crash/restart, cache, database, and audit-outage paths pass. | Recovery suite and audit trail |
| Usability | Real browser flow passes login, ask, clarify, answer, inspect SQL, switch chats, manage memory, and logout. | Browser suite |

The release decision uses measured results on a documented deployment profile. If a gate fails, the MVP remains incomplete until fixed and rechecked.
