# AI Models Research

Research documentation for AI models used in VSCode iPadOS extension.

---

## OpenAI Models

### Overview

OpenAI provides a comprehensive suite of large language models including GPT-4o for general-purpose tasks, o-series reasoning models for complex problem-solving, and specialized embedding models for semantic search and clustering.

---

## GPT-4o Family

### GPT-4o

**Description:** Fast, intelligent, flexible GPT model - our versatile, high-intelligence flagship model

| Attribute | Value |
|-----------|-------|
| **Model ID** | `gpt-4o` |
| **Snapshot** | `gpt-4o-2024-08-06` |
| **Context Window** | 128,000 tokens |
| **Max Output Tokens** | 16,384 |
| **Knowledge Cutoff** | October 1, 2023 |
| **Intelligence** | High |
| **Speed** | Medium |

**Pricing (Standard):**
- Input: $2.50 / 1M tokens
- Cached Input: $1.25 / 1M tokens
- Output: $10.00 / 1M tokens
- Batch Input: $1.25 / 1M tokens
- Batch Output: $5.00 / 1M tokens

**Modalities:**
- Text: Input and output
- Image: Input only
- Audio: Not supported
- Video: Not supported

**Supported Features:**
- Streaming
- Function calling
- Structured outputs
- Fine-tuning
- Distillation
- Predicted outputs

---

### GPT-4o mini

**Description:** Fast, affordable small model for focused tasks

| Attribute | Value |
|-----------|-------|
| **Model ID** | `gpt-4o-mini` |
| **Snapshot** | `gpt-4o-mini-2024-07-18` |
| **Context Window** | 128,000 tokens |
| **Max Output Tokens** | 16,384 |
| **Knowledge Cutoff** | October 1, 2023 |
| **Intelligence** | Average |
| **Speed** | Fast |

**Pricing (Standard):**
- Input: $0.15 / 1M tokens
- Cached Input: $0.075 / 1M tokens
- Output: $0.60 / 1M tokens
- Batch Input: $0.075 / 1M tokens
- Batch Output: $0.30 / 1M tokens

**Modalities:**
- Text: Input and output
- Image: Input only

**Supported Features:**
- Streaming
- Function calling
- Structured outputs
- Fine-tuning
- Predicted outputs (Distillation not supported)

---

### Legacy: gpt-4o-2024-05-13

| Attribute | Value |
|-----------|-------|
| **Snapshot** | `gpt-4o-2024-05-13` |
| **Context Window** | 128,000 tokens |
| **Pricing (Standard)** | Input: $5.00, Output: $15.00 / 1M tokens |

---

## GPT-4.5 Preview (Deprecated)

> **Status:** Deprecated - research preview  
> **Recommendation:** Use `gpt-4.1` or `o3` models instead for most use cases

| Attribute | Value |
|-----------|-------|
| **Model ID** | `gpt-4.5-preview` |
| **Snapshot** | `gpt-4.5-preview-2025-02-27` |
| **Context Window** | 128,000 tokens |
| **Max Output Tokens** | 16,384 |
| **Knowledge Cutoff** | October 1, 2023 |
| **Intelligence** | Higher |
| **Speed** | Medium |

**Pricing (Standard):**
- Input: $75.00 / 1M tokens
- Cached Input: $37.50 / 1M tokens
- Output: $150.00 / 1M tokens
- Batch Input: $37.50 / 1M tokens
- Batch Output: $75.00 / 1M tokens

---

## o-Series Reasoning Models

### o3

**Description:** Reasoning model for complex tasks, succeeded by GPT-5. Well-rounded and powerful model across domains - sets new standard for math, science, coding, and visual reasoning.

| Attribute | Value |
|-----------|-------|
| **Model ID** | `o3` |
| **Snapshot** | `o3-2025-04-16` |
| **Context Window** | 200,000 tokens |
| **Max Output Tokens** | 100,000 |
| **Knowledge Cutoff** | June 1, 2024 |
| **Reasoning** | Highest |
| **Speed** | Slowest |

**Pricing (Standard):**
- Input: $2.00 / 1M tokens
- Cached Input: $0.50 / 1M tokens
- Output: $8.00 / 1M tokens
- Batch Input: $1.00 / 1M tokens
- Batch Output: $4.00 / 1M tokens

**Pricing (Flex):**
- Input: $1.00 / 1M tokens
- Cached Input: $0.25 / 1M tokens
- Output: $4.00 / 1M tokens

**Modalities:**
- Text: Input and output
- Image: Input only

**Supported Features:**
- Streaming
- Function calling
- Structured outputs
- Reasoning token support

**Note:** Succeeded by GPT-5. Use [reasoning guide](https://platform.openai.com/docs/guides/reasoning) for best practices.

---

### o1

**Description:** Previous full o-series reasoning model - trained with reinforcement learning for complex reasoning

| Attribute | Value |
|-----------|-------|
| **Model ID** | `o1` |
| **Snapshot** | `o1-2024-12-17` |
| **Context Window** | 200,000 tokens |
| **Max Output Tokens** | 100,000 |
| **Knowledge Cutoff** | October 1, 2023 |
| **Reasoning** | Higher |
| **Speed** | Slowest |

**Pricing (Standard):**
- Input: $15.00 / 1M tokens
- Cached Input: $7.50 / 1M tokens
- Output: $60.00 / 1M tokens
- Batch Input: $7.50 / 1M tokens
- Batch Output: $30.00 / 1M tokens

**Deprecated Snapshot:**
- `o1-preview` → `o1-preview-2024-09-12`

---

### o3-mini

**Description:** A small model alternative to o3 - providing high intelligence at same cost and latency targets as o1-mini

| Attribute | Value |
|-----------|-------|
| **Model ID** | `o3-mini` |
| **Snapshot** | `o3-mini-2025-01-31` |
| **Context Window** | 200,000 tokens |
| **Max Output Tokens** | 100,000 |
| **Knowledge Cutoff** | October 1, 2023 |
| **Reasoning** | Higher |
| **Speed** | Medium |

**Pricing (Standard):**
- Input: $1.10 / 1M tokens
- Cached Input: $0.55 / 1M tokens
- Output: $4.40 / 1M tokens
- Batch Input: $0.55 / 1M tokens
- Batch Output: $2.20 / 1M tokens

**Supported Features:**
- Streaming
- Function calling
- Structured outputs
- Batch API
- Reasoning token support

---

### o4-mini

**Description:** Fast, cost-efficient reasoning model, succeeded by GPT-5 mini. Optimized for fast, effective reasoning with exceptionally efficient performance in coding and visual tasks.

| Attribute | Value |
|-----------|-------|
| **Model ID** | `o4-mini` |
| **Snapshot** | `o4-mini-2025-04-16` |
| **Context Window** | 200,000 tokens |
| **Max Output Tokens** | 100,000 |
| **Knowledge Cutoff** | June 1, 2024 |
| **Reasoning** | Higher |
| **Speed** | Medium |

**Pricing (Standard):**
- Input: $1.10 / 1M tokens
- Cached Input: $0.275 / 1M tokens
- Output: $4.40 / 1M tokens
- Batch Input: $0.55 / 1M tokens
- Batch Output: $2.20 / 1M tokens

**Pricing (Flex):**
- Input: $0.55 / 1M tokens
- Cached Input: $0.138 / 1M tokens
- Output: $2.20 / 1M tokens

**Modalities:**
- Text: Input and output
- Image: Input only

**Supported Features:**
- Streaming
- Function calling
- Structured outputs
- Fine-tuning
- Reasoning token support

**Note:** Succeeded by GPT-5 mini.

---

### o1-pro

**Description:** Version of o1 with more compute for better responses

| Attribute | Value |
|-----------|-------|
| **Model ID** | `o1-pro` |

**Pricing (Standard):**
- Input: $150.00 / 1M tokens
- Output: $600.00 / 1M tokens

---

### o3-pro

**Description:** Version of o3 with more compute for better responses

| Attribute | Value |
|-----------|-------|
| **Model ID** | `o3-pro` |

**Pricing (Standard):**
- Input: $20.00 / 1M tokens
- Output: $80.00 / 1M tokens

---

## Embeddings Models

### text-embedding-3-large

**Description:** Most capable embedding model - best for both English and non-English tasks

| Attribute | Value |
|-----------|-------|
| **Model ID** | `text-embedding-3-large` |
| **Performance** | High |
| **Speed** | Slow |
| **Dimensions** | 3,072 (default) |

**Pricing:**
- Standard: $0.13 / 1M tokens
- Batch: $0.065 / 1M tokens

**Rate Limits (Tier 1):**
- RPM: 3,000
- TPM: 1,000,000
- Batch Queue: 3,000,000

**Use Cases:**
- Search
- Clustering
- Recommendations
- Anomaly detection
- Classification

---

### text-embedding-3-small

**Description:** Small embedding model - improved, more performant version of ada embedding model

| Attribute | Value |
|-----------|-------|
| **Model ID** | `text-embedding-3-small` |
| **Performance** | Average |
| **Speed** | Medium |
| **Dimensions** | 1,536 (default) |

**Pricing:**
- Standard: $0.02 / 1M tokens
- Batch: $0.01 / 1M tokens

**Rate Limits (Tier 1):**
- RPM: 3,000
- TPM: 1,000,000
- Batch Queue: 3,000,000

---

### text-embedding-ada-002

**Description:** Older embedding model - legacy version

| Attribute | Value |
|-----------|-------|
| **Model ID** | `text-embedding-ada-002` |
| **Performance** | Low |
| **Speed** | Slow |
| **Dimensions** | 1,536 |

**Pricing:**
- Standard: $0.10 / 1M tokens
- Batch: $0.05 / 1M tokens

**Rate Limits (Tier 1):**
- RPM: 3,000
- TPM: 1,000,000
- Batch Queue: 3,000,000

---

## OpenAI Model Comparison Summary

| Model | Context | Input Price | Output Price | Best For |
|-------|---------|-------------|--------------|----------|
| gpt-4o | 128K | $2.50 | $10.00 | General-purpose, high intelligence |
| gpt-4o-mini | 128K | $0.15 | $0.60 | Fast, cost-efficient tasks |
| o3 | 200K | $2.00 | $8.00 | Complex reasoning, math, coding |
| o1 | 200K | $15.00 | $60.00 | Complex reasoning (legacy) |
| o3-mini | 200K | $1.10 | $4.40 | Small reasoning model |
| o4-mini | 200K | $1.10 | $4.40 | Fast reasoning, coding |
| text-embedding-3-large | 8K* | $0.13 | - | Best quality embeddings |
| text-embedding-3-small | 8K* | $0.02 | - | Cost-efficient embeddings |

*\*Embedding models have 8,191 token input limit*

---

## Processing Tiers

OpenAI offers multiple pricing tiers based on processing priority:

| Tier | Description | Price Multiplier |
|------|-------------|------------------|
| **Batch** | Non-urgent, 24-hour turnaround | 0.5x |
| **Flex** | Lower priority, higher latency | 0.5x |
| **Standard** | Default processing | 1.0x |
| **Priority** | Faster processing | 2.0x+ |

---

## Anthropic Claude Models

### Overview

Claude is a family of state-of-the-art large language models developed by Anthropic. All current Claude models support text and image input, text output, multilingual capabilities, and vision.

---

## Claude 4 Series (Current Generation)

### Claude Opus 4.6

**Description:** Our most intelligent model for building agents and coding

| Attribute | Value |
|-----------|-------|
| **Claude API ID** | `claude-opus-4-6` |
| **Claude API Alias** | `claude-opus-4-6` |
| **AWS Bedrock ID** | `anthropic.claude-opus-4-6-v1` |
| **GCP Vertex AI ID** | `claude-opus-4-6` |
| **Context Window** | 200K tokens / 1M tokens (beta) |
| **Max Output** | 128K tokens |
| **Extended Thinking** | Yes |
| **Adaptive Thinking** | Yes |
| **Priority Tier** | Yes |
| **Training Data Cutoff** | August 2025 |
| **Reliable Knowledge Cutoff** | May 2025 |

**Pricing:**
- Input: $5 / MTok
- Output: $25 / MTok
- 5m Cache Writes: $6.25 / MTok
- 1h Cache Writes: $10 / MTok
- Cache Hits & Refreshes: $0.50 / MTok
- Batch Input: $2.50 / MTok
- Batch Output: $12.50 / MTok

**Long Context Pricing (>200K tokens):**
- Input: $10 / MTok
- Output: $37.50 / MTok

---

### Claude Opus 4.5

| Attribute | Value |
|-----------|-------|
| **Claude API ID** | `claude-opus-4-5-20251101` |
| **Claude API Alias** | `claude-opus-4-5` |
| **AWS Bedrock ID** | `anthropic.claude-opus-4-5-20251101-v1:0` |
| **GCP Vertex AI ID** | `claude-opus-4-5@20251101` |
| **Context Window** | 200K tokens |
| **Max Output** | 128K tokens |
| **Extended Thinking** | Yes |
| **Adaptive Thinking** | Yes |
| **Training Data Cutoff** | July 2025 |
| **Reliable Knowledge Cutoff** | January 2025 |

**Pricing:**
- Input: $5 / MTok
- Output: $25 / MTok
- Batch Input: $2.50 / MTok
- Batch Output: $12.50 / MTok

---

### Claude Sonnet 4.5

**Description:** Our best combination of speed and intelligence

| Attribute | Value |
|-----------|-------|
| **Claude API ID** | `claude-sonnet-4-5-20250929` |
| **Claude API Alias** | `claude-sonnet-4-5` |
| **AWS Bedrock ID** | `anthropic.claude-sonnet-4-5-20250929-v1:0` |
| **GCP Vertex AI ID** | `claude-sonnet-4-5@20250929` |
| **Context Window** | 200K tokens / 1M tokens (beta) |
| **Max Output** | 64K tokens |
| **Extended Thinking** | Yes |
| **Adaptive Thinking** | No |
| **Priority Tier** | Yes |
| **Comparative Latency** | Fast |
| **Training Data Cutoff** | July 2025 |
| **Reliable Knowledge Cutoff** | January 2025 |

**Pricing:**
- Input: $3 / MTok
- Output: $15 / MTok
- 5m Cache Writes: $3.75 / MTok
- 1h Cache Writes: $6 / MTok
- Cache Hits & Refreshes: $0.30 / MTok
- Batch Input: $1.50 / MTok
- Batch Output: $7.50 / MTok

**Long Context Pricing (>200K tokens):**
- Input: $6 / MTok
- Output: $22.50 / MTok

---

### Claude Haiku 4.5

**Description:** Our fastest model with near-frontier intelligence

| Attribute | Value |
|-----------|-------|
| **Claude API ID** | `claude-haiku-4-5-20251001` |
| **Claude API Alias** | `claude-haiku-4-5` |
| **AWS Bedrock ID** | `anthropic.claude-haiku-4-5-20251001-v1:0` |
| **GCP Vertex AI ID** | `claude-haiku-4-5@20251001` |
| **Context Window** | 200K tokens |
| **Max Output** | 64K tokens |
| **Extended Thinking** | Yes |
| **Adaptive Thinking** | No |
| **Priority Tier** | Yes |
| **Comparative Latency** | Fastest |
| **Training Data Cutoff** | July 2025 |
| **Reliable Knowledge Cutoff** | February 2025 |

**Pricing:**
- Input: $1 / MTok
- Output: $5 / MTok
- 5m Cache Writes: $1.25 / MTok
- 1h Cache Writes: $2 / MTok
- Cache Hits & Refreshes: $0.10 / MTok
- Batch Input: $0.50 / MTok
- Batch Output: $2.50 / MTok

---

## Legacy Claude 3.x Models

### Claude 3.7 Sonnet (Deprecated)

> **Status:** Deprecated as of October 28, 2025  
> **Retirement Date:** February 19, 2026  
> **Replacement:** `claude-opus-4-6`

| Attribute | Value |
|-----------|-------|
| **Claude API ID** | `claude-3-7-sonnet-20250219` |
| **Context Window** | 200K tokens |
| **Extended Thinking** | Yes |

**Pricing (until retirement):**
- Input: $3 / MTok
- Output: $15 / MTok
- Batch Input: $1.50 / MTok
- Batch Output: $7.50 / MTok

---

### Claude 3.5 Opus

> **Note:** Claude 3.5 Opus was never released. Anthropic's Opus series skipped from Claude 3 Opus directly to the Claude 4 Opus series. There is no `claude-3-5-opus` model in the Anthropic API.
>
> For the most powerful model in the Claude 3.x era, use **Claude 3 Opus** (now deprecated, retiring January 5, 2026).

### Claude 3 Opus (Deprecated)

> **Status:** Deprecated as of June 30, 2025  
> **Retirement Date:** January 5, 2026  
> **Replacement:** `claude-opus-4-6`

| Attribute | Value |
|-----------|-------|
| **Claude API ID** | `claude-3-opus-20240229` |
| **Context Window** | 200K tokens |

---

## Claude Code

### Overview

Claude Code is Anthropic's agentic coding tool that integrates Claude models into development workflows. It is a **product/application** built on top of Claude models, not a separate model itself.

### Key Characteristics

- **Type:** AI-powered coding assistant/IDE integration
- **Base Models:** Uses Claude Opus 4.6 and other Claude models via API
- **Availability:** Available through Claude Console and API
- **Features:**
  - Natural language code editing
  - Terminal/command execution
  - File system operations
  - Code analysis and refactoring
  - Git integration

### Pricing

Claude Code usage is billed at standard Claude API rates based on the underlying model used. There is no additional Claude Code-specific pricing - you pay for the tokens consumed by the model during code generation and analysis.

### API Access

Claude Code functionality can be accessed programmatically through:
- **Claude Code Analytics API:** For tracking usage and performance metrics
- **Agent SDK:** For building custom agentic applications

---

## Context Window Details

### 1M Token Context Window (Beta)

Claude Opus 4.6 and Sonnet 4.5 support a 1M token context window when using the `context-1m-2025-08-07` beta header.

**Requirements:**
- Available for organizations in usage tier 4
- Organizations with custom rate limits
- Long context pricing applies to requests exceeding 200K tokens

---

## Rate Limits and Tiers

| Tier | Description |
|------|-------------|
| **Tier 1** | Entry-level usage with basic limits |
| **Tier 2** | Increased limits for growing applications |
| **Tier 3** | Higher limits for established applications |
| **Tier 4** | Maximum standard limits + 1M context access |
| **Enterprise** | Custom limits available |

---

## Additional Features Pricing

### Fast Mode (Research Preview)

Available on Claude Opus 4.6:

| Context | Input | Output |
|---------|-------|--------|
| ≤ 200K tokens | $30 / MTok | $150 / MTok |
| > 200K tokens | $60 / MTok | $225 / MTok |

### Data Residency

US-only inference via `inference_geo` parameter incurs 1.1x multiplier on all pricing.

---

---

## Moonshot Kimi Models

Moonshot AI (月之暗面) is a Beijing-based AI startup founded in 2023, developing the Kimi family of large language models.

### Model Versions

#### Kimi K2.5 (Latest Flagship - January 2025)

| Attribute | Value |
|-----------|-------|
| **API ID** | `kimi-k2-5` |
| **Architecture** | Mixture-of-Experts (MoE) |
| **Parameters** | 1 trillion (32 billion active per inference) |
| **Context Window** | 256,000 tokens (262K) |
| **Default Temperature** | 1.0 |
| **Default Top-p** | 0.95 |
| **Type** | Open-weight, native multimodal agentic model |
| **Training** | Continual pretraining on ~15 trillion mixed visual and text tokens atop Kimi-K2-Base |

**Capabilities:**
- Native multimodal (vision + language understanding)
- Advanced agentic capabilities with agent swarm workflows
- Instant mode and thinking mode support
- Visual coding and production-ready code generation
- Full-Parameter RL tuning for state-of-the-art performance
- Benchmark dominance across agents, coding, image, and video tasks

---

#### Kimi K2 (2024-2025)

| Attribute | Value |
|-----------|-------|
| **API ID** | `kimi-k2` |
| **Architecture** | MoE, 1T parameters (32B active) |
| **Context Window** | 128K tokens (Instruct) / 256K tokens (newer variants) |
| **Type** | Open-weight with Base and Instruct variants |

**Variants:**
- **Kimi-K2-Base**: Foundation model for researchers and custom fine-tuning
- **Kimi-K2-Instruct**: Post-trained model for general-purpose chat and agentic experiences (reflex-grade, no long thinking)

---

#### Kimi K1.5 (January 2025)

| Attribute | Value |
|-----------|-------|
| **Release** | January 2025 |
| **Context Length** | 128,000 tokens |
| **Type** | Reasoning model with long-context scaling |
| **Key Feature** | RL context window scaled to 128K with continued performance improvements |

**Capabilities:**
- Multi-turn conversations
- Coding assistance
- Long-context document processing
- Upgraded chatbot capabilities

---

#### Kimi Lite

- **Type**: Lightweight variant for faster inference
- **Use Case**: Latency-sensitive applications
- Optimized for speed over maximum capability

---

### API Platform Information

| Feature | Details |
|---------|---------|
| **Platform URL** | https://platform.moonshot.ai/ |
| **Base URL** | OpenAI-compatible API format |
| **Documentation** | https://platform.moonshot.ai/docs/ |

**Key Features:**
- OpenAI-compatible API endpoints for easy migration
- Tool Calling support for agent workflows
- File upload endpoints for context augmentation
- Rate limiting management
- Multi-region alternatives available

---

### Model Comparison Table

| Model | Context | Parameters | Multimodal | Agentic | Open-Weight |
|-------|---------|------------|------------|---------|-------------|
| Kimi K2.5 | 256K | 1T (32B active) | Yes | Yes | Yes |
| Kimi K2 | 128K-256K | 1T (32B active) | Limited | Yes | Yes |
| Kimi K1.5 | 128K | Not disclosed | No | No | Partial |
| Kimi Lite | TBD | Reduced | No | Limited | TBD |

---

### Integration Notes

1. **API Compatibility**: Uses OpenAI-compatible format - easy migration path
2. **Authentication**: API key required from Moonshot platform
3. **Long Context**: 256K window enables entire codebase processing
4. **Tool Calling**: Supports function calling for agent workflows
5. **File Handling**: File upload support for enhanced context

---

## Zhipu AI GLM Models

### Overview

GLM (General Language Model) is a family of large language models developed by Zhipu AI (智谱AI), a Beijing-based AI company founded by researchers from Tsinghua University. The GLM-4 series represents their latest generation of foundation models with variants optimized for different use cases including high intelligence, cost-efficiency, and multimodal capabilities.

**Platform**: [BigModel Open Platform](https://bigmodel.cn/)  
**API Base URL**: `https://open.bigmodel.cn/api/paas/v4`  
**Documentation**: [https://docs.bigmodel.cn](https://docs.bigmodel.cn)

---

## GLM-4 Text Models

### GLM-4-Plus

**Description:** High-intelligence flagship language model with top-tier performance in language understanding, logical reasoning, instruction following, and long-text processing.

| Attribute | Value |
|-----------|-------|
| **Model ID** | `glm-4-plus` |
| **Context Window** | 128,000 tokens |
| **Max Output Tokens** | 4,096 |
| **Positioning** | High Performance |
| **Input Modality** | Text |
| **Output Modality** | Text |

**Pricing:**
- 5 CNY / million tokens (≈ $0.70 / MTok)

**Capabilities:**
- Superior language understanding and logical reasoning
- Excellent instruction following
- Advanced long-text processing with optimized short/long text data mixing
- Strong performance on mathematical and coding tasks (via PPO training)
- Competitive with GPT-4o and Claude 3.5 Sonnet on most benchmarks

**Benchmark Comparison:**
| Model | AlignBench | MMLU | MATH | GPQA | LCB | NCB | IFEval |
|-------|------------|------|------|------|-----|-----|--------|
| GLM-4-Plus | 83.2 | 86.8 | 74.2 | 50.7 | 45.8 | 50.4 | 79.5 |
| GPT-4o | 83.8 | 88.7 | 76.6 | 51.0 | 45.5 | 52.3 | 81.9 |
| Claude 3.5 Sonnet | 80.7 | 88.3 | 71.1 | 56.4 | 49.8 | 53.1 | 80.6 |

**Supported Features:**
- Streaming output
- Function calling / Tool use
- Context caching
- Structured output (JSON)
- MCP (Model Context Protocol) tool integration
- Web search integration

**Recommended Use Cases:**
- Complex translation tasks (including multilingual, slang, emojis)
- Intelligent data classification and labeling
- File information extraction with 93%+ accuracy
- Creative copywriting and marketing content
- Risk assessment reports with industry data analysis
- Intelligent travel planning

**Rate Limits (Concurrent Requests):**
| Tier | V0 | V1 | V2 | V3 |
|------|-----|-----|-----|-----|
| Concurrency | 50 | 100 | 300 | 500 |

---

### GLM-4-Air (GLM-4-Air-250414)

**Description:** Base language model optimized for fast execution of complex tasks with enhanced capabilities in tool calling, web search, and code generation.

| Attribute | Value |
|-----------|-------|
| **Model ID** | `glm-4-air-250414` |
| **Alias** | `glm-4-air` |
| **Context Window** | 128,000 tokens |
| **Max Output Tokens** | 16,384 |
| **Positioning** | High Cost-Performance |
| **Input Modality** | Text |
| **Output Modality** | Text |

**Pricing:**
- 0.5 CNY / million tokens (≈ $0.07 / MTok)

**Capabilities:**
- Pre-trained on 15T high-quality tokens with rich reasoning synthetic data
- Enhanced instruction following and engineering code generation
- Optimized for agentic tasks (tool calling, function calling)
- Performance comparable to larger models, approaching GPT-4o on certain dimensions

**Supported Features:**
- Streaming output
- Function calling / Tool use
- Context caching
- Structured output
- MCP integration

**Rate Limits (Concurrent Requests):**
| Tier | V0 | V1 | V2 | V3 |
|------|-----|-----|-----|-----|
| Concurrency | 30 | 40 | 50 | 60 |

---

### GLM-4-AirX

**Description:** High-speed version of GLM-4-Air-250414 designed for low-latency, high-concurrency scenarios.

| Attribute | Value |
|-----------|-------|
| **Model ID** | `glm-4-airx` |
| **Context Window** | 128,000 tokens |
| **Max Output Tokens** | 16,384 |
| **Positioning** | Extreme Speed |
| **Input Modality** | Text |
| **Output Modality** | Text |

**Pricing:**
- 10 CNY / million tokens (≈ $1.40 / MTok)

**Capabilities:**
- Same performance as GLM-4-Air-250414
- Faster inference speed through optimized prefill and decoder autoregressive output
- Technical iteration on base model components
- Lower latency for real-time applications

**Rate Limits (Concurrent Requests):**
| Tier | V0 | V1 | V2 | V3 |
|------|-----|-----|-----|-----|
| Concurrency | 5 | 30 | 40 | 50 |

---

### GLM-4-Flash (GLM-4-Flash-250414)

**Description:** Free language model offering high-speed inference, strong concurrency guarantees, and extreme cost-performance. Enhanced version of GLM-4-Flash.

| Attribute | Value |
|-----------|-------|
| **Model ID** | `glm-4-flash-250414` |
| **Alias** | `glm-4-flash` |
| **Context Window** | 128,000 tokens |
| **Max Output Tokens** | 16,384 |
| **Positioning** | Free / Cost-Optimized |
| **Price** | Free |
| **Input Modality** | Text |
| **Output Modality** | Text |

**Capabilities:**
- 128K context window (equivalent to 300-page book processing)
- Millisecond-level complex logic processing
- "Instant input, instant answer" experience
- 26-language multilingual support
- External tool calling and web search integration

**Supported Features:**
- Streaming output
- Function calling
- Context caching
- Structured output
- Web search integration

**Rate Limits (Concurrent Requests):**
| Tier | V0 | V1 | V2 | V3 |
|------|-----|-----|-----|-----|
| Concurrency | 200 | 1000 | 2000 | 3000 |

---

### GLM-4-FlashX (GLM-4-FlashX-250414)

**Description:** Enhanced version of GLM-4-Flash with faster inference speed and stronger concurrency guarantees.

| Attribute | Value |
|-----------|-------|
| **Model ID** | `glm-4-flashx-250414` |
| **Context Window** | 128,000 tokens |
| **Max Output Tokens** | 16,384 |
| **Positioning** | High-Speed / Low-Cost |
| **Input Modality** | Text |
| **Output Modality** | Text |

**Pricing:**
- 0.1 CNY / million tokens (≈ $0.014 / MTok)

**Capabilities:**
- Ultra-fast inference speed
- Stronger concurrency guarantees
- Excellent for real-time web retrieval and long-context processing
- Strong multilingual support

**Rate Limits (Concurrent Requests):**
| Tier | V0 | V1 | V2 | V3 |
|------|-----|-----|-----|-----|
| Concurrency | 100 | 150 | 200 | 300 |

---

## GLM-4 Vision Models (GLM-4V)

### GLM-4V-Plus

**Description:** Advanced vision-language model for image understanding, document analysis, and visual reasoning.

| Attribute | Value |
|-----------|-------|
| **Model ID** | `glm-4v-plus` |
| **Context Window** | 8,000-128,000 tokens |
| **Input Modality** | Text + Images |
| **Output Modality** | Text |
| **Positioning** | High-Performance Vision |

**Capabilities:**
- High-accuracy image understanding and description
- Document and chart analysis
- Visual question answering
- Multi-image comparison and analysis
- OCR and text extraction from images

**Note:** GLM-4V models support various image formats and can handle multiple images in a single conversation context.

---

### GLM-4V

**Description:** Base vision-language model for general image understanding tasks.

| Attribute | Value |
|-----------|-------|
| **Model ID** | `glm-4v` |
| **Context Window** | 8,000-128,000 tokens |
| **Input Modality** | Text + Images |
| **Output Modality** | Text |
| **Positioning** | General Vision |

**Capabilities:**
- Image captioning and description
- Object recognition
- Scene understanding
- Visual reasoning
- Basic document analysis

---

## GLM-4 Model Comparison Summary

| Model | Context | Input Price | Output Price | Best For | Speed |
|-------|---------|-------------|--------------|----------|-------|
| GLM-4-Plus | 128K | 5¥/MTok | 5¥/MTok | High-intelligence tasks, complex reasoning | Medium |
| GLM-4-Air | 128K | 0.5¥/MTok | 0.5¥/MTok | Cost-efficient agent tasks, coding | Fast |
| GLM-4-AirX | 128K | 10¥/MTok | 10¥/MTok | Low-latency, high-concurrency applications | Fastest |
| GLM-4-Flash | 128K | Free | Free | Entry-level, prototyping, free tier | Fast |
| GLM-4-FlashX | 128K | 0.1¥/MTok | 0.1¥/MTok | High-speed, budget-friendly production | Fast |
| GLM-4V-Plus | 128K | Variable | Variable | Advanced image understanding | Medium |
| GLM-4V | 128K | Variable | Variable | General vision tasks | Medium |

*\*Prices in Chinese Yuan (CNY). 1 CNY ≈ $0.14 USD*

---

## User Tier System (V0-V3)

GLM models use a tier-based rate limiting system:

| Tier | Description | Typical Limits |
|------|-------------|----------------|
| **V0** | Entry/free tier | Base concurrency limits |
| **V1** | Starter tier | Increased concurrency |
| **V2** | Professional tier | Higher concurrency |
| **V3** | Enterprise tier | Maximum concurrency |

---

## Supported Capabilities (All GLM-4 Models)

| Capability | GLM-4-Plus | GLM-4-Air/X | GLM-4-Flash/X | GLM-4V |
|------------|:----------:|:-----------:|:-------------:|:------:|
| Streaming | ✅ | ✅ | ✅ | ✅ |
| Function Calling | ✅ | ✅ | ✅ | ✅ |
| Tool Use | ✅ | ✅ | ✅ | ✅ |
| Context Caching | ✅ | ✅ | ✅ | ✅ |
| Structured Output | ✅ | ✅ | ✅ | ✅ |
| Web Search | ✅ | ✅ | ✅ | ❌ |
| MCP Protocol | ✅ | ✅ | ✅ | ❌ |
| Vision | ❌ | ❌ | ❌ | ✅ |

---

## Integration Notes

1. **API Compatibility**: OpenAI-compatible REST API format
2. **Authentication**: API key from [BigModel Console](https://bigmodel.cn/console/overview)
3. **SDKs Available**: Python (`zai-sdk`), Java, cURL
4. **Streaming**: Real-time streaming responses supported
5. **Rate Limiting**: Tier-based concurrent request limits
6. **Context Caching**: Intelligent caching for long conversations

---

## References

- [Anthropic Models Overview](https://docs.anthropic.com/en/docs/about-claude/models)
- [Anthropic Pricing](https://docs.anthropic.com/en/docs/about-claude/pricing)
- [Model Deprecations](https://docs.anthropic.com/en/docs/about-claude/model-deprecations)
- [Context Windows](https://docs.anthropic.com/en/docs/build-with-claude/context-windows)
- [Moonshot AI Platform](https://platform.moonshot.ai/docs/overview)
- [Kimi K2.5 GitHub](https://github.com/MoonshotAI/Kimi-K2.5)
- [Kimi K2.5 Hugging Face](https://huggingface.co/moonshotai/Kimi-K2.5)
- [Zhipu AI BigModel Documentation](https://docs.bigmodel.cn/cn/guide/models/text/glm-4)
- [BigModel Platform](https://bigmodel.cn/)
- [BigModel Pricing](https://bigmodel.cn/pricing)

---

*Last Updated: Based on Anthropic, Moonshot, and Zhipu AI documentation as of current date*
