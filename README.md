# MyWiki

一个基于 Obsidian 的本地知识库仓库。

这个仓库最初从 Notion 导出内容迁移而来，现在按更适合 Obsidian 的方式维护：

- `raw/` 保存原始资料、导出稿、截图、附件
- `wiki/` 保存整理后的知识页和导航页
- `AGENT.md` 保存维护规则和知识库 schema
- `qmdw` 提供仓库内固定配置的本地检索与 embedding 包装

目标不是“存一堆 Markdown”，而是把资料沉淀成一个可检索、可回溯、可持续整理的本地 wiki。

## 仓库结构

```text
.
├── AGENT.md
├── qmdw
├── raw/
│   ├── assets/
│   └── ...
├── wiki/
│   ├── index.md
│   ├── log.md
│   ├── map.canvas
│   ├── wiki.base
│   └── ...
├── .config/qmd/
└── .cache/qmd/
```

### `raw/`

- 原始导出、文章、截图、PDF、附件
- 作为事实来源和追溯入口
- 尽量不做“整理性改写”，只做必要的图片本地化、附件归档和格式修补

### `wiki/`

- 已整理的知识页
- 目录页、主题页、索引页、地图都在这里
- 优先面向阅读、检索和持续维护

## 主要入口

- 总入口：[wiki/index.md](wiki/index.md)
- 维护日志：[wiki/log.md](wiki/log.md)
- 检索说明：[wiki/qmdw.md](wiki/qmdw.md)
- 维护规则：[AGENT.md](AGENT.md)

## 依赖

建议至少具备以下工具：

- Obsidian
- Obsidian CLI
- `qmd`

当前仓库已经通过 `qmdw` 固定了 `qmd` 的配置和缓存目录，因此日常使用时优先运行 `./qmdw`，不要直接运行裸 `qmd`。

## 快速开始

### 1. 用 Obsidian 打开仓库

把本仓库目录作为 vault 打开即可。

推荐从下面这些页面开始：

- `wiki/index.md`
- `wiki/map.canvas`
- `wiki/wiki.base`

### 2. 检查本地检索状态

```bash
./qmdw status
```

### 3. 检索内容

```bash
./qmdw query "RAG"
./qmdw search "Harness" -c wiki
./qmdw get "qmd://wiki/llm/RAG/Vector Graph RAG.md"
```

### 4. 资料更新后刷新索引

```bash
./qmdw sync
```

`sync` 会顺序执行：

1. `qmd update`
2. `qmd embed`

这样可以一起处理：

- 新增文件入索引
- 已删除文件从索引中移除
- 内容变更后的 orphaned hashes 清理
- 缺失向量补齐

如果 `embed` 遇到 GPU / Metal 初始化失败，`qmdw` 会尝试自动退回 CPU 模式重试。

## 推荐工作流

### 新资料入库

1. 先把原文、附件、截图放进 `raw/`
2. 图片优先下载到 `raw/assets/`
3. 再把稳定结论整理到 `wiki/`
4. 更新 `wiki/index.md`
5. 大更新写入 `wiki/log.md`
6. 最后运行 `./qmdw sync`

### 查询和整理

1. 先查 `wiki/` 里有没有现成结论
2. 需要追源时再回读 `raw/`
3. 如果一次查询产出了长期有用的总结，就把它回写进 `wiki/`

## 当前约定

- 不照搬 Notion 的空父页模型
- 优先用目录结构组织内容
- 页面尽量保留 `source`
- `wiki/` 下的页面应有 `summary` frontmatter
- 结构变动要同步检查 `index.md`、`log.md`、`map.canvas`、`wiki.base`

详细规则见 [AGENT.md](AGENT.md)。

## 说明

- `.config/qmd/` 和 `.cache/qmd/` 是当前仓库的本地 `qmd` 配置与索引目录
- `.obsidian/` 保存当前 vault 的 Obsidian 配置
- 仓库里会同时存在“原始资料层”和“整理后的知识层”，两者职责不同，不建议混用
