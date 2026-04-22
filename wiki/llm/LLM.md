---
title: LLM
summary: "📚 大语言模型 (Large Language Model) 是基于 Transformer 架构的深度学习模型，通过海量文本数据训练，能够理解、生成和处理自然语言。"
source: https://www.notion.so/2fb10c9390f180cd89b7e32cf3fb4417
source_type: notion
note_type: moc
area: llm
topic: llm
collection: llm
status: active
migrated_on: '2026-04-20'
tags:
- wiki/llm
- wiki/moc
- area/llm
- type/moc
- topic/llm
- collection/llm
---

📚 大语言模型 (Large Language Model) 是基于 Transformer 架构的深度学习模型，通过海量文本数据训练，能够理解、生成和处理自然语言。

[[wiki/llm/模型训练/Flash Attention|模型训练]]

[[wiki/llm/Cuda/1 CUDA 编程基础总结|Cuda]]

[[wiki/llm/Nano-vllm/NANO_VLLM_GUIDE| Nano-vllm]]

[[wiki/llm/RAG/RAG|RAG]]

[[wiki/llm/基础概念/tokenizer|tokenizer]]

- [输入密码 · 语雀](https://www.yuque.com/snailclimb/itdq8h?#) 《SpringAI 智能面试平台+RAG知识库》 🔑 密码：wx81

[[wiki/llm/基础概念/LLM 思维链|LLM 思维链]]

[[wiki/llm/cs336|cs336]]

[[wiki/llm/Agent/Agent|Agent]]

---

### 🏗️ 核心架构

- Transformer 架构：自注意力机制 + 前馈神经网络 (FFN)
- Decoder-only：GPT 系列，适合文本生成
- Encoder-only：BERT 系列，适合理解任务

### ⚡ MoE (Mixture of Experts)

- 多个专家网络 + 门控路由，稀疏激活
- 代表模型：Mixtral 8x7B, Grok-1, Qwen-MoE

> [!note]
> 💡 优势：训练更快、推理 FLOPs 更低 | 挑战：高 VRAM 需求

### 🚀 推理优化

- vLLM：PagedAttention 显存管理、连续批处理
- 量化：GPTQ, AWQ, INT4/8, FP8
- 推测解码：加速生成过程

### 📊 评估基准

- MMLU：多任务语言理解 (57 个学科)
- GSM8K：数学推理 (小学到初中难度)
- HumanEval：代码生成能力
- BIG-Bench：大规模多任务评估

### 🔧 微调方法

- SFT (Supervised Fine-Tuning)：有监督微调
- RLHF：基于人类反馈的强化学习
- LoRA：低秩适配器，参数高效微调
- DPO：直接偏好优化，替代 RLHF
