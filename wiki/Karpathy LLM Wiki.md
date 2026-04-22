---
title: Karpathy LLM Wiki
summary: "这份页面整理自 raw/LLM Wiki.md，核心目标是把“用 LLM 维护个人/团队 wiki”的抽象想法，落成当前仓库可执行的维护方式。"
source: raw/LLM Wiki.md
source_type: local_raw
note_type: guide
area: wiki
topic: workflow
collection: wiki
status: active
migrated_on: 2026-04-20
tags:
  - area/wiki
  - type/guide
  - topic/workflow
  - collection/wiki
aliases:
  - LLM Wiki 模式
---

# 知识库维护模式

这份页面整理自 [raw/LLM Wiki.md](/Users/heleyang/Code/MyWiki/raw/LLM%20Wiki.md)，核心目标是把“用 LLM 维护个人/团队 wiki”的抽象想法，落成当前仓库可执行的维护方式。

## 核心想法

传统 RAG 的工作方式是：提问时再去原始资料里找相关片段，然后临时拼出答案。这样可以回答问题，但知识不会沉淀，复杂问题每次都要重新检索、重新综合。

这里采用的方式不同：

- `raw/` 保存原始资料，作为只读事实来源
- `wiki/` 保存 LLM 整理后的结构化知识页
- `AGENT.md` 保存维护 wiki 的约定、流程和更新原则

关键差异是：**wiki 是持续累积的中间层**。新增资料时，不只是“可检索”，而是会被整理进已有页面，补充摘要、建立链接、修正旧结论、标记冲突，并沉淀成之后可以直接复用的知识结构。

## 三层架构

### 1. Raw sources

- 放在 `raw/` 中
- 包含文章、导出 markdown、截图、PDF、附件等
- 作为事实来源保留，不做整理性改写

### 2. Wiki

- 放在 `wiki/` 中
- 由 LLM 负责创建、更新、交叉引用和结构维护
- 按主题目录组织，而不是 Notion 式空父页嵌套

### 3. Schema

- 放在根目录的 `AGENT.md`
- 定义 ingest、query、lint、日志、索引、命名和资源归档的规则
- 作用是把 LLM 从“泛化聊天助手”约束成“知识库维护者”

## 主要操作

### Ingest

新增资料后，维护动作不应该只停留在单页摘要，而应该至少覆盖下面几类更新：

1. 读取 `raw/` 中的新资料
2. 提炼要点，决定应该更新哪些现有页面
3. 必要时创建新的主题页、对比页或总结页
4. 更新 [index.md](/Users/heleyang/Code/MyWiki/wiki/index.md) 中的入口
5. 追加 [log.md](/Users/heleyang/Code/MyWiki/wiki/log.md) 记录这次变更

一个来源不一定只落到一页，理想状态是一次 ingest 会同步更新多个相关页面。

### Query

问题不只产生“回答”，还应该尽量产生“可复用资产”。

- 如果回答只是一次性解释，可以留在对话里
- 如果回答形成了稳定结论、比较框架、术语总结或专题分析，就应该回写到 `wiki/`

这样查询过程本身也会让知识库继续增长，而不是让有价值的分析只停留在聊天历史里。

### Lint

知识库需要周期性体检。重点检查：

- 页面之间是否存在冲突或过时结论
- 是否有孤儿页、坏链接、旧路径残留
- 重要概念是否频繁出现但仍缺页
- 新目录结构是否同步到了 `map.canvas`、`wiki.base`、`index.md`
- 图片、附件、引用路径是否仍然指向过时位置

## 索引与日志

### index.md

[index.md](/Users/heleyang/Code/MyWiki/wiki/index.md) 是内容入口，应该优先回答“知识库里有什么”。

- 按主题组织入口
- 指向可读页面，而不是原始导出页
- 在结构变化后同步更新

### log.md

[log.md](/Users/heleyang/Code/MyWiki/wiki/log.md) 是时间线，应该回答“最近做了什么”。

- 每次大迁移、大重构、大批量清洗都要追加
- 记录变更内容、验证结果和剩余缺口
- 方便后续 agent 了解最近维护上下文

## 当前仓库的落地约定

结合当前仓库，实际执行时采用下面这些具体原则：

- `raw/` 只做资料归档，不做整理性重写
- `wiki/` 承担阅读、导航、总结和交叉引用
- 页面尽量保留 `source` 字段
- 图片和附件优先归档到 `raw/assets/`
- 不创建只有跳转作用的空父页
- 新的结构调整要同步更新 `index.md`、`log.md`、`map.canvas`、`wiki.base`
- 值得保留的问答结果应该沉淀为 wiki 页面，而不是只留在对话里

## 本地检索工具

当前仓库后续默认采用 `qmd` 作为本地检索工具，而不是只依赖简单的文件遍历或 `grep`。

- `qmd query <query>`：优先使用的混合检索入口
- `qmd search <query>`：纯 BM25 关键词检索
- `qmd get <file>[:line]`：读取单个命中文档
- `qmd multi-get <pattern>`：批量获取多份文档

当前仓库另外提供了一个本地包装脚本：

- `./qmdw ...`

它会自动把 `qmd` 的 config 和 cache 固定到仓库内的 `.config/`、`.cache/`，避免每次手动写环境变量。
更具体的仓库内用法见 [qmdw](/Users/heleyang/Code/MyWiki/wiki/qmdw.md)。

这和原始 `LLM Wiki` 思路里提到的“随着规模增长，需要更强的本地搜索工具”是一致的。对当前仓库来说，`index.md` 仍然是主题导航入口，而 `qmd` 负责更快地在 `wiki/` 与 `raw/` 中定位相关页面与原始资料。

## 这套方式为什么有效

维护知识库最耗人的往往不是阅读和思考，而是繁琐的整理工作：补链接、改摘要、同步多页、处理冲突、维持一致性。人很容易因为维护成本高而放弃，LLM 则更适合承担这类重复但需要上下文的整理工作。

因此，人的职责更接近：

- 筛选资料
- 判断重点
- 提问题
- 做最终取舍

而 LLM 的职责更接近：

- 整理
- 归档
- 交叉引用
- 持续维护

## 对应规则

这份页面偏解释性；真正用于约束后续维护动作的规则，见根目录 [AGENT.md](/Users/heleyang/Code/MyWiki/AGENT.md)。
