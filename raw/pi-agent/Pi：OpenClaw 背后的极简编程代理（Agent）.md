---
title: "Pi：OpenClaw 背后的极简编程代理（Agent）"
source: "https://zhuanlan.zhihu.com/p/2028119712471561823"
author:
  - "[[电话微波炉]]"
published:
created: 2026-04-20
description: "Pi：OpenClaw 背后的极简编程代理（Agent） Pi: The Minimal Agent Within OpenClaw | Armin Ronacher's Thoughts and Writings背景与起源OpenClaw 是一个近期在互联网上爆火的项目（曾用名 ClawdBot、MoltBot…"
tags:
  - "clippings"
---
[Pi: The Minimal Agent Within OpenClaw | Armin Ronacher's Thoughts and Writings](https://link.zhihu.com/?target=https%3A//lucumr.pocoo.org/2026/1/31/pi/)

### 背景与起源

- **OpenClaw** 是一个近期在互联网上爆火的项目（曾用名 ClawdBot、MoltBot），本质是一个连接到用户选择的通信渠道（如聊天工具）上的 **代理（Agent）** ，核心能力就是 **运行代码**
- OpenClaw 的底层引擎是一个名为 **Pi** 的小型编程代理，由 **[Mario Zechner](https://zhida.zhihu.com/search?content_id=273216510&content_type=Article&match_order=1&q=Mario+Zechner&zhida_source=entity)** 编写
- 尽管 OpenClaw 的创建者 Peter 追求”带点疯狂的科幻感”，Mario 则非常务实，但两者共享同一核心理念： **[LLM](https://zhida.zhihu.com/search?content_id=273216510&content_type=Article&match_order=1&q=LLM&zhida_source=entity) 非常擅长编写和运行代码，所以应该拥抱这一点**

---

### Pi 的核心特点

### 1\. 极小的内核（Tiny Core）

- Pi 拥有作者所知的 **所有代理中最短的系统提示词（ [System Prompt](https://zhida.zhihu.com/search?content_id=273216510&content_type=Article&match_order=1&q=System+Prompt&zhida_source=entity) ）**
- 只有 **四个工具（Tools）** ：
- **Read** ：读取文件
	- **Write** ：写入文件
	- **Edit** ：编辑文件
	- **Bash** ：执行命令行命令
- 这种极简设计意味着核心逻辑极度精简，不堆砌功能

### 2\. 强大的扩展系统（Extension System）

- 通过 **扩展（Extension）** 弥补核心的极简
- 扩展可以 **将状态持久化到会话（Session）中** ，这一点非常强大
- 扩展支持 **热重载（ [Hot Reloading](https://zhida.zhihu.com/search?content_id=273216510&content_type=Article&match_order=1&q=Hot+Reloading&zhida_source=entity) ）** ：代理可以写代码、重新加载、测试，循环迭代直到扩展正常运行

### 3\. 高质量的软件工程

- 不闪烁、不高内存占用、不随机崩溃
- 非常 **稳定可靠** ，作者对代码质量有极高要求
- Pi 本身是一系列 **可组合的小组件** ，可以在此基础上构建自定义代理（OpenClaw、Telegram Bot、Mom 等都是这样构建的）

---

### Pi 刻意不包含的东西

### 不支持 MCP（Model Context Protocol）

- 这 **不是偶然的遗漏，而是设计哲学的体现**
- Pi 的核心理念：如果你想让代理做某件它还不会做的事情， **不是去下载扩展或技能，而是让代理自己扩展自己**
- 这是在 **庆祝”代码编写代码”这个理念**
- 如果确实需要 MCP，可以使用 **[mcporter](https://zhida.zhihu.com/search?content_id=273216510&content_type=Article&match_order=1&q=mcporter&zhida_source=entity)** 这类工具将 MCP 调用暴露为 CLI 接口或 TypeScript 绑定，间接使用

### 自我扩展优先于下载他人扩展

- 虽然下载扩展是支持的，但更鼓励的方式是： **把代理指向一个已有扩展，告诉它”参考这个来构建，但按我的需求修改”**
- 这让软件变得像 **黏土（Clay）一样可塑** ——这也是 OpenClaw 名字中 “Claw” 的隐含意味

---

### 架构设计：为”代理构建代理”而生

### AI SDK 层面的设计

- Pi 的底层 AI SDK 设计使得 **一个会话可以包含来自多个不同模型提供商的消息**
- 认识到 **会话在不同模型提供商之间的可移植性有限** ，因此不深度依赖任何特定提供商的专有特性
- 避免锁定（Vendor Lock-in）

### 自定义消息与状态持久化

- 除了模型消息外，会话文件中还维护 **自定义消息（Custom Messages）**
- 这些消息可以被扩展用来 **存储状态** ，或者被系统用来维护信息（这些信息可能 **完全不发送给 AI** ，或只发送部分）

### 会话是树结构（Session Trees）

- **会话在 Pi 中是树状结构** ，可以 **分支（Branch）和导航（Navigate）**
- 实际应用场景：
- 在主会话中遇到工具故障 → 创建一个 **分支去修复工具** → 修复完成后 **回退到主会话的早期节点**
	- Pi 会 **自动总结分支上发生的事情** ，不浪费主会话的上下文
- 这解决了一个关键问题：大多数模型提供商的 MCP 工具需要在 **会话启动时加载到系统上下文或工具区段** ，这使得 **完全重载工具的能力变得极其困难** ——要么丢弃整个缓存，要么让 AI 对先前调用的行为产生混淆

---

### 工具可以在上下文之外运行

- 扩展可以注册工具让 LLM 调用，但作者 **非常克制** 地使用这一能力
- 作者目前唯一额外加载到上下文中的工具是一个 **本地任务追踪器（To-do List）** ——由代理自己构建的
- 大部分添加的内容是 **技能（Skills）** 或 **[TUI](https://zhida.zhihu.com/search?content_id=273216510&content_type=Article&match_order=1&q=TUI&zhida_source=entity) 扩展** ，让与代理的交互体验更好

### TUI 扩展能力

- Pi 扩展可以在终端中 **渲染自定义 TUI 组件** ：
- 旋转器（Spinners）、进度条（Progress Bars）
	- 交互式文件选择器（File Pickers）
	- 数据表格（Data Tables）、预览面板（Preview Panes）
- Mario 甚至证明了可以 **在 Pi 的 TUI 中运行 Doom** ——虽然不实用，但说明了灵活性足以构建任何仪表盘或调试界面

---

### 实用扩展示例

### /answer —— 智能问答格式化

- 作者 **不使用 Plan Mode** ，而是鼓励代理提问并进行 **有成效的来回对话**
- 问题：在对话中内联回答问题会变得 **杂乱**
- `/answer` 扩展会读取代理的最后一条回复， **提取所有问题** ，重新格式化为 **美观的输入框**

### /todos —— 代理可用的待办列表

- 虽然作者批评 Beads 的实现方式，但认为 **给代理一个待办列表确实有用**
- `/todos` 命令显示存储在 `.pi/todos` 中的所有 Markdown 文件
- **代理和用户都可以操作** 这些待办事项
- 会话可以 **认领任务** 并标记为进行中

### /review —— 代码审查

- 核心理念：越来越多的代码由代理编写， **在交给人类之前应先让代理自己审查**
- 利用 Pi 的 **会话树结构** ：分支到一个干净的审查上下文 → 获得发现 → 将修复带回主会话
- UI 模仿 Codex 风格，支持审查 **提交、差异、未提交的更改、远程 PR**
- 提示词关注作者在意的点（例如： **标注新添加的依赖项** ）

### /control —— 多代理通信

- 实验性扩展：让一个 Pi 代理 **向另一个 Pi 代理发送提示**
- 一个 **简单的多代理系统** ，没有复杂的编排，适合实验

### /files —— 会话文件管理

- 列出会话中 **所有被更改或引用的文件**
- 支持：在 Finder 中显示、在 VS Code 中 diff、快速预览、在提示中引用
- `Shift+Ctrl+R` 快速预览最近提到的文件（当代理生成 PDF 时特别有用）

### 社区扩展

- **Nico 的 subagent 扩展** ：子代理系统
- **interactive-shell** ：让 Pi 自主运行交互式 CLI，在可观察的 TUI 覆盖层中显示

---

### 软件构建软件（Software Building Software）

### 自维护的技能体系

- 作者的所有扩展 **都不是自己手写的，而是由代理按照规格构建的**
- 没有 MCP、没有社区技能下载——全部由 **“自己的代理”量身定制**
- 示例：
- 用一个 **直接使用 CDP（Chrome DevTools Protocol）的技能** 完全替代了所有浏览器自动化 CLI 和 MCP
	- 不是因为替代品不好，而是因为这种方式 **更自然、更轻便**
	- 代理 **自己维护自己的功能**

### 技能管理理念

- 作者拥有 **大量技能** ，但关键是 **不需要时就丢弃**
- 具体技能举例：
- 读取其他工程师分享的 Pi 会话（辅助代码审查）
	- 制定提交消息格式和提交行为、更新 Changelog
	- 引导代理使用 `uv` 而非 `pip` ，并拦截 `pip` / `python` 调用重定向到 `uv`
- 部分原来是斜杠命令的功能正在 **迁移为技能** ，测试是否同样有效

### 核心启示

- 与极简代理共事的魅力在于： **让你切身体验”使用软件来构建更多软件”这个理念**
- 把这个理念推到极致： **去掉 UI 和输出，直接连接到聊天工具** ——这就是 OpenClaw 所做的事情
- 鉴于 OpenClaw 的爆炸式增长，作者认为 **这将在某种程度上成为我们的未来**

---

### 总结：Pi 的设计哲学

| 维度 | 设计选择 |
| --- | --- |
| 内核 | 极简——4 个工具 + 最短系统提示词 |
| 扩展性 | 代理自我扩展，而非下载外部插件 |
| 会话模型 | 树状结构，支持分支、回退、跨分支总结 |
| 多模型支持 | 会话可包含多提供商消息，不锁定特定平台 |
| 状态管理 | 扩展可持久化状态到会话，支持热重载 |
| MCP | 刻意不内置，通过代码能力间接实现 |
| TUI | 终端内可渲染丰富的自定义组件 |
| 核心理念 | 代码写代码，软件构建软件，代理扩展代理 |

还没有人送礼物，鼓励一下作者吧

发布于 2026-04-16 14:37・浙江