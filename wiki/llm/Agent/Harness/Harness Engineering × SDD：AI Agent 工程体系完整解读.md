---
title: Harness Engineering × SDD：AI Agent 工程体系完整解读
summary: "📌 来源：腾讯云开发者公众号 · 何艺萍 | 两篇文章联合整理 | 2026-04-04"
source: https://www.notion.so/33810c9390f1816cbf90f84e9ecf9c9a
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
> 📌 来源：腾讯云开发者公众号 · 何艺萍 | 两篇文章联合整理 | 2026-04-04

## 一、两篇文章的关系

两篇文章互为补充，构成完整的 Harness Engineering 知识体系：一篇讲「怎么做（How）」，一篇讲「为什么（Why）」。

| 维度 | 文章一：Harness Engineering 指南 | 文章二：Harness 来了，SDD 还有意义吗？ |
| --- | --- | --- |
| 定位 | 方法论总览 + 实践框架 | 哲学思考 + Spec 角色论证 |
| 核心问题 | AI Agent 如何可靠写出正确代码？ | Harness 时代 Spec 驱动开发还有价值吗？ |
| 回答 | 靠验证管道（Trajectory > Prompt） | Harness 越强，Spec 越重要 |

## 二、核心概念：什么是 Harness Engineering？

> [!note]
> 💡 定义（Mitchell Hashimoto）：当 AI Agent 出错时，用工程化手段避免它重复犯错——这就是 Harness。

### 传统工程 vs Harness 工程

| 维度 | 传统软件工程 | Harness Engineering |
| --- | --- | --- |
| 核心产出 | 代码 | Agent 工作环境（Scaffolding） |
| 质量保障 | Code Review / 测试 | 验证管道（Validation Pipeline） |
| 工程纪律重心 | 写好代码 | 设计好环境 |
| 失败处理 | 人来修 | 系统自动纠正 + 环境进化 |
| 关键资产 | 代码库 | Spec 体系 + 反馈回路 |

### 为什么需要 SDD（规范驱动开发）？

> [!note]
> 🔑 核心论点：Harness 是放大器，Spec 是放大的内容。没有 Spec 的 Harness = 没有轨道的高铁。

- Harness 再强，Agent 只能访问显式写入仓库的内容
- Spec 定义了 Agent 的推理地图、语义约束、正确性判据
- Spec 是机器可读的契约，不是给人看的说明书

## 三、Spec 在 Harness 中的三大角色

### 角色 1：地图 — 渐进式披露的导航

Agent 不需要一开始就理解全部上下文。Spec 提供分层导航：AGENTS.md → 具体模块文档 → 实现细节，避免信息过载，让 Agent 按需获取信息。

### 角色 2：语义基础 — 承载跨服务约束

Linter 能检查语法和格式，但无法检查业务语义。示例：「订单取消后必须触发退款」——这是语义约束，只能靠 Spec 表达。Spec 是机器可读的契约。

### 角色 3：正确性判据 — 验证依据

Agent 输出的代码是否正确？参照 Spec 判断。验证管道的 Oracle（标准答案）来自 Spec。没有 Spec 就没有「正确」的定义。

## 四、Harness Engineering 四大核心原则

### 原则 1：Trajectory > Prompt（轨迹优于提示词）

> [!note]
> ❌ 传统方式：优化 Prompt → 期望一次写对

> [!note]
> ✅ Harness 方式：允许试错 → 用管道验证轨迹 → 自动修正

不要追求「完美的 Prompt」，追求能快速发现错误并自动修复的环境。Trajectory（执行轨迹）是比单次输出更重要的信号。

### 原则 2：环境 > 智力（环境设计优先）

> [!note]
> 📢 OpenAI 团队原话：「工程纪律从写好代码转向构建支撑 Agent 工作的环境」

环境包含：结构化文档(docs/)、产品规格(product-specs/)、执行计划(exec-plans/)、设计文档(design-docs/)、AGENTS.md 轻量导航入口、Linter 规则 + 架构测试、可观测性集成（日志/指标/追踪）

### 原则 3：验证管道是核心基础设施

Agent 写代码 → 编译检查 → Lint → 单元测试 → 集成测试 → 架构规则验证 → 部署，每一层都是快速失败的机会。管道越完善，Agent 自我纠错能力越强。

### 原则 4：自进化机制（Self-Evolution）

当 Agent 出错时，系统应该问：「环境缺了什么让这个错误发生？」——补充约束规则、更新 Spec 文档、增加验证步骤、调整信息披露顺序。关键工具：doc-gardening Agent 定期扫描 Spec 与代码的一致性，自动检测漂移（Drift）。

## 五、项目结构参考

```text
project-root/
├── .harness/
│   ├── pipeline.yaml        # 验证管道配置
│   ├── constraints/          # 架构约束规则
│   └── validators/           # 自定义验证器
├── docs/
│   ├── agents/
│   │   ├── AGENTS.md        # 轻量导航入口（不是大杂烩！）
│   │   ├── architecture.md
│   │   └── decisions/
│   ├── product-specs/        # 产品规格
│   └── exec-plans/           # 执行计划
├── src/                      # 源码（Agent 的主要工作区）
├── tests/
│   ├── validation/           # 管道测试
│   └── e2e/                 # 端到端验证
└── design-docs/              # 设计文档
```

> [!note]
> ⚠️ 常见陷阱：AGENTS.md 变成几百行的「百科全书」。应该只放索引和链接，具体内容分文件存放，保持 Agent 关注点的聚焦。

## 六、SDD 的价值论证

### 质疑：「写 Spec 不是拖慢开发吗？」

回答：SDD 降低的是总成本，不是增加前期投入。无 SDD 的项目快速开始但后期爆炸；有 SDD 的项目前期平稳但总体更短。

### SDD 的三个核心收益

1. 降低返工成本 — Agent 第一次就做对的概率大幅提升
2. 知识资产化 — Spec 是团队可继承的知识，不依赖个人记忆
3. 人才转型 — 人类从「写代码的人」变为「设计环境的人」

## 七、实践启示清单

### ✅ 应该做的

| # | 行动 |
| --- | --- |
| 1 | 审查重心放在 Spec 而非代码 — Spec 决定 Agent 产出的上限 |
| 2 | 区分执行约束与语义约束 — 执行约束交给 linter，语义约束写入 Spec |
| 3 | 建立 Spec 漂移检测机制 — 用 doc-gardening Agent 定期扫描 |
| 4 | 以「AI 还缺什么」为导向解决问题 — 出错先补环境 |
| 5 | AGENTS.md 保持轻量 — 只做导航目录，不做内容堆砌 |
| 6 | 构建渐进式信息披露 — 从概览到细节，让 Agent 按需深入 |

### ❌ 应该避免的

| 陷阱 | 后果 |
| --- | --- |
| 把所有约束塞进 AGENTS.md | 信息过载，Agent 忽略重要内容 |
| 只优化 Prompt 不建环境 | 收益递减，无法规模化 |
| Spec 写完就不维护 | 漂移积累，最终误导 Agent |
| 出错就让人类手动修错 | 错误会重复发生，环境永远不进化 |
| 把 SDD 当作文档工程 | Spec 是可执行的契约，不是给人看的说明 |

## 八、一句话总结

> [!note]
> 🎯 Harness Engineering 回答了「如何让 AI Agent 可靠地工作」——答案是构建包含验证管道和自进化机制的系统化工程环境；而 SDD（规范驱动开发）回答了「在这个环境中什么最重要」——答案是高质量、可维护、作为验证依据的 Spec 文档。二者不是替代关系，而是乘法关系：Harness × Spec = AI 工程的生产力上限。

## 九、延伸阅读

1. Mitchell Hashimoto — My AI Adoption Journey (2026.02)
2. OpenAI Engineering Team — Harness Engineering (2026.02)
3. 本总结基于腾讯云开发者公众号两篇文章整合
