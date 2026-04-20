---
title: "badlogic/pi-mono: AI agent toolkit: coding agent CLI, unified LLM API, TUI & web UI libraries, Slack bot, vLLM pods"
source: "https://github.com/badlogic/pi-mono"
author:
published:
created: 2026-04-20
description: "AI agent toolkit: coding agent CLI, unified LLM API, TUI & web UI libraries, Slack bot, vLLM pods - badlogic/pi-mono"
tags:
  - "clippings"
---
[![pi logo](https://camo.githubusercontent.com/8b5a446dcbd5bea234898b8584e5484099dc0a939d8e59e542b7f5f23b259217/68747470733a2f2f736869747479636f64696e676167656e742e61692f6c6f676f2e737667)](https://shittycodingagent.ai/)

[pi.dev](https://pi.dev/) domain graciously donated by  
  
[![Exy mascot](https://github.com/badlogic/pi-mono/raw/main/packages/coding-agent/docs/images/exy.png)  
exe.dev](https://exe.dev/)

> New issues and PRs from new contributors are auto-closed by default. Maintainers review auto-closed issues daily. See [CONTRIBUTING.md](https://github.com/badlogic/pi-mono/blob/main/CONTRIBUTING.md).

---

## Pi Monorepo

> **Looking for the pi coding agent?** See **[packages/coding-agent](https://github.com/badlogic/pi-mono/blob/main/packages/coding-agent)** for installation and usage.

Tools for building AI agents and managing LLM deployments.

If you use pi or other coding agents for open source work, please share your sessions.

Public OSS session data helps improve coding agents with real-world tasks, tool use, failures, and fixes instead of toy benchmarks.

For the full explanation, see [this post on X](https://x.com/badlogicgames/status/2037811643774652911).

To publish sessions, use [`badlogic/pi-share-hf`](https://github.com/badlogic/pi-share-hf). Read its README.md for setup instructions. All you need is a Hugging Face account, the Hugging Face CLI, and `pi-share-hf`.

You can also watch [this video](https://x.com/badlogicgames/status/2041151967695634619), where I show how I publish my `pi-mono` sessions.

I regularly publish my own `pi-mono` work sessions here:

- [badlogicgames/pi-mono on Hugging Face](https://huggingface.co/datasets/badlogicgames/pi-mono)

## Packages

| Package | Description |
| --- | --- |
| **[@mariozechner/pi-ai](https://github.com/badlogic/pi-mono/blob/main/packages/ai)** | Unified multi-provider LLM API (OpenAI, Anthropic, Google, etc.) |
| **[@mariozechner/pi-agent-core](https://github.com/badlogic/pi-mono/blob/main/packages/agent)** | Agent runtime with tool calling and state management |
| **[@mariozechner/pi-coding-agent](https://github.com/badlogic/pi-mono/blob/main/packages/coding-agent)** | Interactive coding agent CLI |
| **[@mariozechner/pi-mom](https://github.com/badlogic/pi-mono/blob/main/packages/mom)** | Slack bot that delegates messages to the pi coding agent |
| **[@mariozechner/pi-tui](https://github.com/badlogic/pi-mono/blob/main/packages/tui)** | Terminal UI library with differential rendering |
| **[@mariozechner/pi-web-ui](https://github.com/badlogic/pi-mono/blob/main/packages/web-ui)** | Web components for AI chat interfaces |
| **[@mariozechner/pi-pods](https://github.com/badlogic/pi-mono/blob/main/packages/pods)** | CLI for managing vLLM deployments on GPU pods |

## Contributing

See [CONTRIBUTING.md](https://github.com/badlogic/pi-mono/blob/main/CONTRIBUTING.md) for contribution guidelines and [AGENTS.md](https://github.com/badlogic/pi-mono/blob/main/AGENTS.md) for project-specific rules (for both humans and agents).

## Development

```
npm install          # Install all dependencies
npm run build        # Build all packages
npm run check        # Lint, format, and type check
./test.sh            # Run tests (skips LLM-dependent tests without API keys)
./pi-test.sh         # Run pi from sources (can be run from any directory)
```

> **Note:** `npm run check` requires `npm run build` to be run first. The web-ui package uses `tsc` which needs compiled `.d.ts` files from dependencies.

## License

MIT