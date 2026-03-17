# Privacy Policy — CodePad Pro

**Effective Date:** March 17, 2026

---

## 1. Introduction

CodePad Pro is an open-source code editor designed specifically for iPad. It is built with a privacy-first philosophy: your code, your credentials, and your workflow stay on your device. We do not operate any servers, and the application does not phone home.

This Privacy Policy explains what CodePad Pro does — and, more importantly, what it does *not* do — with your information.

---

## 2. Data Collection

**CodePad Pro collects NO personal data.**

We do not collect, store, transmit, or process any of the following:

- **Personal identifiers** (name, email, phone number, device ID, etc.)
- **Usage analytics** (no telemetry, no session tracking, no feature usage statistics)
- **Crash reports** (no crash reporting SDKs are integrated)
- **Advertising identifiers** (no ad SDKs are integrated)
- **Location data**
- **Health or financial data**

CodePad Pro has no analytics, no tracking pixels, no third-party measurement frameworks, and no user accounts. The app functions entirely without an internet connection unless you explicitly connect to your own remote services.

---

## 3. Local Storage

All user data in CodePad Pro is stored exclusively on your iPad within the app's iOS sandbox:

| Data Type | Storage Mechanism |
|---|---|
| Source files, projects, and workspaces | iOS Files app sandbox (app-local container) |
| Workspace preferences, editor settings, UI state | `UserDefaults` (app-local) |
| SSH credentials and API keys | iOS Keychain (see [Section 4](#4-credentials--keys)) |
| Git repositories | Local filesystem within the app sandbox |
| AI provider configurations | `UserDefaults` and iOS Keychain |

No data stored locally is transmitted to us. We have no servers to receive it.

---

## 4. Credentials & Keys

CodePad Pro handles sensitive credentials using Apple's secure system-level storage:

- **SSH credentials** (private keys, passwords, passphrases) and **API keys** (for AI providers, Git hosts, etc.) are stored exclusively in the **iOS Keychain**.
- The iOS Keychain is encrypted at rest using hardware-backed encryption (Secure Enclave on supported devices) and is accessible only to CodePad Pro (or apps you explicitly share Keychain access with through iOS Settings).
- **Credentials are never transmitted to our servers**, because we do not operate any servers.
- Credentials are only transmitted by CodePad Pro when you initiate a connection to a server or API endpoint that *you* have configured (e.g., your own SSH server, your own OpenAI API key for your own OpenAI account).

---

## 5. SSH Connections

CodePad Pro supports connecting to remote servers via SSH for file editing and terminal access:

- **Connections are user-initiated** — CodePad Pro will only connect to servers that you explicitly configure and authorize.
- **We do not operate any proxy servers.** All SSH traffic goes directly from your iPad to your configured server.
- **We do not log, inspect, or intercept any SSH traffic.**
- Connection details (hostnames, ports, usernames) are stored locally in the iOS Keychain.
- SSH key management (generation, import, deletion) is performed entirely on-device.

---

## 6. AI Features

CodePad Pro offers AI-assisted coding features that connect to external AI providers:

- **Supported providers include** (but are not limited to): OpenAI, Anthropic, Google AI, Ollama, and other OpenAI-compatible API endpoints.
- **API keys** for these services are stored locally in the iOS Keychain and are never sent to us.
- **Code snippets, prompts, and responses** are sent directly from your iPad to the AI provider's API endpoint you have configured. This transmission is governed by that provider's own privacy policy and terms of service.
- **No AI data is sent to CodePad Pro's developers or any intermediary server.** We have no visibility into your prompts or the AI's responses.
- If you use a self-hosted provider (such as Ollama running locally or on your own server), all AI data stays within your network.

> **Recommendation:** Review the privacy policies of any AI providers you configure in CodePad Pro to understand how they handle your data.

---

## 7. Git Operations

CodePad Pro supports Git version control:

- **Local Git operations** (commit, branch, merge, diff, log, etc.) are performed entirely on-device using a built-in Git client.
- **Remote Git operations** (push, pull, fetch, clone) connect directly to Git hosting providers (e.g., GitHub, GitLab, Bitbucket) or to your own Git servers via the protocols you configure (HTTPS or SSH).
- **Repository data is stored locally** within the app's sandbox.
- Git credentials (personal access tokens, SSH keys) are stored in the iOS Keychain (see [Section 4](#4-credentials--keys)).
- **We do not proxy, log, or access any Git traffic.**

---

## 8. VS Code Tunnel / Connected Mode

CodePad Pro offers a connected mode that uses a WebView to interface with a remote VS Code or code-server instance:

- The app connects to a **server URL that you configure** (e.g., a VS Code Tunnel URL, a code-server instance, or any compatible endpoint).
- **We do not operate these servers.** The connection is made directly from your iPad's WebView to the URL you provide.
- **We do not proxy, intercept, or log any traffic** between CodePad Pro and your configured server.
- Authentication to these services uses the mechanisms provided by the server (tokens, passwords, etc.) and is handled entirely within the WebView session.

---

## 9. Third-Party Services & SDKs

CodePad Pro deliberately avoids integrating privacy-invasive third-party services:

| Category | Status |
|---|---|
| Analytics SDKs (e.g., Firebase Analytics, Mixpanel, Amplitude) | ❌ Not integrated |
| Crash reporting SDKs (e.g., Crashlytics, Sentry) | ❌ Not integrated |
| Advertising SDKs (e.g., Google AdMob, Facebook Ads) | ❌ Not integrated |
| Social login SDKs | ❌ Not integrated |
| Performance monitoring | ❌ Not integrated |
| Push notification services | ❌ Not integrated |
| Data brokers | ❌ Not integrated |

CodePad Pro is designed to function without any network connectivity. The only network traffic generated by the app is that which you explicitly initiate (SSH connections, AI API calls, Git remote operations, and WebView connections to your configured servers).

---

## 10. Children's Privacy

CodePad Pro is a professional developer tool and is **not directed at children under the age of 13**. We do not knowingly collect personal information from children. Because CodePad Pro does not collect any personal information from any user, the Children's Online Privacy Protection Act (COPPA) is not applicable, but we affirmatively state that the app is not designed for or marketed to children.

---

## 11. Changes to This Privacy Policy

We may update this Privacy Policy from time to time. When we do:

- The updated policy will be committed to the **GitHub repository** where CodePad Pro is developed.
- The **"Effective Date"** at the top of this document will be revised to reflect the date of the most recent changes.
- We encourage you to periodically review this document to stay informed about how CodePad Pro handles privacy.

> **Note:** Because CodePad Pro is an open-source project, all changes to this policy are visible through version history in the repository.

---

## 12. Contact

If you have questions, concerns, or suggestions about this Privacy Policy or CodePad Pro's privacy practices, please open an issue on our GitHub repository:

📧 **GitHub Issues:** [Open a new issue](https://github.com/nicholaschum/CodePad/issues)

We will make our best effort to respond to privacy-related inquiries in a timely manner.

---

## Summary

| Question | Answer |
|---|---|
| Does CodePad Pro collect personal data? | **No.** |
| Does CodePad Pro use analytics or tracking? | **No.** |
| Where is my data stored? | **On your iPad only** (Files sandbox, UserDefaults, iOS Keychain). |
| Are my credentials sent anywhere? | **Only to the servers you configure.** Never to us. |
| Does CodePad Pro have servers? | **No.** |
| Does CodePad Pro contain ads? | **No.** |
| Can I use CodePad Pro offline? | **Yes**, with full local editing and Git support. |

---

*This Privacy Policy is provided as-is for the CodePad Pro open-source project. It is intended to comply with App Store review guidelines, GDPR principles, and general best practices for privacy transparency in mobile applications.*
