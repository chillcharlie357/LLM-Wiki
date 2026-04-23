---
title: qmdw
summary: "qmdw 是当前仓库给 qmd 提供的本地包装脚本，位置在 qmdw。"
note_type: guide
area: wiki
topic: tooling
collection: wiki
status: active
migrated_on: '2026-04-20'
tags:
- area/wiki
- type/guide
- topic/tooling
- collection/wiki
aliases:
- qmd wrapper
- qmd 本地包装脚本
---

# qmdw

`qmdw` 是当前仓库给 `qmd` 提供的本地包装脚本，位置在 [[qmdw]]。

它的目标很简单：**让 `qmd` 在这个仓库里开箱即用**，避免每次手动写环境变量，也避免把索引和配置写到用户目录。

## 为什么需要它

原始 `qmd` 默认会把配置和索引放到用户目录：

- `~/.config/qmd`
- `~/.cache/qmd`

对这个仓库来说，这有两个问题：

1. 仓库级知识库不应该依赖用户目录里的隐式状态
2. 每次手动设置 `XDG_CONFIG_HOME` / `XDG_CACHE_HOME` 很麻烦

因此这里增加了一层很薄的包装：进入仓库后优先运行 `./qmdw`，而不是直接运行 `qmd`。

## 它做了什么

`qmdw` 默认只做 3 件事：

1. 把 `XDG_CONFIG_HOME` 固定到仓库内的 `.config/`
2. 把 `XDG_CACHE_HOME` 固定到仓库内的 `.cache/`
3. 把 `QMD_CONFIG_DIR` 固定到 `.config/qmd`

当前仓库还额外做了一层下载链路兼容：

4. 默认把 `HF_ENDPOINT` 固定到 `https://hf-mirror.com`
5. 同步把 `MODEL_ENDPOINT` 指向同一个镜像地址

此外它还额外提供一个仓库级便捷命令：

6. `./qmdw sync` 会顺序执行一次 `qmd update` 和 `qmd embed`
7. `./qmdw embed` 在 GPU / Metal 初始化失败时，会自动重试一次 CPU 模式

也就是说，在当前仓库里：

- 配置文件在 [[.config/qmd/index.yml]]
- 索引文件在 `/Users/heleyang/Code/MyWiki/.cache/qmd/index.sqlite`
- 模型下载默认走 `https://hf-mirror.com`

## 当前收录范围

现在 `qmdw` 管理的是两个 collection：

- `wiki`：整理后的知识页
- `raw`：原始资料与导出内容

因此它适合两类检索：

- 先在 `wiki/` 里找已经沉淀好的结论
- 需要追源时再在 `raw/` 里找原文

## 常用命令

```bash
./qmdw status
./qmdw sync
./qmdw update
./qmdw embed
./qmdw search 'RAG' -c wiki
./qmdw query 'Pi agent'
./qmdw get 'qmd://wiki/llm/agent/pi/pi.md'
./qmdw ls wiki
```

推荐顺序：

1. 先用 `./qmdw query` 做混合检索
2. 需要精确关键词时用 `./qmdw search`
3. 命中文档后用 `./qmdw get`
4. 想浏览目录时用 `./qmdw ls`

如果是资料新增、页面删除、批量改写或图片本地化之后，要刷新索引和向量，优先直接运行：

```bash
./qmdw sync
```

因为已删除文件和旧内容哈希的清理发生在 `update` 阶段，而缺失向量的补齐发生在 `embed` 阶段。把两步固定成一个命令，比手工记顺序更稳。

如果单独跑 embedding，也建议继续通过：

```bash
./qmdw embed
```

而不是直接 `qmd embed`，因为这里额外做了一层兼容：当 `node-llama-cpp` 的 GPU / Metal 初始化失败时，`qmdw` 会自动使用 `QMD_LLAMA_GPU=off` 退回 CPU 模式重试。

## 和直接运行 qmd 的区别

直接运行 `qmd`：

- 可能读写用户目录下的全局配置
- 可能落到别的 index
- 在当前仓库里不够稳定

运行 `./qmdw`：

- 始终使用当前仓库自己的配置与索引
- 对当前 wiki 的行为更可预测
- 更适合被 agent 和人工重复使用

## 当前限制

`qmdw` 解决的是“仓库内固定配置和索引路径”的问题，不会改变 `qmd` 本身的行为。

目前已知限制：

- 当前仓库已经完成首轮 embedding，状态可用 `./qmdw status` 查看
- 第一次运行 `qmd embed` 时需要下载模型；当前仓库已经通过镜像完成了 embedding 模型的首轮下载
- 当前环境对 `https://huggingface.co` 的连接会超时，因此这里默认改走 `https://hf-mirror.com`
- 当前安装的 `qmd` 版本里，文档提到的 `QMD_EMBED_MODEL` 覆盖行为实测没有生效，不能先假定它已经支持自定义 embedding 模型切换
- 当前这台机器偶发出现金属后端初始化失败；`./qmdw embed` 和 `./qmdw sync` 已增加 CPU 重试逻辑，但速度会明显变慢

所以当前最稳的使用方式仍然是：

- `./qmdw search`
- `./qmdw query`
- `./qmdw get`
- `./qmdw ls`
- `./qmdw sync`

## 相关页面

- [[wiki/index|本地知识库]]
- [[Karpathy LLM Wiki|Karpathy LLM Wiki]]
- [[AGENT]]
