# Security Policy

## 📢 Reporting a Vulnerability

If you discover a security vulnerability in CodePad (VSCodeiPadOS), please report it responsibly.

### How to Report

1. **Preferred: Email** — Send a report to the project maintainers (see repository contact) with the subject line: `[SECURITY] CodePad Vulnerability Report`
2. **Alternative: Private Security Advisory** — Open a [GitHub Security Advisory](https://github.com/<org>/vscode-ipados/security/advisories/new) (requires a GitHub account)

### What to Include

- **Description** of the vulnerability
- **Steps to reproduce** the issue
- **Impact assessment** — what an attacker could do
- **Affected versions** — which version(s) are impacted
- **Suggested fix** (optional but appreciated)
- **Any proof-of-concept code** (optional)

### What to Expect

- **Acknowledgment** within 48 hours
- **Initial assessment** within 5 business days
- **Status updates** every 7 days until resolved
- **Credit** in the fix commit/changelog (unless you request anonymity)

> ⚠️ **Do not** open a public GitHub issue for security vulnerabilities. Public disclosure before a fix is available puts users at risk.

---

## Scope

The following areas are considered within the security scope of this project:

### ✅ In Scope

| Area | Details |
|------|---------|
| **API Key Storage** | How API keys (OpenAI, Anthropic, Google, etc.) and tokens (HuggingFace) are stored and accessed. Keys are stored in the iOS Keychain via `KeychainHelper` with `kSecAttrAccessibleAfterFirstUnlock`. Migration from UserDefaults (plaintext) to Keychain must not regress. |
| **Code Execution Sandboxing** | How user code is executed on-device via the integrated terminal, code runners, and on-device LLM (MLX). The app runs within the iOS app sandbox. Evaluating whether user code can escape the sandbox or access unauthorized resources. |
| **Workspace Trust** | Whether workspace files, extensions, or configurations can be used to execute arbitrary code or access data outside the sandbox. Security-scoped resource access should be properly scoped and released. |
| **Network Communication** | API calls to AI providers, git operations, and any data transmitted over the network. TLS enforcement, certificate pinning, and data in transit. |
| **Data Persistence** | How user data (files, settings, chat history) is stored on device. Sensitive data must use Keychain or appropriate encryption. |
| **Dependency Vulnerabilities** | Security issues in third-party Swift packages (Runestone, GzipSwift, etc.) used by the project. |
| **Crash Reporting** | The built-in `CrashReporter` persists crash logs to disk — ensure no sensitive data (API keys, file contents) is included in crash reports. |

### ❌ Out of Scope

- Issues in third-party AI provider APIs or their infrastructure
- Issues in Apple's iOS/iPadOS operating system
- Issues in the iPadOS app sandbox implementation itself
- Social engineering attacks
- Denial of service via normal app usage (e.g., opening very large files)

---

## Supported Versions

| Version | Supported | Security Updates |
|---------|-----------|-----------------|
| **1.0.x** (main branch) | ✅ Yes | Active |
| Pre-release (branches) | ⚠️ Best effort | When feasible |

Security fixes will be backported to the latest stable release branch when possible.

---

## Key Security Architecture

### API Key Storage

All API keys are stored in the **iOS Keychain** using `KeychainHelper`:

- **Location:** `Utils/KeychainHelper.swift`
- **Service identifier:** `com.vscode-ipados.api-keys`
- **Accessibility:** `kSecAttrAccessibleAfterFirstUnlock` — keys available after first device unlock
- **Migration:** On first launch, keys are automatically migrated from `UserDefaults` (plaintext) to Keychain, then deleted from UserDefaults
- **Providers covered:** OpenAI, Anthropic, Google, Kimi, GLM, Groq, DeepSeek, Mistral, HuggingFace (token)

> 🔒 **Contributors:** Never store secrets in `UserDefaults`, `@AppStorage`, or any plaintext storage. Always use `KeychainHelper.shared.set(_:forKey:)` for any sensitive data.

### Code Execution

- The app runs within the **iOS app sandbox** with limited filesystem and network access
- Entitlements are declared in `VSCodeiPadOS.entitlements`
- On-device code execution (terminal, runners) operates within sandbox constraints
- `NSAllowsLocalNetworking` ATS exception is configured for Ollama/code-server (local-only connections)

### Crash Reporting

The built-in `CrashReporter` (`Utils/AppLogger.swift`) persists crash logs to the Documents directory. It captures:
- Exception name, reason, and call stack
- App version and device model
- OS version

It does **not** capture file contents, API keys, or user data.

---

## Disclosure Policy

1. **Private Report** — Vulnerability is reported privately via email or GitHub Security Advisory
2. **Confirmation** — Maintainers confirm receipt and begin investigation
3. **Fix Development** — Maintainers develop a fix (contributor may also submit a PR)
4. **Coordinated Disclosure** — Once a fix is available, a public advisory is published
5. **Credit** — Reporter is credited in the advisory and changelog (unless anonymous)
6. **CVSS Scoring** — Vulnerabilities are assessed using the [Common Vulnerability Scoring System (CVSS v3.1)](https://www.first.org/cvss/v3.1/)

### Timeline Expectations

| Severity | Fix Timeline |
|----------|-------------|
| **Critical** (data exfiltration, code execution) | 7 days |
| **High** (privilege escalation, sensitive data leak) | 14 days |
| **Medium** (limited impact, requires specific conditions) | 30 days |
| **Low** (informational, minor impact) | 90 days or next release |

Timelines may be adjusted based on complexity. Maintainers will communicate any delays.

---

## Best Practices for Contributors

- **Never commit API keys, tokens, or secrets** to the repository
- **Never use `print()` for logging** — use `AppLogger` which respects iOS log privacy
- **Never store sensitive data in `UserDefaults`** — use `KeychainHelper`
- **Use `[weak self]` in closures** to prevent retain cycles and potential memory issues
- **Use `safeRegex()`** instead of raw `try! NSRegularExpression` to prevent crash vectors
- **Audit new dependencies** for known vulnerabilities before adding Swift Package Manager dependencies
- **Test with VoiceOver enabled** — accessibility gaps can indicate missing input validation

---

## Security-Related Files

| File | Purpose |
|------|---------|
| `VSCodeiPadOS/VSCodeiPadOS/Utils/KeychainHelper.swift` | Keychain wrapper for API key storage |
| `VSCodeiPadOS/VSCodeiPadOS/Utils/AppLogger.swift` | Centralized logging + CrashReporter |
| `VSCodeiPadOS/VSCodeiPadOS.entitlements` | App sandbox entitlements |
| `VSCodeiPadOS/VSCodeiPadOS/PrivacyInfo.xcprivacy` | Apple privacy manifest (API usage declarations) |
| `VSCodeiPadOS/VSCodeiPadOS/Info.plist` | ATS exceptions, UTI declarations, app capabilities |
| `VSCodeiPadOS/FeatureFlags.swift` | Feature toggles for experimental subsystems |

---

Thank you for helping keep CodePad and its users safe! 🛡️
