# MyWiki Agent Schema

本文件定义当前仓库中 agent 维护知识库时应遵守的核心原则与工作流。

## 目标

把本仓库维护成一个**持续累积、持续校正、持续可导航**的本地知识库。

重点不是临时回答问题，而是把有价值的知识沉淀为可复用的 wiki 页面。

## 三层结构

### `raw/`

- 保存原始资料、导出 markdown、PDF、截图、附件
- 视为事实来源
- 默认只读，不做整理性改写

### `wiki/`

- 保存整理后的知识页、目录页、索引、知识地图
- 是主要阅读层和知识沉淀层
- 允许创建、重组、合并、拆分页面

### `AGENT.md`

- 保存维护规则、命名约定和操作流程
- 作为后续 agent 的 schema 文件

## 核心原则

1. Wiki-first, raw-second
   - 优先把知识沉淀到 `wiki/`，不要每次都从 `raw/` 重新推导。

2. Raw is immutable
   - `raw/` 用于归档原始资料；除非是补充附件、图片或新导出，不直接在其中做整理性编辑。

3. Query results can become pages
   - 如果一次问答产出了稳定结论、比较框架、专题总结、方法论或长期有用的解释，应将其整理进 `wiki/`。

4. No empty parent pages
   - 不照搬 Notion 的空父页模型。
   - 优先使用目录结构组织页面。
   - 只有在父页本身有实际正文时才保留该页。

5. Structure changes must propagate
   - 任何目录调整、文件移动、合并或删除，都要同步检查：
   - `wiki/index.md`
   - `wiki/log.md`
   - `wiki/map.canvas`
   - `wiki/wiki.base`
   - 相关页面中的 wikilink 和 `parent_note`

6. Preserve traceability
   - 页面尽量保留 `source` 字段。
   - 附件和图片优先归档到 `raw/assets/`。
   - 避免让知识页失去原始来源线索。

7. Prefer durable summaries over temporary chat answers
   - 有复用价值的分析应写入 wiki，而不是只停留在对话历史。

8. Log every major update
   - 大迁移、大重构、大批量格式清洗、大范围重命名、大规模页面补全，都必须写入 `wiki/log.md`。

## 标准操作

### Ingest

处理新资料时，至少执行以下动作中的大部分：

1. 读取 `raw/` 中的新资料
2. 提炼要点与结论
3. 更新已有页面，必要时新增页面
4. 建立或补充 wikilink
5. 更新 `wiki/index.md`
6. 如有结构变动，同步更新 `map.canvas` / `wiki.base`
7. 在 `wiki/log.md` 中追加记录

### Query

回答问题时：

1. 优先从 `wiki/` 中找现有沉淀内容
2. 优先使用 `qmd` 在 `wiki/` / `raw/` 上做本地检索，再按需打开具体文件
3. 需要时再回读 `raw/`
4. 如果回答形成了新的稳定知识结构，回写到 `wiki/`

### Lint

定期检查：

- 悬空页面与坏链接
- 目录变化后遗留的旧路径
- `map.canvas` 中失效节点
- `wiki.base` 中过期视图
- 页面间冲突或过时结论
- 频繁出现但仍缺页的重要概念

## 检索工具

默认优先使用 `qmd` 作为本地知识库检索工具。

- 优先命令：`qmd query <query>`
- 纯关键词检索：`qmd search <query>`
- 打开单个结果：`qmd get <file>[:line]`
- 批量拉取结果：`qmd multi-get <pattern>`

当前仓库使用工作区内的本地配置与索引：

- `XDG_CONFIG_HOME=/Users/heleyang/Code/MyWiki/.config`
- `XDG_CACHE_HOME=/Users/heleyang/Code/MyWiki/.cache`
- 仓库包装脚本：`/Users/heleyang/Code/MyWiki/qmdw`
- 默认镜像端点：`HF_ENDPOINT=https://hf-mirror.com`
- 使用说明页：`/Users/heleyang/Code/MyWiki/wiki/qmdw.md`

因此在当前仓库中调用 `qmd` 时，优先使用这两个环境变量，避免把本地索引写到用户目录。
如果是人工在仓库里直接使用，优先调用 `./qmdw`，不要手写环境变量。
第一次运行 `./qmdw embed` 时会下载 embedding 模型。

建议顺序：

1. 先用 `qmd query` 做混合检索
2. 需要精确关键词时改用 `qmd search`
3. 锁定文件后用 `qmd get` 或 `qmd multi-get`
4. `qmd` 不可用或未初始化时，再退回 `rg` / `find`

## 页面约定

- 优先使用 Obsidian 友好的 Markdown
- frontmatter 尽量保持统一
- 使用目录组织，而不是根目录平铺
- 避免创建只起跳转作用的重复页
- 保持标题、目录页、文件树、canvas 结构一致

## 当前仓库中的特殊约定

- `wiki/index.md` 是总入口页
- `wiki/log.md` 是维护时间线
- `wiki/map.canvas` 是知识地图
- `wiki/wiki.base` 是结构化索引
- `wiki/llm/LLM.md`、`wiki/backend/后端.md` 等目录页负责主题导航

## 完成标准

一次维护任务完成前，应尽量确认：

- 相关页面已写入或更新
- 索引与导航已同步
- 日志已追加
- 结构化视图没有留下坏路径
- 主要文件 frontmatter 和链接仍可解析
