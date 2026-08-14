---
title: OpenCode 代码评审自动化与 GitHub Action 配置
summary: "用 opencode GitHub Action + opencode-go 订阅在私服仓库跑自动 PR 评审与 /oc 评论触发的完整配置：鉴权、凭证、provider env、pull_request 自动 review，以及挂载 code-review skill 让评审走 Standards+Spec 双轴。"
source: https://github.com/chillcharlie357/text2sql
source_type: github
note_type: methodology
area: llm
topic: agent-ci
collection: Agent
parent_note: "[[wiki/llm/Agent/Agent]]"
status: active
migrated_on: '2026-08-13'
tags:
  - area/llm
  - type/methodology
  - topic/agent
  - topic/agent-ci
  - topic/opencode
  - collection/Agent
aliases:
  - opencode CR 配置
  - opencode GitHub Action 自动评审
  - opencode-go provider 配置
---

# OpenCode 代码评审自动化与 GitHub Action 配置

> [!abstract] 核心结论
> 把 opencode 的 GitHub Action 接进一个私服仓库跑「PR 一开就自动评审 + \`/oc\` 评论手动触发」，只需要一份 \`.github/workflows/opencode.yml\`、一个 opencode-go API key secret 和一个 \`code-review\` skill。真正的坑都在配置链路上：鉴权要选 \`use_github_token: true\`、checkout 要 \`persist-credentials: true\`、provider 读取的 env 名是 \`OPENCODE_API_KEY\`（不是 \`OPENCODE_GO_API_KEY\`）、\`pull_request\` 自动 review 不要传 \`prompt:\` 否则会覆盖评论指令。把这些对齐一次，CI 里 \`Model not found\` 和 \`could not read Username\` 这类报错就消失。

## 1. 能力边界：opencode GitHub Action 原生做什么

opencode 在 GitHub 上的入口是 [\`anomalyco/opencode/github\`](https://github.com/anomalyco/opencode/tree/dev/github) 这个 composite action。它是一个**评论驱动**的 agent runner，原生覆盖这两类事件：

| 事件 | 触发条件 | 行为 |
|------|---------|------|
| \`issue_comment\` / \`pull_request_review_comment\`（\`created\`） | comment body 含 \`/oc\` 或 \`/opencode\` | 读 comment body 当 prompt，跑 agent，把回复作为评论发出 |
| \`pull_request\`（\`opened\`/\`synchronize\`/\`reopened\`/\`ready_for_review\`） | 非草稿 | 不传 prompt 时默认 \`Review this pull request\`；勾出 head 分支、跑 agent、发 PR 评论 |

两类事件可以并存。关键：**\`pull_request\` 事件不要设 \`prompt:\` input** —— handler 里 \`getUserPrompt()\` 的 \`if (customPrompt) return …\` 会全局覆盖评论事件的 body，设了 prompt \`/oc fix this\` 就失效。PR 事件让它自动落到默认 \"Review this pull request\"，评论事件仍从 \`/oc <task>\` 取指令。

## 2. 最小可跑 workflow

\`\`\`yaml
name: opencode

on:
  pull_request:
    types: [opened, synchronize, reopened, ready_for_review]
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]

jobs:
  opencode:
    if: |
      (github.event_name == 'pull_request' && github.event.pull_request.draft == false) ||
      contains(github.event.comment.body, '/oc') ||
      contains(github.event.comment.body, '/opencode')
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: write
      pull-requests: write
      issues: write
    steps:
      - name: Checkout repository
        uses: actions/checkout@v6
        with:
          fetch-depth: 1
          persist-credentials: true

      - name: Run opencode
        uses: anomalyco/opencode/github@latest
        env:
          OPENCODE_API_KEY: \${{ secrets.OPENCODE_GO_API_KEY }}
          GITHUB_TOKEN: \${{ secrets.GITHUB_TOKEN }}
        with:
          model: opencode-go/kimi-k3
          use_github_token: true
\`\`\`

要点：

- \`on.pull_request\` 用 \`ready_for_review\` + \`if: draft == false\` 让草稿 PR 不跑，作者标 ready 时才触发第一次 review。
- \`synchronize\` 让每次 push 都重新 review；省额度可去掉，只留 \`opened\`/\`ready_for_review\`。
- 不传 \`prompt:\`（理由见 §1）。

## 3. 配置链路上的四个坑

这四个坑按 \`Run OpenCode\` step 失败位置分别定位：

### 3.1 鉴权：\`use_github_token: true\`

不设这个 input 时默认 \`false\`，action 走 **OIDC + opencode App 换 token** 路径：

\`\`\`ts
// packages/opencode/.../github.handler.ts
const oidcToken = await core.getIDToken('opencode-github-action')
response = await fetch('https://api.opencode.ai/exchange_github_app_token', {
  headers: { Authorization: \`Bearer \${oidcToken}\` },
})
\`\`\`

这条路径需要事先装好 [opencode-agent App](https://github.com/apps/opencode-agent)，且 OIDC 交换响应有时解析不出 token，崩在 \`undefined is not an object (evaluating 'p.rest')\`。私服仓库最省事的做法是直接用 Actions 自动注入的 \`GITHUB_TOKEN\`：

\`\`\`yaml
env:
  GITHUB_TOKEN: \${{ secrets.GITHUB_TOKEN }}
with:
  use_github_token: true
\`\`\`

handler 里对应分支 **跳过** \`configureGit()\`，直接用 \`GITHUB_TOKEN\` 调 API 和提交。这意味着 \`contents/pull-requests/issues\` 都要 \`write\`，否则推分支、开 PR、发评论都会 403。

### 3.2 checkout 凭证：\`persist-credentials: true\`

\`use_github_token: true\` 这条路假设 \`actions/checkout\` 已经把 \`GITHUB_TOKEN\` 写进 git 的 \`http.https://github.com/.extraheader\`，因此 opencode 自己不再写。如果照 opencode README 抄 \`persist-credentials: false\`，checkout 不留凭证，opencode 去 \`git fetch origin <PR head 分支>\`（不在浅克隆里）就会退化成交互式登录，CI 里直接：

\`\`\`
fatal: could not read Username for 'https://github.com': No such device or address
\`\`\`

所以 \`persist-credentials: true\`。担心里面的 token 泄漏可以放心：checkout 的 post step 会清理 extraheader，job 结束就没了。

### 3.3 provider env：\`OPENCODE_API_KEY\` ≠ \`OPENCODE_GO_API_KEY\`

opencode-go 这个 provider 在 [\`models.opencode.ai/api.json\`](https://models.opencode.ai/api.json) 里这么定义：

\`\`\`json
"opencode-go": {
  "id": "opencode-go",
  "env": ["OPENCODE_API_KEY"],
  "npm": "@ai-sdk/openai-compatible",
  "api": "https://opencode.ai/zen/go/v1",
  "models": { "kimi-k3": {...}, "gpt-5.6-luna": {...}, ... }
}
\`\`\`

它读取的 env 名是 **\`OPENCODE_API_KEY\`**。只设 \`OPENCODE_GO_API_KEY\` 时，provider loader 拿不到 key：

\`\`\`ts
// packages/opencode/src/provider/provider.ts, "opencode" branch
const hasKey = input.env.some((item) => env[item])  // ["OPENCODE_API_KEY"]
if (!ok) {
  for (const [k, v] of Object.entries(input.models))
    if (v.cost.input > 0) delete input.models[k]   // 付费模型全删
  options = { apiKey: "public" }
}
\`\`\`

付费模型（kimi-k3、gpt-5.6-luna 都 \${input > 0}）被全部从可用列表里删掉，于是 \`Model not found: opencode-go/kimi-k3. Did you mean: kimi-k3?\` —— 后半句是因为别家 provider 也有同名的 free \`kimi-k3\`，很骗人。修法：

\`\`\`yaml
env:
  OPENCODE_API_KEY: \${{ secrets.OPENCODE_GO_API_KEY }}   # secret 名不动, 只把值喂给 provider 要的 env 名
\`\`\`

> 想让 secret 名和 env 名一致也行，把 GitHub secret 改名 \`OPENCODE_API_KEY\` 直接引用。

### 3.4 不要在 \`pull_request\` 事件里写 \`prompt:\`

见 §1。设了会覆盖 \`/oc\` 评论里的指令。

## 4. opencode-go 订阅与模型

opencode-go 是 opencode 自己的低成本订阅服务（首月 \$5，之后 \$10/月），用一个 API key 通一堆开源模型。走 [\`https://opencode.ai/zen/go/v1\`](https://opencode.ai/docs/go/#api-端点) 端点，模型列表可在 [\`/v1/models\`](https://opencode.ai/zen/go/v1/models) 实时查。

注册表关键信息：

| provider id | env 干啥要 | 付费模型采样 |
|---|---|---|
| \`opencode-go\` | \`OPENCODE_API_KEY\` | kimi-k3, gpt-5.6-luna, glm-5.2, grok-4.5, deepseek-v4-pro, qwen3.8-max … |

用量限制按美元计：**5h / \$12、周 / \$30、月 / \$60**。自动 review 每次 PR 都触发，量上来很快；想省钱可以只留 \`opened\` + \`ready_for_review\`，去掉 \`synchronize\`。

模型 cost 决定单次评审能换多少请求；DeepSeek V4 Flash、MiMo-V2.5 这种便宜模型每次评审花得少，GLM-5.2、Grok 4.5 这种贵的花得多。

## 5. 挂载 code-review skill 让评审走 Standards + Spec 双轴

opencode 原生支持 agent skills，会在 [\`skill\`](https://opencode.ai/docs/skills/) tool description 里列所有可发现 skill。默认允许全部；只要在以下任一路径放 \`SKILL.md\`，agent 就能加载：

- \`.opencode/skills/<name>/SKILL.md\`
- \`.agents/skills/<name>/SKILL.md\`
- \`.claude/skills/<name>/SKILL.md\`
- \`~/.config/opencode/skills/<name>/SKILL.md\` / \`~/.agents/skills/...\` / \`~/.claude/skills/...\`

把 [[#code-review skill 内容|code-review skill]] 放在仓库 \`.agents/skills/code-review/SKILL.md\`，PR 自动 review 时 build agent 有看到 \`description\` 和 \"review this pull request\" 相匹配，就会主动调用。

### 5.1 SKILL.md 的 frontmatter 约束

\`\`\`yaml
---
name: code-review   # 必须匹配目录名, 小写字母+数字+单连字符
description: ...    # 1–1024 字符, 决定 agent 何时加载该 skill
license: MIT        # 可选
compatibility: opencode   # 可选
metadata: { audience: maintainers, workflow: github-pr-review }
---
\`\`\`

\`name\` 的正则：\`^[a-z0-9]+(-[a-z0-9]+)*$\`。不匹配会silent 不加载。

### 5.2 用权限收口

\`\`\`json
// opencode.json
{
  "permission": {
    "skill": {
      "*": "allow",
      "code-review": "allow",
      "internal-*": "ask"
    }
  }
}
\`\`\`

公共仓库给 \`*\` 默认 allow 没问题；内部 skill 走 \`ask\` 让人在评审里手动批。

### 5.3 双轴评审为什么值得

代码可以只过其中一轴：

- 全符合标准但实现错了 → **Standards pass, Spec fail**。
- 完全按 issue 写但坏了项目规约 → **Spec pass, Standards fail**。

分开报能避免一个轴的好结果掩盖另一个。最终输出一个 PR 评论，结构是 \`## Standards\` / \`## Spec\` / 一行 summary，别多开评论刷屏。

## 6. 外部 fork PR 的安全限制

\`assertPermissions()\` 会用 \`repos.getCollaboratorPermissionLevel\` 校验 PR 作者在仓库是否 write/admin。fork PR 作者不在仓库权限里，会被拦下、run fail。所以这套自动 review 仅对仓库成员提交的内部分支 PR 有效。要给外部 fork 贡献者也 review，得：

- 要么自己写一个 GitHub App（见 §7），自己处理 \`installation\` token 和权限豁免；
- 要么用 \`workflow_run\` 事件让维护者手动触发对外 fork PR 的 review。

## 7. 什么时候该升级成自建 GitHub App

opencode-action 不会暴露 GitHub 的 \`approve\`/\`request changes\`，只能发评论。如果想要以下任一点，方案 B 才必要：

1. 真正提交 approve / request_changes，而非只是发评论。
2. 跨多仓库复用一套逻辑、走 App installation token 而不是每仓库各自 \`GITHUB_TOKEN\`。
3. 在给外部 fork PR 自动 review（当前 assertPermissions 会拦）。

实现骨架：

1. GitHub → Settings → Developer settings → New GitHub App，权限 \`pull_requests: write\`、\`contents: read\`，订阅 \`pull_request\` webhook。
2. App 私钥存为 secret，如 \`APP_ID\`、\`APP_PRIVATE_KEY\`。
3. workflow 用 [\`actions/create-github-app-token@v2\`](https://github.com/actions/create-github-app-token) 换出 installation token，代替 \`GITHUB_TOKEN\` 注入给 opencode step。
4. 仍走 opencode go（\`OPENCODE_API_KEY\`）做模型推理，提交 review 走 GitHub API \`POST /repos/{owner}/{repo}/pulls/{pr}/reviews\`。

这一步是**替换「谁触发 + 谁提交 review」**，不替换 opencode 本身；opencode 的 skills / agents / session 还能复用。

## 8. 验收清单

落地一个新仓库时按这个清单走：

- [ ] 仓库 settings → secrets 添加 \`OPENCODE_GO_API_KEY\`（opencode-go 订阅 API key）。
- [ ] 添加 \`.github/workflows/opencode.yml\`（§2 整段）。
- [ ] 确认 \`permissions\` 里有 \`contents/pull-requests/issues: write\` 和 \`id-token: write\`。
- [ ] 确认 \`Checkout\` 的 \`persist-credentials: true\`。
- [ ] 确认 \`OPENCODE_API_KEY\` env 指向 \`secrets.OPENCODE_GO_API_KEY\`。
- [ ] \`with.use_github_token: true\`，\`with.model: opencode-go/<model-id>\`。
- [ ] 不在 \`with:\` 里写 \`prompt:\`（除非确实想覆盖所有事件）。
- [ ] 把 \`.agents/skills/code-review/SKILL.md\` 放进仓库（§5）。
- [ ] 开一个非草稿内部 PR，应自动收到一条 opencode review 评论。
- [ ] 评论 \`/oc 总结 diff\` 应触发一条 agent 回复。
- [ ] 检查一处失败的 run：\`gh run view <run-id> --log-failed\` 看 \`Run opencode\` step 的报错行定位到 §3 的哪个坑。

## 9. 现场参考（text2sql 实跑记录）

整套在 \`chillcharlie357/text2sql\` 上按上面顺序跑通，调试经历：

| PR | 修复对象 | 失败行 → 修复 |
|----|----------|----------------|
| [#24](https://github.com/chillcharlie357/text2sql/pull/24) | 鉴权 | \`Failed to parse JSON / p.rest\` → \`use_github_token: true\` + \`GITHUB_TOKEN\` env，删掉裸 \`pull_request\` 触发器 |
| [#25](https://github.com/chillcharlie357/text2sql/pull/25) | checkout 凭证 | \`could not read Username for 'https://github.com'\` → \`persist-credentials: true\` |
| [#26](https://github.com/chillcharlie357/text2sql/pull/26) | provider env | \`Model not found: opencode-go/kimi-k3\` → \`OPENCODE_API_KEY\` env |
| [#27](https://github.com/chillcharlie357/text2sql/pull/27) | 自动 review | 加回 \`pull_request\` 触发器，\`if: draft == false\`，不设 \`prompt:\` |
| [#29](https://github.com/chillcharlie357/text2sql/pull/29) | skill | \`.agents/skills/code-review/SKILL.md\` 上线 |

PR #28 是验证 PR（仅改 README 一行注释），run 31705100409 在 1 分 20 秒内跑完，自动产出一条结构化 review 评论，确认 §1+§2+§3 整链路通。

## 10. 相关概念

- [[wiki/llm/Agent/Agent|Agent]]：agent 的整体工作流与运行时
- [[wiki/llm/Agent/Agent Skill 设计与质量保障|Agent Skill 设计与质量保障]]：skill 化的通用设计原则，本文 §5 的 code-review skill 即遵循这套原则（渐进披露、路由准确、边界清晰）
- [[wiki/llm/Agent/Agent 业务理解与意图识别]]：从团建角度补充 \"为什么 skill description 要写得能被 agent 路由到\"

## source

- 实跑仓库：https://github.com/chillcharlie357/text2sql
- opencode GitHub action：https://github.com/anomalyco/opencode/tree/dev/github
- opencode-go 配置文档：https://opencode.ai/docs/go/
- opencode skills 文档：https://opencode.ai/docs/skills/