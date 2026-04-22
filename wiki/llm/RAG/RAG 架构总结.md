---
title: RAG 架构总结
summary: "RAG (Retrieval Augmented Generation, 检索增强生成) 是一种通过结合实时数据检索来增强大语言模型文本生成的技术。"
source: https://www.notion.so/32110c9390f1814fa0b6face8ab5e8c5
source_type: notion
note_type: reference
area: llm
topic: rag
collection: RAG
parent_note: '[[wiki/llm/RAG/RAG]]'
status: seed
migrated_on: '2026-04-20'
tags:
- area/llm
- type/reference
- topic/rag
- collection/RAG
---

RAG (Retrieval Augmented Generation, 检索增强生成) 是一种通过结合实时数据检索来增强大语言模型文本生成的技术。

核心流程：检索 (Retrieval) → 生成 (Generation)

优势：减少幻觉、提高准确性、支持实时更新

---

## 1. Simple RAG (简单 RAG)

最基础的 RAG 形式，从静态数据库检索文档后生成响应。

流程：用户查询 → 文档检索 → 生成响应

适用：FAQ 系统、客服机器人、产品手册查询

![](https://humanloop.com/blog/rag-architectures/simple-rag.png)

## 2. Simple RAG with Memory (带记忆的简单 RAG)

引入存储组件，保留之前交互的信息，支持跨多轮对话的上下文感知。

流程：用户查询 → 访问记忆 → 文档检索 → 结合记忆生成响应

适用：客服聊天机器人、个性化推荐、需要记住用户偏好的场景

![](https://humanloop.com/blog/rag-architectures/simple-rag-with-memory.png)

## 3. Branched RAG (分支 RAG)

根据输入查询智能选择最相关的数据源，而非查询所有可用源。

流程：用户查询 → 分支选择 → 单一检索 → 生成响应

适用：法律工具、多学科研究、需要选择最佳信息源的复杂查询

![](https://humanloop.com/blog/rag-architectures/branched-rag.png)

## 4. HyDe (Hypothetical Document Embedding)

假设文档嵌入，先生成假设文档的嵌入表示，再以此指导检索，提高结果相关性。

流程：用户查询 → 创建假设文档 → 基于假设文档检索 → 生成响应

适用：研发、模糊查询、创意内容生成、需要灵活想象输出的场景

![](https://humanloop.com/blog/rag-architectures/HyDe.png)

## 5. Adaptive RAG (自适应 RAG)

根据查询复杂度动态调整检索策略的实时自适应实现。

流程：用户查询 → **自适应检索（单源/多源）** → 生成定制响应

适用：企业搜索系统、查询类型多变的场景、平衡速度与深度

![](https://humanloop.com/blog/rag-architectures/adaptive-rag.png)

## 6. Corrective RAG / CRAG (校正 RAG)

引入**自反思/自评分机制**，对检索文档进行质量评估后再进行生成。

流程：用户查询 → 文档检索 → 知识条带拆分与评分 → 知识精炼（过滤无关/补充搜索） → 生成响应

适用：法律文档生成、医疗诊断支持、金融分析等需要高准确性的场景

![](https://humanloop.com/blog/rag-architectures/corrective-rag.png)

## 7. Self-RAG (自检索 RAG)

在生成过程中自主生成检索查询，迭代完善检索内容。

流程：用户查询 → 初始检索 → 自检索循环（识别信息缺口并发出新查询） → 迭代生成响应

适用：探索性研究、长篇幅内容创作、需要动态补充信息的复杂查询

![](https://humanloop.com/blog/rag-architectures/self-rag.png)

## 8. Agentic RAG (代理 RAG)

引入代理行为，为每个文档分配 Document Agent，通过 Meta-Agent 协调多源信息。

流程：复杂查询 → 激活多个代理 → 多步检索（Meta-Agent 协调） → 综合生成响应

适用：自动化研究、多源数据聚合、高管决策支持、需要跨系统整合信息的任务

![](https://humanloop.com/blog/rag-architectures/agentic-rag.png)

---

## 参考文献

Humanloop. [8 Retrieval Augmented Generation (RAG) Architectures You Should Know in 2025](https://humanloop.com/blog/rag-architectures). 2025.

RAG 评估指南：[https://github.com/humanloop/humanloop-cookbook/blob/main/tutorials/rag/evaluate-rag.ipynb](https://github.com/humanloop/humanloop-cookbook/blob/main/tutorials/rag/evaluate-rag.ipynb)

RAG 详解：[https://humanloop.com/blog/rag-explained](https://humanloop.com/blog/rag-explained)

更新时间：2026-03-12
