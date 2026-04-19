# Thunder SDK Creator

You are helping implement a new Thunder SDK.

**Before doing anything else, read the full specification:**

```
tools/sdks/specification/README.md
```

The spec is the authoritative source for all requirements. Everything in this skill is a process guide that points you to spec sections — when there is any ambiguity, the spec wins.

---

## Step 1 — Identify the SDK

Ask the user (or infer from context) before writing any code:

- **SDK name** — must match an entry in the spec §15.1 SDK list (e.g. `react`, `browser`, `nextjs`)
- **Layer** — Agnostic | Platform | Core Lib | Framework Specific (spec §2.2)
- **Parent SDK** — the immediate layer below; no layer may skip its parent (spec §2.6)
- **Ecosystem** — JavaScript, Python, Swift, Kotlin, Dart, etc.

Cross-check the layer assignment against the worked example diagram in spec §2.4 and the ecosystem table in spec §2.5.

---

## Step 2 — Scaffold the directory structure

Read spec §15.0 for the canonical layout. The SDK source lives flat at:

```
tools/sdks/<sdk-name>/           # publishable SDK library source (no code/ subdirectory)
.github/actions/<sdk-name>-sdk/  # composite CI action (spec §15.4)
```

Run `ls tools/sdks/` first to confirm the name is consistent with existing SDKs.

---

## Step 3 — Implement `code/`

Work through the spec in order. For each area below, **re-read the referenced section** before implementing — do not rely on memory or the summaries here.

| Area | Spec section | Key requirement |
|------|-------------|-----------------|
| Package naming | §15.2 | Follow ecosystem convention (`@thunder/*`, `io.thunder.*`, etc.) |
| Layer contract | §2.2, §2.6 | Implement only this layer's responsibility; never re-implement parent logic |
| Initialization | §5.1 | Validate config at init; throw `SDKNotInitializedException` before init |
| Configuration schema | §5.2 | All required + applicable optional fields; reject HTTP `baseUrl` |
| Preferences (UI SDKs) | §5.3 | `theme` + `i18n` sub-objects |
| Operational modes | §4 | Both redirect and app-native; mode inferred from config, not declared |
| PKCE | §11.2 | Mandatory in redirect mode; `S256` only; `code_verifier` in memory only |
| `IAMClient` interface | §7.1 | All methods; `signIn()`/`signUp()` overloaded for both modes |
| Identity lifecycle ops | §6 | Auth, registration, recovery, session, token, profile, org management |
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

## Step 4 — Create sample application

Read spec §17 in full before starting the sample app.

- Confirm the required sample name for this SDK from spec §17.3 — names follow `<sdk>-<scenario>` (e.g. `ios-b2c`, `react-b2c`)
- Create the sample under `samples/apps/<sample-name>/`
- Follow the B2C reference flow (spec §17.5) for browser/mobile SDKs, or the server-side equivalent
- Rules: self-contained install, env vars only (`.env.example` checked in, `.env` gitignored), own `README.md`
- Quality bar: spec §17.4 checklist must pass before the SDK is considered shippable

---

## Step 5 — Documentation stubs

Read spec §16 before creating any docs. Create stubs at:

- `docs/content/guides/quick-start/<sdk-name>/` — quickstart guide (spec §16.1)
- `docs/content/sdks/<sdk-name>/` — API reference directory (spec §16.2)

---

## Step 6 — Final checklist

Cross this against spec §15.3 before declaring the SDK done:

- [ ] `tools/sdks/<sdk-name>/` — source, `README.md`, build config, test suite (80%+ coverage target)
- [ ] `samples/apps/<sdk>-<scenario>/` — `README.md`, `.env.example`, no hardcoded secrets
- [ ] `.github/actions/<sdk-name>-sdk/action.yml` — composite CI action (spec §15.4)
- [ ] Job added to `.github/workflows/pr-builder.yml` calling the composite action (spec §15.4)
- [ ] Tag convention documented: `sdk/<sdk-name>/v<semver>` triggers the release workflow (spec §15.4)
- [ ] Package named per spec §15.2
- [ ] Parent SDK declared as a versioned dependency; no layer skipped (spec §2.6)
- [ ] All `IAMClient` methods implemented or correctly delegated (spec §7.1)
- [ ] PKCE enforced (`S256` only, verifier in memory only) (spec §11.2)
- [ ] Token storage uses platform-secure defaults (spec §11.1)
- [ ] ID token validation complete (spec §11.4)
- [ ] All error codes from spec §10.2 implemented as typed enum
- [ ] No credentials, tokens, or PII logged at any level (spec §11.6)
- [ ] CI: lint, build, and test configured
- [ ] Docs stubs created (spec §16)

---

## Standing conventions (AGENTS.md + spec)

- API terms: `signIn` / `signOut` / `signUp` — never `login` / `logout` / `register` (spec §18 glossary)
- Options types are open map/record types, not closed structs (spec §9.1)
- `isLoading()` is synchronous; all network I/O is async (spec §7.1)
- No premature abstractions, feature flags, or backwards-compat shims
- Delete dead code cleanly — no `// removed` comments, no `_`-prefixed unused variables
- Do not modify CI/CD, GitHub Actions, or Makefiles without explicit approval
- Do not add dependencies without explicit approval
