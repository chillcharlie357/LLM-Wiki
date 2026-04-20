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
- 将 [raw/LLM Wiki.md](/Users/heleyang/Code/MyWiki/raw/LLM%20Wiki.md) 的抽象模式整理为 [Karpathy LLM Wiki](/Users/heleyang/Code/MyWiki/wiki/Karpathy%20LLM%20Wiki.md)，并在根目录新增 [AGENT.md](/Users/heleyang/Code/MyWiki/AGENT.md) 作为知识库维护 schema，固化三层结构、ingest/query/lint、日志与索引同步、空父页禁用等关键原则。
- 接入 `qmd` 作为后续默认本地检索工具，并将其写入 `AGENT.md` 与 `Karpathy LLM Wiki` 页面，约定优先使用 `qmd query/search/get/multi-get` 在 `wiki/` 与 `raw/` 中定位相关内容。
- 在工作区内完成 `qmd` 初始化：使用本地 `.config/qmd/index.yml` 与 `.cache/qmd/index.sqlite` 建立 `wiki` / `raw` 两个 collection，并确认 `qmd ls`、`qmd search`、`qmd get` 可在当前仓库内正常工作；同时将这些本地索引文件加入 `.gitignore`。
- 增加仓库内包装脚本 `./qmdw`，统一为当前知识库注入本地 `qmd` config/cache 路径，避免后续每次手写 `XDG_CONFIG_HOME` / `XDG_CACHE_HOME`。
- 为 `qmdw` 增加独立说明页 [qmdw](/Users/heleyang/Code/MyWiki/wiki/qmdw.md)，集中记录它的职责、固定的配置/索引路径、常用命令、与直接运行 `qmd` 的区别，以及当前 embedding 相关限制；同时同步更新首页与维护约定中的入口。
- 继续排查 `qmd embed`：在已授权状态下重试 embedding 后，确认它会长时间停在初始化阶段且不落模型文件、不写向量；进一步用 `curl -I https://huggingface.co` 验证当前环境到 Hugging Face 连接超时，因此当前 embedding 阻塞点可以收敛为模型下载链路而不是本地索引配置。
- 调整 `qmdw` 的模型下载链路：基于 `node-llama-cpp` 对 `HF_ENDPOINT` / `MODEL_ENDPOINT` 的支持，将默认 Hugging Face 端点切换为 `https://hf-mirror.com`；并通过 `curl -I https://hf-mirror.com` 验证镜像站在当前环境下可达。
- 通过 `hf-mirror.com` 跑通 `./qmdw embed`：成功下载 `embeddinggemma-300M-Q8_0.gguf` 到仓库内 `.cache/qmd/models/`，并为当前 `wiki` / `raw` 两个 collection 生成 497 个向量分块；`./qmdw status` 已更新为 `Vectors: 497 embedded`。
- 执行一轮 wiki lint：校验 `wiki/` 下全部 Markdown frontmatter、`map.canvas` 文件节点与连线、绝对本地来源链接、`qmd` 索引状态；修复首页中残留的坏链接 `wiki/foundations/基础 -> 基础目录`，并准备重新同步 `qmd` 索引与 embeddings。
- 调整 `Agent` 目录结构：将 `Harness Engineering`、`Harness Engineering × SDD`、`OpenHarness`、`OpenClaw vs Claude Code vs Mem0` 四篇收纳到 `wiki/llm/Agent/Harness/` 子目录，保留独立页面但减少 `Agent/` 根层级平铺；同时同步更新首页、`Agent.md` 与 `Pi.md` 中的链接。
- 生成 repo 内 skill [obsidian-wiki-maintainer](/Users/heleyang/Code/MyWiki/skills/obsidian-wiki-maintainer/SKILL.md)：把当前知识库维护流程整理成可复用的 Skill，覆盖创建 wiki、插入/更新内容、使用 `qmdw` 检索、以及 frontmatter / link / canvas / qmd 索引与 embedding 的 lint 流程。
- 将 [obsidian-wiki-maintainer](/Users/heleyang/Code/MyWiki/skills/obsidian-wiki-maintainer/SKILL.md) 去项目绑定并改成可迁移版本：移除绝对路径、个人目录与仓库专属表述，改为先探测当前 vault 约定，再按通用的 create / ingest / retrieve / lint 流程执行；同时为 `qmdw` 提供 plain `qmd` 回退路径。
- 为 [obsidian-wiki-maintainer](/Users/heleyang/Code/MyWiki/skills/obsidian-wiki-maintainer/SKILL.md) 补充标准模板与依赖说明：新增 `AGENT.md`、`index.md`、`log.md`、`qmdw`、`.config/qmd/index.yml` 模板，并明确该 skill 依赖 `obsidian` CLI 与 `qmd`，适合作为新 vault 的通用初始化骨架。
- 继续补齐 [obsidian-wiki-maintainer](/Users/heleyang/Code/MyWiki/skills/obsidian-wiki-maintainer/SKILL.md) 的 `raw/` 模板：新增 `raw/README.md` 说明 source archive 的职责、规则与建议目录结构，并增加 `raw/assets/.gitkeep` 作为附件目录占位。
- 将 `raw/pi-agent/` 提炼为 `wiki/llm/Agent/Pi/` 主题目录：新增 `Pi.md` 与 `Pi 与 OpenClaw 集成架构.md`，把 Pi 的极简哲学、self-extension 思路、session tree、pi-mono 组件分层，以及 OpenClaw 的 embedded 集成方式整理进 wiki，并同步更新 `Agent.md`、`index.md` 与 `map.canvas` 导航。
- 为 `Pi` 主题补充 Mermaid 可视化：在 `Pi.md` 中增加 `pi-mono` 代码架构图、自我扩展闭环图与 session 树工作流图；在 `Pi 与 OpenClaw 集成架构.md` 中增加嵌入式分层架构图、运行时序图与工具管线图，方便在 Obsidian 阅读视图里直接理解代码结构与执行路径。
- 新增 [obsidian-wiki-maintainer](/Users/heleyang/Code/MyWiki/skills/obsidian-wiki-maintainer/SKILL.md) 的全局安装与一键初始化能力：补充 `scripts/install_global.sh` 用于安装到全局 skills 目录，并新增 `scripts/bootstrap_wiki.sh` 用于一键生成新 Obsidian wiki 的标准骨架、`qmdw` 包装脚本和本地 qmd 配置。
- 调整 `bootstrap_wiki.sh` 的 `AGENT.md` 策略：如果目标项目已存在 `AGENT.md`，不再覆盖，而是在文件尾部追加一个带标记的 Obsidian wiki 维护区块；若该区块已存在，则跳过，避免重复写入。
- 为 `obsidian-wiki-maintainer` 增加首次使用依赖体检：新增 `scripts/check_dependencies.sh`，在 bootstrap 前检查 `obsidian`、`qmd`、Obsidian 安装版本，以及 macOS/Linux 下的 CLI 注册与 PATH 状态，并引用官方 CLI troubleshooting 作为诊断入口。
