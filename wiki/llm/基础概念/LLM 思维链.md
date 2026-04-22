---
title: LLM 思维链
summary: "LLM 思维链 (Chain of Thought) 是 2025 年大模型面试的核心考点。本文整理了 5 种主流思维链技术及其面试要点。"
source: https://www.notion.so/32110c9390f1811eac57c8d6dab59dd4
source_type: notion
note_type: topic
area: llm
topic: reasoning
collection: llm
parent_note: '[[wiki/llm/LLM]]'
status: seed
migrated_on: '2026-04-20'
tags:
- area/llm
- type/topic
- topic/reasoning
- collection/llm
---

LLM 思维链 (Chain of Thought) 是 2025 年大模型面试的核心考点。本文整理了 5 种主流思维链技术及其面试要点。

## 1. Chain of Thought (CoT) | 思维链

核心概念：让模型在给出答案前展示推理步骤

- 典型 Prompt："Let's think step by step"
- 适用任务：数学推理、逻辑推理、多步问题
- Zero-shot CoT vs Few-shot CoT

论文：Chain-of-Thought Prompting Elicits Reasoning in Large Language Models

[链接：https://arxiv.org/abs/2201.11903](https://arxiv.org/abs/2201.11903)

---

#### 📊 CoT 架构图

![](https://ar5iv.labs.arxiv.org/html/2201.11903/assets/x1.png)

💡 CoT: 将复杂问题分解为多个推理步骤

## 2. Self-Consistency | 自一致性

核心概念：生成多条推理路径，选择最一致的答案

- 工作流程：同一问题 → 多次采样 → 投票选择
- 优势：提高答案可靠性
- 权衡：计算成本 vs 准确率

[https://arxiv.org/abs/2203.11171](https://arxiv.org/abs/2203.11171)

---

#### 📊 Self-Consistency 架构图

![](https://ar5iv.labs.arxiv.org/html/2203.11171/assets/x1.png)

💡 Self-Consistency: 生成多条推理路径，投票选择最一致答案

## 3. Tree of Thoughts (ToT) | 思维树

核心概念：树状结构，支持回溯和分支

- 搜索策略：BFS / DFS
- 适用场景：创意写作、规划问题

[https://arxiv.org/abs/2305.10601](https://arxiv.org/abs/2305.10601)

---

#### 📊 ToT 架构图

![](https://raw.githubusercontent.com/princeton-nlp/tree-of-thought-llm/master/pics/teaser.png)

💡 ToT: 树状结构探索，支持回溯和分支剪枝

## 4. Graph of Thoughts (GoT) | 思维图

核心概念：图结构，支持聚合、循环和复杂依赖

- 与 ToT 区别：支持非线性思维连接

[论文：https://arxiv.org/abs/2308.09687](https://arxiv.org/abs/2308.09687)

---

#### 📊 GoT 架构图

![](https://ar5iv.labs.arxiv.org/html/2308.09687/assets/x1.png)

💡 GoT: 图结构，支持聚合、循环和复杂依赖关系

## 5. ReAct | Reason + Act

核心概念：推理 + 行动，与外部环境交互

- 工作流程：思考 → 行动 → 观察 → 循环
- 优势：减少幻觉，支持工具调用

[论文：https://arxiv.org/abs/2210.03629](https://arxiv.org/abs/2210.03629)

### 📊 架构图

#### ReAct 工作流程

![](https://react-lm.github.io/files/diagram.png)

ReAct: Thought → Action → Observation 循环

#### LLM Agent 架构

![](https://lilianweng.github.io/posts/2023-06-23-agent/agent-overview.png)

LLM Agent = 大脑 (LLM) + 规划 + 记忆 + 工具使用

## 常见面试问题

1. 解释 CoT 的工作原理，为什么它能提升模型表现？
2. CoT 和 Self-Consistency 有什么区别？如何结合使用？
3. ToT 适用于什么场景？举例说明
4. ReAct 如何解决 LLM 的幻觉问题？
5. 如何评估思维链的质量？
6. 思维链技术有哪些局限性？
7. 在实际项目中如何选择适合的推理架构？

## 参考资源

- [GitHub: wdndev/llm_interview_note (13.1k 星)](https://github.com/wdndev/llm_interview_note)
- [在线阅读：https://wdndev.github.io/llm_interview_note](https://wdndev.github.io/llm_interview_note)

---
