# KV Cache Memory Calculations for iPad Pro M4 (16GB RAM)
## Date: February 16, 2026

---

## 1. Verified Model Architectures (from HuggingFace config.json)

### Llama 3.1 8B / Llama 3 8B
- Source: huggingface.co/unsloth/llama-3-8b/raw/main/config.json
- num_hidden_layers: 32
- num_key_value_heads: 8 (GQA, 32 query heads)
- head_dim: 128
- hidden_size: 4096

### Qwen3 8B
- Source: huggingface.co/Qwen/Qwen3-8B/raw/main/config.json
- num_hidden_layers: 36
- num_key_value_heads: 8 (GQA, 32 query heads)
- head_dim: 128
- hidden_size: 4096

### Llama 3.2 3B
- Source: huggingface.co/unsloth/Llama-3.2-3B/raw/main/config.json
- num_hidden_layers: 28
- num_key_value_heads: 8 (GQA, 24 query heads)
- head_dim: 128
- hidden_size: 3072

### Qwen3 4B
- Source: huggingface.co/Qwen/Qwen3-4B/raw/main/config.json
- num_hidden_layers: 36
- num_key_value_heads: 8 (GQA, 32 query heads)
- head_dim: 128
- hidden_size: 2560

---

## 2. KV Cache Formula

```
KV Cache Memory = 2 × num_layers × batch_size × seq_len × num_kv_heads × head_dim × bytes_per_element
```

For batch_size=1, the **bytes per token** (constant):
```
bytes_per_token = 2 × num_layers × num_kv_heads × head_dim × bytes_per_element
```

## 3. Bytes Per Token for Each Model

### FP16 KV Cache (2 bytes per element) — Default

| Model | Formula | Bytes/Token | KB/Token |
|-------|---------|-------------|----------|
| Llama 3.1 8B | 2 × 32 × 8 × 128 × 2 | 131,072 | **128 KB** |
| Qwen3 8B | 2 × 36 × 8 × 128 × 2 | 147,456 | **144 KB** |
| Llama 3.2 3B | 2 × 28 × 8 × 128 × 2 | 114,688 | **112 KB** |
| Qwen3 4B | 2 × 36 × 8 × 128 × 2 | 147,456 | **144 KB** |

Note: Qwen3 4B has the SAME KV cache per token as Qwen3 8B because they share
identical num_layers (36), num_kv_heads (8), and head_dim (128). The size difference
is in hidden_size and intermediate_size which don't affect KV cache.

### Q8_0 KV Cache (1 byte per element) — With KV quantization

| Model | Bytes/Token | KB/Token |
|-------|-------------|----------|
| Llama 3.1 8B | 65,536 | **64 KB** |
| Qwen3 8B | 73,728 | **72 KB** |
| Llama 3.2 3B | 57,344 | **56 KB** |
| Qwen3 4B | 73,728 | **72 KB** |

### Q4_0 KV Cache (0.5 bytes per element) — Aggressive KV quantization

| Model | Bytes/Token | KB/Token |
|-------|-------------|----------|
| Llama 3.1 8B | 32,768 | **32 KB** |
| Qwen3 8B | 36,864 | **36 KB** |
| Llama 3.2 3B | 28,672 | **28 KB** |
| Qwen3 4B | 36,864 | **36 KB** |

---

## 4. KV Cache Sizes at Standard Context Lengths

### Llama 3.1 8B

| Context | FP16 KV | Q8_0 KV | Q4_0 KV |
|---------|---------|---------|----------|
| 4K (4,096) | 512 MB | 256 MB | 128 MB |
| 8K (8,192) | 1.0 GB | 512 MB | 256 MB |
| 16K (16,384) | 2.0 GB | 1.0 GB | 512 MB |
| 32K (32,768) | 4.0 GB | 2.0 GB | 1.0 GB |
| 64K (65,536) | 8.0 GB | 4.0 GB | 2.0 GB |
| 128K (131,072) | 16.0 GB | 8.0 GB | 4.0 GB |

### Qwen3 8B

| Context | FP16 KV | Q8_0 KV | Q4_0 KV |
|---------|---------|---------|----------|
| 4K (4,096) | 576 MB | 288 MB | 144 MB |
| 8K (8,192) | 1.125 GB | 576 MB | 288 MB |
| 16K (16,384) | 2.25 GB | 1.125 GB | 576 MB |
| 32K (32,768) | 4.5 GB | 2.25 GB | 1.125 GB |
| 64K (65,536) | 9.0 GB | 4.5 GB | 2.25 GB |
| 128K (131,072) | 18.0 GB | 9.0 GB | 4.5 GB |

### Llama 3.2 3B

| Context | FP16 KV | Q8_0 KV | Q4_0 KV |
|---------|---------|---------|----------|
| 4K (4,096) | 448 MB | 224 MB | 112 MB |
| 8K (8,192) | 896 MB | 448 MB | 224 MB |
| 16K (16,384) | 1.75 GB | 896 MB | 448 MB |
| 32K (32,768) | 3.5 GB | 1.75 GB | 896 MB |
| 64K (65,536) | 7.0 GB | 3.5 GB | 1.75 GB |
| 128K (131,072) | 14.0 GB | 7.0 GB | 3.5 GB |

### Qwen3 4B (same KV as Qwen3 8B!)

| Context | FP16 KV | Q8_0 KV | Q4_0 KV |
|---------|---------|---------|----------|
| 4K (4,096) | 576 MB | 288 MB | 144 MB |
| 8K (8,192) | 1.125 GB | 576 MB | 288 MB |
| 16K (16,384) | 2.25 GB | 1.125 GB | 576 MB |
| 32K (32,768) | 4.5 GB | 2.25 GB | 1.125 GB |
| 64K (65,536) | 9.0 GB | 4.5 GB | 2.25 GB |
| 128K (131,072) | 18.0 GB | 9.0 GB | 4.5 GB |

---

## 5. iPad Pro M4 16GB Memory Budget

### System Memory Constraints
- Total RAM: 16 GB
- iPadOS + system services: ~3-4 GB
- With extended memory entitlement: apps can use up to ~12 GB
- Inference engine overhead (llama.cpp/MLX runtime, activations, buffers): ~0.5-1 GB

### Realistic Available Memory Tiers:
- **Optimistic**: 12 GB total for app → ~11 GB for model + KV cache
- **Realistic**: ~10-11 GB for model + KV cache
- **Conservative**: ~9 GB for model + KV cache (leaving safety margin)

### Model Weight Sizes at Q4_K_M Quantization:
- Llama 3.1 8B Q4_K_M: ~4.9 GB
- Qwen3 8B Q4_K_M: ~5.0 GB
- Llama 3.2 3B Q4_K_M: ~2.0 GB
- Qwen3 4B Q4_K_M: ~2.5 GB

---

## 6. MAXIMUM CONTEXT LENGTHS ON iPad Pro M4 16GB

### Using 10GB available budget (realistic, with overhead accounted for)

### 7-8B Models (Q4 weights ≈ 5GB → ~5GB remaining for KV cache)

| Model | KV Type | Available | KB/Token | Max Tokens | Max Context |
|-------|---------|-----------|----------|------------|-------------|
| Llama 3.1 8B | FP16 | 5 GB | 128 | 40,960 | **~40K** |
| Llama 3.1 8B | Q8_0 | 5 GB | 64 | 81,920 | **~80K** |
| Llama 3.1 8B | Q4_0 | 5 GB | 32 | 163,840 | **~160K** |
| Qwen3 8B | FP16 | 5 GB | 144 | 36,408 | **~35K** |
| Qwen3 8B | Q8_0 | 5 GB | 72 | 72,817 | **~71K** |
| Qwen3 8B | Q4_0 | 5 GB | 36 | 145,635 | **~142K** |

### 7-8B Models with 7GB for KV (optimistic, 12GB app budget)

| Model | KV Type | Available | Max Tokens | Max Context |
|-------|---------|-----------|------------|-------------|
| Llama 3.1 8B | FP16 | 7 GB | 57,344 | **~56K** |
| Llama 3.1 8B | Q8_0 | 7 GB | 114,688 | **~112K** |
| Llama 3.1 8B | Q4_0 | 7 GB | 229,376 | **~128K** (model limit) |
| Qwen3 8B | FP16 | 7 GB | 50,972 | **~49K** |
| Qwen3 8B | Q8_0 | 7 GB | 101,944 | **~99K** |
| Qwen3 8B | Q4_0 | 7 GB | 203,889 | **~131K** (model native max 32K, YaRN 128K) |

### 3-4B Models (Q4 weights ≈ 2-2.5GB → ~7.5-8GB remaining for KV)

#### Llama 3.2 3B (Q4 weights ~2GB → ~8GB for KV, realistic budget)

| KV Type | Available | KB/Token | Max Tokens | Max Context |
|---------|-----------|----------|------------|-------------|
| FP16 | 8 GB | 112 | 74,898 | **~73K** |
| Q8_0 | 8 GB | 56 | 149,796 | **~128K** (model limit) |
| Q4_0 | 8 GB | 28 | 299,593 | **~128K** (model limit, memory to spare) |

#### Qwen3 4B (Q4 weights ~2.5GB → ~7.5GB for KV, realistic budget)

| KV Type | Available | KB/Token | Max Tokens | Max Context |
|---------|-----------|----------|------------|-------------|
| FP16 | 7.5 GB | 144 | 54,613 | **~53K** |
| Q8_0 | 7.5 GB | 72 | 109,226 | **~106K** |
| Q4_0 | 7.5 GB | 36 | 218,453 | **~128K+** |

---

## 7. KEY FINDINGS & PRACTICAL RECOMMENDATIONS

### For iPad Pro M4 16GB:

#### 8B Models (Llama 3.1 8B / Qwen3 8B at Q4_K_M):
- **FP16 KV cache**: Realistically **32K-40K context** (safe), up to ~56K optimistic
- **Q8_0 KV cache**: Realistically **64K-80K context**, up to ~112K optimistic
- **Q4_0 KV cache**: Can reach **128K** (model's full context) with memory to spare
- ⚠️ Qwen3 8B uses 12.5% more KV memory than Llama 3.1 8B (36 vs 32 layers)

#### 3B Models (Llama 3.2 3B at Q4_K_M):
- **FP16 KV cache**: Comfortably **64K+ context**
- **Q8_0 KV cache**: Full **128K context** easily
- **Q4_0 KV cache**: Full **128K context** with ~4.5GB to spare

#### Surprising Finding - Qwen3 4B:
- Despite being a smaller model (saves ~2.5GB on weights vs 8B),
  the KV cache per token is IDENTICAL to Qwen3 8B (same layers, heads, head_dim)
- The only savings come from smaller model weights, not KV efficiency
- Llama 3.2 3B is more KV-efficient: 112 KB/token vs 144 KB/token for Qwen3 4B

### Quick Reference: KV Cache Per Token

| Model | FP16 | Q8 | Q4 |
|-------|------|-----|-----|
| Llama 3.1 8B | 128 KB | 64 KB | 32 KB |
| Qwen3 8B | 144 KB | 72 KB | 36 KB |
| Llama 3.2 3B | 112 KB | 56 KB | 28 KB |
| Qwen3 4B | 144 KB | 72 KB | 36 KB |

### Quick Reference: Memory Budget Rule of Thumb

Total Memory Needed = Model_Weights + KV_Cache + Overhead(~1GB)

On iPad Pro M4 16GB, available ≈ 10-12 GB for everything.

---

## 8. SOURCES

- Model configs: HuggingFace config.json for each model (verified by direct fetch)
- KV cache formula: mbrenndoerfer.com/writing/kv-cache-memory-calculation-llm-inference-gpu
- iPad memory limits: Apple developer docs, developer forums, user reports
  - Extended memory entitlement allows up to ~12GB on 16GB devices
  - Default limit without entitlement: ~5GB
- KV cache quantization: llama.cpp supports Q8_0 and Q4_0 KV cache quantization
  - Reddit tests confirm ~50% savings with Q8, ~75% savings with Q4
- Cross-validated with: techtactician.com, skymod.tech, kolosal.ai blog
