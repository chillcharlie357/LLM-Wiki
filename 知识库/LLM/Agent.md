---
title: Agent
source: https://www.notion.so/33010c9390f18075bb1cdb54509e3e9f
parent: "[[知识库/LLM]]"
---

# Agent

附件：原 Notion 页面包含一个 PDF 附件，当前只保留页面内容与引用。

- [[知识库/Agent面试文档（2026-2-23）]]

# 概念整理（面试经常问）

## Skills, Tools, MCP

Skills 是 Agent 的原子能力单元；Tools 是外部 API/服务封装；MCP 是 Anthropic 制定的资源通信协议，统一 Agent 与数据源的连接标准。

### Skills (技能)

- 原子能力单元，有明确输入输出
- 示例：搜索、计算、代码执行、文件操作
- 被 LLM 发现和调用

### Tools (工具)

- 外部 API/服务的封装
- 示例：天气 API、数据库、浏览器、Discord Bot
- 与 Skills 区别：Tools 偏向外部集成

### MCP (Model Context Protocol)

- Anthropic 制定的 Agent-资源通信协议
- 架构：Host(Claude) ↔ Client ↔ Server(资源)
- 资源类型：文件、数据库、API、Git 仓库等

> 💡 类比：MCP 是 Agent 界的 USB-C 接口，统一资源接入标准

## Agent，LLM

LLM 是大语言模型，负责理解和生成文本；Agent 是由 LLM 驱动的智能系统，具备自主性、工具使用、记忆和规划能力，能执行复杂任务。

### LLM (大语言模型)

- 基于 Transformer 的深度学习模型
- 能力：理解、生成、处理自然语言
- 代表：GPT-4、Claude、Gemini、Qwen

### AI Agent (智能体)

- 由 LLM 驱动的智能系统
- 四大属性：自主性、工具使用、记忆、规划
- 能执行多步骤复杂任务

### 关系

- LLM 是 Agent 的"大脑"，负责决策和推理
- Agent = LLM + 工具 + 记忆 + 规划

> 💡 类比：LLM 是大脑，Agent 是完整的机器人 (大脑 + 手 + 记忆 + 规划能力)

## SPEC 规范编程

# 平常怎么用AI工具的

- [[知识库/Harness Engineering：AI Agent 工程实践指南]]
- [[知识库/Harness Engineering × SDD：AI Agent 工程体系完整解读]]
- [[知识库/OpenHarness：开源智能体基础设施深入解析]]
- [[知识库/OpenClaw vs Claude Code vs Mem0 技术对比]]
