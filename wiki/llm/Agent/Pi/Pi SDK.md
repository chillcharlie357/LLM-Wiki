---
title: Pi SDK
summary: "Pi SDK 通过 `@mariozechner/pi-coding-agent` 暴露 `createAgentSession()`、ResourceLoader、SessionManager、ModelRegistry、工具和扩展机制，让开发者把 Pi 嵌入自己的 CLI、Web UI、Slack/Telegram bot 或 OpenClaw 式 agent 平台。"
source: https://github.com/badlogic/pi-mono/blob/main/packages/coding-agent/docs/sdk.md
source_type: github
note_type: reference
area: llm
topic: agent-sdk
collection: Agent
parent_note: '[[wiki/llm/Agent/Pi/Pi]]'
status: active
migrated_on: '2026-04-23'
tags:
- area/llm
- type/reference
- topic/agent
- topic/sdk
- collection/Agent
aliases:
- Pi Agent SDK
- pi-coding-agent SDK
- createAgentSession
related_sources:
- https://github.com/badlogic/pi-mono/blob/main/packages/coding-agent/examples/sdk/README.md
- https://github.com/badlogic/pi-mono/blob/main/packages/coding-agent/docs/extensions.md
- https://github.com/badlogic/pi-mono/blob/main/packages/coding-agent/docs/packages.md
---

# Pi SDK

Pi SDK 的核心价值是：不把 Pi 当成外部 CLI，而是在自己的 Node.js 进程里创建、控制和订阅一个 agent session。这样可以自己接管模型、工具、安全策略、session 持久化、UI/channel 输出和扩展加载。

## 适用场景

- 自定义 coding agent CLI。
- Web / Desktop / Mobile agent UI。
- Slack、Telegram、Discord、WhatsApp bot。
- CI / 自动化流水线里的 agent reasoning。
- 内部开发平台，把 Pi 作为 agent runtime substrate。
- OpenClaw 式多渠道 agent 平台。

如果你只是想从其他语言调用 Pi，RPC 模式更简单；如果你在 Node.js / TypeScript 中开发，并且需要类型、状态和工具控制，SDK 更合适。

## 包分层

| 包 | 作用 | 你什么时候会碰到 |
| --- | --- | --- |
| `@mariozechner/pi-ai` | 多 provider 模型抽象、模型选择、streaming IO | 选模型、接 OpenAI / Anthropic / Google 等 provider |
| `@mariozechner/pi-agent-core` | agent loop、消息类型、工具执行、状态抽象 | 写底层 tool / 处理 agent message 时 |
| `@mariozechner/pi-coding-agent` | 高层 SDK、session、resource loading、内置工具、settings、auth | 大多数 SDK 集成的主入口 |
| `@mariozechner/pi-tui` | TUI 组件 | 做终端交互界面或 extension UI |
| `@mariozechner/pi-web-ui` | Web chat UI 组件 | 做浏览器端 agent UI |
| `@mariozechner/pi-mom` | Slack bot 集成 | 做聊天平台委托 |
| `@mariozechner/pi-pods` | vLLM pods 管理 | 管理模型部署 |

## 核心 API

| API | 角色 |
| --- | --- |
| `createAgentSession()` | 创建单个 `AgentSession`，适合最小嵌入、自定义工具和单 session 控制 |
| `AgentSession` | 执行 `prompt()`、订阅事件、控制模型、读取消息、abort、compact、树导航 |
| `createAgentSessionRuntime()` | 管理可替换的活动 session，支持 new / switch / fork / import 等运行时操作 |
| `DefaultResourceLoader` | 发现和加载 extensions、skills、prompts、themes、context files |
| `AuthStorage` | 管理 API key / OAuth / runtime API key |
| `ModelRegistry` | 查找 built-in / custom model，筛选可用模型 |
| `SessionManager` | 管理 session 文件、树状历史和持久化 |
| `SettingsManager` | 合并 global/project settings，支持运行时 override |
| `defineTool()` | 定义独立 custom tool |
| `codingTools` | 默认 `read / bash / edit / write` |
| `readOnlyTools` | 只读 `read / grep / find / ls`，更适合安全分析场景 |

## 最小集成

```ts
import {
  AuthStorage,
  createAgentSession,
  ModelRegistry,
  SessionManager,
} from "@mariozechner/pi-coding-agent";

const authStorage = AuthStorage.create();
const modelRegistry = ModelRegistry.create(authStorage);

const { session } = await createAgentSession({
  authStorage,
  modelRegistry,
  sessionManager: SessionManager.inMemory(),
});

const unsubscribe = session.subscribe((event) => {
  if (
    event.type === "message_update" &&
    event.assistantMessageEvent.type === "text_delta"
  ) {
    process.stdout.write(event.assistantMessageEvent.delta);
  }
});

try {
  await session.prompt("Summarize the current repository.");
} finally {
  unsubscribe();
  session.dispose();
}
```

这个模式适合验证 SDK 可用性，但不适合生产直接暴露，因为默认工具可能包含写文件和执行命令能力。

## 安全的只读模式

```ts
import {
  createAgentSession,
  readOnlyTools,
  SessionManager,
} from "@mariozechner/pi-coding-agent";

const { session } = await createAgentSession({
  cwd: "/repo",
  tools: readOnlyTools,
  sessionManager: SessionManager.inMemory(),
});

await session.prompt("Find the main extension points in this codebase.");
```

做 SDK 集成时建议先从 `readOnlyTools` 开始，确认模型、事件、输出、session 管理都稳定后，再逐步打开 `bash` / `edit` / `write`。

## 模型与 thinking level

```ts
import { getModel } from "@mariozechner/pi-ai";
import {
  AuthStorage,
  createAgentSession,
  ModelRegistry,
} from "@mariozechner/pi-coding-agent";

const authStorage = AuthStorage.create();
const modelRegistry = ModelRegistry.create(authStorage);
const model = getModel("anthropic", "claude-opus-4-5");

if (!model) throw new Error("model not found");

const { session } = await createAgentSession({
  authStorage,
  modelRegistry,
  model,
  thinkingLevel: "high",
});
```

如果不指定模型，Pi 会尝试从 session、settings 或可用模型中恢复/选择。生产系统更应该显式传入模型和 auth profile，避免不同运行环境表现不一致。

## 自定义工具

```ts
import { Type } from "@sinclair/typebox";
import { createAgentSession, defineTool } from "@mariozechner/pi-coding-agent";

const ticketLookup = defineTool({
  name: "ticket_lookup",
  label: "Ticket Lookup",
  description: "Look up an internal ticket by id.",
  parameters: Type.Object({
    id: Type.String({ description: "Ticket id, for example ENG-123" }),
  }),
  execute: async (_toolCallId, params) => {
    const ticket = await lookupTicket(params.id);
    return {
      content: [{ type: "text", text: JSON.stringify(ticket, null, 2) }],
      details: { id: params.id },
    };
  },
});

const { session } = await createAgentSession({
  customTools: [ticketLookup],
});
```

工具设计建议：

- tool name 稳定，不要频繁改名。
- 参数 schema 写窄，避免让模型传任意 JSON。
- 返回内容给模型时做摘要，详细结构放在 `details`。
- 所有外部副作用都要有 policy、权限或 dry-run。
- 支持 `AbortSignal`，否则长任务会拖垮宿主。

## ResourceLoader

`DefaultResourceLoader` 是 SDK 集成最重要的对象之一。它负责加载：

- extensions
- skills
- prompt templates / slash commands
- themes
- `AGENTS.md` / context files
- system prompt override

```ts
import {
  createAgentSession,
  DefaultResourceLoader,
} from "@mariozechner/pi-coding-agent";

const resourceLoader = new DefaultResourceLoader({
  cwd: "/repo",
  agentDir: "/service/pi-agent",
  systemPromptOverride: () => `
You are an internal engineering agent.
Use tools conservatively.
Never write outside the workspace.
`,
  additionalExtensionPaths: [
    "/service/pi-extensions/audit.ts",
  ],
});

await resourceLoader.reload();

const { session } = await createAgentSession({
  cwd: "/repo",
  agentDir: "/service/pi-agent",
  resourceLoader,
});
```

默认 discovery 规则里，`cwd` 影响项目级 `.pi/extensions/`、`.pi/skills/`、`.pi/prompts/`、上级目录中的 `.agents/skills/` 和 `AGENTS.md`；`agentDir` 影响全局 extensions、skills、prompts、settings、models、auth 和 sessions。

## Skills / Prompts / Context Files

SDK 可以直接覆盖或追加资源，不一定非要落盘。

```ts
import {
  createAgentSession,
  DefaultResourceLoader,
  type PromptTemplate,
  type Skill,
} from "@mariozechner/pi-coding-agent";

const skill: Skill = {
  name: "repo-review",
  description: "Review code with repository-specific standards.",
  filePath: "/virtual/repo-review/SKILL.md",
  baseDir: "/virtual/repo-review",
  source: "runtime",
};

const deployPrompt: PromptTemplate = {
  name: "deploy-check",
  description: "Run release readiness checks.",
  source: "runtime",
  content: "Check tests, changelog, config, migrations, and rollback plan.",
};

const loader = new DefaultResourceLoader({
  skillsOverride: (current) => ({
    skills: [...current.skills, skill],
    diagnostics: current.diagnostics,
  }),
  promptsOverride: (current) => ({
    prompts: [...current.prompts, deployPrompt],
    diagnostics: current.diagnostics,
  }),
  agentsFilesOverride: (current) => ({
    agentsFiles: [
      ...current.agentsFiles,
      { path: "/virtual/AGENTS.md", content: "# Rules\n\n- Be precise." },
    ],
  }),
});
```

这种方式适合 SaaS / 内部平台：每个租户或项目可以动态注入自己的规则、skills 和 slash commands。

## Extensions

Extensions 是 Pi 的“系统级扩展点”。它们可以：

- 注册 tools。
- 订阅 agent / session / tool events。
- 修改 tool result 或消息渲染。
- 做权限 gate。
- 做路径保护。
- 做自定义 compaction。
- 做 file watcher / webhook / CI integration。
- 渲染 TUI 组件。

```ts
import {
  createAgentSession,
  DefaultResourceLoader,
} from "@mariozechner/pi-coding-agent";

const loader = new DefaultResourceLoader({
  extensionFactories: [
    (pi) => {
      pi.on("tool_execution_start", (event) => {
        console.log("tool start", event);
      });
    },
  ],
});

await loader.reload();

const { session } = await createAgentSession({ resourceLoader: loader });
```

如果宿主系统需要和 extension 双向通信，可以创建共享 event bus，并传给 `DefaultResourceLoader`。这比把所有状态塞进 prompt 更干净。

## Session Runtime

`AgentSession` 管一个具体 session。若你的应用要支持新建、切换、fork、导入 session，就应该使用 `createAgentSessionRuntime()`。

关键注意点：

- `runtime.session` 会在 `newSession()` / `switchSession()` / `fork()` 后变化。
- 事件订阅绑定的是旧 session，替换 session 后要重新订阅。
- 如果用了 extensions，新 session 上要重新绑定。
- runtime 创建失败时会抛错，宿主需要决定重试、降级或返回错误。

```ts
import {
  createAgentSessionFromServices,
  createAgentSessionRuntime,
  createAgentSessionServices,
  getAgentDir,
  SessionManager,
  type CreateAgentSessionRuntimeFactory,
} from "@mariozechner/pi-coding-agent";

const factory: CreateAgentSessionRuntimeFactory = async ({
  cwd,
  sessionManager,
  sessionStartEvent,
}) => {
  const services = await createAgentSessionServices({ cwd });
  return {
    ...(await createAgentSessionFromServices({
      services,
      sessionManager,
      sessionStartEvent,
    })),
    services,
    diagnostics: services.diagnostics,
  };
};

const runtime = await createAgentSessionRuntime(factory, {
  cwd: process.cwd(),
  agentDir: getAgentDir(),
  sessionManager: SessionManager.create(process.cwd()),
});

await runtime.fork("entry-id");
```

## OpenClaw 式嵌入骨架

OpenClaw 的核心模式是：Pi 负责 agent loop 和 session，宿主负责业务层 orchestration。

```ts
async function runEmbeddedPi(params: {
  workspaceDir: string;
  agentDir: string;
  prompt: string;
  model: unknown;
  authStorage: unknown;
  modelRegistry: unknown;
  customTools: unknown[];
  onReply: (text: string) => Promise<void>;
}) {
  const settingsManager = SettingsManager.create(
    params.workspaceDir,
    params.agentDir,
  );

  const sessionManager = SessionManager.create(
    params.workspaceDir,
    `${params.agentDir}/sessions`,
  );

  const resourceLoader = new DefaultResourceLoader({
    cwd: params.workspaceDir,
    agentDir: params.agentDir,
    settingsManager,
    additionalExtensionPaths: [
      "/extensions/context-pruning.ts",
      "/extensions/compaction-safeguard.ts",
    ],
  });

  await resourceLoader.reload();

  const { session } = await createAgentSession({
    cwd: params.workspaceDir,
    agentDir: params.agentDir,
    authStorage: params.authStorage,
    modelRegistry: params.modelRegistry,
    model: params.model,
    tools: [],
    customTools: params.customTools,
    sessionManager,
    settingsManager,
    resourceLoader,
  });

  const unsubscribe = session.subscribe(async (event) => {
    if (
      event.type === "message_update" &&
      event.assistantMessageEvent.type === "text_delta"
    ) {
      await params.onReply(event.assistantMessageEvent.delta);
    }
  });

  try {
    await session.prompt(params.prompt);
  } finally {
    unsubscribe();
    session.dispose();
  }
}
```

OpenClaw 还会额外做：

- channel-specific tools：Discord / Telegram / Slack / WhatsApp 动作。
- tool policy：按 profile、provider、agent、group、sandbox 过滤。
- schema normalization：适配不同 provider 的 tool schema 兼容性。
- abort wrapping：让长工具能响应取消。
- system prompt construction：拼装工具、sandbox、messaging、memory、runtime metadata。
- failover：模型失败后切换 provider / model / auth profile。
- streaming chunking：把模型输出切成适合聊天渠道的 block。

## SDK vs RPC

| 方案 | 适合场景 | 优点 | 代价 |
| --- | --- | --- | --- |
| SDK | Node.js / TypeScript 宿主，想直接控制 session 和工具 | 类型安全、直接访问状态、可程序化注入 tools/extensions | 和 Pi 在同一进程，隔离性弱 |
| RPC | 非 Node.js 语言、需要进程隔离、想保持客户端语言无关 | 易跨语言，Pi 可作为子进程 | 协议层更薄，状态和资源控制不如 SDK 直接 |
| CLI | 人工使用或简单脚本 | 最低成本 | 不适合复杂平台集成 |

## 开发路线

### 路线 A：个人增强版 Pi

1. 安装 `@mariozechner/pi-coding-agent`。
2. 用 `createAgentSession()` 跑通最小例子。
3. 加 `.pi/skills/`、`.pi/prompts/`。
4. 写 1-2 个 extension，例如 `/review`、`/todos`、path guard。
5. 打包成 Pi Package。

### 路线 B：内部 coding agent 平台

1. 用 SDK 嵌入，而不是 CLI。
2. 每个 workspace 一个 `SessionManager`。
3. 用 `readOnlyTools` 作为默认工具集。
4. 对写文件、bash、外部 API 做 policy gate。
5. 注入公司级 `AGENTS.md`、项目级 skills、审计 extension。
6. 对接 WebSocket / Slack / 内部 IM。

### 路线 C：OpenClaw 类多渠道 agent

1. 自己实现 gateway 和 channel adapters。
2. Pi session 作为 embedded runtime。
3. 自己实现 tool pipeline、sandbox、schema normalization。
4. 自己管理 auth profile、model fallback、session compaction。
5. 把 channel output 从 Pi event stream 转成消息平台 block。

## 设计原则

- 先用只读工具跑通，再开放写操作。
- 不要把业务系统 API 直接变成无权限 tool。
- Skills 适合规则和知识，Extensions 适合代码级控制，Custom Tools 适合业务动作。
- `ResourceLoader` 是资源注入边界，`SessionManager` 是长期状态边界，`ModelRegistry/AuthStorage` 是模型与凭证边界。
- 如果要做长期运行服务，必须处理 `abort()`、dispose、事件退订、settings flush 和 session 文件损坏。
- Pi Package 权限很高，第三方包要审源码后再安装。

## 相关

- [[wiki/llm/Agent/Pi/Pi|Pi]]
- [[wiki/llm/Agent/Pi/Pi 与 OpenClaw 集成架构|Pi 与 OpenClaw 集成架构]]
- [[wiki/llm/Agent/Agent|Agent]]
