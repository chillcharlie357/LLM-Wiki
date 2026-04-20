---
title: RAG 系统评估指标
source: https://www.notion.so/33710c9390f181bab280c149551c9020
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

## 📊 RAG 系统评估框架

RAG 评估主要从三个维度进行：检索质量、生成质量、端到端评估

### 1️⃣ 检索质量 (Retrieval)

- Recall@K: 前 K 个结果中包含正确答案的比例
- MRR (Mean Reciprocal Rank): 正确答案的平均排名倒数
- NDCG@K: 考虑排名位置的相关性评分
- Hit Rate: 检索到相关文档的比例

### 2️⃣ 生成质量 (Generation)

- Faithfulness (忠实度): 生成内容是否基于检索到的文档
- Answer Relevance (答案相关性): 生成答案是否与问题相关
- Context Relevance (上下文相关性): 检索的上下文是否有用
- BLEU/ROUGE: 与参考答案的文本相似度

### 3️⃣ 端到端评估 (End-to-End)

- Answer Accuracy: 最终答案是否正确
- Response Time: 端到端延迟
- Token 效率：消耗的 token 数量

### 🛠️ Ragas 核心指标

- Faithfulness (忠实度): 答案是否基于上下文，无幻觉
- Answer Relevance (答案相关性): 答案与问题的相关程度
- Context Precision (上下文精度): 相关文档在检索结果中的排名
- Context Recall (上下文召回率): 检索到的上下文包含正确答案的程度
- Answer Similarity (答案相似度): 与参考答案的语义相似度

### 🔧 常用评估工具

- Ragas (最流行): 开源 RAG 评估框架
- TruLens: 带可视化仪表板的评估工具
- ARES: 自动化 RAG 评估系统
- DeepEval: 基于 LLM 的评估框架

### 💡 面试加分点

1. 构建评估数据集：人工标注 (问题，上下文，正确答案) 三元组
2. 自动化评估流水线：每次迭代自动跑评估
3. A/B 测试：对比不同检索策略/模型的效果
4. 线上监控：用户反馈、点赞率、追问率

---

📅 更新时间：2026-04-03 | 来源：Ragas 官方文档 + 字节面试真题
