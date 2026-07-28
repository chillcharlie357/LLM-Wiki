---
title: DeepSeek V4
summary: "DeepSeek V4 是 DeepSeek 在 2026-04-24 发布的百万 token 上下文 MoE 模型系列，包含 V4-Pro 与 V4-Flash，核心改进集中在长上下文效率、Agent 能力、推理能力和 API 迁移。"
source: https://api-docs.deepseek.com/zh-cn/news/news260424
source_type: deepseek-news
note_type: model
area: llm
topic: deepseek-v4
collection: 模型
status: active
migrated_on: '2026-04-26'
tags:
- area/llm
- type/model
- topic/deepseek
- topic/long-context
- collection/模型
aliases:
- DeepSeek-V4
- DeepSeek V4 Pro
- DeepSeek V4 Flash
related_sources:
- raw/web/deepseek/news260424.md
- raw/web/deepseek/news260424.html
- raw/assets/papers/deepseek/DeepSeek_V4.pdf
- https://huggingface.co/collections/deepseek-ai/deepseek-v4
- https://modelscope.cn/collections/deepseek-ai/DeepSeek-V4
- https://huggingface.co/deepseek-ai/DeepSeek-V4-Pro/blob/main/DeepSeek_V4.pdf
---

# DeepSeek V4

DeepSeek V4 是 DeepSeek 在 2026-04-24 发布的预览版模型系列，主打 **1M token 上下文**、更强 Agent 能力和更高长上下文推理效率。官方同时提供两个版本：

| 版本 | 参数规模 | 激活参数 | 定位 |
| --- | --- | --- | --- |
| DeepSeek-V4-Pro | 1.6T | 49B | 高能力版本，面向复杂推理、知识、Agentic Coding 和长上下文任务 |
| DeepSeek-V4-Flash | 284B | 13B | 更快、更经济的 API 版本，推理能力接近 Pro，但知识与困难 Agent 任务较弱 |

## 核心变化

- **百万上下文成为官方服务标配**：V4-Pro 与 V4-Flash 最大上下文长度均为 1M。
- **长上下文效率大幅提升**：技术报告称，在 1M token 上下文下，V4-Pro 相比 DeepSeek-V3.2 只需要约 27% 单 token 推理 FLOPs 和 10% KV cache；V4-Flash 进一步降到约 10% FLOPs 和 7% KV cache。
- **混合注意力架构**：技术报告将核心注意力改进拆为 Compressed Sparse Attention（CSA）与 Heavily Compressed Attention（HCA），目标是在 token 维度压缩 KV cache，同时保留长上下文可用性。
- **mHC 与 Muon**：引入 Manifold-Constrained Hyper-Connections（mHC）增强残差连接，并使用 Muon optimizer 改善收敛与训练稳定性。
- **Agent 能力专项优化**：官方新闻提到 V4 针对 Claude Code、OpenClaw、OpenCode、CodeBuddy 等主流 Agent 产品做了适配和优化。

## API 迁移

DeepSeek API 已同步上线 `deepseek-v4-pro` 与 `deepseek-v4-flash`，`base_url` 不变，调用时改 `model` 参数即可。两者均支持非思考模式与思考模式，思考模式使用 `reasoning_effort` 设置 `high` 或 `max`。

> [!warning]
> 旧模型名 `deepseek-chat` 与 `deepseek-reasoner` 将在 2026-07-24 停止使用。过渡期内，`deepseek-chat` 指向 `deepseek-v4-flash` 非思考模式，`deepseek-reasoner` 指向 `deepseek-v4-flash` 思考模式。

## 本地 raw

- 官方新闻可读版：[[raw/web/deepseek/news260424|DeepSeek-V4 预览版发布]]
- 官方新闻 HTML：`raw/web/deepseek/news260424.html`
- 技术报告 PDF：![[raw/assets/papers/deepseek/DeepSeek_V4.pdf]]

## 相关

- [[wiki/llm/LLM|LLM]]
- [[wiki/llm/模型训练/Flash Attention|Flash Attention]]
- [[wiki/llm/Agent/Agent|Agent]]
