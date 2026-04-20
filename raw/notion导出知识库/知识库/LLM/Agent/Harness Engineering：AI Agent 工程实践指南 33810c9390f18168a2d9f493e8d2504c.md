# Harness Engineering：AI Agent 工程实践指南

所有者: workbuddy
创建时间: 2026年4月4日 17:34

# Harness Engineering：AI Agent 工程实践指南

<aside>
📖 来源：阿里云开发者公众号 | 作者：泮圣伟 | https://mp.weixin.qq.com/s/Et3WwNtEXEgxjaQHrQFDyQ

</aside>

---

## 🎯 核心问题

AI Agent 写代码时"看不见"——不知道架构分层约束、不记住会话间的规范约定、没有自动验证机制。

与其教 Agent 怎么做，不如让它自己验证做得对不对。靠代码、linter、测试来保证正确性，而不是依赖 LLM 的"直觉"。

## 📐 四大核心原则

1. 仓库是唯一事实来源 — 架构决策、分层规则、命名规范全部版本化到 Git
2. AGENTS.md 是地图不是手册 — 控制在 ~100 行，做索引指路，详细内容按需加载
3. 约束管边界不管实现 — 用层级编号（Layer 0-4）规范依赖方向
4. 人设计系统，Agent 执行 — 人的价值从\"写正确代码\"转变为\"设计让 Agent 可靠产出的环境\"

## 🏗️ 项目结构

```
my-project/
├── AGENTS.md
├── docs/ (架构文档、开发指南)
├── scripts/ (lint-deps, lint-quality, validate.py)
└── harness/ (tasks, trace, memory)
```

## ✅ 验证管道

```
build → lint-arch → test → verify
(编译→架构合规→测试→端到端验证)
```

<aside>
💡 关键实践：写代码前先问\"能不能做\"，提前预验证！

</aside>

## 🧠 上下文管理：协调者不写代码

- 协调者只规划/委派，不碰代码；子代理干净启动、干完释放
- 模型分级：简单任务用 Haiku（快+便宜），复杂任务用 Opus（深度推理）
- 交叉 Review 用不同模型，减少盲区重叠，总成本可降 60-70%

## 🔄 Harness 自我进化

```
Agent 执行 → 验证失败 → Critic 分析模式 → Refiner 更新规则 → 下一个 Agent 受益

高频成功模式被\"编译\"成确定性脚本，棘轮效应让系统越来越强。
```

## 💎 一句话总结

> 竞争优势不再是 Prompt，而是 Trajectory。
这些积累，换个模型复制不来。
>