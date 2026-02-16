# Agent: research-nanbeige-mlx
**Status:** done
**Tokens:** 2,573
**Cost:** $0.0000
**Time:** 2026-02-16T20:42:43.259Z

## Task
Search the web for 'Nanbeige4.1 mlx-community' and check https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit - look at the model's tokenizer config, what tokenizer type it uses, and whether there are any known issues loading it with swift-transformers. Also check if there's a different quantized version that works.

## Response
I'll investigate this systematically. Let me start by searching the web and fetching the model page.





---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit   
| ✓ | ⏱: 1.03s 
[SCRAPE].. ◆ https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit   
| ✓ | ⏱: 0.01s 
[COMPLETE] ● https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit   
| ✓ | ⏱: 1.05s 
[![Hugging Face's logo](https://huggingface.co/front/assets/huggingface_logo-noborder.svg) Hugging Face](https://huggingface.co/)
  * [](https://huggingface.co/models)
  * [](https://huggingface.co/datasets)
  * [](https://huggingface.co/spaces)
  * [](https://huggingface.co/docs)
  * [](https://huggingface.co/enterprise)
  * [Pricing](https://huggingface.co/pricing)
  * * * *
  * [Log In](https://huggingface.co/login)
  * [Sign Up](https://huggingface.co/join)


# 
[ ![](https://cdn-avatars.huggingface.co/v1/production/uploads/623c830997ddced06d78699b/3qTjC7d3YFCJTwpxd2noq.png) ](https://huggingface.co/mlx-community)
[mlx-community](https://huggingface.co/mlx-community)
/
[Nanbeige4.1-3B-heretic-4bit](https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit)
like 0
Follow
![](https://cdn-avatars.huggingface.co/v1/production/uploads/623c830997ddced06d78699b/3qTjC7d3YFCJTwpxd2noq.png) MLX Community 8.73k
[ Text Generation ](https://huggingface.co/models?pipeline_tag=text-generation)[ MLX ](https://huggingface.co/models?library=mlx)[ Safetensors ](https://huggingface.co/models?library=safetensors)[ English ](https://huggingface.co/models?language=en)[ Chinese ](https://huggingface.co/models?language=zh)[ llama ](https://huggingface.co/models?other=llama)[ llm ](https://huggingface.co/models?other=llm)[ nanbeige ](https://huggingface.co/models?other=nanbeige)[ heretic ](https://huggingface.co/models?other=heretic)[ uncensored ](https://huggingface.co/models?other=uncensored)[ decensored ](https://huggingface.co/models?other=decensored)[ abliterated ](https://huggingface.co/models?other=abliterated)[ conversational ](https://huggingface.co/models?other=conversational)[ 4-bit precision ](https://huggingface.co/models?other=4-bit)
License: apache-2.0
[](https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit)[Files Files and versions xet ](https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit/tree/main)[](https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit/discussions)
  * [mlx-community/Nanbeige4.1-3B-heretic-4bit](https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit#mlx-communitynanbeige41-3b-heretic-4bit "mlx-community/Nanbeige4.1-3B-heretic-4bit")
    * [Use with mlx](https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit#use-with-mlx "Use with mlx")


#  [ ](https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit#mlx-communitynanbeige41-3b-heretic-4bit) mlx-community/Nanbeige4.1-3B-heretic-4bit 
This model [mlx-community/Nanbeige4.1-3B-heretic-4bit](https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit) was converted to MLX format from [Daizee/Nanbeige4.1-3B-heretic](https://huggingface.co/Daizee/Nanbeige4.1-3B-heretic) using mlx-lm version **0.30.7**.
##  [ ](https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit#use-with-mlx) Use with mlx 
```
pip install mlx-lm

```

```
from mlx_lm import load, generate

model, tokenizer = load("mlx-community/Nanbeige4.1-3B-heretic-4bit")

prompt = "hello"

if tokenizer.chat_template is not None:
    messages = [{"role": "user", "content": prompt}]
    prompt = tokenizer.apply_chat_template(
        messages, add_generation_prompt=True, return_dict=False,
    )

response = generate(model, tokenizer, prompt=prompt, verbose=True)

```


Downloads last month
    4 
[](https://huggingface.co/docs/safetensors)
Model size
0.6B params
Tensor type
BF16 
·
U32 
·
Chat template
Files info
[](https://huggingface.co/docs/hub/mlx)
Hardware compatibility
[Log In ](https://huggingface.co/login) to add your hardware
4-bit
MLX 2.21 GB
Inference Providers [NEW ](https://huggingface.co/docs/inference-providers)
[Text Generation](https://huggingface.co/tasks/text-generation "Learn more about text-generation")
This model isn't deployed by any Inference Provider. [🙋 Ask for provider support](https://huggingface.co/spaces/huggingface/InferenceSupport/discussions/new?title=mlx-community/Nanbeige4.1-3B-heretic-4bit&description=React%20to%20this%20comment%20with%20an%20emoji%20to%20vote%20for%20%5Bmlx-community%2FNanbeige4.1-3B-heretic-4bit%5D\(%2Fmlx-community%2FNanbeige4.1-3B-heretic-4bit\)%20to%20be%20supported%20by%20Inference%20Providers.%0A%0A\(optional\)%20Which%20providers%20are%20you%20interested%20in%3F%20\(Novita%2C%20Hyperbolic%2C%20Together%E2%80%A6\)%0A)
##  mlx-community/Nanbeige4.1-3B-heretic-4bit [](https://huggingface.co/docs/hub/model-cards#specifying-a-base-model)
Base model
[Nanbeige/Nanbeige4-3B-Base](https://huggingface.co/Nanbeige/Nanbeige4-3B-Base)
[Daizee/Nanbeige4.1-3B-heretic](https://huggingface.co/Daizee/Nanbeige4.1-3B-heretic)
([2](https://huggingface.co/models?other=base_model:quantized:Daizee/Nanbeige4.1-3B-heretic)) 
this model 
Company
[TOS](https://huggingface.co/terms-of-service) [Privacy](https://huggingface.co/privacy) [About](https://huggingface.co/huggingface) [Careers](https://apply.workable.com/huggingface/) [](https://huggingface.co/)
Website
[Models](https://huggingface.co/models) [Datasets](https://huggingface.co/datasets) [Spaces](https://huggingface.co/spaces) [Pricing](https://huggingface.co/pricing) [Docs](https://huggingface.co/docs)


Now let me fetch the tokenizer config and other key files from this model.



---

## 🔧 TOOL RESULTS

[web_fetch]
🌐 https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit/raw/main/tokenizer_config.json

{
  "add_prefix_space": true,
  "backend": "tokenizers",
  "bos_token": "",
  "clean_up_tokenization_spaces": false,
  "eos_token": "",
  "is_local": true,
  "legacy": true,
  "max_length": null,
  "model_max_length": 1000000000000000019884624838656,
  "pad_to_multiple_of": null,
  "pad_token": "",
  "pad_token_type_id": 0,
  "padding_side": "left",
  "sp_model_kwargs": {},
  "spaces_between_special_tokens": false,
  "tokenizer_class": "TokenizersBackend",
  "tool_parser_type": "json_tools",
  "unk_token": "",
  "use_default_system_prompt": false
}


That's a very unusual `tokenizer_class`: `"TokenizersBackend"`. Let me investigate further - the config file, and search for swift-transformers compatibility issues.



---

## 🔧 TOOL RESULTS

[web_fetch]
🌐 https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit/raw/main/config.json

{
    "architectures": [
        "LlamaForCausalLM"
    ],
    "attention_bias": false,
    "attention_dropout": 0.0,
    "bos_token_id": 166100,
    "dtype": "bfloat16",
    "embd_pdrop": 0.0,
    "eos_token_id": 166101,
    "head_dim": 128,
    "hidden_act": "silu",
    "hidden_size": 2560,
    "initializer_range": 0.02,
    "intermediate_size": 10496,
    "max_position_embeddings": 262144,
    "mlp_bias": false,
    "model_type": "llama",
    "num_attention_heads": 20,
    "num_hidden_layers": 32,
    "num_key_value_heads": 4,
    "pad_token_id": 0,
    "pretraining_tp": 1,
    "quantization": {
        "group_size": 64,
        "bits": 4,
        "mode": "affine"
    },
    "quantization_config": {
        "group_size": 64,
        "bits": 4,
        "mode": "affine"
    },
    "resid_pdrop": 0.0,
    "rms_norm_eps": 1e-05,
    "rope_scaling": null,
    "rope_theta": 70000000,
    "tie_word_embeddings": false,
    "transformers_version": "4.57.3",
    "use_cache": true,
    "vocab_size": 166144
}




---

## 🔧 TOOL RESULTS

[web_search]
🔍 DuckDuckGo results for "swift-transformers TokenizersBackend tokenizer_class issue" (10 results):

1. **TokenizersBackend does not exist | mike bommarito**
   https://michaelbommarito.com/wiki/programming/languages/python/libraries/transformers-v5/tokenizersbackend-error/
   how to fix the &quot;Tokenizer class TokenizersBackend does not exist or is not currently imported&quot; error when loading models

2. **GitHub - huggingface/swift-transformers: Swift Package to implement a ...**
   https://github.com/huggingface/swift-transformers
   Swift Transformers is a community project and we welcome contributions. Please check out Issues tagged with good first issue if you are looking for a place to start! Before submitting a pull request, please ensure your code: Passes the test suite (swift test) Passes linting checks (swift format lint --recursive .) To format your code, run swift format -i --recursive ..

3. **Custom Tokenizers | huggingface/swift-transformers | DeepWiki**
   https://deepwiki.com/huggingface/swift-transformers/7.1-custom-tokenizers
   Custom Tokenizers Relevant source files This document provides a comprehensive guide for implementing custom tokenizer types in swift-transformers. It covers the protocol hierarchy, required method implementations, integration with the AutoTokenizer factory system, and best practices for creating production-ready tokenizers.

4. **Tokenizer - Hugging Face**
   https://huggingface.co/docs/transformers/v5.0.0rc1/en/main_classes/tokenizer
   A tokenizer is in charge of preparing the inputs for a model. The library contains tokenizers for all the models. Most of the tokenizers are available in two flavors: a full python implementation and a &quot;Fast&quot; implementation based on the Rust library 🤗 Tokenizers. The &quot;Fast&quot; implementations allows: a significant speed-up in particular when doing batched tokenization and additional ...

5. **tokenizer backend changes | mike bommarito**
   https://michaelbommarito.com/wiki/programming/languages/python/libraries/transformers-v5/tokenizers/
   unified tokenizer backend system eliminating the fast/slow distinction in transformers v5.0

6. **Model-Specific Tokenizers | huggingface/swift-transformers | DeepWiki**
   https://deepwiki.com/huggingface/swift-transformers/2.5-model-specific-tokenizers
   Tokenizer Class Registration and Lookup Model-specific tokenizers are registered in the PreTrainedTokenizerClasses.tokenizerClasses dictionary, which maps tokenizer class names from configuration files to Swift types.

7. **swift-transformers - Swift Package Index**
   https://swiftpackageindex.com/huggingface/swift-transformers
   Swift Transformers is a community project and we welcome contributions. Please check out Issues tagged with good first issue if you are looking for a place to start! Before submitting a pull request, please ensure your code: Passes the test suite (swift test) Passes linting checks (swift format lint --recursive .) To format your code, run swift format -i --recursive ..

8. **tokenizer suggestions · Issue #63 · huggingface/swift-transformers**
   https://github.com/huggingface/swift-transformers/issues/63
   Expose eos: +1, I saw your use in mlx-swift and it makes sense. I&#x27;ll open a PR soon. Also thought about the fallback tokenizer method but thought it was better to explicitly fail on unsupported tokenizers. A mechanism for the user to register overrides does look interesting!

9. **swift-transformers/Sources/Tokenizers/Tokenizer.swift at main ...**
   https://github.com/huggingface/swift-transformers/blob/main/Sources/Tokenizers/Tokenizer.swift
   /// /// This class provides a complete tokenizer implementation that can be initialized from /// Hugging Face Hub configuration files and supports all standard tokenization operations /// including chat template application, normalization, pre-tokenization, and post-processing. public class PreTrainedTokenizer: @unchecked Sendable, Tokenizer ...

10. **Tokenization in Transformers v5: Simpler, Clearer, and More Modular**
   https://huggingface.co/blog/tokenizers
   We&#x27;re on a journey to advance and democratize artificial intelligence through open source and open science.




---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://michaelbommarito.com/wiki/programming/languages/python/libraries/transformers-v5/tokenizersbackend-error/

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://michaelbommarito.com/wiki/programming/la...braries/transformers-v5/token
izersbackend-error/  | ✓ | ⏱: 0.85s 
[SCRAPE].. ◆ 
https://michaelbommarito.com/wiki/programming/la...braries/transformers-v5/token
izersbackend-error/  | ✓ | ⏱: 0.02s 
[COMPLETE] ● 
https://michaelbommarito.com/wiki/programming/la...braries/transformers-v5/token
izersbackend-error/  | ✓ | ⏱: 0.88s 
[Skip to main content](https://michaelbommarito.com/wiki/programming/languages/python/libraries/transformers-v5/tokenizersbackend-error/#main-content)
[ New book available: This Is Server Country ](https://servercountry.org/)
[ mjbommar@🌐:~$  mjb _ ](https://michaelbommarito.com/)
`⌘K`
[ mjbommar@🌐:~$  mjb _ ](https://michaelbommarito.com/)
`⌘K`
  * [ about ](https://michaelbommarito.com/about)
  * [ blog ](https://michaelbommarito.com/blog)
  * [ wiki ](https://michaelbommarito.com/wiki)
  * [ publications ](https://michaelbommarito.com/publications)
  * [ projects ](https://michaelbommarito.com/projects)
  * [ contact ](https://michaelbommarito.com/contact)


  * [ about ](https://michaelbommarito.com/about)
  * [ blog ](https://michaelbommarito.com/blog)
  * [ wiki ](https://michaelbommarito.com/wiki)
  * [ publications ](https://michaelbommarito.com/publications)
  * [ projects ](https://michaelbommarito.com/projects)
  * [ contact ](https://michaelbommarito.com/contact)


[ wiki ](https://michaelbommarito.com/wiki)[ programming ](https://michaelbommarito.com/wiki/programming)languagespythonlibrariestransformers-v5tokenizersbackend does not exist
#  tokenizersbackend does not exist 
published: December 8, 2025 •
[python](https://michaelbommarito.com/wiki/tag/python)[transformers](https://michaelbommarito.com/wiki/tag/transformers)[huggingface](https://michaelbommarito.com/wiki/tag/huggingface)[tokenizers](https://michaelbommarito.com/wiki/tag/tokenizers)[troubleshooting](https://michaelbommarito.com/wiki/tag/troubleshooting)[error](https://michaelbommarito.com/wiki/tag/error)
on this page 
  * [ why this happens ](https://michaelbommarito.com/wiki/programming/languages/python/libraries/transformers-v5/tokenizersbackend-error/#why-this-happens)
  * [ the fix ](https://michaelbommarito.com/wiki/programming/languages/python/libraries/transformers-v5/tokenizersbackend-error/#the-fix)
    * [ option 1: install the release candidate ](https://michaelbommarito.com/wiki/programming/languages/python/libraries/transformers-v5/tokenizersbackend-error/#option-1-install-the-release-candidate)
    * [ option 2: install from github (latest dev) ](https://michaelbommarito.com/wiki/programming/languages/python/libraries/transformers-v5/tokenizersbackend-error/#option-2-install-from-github-latest-dev)
  * [ verifying the fix ](https://michaelbommarito.com/wiki/programming/languages/python/libraries/transformers-v5/tokenizersbackend-error/#verifying-the-fix)
  * [ example: fill-mask pipeline ](https://michaelbommarito.com/wiki/programming/languages/python/libraries/transformers-v5/tokenizersbackend-error/#example-fill-mask-pipeline)
  * [ if you cannot upgrade ](https://michaelbommarito.com/wiki/programming/languages/python/libraries/transformers-v5/tokenizersbackend-error/#if-you-cannot-upgrade)
  * [ related errors ](https://michaelbommarito.com/wiki/programming/languages/python/libraries/transformers-v5/tokenizersbackend-error/#related-errors)
  * [ references ](https://michaelbommarito.com/wiki/programming/languages/python/libraries/transformers-v5/tokenizersbackend-error/#references)


##  on this page 
  * [ why this happens ](https://michaelbommarito.com/wiki/programming/languages/python/libraries/transformers-v5/tokenizersbackend-error/#why-this-happens)
  * [ the fix ](https://michaelbommarito.com/wiki/programming/languages/python/libraries/transformers-v5/tokenizersbackend-error/#the-fix)
    * [ option 1: install the release candidate ](https://michaelbommarito.com/wiki/programming/languages/python/libraries/transformers-v5/tokenizersbackend-error/#option-1-install-the-release-candidate)
    * [ option 2: install from github (latest dev) ](https://michaelbommarito.com/wiki/programming/languages/python/libraries/transformers-v5/tokenizersbackend-error/#option-2-install-from-github-latest-dev)
  * [ verifying the fix ](https://michaelbommarito.com/wiki/programming/languages/python/libraries/transformers-v5/tokenizersbackend-error/#verifying-the-fix)
  * [ example: fill-mask pipeline ](https://michaelbommarito.com/wiki/programming/languages/python/libraries/transformers-v5/tokenizersbackend-error/#example-fill-mask-pipeline)
  * [ if you cannot upgrade ](https://michaelbommarito.com/wiki/programming/languages/python/libraries/transformers-v5/tokenizersbackend-error/#if-you-cannot-upgrade)
  * [ related errors ](https://michaelbommarito.com/wiki/programming/languages/python/libraries/transformers-v5/tokenizersbackend-error/#related-errors)
  * [ references ](https://michaelbommarito.com/wiki/programming/languages/python/libraries/transformers-v5/tokenizersbackend-error/#references)


when loading a model from hugging face hub, you may encounter this error:
```
ValueError: Tokenizer class TokenizersBackend does not exist or is not currently imported.
```

## why this happens
this error occurs when a model was uploaded with **transformers v5.0** (which uses the new unified tokenizer backend system) but you’re trying




---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://deepwiki.com/huggingface/swift-transformers/2.5-model-specific-tokenizers

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://deepwiki.com/huggingface/swift-transformers/2.5-model-specific-tokenizer
s                    | ✓ | ⏱: 2.40s 
[SCRAPE].. ◆ 
https://deepwiki.com/huggingface/swift-transformers/2.5-model-specific-tokenizer
s                    | ✓ | ⏱: 0.03s 
[COMPLETE] ● 
https://deepwiki.com/huggingface/swift-transformers/2.5-model-specific-tokenizer
s                    | ✓ | ⏱: 2.43s 
[DeepWiki](https://deepwiki.com/)
[DeepWiki](https://deepwiki.com/)
[huggingface/swift-transformers ](https://github.com/huggingface/swift-transformers "Open repository")
Index your code with
Devin
Share
Last indexed: 25 November 2025 ([91286f](https://github.com/huggingface/swift-transformers/commits/91286f23))
  * [Overview](https://deepwiki.com/huggingface/swift-transformers/1-overview)
  * [Architecture](https://deepwiki.com/huggingface/swift-transformers/1.1-architecture)
  * [Installation and Setup](https://deepwiki.com/huggingface/swift-transformers/1.2-installation-and-setup)
  * [Quick Start Guide](https://deepwiki.com/huggingface/swift-transformers/1.3-quick-start-guide)
  * [Tokenizers](https://deepwiki.com/huggingface/swift-transformers/2-tokenizers)
  * [AutoTokenizer](https://deepwiki.com/huggingface/swift-transformers/2.1-autotokenizer)
  * [Chat Templates](https://deepwiki.com/huggingface/swift-transformers/2.2-chat-templates)
  * [Tokenizer Types](https://deepwiki.com/huggingface/swift-transformers/2.3-tokenizer-types)
  * [BPE Tokenizer](https://deepwiki.com/huggingface/swift-transformers/2.3.1-bpe-tokenizer)
  * [BERT Tokenizer](https://deepwiki.com/huggingface/swift-transformers/2.3.2-bert-tokenizer)
  * [Unigram Tokenizer](https://deepwiki.com/huggingface/swift-transformers/2.3.3-unigram-tokenizer)
  * [Tokenizer Components](https://deepwiki.com/huggingface/swift-transformers/2.4-tokenizer-components)
  * [Pre-Tokenizers](https://deepwiki.com/huggingface/swift-transformers/2.4.1-pre-tokenizers)
  * [Normalizers](https://deepwiki.com/huggingface/swift-transformers/2.4.2-normalizers)
  * [Post-Processors](https://deepwiki.com/huggingface/swift-transformers/2.4.3-post-processors)
  * [Decoders](https://deepwiki.com/huggingface/swift-transformers/2.4.4-decoders)
  * [Model-Specific Tokenizers](https://deepwiki.com/huggingface/swift-transformers/2.5-model-specific-tokenizers)
  * [Hub](https://deepwiki.com/huggingface/swift-transformers/3-hub)
  * [Hub API](https://deepwiki.com/huggingface/swift-transformers/3.1-hub-api)
  * [Downloader](https://deepwiki.com/huggingface/swift-transformers/3.2-downloader)
  * [Configuration Loading](https://deepwiki.com/huggingface/swift-transformers/3.3-configuration-loading)
  * [Caching and Metadata](https://deepwiki.com/huggingface/swift-transformers/3.4-caching-and-metadata)
  * [Error Handling](https://deepwiki.com/huggingface/swift-transformers/3.5-error-handling)
  * [Models](https://deepwiki.com/huggingface/swift-transformers/4-models)
  * [Language Model](https://deepwiki.com/huggingface/swift-transformers/4.1-language-model)
  * [Stateful KV Cache Models](https://deepwiki.com/huggingface/swift-transformers/4.2-stateful-kv-cache-models)
  * [CoreML Integration](https://deepwiki.com/huggingface/swift-transformers/4.3-coreml-integration)
  * [Model Configuration](https://deepwiki.com/huggingface/swift-transformers/4.4-model-configuration)
  * [Generation](https://deepwiki.com/huggingface/swift-transformers/5-generation)
  * [Generation Configuration](https://deepwiki.com/huggingface/swift-transformers/5.1-generation-configuration)
  * [Generation Modes](https://deepwiki.com/huggingface/swift-transformers/5.2-generation-modes)
  * [Logits Processing](https://deepwiki.com/huggingface/swift-transformers/5.3-logits-processing)
  * [Streaming and Callbacks](https://deepwiki.com/huggingface/swift-transformers/5.4-streaming-and-callbacks)
  * [Testing](https://deepwiki.com/huggingface/swift-transformers/6-testing)
  * [Tokenizer Testing](https://deepwiki.com/huggingface/swift-transformers/6.1-tokenizer-testing)
  * [Hub Testing](https://deepwiki.com/huggingface/swift-transformers/6.2-hub-testing)
  * [Advanced Topics](https://deepwiki.com/huggingface/swift-transformers/7-advanced-topics)
  * [Custom Tokenizers](https://deepwiki.com/huggingface/swift-transformers/7.1-custom-tokenizers)
  * [Performance Optimization](https://deepwiki.com/huggingface/swift-transformers/7.2-performance-optimization)
  * [Offline Deployment](https://deepwiki.com/huggingface/swift-transformers/7.3-offline-deployment)


Menu
# Model-Specific Tokenizers
Relevant source files
  * [](https://github.com/huggingface/swift-transformers/blob/91286f23/Sources/Tokenizers/Tokenizer.swift)
  * [](https://github.com/huggingface/swift-transformers/blob/91286f23/Tests/TokenizersTests/Resources/llama_3.2_encoded.json)
  * [](https://github.com/huggingface/swift-transformers/blob/91286f23/Tests/TokenizersTests/Resources/tokenizer_tests.json)
  * [](https://github.com/huggingface/swift-transformers/blob/91286f23/Tests/TokenizersTests/TokenizerTests.swift)


Model-specific tokenizers are specialized implementations that extend the standard tokenization pipeline to handle model-specific behaviors, legacy compatibility requirements, and configuration quirks that cannot be addressed through generic tokenization components alone.
For information about the core tokenization model types (BPE, Unigram, BERT), see [Tokenizer Types](https://deepwiki.com/huggingface/swift-transformers/2.3-tokenizer-types). For information about the standard tokenization components (pre-tokenizers, normalizers, post-processors, decoders), see [Tokenizer Components](https://deepwiki.com/huggingface/swift-transformers/2.4-tokenizer-components).
## Purpose and Scope
Model-specific tokenizers solve two primary problems:
  1. **Legacy Compatibility** : Some model families have evolved their tokenization behavior over time, requiring backward-compatible implementations that preserve original behavior while supporting newer models
  2. **Configuration Overrides** : Certain models require programmatic modifications to their tokenizer configuration that cannot be expressed solely through the `tokenizer.json` and `tokenizer_config.json` files


The most prominent example is `LlamaPreTrainedTokenizer`, which handles multiple generations of Llama models with different tokenization behaviors.
Sources: [853-859](https://github.com/huggingface/swift-transformers/blob/91286f23/Sources/Tokenizers/Tokenizer.swift#L853-L859) [985-1019](https://github.com/huggingface/swift-transformers/blob/91286f23/Sources/Tokenizers/Tokenizer.swift#L985-L1019)
## Architecture Overview
**Model-Specific Tokenizer Selection Flow**
The `AutoTokenizer` uses a two-level selection mechanism:
  1. **Tokenizer Class Selection** : Determines which `PreTrainedTokenizer` subclass to instantiate based on `tokenizer_class` in the configuration
  2. **Tokenizing Model Selection** : Determines which underlying tokenization algorithm (BPE, BERT, Unigram) to use


This separation allows model-specific tokenizers to wrap and modify the behavior of any underlying tokenization algorithm.
Sources: [861-891](https://github.com/huggingface/swift-transformers/blob/91286f23/Sources/Tokenizers/Tokenizer.swift#L861-L891)
## Registration System
**Tokenizer Class Registration and Lookup**
Model-specific tokenizers are registered in the `PreTrainedTokenizerClasses.tokenizerClasses` dictionary, which maps tokenizer class names from configuration files to Swift types.
Configuration Key | Swift Type | Purpose  
---|---|---  
`"LlamaTokenizer"` | `LlamaPreTrainedTokenizer.self` | Handles Llama model family tokenization with legacy mode support  
The lookup process:
  1. Extract `tokenizer_class` from `tokenizer_config.json`
  2. Strip `"Fast"` suffix if present (e.g., `"LlamaTokenizerFast"` → `"LlamaTokenizer"`)
  3. Look up the tokenizer class in `PreTrainedTokenizerClasses.tokenizerClasses`
  4. Fall back to `PreTrainedTokenizer` if no specialized class is registered


Sources: [853-878](https://github.com/huggingface/swift-transformers/blob/91286f23/Sources/Tokenizers/Tokenizer.swift#L853-L878)
## LlamaPreTrainedTokenizer
`LlamaPreTrainedTokenizer` is the primary model-specific tokenizer implementation, handling behavioral differences across Llama model generations.
### Legacy Mode Behavior
**LlamaPreTrainedTokenizer Initialization Flow**
The `isLegacy` flag controls two major behavioral differences:
  1. **Configuration Modification** (applied during initialization):
     * **Legacy Mode (`isLegacy = true`)**: Uses the original `normalizer` and `pre_tokenizer` from `tokenizer.json`
     * **Modern Mode (`isLegacy = false`)**: Removes the normalizer and replaces the pre-tokenizer with a Metaspace pre-tokenizer
  2. **Token Prefix Handling** (applied during tokenization):
     * **Legacy Mode** : Does not add a prefix to the input text
     * **Modern Mode** : Prepends a SentencePiece underline (`▁`) to the input text, unless the first token is a special token


Sources: [985-1004](https://github.com/huggingface/swift-transformers/blob/91286f23/Sources/Tokenizers/Tokenizer.swift#L985-L1004)
### Tokenization Override
**LlamaPreTrainedTokenizer Tokenization Logic**
The override of the `tokenize` method implements the modern Llama behavior:
  1. If `isLegacy` is `true` or text is empty, delegate directly to the parent implementation
  2. If `isLegacy` is `false`: 
     * Prepend the SentencePiece underline (`▁`) to the text
     * Replace any existing `▁` in the text with spaces
     * Call the parent `tokenize` method
     * If the first token is `▁` and the second token is a special token, remove the first token


This ensures that special tokens at the beginning of the text are not preceded by an unwanted prefix token.
Sources: [1008-1018](https://github.com/huggingface/swift-transformers/blob/91286f23/Sources/Tokenizers/Tokenizer.swift#L1008-L1018)
### Example Usage
The test suite demonstrates the expected behavior:
```


```

In legacy mode, a space at the beginning of the input produces an additional token (the prefix token `29871`) before the actual content token.
Sources: [215-222](https://github.com/huggingface/swift-transformers/blob/91286f23/Tests/TokenizersTests/TokenizerTests.swift#L215-L222)
## Post-Processor Customization
The `maybeUpdatePostProcessor` function provides runtime modif




---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/huggingface/swift-transformers/blob/main/Sources/Tokenizers/Tokenizer.swift

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://github.com/huggingface/swift-transformers/blob/main/Sources/Tokenizers/T
okenizer.swift       | ✓ | ⏱: 1.47s 
[SCRAPE].. ◆ 
https://github.com/huggingface/swift-transformers/blob/main/Sources/Tokenizers/T
okenizer.swift       | ✓ | ⏱: 0.07s 
[COMPLETE] ● 
https://github.com/huggingface/swift-transformers/blob/main/Sources/Tokenizers/T
okenizer.swift       | ✓ | ⏱: 1.55s 
[Skip to content](https://github.com/huggingface/swift-transformers/blob/main/Sources/Tokenizers/Tokenizer.swift#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fhuggingface%2Fswift-transformers%2Fblob%2Fmain%2FSources%2FTokenizers%2FTokenizer.swift)
Appearance settings
  * Platform
    * AI CODE CREATION
      * [ GitHub CopilotWrite better code with AI ](https://github.com/features/copilot)
      * [ GitHub SparkBuild and deploy intelligent apps ](https://github.com/features/spark)
      * [ GitHub ModelsManage and compare prompts ](https://github.com/features/models)
      * [ MCP RegistryNewIntegrate external tools ](https://github.com/mcp)
    * DEVELOPER WORKFLOWS
      * [ ActionsAutomate any workflow ](https://github.com/features/actions)
      * [ CodespacesInstant dev environments ](https://github.com/features/codespaces)
      * [ IssuesPlan and track work ](https://github.com/features/issues)
      * [ Code ReviewManage code changes ](https://github.com/features/code-review)
    * APPLICATION SECURITY
      * [ GitHub Advanced SecurityFind and fix vulnerabilities ](https://github.com/security/advanced-security)
      * [ Code securitySecure your code as you build ](https://github.com/security/advanced-security/code-security)
      * [ Secret protectionStop leaks before they start ](https://github.com/security/advanced-security/secret-protection)
    * EXPLORE
      * [Why GitHub](https://github.com/why-github)
      * [Documentation](https://docs.github.com)
      * [Blog](https://github.blog)
      * [Changelog](https://github.blog/changelog)
      * [Marketplace](https://github.com/marketplace)
[View all features](https://github.com/features)
  * Solutions
    * BY COMPANY SIZE
      * [Enterprises](https://github.com/enterprise)
      * [Small and medium teams](https://github.com/team)
      * [Startups](https://github.com/enterprise/startups)
      * [Nonprofits](https://github.com/solutions/industry/nonprofits)
    * BY USE CASE
      * [App Modernization](https://github.com/solutions/use-case/app-modernization)
      * [DevSecOps](https://github.com/solutions/use-case/devsecops)
      * [DevOps](https://github.com/solutions/use-case/devops)
      * [CI/CD](https://github.com/solutions/use-case/ci-cd)
      * [View all use cases](https://github.com/solutions/use-case)
    * BY INDUSTRY
      * [Healthcare](https://github.com/solutions/industry/healthcare)
      * [Financial services](https://github.com/solutions/industry/financial-services)
      * [Manufacturing](https://github.com/solutions/industry/manufacturing)
      * [Government](https://github.com/solutions/industry/government)
      * [View all industries](https://github.com/solutions/industry)
[View all solutions](https://github.com/solutions)
  * Resources
    * EXPLORE BY TOPIC
      * [AI](https://github.com/resources/articles?topic=ai)
      * [Software Development](https://github.com/resources/articles?topic=software-development)
      * [DevOps](https://github.com/resources/articles?topic=devops)
      * [Security](https://github.com/resources/articles?topic=security)
      * [View all topics](https://github.com/resources/articles)
    * EXPLORE BY TYPE
      * [Customer stories](https://github.com/customer-stories)
      * [Events & webinars](https://github.com/resources/events)
      * [Ebooks & reports](https://github.com/resources/whitepapers)
      * [Business insights](https://github.com/solutions/executive-insights)
      * [GitHub Skills](https://skills.github.com)
    * SUPPORT & SERVICES
      * [Documentation](https://docs.github.com)
      * [Customer support](https://support.github.com)
      * [Community forum](https://github.com/orgs/community/discussions)
      * [Trust center](https://github.com/trust-center)
      * [Partners](https://github.com/partners)
  * Open Source
    * COMMUNITY
      * [ GitHub SponsorsFund open source developers ](https://github.com/sponsors)
    * PROGRAMS
      * [Security Lab](https://securitylab.github.com)
      * [Maintainer Community](https://maintainers.github.com)
      * [Accelerator](https://github.com/accelerator)
      * [Archive Program](https://archiveprogram.github.com)
    * REPOSITORIES
      * [Topics](https://github.com/topics)
      * [Trending](https://github.com/trending)
      * [Collections](https://github.com/collections)
  * Enterprise
    * ENTERPRISE SOLUTIONS
      * [ Enterprise platformAI-powered developer platform ](https://github.com/enterprise)
    * AVAILABLE ADD-ONS
      * [ GitHub Advanced SecurityEnterprise-grade security features ](https://github.com/security/advanced-security)
      * [ Copilot for BusinessEnterprise-grade AI features ](https://github.com/features/copilot/copilot-business)
      * [ Premium SupportEnterprise-grade 24/7 support ](https://github.com/premium-support)
  * [Pricing](https://github.com/pricing)


Search or jump to...
# Search code, repositories, users, issues, pull requests...
Search 
Clear
[Search syntax tips](https://docs.github.com/search-github/github-code-search/understanding-github-code-search-syntax)
#  Provide feedback 
We read every piece of feedback, and take your input very seriously.
Include my email address so I can be contacted
Cancel  Submit feedback 
#  Saved searches 
## Use saved searches to filter your results more quickly
Name
Query
To see all available qualifiers, see our [documentation](https://docs.github.com/search-github/github-code-search/understanding-github-code-search-syntax). 
Cancel  Create saved search 
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fhuggingface%2Fswift-transformers%2Fblob%2Fmain%2FSources%2FTokenizers%2FTokenizer.swift)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Fblob%2Fshow&source=header-repo&source_repo=huggingface%2Fswift-transformers)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/huggingface/swift-transformers/blob/main/Sources/Tokenizers/Tokenizer.swift) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/huggingface/swift-transformers/blob/main/Sources/Tokenizers/Tokenizer.swift) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/huggingface/swift-transformers/blob/main/Sources/Tokenizers/Tokenizer.swift) to refresh your session. Dismiss alert
{{ message }}
[ huggingface ](https://github.com/huggingface) / **[swift-transformers](https://github.com/huggingface/swift-transformers) ** Public
  * [ ](https://github.com/login?return_to=%2Fhuggingface%2Fswift-transformers) You must be signed in to change notification settings
  * [ 163 ](https://github.com/login?return_to=%2Fhuggingface%2Fswift-transformers)
  * [ Star  1.3k ](https://github.com/login?return_to=%2Fhuggingface%2Fswift-transformers)


  * [ Code ](https://github.com/huggingface/swift-transformers)
  * [ Issues 16 ](https://github.com/huggingface/swift-transformers/issues)
  * [ Pull requests 7 ](https://github.com/huggingface/swift-transformers/pulls)
  * [ Actions ](https://github.com/huggingface/swift-transformers/actions)
  * [ Security 0 ](https://github.com/huggingface/swift-transformers/security)
  * [ Insights ](https://github.com/huggingface/swift-transformers/pulse)


Additional navigation options
  * [ Code  ](https://github.com/huggingface/swift-transformers)
  * [ Issues  ](https://github.com/huggingface/swift-transformers/issues)
  * [ Pull requests  ](https://github.com/huggingface/swift-transformers/pulls)
  * [ Actions  ](https://github.com/huggingface/swift-transformers/actions)
  * [ Security  ](https://github.com/huggingface/swift-transformers/security)
  * [ Insights  ](https://github.com/huggingface/swift-transformers/pulse)


## Collapse file tree
## Files
main
Search this repository
  * .github
  * .vscode
  * Examples
  * Sources
    * Generation
    * Hub
    * Models
    * Tokenizers
      * BPETokenizer.swift
      * BertTokenizer.swift
      * ByteEncoder.swift
      * Decoder.swift
      * Normalizer.swift
      * PostProcessor.swift
      * PreTokenizer.swift
      * String+PreTokenization.swift
      * TokenLattice.swift
      * Tokenizer.swift
      * Trie.swift
      * UnigramTokenizer.swift
  * Tests
  * media
  * .git-blame-ignore-revs
  * .gitignore
  * .spi.yml
  * .swift-format
  * LICENSE
  * Package.swift
  * README.md


## Breadcrumbs
  1. [swift-transformers](https://github.com/huggingface/swift-transformers/tree/main)
  2. /[Sources](https://github.com/huggingface/swift-transformers/tree/main/Sources)
  3. /[Tokenizers](https://github.com/huggingface/swift-transformers/tree/main/Sources/Tokenizers)


/
# Tokenizer.swift
Copy path
BlameMore file actions
BlameMore file actions
## Latest commit
[![DePasqualeOrg](https://avatars.githubusercontent.com/u/25420077?v=4&size=40)](https://github.com/DePasqualeOrg)[DePasqualeOrg](https://github.com/huggingface/swift-transformers/commits?author=DePasqualeOrg)
[Make Message, ToolSpec, additionalContext sendable (](https://github.com/huggingface/swift-transformers/commit/573e5c9036c2f136b3a8a071da8e8907322403d0)[#298](https://github.com/huggingface/swift-transformers/pull/298)[)](https://github.com/huggingface/swift-transformers/commit/573e5c9036c2f136b3a8a071da8e8907322403d0)
Dec 10, 2025
[573e5c9](https://github.com/huggingface/swift-transformers/commit/573e5c9036c2f136b3a8a071da8e8907322403d0) · Dec 10, 2025
## History
[History](https://github.com/huggingface/swift-transformers/commits/main/Sources/Tokenizers/Tokenizer.swift)
Open commit details
[](https://github.com/huggingface/swift-transformers/commits/main/Sources/Tokenizers/Tokenizer.swift)History
1013 lines (881 loc) · 43.7 KB
## Breadcrumbs
  1. [swift-transformers](https://github.com/huggingface/swift-transformers/tree/main)
  2. /[Sources](https://github.com/huggingface/swift-transformers/tree/main/Sources)
  3. /[Tokenizers](https://github.com/huggingface/swift-transformers/tree/main/Sources/Tokenizers)


/
# Tokenizer.swift
Top
## File metadata and controls
  * Code
  * Blame


1013 lines (881 loc) · 43.7 KB
[Raw](https://github.com/huggingface/swift-transformers/raw/refs/heads/main/Sources/Tokenizers/Tokenizer.swift)
Copy raw file
Download raw file
Open symbols panel
Edit and raw actions
// // Tokenizer.swift // // // Created by Pedro Cuenca on 6/5/23. // import Foundation import Hub import Jinja /// A type alias for chat messages, represented as key-value pairs. public typealias Message = [String: any Sendable] /// A type alias for tool specifications used in chat templating. public typealias ToolSpec = [String: any Sendable] /// Errors that can occur during tokenizer operations. public enum TokenizerError: LocalizedError { case missingConfig case missingTokenizerClassInConfig case unsupportedTokenizer(String) case missingVocab case malformedVocab case chatTemplate(String) case missingChatTemplate case tooLong(String) case mismatchedConfig(String) public var errorDescription: String? { switch self { case .missingConfig: String(localized: "Tokenizer configuration is missing.", comment: "Error when tokenizer config cannot be found") case .missingTokenizerClassInConfig: String(localized: "The tokenizer class is not specified in the configuration.", comment: "Error when tokenizer_class is missing in config") case let .unsupportedTokenizer(name): String(localized: "The tokenizer type '\\(name)' is not supported.", comment: "Error when tokenizer type is not supported") case .missingVocab: String(localized: "Vocabulary file is missing from the tokenizer configuration.", comment: "Error when vocab file is missing") case .malformedVocab: String(localized: "The vocabulary file is malformed or corrupted.", comment: "Error when vocab file is malformed") case let .chatTemplate(message): String(localized: "Chat template error: \\(message)", comment: "Error with chat template") case .missingChatTemplate: String(localized: "This tokenizer does not have a chat template, and no template was passed.") case let .tooLong(message): String(localized: "Input is too long: \\(message)", comment: "Error when input exceeds maximum length") case let .mismatchedConfig(message): String(localized: "Tokenizer configuration mismatch: \\(message)", comment: "Error when tokenizer configuration is inconsistent") } } } /// A protocol defining the core tokenization functionality. /// /// This protocol defines the fundamental operations that any tokenization model must support, /// including converting between text and tokens, and between tokens and their numeric IDs. public protocol TokenizingModel { /// Tokenizes the input text into a sequence of tokens. /// /// - Parameter text: The input text to tokenize /// - Returns: An array of tokens as strings func tokenize(text: String) -> [String] /// Alias for `tokenize` that allows the instance to be called as a function. /// /// - Parameter text: The input text to tokenize /// - Returns: An array of tokens as strings func callAsFunction(_ text: String) -> [String] /// Converts a token string to its corresponding numeric ID. /// /// - Parameter token: The token string to convert /// - Returns: The numeric ID of the token, or nil if the token is not in the vocabulary func convertTokenToId(_ token: String) -> Int? /// Converts multiple token strings to their corresponding numeric IDs. /// /// - Parameter tokens: An array of token strings to convert /// - Returns: An array of numeric IDs, with nil values for tokens not in the vocabulary func convertTokensToIds(_ tokens: [String]) -> [Int?] /// Converts a numeric token ID back to its string representation. /// /// - Parameter id: The numeric token ID to convert /// - Returns: The token string, or nil if the ID is not valid func convertIdToToken(_ id: Int) -> String? /// Converts multiple numeric token IDs back to their string representations. /// /// - Parameter ids: An array of numeric token IDs to convert /// - Returns: An array of token strings, with nil values for invalid IDs func convertIdsToTokens(_ ids: [Int]) -> [String?] /// The beginning-of-sequence token string, if defined. var bosToken: String? { get } /// The numeric ID of the beginning-of-sequence token, if defined. var bosTokenId: Int? { get } /// The end-of-sequence token string, if defined. var eosToken: String? { get } /// The numeric ID of the end-of-sequence token, if defined. var eosTokenId: Int? { get } /// The unknown token string used for out-of-vocabulary words. var unknownToken: String? { get } /// The numeric ID of the unknown token. var unknownTokenId: Int? { get } /// Whether consecutive unknown tokens should be fused together. var fuseUnknownTokens: Bool { get } } /// Helper - possibly to be moved somewhere else func addedTokenAsString(_ addedToken: Config?) -> Stri


Let me get the raw source code for the specific section that handles tokenizer class registration.



---

## 🔧 TOOL RESULTS

[web_fetch]
🌐 https://raw.githubusercontent.com/huggingface/swift-transformers/refs/heads/main/Sources/Tokenizers/Tokenizer.swift

//
//  Tokenizer.swift
//
//
//  Created by Pedro Cuenca on 6/5/23.
//

import Foundation
import Hub
import Jinja

/// A type alias for chat messages, represented as key-value pairs.
public typealias Message = [String: any Sendable]

/// A type alias for tool specifications used in chat templating.
public typealias ToolSpec = [String: any Sendable]

/// Errors that can occur during tokenizer operations.
public enum TokenizerError: LocalizedError {
    case missingConfig
    case missingTokenizerClassInConfig
    case unsupportedTokenizer(String)
    case missingVocab
    case malformedVocab
    case chatTemplate(String)
    case missingChatTemplate
    case tooLong(String)
    case mismatchedConfig(String)

    public var errorDescription: String? {
        switch self {
        case .missingConfig:
            String(localized: "Tokenizer configuration is missing.", comment: "Error when tokenizer config cannot be found")
        case .missingTokenizerClassInConfig:
            String(localized: "The tokenizer class is not specified in the configuration.", comment: "Error when tokenizer_class is missing in config")
        case let .unsupportedTokenizer(name):
            String(localized: "The tokenizer type '\(name)' is not supported.", comment: "Error when tokenizer type is not supported")
        case .missingVocab:
            String(localized: "Vocabulary file is missing from the tokenizer configuration.", comment: "Error when vocab file is missing")
        case .malformedVocab:
            String(localized: "The vocabulary file is malformed or corrupted.", comment: "Error when vocab file is malformed")
        case let .chatTemplate(message):
            String(localized: "Chat template error: \(message)", comment: "Error with chat template")
        case .missingChatTemplate:
            String(localized: "This tokenizer does not have a chat template, and no template was passed.")
        case let .tooLong(message):
            String(localized: "Input is too long: \(message)", comment: "Error when input exceeds maximum length")
        case let .mismatchedConfig(message):
            String(localized: "Tokenizer configuration mismatch: \(message)", comment: "Error when tokenizer configuration is inconsistent")
        }
    }
}

/// A protocol defining the core tokenization functionality.
///
/// This protocol defines the fundamental operations that any tokenization model must support,
/// including converting between text and tokens, and between tokens and their numeric IDs.
public protocol TokenizingModel {
    /// Tokenizes the input text into a sequence of tokens.
    ///
    /// - Parameter text: The input text to tokenize
    /// - Returns: An array of tokens as strings
    func tokenize(text: String) -> [String]

    /// Alias for `tokenize` that allows the instance to be called as a function.
    ///
    /// - Parameter text: The input text to tokenize
    /// - Returns: An array of tokens as strings
    func callAsFunction(_ text: String) -> [String]

    /// Converts a token string to its corresponding numeric ID.
    ///
    /// - Parameter token: The token string to convert
    /// - Returns: The numeric ID of the token, or nil if the token is not in the vocabulary
    func convertTokenToId(_ token: String) -> Int?

    /// Converts multiple token strings to their corresponding numeric IDs.
    ///
    /// - Parameter tokens: An array of token strings to convert
    /// - Returns: An array of numeric IDs, with nil values for tokens not in the vocabulary
    func convertTokensToIds(_ tokens: [String]) -> [Int?]

    /// Converts a numeric token ID back to its string representation.
    ///
    /// - Parameter id: The numeric token ID to convert
    /// - Returns: The token string, or nil if the ID is not valid
    func convertIdToToken(_ id: Int) -> String?

    /// Converts multiple numeric token IDs back to their string representations.
    ///
    /// - Parameter ids: An array of numeric token IDs to convert
    /// - Returns: An array of token strings, with nil values for invalid IDs
    func convertIdsToTokens(_ ids: [Int]) -> [String?]

    /// The beginning-of-sequence token string, if defined.
    var bosToken: String? { get }

    /// The numeric ID of the beginning-of-sequence token, if defined.
    var bosTokenId: Int? { get }

    /// The end-of-sequence token string, if defined.
    var eosToken: String? { get }

    /// The numeric ID of the end-of-sequence token, if defined.
    var eosTokenId: Int? { get }

    /// The unknown token string used for out-of-vocabulary words.
    var unknownToken: String? { get }

    /// The numeric ID of the unknown token.
    var unknownTokenId: Int? { get }

    /// Whether consecutive unknown tokens should be fused together.
    var fuseUnknownTokens: Bool { get }
}

/// Helper - possibly to be moved somewhere else
func addedTokenAsString(_ addedToken: Config?) -> String? {
    guard let addedToken else { return nil }
    if let stringValue = addedToken.string() {
        return stringValue
    }
    // This is possibly a serialization of the AddedToken class
    // TODO: support lstrip, rstrip, normalized, etc.
    return addedToken.content.string()
}

public extension TokenizingModel {
    func callAsFunction(_ text: String) -> [String] {
        tokenize(text: text)
    }

    func convertTokensToIds(_ tokens: [String]) -> [Int?] {
        tokens.map { convertTokenToId($0) }
    }

    func convertIdsToTokens(_ ids: [Int]) -> [String?] {
        ids.map { convertIdToToken($0) }
    }
}

/// A tokenizer model that can be initialized from Hugging Face Hub configuration data.
///
/// This protocol extends `TokenizingModel` with the ability to be created from configuration
/// files typically found in tokenizer repositories on the Hugging Face Hub.
public protocol PreTrainedTokenizerModel: TokenizingModel {
    /// Initializes a tokenizer model from configuration data.
    ///
    /// - Parameters:
    ///   - tokenizerConfig: The tokenizer configuration (typically from tokenizer_config.json)
    ///   - tokenizerData: The tokenizer data (typically from tokenizer.json)
    ///   - addedTokens: A dictionary mapping added token strings to their IDs
    /// - Throws: `TokenizerError` if the configuration is invalid or missing required data
    init(tokenizerConfig: Config, tokenizerData: Config, addedTokens: [String: Int]) throws
}

enum TokenizerModel {
    static let knownTokenizers: [String: PreTrainedTokenizerModel.Type] = [
        "BertTokenizer": BertTokenizer.self,
        "CodeGenTokenizer": BPETokenizer.self,
        "CodeLlamaTokenizer": BPETokenizer.self,
        "CohereTokenizer": BPETokenizer.self,
        "DistilbertTokenizer": BertTokenizer.self,
        "DistilBertTokenizer": BertTokenizer.self,
        "FalconTokenizer": BPETokenizer.self,
        "GemmaTokenizer": BPETokenizer.self,
        "GPT2Tokenizer": BPETokenizer.self,
        "LlamaTokenizer": BPETokenizer.self,
        "RobertaTokenizer": BPETokenizer.self,
        "T5Tokenizer": T5Tokenizer.self,
        "TokenizersBackend": BPETokenizer.self,
        "PreTrainedTokenizer": BPETokenizer.self,
        "Qwen2Tokenizer": BPETokenizer.self,
        "WhisperTokenizer": BPETokenizer.self,
        "XLMRobertaTokenizer": UnigramTokenizer.self,
    ]

    static func unknownToken(from tokenizerConfig: Config) -> String? {
        tokenizerConfig.unkToken.content.string() ?? tokenizerConfig.unkToken.string()
    }

    static func from(tokenizerConfig: Config, tokenizerData: Config, addedTokens: [String: Int], strict: Bool = true) throws -> TokenizingModel {
        guard let tokenizerClassName = tokenizerConfig.tokenizerClass.string() else {
            throw TokenizerError.missingTokenizerClassInConfig
        }

        // Some tokenizer_class entries use a Fast suffix
        let tokenizerName = tokenizerClassName.replacingOccurrences(of: "Fast", with: "")
        // Fallback to BPETokenizer if class is not explicitly registered
        let tokenizerClass = TokenizerModel.knownTokenizers[tokenizerName] ?? BPETokenizer.self
        if TokenizerModel.knownTokenizers[tokenizerName] == nil {
            if strict {
                throw TokenizerError.unsupportedTokenizer(tokenizerName)
            } else {
                print("Warning: Tokenizer model class \(tokenizerName) is not registered, falling back to a standard BPE implementation.")
            }
        }
        return try tokenizerClass.init(tokenizerConfig: tokenizerConfig, tokenizerData: tokenizerData, addedTokens: addedTokens)
    }
}

/// Arguments for specifying chat templates when applying chat formatting.
public enum ChatTemplateArgument {
    /// A Jinja template to use for the conversation.
    ///
    /// Normally it is not necessary to provide a template, since it will be read from the tokenizer config.
    case literal(String)

    /// For models whose tokenizer config includes multiple chat templates, the template can be specified by name.
    ///
    /// Normally this is not necessary.
    case name(String)
}

/// A complete tokenizer interface supporting encoding, decoding, and chat template functionality.
///
/// This is the main protocol that defines all tokenizer operations, including text processing,
/// chat template application, and special token handling.
public protocol Tokenizer: Sendable {
    /// Tokenizes the input text into a sequence of tokens.
    ///
    /// - Parameter text: The input text to tokenize
    /// - Returns: An array of tokens as strings
    func tokenize(text: String) -> [String]

    /// Encodes text into token IDs with special tokens included by default.
    ///
    /// This is the main entry point for most tokenization tasks.
    ///
    /// - Parameter text: The input text to encode
    /// - Returns: An array of token IDs
    func encode(text: String) -> [Int]

    /// Encodes text into token IDs with optional special token handling.
    ///
    /// - Parameters:
    ///   - text: The input text to encode
    ///   - addSpecialTokens: Whether to add special tokens (e.g., BOS, EOS)
    /// - Returns: An array of token IDs
    func encode(text: String, addSpecialTokens: Bool) -> [Int]

    /// Function call syntax for encoding text.
    ///
    /// - Parameters:
    ///   - text: The input text to encode
    ///   - addSpecialTokens: Whether to add special tokens
    /// - Returns: An array of token IDs
    func callAsFunction(_ text: String, addSpecialTokens: Bool) -> [Int]

    /// Decodes token IDs back into text with special tokens included.
    ///
    /// - Parameter tokens: The token IDs to decode
    /// - Returns: The decoded text string
    func decode(tokens: [Int]) -> String

    /// Decodes token IDs back into text with optional special token handling.
    ///
    /// - Parameters:
    ///   - tokens: The token IDs to decode
    ///   - skipSpecialTokens: Whether to skip special tokens in the output
    /// - Returns: The decoded text string
    func decode(tokens: [Int], skipSpecialTokens: Bool) -> String

    /// Converts a token string to its corresponding numeric ID.
    ///
    /// - Parameter token: The token string to convert
    /// - Returns: The numeric ID of the token, or nil if not found
    func convertTokenToId(_ token: String) -> Int?

    /// Converts multiple token strings to their corresponding numeric IDs.
    ///
    /// - Parameter tokens: An array of token strings to convert
    /// - Returns: An array of numeric IDs, with nil values for unknown tokens
    func convertTokensToIds(_ tokens: [String]) -> [Int?]

    /// Converts a numeric token ID back to its string representation.
    ///
    /// - Parameter id: The numeric token ID to convert
    /// - Returns: The token string, or nil if the ID is invalid
    func convertIdToToken(_ id: Int) -> String?

    /// Converts multiple numeric token IDs back to their string representations.
    ///
    /// - Parameter ids: An array of numeric token IDs to convert
    /// - Returns: An array of token strings, with nil values for invalid IDs
    func convertIdsToTokens(_ ids: [Int]) -> [String?]

    /// The beginning-of-sequence token string, if defined.
    var bosToken: String? { get }

    /// The numeric ID of the beginning-of-sequence token, if defined.
    var bosTokenId: Int? { get }

    /// The end-of-sequence token string, if defined.
    var eosToken: String? { get }

    /// The numeric ID of the end-of-sequence token, if defined.
    var eosTokenId: Int? { get }

    /// The unknown token string used for out-of-vocabulary words.
    var unknownToken: String? { get }

    /// The numeric ID of the unknown token.
    var unknownTokenId: Int? { get }

    /// Whether this tokenizer has a chat template configured.
    var hasChatTemplate: Bool { get }

    /// Applies the configured chat template to format messages for model input.
    ///
    /// - Parameter messages: Array of message dictionaries representing the conversation
    /// - Returns: Token IDs for the formatted conversation
    /// - Throws: `TokenizerError` if template application fails or no template is available
    func applyChatTemplate(messages: [Message]) throws -> [Int]

    /// Applies the configured chat template with optional tool specifications.
    ///
    /// - Parameters:
    ///   - messages: Array of message dictionaries representing the conversation
    ///   - tools: Optional array of tool specifications for function calling
    /// - Returns: Token IDs for the formatted conversation
    /// - Throws: `TokenizerError` if template application fails or no template is available
    func applyChatTemplate(messages: [Message], tools: [ToolSpec]?) throws -> [Int]

    /// Applies the configured chat template with tools and additional context.
    ///
    /// - Parameters:
    ///   - messages: Array of message dictionaries representing the conversation
    ///   - tools: Optional array of tool specifications for function calling
    ///   - additionalContext: Additional context variables for template rendering
    /// - Returns: Token IDs for the formatted conversation
    /// - Throws: `TokenizerError` if template application fails or no template is available
    func applyChatTemplate(messages: [Message], tools: [ToolSpec]?, additionalContext: [String: any Sendable]?) throws -> [Int]

    /// Applies a specific chat template to format messages.
    ///
    /// - Parameters:
    ///   - messages: Array of message dictionaries representing the conversation
    ///   - chatTemplate: The chat template to use (literal template or template name)
    /// - Returns: Token IDs for the formatted conversation
    /// - Throws: `TokenizerError` if template application fails
    func applyChatTemplate(messages: [Message], chatTemplate: ChatTemplateArgument) throws -> [Int]

    /// Applies a chat template provided as a literal string.
    ///
    /// - Parameters:
    ///   - messages: Array of message dictionaries representing the conversation
    ///   - chatTemplate: The Jinja template string to use for formatting
    /// - Returns: Token IDs for the formatted conversation
    /// - Throws: `TokenizerError` if template application fails
    func applyChatTemplate(messages: [Message], chatTemplate: String) throws -> [Int]

    /// Applies a chat template with full control over all parameters.
    ///
    /// - Parameters:
    ///   - messages: Array of message dictionaries representing the conversation
    ///   - chatTemplate: Optional chat template specification
    ///   - addGenerationPrompt: Whether to add a generation prompt for the assistant
    ///   - truncation: Whether to truncate if the result exceeds maximum length
    ///   - maxLength: Maximum allowed token length
    ///   - tools: Optional array of tool specifications for function calling
    /// - Returns: Token IDs for the formatted conversation
    /// - Throws: `TokenizerError` if template application fails
    func applyChatTemplate(
        messages: [Message],
        chatTemplate: ChatTemplateArgument?,
        addGenerationPrompt: Bool,
        truncation: Bool,
        maxLength: Int?,
        tools: [ToolSpec]?
    ) throws -> [Int]

    /// Applies a chat template with full control over all parameters including additional context.
    ///
    /// - Parameters:
    ///   - messages: Array of message dictionaries representing the conversation
    ///   - chatTemplate: Optional chat template specification
    ///   - addGenerationPrompt: Whether to add a generation prompt for the assistant
    ///   - truncation: Whether to truncate if the result exceeds maximum length
    ///   - maxLength: Maximum allowed token length
    ///   - tools: Optional array of tool specifications for function calling
    ///   - additionalContext: Additional context variables for template rendering
    /// - Returns: Token IDs for the formatted conversation
    /// - Throws: `TokenizerError` if template application fails
    func applyChatTemplate(
        messages: [Message],
        chatTemplate: ChatTemplateArgument?,
        addGenerationPrompt: Bool,
        truncation: Bool,
        maxLength: Int?,
        tools: [ToolSpec]?,
        additionalContext: [String: any Sendable]?
    ) throws -> [Int]
}

extension Tokenizer {
    public var hasChatTemplate: Bool { false }

    /// Call previous signature for backwards compatibility
    func applyChatTemplate(
        messages: [Message],
        // A chat template can optionally be provided or specified by name when several templates are included in the tokenizer config. Normally this is not necessary.
        chatTemplate: ChatTemplateArgument?,
        addGenerationPrompt: Bool,
        truncation: Bool,
        maxLength: Int?,
        tools: [ToolSpec]?,
        additionalContext: [String: any Sendable]?
    ) throws -> [Int] {
        if additionalContext == nil {
            try applyChatTemplate(
                messages: messages, chatTemplate: chatTemplate, addGenerationPrompt: addGenerationPrompt, truncation: truncation, maxLength: maxLength,
                tools: tools
            )
        } else {
            throw TokenizerError.chatTemplate("Not implemented")
        }
    }
}

public extension Tokenizer {
    func callAsFunction(_ text: String, addSpecialTokens: Bool = true) -> [Int] {
        encode(text: text, addSpecialTokens: addSpecialTokens)
    }

    func decode(tokens: [Int]) -> String {
        decode(tokens: tokens, skipSpecialTokens: false)
    }

    func convertTokensToIds(_ tokens: [String]) -> [Int?] {
        tokens.map { convertTokenToId($0) }
    }

    func convertIdsToTokens(_ ids: [Int]) -> [String?] {
        ids.map { convertIdToToken($0) }
    }
}

let specialTokenAttributes: [String] = [
    "bos_token",
    "eos_token",
    "unk_token",
    "sep_token",
    "pad_token",
    "cls_token",
    "mask_token",
    "additional_special_tokens",
]

/// A comprehensive tokenizer implementation supporting pre-trained models from Hugging Face.
///
/// This class provides a complete tokenizer implementation that can be initialized from
/// Hugging Face Hub configuration files and supports all standard tokenization operations
/// including chat template application, normalization, pre-tokenization, and post-processing.
public class PreTrainedTokenizer: @unchecked Sendable, Tokenizer {
    let model: TokenizingModel

    public var bosToken: String? { model.bosToken }
    public var bosTokenId: Int? { model.bosTokenId }
    public var eosToken: String? { model.eosToken }
    public var eosTokenId: Int? { model.eosTokenId }
    public var unknownToken: String? { model.unknownToken }
    public var unknownTokenId: Int? { model.unknownTokenId }
    public var fuseUnknownTokens: Bool { model.fuseUnknownTokens }

    let addedTokens: Set
    let specialTokens: [String: Int]
    let addedTokensRegex: NSRegularExpression?

    private let preTokenizer: PreTokenizer?
    private let normalizer: Normalizer?
    private let postProcessor: PostProcessor?
    private let decoder: Decoder?
    private let tokenizerConfig: Config

    private let cleanUpTokenizationSpaces: Bool

    /// Cache for compiled Jinja templates keyed by their literal template string
    private var compiledChatTemplateCache: [String: Template] = [:]

    /// Lock to protect the compiled chat template cache from concurrent access
    private let cacheLock = NSLock()

    /// Initializes a tokenizer from Hugging Face configuration files.
    ///
    /// - Parameters:
    ///   - tokenizerConfig: Configuration from tokenizer_config.json
    ///   - tokenizerData: Configuration from tokenizer.json
    ///   - strict: Whether to enforce strict validation of tokenizer types
    /// - Throws: `TokenizerError` if configuration is invalid or tokenizer type is unsupported
    public required init(tokenizerConfig: Config, tokenizerData: Config, strict: Bool = true) throws {
        var addedTokens: [String: Int] = [:]
        var specialTokens: [String: Int] = [:]
        for addedToken in tokenizerData["addedTokens"].array(or: []) {
            guard let id = addedToken["id"].integer() else { continue } // malformed: token with no id
            guard let content = addedToken.content.string() else { continue } // malformed: token with no content
            addedTokens[content] = id

            if addedToken["special"].boolean(or: false) {
                specialTokens[content] = id
            }
        }

        // Convert to tuples for easier access, then sort by length (descending) to avoid early partial matches
        // (https://github.com/xenova/transformers.js/commit/c305c3824f628f1f02806a6310bd3b18b0f7f8f5)
        let unwrappedAddedTokens: [(content: String, prefix: Bool, suffix: Bool)] = (tokenizerData["addedTokens"].array(or: [])).compactMap { addedToken -> (String, Bool, Bool)? in
            guard let content = addedToken.content.string() else { return nil }
            let prefix = addedToken["lstrip"].boolean(or: false)
            let suffix = addedToken["rstrip"].boolean(or: false)
            return (content: content, prefix: prefix, suffix: suffix)
        }.sorted {
            $0.content.count > $1.content.count
        }

        // then concatenate into regular expression
        let addedTokensRegexString = unwrappedAddedTokens.map {
            let token = NSRegularExpression.escapedPattern(for: $0.content)
            let prefix = $0.prefix ? #"\s*"# : ""
            let suffix = $0.suffix ? #"\s*"# : ""
            return "\(prefix)(\(token))\(suffix)"
        }.joined(separator: "|")
        addedTokensRegex = try? NSRegularExpression(pattern: addedTokensRegexString, options: [])

        self.specialTokens = specialTokens
        self.addedTokens = Set(addedTokens.keys)

        preTokenizer = PreTokenizerFactory.fromConfig(config: tokenizerData["preTokenizer"])
        normalizer = NormalizerFactory.fromConfig(config: tokenizerData["normalizer"])
        postProcessor = PostProcessorFactory.fromConfig(config: tokenizerData["postProcessor"])
        decoder = DecoderFactory.fromConfig(config: tokenizerData["decoder"], addedTokens: self.addedTokens)
        cleanUpTokenizationSpaces = tokenizerConfig.cleanUpTokenizationSpaces.boolean(or: true)
        self.tokenizerConfig = tokenizerConfig

        model = try TokenizerModel.from(tokenizerConfig: tokenizerConfig, tokenizerData: tokenizerData, addedTokens: addedTokens, strict: strict)
    }

    private func compiledTemplate(for templateString: String) throws -> Template {
        // Fast path: check cache under lock
        cacheLock.lock()
        if let cached = compiledChatTemplateCache[templateString] {
            cacheLock.unlock()
            return cached
        }
        cacheLock.unlock()

        // Compile template outside of lock to avoid holding lock during expensive operation
        let compiled = try Template(templateString)

        // Insert into cache under lock (using double-checked locking pattern)
        cacheLock.lock()
        defer { cacheLock.unlock() }

        // Check again in case another thread compiled the same template
        if let cached = compiledChatTemplateCache[templateString] {
            return cached
        }

        compiledChatTemplateCache[templateString] = compiled
        return compiled
    }

    func preTokenize(_ text: String, options: PreTokenizerOptions) -> [String] {
        guard let preTokenizer else { return [text] }
        return preTokenizer(text: text, options: options)
    }

    func normalize(_ text: String) -> String {
        guard let normalizer else { return text }
        return normalizer(text: text)
    }

    func postProcess(_ tokens: [String], addSpecialTokens: Bool = true) -> [String] {
        guard let postProcessor else { return tokens }
        return postProcessor(tokens: tokens, addSpecialTokens: addSpecialTokens)
    }

    func decodeTokens(_ tokens: [String]) -> [String] {
        guard let tokenDecoder = decoder else { return tokens }
        return tokenDecoder(tokens: tokens)
    }

    /// Clean up a list of simple English tokenization artifacts like spaces before punctuations and abbreviated forms
    func cleanUp(text: String) -> String {
        guard cleanUpTokenizationSpaces else { return text }

        return
            text
            .replacingOccurrences(of: " .", with: ".")
            .replacingOccurrences(of: " ?", with: "?")
            .replacingOccurrences(of: " !", with: "!")
            .replacingOccurrences(of: " ,", with: ",")
            .replacingOccurrences(of: " ' ", with: "'")
            .replacingOccurrences(of: " n't", with: "n't")
            .replacingOccurrences(of: " 'm", with: "'m")
            .replacingOccurrences(of: " 's", with: "'s")
            .replacingOccurrences(of: " 've", with: "'ve")
            .replacingOccurrences(of: " 're", with: "'re")
    }

    func fuseUnknown(_ tokens: [String]) -> [String] {
        guard fuseUnknownTokens else { return tokens }
        let (fused, _) = tokens.reduce((fused: [String](), previousIsUnknown: false)) { result, token in
            var (fused, previousIsUnknown) = result
            let isUnknown = model.convertTokenToId(token) == model.unknownTokenId
            if isUnknown {
                if !previousIsUnknown { fused.append(token) }
            } else {
                fused.append(token)
            }
            return (fused, isUnknown)
        }
        return fused
    }

    /// Tokenizes input text using the configured normalization and pre-tokenization steps.
    ///
    /// - Parameter text: The input text to tokenize
    /// - Returns: An array of token strings
    public func tokenize(text: String) -> [String] {
        // Take care of special tokens first
        let sections: [String] =
            if let regex = addedTokensRegex {
                text.split(by: regex)
            } else {
                [text]
            }
        return sections.enumerated().map { section, x in
            if addedTokens.contains(x) { return [x] }
            return preTokenize(normalize(x), options: section == 0 ? [.firstSection] : []).flatMap { model($0) }
        }.flatMap { fuseUnknown($0) }
    }

    /// Encodes input text into token IDs with optional special token handling.
    ///
    /// This is the main entry point for text encoding operations.
    ///
    /// - Parameters:
    ///   - text: The input text to encode
    ///   - addSpecialTokens: Whether to add special tokens during post-processing
    /// - Returns: An array of token IDs
    public func encode(text: String, addSpecialTokens: Bool = true) -> [Int] {
        postProcess(tokenize(text: text), addSpecialTokens: addSpecialTokens).map { model.convertTokenToId($0)! }
    }

    /// Encodes input text into token IDs with special tokens included by default.
    ///
    /// - Parameter text: The input text to encode
    /// - Returns: An array of token IDs
    public func encode(text: String) -> [Int] {
        encode(text: text, addSpecialTokens: true)
    }

    /// Decodes token IDs back into human-readable text.
    ///
    /// - Parameters:
    ///   - tokens: The token IDs to decode
    ///   - skipSpecialTokens: Whether to exclude special tokens from the output text
    /// - Returns: The decoded text string
    public func decode(tokens: [Int], skipSpecialTokens: Bool = false) -> String {
        // IDs to tokens
        let tokenStrings: [String]
        if skipSpecialTokens {
            let specialTokenIDs = Set(specialTokens.values)
            tokenStrings =
                tokens
                .filter { !specialTokenIDs.contains($0) }
                .compactMap { model.convertIdToToken($0) }
        } else {
            tokenStrings = tokens.compactMap { model.convertIdToToken($0) }
        }
        let decoded = decodeTokens(tokenStrings)
        // At this point we should have a single String
        return cleanUp(text: decoded.joined(separator: ""))
    }

    /// Converts a token string to its corresponding numeric ID.
    ///
    /// - Parameter token: The token string to convert
    /// - Returns: The numeric ID of the token, or nil if not found in the vocabulary
    public func convertTokenToId(_ token: String) -> Int? {
        model.convertTokenToId(token)
    }

    /// Converts a numeric token ID back to its string representation.
    ///
    /// - Parameter id: The numeric token ID to convert
    /// - Returns: The token string, or nil if the ID is invalid
    public func convertIdToToken(_ id: Int) -> String? {
        model.convertIdToToken(id)
    }

    /// Whether this tokenizer has a chat template configured.
    public var hasChatTemplate: Bool {
        !tokenizerConfig.chatTemplate.isNull()
    }

    public func applyChatTemplate(messages: [Message]) throws -> [Int] {
        try applyChatTemplate(messages: messages, addGenerationPrompt: true)
    }

   

... [truncated]


Interesting! I can see `TokenizersBackend` is actually registered in swift-transformers. Let me now check the other available quantized versions and the original model's tokenizer config for comparison.



---

## 🔧 TOOL RESULTS

[web_fetch]
🌐 https://huggingface.co/mlx-community/Nanbeige4.1-3B-8bit/raw/main/tokenizer_config.json

{
  "add_prefix_space": true,
  "backend": "tokenizers",
  "bos_token": "",
  "clean_up_tokenization_spaces": false,
  "eos_token": "",
  "extra_special_tokens": [
    ""
  ],
  "is_local": true,
  "legacy": true,
  "model_max_length": 1000000000000000019884624838656,
  "model_specific_special_tokens": {},
  "pad_token": "",
  "sp_model_kwargs": {},
  "spaces_between_special_tokens": false,
  "tokenizer_class": "TokenizersBackend",
  "tool_parser_type": "json_tools",
  "unk_token": "",
  "use_default_system_prompt": false
}




---

## 🔧 TOOL RESULTS

[web_search]
🔍 DuckDuckGo results for "Nanbeige4.1 mlx-community swift-transformers tokenizer issue" (10 results):

1. **mlx-community/Nanbeige4.1-3B-8bit · Hugging Face**
   https://huggingface.co/mlx-community/Nanbeige4.1-3B-8bit
   We&#x27;re on a journey to advance and democratize artificial intelligence through open source and open science.

2. **GitHub - huggingface/swift-transformers: Swift Package to implement a ...**
   https://github.com/huggingface/swift-transformers
   Swift Transformers is a community project and we welcome contributions. Please check out Issues tagged with good first issue if you are looking for a place to start! Before submitting a pull request, please ensure your code: Passes the test suite (swift test) Passes linting checks (swift format lint --recursive .) To format your code, run swift format -i --recursive ..

3. **Nanbeige4-3B Technical Report: Exploring the Frontier of Small Language ...**
   https://arxiv.org/html/2512.06266v1
   To support the community and foster open, reproducible research in LLMs, we open-source the Nanbeige4-3B model family. We hope this will empower researchers and developers to explore advanced training methodologies, accelerate innovation in reasoning-centric models, and contribute to a more open and collaborative AI ecosystem.

4. **swift-transformers - Swift Package Index**
   https://swiftpackageindex.com/huggingface/swift-transformers
   Swift Transformers is a community project and we welcome contributions. Please check out Issues tagged with good first issue if you are looking for a place to start! Before submitting a pull request, please ensure your code: Passes the test suite (swift test) Passes linting checks (swift format lint --recursive .) To format your code, run swift format -i --recursive ..

5. **Nanbeige/Nanbeige4-3B-Base · Hugging Face**
   https://huggingface.co/Nanbeige/Nanbeige4-3B-Base
   1. Introduction Nanbeige4-3B-Base is a 3B-parameter base model within the fourth-generation Nanbeige LLM family. It showcases that even a compact model can achieve advanced performances through continuous enhancements in data quality and training methodologies.

6. **[2512.06266] Nanbeige4-3B Technical Report: Exploring the Frontier of ...**
   https://arxiv.org/abs/2512.06266
   We present Nanbeige4-3B, a family of small-scale but high-performing language models. Pretrained on 23T high-quality tokens and finetuned on over 30 million diverse instructions, we extend the boundary of the scaling law for small language models. In pre-training, we design a Fine-Grained Warmup-Stable-Decay (FG-WSD) training scheduler, which progressively refines data mixtures across stages ...

7. **Nanbeige4-3B-Thinking: How a 23T Token Pipeline Pushes 3B Models Past ...**
   https://www.marktechpost.com/2025/12/12/nanbeige4-3b-thinking-how-a-23t-token-pipeline-pushes-3b-models-past-30b-class-reasoning/
   The research team ships 2 primary checkpoints, Nanbeige4-3B-Base and Nanbeige4-3B-Thinking, and evaluates the reasoning tuned model against Qwen3 checkpoints from 4B up to 32B parameters. Recommended Open Source AI: Meet CopilotKit- Framework for building agent-native applications with Generative UI.

8. **Swift Package to implement a transformers-like API in Swift**
   https://github.com/CosmicJesterX/transformer-swift
   Swift Transformers is a community project and we welcome contributions. Please check out Issues tagged with good first issue if you are looking for a place to start!

9. **GitHub - EJudgeProjects/swift-transformers: Clone of the HuggingFace ...**
   https://github.com/EJudgeProjects/swift-transformers
   swift-transformers is a collection of utilities to help adopt language models in Swift apps. It tries to follow the Python transformers API and abstractions whenever possible, but it also aims to provide an idiomatic Swift interface and does not assume prior familiarity with transformers or tokenizers.

10. **McG-221/Nanbeige4.1-3B-mlx-8Bit · Hugging Face**
   https://huggingface.co/McG-221/Nanbeige4.1-3B-mlx-8Bit
   We&#x27;re on a journey to advance and democratize artificial intelligence through open source and open science.




---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/huggingface/swift-transformers/issues?q=TokenizersBackend

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://github.com/huggingface/swift-transformers/issues?q=TokenizersBackend    
| ✓ | ⏱: 1.51s 
[SCRAPE].. ◆ 
https://github.com/huggingface/swift-transformers/issues?q=TokenizersBackend    
| ✓ | ⏱: 0.03s 
[COMPLETE] ● 
https://github.com/huggingface/swift-transformers/issues?q=TokenizersBackend    
| ✓ | ⏱: 1.54s 
[Skip to content](https://github.com/huggingface/swift-transformers/issues?q=TokenizersBackend#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fhuggingface%2Fswift-transformers%2Fissues%3Fq%3DTokenizersBackend)
Appearance settings
  * Platform
    * AI CODE CREATION
      * [ GitHub CopilotWrite better code with AI ](https://github.com/features/copilot)
      * [ GitHub SparkBuild and deploy intelligent apps ](https://github.com/features/spark)
      * [ GitHub ModelsManage and compare prompts ](https://github.com/features/models)
      * [ MCP RegistryNewIntegrate external tools ](https://github.com/mcp)
    * DEVELOPER WORKFLOWS
      * [ ActionsAutomate any workflow ](https://github.com/features/actions)
      * [ CodespacesInstant dev environments ](https://github.com/features/codespaces)
      * [ IssuesPlan and track work ](https://github.com/features/issues)
      * [ Code ReviewManage code changes ](https://github.com/features/code-review)
    * APPLICATION SECURITY
      * [ GitHub Advanced SecurityFind and fix vulnerabilities ](https://github.com/security/advanced-security)
      * [ Code securitySecure your code as you build ](https://github.com/security/advanced-security/code-security)
      * [ Secret protectionStop leaks before they start ](https://github.com/security/advanced-security/secret-protection)
    * EXPLORE
      * [Why GitHub](https://github.com/why-github)
      * [Documentation](https://docs.github.com)
      * [Blog](https://github.blog)
      * [Changelog](https://github.blog/changelog)
      * [Marketplace](https://github.com/marketplace)
[View all features](https://github.com/features)
  * Solutions
    * BY COMPANY SIZE
      * [Enterprises](https://github.com/enterprise)
      * [Small and medium teams](https://github.com/team)
      * [Startups](https://github.com/enterprise/startups)
      * [Nonprofits](https://github.com/solutions/industry/nonprofits)
    * BY USE CASE
      * [App Modernization](https://github.com/solutions/use-case/app-modernization)
      * [DevSecOps](https://github.com/solutions/use-case/devsecops)
      * [DevOps](https://github.com/solutions/use-case/devops)
      * [CI/CD](https://github.com/solutions/use-case/ci-cd)
      * [View all use cases](https://github.com/solutions/use-case)
    * BY INDUSTRY
      * [Healthcare](https://github.com/solutions/industry/healthcare)
      * [Financial services](https://github.com/solutions/industry/financial-services)
      * [Manufacturing](https://github.com/solutions/industry/manufacturing)
      * [Government](https://github.com/solutions/industry/government)
      * [View all industries](https://github.com/solutions/industry)
[View all solutions](https://github.com/solutions)
  * Resources
    * EXPLORE BY TOPIC
      * [AI](https://github.com/resources/articles?topic=ai)
      * [Software Development](https://github.com/resources/articles?topic=software-development)
      * [DevOps](https://github.com/resources/articles?topic=devops)
      * [Security](https://github.com/resources/articles?topic=security)
      * [View all topics](https://github.com/resources/articles)
    * EXPLORE BY TYPE
      * [Customer stories](https://github.com/customer-stories)
      * [Events & webinars](https://github.com/resources/events)
      * [Ebooks & reports](https://github.com/resources/whitepapers)
      * [Business insights](https://github.com/solutions/executive-insights)
      * [GitHub Skills](https://skills.github.com)
    * SUPPORT & SERVICES
      * [Documentation](https://docs.github.com)
      * [Customer support](https://support.github.com)
      * [Community forum](https://github.com/orgs/community/discussions)
      * [Trust center](https://github.com/trust-center)
      * [Partners](https://github.com/partners)
  * Open Source
    * COMMUNITY
      * [ GitHub SponsorsFund open source developers ](https://github.com/sponsors)
    * PROGRAMS
      * [Security Lab](https://securitylab.github.com)
      * [Maintainer Community](https://maintainers.github.com)
      * [Accelerator](https://github.com/accelerator)
      * [Archive Program](https://archiveprogram.github.com)
    * REPOSITORIES
      * [Topics](https://github.com/topics)
      * [Trending](https://github.com/trending)
      * [Collections](https://github.com/collections)
  * Enterprise
    * ENTERPRISE SOLUTIONS
      * [ Enterprise platformAI-powered developer platform ](https://github.com/enterprise)
    * AVAILABLE ADD-ONS
      * [ GitHub Advanced SecurityEnterprise-grade security features ](https://github.com/security/advanced-security)
      * [ Copilot for BusinessEnterprise-grade AI features ](https://github.com/features/copilot/copilot-business)
      * [ Premium SupportEnterprise-grade 24/7 support ](https://github.com/premium-support)
  * [Pricing](https://github.com/pricing)


Search or jump to...
# Search code, repositories, us




---

## 🔧 TOOL RESULTS

[web_search]
🔍 DuckDuckGo results for "site:github.com/huggingface/swift-transformers issues Nanbeige OR TokenizersBackend" (10 results):

1. **swift-transformers/Sources/Tokenizers/Tokenizer.swift at main ...**
   https://github.com/huggingface/swift-transformers/blob/main/Sources/Tokenizers/Tokenizer.swift
   Swift Package to implement a transformers-like API in Swift - huggingface/swift-transformers

2. **TokenizersBackend does not exist | mike bommarito**
   https://michaelbommarito.com/wiki/programming/languages/python/libraries/transformers-v5/tokenizersbackend-error/
   how to fix the &quot;Tokenizer class TokenizersBackend does not exist or is not currently imported&quot; error when loading models

3. **Releases: huggingface/transformers - GitHub**
   https://github.com/huggingface/transformers/releases?after=v2.10.0
   We are excited to announce the initial release of Transformers v5. This is the first major release in five years, and the release is significant: 1200 commits have been pushed to main since the latest minor release. This release removes a lot of long-due deprecations, introduces several refactors ...

4. **tokenizer backend changes | mike bommarito**
   https://michaelbommarito.com/wiki/programming/languages/python/libraries/transformers-v5/tokenizers/
   unified tokenizer backend system eliminating the fast/slow distinction in transformers v5.0

5. **The Architectural Epiphany: Why HF Transformers v5 Finally Makes ...**
   https://www.linkedin.com/pulse/architectural-epiphany-why-hf-transformers-v5-finally-giampieri-eagbf
   TL;DR: Transformers v5 overhauls the tokenization ecosystem by decoupling tokenizer architecture from trained parameters mimicking the modularity of PyTorch&#x27;s . By consolidating &quot;fast&quot; and &quot;slow ...

6. **Tokenizer - Hugging Face**
   https://huggingface.co/docs/transformers/en/main_classes/tokenizer
   We&#x27;re on a journey to advance and democratize artificial intelligence through open source and open science.

7. **Hugging Face Transformers Library - Augment Code**
   https://www.augmentcode.com/open-source/huggingface/transformers
   Transformers is a unified model-definition framework for state-of-the-art machine learning across text, computer vision, audio, video, and multimodal tasks. It serves as the central hub for model definitions, enabling compatibility across training frameworks (PyTorch, JAX, TensorFlow), inference engines (vLLM, SGLang, TGI), and adjacent libraries (llama.cpp, mlx).

8. **transformers/docs/source/en/main_classes/tokenizer.md at main ...**
   https://github.com/huggingface/transformers/blob/main/docs/source/en/main_classes/tokenizer.md
   A tokenizer is in charge of preparing the inputs for a model. The library contains tokenizers for all the models. Most of the tokenizers are available in two flavors: a full python implementation and a &quot;Fast&quot; implementation based on the Rust library 🤗 Tokenizers. The &quot;Fast&quot; implementations allows: a significant speed-up in particular when doing batched tokenization and additional methods to ...

9. **Releases · huggingface/transformers - GitHub**
   https://github.com/huggingface/transformers/releases?after=v3.2.0
   TokenizersBackend (preferred): Rust-based tokenizers from the 🤗 tokenizers library. In general it provides optimal performance, but it also offers a lot more features that are commonly adopted across the ecosystem: handling additional tokens a full python API for setting and updating automatic parallelization, automatic offsets customization ...

10. **Releases · huggingface/transformers - GitHub**
   https://github.com/huggingface/transformers/releases
   TokenizersBackend (preferred): Rust-based tokenizers from the 🤗 tokenizers library. In general it provides optimal performance, but it also offers a lot more features that are commonly adopted across the ecosystem: handling additional tokens a full python API for setting and updating automatic parallelization, automatic offsets customization ...




---

## 🔧 TOOL RESULTS

[web_fetch]
🌐 https://huggingface.co/Daizee/Nanbeige4.1-3B-heretic/raw/main/tokenizer_config.json

{
  "add_bos_token": true,
  "add_eos_token": false,
  "add_prefix_space": true,
  "added_tokens_decoder": {
    "0": {
      "content": "",
      "lstrip": false,
      "normalized": true,
      "rstrip": false,
      "single_word": false,
      "special": true
    },
    "1": {
      "content": "",
      "lstrip": false,
      "normalized": true,
      "rstrip": false,
      "single_word": false,
      "special": true
    },
    "2": {
      "content": "",
      "lstrip": false,
      "normalized": true,
      "rstrip": false,
      "single_word": false,
      "special": true
    },
    "166100": {
      "content": "",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": true
    },
    "166101": {
      "content": "",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": true
    },
    "166102": {
      "content": "",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": true
    },
    "166103": {
      "content": "",
      "lstrip": false,
      "normalized": true,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "166104": {
      "content": "",
      "lstrip": false,
      "normalized": true,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "166105": {
      "content": "",
      "lstrip": false,
      "normalized": true,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "166106": {
      "content": "",
      "lstrip": false,
      "normalized": true,
      "rstrip": false,
      "single_word": false,
      "special": false
    }
  },
  "additional_special_tokens": [
    ""
  ],
  "bos_token": "",
  "clean_up_tokenization_spaces": false,
  "eos_token": "",
  "extra_special_tokens": {},
  "legacy": true,
  "model_max_length": 1000000000000000019884624838656,
  "pad_token": "",
  "sp_model_kwargs": {},
  "spaces_between_special_tokens": false,
  "tokenizer_class": "LlamaTokenizer",
  "unk_token": "",
  "use_default_system_prompt": false
}


This is a critical finding! The **original** model (`Daizee/Nanbeige4.1-3B-heretic`) uses `"tokenizer_class": "LlamaTokenizer"`, but the MLX conversion changed it to `"TokenizersBackend"`. Let me now check the `PreTrainedTokenizerClasses` registration to see if this causes a subtle issue with the Llama-specific tokenizer behavior.



---

## 🔧 TOOL RESULTS

[web_search]
No results found for: "github huggingface swift-transformers "PreTrainedTokenizerClasses" "LlamaPreTrainedTokenizer""


Let me look at the relevant section of the swift-transformers source more carefully - I need to find the `PreTrainedTokenizerClasses` section and the `LlamaPreTrainedTokenizer`.



---

## 🔧 TOOL RESULTS

[web_fetch]
🌐 https://raw.githubusercontent.com/huggingface/swift-transformers/refs/heads/main/Sources/Tokenizers/Tokenizer.swift

//
//  Tokenizer.swift
//
//
//  Created by Pedro Cuenca on 6/5/23.
//

import Foundation
import Hub
import Jinja

/// A type alias for chat messages, represented as key-value pairs.
public typealias Message = [String: any Sendable]

/// A type alias for tool specifications used in chat templating.
public typealias ToolSpec = [String: any Sendable]

/// Errors that can occur during tokenizer operations.
public enum TokenizerError: LocalizedError {
    case missingConfig
    case missingTokenizerClassInConfig
    case unsupportedTokenizer(String)
    case missingVocab
    case malformedVocab
    case chatTemplate(String)
    case missingChatTemplate
    case tooLong(String)
    case mismatchedConfig(String)

    public var errorDescription: String? {
        switch self {
        case .missingConfig:
            String(localized: "Tokenizer configuration is missing.", comment: "Error when tokenizer config cannot be found")
        case .missingTokenizerClassInConfig:
            String(localized: "The tokenizer class is not specified in the configuration.", comment: "Error when tokenizer_class is missing in config")
        case let .unsupportedTokenizer(name):
            String(localized: "The tokenizer type '\(name)' is not supported.", comment: "Error when tokenizer type is not supported")
        case .missingVocab:
            String(localized: "Vocabulary file is missing from the tokenizer configuration.", comment: "Error when vocab file is missing")
        case .malformedVocab:
            String(localized: "The vocabulary file is malformed or corrupted.", comment: "Error when vocab file is malformed")
        case let .chatTemplate(message):
            String(localized: "Chat template error: \(message)", comment: "Error with chat template")
        case .missingChatTemplate:
            String(localized: "This tokenizer does not have a chat template, and no template was passed.")
        case let .tooLong(message):
            String(localized: "Input is too long: \(message)", comment: "Error when input exceeds maximum length")
        case let .mismatchedConfig(message):
            String(localized: "Tokenizer configuration mismatch: \(message)", comment: "Error when tokenizer configuration is inconsistent")
        }
    }
}

/// A protocol defining the core tokenization functionality.
///
/// This protocol defines the fundamental operations that any tokenization model must support,
/// including converting between text and tokens, and between tokens and their numeric IDs.
public protocol TokenizingModel {
    /// Tokenizes the input text into a sequence of tokens.
    ///
    /// - Parameter text: The input text to tokenize
    /// - Returns: An array of tokens as strings
    func tokenize(text: String) -> [String]

    /// Alias for `tokenize` that allows the instance to be called as a function.
    ///
    /// - Parameter text: The input text to tokenize
    /// - Returns: An array of tokens as strings
    func callAsFunction(_ text: String) -> [String]

    /// Converts a token string to its corresponding numeric ID.
    ///
    /// - Parameter token: The token string to convert
    /// - Returns: The numeric ID of the token, or nil if the token is not in the vocabulary
    func convertTokenToId(_ token: String) -> Int?

    /// Converts multiple token strings to their corresponding numeric IDs.
    ///
    /// - Parameter tokens: An array of token strings to convert
    /// - Returns: An array of numeric IDs, with nil values for tokens not in the vocabulary
    func convertTokensToIds(_ tokens: [String]) -> [Int?]

    /// Converts a numeric token ID back to its string representation.
    ///
    /// - Parameter id: The numeric token ID to convert
    /// - Returns: The token string, or nil if the ID is not valid
    func convertIdToToken(_ id: Int) -> String?

    /// Converts multiple numeric token IDs back to their string representations.
    ///
    /// - Parameter ids: An array of numeric token IDs to convert
    /// - Returns: An array of token strings, with nil values for invalid IDs
    func convertIdsToTokens(_ ids: [Int]) -> [String?]

    /// The beginning-of-sequence token string, if defined.
    var bosToken: String? { get }

    /// The numeric ID of the beginning-of-sequence token, if defined.
    var bosTokenId: Int? { get }

    /// The end-of-sequence token string, if defined.
    var eosToken: String? { get }

    /// The numeric ID of the end-of-sequence token, if defined.
    var eosTokenId: Int? { get }

    /// The unknown token string used for out-of-vocabulary words.
    var unknownToken: String? { get }

    /// The numeric ID of the unknown token.
    var unknownTokenId: Int? { get }

    /// Whether consecutive unknown tokens should be fused together.
    var fuseUnknownTokens: Bool { get }
}

/// Helper - possibly to be moved somewhere else
func addedTokenAsString(_ addedToken: Config?) -> String? {
    guard let addedToken else { return nil }
    if let stringValue = addedToken.string() {
        return stringValue
    }
    // This is possibly a serialization of the AddedToken class
    // TODO: support lstrip, rstrip, normalized, etc.
    return addedToken.content.string()
}

public extension TokenizingModel {
    func callAsFunction(_ text: String) -> [String] {
        tokenize(text: text)
    }

    func convertTokensToIds(_ tokens: [String]) -> [Int?] {
        tokens.map { convertTokenToId($0) }
    }

    func convertIdsToTokens(_ ids: [Int]) -> [String?] {
        ids.map { convertIdToToken($0) }
    }
}

/// A tokenizer model that can be initialized from Hugging Face Hub configuration data.
///
/// This protocol extends `TokenizingModel` with the ability to be created from configuration
/// files typically found in tokenizer repositories on the Hugging Face Hub.
public protocol PreTrainedTokenizerModel: TokenizingModel {
    /// Initializes a tokenizer model from configuration data.
    ///
    /// - Parameters:
    ///   - tokenizerConfig: The tokenizer configuration (typically from tokenizer_config.json)
    ///   - tokenizerData: The tokenizer data (typically from tokenizer.json)
    ///   - addedTokens: A dictionary mapping added token strings to their IDs
    /// - Throws: `TokenizerError` if the configuration is invalid or missing required data
    init(tokenizerConfig: Config, tokenizerData: Config, addedTokens: [String: Int]) throws
}

enum TokenizerModel {
    static let knownTokenizers: [String: PreTrainedTokenizerModel.Type] = [
        "BertTokenizer": BertTokenizer.self,
        "CodeGenTokenizer": BPETokenizer.self,
        "CodeLlamaTokenizer": BPETokenizer.self,
        "CohereTokenizer": BPETokenizer.self,
        "DistilbertTokenizer": BertTokenizer.self,
        "DistilBertTokenizer": BertTokenizer.self,
        "FalconTokenizer": BPETokenizer.self,
        "GemmaTokenizer": BPETokenizer.self,
        "GPT2Tokenizer": BPETokenizer.self,
        "LlamaTokenizer": BPETokenizer.self,
        "RobertaTokenizer": BPETokenizer.self,
        "T5Tokenizer": T5Tokenizer.self,
        "TokenizersBackend": BPETokenizer.self,
        "PreTrainedTokenizer": BPETokenizer.self,
        "Qwen2Tokenizer": BPETokenizer.self,
        "WhisperTokenizer": BPETokenizer.self,
        "XLMRobertaTokenizer": UnigramTokenizer.self,
    ]

    static func unknownToken(from tokenizerConfig: Config) -> String? {
        tokenizerConfig.unkToken.content.string() ?? tokenizerConfig.unkToken.string()
    }

    static func from(tokenizerConfig: Config, tokenizerData: Config, addedTokens: [String: Int], strict: Bool = true) throws -> TokenizingModel {
        guard let tokenizerClassName = tokenizerConfig.tokenizerClass.string() else {
            throw TokenizerError.missingTokenizerClassInConfig
        }

        // Some tokenizer_class entries use a Fast suffix
        let tokenizerName = tokenizerClassName.replacingOccurrences(of: "Fast", with: "")
        // Fallback to BPETokenizer if class is not explicitly registered
        let tokenizerClass = TokenizerModel.knownTokenizers[tokenizerName] ?? BPETokenizer.self
        if TokenizerModel.knownTokenizers[tokenizerName] == nil {
            if strict {
                throw TokenizerError.unsupportedTokenizer(tokenizerName)
            } else {
                print("Warning: Tokenizer model class \(tokenizerName) is not registered, falling back to a standard BPE implementation.")
            }
        }
        return try tokenizerClass.init(tokenizerConfig: tokenizerConfig, tokenizerData: tokenizerData, addedTokens: addedTokens)
    }
}

/// Arguments for specifying chat templates when applying chat formatting.
public enum ChatTemplateArgument {
    /// A Jinja template to use for the conversation.
    ///
    /// Normally it is not necessary to provide a template, since it will be read from the tokenizer config.
    case literal(String)

    /// For models whose tokenizer config includes multiple chat templates, the template can be specified by name.
    ///
    /// Normally this is not necessary.
    case name(String)
}

/// A complete tokenizer interface supporting encoding, decoding, and chat template functionality.
///
/// This is the main protocol that defines all tokenizer operations, including text processing,
/// chat template application, and special token handling.
public protocol Tokenizer: Sendable {
    /// Tokenizes the input text into a sequence of tokens.
    ///
    /// - Parameter text: The input text to tokenize
    /// - Returns: An array of tokens as strings
    func tokenize(text: String) -> [String]

    /// Encodes text into token IDs with special tokens included by default.
    ///
    /// This is the main entry point for most tokenization tasks.
    ///
    /// - Parameter text: The input text to encode
    /// - Returns: An array of token IDs
    func encode(text: String) -> [Int]

    /// Encodes text into token IDs with optional special token handling.
    ///
    /// - Parameters:
    ///   - text: The input text to encode
    ///   - addSpecialTokens: Whether to add special tokens (e.g., BOS, EOS)
    /// - Returns: An array of token IDs
    func encode(text: String, addSpecialTokens: Bool) -> [Int]

    /// Function call syntax for encoding text.
    ///
    /// - Parameters:
    ///   - text: The input text to encode
    ///   - addSpecialTokens: Whether to add special tokens
    /// - Returns: An array of token IDs
    func callAsFunction(_ text: String, addSpecialTokens: Bool) -> [Int]

    /// Decodes token IDs back into text with special tokens included.
    ///
    /// - Parameter tokens: The token IDs to decode
    /// - Returns: The decoded text string
    func decode(tokens: [Int]) -> String

    /// Decodes token IDs back into text with optional special token handling.
    ///
    /// - Parameters:
    ///   - tokens: The token IDs to decode
    ///   - skipSpecialTokens: Whether to skip special tokens in the output
    /// - Returns: The decoded text string
    func decode(tokens: [Int], skipSpecialTokens: Bool) -> String

    /// Converts a token string to its corresponding numeric ID.
    ///
    /// - Parameter token: The token string to convert
    /// - Returns: The numeric ID of the token, or nil if not found
    func convertTokenToId(_ token: String) -> Int?

    /// Converts multiple token strings to their corresponding numeric IDs.
    ///
    /// - Parameter tokens: An array of token strings to convert
    /// - Returns: An array of numeric IDs, with nil values for unknown tokens
    func convertTokensToIds(_ tokens: [String]) -> [Int?]

    /// Converts a numeric token ID back to its string representation.
    ///
    /// - Parameter id: The numeric token ID to convert
    /// - Returns: The token string, or nil if the ID is invalid
    func convertIdToToken(_ id: Int) -> String?

    /// Converts multiple numeric token IDs back to their string representations.
    ///
    /// - Parameter ids: An array of numeric token IDs to convert
    /// - Returns: An array of token strings, with nil values for invalid IDs
    func convertIdsToTokens(_ ids: [Int]) -> [String?]

    /// The beginning-of-sequence token string, if defined.
    var bosToken: String? { get }

    /// The numeric ID of the beginning-of-sequence token, if defined.
    var bosTokenId: Int? { get }

    /// The end-of-sequence token string, if defined.
    var eosToken: String? { get }

    /// The numeric ID of the end-of-sequence token, if defined.
    var eosTokenId: Int? { get }

    /// The unknown token string used for out-of-vocabulary words.
    var unknownToken: String? { get }

    /// The numeric ID of the unknown token.
    var unknownTokenId: Int? { get }

    /// Whether this tokenizer has a chat template configured.
    var hasChatTemplate: Bool { get }

    /// Applies the configured chat template to format messages for model input.
    ///
    /// - Parameter messages: Array of message dictionaries representing the conversation
    /// - Returns: Token IDs for the formatted conversation
    /// - Throws: `TokenizerError` if template application fails or no template is available
    func applyChatTemplate(messages: [Message]) throws -> [Int]

    /// Applies the configured chat template with optional tool specifications.
    ///
    /// - Parameters:
    ///   - messages: Array of message dictionaries representing the conversation
    ///   - tools: Optional array of tool specifications for function calling
    /// - Returns: Token IDs for the formatted conversation
    /// - Throws: `TokenizerError` if template application fails or no template is available
    func applyChatTemplate(messages: [Message], tools: [ToolSpec]?) throws -> [Int]

    /// Applies the configured chat template with tools and additional context.
    ///
    /// - Parameters:
    ///   - messages: Array of message dictionaries representing the conversation
    ///   - tools: Optional array of tool specifications for function calling
    ///   - additionalContext: Additional context variables for template rendering
    /// - Returns: Token IDs for the formatted conversation
    /// - Throws: `TokenizerError` if template application fails or no template is available
    func applyChatTemplate(messages: [Message], tools: [ToolSpec]?, additionalContext: [String: any Sendable]?) throws -> [Int]

    /// Applies a specific chat template to format messages.
    ///
    /// - Parameters:
    ///   - messages: Array of message dictionaries representing the conversation
    ///   - chatTemplate: The chat template to use (literal template or template name)
    /// - Returns: Token IDs for the formatted conversation
    /// - Throws: `TokenizerError` if template application fails
    func applyChatTemplate(messages: [Message], chatTemplate: ChatTemplateArgument) throws -> [Int]

    /// Applies a chat template provided as a literal string.
    ///
    /// - Parameters:
    ///   - messages: Array of message dictionaries representing the conversation
    ///   - chatTemplate: The Jinja template string to use for formatting
    /// - Returns: Token IDs for the formatted conversation
    /// - Throws: `TokenizerError` if template application fails
    func applyChatTemplate(messages: [Message], chatTemplate: String) throws -> [Int]

    /// Applies a chat template with full control over all parameters.
    ///
    /// - Parameters:
    ///   - messages: Array of message dictionaries representing the conversation
    ///   - chatTemplate: Optional chat template specification
    ///   - addGenerationPrompt: Whether to add a generation prompt for the assistant
    ///   - truncation: Whether to truncate if the result exceeds maximum length
    ///   - maxLength: Maximum allowed token length
    ///   - tools: Optional array of tool specifications for function calling
    /// - Returns: Token IDs for the formatted conversation
    /// - Throws: `TokenizerError` if template application fails
    func applyChatTemplate(
        messages: [Message],
        chatTemplate: ChatTemplateArgument?,
        addGenerationPrompt: Bool,
        truncation: Bool,
        maxLength: Int?,
        tools: [ToolSpec]?
    ) throws -> [Int]

    /// Applies a chat template with full control over all parameters including additional context.
    ///
    /// - Parameters:
    ///   - messages: Array of message dictionaries representing the conversation
    ///   - chatTemplate: Optional chat template specification
    ///   - addGenerationPrompt: Whether to add a generation prompt for the assistant
    ///   - truncation: Whether to truncate if the result exceeds maximum length
    ///   - maxLength: Maximum allowed token length
    ///   - tools: Optional array of tool specifications for function calling
    ///   - additionalContext: Additional context variables for template rendering
    /// - Returns: Token IDs for the formatted conversation
    /// - Throws: `TokenizerError` if template application fails
    func applyChatTemplate(
        messages: [Message],
        chatTemplate: ChatTemplateArgument?,
        addGenerationPrompt: Bool,
        truncation: Bool,
        maxLength: Int?,
        tools: [ToolSpec]?,
        additionalContext: [String: any Sendable]?
    ) throws -> [Int]
}

extension Tokenizer {
    public var hasChatTemplate: Bool { false }

    /// Call previous signature for backwards compatibility
    func applyChatTemplate(
        messages: [Message],
        // A chat template can optionally be provided or specified by name when several templates are included in the tokenizer config. Normally this is not necessary.
        chatTemplate: ChatTemplateArgument?,
        addGenerationPrompt: Bool,
        truncation: Bool,
        maxLength: Int?,
        tools: [ToolSpec]?,
        additionalContext: [String: any Sendable]?
    ) throws -> [Int] {
        if additionalContext == nil {
            try applyChatTemplate(
                messages: messages, chatTemplate: chatTemplate, addGenerationPrompt: addGenerationPrompt, truncation: truncation, maxLength: maxLength,
                tools: tools
            )
        } else {
            throw TokenizerError.chatTemplate("Not implemented")
        }
    }
}

public extension Tokenizer {
    func callAsFunction(_ text: String, addSpecialTokens: Bool = true) -> [Int] {
        encode(text: text, addSpecialTokens: addSpecialTokens)
    }

    func decode(tokens: [Int]) -> String {
        decode(tokens: tokens, skipSpecialTokens: false)
    }

    func convertTokensToIds(_ tokens: [String]) -> [Int?] {
        tokens.map { convertTokenToId($0) }
    }

    func convertIdsToTokens(_ ids: [Int]) -> [String?] {
        ids.map { convertIdToToken($0) }
    }
}

let specialTokenAttributes: [String] = [
    "bos_token",
    "eos_token",
    "unk_token",
    "sep_token",
    "pad_token",
    "cls_token",
    "mask_token",
    "additional_special_tokens",
]

/// A comprehensive tokenizer implementation supporting pre-trained models from Hugging Face.
///
/// This class provides a complete tokenizer implementation that can be initialized from
/// Hugging Face Hub configuration files and supports all standard tokenization operations
/// including chat template application, normalization, pre-tokenization, and post-processing.
public class PreTrainedTokenizer: @unchecked Sendable, Tokenizer {
    let model: TokenizingModel

    public var bosToken: String? { model.bosToken }
    public var bosTokenId: Int? { model.bosTokenId }
    public var eosToken: String? { model.eosToken }
    public var eosTokenId: Int? { model.eosTokenId }
    public var unknownToken: String? { model.unknownToken }
    public var unknownTokenId: Int? { model.unknownTokenId }
    public var fuseUnknownTokens: Bool { model.fuseUnknownTokens }

    let addedTokens: Set
    let specialTokens: [String: Int]
    let addedTokensRegex: NSRegularExpression?

    private let preTokenizer: PreTokenizer?
    private let normalizer: Normalizer?
    private let postProcessor: PostProcessor?
    private let decoder: Decoder?
    private let tokenizerConfig: Config

    private let cleanUpTokenizationSpaces: Bool

    /// Cache for compiled Jinja templates keyed by their literal template string
    private var compiledChatTemplateCache: [String: Template] = [:]

    /// Lock to protect the compiled chat template cache from concurrent access
    private let cacheLock = NSLock()

    /// Initializes a tokenizer from Hugging Face configuration files.
    ///
    /// - Parameters:
    ///   - tokenizerConfig: Configuration from tokenizer_config.json
    ///   - tokenizerData: Configuration from tokenizer.json
    ///   - strict: Whether to enforce strict validation of tokenizer types
    /// - Throws: `TokenizerError` if configuration is invalid or tokenizer type is unsupported
    public required init(tokenizerConfig: Config, tokenizerData: Config, strict: Bool = true) throws {
        var addedTokens: [String: Int] = [:]
        var specialTokens: [String: Int] = [:]
        for addedToken in tokenizerData["addedTokens"].array(or: []) {
            guard let id = addedToken["id"].integer() else { continue } // malformed: token with no id
            guard let content = addedToken.content.string() else { continue } // malformed: token with no content
            addedTokens[content] = id

            if addedToken["special"].boolean(or: false) {
                specialTokens[content] = id
            }
        }

        // Convert to tuples for easier access, then sort by length (descending) to avoid early partial matches
        // (https://github.com/xenova/transformers.js/commit/c305c3824f628f1f02806a6310bd3b18b0f7f8f5)
        let unwrappedAddedTokens: [(content: String, prefix: Bool, suffix: Bool)] = (tokenizerData["addedTokens"].array(or: [])).compactMap { addedToken -> (String, Bool, Bool)? in
            guard let content = addedToken.content.string() else { return nil }
            let prefix = addedToken["lstrip"].boolean(or: false)
            let suffix = addedToken["rstrip"].boolean(or: false)
            return (content: content, prefix: prefix, suffix: suffix)
        }.sorted {
            $0.content.count > $1.content.count
        }

        // then concatenate into regular expression
        let addedTokensRegexString = unwrappedAddedTokens.map {
            let token = NSRegularExpression.escapedPattern(for: $0.content)
            let prefix = $0.prefix ? #"\s*"# : ""
            let suffix = $0.suffix ? #"\s*"# : ""
            return "\(prefix)(\(token))\(suffix)"
        }.joined(separator: "|")
        addedTokensRegex = try? NSRegularExpression(pattern: addedTokensRegexString, options: [])

        self.specialTokens = specialTokens
        self.addedTokens = Set(addedTokens.keys)

        preTokenizer = PreTokenizerFactory.fromConfig(config: tokenizerData["preTokenizer"])
        normalizer = NormalizerFactory.fromConfig(config: tokenizerData["normalizer"])
        postProcessor = PostProcessorFactory.fromConfig(config: tokenizerData["postProcessor"])
        decoder = DecoderFactory.fromConfig(config: tokenizerData["decoder"], addedTokens: self.addedTokens)
        cleanUpTokenizationSpaces = tokenizerConfig.cleanUpTokenizationSpaces.boolean(or: true)
        self.tokenizerConfig = tokenizerConfig

        model = try TokenizerModel.from(tokenizerConfig: tokenizerConfig, tokenizerData: tokenizerData, addedTokens: addedTokens, strict: strict)
    }

    private func compiledTemplate(for templateString: String) throws -> Template {
        // Fast path: check cache under lock
        cacheLock.lock()
        if let cached = compiledChatTemplateCache[templateString] {
            cacheLock.unlock()
            return cached
        }
        cacheLock.unlock()

        // Compile template outside of lock to avoid holding lock during expensive operation
        let compiled = try Template(templateString)

        // Insert into cache under lock (using double-checked locking pattern)
        cacheLock.lock()
        defer { cacheLock.unlock() }

        // Check again in case another thread compiled the same template
        if let cached = compiledChatTemplateCache[templateString] {
            return cached
        }

        compiledChatTemplateCache[templateString] = compiled
        return compiled
    }

    func preTokenize(_ text: String, options: PreTokenizerOptions) -> [String] {
        guard let preTokenizer else { return [text] }
        return preTokenizer(text: text, options: options)
    }

    func normalize(_ text: String) -> String {
        guard let normalizer else { return text }
        return normalizer(text: text)
    }

    func postProcess(_ tokens: [String], addSpecialTokens: Bool = true) -> [String] {
        guard let postProcessor else { return tokens }
        return postProcessor(tokens: tokens, addSpecialTokens: addSpecialTokens)
    }

    func decodeTokens(_ tokens: [String]) -> [String] {
        guard let tokenDecoder = decoder else { return tokens }
        return tokenDecoder(tokens: tokens)
    }

    /// Clean up a list of simple English tokenization artifacts like spaces before punctuations and abbreviated forms
    func cleanUp(text: String) -> String {
        guard cleanUpTokenizationSpaces else { return text }

        return
            text
            .replacingOccurrences(of: " .", with: ".")
            .replacingOccurrences(of: " ?", with: "?")
            .replacingOccurrences(of: " !", with: "!")
            .replacingOccurrences(of: " ,", with: ",")
            .replacingOccurrences(of: " ' ", with: "'")
            .replacingOccurrences(of: " n't", with: "n't")
            .replacingOccurrences(of: " 'm", with: "'m")
            .replacingOccurrences(of: " 's", with: "'s")
            .replacingOccurrences(of: " 've", with: "'ve")
            .replacingOccurrences(of: " 're", with: "'re")
    }

    func fuseUnknown(_ tokens: [String]) -> [String] {
        guard fuseUnknownTokens else { return tokens }
        let (fused, _) = tokens.reduce((fused: [String](), previousIsUnknown: false)) { result, token in
            var (fused, previousIsUnknown) = result
            let isUnknown = model.convertTokenToId(token) == model.unknownTokenId
            if isUnknown {
                if !previousIsUnknown { fused.append(token) }
            } else {
                fused.append(token)
            }
            return (fused, isUnknown)
        }
        return fused
    }

    /// Tokenizes input text using the configured normalization and pre-tokenization steps.
    ///
    /// - Parameter text: The input text to tokenize
    /// - Returns: An array of token strings
    public func tokenize(text: String) -> [String] {
        // Take care of special tokens first
        let sections: [String] =
            if let regex = addedTokensRegex {
                text.split(by: regex)
            } else {
                [text]
            }
        return sections.enumerated().map { section, x in
            if addedTokens.contains(x) { return [x] }
            return preTokenize(normalize(x), options: section == 0 ? [.firstSection] : []).flatMap { model($0) }
        }.flatMap { fuseUnknown($0) }
    }

    /// Encodes input text into token IDs with optional special token handling.
    ///
    /// This is the main entry point for text encoding operations.
    ///
    /// - Parameters:
    ///   - text: The input text to encode
    ///   - addSpecialTokens: Whether to add special tokens during post-processing
    /// - Returns: An array of token IDs
    public func encode(text: String, addSpecialTokens: Bool = true) -> [Int] {
        postProcess(tokenize(text: text), addSpecialTokens: addSpecialTokens).map { model.convertTokenToId($0)! }
    }

    /// Encodes input text into token IDs with special tokens included by default.
    ///
    /// - Parameter text: The input text to encode
    /// - Returns: An array of token IDs
    public func encode(text: String) -> [Int] {
        encode(text: text, addSpecialTokens: true)
    }

    /// Decodes token IDs back into human-readable text.
    ///
    /// - Parameters:
    ///   - tokens: The token IDs to decode
    ///   - skipSpecialTokens: Whether to exclude special tokens from the output text
    /// - Returns: The decoded text string
    public func decode(tokens: [Int], skipSpecialTokens: Bool = false) -> String {
        // IDs to tokens
        let tokenStrings: [String]
        if skipSpecialTokens {
            let specialTokenIDs = Set(specialTokens.values)
            tokenStrings =
                tokens
                .filter { !specialTokenIDs.contains($0) }
                .compactMap { model.convertIdToToken($0) }
        } else {
            tokenStrings = tokens.compactMap { model.convertIdToToken($0) }
        }
        let decoded = decodeTokens(tokenStrings)
        // At this point we should have a single String
        return cleanUp(text: decoded.joined(separator: ""))
    }

    /// Converts a token string to its corresponding numeric ID.
    ///
    /// - Parameter token: The token string to convert
    /// - Returns: The numeric ID of the token, or nil if not found in the vocabulary
    public func convertTokenToId(_ token: String) -> Int? {
        model.convertTokenToId(token)
    }

    /// Converts a numeric token ID back to its string representation.
    ///
    /// - Parameter id: The numeric token ID to convert
    /// - Returns: The token string, or nil if the ID is invalid
    public func convertIdToToken(_ id: Int) -> String? {
        model.convertIdToToken(id)
    }

    /// Whether this tokenizer has a chat template configured.
    public var hasChatTemplate: Bool {
        !tokenizerConfig.chatTemplate.isNull()
    }

    public func applyChatTemplate(messages: [Message]) throws -> [Int] {
        try applyChatTemplate(messages: messages, addGenerationPrompt: true)
    }

    public func applyChatTemplate(messages: [Message], tools: [ToolSpec]? = nil) throws -> [Int] {
        try applyChatTemplate(messages: messages, addGenerationPrompt: true, tools: tools)
    }

    public func applyChatTemplate(messages: [Message], tools: [ToolSpec]? = nil, additionalContext: [String: any Sendable]? = nil) throws
        -> [Int]
    {
        try applyChatTemplate(
            messages: messages,
            addGenerationPrompt: true,
            tools: tools,
            additionalContext: additionalContext
        )
    }

    public func applyChatTemplate(messages: [Message], chatTemplate: ChatTemplateArgument) throws -> [Int] {
        try applyChatTemplate(messages: messages, chatTemplate: chatTemplate, addGenerationPrompt: true)
    }

    public func applyChatTemplate(messages: [Message], chatTemplate: String) throws -> [Int] {
        try applyChatTemplate(messages: messages, chatTemplate: .literal(chatTemplate), addGenerationPrompt: true)
    }

    public func applyChatTemplate(
        messages: [Message],
        chatTemplate: ChatTemplateArgument? = nil,
        addGenerationPrompt: Bool = false,
        truncation: Bool = false,
        maxLength: Int? = nil,
        tools: [ToolSpec]? = nil
    ) throws -> [Int] {
        try applyChatTemplate(
            messages: messages, chatTemplate: chatTemplate, addGenerationPrompt: addGenerationPrompt, truncation: truncation, maxLength: maxLength,
            tools: tools, additionalContext: nil
        )
    }

    public func applyChatTemplate(
        messages: [Message],
        chatTemplate: ChatTemplateArgument? = nil,
        addGenerationPrompt: Bool = false,
        truncation: Bool = false,
        maxLength: Int? = nil,
        // A list of tools (callable functions) that will be accessible to the model. If the template does not
        // support function calling, this argument will have no effect. Each tool should be passed as a JSON Schema,
        // giving the name, description and argument types for the tool. See the
        // [chat templating guide](https://huggingface.co/docs/transformers/main/en/chat_templating#automated-function-conversion-for-tool-use)
        // for more information.
        tools: [ToolSpec]? = nil,
        additionalContext: [String: any Sendable]? = nil
    ) throws -> [Int] {
        var selectedChatTemplate: String?
        if let chatTemplate, case let .literal(template) = chatTemplate {
            // Use chat template from argument
            selectedChatTemplate = template
        } else if !tokenizerConfig.chatTemplate.isNull() {
            let valueFromConfig: Config = tokenizerConfig.chatTemplate
            if let arrayValue = valueFromConfig.array() {
                // If the config specifies a list of chat templates, convert them to a dictionary
                let templateDict = [String: String](
                    uniqueKeysWithValues: arrayValue.compactMap { item in
                        guard let name = item["name"].string(), let template = item["template"].string() else {
                            return nil
                        }
                        return (name, template)
                    })
                if let chatTemplate, case let .name(name) = chatTemplate {
                    // Select chat template from config by name
                    if let matchingDictEntry = templateDict[name] {
                        selectedChatTemplate = matchingDictEntry
                    } else {
                        throw TokenizerError.chatTemplate("No chat template named \"\(name)\" was found in the tokenizer config")
                    }
                } else if let tools, !tools.isEmpty, let toolUseTemplate = templateDict["tool_use"] {
                    // Use tool use chat template from config
                    selectedChatTemplate = toolUseTemplate
                } else if let defaultChatTemplate = templateDict["default"] {
                    // Use default chat template from config
                    selectedChatTemplate = defaultChatTemplate
                }
            } else if let stringValue = valueFromConfig.string() {
                // Use chat template from config
                selectedChatTemplate = stringValue
            }
        }

        guard let selectedChatTemplate else {
            throw TokenizerError.missingChatTemplate
        }

        let template = try compiledTemplate(for: selectedChatTemplate)
        var context: [String: Jinja.Value] = try [
            "messages": .array(messages.map { try Value(any: $0) }),
            "add_generation_prompt": .boolean(addGenerationPrompt),
        ]
        if let tools {
            context["tools"] = try .array(tools.map { try Value(any: $0) })
        }
        if let additionalContext {
            // Additional keys and values to be added to the context provided to the prompt templating engine.
            // For example, the app could set "tools_in_user_message" to false for Llama 3.1 and 3.2 if a system message is provided.
            // The default value is true in the Llama 3.1 and 3.2 chat templates, but these models will perform better if the tools are included in a system message.
            for (key, value) in additionalContext {
                context[key] = try Value(any: value)
            }
        }

        for (key, value) in tokenizerConfig.dictionary(or: [:]) {
            if specialTokenAttributes.contains(key.string), !value.isNull() {
                if let stringValue = value.string() {
                    context[key.string] = .string(stringValue)
                } else if let dictionary = value.dictionary() {
                    if let addedTokenString = addedTokenAsString(Config(dictionary)) {
                        context[key.string] = .string(addedTokenString)
                    }
                } else if let array: [String] = value.get() {
                    context[key.string] = .array(array.map { .string($0) })
                } else {
                    context[key.string] = try Value(any: value)
                }
            }
        }

        let rendered = try template.render(context)
        var encodedTokens = encode(text: rendered, addSpecialTokens: false)
        var maxLength = maxLength ?? encodedTokens.count
        maxLength = min(maxLength, tokenizerConfig.modelMaxLength.integer() ?? maxLength)
        if encodedTokens.count > maxLength {
            if truncation {
                encodedTokens = Array(encodedTokens.prefix(maxLength))
            }
        }

        return encodedTokens
    }
}

// MARK: - Building

/// A namespace for automatically creating appropriate tokenizer instances.
///
/// `AutoTokenizer` provides static methods for loading pre-trained tokenizers
/// from the Hugging Face Hub or local directories. It automatically selects
/// the appropriate tokenizer class based on the configuration.
public enum AutoTokenizer {}

enum PreTrainedTokenizerClasses {
    /// Class overrides for custom behaviour
    /// Not to be confused with the TokenizerModel classes defined in TokenizerModel
    static let tokenizerClasses: [String: PreTrainedTokenizer.Type] = [
        "LlamaTokenizer": LlamaPreTrainedTokenizer.self
    ]
}

public extension AutoTokenizer {
    /// Determines the appropriate tokenizer class for the given configuration.
    ///
    /// - Parameter tokenizerConfig: The tokenizer configuration
    /// - Returns: The appropriate `PreTrainedTokenizer` subclass
    internal static func tokenizerClass(for tokenizerConfig: Config) -> PreTrainedTokenizer.Type {
        guard let tokenizerClassName = tokenizerConfig.tokenizerClass.string() else {
            return PreTrainedTokenizer.self
        }

        // Some tokenizer_class entries use a Fast suffix
        let tokenizerName = tokenizerClassName.replacingOccurrences(of: "Fast", with: "")
        if let tokenizerClass = PreTrainedTokenizerClasses.tokenizerClasses[tokenizerName] {
            return tokenizerClass
        }

        return PreTrainedTokenizer.self
    }

    /// Creates a tokenizer from configuration objects.
    ///
    /// - Parameters:
    ///   - tokenizerConfig: The tokenizer configuration (from tokenizer_config.json)
    ///   - tokenizerData: The tokenizer data (from tokenizer.json)
    ///   - strict: Whether to enforce strict validation
    /// - Returns: A configured `Tokenizer` instance
    /// - Throws: `TokenizerError` if configuration is invalid
    static func from(tokenizerConfig: Config, tokenizerData: Config, strict: Bool = true) throws -> Tokenizer {
        let tokenizerClass = tokenizerClass(for: tokenizerConfig)
        return try tokenizerClass.init(tokenizerConfig: tokenizerConfig, tokenizerData: tokenizerData, strict: strict)
    }

    /// Loads a tokenizer from a pre-trained model on the Hugging Face Hub.
    ///
    /// - Parameters:
    ///   - model: The model identifier (e.g., "bert-base-uncased")
    ///   - hubApi: The Hub API instance to use for downloading
    ///   - strict: Whether to enforce strict validation
    /// - Returns: A configured `Tokenizer` instance
    /// - Throws: `TokenizerError` if the model cannot be loaded or configured
    static func from(
        pretrained model: String,
        hubApi: HubApi = .shared,
        strict: Bool = true
    ) async throws -> Tokenizer {
        let config = LanguageModelConfigurationFromHub(modelName: model, hubApi: hubApi)
        guard let tokenizerConfig = try await config.tokenizerConfig else { throw TokenizerError.missingConfig }
        let tokenizerData = try await config.tokenizerData

        return try AutoTokenizer.from(tokenizerConfig: tokenizerConfig, tokenizerData: tokenizerData, strict: strict)
    }

    /// Loads a tokenizer from a local model folder.
    ///
    /// - Parameters:
    ///   - modelFolder: The URL path to the local model folder
    ///   - hubApi: The Hub API instance to use (unused for local loading)
    ///   - strict: Whether to enforce strict validation
    /// - Returns: A configured `Tokenizer` instance
    /// - Throws: `TokenizerError` if the model folder is invalid or missing files
    static func from(
        modelFolder: URL,
        hubApi: HubApi = .shared,
        strict: Bool = true
    ) async throws -> Tokenizer {
        let config = LanguageModelConfigurationFromHub(modelFolder: modelFolder, hubApi: hubApi)
        guard let tokenizerConfig = try await config.tokenizerConfig else { throw TokenizerError.missingConfig }
        let tokenizerData = try await config.tokenizerData

        return try PreTrainedTokenizer(tokenizerConfig: tokenizerConfig, tokenizerData: tokenizerData, strict: strict)
    }
}

// MARK: - Tokenizer model classes

class T5Tokenizer: UnigramTokenizer, @unchecked Sendable {}

// MARK: - PreTrainedTokenizer classes

let sentencePieceUnderline = "▁"

/// Hack for Llama tokenizers, see https://github.com/huggingface/transformers/blob/bcb841f0073fcd7a4fb88ea8064313c17dcab04a/src/transformers/models/llama/tokenization_llama_fast.py#L181
/// Return updated config, or nil
func maybeUpdatePostProcessor(tokenizerConfig: Config, processorConfig: Config?) throws -> Config? {
    // If it's already a Template processor (instead of a ByteLevel one), assume it's correct
    let postProcessor = PostProcessorFactory.fromConfig(config: processorConfig)
    guard !(postProcessor is TemplateProcessing) else { return nil }

    let addBosToken = tokenizerConfig.addBosToken.boolean(or: false)
    let bosToken = addedTokenAsString(tokenizerConfig.bosToken)
    if addBosToken, bosToken == nil {
        throw TokenizerError.mismatchedConfig("add_bos_token is True but bos_token is nil")
    }

    let addEosToken = tokenizerConfig.addEosToken.boolean(or: false)
    let eosToken = addedTokenAsString(tokenizerConfig.eosToken)
    if addEosToken, eosToken == nil {
        throw TokenizerError.mismatchedConfig("add_eos_token is True but eos_token is nil")
    }

    // alt implementation
    var single: [[String: Any]] = []
    if addBosToken {
        single = single + [["SpecialToken": ["id": bosToken!, "type_id": 0]]]
    }
    single = single + [["Sequence": ["id": "A", "type_id": 0]]]
    if addEosToken {
        single = single + [["SpecialToken": ["id": eosToken!, "type_id": 0]]]
    }

    var pair: [[String: Any]] = single
    if addBosToken {
        pair = pair + [["SpecialToken": ["id": bosToken!, "type_id": 1]]]
    }
    pair = pair + [["Sequence": ["id": "B", "type_id": 1]]]
    if addEosToken {
        pair = pair + [["SpecialToken": ["id": eosToken!, "type_id": 1]]]
    }

    let postProcessorConfig = Config(["type": PostProcessorType.TemplateProcessing.rawValue, "single": single, "pair": pair])
    return postProcessorConfig
}

/// See https://github.com/xenova/transformers.js/blob/1a9964fb09b8f54fcbeac46dc6aae8d76795809d/src/tokenizers.js#L3203 for these exceptions
class LlamaPreTrainedTokenizer: PreTrainedTokenizer, @unchecked Sendable {
    let isLegacy: Bool

    required init(tokenizerConfig: Config, tokenizerData: Config, strict: Bool = true) throws {
        isLegacy = tokenizerConfig.legacy.boolean(or: true)
        var configDictionary = tokenizerData.dictionary(or: [:])
        if !isLegacy {
            _ = configDictionary.removeValue(forKey: "normalizer")
            configDictionary["pre_tokenizer"] = [
                "type": "Metaspace", "replacement": .init(sentencePieceUnderline), "add_prefix_space": true, "prepend_scheme": "first",
            ]
        }

        if let postProcessorConfig = try maybeUpdatePostProcessor(tokenizerConfig: tokenizerConfig, processorConfig: tokenizerData["postProcessor"]) {
            configDictionary["post_processor"] = .init(postProcessorConfig.dictionary(or: [:]))
        }

        let updatedData = Config(configDictionary)
        try super.init(tokenizerConfig: tokenizerConfig, tokenizerData: updatedData, strict: strict)
    }

    /// If `isLegacy` is `False`, a prefix token is added unless the first token is special.
    /// https://github.com/huggingface/transformers/blob/e6dcf8abd6f65bb4b6dfc1831b20d9ba49ce00e2/src/transformers/models/t5/tokenization_t5.py#L374-L387
    override func tokenize(text: String) -> [String] {
        if isLegacy || text.isEmpty {
            return super.tokenize(text: text)
        }

        let tokens = super.tokenize(text: sentencePieceUnderline + text.replacingOccurrences(of: sentencePieceUnderline, with: " "))
        if tokens.first == sentencePieceUnderline, let second = tokens.dropFirst().first, specialTokens[second] != nil {
            return Array(tokens[1...])
        }
        return tokens
    }
}


Now I have the complete picture. Let me check if there are alternative 4-bit conversions with the correct tokenizer class.



---

## 🔧 TOOL RESULTS

[web_search]
No results found for: "Nanbeige4.1-3B mlx 4bit "LlamaTokenizer" huggingface"




---

## 🔧 TOOL RESULTS

[web_search]
🔍 DuckDuckGo results for "Nanbeige4.1-3B mlx 4bit quantized huggingface" (10 results):

1. **cyankiwi/Nanbeige4.1-3B-AWQ-4bit · Hugging Face**
   https://huggingface.co/cyankiwi/Nanbeige4.1-3B-AWQ-4bit
   Introduction Nanbeige4.1-3B is built upon Nanbeige4-3B-Base and represents an enhanced iteration of our previous reasoning model, Nanbeige4-3B-Thinking-2511, achieved through further post-training optimization with supervised fine-tuning (SFT) and reinforcement learning (RL).

2. **Nanbeige4.1-3B | AI Model Details**
   https://www.aimodels.fyi/models/huggingFace/nanbeige4.1-3b-nanbeige
   Model overview Nanbeige4.1-3B represents an enhanced iteration built on the foundation of its predecessor Nanbeige4-3B-Thinking-2511, achieving significant improvements through supervised fine-tuning and reinforcement learning optimization. This compact 3-billion parameter model demonstrates that smaller models can simultaneously excel at reasoning, preference alignment, and agentic behaviors ...

3. **Nanbeige4-3B Technical Report: Exploring the Frontier of Small Language ...**
   https://arxiv.org/html/2512.06266v1
   The model checkpoints are available at https://huggingface.co/Nanbeige. Figure 1: Performance Comparison between Nanbeige4-3B-Thinking and Qwen series models. 1 Introduction

4. **mlx-community/Nanbeige4.1-3B-8bit - AI Model Details &amp; Pricing | AI ...**
   https://www.aitimelines.club/models/mlx-community%2FNanbeige4.1-3B-8bit
   Explore mlx-community/Nanbeige4.1-3B-8bit AI model. 122 downloads, 4 likes. Open source model.

5. **Nanbeige4-3B Technical Report: Exploring the ... - Semantic Scholar**
   https://www.semanticscholar.org/paper/Nanbeige4-3B-Technical-Report%3A-Exploring-the-of-Yang-Peng/c455dd978d2150004df195625a8aa9bf1979c935
   This work presents Nanbeige4-3B, a family of small-scale but high-performing language models, and designs a joint mechanism that integrates deliberative generation refinement and chain-of-thought reconstruction, yielding substantial gains on complex tasks. We present Nanbeige4-3B, a family of small-scale but high-performing language models. Pretrained on 23T high-quality tokens and finetuned ...

6. **Nanbeige4-3B: 3B-Scale Transformer Model**
   https://www.emergentmind.com/topics/nanbeige4-3b
   Nanbeige4-3B is a 3B-parameter decoder-only Transformer that achieves superior benchmark performance via innovative data curation and specialized training.

7. **(PDF) Nanbeige4-3B Technical Report: Exploring the ... - ResearchGate**
   https://www.researchgate.net/publication/398475286_Nanbeige4-3B_Technical_Report_Exploring_the_Frontier_of_Small_Language_Models
   The model checkpoints are available at https://huggingface.co/Nanbeige. Figure 1: Performance Comparison between Nanbeige4-3B-Thinking and Qwen series models. Preprint.

8. **Use Quantization with Hugging Face Models - mobiarch**
   https://mobiarch.wordpress.com/2024/03/18/use-quantization-with-hugging-face-models/
   Most LLM models today use 32-bit or 16-bit floating point for the parameters (weights). Due to the large number of parameters involved a lot of GPU VRAM and regular RAM memory is needed to work with these models. Quantization algorithms convert the parameters into 8bit or 4bit floating point thereby reducing the memory and computational…

9. **Nanbeige/Nanbeige4.1-3B · Hugging Face**
   https://huggingface.co/Nanbeige/Nanbeige4.1-3B
   Introduction Nanbeige4.1-3B is built upon Nanbeige4-3B-Base and represents an enhanced iteration of our previous reasoning model, Nanbeige4-3B-Thinking-2511, achieved through further post-training optimization with supervised fine-tuning (SFT) and reinforcement learning (RL). As a highly competitive open-source model at a small parameter scale, Nanbeige4.1-3B illustrates that compact models ...

10. **Quantized Models for Nanbeige/Nanbeige4.1-3B - Hugging Face**
   https://huggingface.co/models?other=base_model:quantized:Nanbeige/Nanbeige4.1-3B
   Active filters: Nanbeige/Nanbeige4.1-3B. Clear all . Edge-Quant/Nanbeige4.1-3B-Q4_K_M-GGUF. Text Generation • 4B • Updated about 6 hours ago • 2




---

## 🔧 TOOL RESULTS

[web_search]
🔍 DuckDuckGo results for "site:huggingface.co mlx-community Nanbeige4.1-3B 4bit" (10 results):

1. **mlx-community/Nanbeige4.1-3B-heretic-4bit · Hugging Face**
   https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit
   This model mlx-community/Nanbeige4.1-3B-heretic-4bit was converted to MLX format from Daizee/Nanbeige4.1-3B-heretic using mlx-lm version 0.30.7.

2. **mlx-community/Nanbeige4.1-3B-8bit · Hugging Face**
   https://huggingface.co/mlx-community/Nanbeige4.1-3B-8bit
   We&#x27;re on a journey to advance and democratize artificial intelligence through open source and open science.

3. **Nanbeige/Nanbeige4.1-3B · Hugging Face**
   https://huggingface.co/Nanbeige/Nanbeige4.1-3B
   Introduction Nanbeige4.1-3B is built upon Nanbeige4-3B-Base and represents an enhanced iteration of our previous reasoning model, Nanbeige4-3B-Thinking-2511, achieved through further post-training optimization with supervised fine-tuning (SFT) and reinforcement learning (RL). As a highly competitive open-source model at a small parameter scale, Nanbeige4.1-3B illustrates that compact models ...

4. **mlx-community/Nanbeige4.1-3B-8bit at main - Hugging Face**
   https://huggingface.co/mlx-community/Nanbeige4.1-3B-8bit/tree/main
   Nanbeige4.1-3B-8bit like 2 MLX Community 8.63k Text Generation MLX Safetensors English Chinese llama llm nanbeige conversational 8-bit precision License:apache-2.0 Model card FilesFiles and versions xet Community Use this model main Nanbeige4.1-3B-8bit 4.2 GB 1 contributor History:2 commits ivanfioravanti Add files using upload-large-folder tool

5. **mlx-community/Nanbeige4-3B-Thinking-2511-gabliterated-8bit · Hugging Face**
   https://huggingface.co/mlx-community/Nanbeige4-3B-Thinking-2511-gabliterated-8bit
   This model mlx-community/Nanbeige4-3B-Thinking-2511-gabliterated-8bit was converted to MLX format from Goekdeniz-Guelmez/Nanbeige4-3B-Thinking-2511-gabliterated using mlx-lm version 0.30.2.

6. **RepublicOfKorokke/Nanbeige4.1-3B-mlx-nvfp4 · Hugging Face**
   https://huggingface.co/RepublicOfKorokke/Nanbeige4.1-3B-mlx-nvfp4
   Nanbeige4.1-3B-mlx-nvfp4 like 0 Text Generation MLX Safetensors English Chinese llama llm nanbeige conversational 4-bit precision License:apache-2.0 Model card FilesFiles and versions xet Community Use this model

7. **McG-221/Nanbeige4.1-3B-mlx-8Bit · Hugging Face**
   https://huggingface.co/McG-221/Nanbeige4.1-3B-mlx-8Bit
   We&#x27;re on a journey to advance and democratize artificial intelligence through open source and open science.

8. **Nanbeige LLM Lab - Hugging Face**
   https://huggingface.co/Nanbeige
   Org profile for Nanbeige LLM Lab on Hugging Face, the AI community building the future.

9. **mlx-community/Nanbeige4.1-3B-8bit · Discussions - Hugging Face**
   https://huggingface.co/mlx-community/Nanbeige4.1-3B-8bit/discussions
   Nanbeige4.1-3B-8bit like 2 MLX Community 8.63k Text Generation MLX Safetensors English Chinese llama llm nanbeige conversational 8-bit precision License:apache-2.0 Model card FilesFiles and versions xet Community Use this model New discussion New pull request Resources PR &amp; discussions documentation Code of Conduct Hub documentation All ...

10. **WaveCut/Nanbeige4.1-3B-mlx_8bit - Hugging Face**
   https://huggingface.co/WaveCut/Nanbeige4.1-3B-mlx_8bit
   WaveCut / Nanbeige4.1-3B-mlx_8bit like 0 Text Generation MLX Safetensors English Chinese llama llm nanbeige conversational 8-bit precision License:apache-2.0 Model card FilesFiles and versions xet Community Use this model WaveCut/Nanbeige4.1-3B-mlx_8bit Use with mlx




---

## 🔧 TOOL RESULTS

[web_fetch]
🌐 https://huggingface.co/RepublicOfKorokke/Nanbeige4.1-3B-mlx-nvfp4/raw/main/tokenizer_config.json

{
  "add_prefix_space": true,
  "backend": "tokenizers",
  "bos_token": "",
  "clean_up_tokenization_spaces": false,
  "eos_token": "",
  "extra_special_tokens": [
    ""
  ],
  "is_local": true,
  "legacy": true,
  "model_max_length": 1000000000000000019884624838656,
  "model_specific_special_tokens": {},
  "pad_token": "",
  "sp_model_kwargs": {},
  "spaces_between_special_tokens": false,
  "tokenizer_class": "TokenizersBackend",
  "tool_parser_type": "json_tools",
  "unk_token": "",
  "use_default_system_prompt": false
}


All MLX conversions seem to have `TokenizersBackend`. Let me check the official Nanbeige4.1-3B original tokenizer config and also search for a non-heretic 4-bit MLX version.



---

## 🔧 TOOL RESULTS

[web_fetch]
🌐 https://huggingface.co/Nanbeige/Nanbeige4.1-3B/raw/main/tokenizer_config.json

{
  "add_bos_token": true,
  "add_eos_token": false,
  "add_prefix_space": true,
  "added_tokens_decoder": {
    "0": {
      "content": "",
      "lstrip": false,
      "normalized": true,
      "rstrip": false,
      "single_word": false,
      "special": true
    },
    "1": {
      "content": "",
      "lstrip": false,
      "normalized": true,
      "rstrip": false,
      "single_word": false,
      "special": true
    },
    "2": {
      "content": "",
      "lstrip": false,
      "normalized": true,
      "rstrip": false,
      "single_word": false,
      "special": true
    },
    "166100": {
      "content": "",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": true
    },
    "166101": {
      "content": "",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": true
    },
    "166102": {
      "content": "",
      "lstrip": false,
      "normalized": false,
      "rstrip": false,
      "single_word": false,
      "special": true
    },
    "166103": {
      "content": "",
      "lstrip": false,
      "normalized": true,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "166104": {
      "content": "",
      "lstrip": false,
      "normalized": true,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "166105": {
      "content": "",
      "lstrip": false,
      "normalized": true,
      "rstrip": false,
      "single_word": false,
      "special": false
    },
    "166106": {
      "content": "",
      "lstrip": false,
      "normalized": true,
      "rstrip": false,
      "single_word": false,
      "special": false
    }
  },
  "additional_special_tokens": [
    ""
  ],
  "bos_token": "",
  "chat_template": "\n        {%- if tools %}\n            {{- 'system\n' }}\n            {%- if messages[0].role == 'system' %}\n                {{- messages[0].content + '\n\n' }}\n            {%- else %} \n                {{- '你是一位工具函数调用专家，你会得到一个问题和一组可能的工具函数。根据问题，你需要进行一个或多个函数/工具调用以实现目的，请尽量尝试探索通过工具解决问题。\n如果没有一个函数可以使用，请直接使用自然语言回复用户。\n如果给定的问题缺少函数所需的参数，请使用自然语言进行提问，向用户询问必要信息。\n如果调用结果已经足够回答用户问题，请对历史结果进行总结，使用自然语言回复用户。' }} \n            {%- endif %}\n            {{- \"# Tools\n\nYou may call one or more functions to assist with the user query.\n\nYou are provided with function signatures within  XML tags:\n\" }}\n            {%- for tool in tools %}\n                {{- \"\n\" }}\n                {{- tool | tojson }}\n            {%- endfor %}\n            {{- \"\n\n\nFor each function call, return a json object with function name and arguments within  XML tags:\n\n{\\\"name\\\": , \\\"arguments\\\": }\n\n\" }}\n        {%- else %}\n            {%- if messages[0].role == 'system' %}\n                {{- 'system\n' + messages[0].content + '\n' }}\n            {%- else %} \n                {{- 'system\n你是南北阁，一款由BOSS直聘自主研发并训练的专业大语言模型。\n' }} \n            {%- endif %}\n        {%- endif %}\n        {%- set ns = namespace(multi_step_tool=true, last_query_index=messages|length - 1) %}\n        {%- for message in messages[::-1] %}\n            {%- set index = (messages|length - 1) - loop.index0 %}\n            {%- if ns.multi_step_tool and message.role == \"user\" and message.content is string and not(message.content.startswith('') and message.content.endswith('')) %}\n                {%- set ns.multi_step_tool = false %}\n                {%- set ns.last_query_index = index %}\n            {%- endif %}\n        {%- endfor %}\n        {%- for message in messages %}\n            {%- if message.content is string %}\n                {%- set content = message.content %}\n            {%- else %}\n                {%- set content = '' %}\n            {%- endif %}\n            {%- if (message.role == \"user\") or (message.role == \"system\" and not loop.first) %}\n                {{- '' + message.role + '\n' + content + '' + '\n' }}\n            {%- elif message.role == \"assistant\" %}\n                {%- set reasoning_content = '' %}\n                {%- if message.reasoning_content is string %}\n                    {%- set reasoning_content = message.reasoning_content %}\n                {%- else %}\n                    {%- if '' in content %}\n                        {%- set reasoning_content = content.split('')[0].rstrip('\n').split('')[-1].lstrip('\n') %}\n                        {%- set content = content.split('')[-1].lstrip('\n') %}\n                    {%- endif %}\n                {%- endif %}\n                {%- if loop.index0 > ns.last_query_index or keep_all_think or (extra_body is defined and extra_body.keep_all_think) %}\n                    {%- if loop.last or (not loop.last and reasoning_content) %}\n                        {{- '' + message.role + '\n\n' + reasoning_content.strip('\n') + '\n\n\n' + content.lstrip('\n') }}\n                    {%- else %}\n                        {{- '' + message.role + '\n' + conten

... [truncated]


Now I have a complete picture. Let me verify one more detail — whether the heretic-4bit version is missing the chat template too.



---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit/tree/main

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit/tree/main      
| ✓ | ⏱: 1.43s 
[SCRAPE].. ◆ 
https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit/tree/main      
| ✓ | ⏱: 0.01s 
[COMPLETE] ● 
https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit/tree/main      
| ✓ | ⏱: 1.44s 
[![Hugging Face's logo](https://huggingface.co/front/assets/huggingface_logo-noborder.svg) Hugging Face](https://huggingface.co/)
  * [](https://huggingface.co/models)
  * [](https://huggingface.co/datasets)
  * [](https://huggingface.co/spaces)
  * [](https://huggingface.co/docs)
  * [](https://huggingface.co/enterprise)
  * [Pricing](https://huggingface.co/pricing)
  * * * *
  * [Log In](https://huggingface.co/login)
  * [Sign Up](https://huggingface.co/join)


# 
[ ![](https://cdn-avatars.huggingface.co/v1/production/uploads/623c830997ddced06d78699b/3qTjC7d3YFCJTwpxd2noq.png) ](https://huggingface.co/mlx-community)
[mlx-community](https://huggingface.co/mlx-community)
/
[Nanbeige4.1-3B-heretic-4bit](https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit)
like 0
Follow
![](https://cdn-avatars.huggingface.co/v1/production/uploads/623c830997ddced06d78699b/3qTjC7d3YFCJTwpxd2noq.png) MLX Community 8.73k
[ Text Generation ](https://huggingface.co/models?pipeline_tag=text-generation)[ MLX ](https://huggingface.co/models?library=mlx)[ Safetensors ](https://huggingface.co/models?library=safetensors)[ English ](https://huggingface.co/models?language=en)[ Chinese ](https://huggingface.co/models?language=zh)[ llama ](https://huggingface.co/models?other=llama)[ llm ](https://huggingface.co/models?other=llm)[ nanbeige ](https://huggingface.co/models?other=nanbeige)[ heretic ](https://huggingface.co/models?other=heretic)[ uncensored ](https://huggingface.co/models?other=uncensored)[ decensored ](https://huggingface.co/models?other=decensored)[ abliterated ](https://huggingface.co/models?other=abliterated)[ conversational ](https://huggingface.co/models?other=conversational)[ 4-bit precision ](https://huggingface.co/models?other=4-bit)
License: apache-2.0
[](https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit)[Files Files and versions xet ](https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit/tree/main)[](https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit/discussions)
[Nanbeige4.1-3B-heretic-4bit](https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit/tree/main)
2.23 GB
[
  * ![](https://cdn-avatars.huggingface.co/v1/production/uploads/no-auth/7M_WveAd4mU3AnS4pPd5O.png)
  * 1 contributor

](https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit/commits/main) [History: 2 commits](https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit/commits/main)
![Daizee's picture](https://cdn-avatars.huggingface.co/v1/production/uploads/no-auth/7M_WveAd4mU3AnS4pPd5O.png)
[Daizee](https://huggingface.co/Daizee)
[Add files using upload-large-folder tool](https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit/commit/d81b23a5599a9f69b9cd30f9bf48f57aa5e06daf)
[d81b23a](https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit/commit/d81b23a5599a9f69b9cd30f9bf48f57aa5e06daf) verified about 18 hours ago
  * [.gitattributes](https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit/blob/main/.gitattributes)
[1.57 kB ](https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit/resolve/main/.gitattributes?download=true "Download file") [Add files using upload-large-folder tool](https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit/commit/d81b23a5599a9f69b9cd30f9bf48f57aa5e06daf) [about 18 hours ago](https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit/commit/d81b23a5599a9f69b9cd30f9bf48f57aa5e06daf)
  * [README.md](https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit/blob/main/README.md)
[1.02 kB ](https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit/resolve/main/README.md?download=true "Download file") [Add files using upload-large-folder tool](https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit/commit/d81b23a5599a9f69b9cd30f9bf48f57aa5e06daf) [about 18 hours ago](https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit/commit/d81b23a5599a9f69b9cd30f9bf48f57aa5e06daf)
  * [chat_template.jinja](https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit/blob/main/chat_template.jinja)
[5.53 kB ](https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit/resolve/main/chat_template.jinja?download=true "Download file") [Add files using upload-large-folder tool](https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit/commit/d81b23a5599a9f69b9cd30f9bf48f57aa5e06daf) [about 18 hours ago](https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit/commit/d81b23a5599a9f69b9cd30f9bf48f57aa5e06daf)
  * [config.json](https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit/blob/main/config.json)
[1.02 kB ](https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit/resolve/main/config.json?download=true "Download file") [Add files using upload-large-folder tool](https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit/commit/d81b23a5599a9f69b9cd30f9bf48f57aa5e06daf) [about 18 hours ago](https://huggingface.co/mlx-community/Nanbeige4.1-3B


Now I have all the evidence needed. Let me compile the complete findings.

>>>REPORT
# Nanbeige4.1-3B-heretic-4bit: Tokenizer Investigation

## Model Overview
- **Model**: `mlx-community/Nanbeige4.1-3B-heretic-4bit` (https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit)
- **Architecture**: `LlamaForCausalLM` (model_type: `llama`), 3B params, 4-bit quantized
- **Converted from**: `Daizee/Nanbeige4.1-3B-heretic` using mlx-lm v0.30.7
- **Vocab size**: 166,144

## Tokenizer Config Analysis

### The `tokenizer_class` Issue
The **MLX-converted** model's `tokenizer_config.json` uses:
```json
"tokenizer_class": "TokenizersBackend"
```

The **original** models (`Daizee/Nanbeige4.1-3B-heretic` and `Nanbeige/Nanbeige4.1-3B`) both use:
```json
"tokenizer_class": "LlamaTokenizer"
```

**`TokenizersBackend` is a new tokenizer class introduced by HuggingFace transformers v5.0** as part of a unified tokenizer backend system replacing the old Fast/Slow distinction. When `mlx-lm` converted this model, it used transformers v5.0+ which rewrote the tokenizer_class.

### Missing Config Fields
The heretic-4bit tokenizer_config.json is also **stripped down** compared to the original:
- **Missing**: `add_bos_token` (original has `true`), `add_eos_token` (original has `false`), `added_tokens_decoder`, `chat_template` (inline), `additional_special_tokens`
- **Added**: `"backend": "tokenizers"`, `"is_local": true`, `"max_length": null`, `"pad_to_multiple_of": null`, `"pad_token_type_id": 0`, `"padding_side": "left"`

## swift-transformers Compatibility

### Two-level tokenizer selection in swift-transformers (Tokenizer.swift):

**Level 1 – TokenizerModel (underlying tokenizing algorithm):**
```swift
static let knownTokenizers: [String: PreTrainedTokenizerModel.Type] = [
    ...
    "LlamaTokenizer": BPETokenizer.self,
    "TokenizersBackend": BPETokenizer.self,  // ← registered, maps to BPE
    ...
]
```
✅ `TokenizersBackend` IS registered here → will use `BPETokenizer` (same as `LlamaTokenizer`).

**Level 2 – PreTrainedTokenizerClasses (high-level tokenizer behavior):**
```swift
enum PreTrainedTokenizerClasses {
    static let tokenizerClasses: [String: PreTrainedTokenizer.Type] = [
        "LlamaTokenizer": LlamaPreTrainedTokenizer.self
    ]
}
```
❌ `TokenizersBackend` is **NOT** registered here → falls back to base `PreTrainedTokenizer` instead of `LlamaPreTrainedTokenizer`.

### Consequence: Subtle Behavioral Differences
`LlamaPreTrainedTokenizer` provides critical Llama-specific behavior:
1. **`maybeUpdatePostProcessor`**: Handles `add_bos_token`/`add_eos_token` by replacing the ByteLevel post-processor with a TemplateProcessing one that inserts BOS/EOS tokens. Without this, BOS tokens may not be added correctly.
2. **Legacy mode handling**: For `legacy: true` (which this model uses), it affects normalizer and pre-tokenizer behavior.
3. **SentencePiece underline prefix handling**: In non-legacy mode, prepends `▁` to input text.

Since the heretic-4bit config says `"tokenizer_class": "TokenizersBackend"`, swift-transformers will:
- ✅ Load the tokenizer successfully (no crash)
- ⚠️ Use base `PreTrainedTokenizer` instead of `LlamaPreTrainedTokenizer`
- ⚠️ Miss the `add_bos_token` post-processor update (made worse by `add_bos_token` being absent from the config entirely)
- ⚠️ Potentially produce incorrect token sequences for the model

## Alternative Quantized Versions

**All MLX conversions have the same `TokenizersBackend` problem:**
| Model | tokenizer_class |
|-------|----------------|
| `mlx-community/Nanbeige4.1-3B-heretic-4bit` | `TokenizersBackend` |
| `mlx-community/Nanbeige4.1-3B-8bit` | `TokenizersBackend` |
| `mlx-community/Nanbeige4.1-3B-bf16` | `TokenizersBackend` |
| `RepublicOfKorokke/Nanbeige4.1-3B-mlx-nvfp4` | `TokenizersBackend` |

This is because all were converted using mlx-lm with transformers v5.0+.

## Recommended Fix
To use any of these MLX Nanbeige4.1 models with swift-transformers correctly, manually edit the downloaded `tokenizer_config.json`:
1. Change `"tokenizer_class": "TokenizersBackend"` → `"tokenizer_class": "LlamaTokenizer"`
2. Add `"add_bos_token": true` and `"add_eos_token": false`

This will cause swift-transformers to use `LlamaPreTrainedTokenizer` which provides the correct Llama-family tokenization behavior.

Alternatively, a PR could be submitted to swift-transformers to add `"TokenizersBackend"` → `LlamaPreTrainedTokenizer.self` mapping in `PreTrainedTokenizerClasses` when the `model_type` in config.json is `"llama"`, though this would require architecture-aware tokenizer class resolution.
>>>END
