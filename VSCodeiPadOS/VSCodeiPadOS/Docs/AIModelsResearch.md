# AI Models Research

## OpenAI

| Model | Input (per 1M tokens) | Output (per 1M tokens) | Context |
|-------|-----------------------|------------------------|---------|
| **gpt-4o** | $2.50 | $10.00 | 128k |
| **gpt-4o-mini** | $0.15 | $0.60 | 128k |
| **gpt-4.5-preview** | $75.00 | $150.00 | 128k |
| **o1** | $15.00 | $60.00 | 128k |
| **o1-mini** | $3.00 | $12.00 | 128k |
| **o3-mini** | $1.10 | $4.40 | 128k |

**API Endpoint:** `https://api.openai.com/v1/chat/completions`

## Anthropic

| Model | Input (per 1M tokens) | Output (per 1M tokens) | Context |
|-------|-----------------------|------------------------|---------|
| **claude-3-7-sonnet-20250219** | $3.00 | $15.00 | 200k |
| **claude-3-5-sonnet-20241022** | $3.00 | $15.00 | 200k |
| **claude-3-opus-20240229** | $15.00 | $75.00 | 200k |

**API Endpoint:** `https://api.anthropic.com/v1/messages`

## Google (Gemini)

| Model | Input (per 1M tokens) | Output (per 1M tokens) | Context |
|-------|-----------------------|------------------------|---------|
| **gemini-2.0-flash** | $0.10 | $0.40 | 1M |
| **gemini-2.5-pro** | $1.25 (<200k)<br>$2.50 (>200k) | $10.00 (<200k)<br>$15.00 (>200k) | 2M |
| **gemini-2.5-flash** | $0.30 | $2.50 | 1M |

**API Endpoint:** `https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent`

## Kimi (Moonshot)

| Model | Input (per 1M tokens) | Output (per 1M tokens) | Context |
|-------|-----------------------|------------------------|---------|
| **moonshot-v1-8k** | ¥12.00 (~$1.68) | ¥12.00 (~$1.68) | 8k |
| **moonshot-v1-32k** | ¥24.00 (~$3.36) | ¥24.00 (~$3.36) | 32k |
| **moonshot-v1-128k** | ¥60.00 (~$8.40) | ¥60.00 (~$8.40) | 128k |
| **kimi-k2.5** | $0.60 | $2.50 | 128k |

**API Endpoint:** `https://api.moonshot.cn/v1/chat/completions`

## GLM (Zhipu)

| Model | Input (per 1M tokens) | Output (per 1M tokens) | Context |
|-------|-----------------------|------------------------|---------|
| **glm-4-plus** | ¥5.00 (~$0.70) | ¥5.00 (~$0.70) | 128k |
| **glm-4-air** | ¥1.00 (~$0.14) | ¥1.00 (~$0.14) | 128k |
| **glm-4-flash** | Free / ¥0.10 (~$0.01) | Free / ¥0.10 (~$0.01) | 128k |

**API Endpoint:** `https://open.bigmodel.cn/api/paas/v4/chat/completions`

## Groq

| Model | Input (per 1M tokens) | Output (per 1M tokens) | Context |
|-------|-----------------------|------------------------|---------|
| **llama-3.3-70b-versatile** | $0.59 | $0.79 | 128k |
| **mixtral-8x7b-32768** | $0.24 | $0.24 | 32k |
| **llama-3.1-8b-instant** | $0.05 | $0.08 | 128k |

**API Endpoint:** `https://api.groq.com/openai/v1/chat/completions`

## Mistral

| Model | Input (per 1M tokens) | Output (per 1M tokens) | Context |
|-------|-----------------------|------------------------|---------|
| **mistral-large-latest** | $2.00 | $6.00 | 128k |
| **codestral-latest** | $0.20 | $0.60 | 32k |
| **mistral-small** | $0.20 | $0.60 | 32k |

**API Endpoint:** `https://api.mistral.ai/v1/chat/completions`

## DeepSeek

| Model | Input (per 1M tokens) | Output (per 1M tokens) | Context |
|-------|-----------------------|------------------------|---------|
| **deepseek-chat (V3)** | $0.14 | $0.28 | 64k |
| **deepseek-coder** | $0.14 | $0.28 | 64k |
| **deepseek-reasoner (R1)**| $0.55 | $2.19 | 128k |

**API Endpoint:** `https://api.deepseek.com/chat/completions`

*Note: Pricing and availability subject to change. Some "preview" models may have different rate limits or access requirements.*