# Nanbeige Chat Template Fix - CRITICAL DOCUMENTATION

> **DO NOT REMOVE OR MODIFY THE TEMPLATE PATCHING CODE WITHOUT READING THIS**

## The Problem

The `mlx-community/Nanbeige4.1-3B-heretic-4bit` model outputs **Chinese** instead of English because:

1. The MLX community quantized version is MISSING the `chat_template` field in `tokenizer_config.json`
2. OR it has a template with Chinese default system prompts ("你是南北阁...")
3. Without proper English template, the model defaults to Chinese responses

## The Fix Location

**File:** `Services/LocalLLMService.swift`
**Function:** `patchTokenizerConfig(at url: URL)`
**Lines:** ~314-345

## What the Fix Does

1. Detects Nanbeige model by checking if path contains "nanbeige" (case-insensitive)
2. **ALWAYS** overwrites the `chat_template` with our English version
3. Uses STX/ETX control characters (U+0002/U+0003) as message delimiters (Nanbeige's format)
4. Sets English default system prompt: "You are a helpful coding assistant. Always respond in English."

## The Template Format

Nanbeige uses non-standard delimiters:
```
␂system\n{system_prompt}␃\n
␂user\n{user_message}␃\n
␂assistant\n{response}␃\n
```

Where `␂` is STX (U+0002) and `␃` is ETX (U+0003).

## If Model Outputs Chinese Again

1. **Clear iPad model cache**: The template is patched at download time. If model was cached before the fix, it has the old template.
   - Use `clearModelCache()` function in app
   - OR delete `~/Library/Caches/huggingface/` on iPad
   - Then re-download the model

2. **Check console logs**: Look for:
   - `[LocalLLM] patchTokenizerConfig: path=..., isNanbeige=true`
   - `[LocalLLM] FORCED Nanbeige chat_template to English version`

3. **Verify the code**: Make sure `patchTokenizerConfig` is being called and the Nanbeige branch is executing.

## History of This Bug

- **2026-02-16**: First fixed in commit `3e12e6b`
- **2026-02-21**: Regressed because cached models on iPad had old templates. Fixed by ALWAYS overwriting template (not just when empty/matching specific Chinese strings).

## Code Snippet (for reference)

```swift
// In patchTokenizerConfig:
let isNanbeige = url.path.lowercased().contains("nanbeige")
if isNanbeige {
    // ALWAYS overwrite - don't check if equal, just set it
    json["chat_template"] = nanbeigeTemplate
    needsWrite = true
}
```

## DO NOT

- Remove the template patching code
- Make the patching conditional ("only if empty" etc.)
- Change the template format without testing on iPad
- Assume the HuggingFace Hub version is fixed - it's not
