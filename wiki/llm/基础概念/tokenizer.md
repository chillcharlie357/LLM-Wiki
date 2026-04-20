---
title: tokenizer
source: https://www.notion.so/31b10c9390f18068904ecf585c4d363b
source_type: notion
note_type: topic
area: llm
topic: tokenizer
collection: llm
parent_note: '[[wiki/llm/LLM]]'
status: seed
migrated_on: '2026-04-20'
tags:
- area/llm
- type/topic
- topic/tokenizer
- collection/llm
---

## BPE (Byte Pair Encoding) 和 WordPiece 的区别

都是**子词（Subword）分词算法**。它们都旨在解决“未登录词（OOV）”问题，但在**合并规则**和**对齐逻辑**上有着本质的区别。

### **BPE：基于单纯的频率**

BPE 的逻辑非常直观：寻找语料中**出现次数最多**的相邻字符对，并将它们合并。

- **过程**：假设 `a` 和 `b` 经常在一起出现（如 `e` 和 `r`），我们就把 `er` 作为一个新的 Token 加入词表。
- **优点**：简单、高效，不依赖复杂的统计假设。

### **WordPiece：基于互信息/似然概率**

WordPiece 不仅仅看频率，它会考虑合并后对整体语料的“解释力”。

它计算两个子词 A 和 B 合并为 AB 的得分：$\text{Score} = \frac{P(AB)}{P(A) \times P(B)}$

- **逻辑**：它衡量的是 A 和 B 结合的紧密程度。如果 A 和 B 经常在一起，但 A 或 B 单独出现的概率很低，那么这个分数就会很高。
- **直观理解**：它更倾向于合并那些“**在一起时比分开时更有意义**”的词对，从而构建一个信息熵更优的词表。
