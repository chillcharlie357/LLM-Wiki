---
title: Vector Graph RAG
summary: "Vector Graph RAG 的核心目标，是在不额外引入图数据库的前提下，把多跳检索能力压回同一套向量数据库里。它的卖点不是“图谱替代向量检索”，而是把实体、关系、段落都存成可检索对象，再靠 ID 引用形成一个逻辑图结构。"
source: https://mp.weixin.qq.com/s/O_3MS-pHts15Quqwev4MEg
source_type: weixin
note_type: reference
area: llm
topic: rag
collection: RAG
parent_note: '[[wiki/llm/RAG/RAG]]'
status: seed
migrated_on: '2026-04-22'
tags:
- area/llm
- type/reference
- topic/rag
- collection/RAG
- rag/multi-hop
- vector-db
aliases:
- Vector Graph RAG 开源！一套向量数据库同时搞定语义检索+RAG多跳
---

# Vector Graph RAG

Vector Graph RAG 的核心目标，是在不额外引入图数据库的前提下，把多跳检索能力压回同一套向量数据库里。它的卖点不是“图谱替代向量检索”，而是把实体、关系、段落都存成可检索对象，再靠 ID 引用形成一个逻辑图结构。

## 一句话总结

- 一个 Milvus 同时承担语义检索和“图式”多跳扩展。
- 实体、关系、段落分成三张表，用 ID 互相引用，而不是依赖独立图数据库。
- 查询阶段固定走 `种子检索 -> 子图扩展 -> LLM 重排 -> 答案生成`。
- 重点优势是系统更简单、时延更可控、调用 LLM 次数固定。

## 核心问题

普通 RAG 擅长单跳问题，但对多跳问题经常会漏掉中间桥接实体。

示例问题：

> 糖尿病的一线用药有哪些需要注意的副作用？

这类问题至少包含两段关系链：

1. 糖尿病的一线用药是二甲双胍。
2. 二甲双胍有哪些副作用或注意事项。

Naive RAG 往往只能召回“糖尿病”“副作用”附近的段落，但抓不到“二甲双胍”这个关键中间节点。

![[raw/assets/weixin/vector-graph-rag/body-01.jpeg]]

## 数据模型

Vector Graph RAG 用三张逻辑表承载“图”：

### Entities

- 存去重后的实体
- 每个实体有唯一 ID
- 保存实体 embedding
- 记录该实体参与的 `relation_ids`

### Relations

- 存三元组关系
- 记录 `subject_id`、`object_id`
- 把关系文本本身也向量化
- 记录其来源 `passage_ids`

### Passages

- 存原始文档段落
- 记录段落中包含的实体 ID 和关系 ID
- 用于最终答案生成时回填完整上下文

这套结构的关键，不是把 Milvus 变成图数据库，而是通过实体、关系、段落之间的 ID 引用，拼出一个可以扩展的逻辑子图。

![[raw/assets/weixin/vector-graph-rag/body-02.jpeg]]

## 检索流程

### 1. 种子检索

- 从问题里抽实体和关键短语
- 在实体表和关系表中做向量检索
- 找到初始候选实体与关系

### 2. 子图扩展

- 从种子实体出发读取 `relation_ids`
- 到关系表拿到相邻关系
- 再从关系里拿到新的实体 ID
- 默认做 1 跳扩展，必要时继续扩展

这一步把原本分散在不同段落里的信息链路补齐，是它区别于 Naive RAG 的核心。

### 3. LLM 重排

- 子图扩展后候选关系会变多
- 其中很多是噪音、背景知识或弱相关内容
- 让 LLM 对候选关系做一次性筛选，而不是多轮 agent 迭代

### 4. 生成答案

- 不直接把关系三元组喂给 LLM
- 而是回到关系对应的原始段落
- 用完整上下文生成最终答案

![[raw/assets/weixin/vector-graph-rag/body-03.jpeg]]

![[raw/assets/weixin/vector-graph-rag/body-04.jpeg]]

## 为什么它比“图数据库 + 向量库”轻

- 不需要维护两套基础设施
- 不需要引入 Cypher 一类新查询语言
- 不需要处理图库与向量库的数据同步
- 多出来的访问主要是主键级 ID 查询，成本远低于多轮 LLM 推理

原文的论点可以浓缩成一句话：

> 它不是把图遍历做没了，而是把图遍历降级成向量数据库上的元数据跳转。

## 和常见方案的对比

### 对 Naive RAG

- 优势：能跨段落补齐推理链
- 代价：比单次向量检索多几次 ID 查询
- 适用：2 到 4 跳的多跳问答

![[raw/assets/weixin/vector-graph-rag/body-05.png]]

### 对 GraphRAG

- 优势：部署更轻，不强依赖图数据库和复杂索引构建
- 劣势：不擅长全局摘要、社区聚类这类图级分析任务

### 对 HippoRAG

- 优势：更偏工程落地，依赖更少，不需要额外的 ColBERTv2 体系
- 劣势：在最难的多跳 benchmark 上未必始终领先

### 对 IRCoT / Agentic RAG

- 优势：LLM 调用次数固定，更可控
- 劣势：极长推理链或开放式探索任务的灵活性可能不如多轮迭代方案

![[raw/assets/weixin/vector-graph-rag/body-06.png]]

## 适用场景

- 知识密集、实体关系明显的语料
- 2 到 4 跳的多跳问答
- 想要单库部署，不愿引入独立图数据库的团队
- 对时延和 API 成本比较敏感的系统

## 局限和判断

- 它本质上仍然依赖关系抽取质量，抽取差会直接影响扩展质量。
- “一个向量库搞定一切”成立的前提，是业务更看重多跳检索，而不是复杂图分析。
- 原文 benchmark 结论是有吸引力的，但仍然需要结合你自己的语料结构做验证，不能直接把公开集成绩映射到生产场景。

## 快速上手要点

原文给出的使用路径很直接：

```python
from vector_graph_rag import VectorGraphRAG

rag = VectorGraphRAG()
rag.add_texts([
    "二甲双胍是2型糖尿病的一线用药。",
    "服用二甲双胍的患者应定期监测肾功能。",
])

result = rag.query("糖尿病的一线用药有哪些副作用需要注意？")
print(result.answer)
```

工程含义很明确：

- 默认可用 Milvus Lite 本地起步
- 文本入库时自动抽三元组并建立实体-关系-段落索引
- 查询接口直接跑完整的多跳检索链路

## 可视化前端

原文还展示了一个交互式前端，用于把检索流程的四个阶段可视化：

- 种子节点
- 子图扩展后的节点
- 重排保留的关系
- 最终用于回答的上下文

![[raw/assets/weixin/vector-graph-rag/body-07.gif]]

![[raw/assets/weixin/vector-graph-rag/body-08.png]]

## 相关笔记

- [[wiki/llm/RAG/RAG|RAG]]
- [[wiki/llm/RAG/RAG 架构总结|RAG 架构总结]]
- [[wiki/llm/RAG/RAG 系统评估指标|RAG 系统评估指标]]

## 参考

- 微信原文：<https://mp.weixin.qq.com/s/O_3MS-pHts15Quqwev4MEg>
- GitHub：<https://github.com/zilliztech/vector-graph-rag>
- 文档：<https://zilliztech.github.io/vector-graph-rag>
