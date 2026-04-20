---
title: OpenHarness：开源智能体基础设施深入解析
source: https://www.notion.so/33910c9390f181359664f406715cbdb8
source_type: notion
note_type: reference
area: llm
topic: agent
collection: Agent
parent_note: '[[wiki/llm/Agent/Agent]]'
status: seed
migrated_on: '2026-04-20'
tags:
- area/llm
- type/reference
- topic/agent
- collection/Agent
---

> [!note]
> 📌 来源：AI 原力注入 · GrissomFI | 发布时间：2026-04-05 | GitHub: github.com/HKUDS/OpenHarness

## 一、为什么需要智能体基础设施？

大型语言模型（LLM）虽在推理与生成能力上有突破，但受限于静态上下文窗口，无法直接与现实世界交互。智能体基础设施（Agent Harness）通过为模型配备工具、记忆、安全边界等，将其转化为能自主执行复杂任务的工程化智能体。

### 现状问题

- 学术界与工业界缺乏统一的基础设施标准
- 研究者需从零构建工具路由、权限管控等
- 工程门槛高，重复造轮子严重

### OpenHarness 定位：轻量级、高度可扩展的开源智能体基础设施

> [!note]
> 🧮 智能体能力等式：Harness = Tools + Knowledge + Observation + Action + Permissions

#### 🔧 Tools（工具）— 模型与外部世界交互的「手」

43+ 核心工具，包括文件读写（Read/Write/Edit/Glob）、终端执行（Bash）、代码操作（Search/Replace）等。所有工具继承 BaseTool 抽象类，使用 Pydantic 模型验证输入，自动生成 JSON Schema。

#### 📚 Knowledge（知识）— 领域特定的记忆与常识

通过 Skills 技术树和 MEMORY.md 持久化实现，支持领域知识注入和跨会话记忆保持。

#### 👁️ Observation（观察）— 工具执行结果反馈环境状态

每次工具执行后返回 ToolResult，让模型感知环境变化。

#### ⚡ Action（行动）— 实际改变物理世界

修改文件、执行脚本、创建资源——从感知到执行的闭环。

#### 🛡️ Permissions（权限）— 安全沙盒机制

三级拦截：工具黑名单 → 路径规则匹配 → 高危操作人工确认，收敛模型幻觉风险。

## 二、快速入门：从一行命令到全自动修 Bug

### 环境要求与安装

Python 3.10+，使用 uv 管理依赖

```bash
git clone https://github.com/HKUDS/OpenHarness.git
cd OpenHarness
uv sync --extra dev
```

### 配置模型 API（以 Kimi 为例）

```bash
export ANTHROPIC_BASE_URL=https://api.moonshot.cn/anthropic
export ANTHROPIC_API_KEY=YOUR_KIMI_API_KEY
export ANTHROPIC_MODEL=kimi-k2.5
```

### 运行示例：一键重构代码库

```bash
uv run oh -p "Inspect this repository and list the top 3 refactors"
```

智能体自动调用 Glob 扫描文件树，使用 Read 工具读取源码，输出结构化重构建议（如：合并重复的 QueryContext 构造、提取权限检查逻辑等）。

## 三、架构说明

### 核心执行流

用户输入 → CLI/终端 UI → QueryEngine → 模型适配器 → Tool Registry → 权限拦截 → 工具执行 → 结果反馈

### 子系统模块划分

#### 引擎与调度层

- engine/ — 主链路驱动，负责 Agent Loop 的完整执行流程
- coordinator/ — 多智能体调度，支持 Agent 间协同工作
- tasks/ — 后台任务管理，异步任务队列

#### 动作与知识层

- tools/ — 43+ 原子工具（文件/终端/代码操作等）
- skills/ — 领域知识库（Skills 技术树）
- memory/ — 持久化记忆系统（MEMORY.md）

#### 安全与扩展层

- permissions/ — 权限拦截（三级安全检查）
- hooks/ — 生命周期钩子（工具执行前后可插拔逻辑）
- plugins/ — 插件系统（扩展核心能力）

#### 接口与协议层

- api/ — 模型适配器（支持 Anthropic/OpenAI 等多模型）
- mcp/ — 模型上下文协议客户端（MCP 协议支持）

## 四、核心功能解析

### 4.1 并发工具引擎（query.py）

支持单工具顺序执行与多工具并发执行（asyncio.gather），降低 I/O 阻塞，提升 Agent 执行效率。

```python
# 并发执行逻辑（位于 query.py）
if len(tool_calls) == 1:
    # 单工具顺序执行
    result = await _execute_tool_call(context, tc.name, tc.id, tc.input)
else:
    # 多工具并发执行
    results = await asyncio.gather(
        *[_execute_tool_call(context, tc.name, tc.id, tc.input) for tc in tool_calls]
    )
```

### 4.2 工具抽象与注册

所有工具继承 BaseTool 抽象类，使用 Pydantic 模型验证输入，自动生成 JSON Schema。开发者可通过定义 input_model 和 execute 方法快速扩展工具。

```python
class BaseTool(ABC):
    name: str
    description: str
    input_model: type[BaseModel]
    
    async def execute(self, arguments: BaseModel,
                     context: ToolExecutionContext) -> ToolResult:
        pass
    
    def to_api_schema(self) -> dict[str, Any]:
        return {
            "name": self.name,
            "description": self.description,
            "input_schema": self.input_model.model_json_schema(),
        }
```

### 4.3 细粒度权限管控（checker.py）

三级拦截机制确保模型幻觉或恶意指令不会执行危险操作（如 rm -rf）：

1. 工具黑名单 — 直接拒绝已禁止的工具
2. 路径规则（glob 匹配）— 按文件路径模式控制访问范围
3. 只读放行 + 高危确认 — 读操作自动通过，写操作需人工审批

```python
# 权限检查逻辑（位于 checker.py）
def evaluate(self, tool_name: str, *, is_read_only: bool,
             file_path: str | None = None,
             command: str | None = None) -> PermissionDecision:
    # 第一级：工具黑名单
    if tool_name in self._settings.denied_tools:
        return PermissionDecision(allowed=False,
            reason=f"{tool_name} is explicitly denied")
    
    # 第二级：路径规则匹配
    if file_path and self._path_rules:
        for rule in self._path_rules:
            if fnmatch.fnmatch(file_path, rule.pattern) and not rule.allow:
                return PermissionDecision(allowed=False,
                    reason=f"Path {file_path} matches deny rule")
    
    # 第三级：只读放行，写操作需确认
    if is_read_only:
        return PermissionDecision(allowed=True,
            reason="read-only tools are allowed")
    
    return PermissionDecision(allowed=False, requires_confirmation=True,
        reason="Mutating tools require user confirmation")
```

## 五、核心流程：Agent Loop

1. 输入解析 — 用户指令 + 系统提示词（如 CLAUDE.md）拼接
2. 模型推理 — 发送至 LLM，生成工具调用意图
3. 安全拦截 — 权限校验 + 人工审批（高危操作）
4. 工具执行 — 路由至 Tool Registry，执行后返回 ToolResult
5. 循环直至完成 — 模型根据反馈继续调用工具或输出总结

## 六、总结与定位

> [!note]
> 🎯 OpenHarness 通过模块化设计（工具、安全、记忆、协同）为大模型提供「手眼」，降低智能体研发门槛。既是开发者的提效工具，也是学术/企业级可定制沙盒。愿景：成为探索 AI 应用生态的开源基石。

### 核心亮点总结

- 智能体能力等式：Harness = Tools + Knowledge + Observation + Action + Permissions
- 43+ 原子工具，并发执行引擎（asyncio.gather）
- 三级权限拦截：黑名单 → 路径规则 → 高危确认
- 模块化架构：引擎层 / 动作层 / 安全层 / 协议层
- 支持多模型适配 + MCP 协议 + 插件扩展

### 延伸阅读与资源

- GitHub: github.com/HKUDS/OpenHarness

OpenClaw vs Claude Code vs Mem0 技术对比
