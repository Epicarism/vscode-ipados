# Agent: check-nanbeige-tokenizer
**Status:** done
**Tokens:** 1,125
**Cost:** $0.0000
**Time:** 2026-02-16T20:37:52.332Z

## Task
Fetch the tokenizer config for the Nanbeige model: https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit/raw/main/tokenizer_config.json and also check https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit/tree/main for what tokenizer files exist. Report the tokenizer_class, backend, and any other relevant config.

## Response
I'll fetch both URLs now to gather the information.





---

## 🔧 TOOL RESULTS

[web_fetch]
🌐 https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit/tree/main

• 

• 

• 

• 

• 

• 

•   
		mlx-community/Nanbeige4.1-3B-heretic-4bit at main

				Hugging Face

• 

						Models
				
• 

						Datasets
				
• 

						Spaces
				
• 

			Community

• 

						Docs
				
• 

						Enterprise

• [Pricing
			](/pricing)

• 

• 
		
• [Log In
				](/login)
			
• [Sign Up
					](/join)

	&quot;,&quot;eos_token&quot;:&quot;&quot;,&quot;pad_token&quot;:&quot;&quot;,&quot;unk_token&quot;:&quot;&quot;,&quot;use_default_system_prompt&quot;:false},&quot;chat_template_jinja&quot;:&quot;\n        {%- if tools %}\n            {{- 'system\n' }}\n            {%- if messages[0].role == 'system' %}\n                {{- messages[0].content + '\n\n' }}\n            {%- else %} \n                {{- '你是一位工具函数调用专家，你会得到一个问题和一组可能的工具函数。根据问题，你需要进行一个或多个函数/工具调用以实现目的，请尽量尝试探索通过工具解决问题。\n如果没有一个函数可以使用，请直接使用自然语言回复用户。\n如果给定的问题缺少函数所需的参数，请使用自然语言进行提问，向用户询问必要信息。\n如果调用结果已经足够回答用户问题，请对历史结果进行总结，使用自然语言回复用户。' }} \n            {%- endif %}\n            {{- \&quot;# Tools\n\nYou may call one or more functions to assist with the user query.\n\nYou are provided with function signatures within  XML tags:\n\&quot; }}\n            {%- for tool in tools %}\n                {{- \&quot;\n\&quot; }}\n                {{- tool | tojson }}\n            {%- endfor %}\n            {{- \&quot;\n\n\nFor each function call, return a json object with function name and arguments within  XML tags:\n\n{\\\&quot;name\\\&quot;: , \\\&quot;arguments\\\&quot;: }\n\n\&quot; }}\n        {%- else %}\n            {%- if messages[0].role == 'system' %}\n                {{- 'system\n' + messages[0].content + '\n' }}\n            {%- else %} \n                {{- 'system\n你是南北阁，一款由BOSS直聘自主研发并训练的专业大语言模型。\n' }} \n            {%- endif %}\n        {%- endif %}\n        {%- set ns = namespace(multi_step_tool=true, last_query_index=messages|length - 1) %}\n        {%- for message in messages[::-1] %}\n            {%- set index = (messages|length - 1) - loop.index0 %}\n            {%- if ns.multi_step_tool and message.role == \&quot;user\&quot; and message.content is string and not(message.content.startswith('') and message.content.endswith('')) %}\n                {%- set ns.multi_step_tool = false %}\n                {%- set ns.last_query_index = index %}\n            {%- endif %}\n        {%- endfor %}\n        {%- for message in messages %}\n            {%- if message.content is string %}\n                {%- set content = message.content %}\n            {%- else %}\n                {%- set content = '' %}\n            {%- endif %}\n            {%- if (message.role == \&quot;user\&quot;) or (message.role == \&quot;system\&quot; and not loop.first) %}\n                {{- '' + message.role + '\n' + content + '' + '\n' }}\n            {%- elif message.role == \&quot;assistant\&quot; %}\n                {%- set reasoning_content = '' %}\n                {%- if message.reasoning_content is string %}\n                    {%- set reasoning_content = message.reasoning_content %}\n                {%- else %}\n                    {%- if '' in content %}\n                        {%- set reasoning_content = content.split('')[0].rstrip('\n').split('')[-1].lstrip('\n') %}\n                        {%- set content = content.split('')[-1].lstrip('\n') %}\n                    {%- endif %}\n                {%- endif %}\n                {%- if loop.index0 > ns.last_query_index or keep_all_think or (extra_body is defined and extra_body.keep_all_think) %}\n                    {%- if loop.last or (not loop.last and reasoning_content) %}\n                        {{- '' + message.role + '\n\n' + reasoning_content.strip('\n') + '\n\n\n' + content.lstrip('\n') }}\n                    {%- else %}\n                        {{- '' + message.role + '\n' + content }}\n                    {%- endif %}\n                {%- else %}\n                    {{- '' + message.role + '\n' + content }}\n                {%- endif %}\n                {%- if message.tool_calls %}\n                    {%- for tool_call in message.tool_calls %}\n                        {%- if (loop.first and content) or (not loop.first) %}\n                            {{- '\n' }}\n                        {%- endif %}\n                        {%- if tool_call.function %}\n                            {%- set tool_call = tool_call.function %}\n                        {%- endif %}\n                        {{- '\n{\&quot;name\&quot;: \&quot;' }}\n                        {{- tool_call.name }}\n                        {{- '\&quot;, \&quot;arguments\&quot;: ' }}\n                        {%- if tool_call.arguments is string %}\n                            {{- tool_call.arguments }}\n                        {%- else %}\n                            {{- tool_call.arguments | tojson }}\n                        {%- endif %}\n                        {{- '}\n' }}\n                    {%- endfor %}\n                {%- endif %}\n                {{- '\n' }}\n            {%- elif message.role == \&quot;tool\&quot; %}\n                {%- if loop.first or (messages[loop.index0 - 1].role != \&quot;tool\&quot;) %}\n                    {{- 'user' }}\n                {%- endif %}\n                {{- '\n\n' }}\n                {{- content }}\n                {{- '\n' }}\n                {%- if loop.last or (messages[loop.index0 + 1].role != \&quot;tool\&quot;) %}\n                    {{- '\n' }}\n                {%- endif %}\n            {%- endif %}\n        {%- endfor %}\n        {%- if add_generation_prompt %}\n            {{- 'assistant\n' }}\n        {%- endif %}\n&quot;},&quot;createdAt&quot;:&quot;2026-02-16T03:08:47.000Z&quot;,&quot;discussionsDisabled&quot;:false,&quot;discussionsSorting&quot;:&quot;recently-created&quot;,&quot;downloads&quot;:4,&quot;downloadsAllTime&quot;:4,&quot;id&quot;:&quot;mlx-community/Nanbeige4.1-3B-heretic-4bit&quot;,&quot;isLikedByUser&quot;:false,&quot;availableInferenceProviders&quot;:[],&quot;inference&quot;:&quot;&quot;,&quot;lastModified&quot;:&quot;2026-02-16T03:10:48.000Z&quot;,&quot;likes&quot;:0,&quot;pipeline_tag&quot;:&quot;text-generation&quot;,&quot;library_name&quot;:&quot;mlx&quot;,&quot;librariesOther&quot;:[],&quot;trackDownloads&quot;:true,&quot;model-index&quot;:null,&quot;private&quot;:false,&quot;repoType&quot;:&quot;model&quot;,&quot;gated&quot;:false,&quot;tags&quot;:[&quot;mlx&quot;,&quot;safetensors&quot;,&quot;llama&quot;,&quot;llm&quot;,&quot;nanbeige&quot;,&quot;heretic&quot;,&quot;uncensored&quot;,&quot;decensored&quot;,&quot;abliterated&quot;,&quot;text-generation&quot;,&quot;conversational&quot;,&quot;en&quot;,&quot;zh&quot;,&quot;base_model:Daizee/Nanbeige4.1-3B-heretic&quot;,&quot;base_model:quantized:Daizee/Nanbeige4.1-3B-heretic&quot;,&quot;license:apache-2.0&quot;,&quot;4-bit&quot;,&quot;region:us&quot;],&quot;tag_objs&quot;:[{&quot;id&quot;:&quot;text-generation&quot;,&quot;label&quot;:&quot;Text Generation&quot;,&quot;type&quot;:&quot;pipeline_tag&quot;,&quot;subType&quot;:&quot;nlp&quot;},{&quot;id&quot;:&quot;mlx&quot;,&quot;label&quot;:&quot;MLX&quot;,&quot;type&quot;:&quot;library&quot;},{&quot;id&quot;:&quot;safetensors&quot;,&quot;label&quot;:&quot;Safetensors&quot;,&quot;type&quot;:&quot;library&quot;},{&quot;id&quot;:&quot;en&quot;,&quot;label&quot;:&quot;English&quot;,&quot;type&quot;:&quot;language&quot;},{&quot;id&quot;:&quot;zh&quot;,&quot;label&quot;:&quot;Chinese&quot;,&quot;type&quot;:&quot;language&quot;},{&quot;id&quot;:&quot;llama&quot;,&quot;label&quot;:&quot;llama&quot;,&quot;type&quot;:&quot;other&quot;,&quot;clickable&quot;:true},{&quot;id&quot;:&quot;llm&quot;,&quot;label&quot;:&quot;llm&quot;,&quot;type&quot;:&quot;other&quot;,&quot;clickable&quot;:true},{&quot;id&quot;:&quot;nanbeige&quot;,&quot;label&quot;:&quot;nanbeige&quot;,&quot;type&quot;:&quot;other&quot;,&quot;clickable&quot;:true},{&quot;id&quot;:&quot;heretic&quot;,&quot;label&quot;:&quot;heretic&quot;,&quot;type&quot;:&quot;other&quot;,&quot;clickable&quot;:true},{&quot;id&quot;:&quot;uncensored&quot;,&quot;label&quot;:&quot;uncensored&quot;,&quot;type&quot;:&quot;other&quot;,&quot;clickable&quot;:true},{&quot;id&quot;:&quot;decensored&quot;,&quot;label&quot;:&quot;decensored&quot;,&quot;type&quot;:&quot;other&quot;,&quot;clickable&quot;:true},{&quot;id&quot;:&quot;abliterated&quot;,&quot;label&quot;:&quot;abliterated&quot;,&quot;type&quot;:&quot;other&quot;,&quot;clickable&quot;:true},{&quot;id&quot;:&quot;conversational&quot;,&quot;label&quot;:&quot;conversational&quot;,&quot;type&quot;:&quot;other&quot;,&quot;clickable&quot;:true},{&quot;id&quot;:&quot;base_model:Daizee/Nanbeige4.1-3B-heretic&quot;,&quot;label&quot;:&quot;base_model:Daizee/Nanbeige4.1-3B-heretic&quot;,&quot;type&quot;:&quot;other&quot;,&quot;clickable&quot;:true},{&quot;id&quot;:&quot;base_model:quantized:Daizee/Nanbeige4.1-3B-heretic&quot;,&quot;label&quot;:&quot;base_model:quantized:Daizee/Nanbeige4.1-3B-heretic&quot;,&quot;type&quot;:&quot;other&quot;,&quot;clickable&quot;:true},{&quot;id&quot;:&quot;4-bit&quot;,&quot;label&quot;:&quot;4-bit precision&quot;,&quot;type&quot;:&quot;other&quot;,&quot;clickable&quot;:true},{&quot;id&quot;:&quot;license:apache-2.0&quot;,&quot;label&quot;:&quot;apache-2.0&quot;,&quot;type&quot;:&quot;license&quot;},{&quot;type&quot;:&quot;region&quot;,&quot;label&quot;:&quot;🇺🇸 Region: US&quot;,&quot;id&quot;:&quot;region:us&quot;}],&quot;widgetData&quot;:[{&quot;text&quot;:&quot;Hi, what can you help me with?&quot;},{&quot;text&quot;:&quot;What is 84 * 3 / 2?&quot;},{&quot;text&quot;:&quot;Tell me an interesting fact about the universe!&quot;},{&quot;text&quot;:&quot;Explain quantum computing in simple terms.&quot;}],&quot;safetensors&quot;:{&quot;parameters&quot;:{&quot;BF16&quot;:123087360,&quot;U32&quot;:491683840},&quot;total&quot;:614771200,&quot;sharded&quot;:false},&quot;mlxFilePaths&quot;:[&quot;model.safetensors&quot;],&quot;hasBlockedOids&quot;:false,&quot;region&quot;:&quot;us&quot;,&quot;isQuantized&quot;:true},&quot;discussionsStats&quot;:{&quot;closed&quot;:0,&quot;open&quot;:0,&quot;total&quot;:0},&quot;query&quot;:{},&quot;inferenceContextData&quot;:{&quot;billableEntities&quot;:[],&quot;entityName2Providers&quot;:{}}}">

[mlx-community](/mlx-community)
	
		/

[Nanbeige4.1-3B-heretic-4bit](/mlx-community/Nanbeige4.1-3B-heretic-4bit)

		like
	0

			Follow
		
		MLX Community
	8.73k

	Text Generation

	MLX

	Safetensors

	English

	Chinese

	llama

	llm

	nanbeige

	heretic

	uncensored

	decensored

	abliterated

	conversational

		4-bit precision

	License:

	apache-2.0

	Model card

	Files
		Files and versions

						xet

	Community

			Use this model

			main

			[Nanbeige4.1-3B-heretic-4bit](/mlx-community/Nanbeige4.1-3B-heretic-4bit/tree/main)
				
			2.23 GB

• 

• 1 contributor

				History:
					2 commits

			[Daizee
					](/Daizee)

		Add files using upload-large-folder tool
		[d81b23a](/mlx-community/Nanbeige4.1-3B-heretic-4bit/commit/d81b23a5599a9f69b9cd30f9bf48f57aa5e06daf)
		verified
		about 17 hours ago
				&quot;,&quot;eos_token&quot;:&quot;&quot;,&quot;pad_token&quot;:&quot;&quot;,&quot;unk_token&quot;:&quot;&quot;,&quot;use_default_system_prompt&quot;:false},&quot;chat_template_jinja&quot;:&quot;\n        {%- if tools %}\n            {{- 'system\n' }}\n            {%- if messages[0].role == 'system' %}\n                {{- messages[0].content + '\n\n' }}\n            {%- else %} \n                {{- '你是一位工具函数调用专家，你会得到一个问题和一组可能的工具函数。根据问题，你需要进行一个或多个函数/工具调用以实现目的，请尽量尝试探索通过工具解决问题。\n如果没有一个函数可以使用，请直接使用自然语言回复用户。\n如果给定的问题缺少函数所需的参数，请使用自然语言进行提问，向用户询问必要信息。\n如果调用结果已经足够回答用户问题，请对历史结果进行总结，使用自然语言回复用户。' }} \n            {%- endif %}\n            {{- \&quot;# Tools\n\nYou may call one or more functions to assist with the user query.\n\nYou are provided with function signatures within  XML tags:\n\&quot; }}\n            {%- for tool in tools %}\n                {{- \&quot;\n\&quot; }}\n                {{- tool | tojson }}\n            {%- endfor %}\n            {{- \&quot;\n\n\nFor each function call, return a json object with function name and arguments within  XML tags:\n\n{\\\&quot;name\\\&quot;: , \\\&quot;arguments\\\&quot;: }\n\n\&quot; }}\n        {%- else %}\n            {%- if messages[0].role == 'system' %}\n                {{- 'system\n' + messages[0].content + '\n' }}\n            {%- else %} \n                {{- 'system\n你是南北阁，一款由BOSS直聘自主研发并训练的专业大语言模型。\n' }} \n            {%- endif %}\n        {%- endif %}\n        {%- set ns = namespace(multi_step_tool=true, last_query_index=messages|length - 1) %}\n        {%- for message in messages[::-1] %}\n            {%- set index = (messages|length - 1) - loop.index0 %}\n            {%- if ns.multi_step_tool and message.role == \&quot;user\&quot; and message.content is string and not(message.content.startswith('') and message.content.endswith('')) %}\n                {%- set ns.multi_step_tool = false %}\n                {%- set ns.last_query_index = index %}\n            {%- endif %}\n        {%- endfor %}\n        {%- for message in messages %}\n            {%- if message.content is string %}\n                {%- set content = message.content %}\n            {%- else %}\n                {%- set content = '' %}\n            {%- endif %}\n            {%- if (message.role == \&quot;user\&quot;) or (message.role == \&quot;system\&quot; and not loop.first) %}\n                {{- '' + message.role + '\n' + content + '' + '\n' }}\n            {%- elif message.role == \&quot;assistant\&quot; %}\n                {%- set reasoning_content = '' %}\n                {%- if message.reasoning_content is string %}\n                    {%- set reasoning_content = message.reasoning_content %}\n                {%- else %}\n                    {%- if '' in content %}\n                        {%- set reasoning_content = content.split('')[0].rstrip('\n').split('')[-1].lstrip('\n') %}\n                        {%- set content = content.split('')[-1].lstrip('\n') %}\n                    {%- endif %}\n                {%- endif %}\n                {%- if loop.index0 > ns.last_query_index or keep_all_think or (extra_body is defined and extra_body.keep_all_think) %}\n                    {%- if loop.last or (not loop.last and reasoning_content) %}\n                        {{- '' + message.role + '\n\n' + reasoning_content.strip('\n') + '\n\n\n' + content.lstrip('\n') }}\n                    {%- else %}\n                        {{- '' + message.role + '\n' + content }}\n                    {%- endif %}\n                {%- else %}\n                    {{- '' + message.role + '\n' + content }}\n                {%- endif %}\n                {%- if message.tool_calls %}\n                    {%- for tool_call in message.tool_calls %}\n                        {%- if (loop.first and content) or (not loop.first) %}\n                            {{- '\n' }}\n                        {%- endif %}\n                        {%- if tool_call.function %}\n                            {%- set tool_call = tool_call.function %}\n                        {%- endif %}\n                        {{- '\n{\&quot;name\&quot;: \&quot;' }}\n                        {{- tool_call.name }}\n                        {{- '\&quot;, \&quot;arguments\&quot;: ' }}\n                        {%- if tool_call.arguments is string %}\n                            {{- tool_call.arguments }}\n                        {%- else %}\n                            {{- tool_call.arguments | tojson }}\n                        {%- endif %}\n                        {{- '}\n' }}\n                    {%- endfor %}\n                {%- endif %}\n                {{- '\n' }}\n            {%- elif message.role == \&quot;tool\&quot; %}\n                {%- if loop.first or (messages[loop.index0 - 1].role != \&quot;tool\&quot;) %}\n                    {{- 'user' }}\n                {%- endif %}\n                {{- '\n\n' }}\n                {{- content }}\n                {{- '\n' }}\n                {%- if loop.last or (messages[loop.index0 + 1].role != \&quot;tool\&quot;) %}\n                    {{- '\n' }}\n                {%- endif %}\n            {%- endif %}\n        {%- endfor %}\n        {%- if add_generation_prompt %}\n            {{- 'assistant\n' }}\n        {%- endif %}\n&quot;},&quot;createdAt&quot;:&quot;2026-02-16T03:08:47.000Z&quot;,&quot;discussionsDisabled&quot;:false,&quot;discussionsSorting&quot;:&quot;recently-created&quot;,&quot;downloads&quot;:4,&quot;downloadsAllTime&quot;:4,&quot;id&quot;:&quot;mlx-community/Nanbeige4.1-3B-heretic-4bit&quot;,&quot;isLikedByUser&quot;:false,&quot;availableInferenceProviders&quot;:[],&quot;inference&quot;:&quot;&quot;,&quot;lastModified&quot;:&quot;2026-02-16T03:10:48.000Z&quot;,&quot;likes&quot;:0,&quot;pipeline_tag&quot;:&quot;text-generation&quot;,&quot;library_name&quot;:&quot;mlx&quot;,&quot;librariesOther&quot;:[],&quot;trackDownloads&quot;:true,&quot;model-index&quot;:null,&quot;private&quot;:false,&quot;repoType&quot;:&quot;model&quot;,&quot;gated&quot;:false,&quot;tags&quot;:[&quot;mlx&quot;,&quot;safetensors&quot;,&quot;llama&quot;,&quot;llm&quot;,&quot;nanbeige&quot;,&quot;heretic&quot;,&quot;uncensored&quot;,&quot;decensored&quot;,&quot;abliterated&quot;,&quot;text-generation&quot;,&quot;conversational&quot;,&quot;en&quot;,&quot;zh&quot;,&quot;base_model:Daizee/Nanbeige4.1-3B-heretic&quot;,&quot;base_model:quantized:Daizee/Nanbeige4.1-3B-heretic&quot;,&quot;license:apache-2.0&quot;,&quot;4-bit&quot;,&quot;region:us&quot;],&quot;tag_objs&quot;:[{&quot;id&quot;:&quot;text-generation&quot;,&quot;label&quot;:&quot;Text Generation&quot;,&quot;type&quot;:&quot;pipeline_tag&quot;,&quot;subType&quot;:&quot;nlp&quot;},{&quot;id&quot;:&quot;mlx&quot;,&quot;label&quot;:&quot;MLX&quot;,&quot;type&quot;:&quot;library&quot;},{&quot;id&quot;:&quot;safetensors&quot;,&quot;label&quot;:&quot;Safetensors&quot;,&quot;type&quot;:&quot;library&quot;},{&quot;id&quot;:&quot;en&quot;,&quot;label&quot;:&quot;English&quot;,&quot;type&quot;:&quot;language&quot;},{&quot;id&quot;:&quot;zh&quot;,&quot;label&quot;:&quot;Chinese&quot;,&quot;type&quot;:&quot;language&quot;},{&quot;id&quot;:&quot;llama&quot;,&quot;label&quot;:&quot;llama&quot;,&quot;type&quot;:&quot;other&quot;,&quot;clickable&quot;:true},{&quot;id&quot;:&quot;llm&quot;,&quot;label&quot;:&quot;llm&quot;,&quot;type&quot;:&quot;other&quot;,&quot;clickable&quot;:true},{&quot;id&quot;:&quot;nanbeige&quot;,&quot;label&quot;:&quot;nanbeige&quot;,&quot;type&quot;:&quot;other&quot;,&quot;clickable&quot;:true},{&quot;id&quot;:&quot;heretic&quot;,&quot;label&quot;:&quot;heretic&quot;,&quot;type&quot;:&quot;other&quot;,&quot;clickable&quot;:true},{&quot;id&quot;:&quot;uncensored&quot;,&quot;label&quot;:&quot;uncensored&quot;,&quot;type&quot;:&quot;other&quot;,&quot;clickable&quot;:true},{&quot;id&quot;:&quot;decensored&quot;,&quot;label&quot;:&quot;decensored&quot;,&quot;type&quot;:&quot;other&quot;,&quot;clickable&quot;:true},{&quot;id&quot;:&quot;abliterated&quot;,&quot;label&quot;:&quot;abliterated&quot;,&quot;type&quot;:&quot;other&quot;,&quot;clickable&quot;:true},{&quot;id&quot;:&quot;conversational&quot;,&quot;label&quot;:&quot;conversational&quot;,&quot;type&quot;:&quot;other&quot;,&quot;clickable&quot;:true},{&quot;id&quot;:&quot;base_model:Daizee/Nanbeige4.1-3B-heretic&quot;,&quot;label&quot;:&quot;base_model:Daizee/Nanbeige4.1-3B-heretic&quot;,&quot;type&quot;:&quot;other&quot;,&quot;clickable&quot;:true},{&quot;id&quot;:&quot;base_model:quantized:Daizee/Nanbeige4.1-3B-heretic&quot;,&quot;label&quot;:&quot;base_model:quantized:Daizee/Nanbeige4.1-3B-heretic&quot;,&quot;type&quot;:&quot;other&quot;,&quot;clickable&quot;:true},{&quot;id&quot;:&quot;4-bit&quot;,&quot;label&quot;:&quot;4-bit precision&quot;,&quot;type&quot;:&quot;other&quot;,&quot;clickable&quot;:true},{&quot;id&quot;:&quot;license:apache-2.0&quot;,&quot;label&quot;:&quot;apache-2.0&quot;,&quot;type&quot;:&quot;license&quot;},{&quot;type&quot;:&quot;region&quot;,&quot;label&quot;:&quot;🇺🇸 Region: US&quot;,&quot;id&quot;:&quot;region:us&quot;}],&quot;widgetData&quot;:[{&quot;text&quot;:&quot;Hi, what can you help me with?&quot;},{&quot;text&quot;:&quot;What is 84 * 3 / 2?&quot;},{&quot;text&quot;:&quot;Tell me an interesting fact about the universe!&quot;},{&quot;text&quot;:&quot;Explain quantum computing in simple terms.&quot;}],&quot;safetensors&quot;:{&quot;parameters&quot;:{&quot;BF16&quot;:123087360,&quot;U32&quot;:491683840},&quot;total&quot;:614771200,&quot;sharded&quot;:false},&quot;mlxFilePaths&quot;:[&quot;model.safetensors&quot;],&quot;hasBlockedOids&quot;:false,&quot;region&quot;:&quot;us&quot;,&quot;isQuantized&quot;:true},&quot;hasGatedAccess&quot;:true,&quot;inferenceContextData&quot;:{&quot;billableEntities&quot;:[],&quot;entityName2Providers&quot;:{}}}">

• 

					.gitattributes

			1.57 kB

			Add files using upload-large-folder tool
				about 17 hours ago

• 

					README.md

			1.02 kB

			Add files using upload-large-folder tool
				about 17 hours ago

• 

					chat_template.jinja

			5.53 kB

			Add files using upload-large-folder tool
				about 17 hours ago

• 

					config.json

			1.02 kB

			Add files using upload-large-folder tool
				about 17 hours ago

• 

					generation_config.json

			149 Bytes

			Add files using upload-large-folder tool
				about 17 hours ago

• 

					model.safetensors

			2.21 GB

	xet

			Add files using upload-large-folder tool
				about 17 hours ago

• 

					model.safetensors.index.json

			52.4 kB

			Add files using upload-large-folder tool
				about 17 hours ago

• 

					tokenizer.json

			18.5 MB

	xet

			Add files using upload-large-folder tool
				about 17 hours ago

• 

					tokenizer_config.json

			587 Bytes

			Add files using upload-large-folder tool
				about 17 hours ago


>>>REPORT

## Nanbeige4.1-3B-heretic-4bit Tokenizer Config

### tokenizer_config.json (full contents)

Fetched from `https://huggingface.co/mlx-community/Nanbeige4.1-3B-heretic-4bit/raw/main/tokenizer_config.json`:

```json
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
```

### Key Fields

| Field | Value |
|-------|-------|
| **tokenizer_class** | `TokenizersBackend` |
| **backend** | `tokenizers` |
| **bos_token** | `""` (empty string) |
| **eos_token** | `""` (empty string) |
| **pad_token** | `""` (empty string) |
| **unk_token** | `""` (empty string) |
| **padding_side** | `left` |
| **model_max_length** | ~1e30 (effectively unlimited) |
| **legacy** | `true` |
| **add_prefix_space** | `true` |
| **tool_parser_type** | `json_tools` |
| **use_default_system_prompt** | `false` |
| **is_local** | `true` |

### Tokenizer Files in Repository

From the tree listing at `/tree/main`:

1. **`tokenizer.json`** — 18.5 MB (the main HuggingFace fast-tokenizer vocabulary/merges file)
2. **`tokenizer_config.json`** — 587 Bytes (config shown above)
3. **`chat_template.jinja`** — 5.53 kB (standalone Jinja chat template)

**Notable:** There is **no** `tokenizer.model` (SentencePiece `.model` file) present, despite `sp_model_kwargs: {}` and `legacy: true` being set. The tokenizer relies entirely on `tokenizer.json` (the HuggingFace `tokenizers` library fast-tokenizer format), consistent with `"backend": "tokenizers"` and `"tokenizer_class": "TokenizersBackend"`.

### Other Relevant Model Context
- **Architecture:** LLaMA-based (`llama` tag)
- **Base model:** `Daizee/Nanbeige4.1-3B-heretic` (quantized to 4-bit for MLX)
- **Library:** MLX (Apple Silicon optimized)
- **License:** Apache-2.0
- **Languages:** English, Chinese
- **Default system prompt** (from chat template): `"你是南北阁，一款由BOSS直聘自主研发并训练的专业大语言模型。"` ("I am Nanbeige, a professional LLM independently developed and trained by BOSS Zhipin.")
- The chat template supports tool calling with `<tool_call>` XML tags and reasoning/thinking blocks.

### Key Takeaway for MLX-LM / tokenizer loading

The `"tokenizer_class": "TokenizersBackend"` is **non-standard** — it is NOT a recognized HuggingFace `AutoTokenizer` class name (those would be e.g. `LlamaTokenizer`, `LlamaTokenizerFast`, `PreTrainedTokenizerFast`). This means `AutoTokenizer.from_pretrained()` will likely fail to resolve this class. MLX-LM or custom loading code must handle this by falling back to loading `tokenizer.json` directly via the `tokenizers` library or `PreTrainedTokenizerFast`.

>>>END
