---
title: OpenClaw vs Claude Code vs Mem0 技术对比
summary: "Claude Code 四层记忆：L1 CLAUDE.md（项目级）/ L2 Auto Memory（跨会话）/ L3 Session（当前会话）/ L4 AutoDream（持续思考）"
source: https://www.notion.so/33b10c9390f1817a89d9f23df8236fa5
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

### 一、核心定位

- Claude Code：Anthropic 官方 CLI 工具，面向开发者，强调工具调用和安全审计
- OpenClaw：开源本地自主 Agent，支持多平台（本地/Cline/Roo Code/Claude Desktop）
- Mem0：面向 AI 应用的记忆层框架，作为基础设施嵌入其他 Agent 系统

### 二、架构设计对比

Claude Code 四层记忆：L1 CLAUDE.md（项目级）/ L2 Auto Memory（跨会话）/ L3 Session（当前会话）/ L4 AutoDream（持续思考）

OpenClaw 本地化自主 Agent：Markdown 配置 + SQLite 存储 + 多渠道支持（命令行/Cline/Roo Code）

Mem0 四层记忆：用户记忆/会话记忆/代理记忆/系统记忆，向量 + 图双存储，LLM 决策整合

### 三、Memory 系统深度对比

Claude Code：轻量级，基于文件系统（L1/L2）+ 会话上下文（L3）+ 持续思考优化（L4）

OpenClaw：偏好、规则、对话历史全存在 SQLite，支持增量学习

Mem0：最复杂，语义向量 + 知识图谱 + LLM 整合，支持自我反思和重要性评分

### 四、Agent 能力对比

- Claude Code：工具调用（Bash/Edit/Read/Glob/Web/Browser）/ 安全沙箱 / MCP 协议支持
- OpenClaw：本地文件访问/代码执行/多 LLM 切换/多平台支持
- Mem0：仅记忆层，不含 Agent 执行能力，需集成外部 Agent 使用

### 五、安全性对比

- Claude Code：安全审计严格，有禁止命令白名单 / 沙箱执行 / MCP server 隔离
- OpenClaw：CVE-2026-25253 本地提权漏洞，本地运行风险需用户自担
- Mem0：开源框架，数据由用户控制，需自行部署

### 六、价格对比

- Claude Code：Claude Code Pro 订阅 $100/月，Max $200/月（含 Claude Max）
- OpenClaw：开源免费，运行成本由 LLM API 费用决定
- Mem0：开源免费，自托管，Mem0 Platform 订阅制

### 七、核心设计哲学

- Claude Code：Developer-first / 安全优先 / 渐进式思考（Preview-Plan-Execute）
- OpenClaw：自主性最大化 / 本地优先 / 多智能体协作
- Mem0：记忆即基础设施 / 可嵌入任何 Agent / 智能遗忘策略

### 八、适用场景

- Claude Code：软件开发 / 代码审查 / 自动化测试 / 安全审计
- OpenClaw：复杂多步骤任务 / 跨平台操作 / 本地敏感数据处理
- Mem0：AI 应用需要持续记忆 / 多用户个性化 / RAG 增强

### 九、参考资料

- Harness Engineering：AI Agent 工程实践指南 [(链接)](https://mp.weixin.qq.com/s/1RkWpmZBT11sXJYtv93NHA)
- Harness Engineering x SDD：AI Agent 工程体系完整解读 [(链接)](https://mp.weixin.qq.com/s/GjZ-tFBVwfJwK11F1lP5TQ)

## Mem0 知识图谱实现详解

### 一、双存储架构（Vector + Graph）

Mem0 采用向量数据库 + 图数据库的双存储架构，两者协同工作：

- 向量存储（Vector DB）：存储对话内容的嵌入向量，用于语义相似性检索。默认支持 Qdrant，可替换为其他向量库。
- 图存储（Graph DB）：存储实体节点和关系边，支持关系推理和关联查询。支持的图数据库包括 Neo4j、Memgraph、Amazon Neptune、Kuzu、Apache AGE 等。

### 二、实体与关系提取流程

图谱构建的核心流程如下：

1. LLM 实体抽取：用户添加记忆时，LLM 自动从文本中提取实体（Person/Organization/Event/Location）和关系
2. 置信度过滤：默认阈值 0.75，低于此值的实体关系不写入图谱
3. 双写存储：向量嵌入写入 Vector DB，节点+边写入 Graph DB
4. 自动演化：随着记忆持续添加，图谱动态扩展，新实体自动与已有实体建立连接

### 三、GraphRAG 检索机制

Mem0 的检索采用 GraphRAG（图增强检索）策略：

1. 第一步 - 语义搜索：通过 Vector DB 做向量相似性匹配，获取候选记忆片段（可选 reranker 重排序）
2. 第二步 - 图查询补充：Graph DB 返回与候选结果相关的实体-关系上下文（存放在 relations 字段中）
3. 第三步 - 结果融合：两类结果合并后返回给 Agent，图查询不改变向量排序，仅做关联增强

### 四、节点与边的类型体系

- 节点类型：Person（人物）、Organization（组织）、Event（事件）、Location（地点）、自定义类型
- 边类型示例：MET（相遇）、ATTENDED（参加）、LOCATED_AT（位于）、OWNS（拥有）、WORKS_AT（就职于）

示例图谱：Alice (Person) --MET--> Bob (Person) --ATTENDED--> GraphConf 2025 (Event) --IN--> San Francisco (Location)

### 五、可配置项与运维

- 自定义提取提示词（Custom Prompt）：指定只提取特定类型的实体（如只提取人物、组织、项目链接）
- 按请求启用/禁用图谱：enable_graph=False 临时关闭图存储读写
- 多智能体隔离：user_id / agent_id / run_id 区分不同智能体的图谱上下文
- 故障降级：图数据库不可用时自动降级为纯向量搜索模式
- 定期清理：长时间未活跃的节点需手动清理（如 Neo4j 中执行 DETACH DELETE）

## 三系统全面对比（除 Memory 外）

### 一、架构设计哲学

Claude Code：云端一体化架构，紧密耦合 Anthropic 模型能力，定位为完整开发者工具（CLI + IDE）

OpenClaw：本地优先 + Gateway 模块化网关，多节点部署，定位为自主 Agent 平台（支持本地/Cline/Roo Code/Claude Desktop）

Mem0：记忆层抽象架构（Memory-as-a-Service），自身不是独立 Agent，需嵌入其他系统使用

### 二、工具链设计与 MCP 支持

- Claude Code：**"工具即能力边界"**
- Fail-closed 安全默认：工具默认不可并行、非只读、需权限确认
- 专用工具优先（FileReadTool/BashTool/WebFetchTool），避免过度依赖 Bash
- MCP 深度集成：mcp__<server>__<tool> 动态加载 + 权限继承 + McpAuthTool OAuth 认证
- OpenClaw：TOOLS.md 声明式注册工具 + Skills 技能插件串联
- 原生终端/文件系统/浏览器等高权限本地工具，扩展性强但依赖本地环境
- 依赖 MCP 作为核心扩展通道，但未深度集成认证流程
- Mem0：无工具调用能力，专注记忆 API 服务

### 三、安全机制对比

- Claude Code：BashTool 8 层安全检查**（核心亮点）**
- 命令解析 -> 白名单 -> 路径限制 -> 网络隔离 -> 进程控制等多重防护
- 禁止编辑未读文件（readFileState 缓存校验）
- SandboxManager 统一资源隔离（FS/Network/Process）
- OpenClaw：高权限本地执行，CVE-2026-25253 本地提权漏洞已公开
- 需用户自行配置沙箱和权限边界，安全性依赖用户配置水平
- Mem0：专注数据安全（加密存储 + API Key 访问控制），不涉及执行环节的安全风险

### 四、多 Agent 协作能力

- Claude Code：三层协作架构**（业界最完善）**
- L1 Subagent：同步/异步轻量子任务
- L2 Team/Swarm：进程内/进程间多 Agent 编队
- L3 Coordinator：纯编排模式，Leader Permission Bridge 权限传递
- 通信机制：文件系统邮箱 / 内存消息队列
- OpenClaw：分布式多节点部署（Gateway + Nodes），通过 MCP 连接跨实例
- Mem0：无多 Agent 架构，专注单 Agent 记忆生命周期管理

### 五、多模态支持

- Claude Code：暂不支持多模态交互（纯文本代码生成与问答）
- OpenClaw：支持有限的多模态输入（屏幕截图、摄像头画面），依赖本地硬件驱动
- Mem0：不支持多媒体记忆，专注文本记忆的存储与检索

### 六、思考模式 Preview-Plan-Execute

- Claude Code：独有的渐进式思考框架**（独家特性）**
- Preview：意图识别 + 工具选择预览
- Plan：任务分解为步骤序列，展示给用户确认
- Execute：逐步执行 + 实时反馈
- OpenClaw / Mem0：无内置渐进式思考框架，直接执行或返回结果

### 七、部署与定价总结

- Claude Code：Pro $100/月，Max $200/月，云端托管零运维，安全性由官方保障
- OpenClaw：开源免费，自部署，运行成本由 LLM API 费用决定，灵活性最高
- Mem0：开源免费自托管，或 Mem0 Platform 订阅制，作为基础设施嵌入任何 AI 应用
