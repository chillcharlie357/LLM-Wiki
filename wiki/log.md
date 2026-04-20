---
title: log
note_type: log
area: wiki
topic: log
collection: wiki
status: active
migrated_on: '2026-04-20'
tags:
- area/wiki
- type/log
- topic/log
- collection/wiki
---

# log

## 2026-04-20

- 初始化本地 Obsidian vault，并接入 git 版本控制。
- 从 Notion `🖥️ 知识库` 迁移首批页面到本地 Markdown。
- 修正部分页面中的公式和代码块格式。
- 参考 Karpathy 的 wiki 组织方式，将内容整理到 `wiki/`，为 `raw/` 预留原始资料目录。
- 按 Obsidian 的使用习惯补齐目录页、`wiki.base` 结构化索引和 `map.canvas` 知识地图，使文件树、目录页和可视化关系保持一致。
- 维护约定更新：后续每次较大的 wiki 迁移、结构调整或批量整理，都需要同步追加到本页，记录变更内容、验证结果和剩余缺口。
- 删除无实际正文的父页面文件，避免把 Notion 的层级页模型直接照搬到 Obsidian；同步清理首页、目录页、`wiki.base` 和 `map.canvas` 中对这些空父页的引用。
- 为全部现有笔记补齐统一 frontmatter 元数据，新增 `note_type`、`area`、`topic`、`collection`、`status`、`source_type`、`migrated_on` 等字段，并让 `wiki.base` 基于这些属性提供按类型、状态和集合分组的视图。
- 以 `raw/notion导出知识库/` 的手动导出结果为准重新核对覆盖率，将缺失的 `Cuda`、`Nano-vllm`、`Agent` 延伸阅读等 11 篇笔记补入 `wiki/`，并保留 `raw/` 作为只读原始镜像。
- 将现有 `wiki/` 中 29 篇已有技术笔记的正文从 `raw/notion导出知识库/` 原始导出重新回填，替换此前不完整的摘要版内容；目录结构、frontmatter 元数据和手工目录页继续保留。
- 将手动导出中的 24 个本地资源镜像归档到 `raw/assets/notion导出知识库/`，并批量改写 `wiki/` 中的资源嵌入路径；同时清洗 Notion 导出痕迹，将 `<aside>` 转为 Obsidian callout，统一正文标题层级，去掉空引用行和明显的空链接噪声。
- 修复 `wiki/` 中一批不符合 Obsidian Markdown 的格式问题：为空代码块补语言标识，清理 `\(...\)` 数学写法和坏掉的 `file:///` / 外链混合链接，并手工修正 `cs336`、`Flash Attention`、`Agent面试文档（2026-2-23）` 的公式与代码块渲染。
- 继续优化阅读视图渲染：批量拆开被导出压缩到同一行的标题、表格、代码块和横线，合并 `Agent面试文档（2026-2-23）` 中被拆成多张的连续表格，并把 `Nano-vLLM` 中的架构示意从伪代码块调整为更适合 Obsidian 展示的 `text` 图示。
- 继续精修长文排版：将 `Agent面试文档（2026-2-23）` 中的全角编号和伪列表转换为标准 Markdown 有序列表，统一 `Q:` 问答标记和缺失空格的无序列表，并顺手修正若干问答行内排版与示例可读性。
- 继续修正 `Agent面试文档（2026-2-23）` 的阅读视图细节：修复被污染的 frontmatter 分隔线，统一问答标题后的空格和全角符号，补齐断裂的 `Pydantic` 代码块，并把 MCP 架构说明、RAG 基础流程、Computer Use 技术流程改写为更适合 Obsidian 阅读视图的 Markdown 列表。
- 合并 `wiki/llm/Agent/Agent.md` 与 `Agent面试文档（2026-2-23）.md`：保留 `Agent` 作为唯一入口页，将面试文档正文并入同一页面，给 `Agent` 增加旧标题 alias，清理首页里的重复入口，减少 Obsidian 文件树中的重复节点。
- 调整 LLM 目录层级：保留 `wiki/llm/LLM.md` 作为目录页，将 `LLM 思维链.md` 和 `tokenizer.md` 归入 `wiki/llm/基础概念/`，并同步更新首页与 LLM 目录页的链接，减少 LLM 根层级的平铺条目。
- 修复 `wiki/map.canvas` 中因笔记移动导致的坏节点：将 `tokenizer` 节点从旧路径 `wiki/llm/tokenizer.md` 更新为 `wiki/llm/基础概念/tokenizer.md`，并重新校验 canvas 中所有文件节点与连线引用，确保没有悬空节点和断边。
