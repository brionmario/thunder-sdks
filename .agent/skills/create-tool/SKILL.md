---
name: create-tool
description: Scaffold and implement a new ThunderID SDK or integration package. Use when adding support for a new language, framework, or platform (e.g. Angular SDK, Go SDK, Auth.js integration), or when setting up the CI, sample app, and docs stubs for an existing SDK entry.
allowed-tools: Bash(*) Read(*) Edit(*) Write(*)
---

# ThunderID SDK / Integration Creator

You are helping implement a new ThunderID SDK or integration package.

**Before doing anything else, read the full specification:**

```
https://github.com/brionmario/thunder-sdks/blob/21c1b94/docs/content/community/contributing/contributing-code/tooling-development/sdk-specification/README.md
```

The spec is the authoritative source for all requirements. Everything in this skill is a process guide that points you to spec sections — when there is any ambiguity, the spec wins.

---

## Step 0 — Verify the working directory

Before writing any code, confirm you are working inside the ThunderID monorepo.

Run:

```bash
ls tools backend frontend 2>/dev/null | head -1 && echo "OK: in monorepo" || echo "NOT in monorepo"
```

- **If the check passes** (all three directories are present): proceed.
- **If the check fails:** ask the user:
  > This skill needs to run inside the ThunderID monorepo (`asgardeo/thunder`). You have two options:
  > 1. **Clone it:** `git clone https://github.com/asgardeo/thunder.git` then re-run this skill from that directory.
  > 2. **Point me to your local copy:** provide the absolute path to your existing clone and I will `cd` there first.

Do not proceed until the working directory is confirmed to be the monorepo root.

---

## Step 1 — SDK or Integration?

Before writing any code, determine whether you are building an **SDK** or an **Integration**. Read spec §2.7 for the full definition. The key question:

> Does the target ecosystem already have a well-established auth abstraction that developers use directly (e.g., Auth.js providers, Passport strategies, Backstage auth plugins)?

| If… | Build… | Lives under |
| --- | ------ | ----------- |
| You are implementing the ThunderID ThunderIDClient for a new language, platform, or framework | **SDK** | `tools/sdks/` |
| You are adapting ThunderID into a third-party auth framework's provider/strategy/plugin interface | **Integration** | `tools/integrations/` |

If building an **Integration**, skip to the [Integration workflow](#integration-workflow) below.

---

## SDK Workflow

### Step 2 — Identify the SDK

Ask the user (or infer from context) before writing any code:

- **SDK name** — must match an entry in the spec §15.1 SDK list. SDK directory names are short, platform-specific identifiers with **no product prefix**:
  - ✅ `ios`, `android`, `react`, `browser`, `flutter`, `go`
  - ❌ `thunderid-ios`, `thunderid-android`, `thunder-react`
- **Layer** — Agnostic | Platform | Core Lib | Framework Specific (spec §2.2)
- **Parent SDK** — the immediate layer below; no layer may skip its parent (spec §2.6)
- **Ecosystem** — JavaScript, Python, Swift, Kotlin, Dart, Go, etc.

The product prefix (`@thunderid/`, `io.thunderid.*`, `ThunderID`, etc.) applies only to the **published package name** (spec §15.2), never to the directory name.

Cross-check the layer assignment against the worked example diagram in spec §2.4 and the ecosystem table in spec §2.5.

---

### Step 3 — Generate a plan and confirm

Before creating any files or directories, output a complete plan using the following format and **stop for user confirmation**. Do not write any code until the user explicitly approves.

```
## Plan: <sdk-name> SDK

**Layer:** <layer>
**Parent SDK:** <parent>
**Published package name:** <name per spec §15.2>

### Files to create
- [ ] tools/sdks/<sdk-name>/                     — SDK source root
- [ ] tools/sdks/<sdk-name>/README.md
- [ ] tools/sdks/<sdk-name>/<build-config>        — e.g. package.json, build.gradle, Package.swift
- [ ] .github/actions/<sdk-name>-sdk/action.yml  — composite CI action
- [ ] samples/apps/<sdk>-<scenario>/              — sample app
- [ ] samples/apps/<sdk>-<scenario>/.env.example
- [ ] samples/apps/<sdk>-<scenario>/README.md
- [ ] docs/content/guides/quick-start/<sdk-name>/index.md
- [ ] docs/content/sdks/<sdk-name>/overview.md
- [ ] <any additional files specific to this SDK>

### CI changes
- [ ] Add job to .github/workflows/pr-builder.yml

### Out of scope for this PR
- <list anything deferred, e.g. full IAMClient implementation, UI components>
```

After presenting the plan, ask:

> Does this plan look right? Any changes before I start? (Reply **yes** to proceed, or tell me what to adjust.)

If the user requests changes, revise the plan and ask again. Only begin implementing once the user confirms.

---

### Step 4 — Scaffold the directory structure

Read spec §15.0 for the canonical layout. The SDK source lives flat at:

```
tools/sdks/<sdk-name>/           # publishable SDK library source (no code/ subdirectory)
.github/actions/<sdk-name>-sdk/  # composite CI action (spec §15.4)
```

Run `ls tools/sdks/` first to confirm the name is consistent with existing SDKs.

---

### Step 3 — Implement

Work through the spec in order. For each area below, **re-read the referenced section** before implementing — do not rely on memory or the summaries here.

| Area | Spec section | Key requirement |
|------|-------------|-----------------|
| Package naming | §15.2 | Follow ecosystem convention (`@thunderid/*`, `io.thunderid.*`, etc.) |
| Layer contract | §2.2, §2.6 | Implement only this layer's responsibility; never re-implement parent logic |
| Initialization | §5.1 | Validate config at init; throw `SDKNotInitializedException` before init |
| Configuration schema | §5.2 | All required + applicable optional fields; reject HTTP `baseUrl` |
| Preferences (UI SDKs) | §5.3 | `theme` + `i18n` sub-objects |
| Operational modes | §4 | Both redirect and app-native; mode inferred from config, not declared |
| PKCE | §11.2 | Mandatory in redirect mode; `S256` only; `code_verifier` in memory only |
| `ThunderIDClient` interface | §7.1 | All methods; `signIn()`/`signUp()` overloaded for both modes |
| Identity lifecycle ops | §6 | Auth, registration, recovery, session, token, profile, org management *(org not yet implemented)* |
| Framework integration | §7.2, §7.3 | Single entry point (hook/service/composable); init at app root |
| UI components | §8 | All four categories; `Base*` unstyled variants; WCAG 2.1 AA; i18n |
| Async contract | §9.2 | Platform-idiomatic async (Promise, suspend, async throws, Future, etc.) |
| Input validation | §9.3 | Validate before network calls; throw synchronously on bad input |
| Idempotency | §9.4 | `signOut()` silent when no session; `initialize()` throws if called twice |
| Error model | §10 | `IAMError` struct; all error codes as typed enum; never swallow errors |
| Token storage | §11.1 | Platform-secure defaults; expose `StorageAdapter` interface |
| Token validation | §11.4 | Signature (JWKS), `iss`, `aud`, `exp`, `nonce`; JWKS caching + rotation |
| Token lifecycle | §11.7 | Auto-refresh ~60 s before expiry; rotate refresh tokens atomically |
| Credential handling | §11.5 | HTTPS only; never store or log credentials |
| Log sanitization | §11.6 | Mask tokens, emails, phone numbers; never log passwords or refresh tokens |
| Extensibility | §13 | `StorageAdapter`, `LoggerAdapter`, `HTTPAdapter`, event hooks |
| Standards compliance | §14 | OAuth 2.0, PKCE, OIDC, JWT, JWKS, RFC 7009, TOTP, FIDO2/WebAuthn |

---

### Step 4 — Create sample application

Read spec §17 in full before starting the sample app.

- Confirm the required sample name for this SDK from spec §17.3 — names follow `<sdk>-<scenario>` (e.g. `ios-b2c`, `react-b2c`)
- Create the sample under `samples/apps/<sample-name>/`
- Follow the B2C reference flow (spec §17.5) for browser/mobile SDKs, or the server-side equivalent
- Rules: self-contained install, env vars only (`.env.example` checked in, `.env` gitignored), own `README.md`
- Quality bar: spec §17.4 checklist must pass before the SDK is considered shippable

---

### Step 5 — Documentation stubs

Read spec §16 before creating any docs. Create stubs at:

- `docs/content/guides/quick-start/<sdk-name>/` — quickstart guide (spec §16.1)
- `docs/content/sdks/<sdk-name>/` — API reference directory (spec §16.2)

---

### Step 6 — Final checklist

Cross this against spec §15.3 before declaring the SDK done:

- [ ] `tools/sdks/<sdk-name>/` — source, `README.md`, build config, test suite (80%+ coverage target)
- [ ] `samples/apps/<sdk>-<scenario>/` — `README.md`, `.env.example`, no hardcoded secrets
- [ ] `.github/actions/<sdk-name>-sdk/action.yml` — composite CI action (spec §15.4)
- [ ] Job added to `.github/workflows/pr-builder.yml` calling the composite action (spec §15.4)
- [ ] Tag convention documented: `sdk/<sdk-name>/v<semver>` triggers the release workflow (spec §15.4)
- [ ] Package named per spec §15.2
- [ ] Parent SDK declared as a versioned dependency; no layer skipped (spec §2.6)
- [ ] All `ThunderIDClient` methods implemented or correctly delegated (spec §7.1)
- [ ] PKCE enforced (`S256` only, verifier in memory only) (spec §11.2)
- [ ] Token storage uses platform-secure defaults (spec §11.1)
- [ ] ID token validation complete (spec §11.4)
- [ ] All error codes from spec §10.2 implemented as typed enum
- [ ] No credentials, tokens, or PII logged at any level (spec §11.6)
- [ ] CI: lint, build, and test configured
- [ ] Docs stubs created (spec §16)

---

## Integration Workflow

### Step 1 — Identify the integration

Ask the user (or infer from context) before writing any code:

- **Integration name** — must match an entry in the spec §15.5 integration list (e.g. `authjs`, `passport`, `backstage`)
- **Target framework** — the third-party auth framework being integrated (e.g., Auth.js, Passport.js, Backstage)
- **ThunderID SDK dependency** — which ThunderID SDK this integration consumes (almost always the Node.js SDK)
- **Interface to implement** — the provider/strategy/plugin contract of the target framework

Read spec §2.7 to confirm the integration fits the definition.

---

### Step 2 — Generate a plan and confirm

Before creating any files or directories, output a complete plan using the following format and **stop for user confirmation**. Do not write any code until the user explicitly approves.

```
## Plan: <integration-name> integration

**Target framework:** <framework>
**ThunderID SDK consumed:** <sdk>
**Published package name:** @thunderid/integration-<name>

### Files to create
- [ ] tools/integrations/<integration-name>/                    — integration source root
- [ ] tools/integrations/<integration-name>/README.md
- [ ] tools/integrations/<integration-name>/<build-config>      — e.g. package.json
- [ ] .github/actions/<integration-name>-integration/action.yml — composite CI action
- [ ] samples/apps/<integration-name>-sample/                   — sample app
- [ ] samples/apps/<integration-name>-sample/.env.example
- [ ] samples/apps/<integration-name>-sample/README.md
- [ ] docs/content/guides/quick-start/<integration-name>/index.md
- [ ] docs/content/integrations/<integration-name>/overview.md
- [ ] <any additional files specific to this integration>

### CI changes
- [ ] Add job to .github/workflows/pr-builder.yml

### Out of scope for this PR
- <list anything deferred>
```

After presenting the plan, ask:

> Does this plan look right? Any changes before I start? (Reply **yes** to proceed, or tell me what to adjust.)

If the user requests changes, revise the plan and ask again. Only begin implementing once the user confirms.

---

### Step 3 — Scaffold the directory structure

The integration source lives flat at:

```
tools/integrations/<integration-name>/   # publishable integration source (no code/ subdirectory)
.github/actions/<integration-name>-integration/  # composite CI action
```

Run `ls tools/integrations/` first to confirm the name is consistent with existing integrations.

---

### Step 4 — Implement

Integrations have a different implementation contract from SDKs. Key rules from spec §2.7:

- **Do NOT implement `ThunderIDClient`** — this is not a ThunderID SDK
- **Do NOT re-implement OAuth2/OIDC logic** — import and call the ThunderID SDK instead
- **Implement the target framework's interface** in full — study the target framework's provider/strategy/plugin docs before writing a line of code
- Declare a **versioned dependency** on the ThunderID SDK (e.g., `@thunderid/node`)
- Follow the target framework's own conventions for errors, sessions, and configuration
- Package naming follows the convention in spec §15.5: `@thunderid/integration-<name>`

---

### Step 5 — Create sample application

Integrations also need a sample. The sample demonstrates the integration in the context of the target framework:

- Name: `<integration-name>-sample` (e.g., `authjs-sample`, `passport-sample`)
- Create under `samples/apps/<integration-name>-sample/`
- Self-contained install, env vars only, own `README.md`
- Must demonstrate: unauthenticated → sign-in → authenticated state → sign-out

---

### Step 6 — Documentation stubs

Create stubs at:

- `docs/content/guides/quick-start/<integration-name>/` — quickstart guide
- `docs/content/integrations/<integration-name>/` — integration reference

---

### Step 7 — Final checklist

- [ ] `tools/integrations/<integration-name>/` — source, `README.md`, build config, test suite
- [ ] ThunderID SDK declared as a versioned dependency; correct SDK layer used (spec §2.7)
- [ ] Target framework's provider/strategy/plugin interface implemented fully
- [ ] No OAuth2/OIDC logic re-implemented — all delegated to the ThunderID SDK
- [ ] Package named `@thunderid/integration-<name>` (spec §15.5)
- [ ] `.github/actions/<integration-name>-integration/action.yml` — composite CI action
- [ ] Job added to `.github/workflows/pr-builder.yml`
- [ ] Tag convention: `integration/<integration-name>/v<semver>`
- [ ] Sample app created under `samples/apps/<integration-name>-sample/`
- [ ] No credentials, tokens, or PII logged at any level
- [ ] Docs stubs created

---

## Standing conventions (AGENTS.md + spec)

- API terms: `signIn` / `signOut` / `signUp` — never `login` / `logout` / `register` (spec §18 glossary)
- Options types are open map/record types, not closed structs (spec §9.1)
- `isLoading()` is synchronous; all network I/O is async (spec §7.1)
- No premature abstractions, feature flags, or backwards-compat shims
- Delete dead code cleanly — no `// removed` comments, no `_`-prefixed unused variables
- Do not modify CI/CD, GitHub Actions, or Makefiles without explicit approval
- Do not add dependencies without explicit approval
