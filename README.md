# agent-guardrails

Battle-tested hooks and rules for AI coding agents. Enforcement gates that block bad patterns — not suggestions agents can ignore.

[![Install with skills CLI](https://img.shields.io/badge/install-npx%20skills%20add-blue)](https://skills.sh)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Why This Exists

Every guardrail in this package was created because something broke in production:

| Incident | Cost | Guardrail Created |
|----------|------|-------------------|
| Feature shipped without any tests | Broke in production, required hotfix | **TDD Guard** — blocks edits to files without tests |
| Agent said "done" but only disabled a workflow node, not the workflow | $10,000 in wasted API executions | **Verify Before Done** — requires evidence before completion claims |
| Tests passed but TypeScript had type errors | Multiple follow-up commits to fix CI | **Typecheck on Edit** — runs tsc after every edit |
| Agent context file grew past truncation limit | Lost critical project decisions | **Memory Guard** — blocks writes exceeding line limit |

## Install

```bash
npx skills add laundromatic/agent-guardrails
```

Works with Claude Code, Cursor, Windsurf, Codex, and 18+ other AI coding agents.

## Components

### Hooks

**TDD Guard** (`hooks/tdd-guard/`) — PreToolUse hook that blocks edits to source files lacking a corresponding test file. Exit code 2 = hard block. Configurable test file patterns. Skips test files, type declarations, CSS, page components, and UI library primitives.

**Typecheck on Edit** (`hooks/typecheck-on-edit/`) — PostToolUse hook that runs `tsc --noEmit` after every TypeScript file edit. Surfaces type errors immediately instead of waiting for CI. Informational (doesn't block).

**Memory Guard** (`hooks/memory-guard/`) — PreToolUse hook that blocks writes to memory index files exceeding a configurable line limit (default: 150). Prevents context loss from file truncation.

### Skills

**Verify Before Done** (`skills/verify-before-done/`) — Instructs the agent to never claim "done", "fixed", or "complete" without verifiable evidence. Requires test output, API response, or screenshot comparison. If verification isn't possible, the agent must say "UNVERIFIED — requires manual confirmation."

### Rules

**Evidence-Based Completion** (`rules/evidence-based-completion.md`) — Rule template for CLAUDE.md that enforces evidence-based completion claims across all work.

**Plan vs Reality** (`rules/plan-vs-reality.md`) — Rule template that establishes a hierarchy when plan documents conflict with what was actually built. Session notes and code reflect reality; plan documents reflect intentions.

## How Hooks Work

Claude Code (and compatible agents) support hooks that run shell scripts at specific points:

- **PreToolUse**: Runs before the agent uses a tool (Edit, Write, etc.). Exit code 2 blocks the action with an error message.
- **PostToolUse**: Runs after the agent uses a tool. Cannot block, but can surface information.

These hooks are configured in `.claude/settings.json` or `.claude/settings.local.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "command": ".claude/hooks/tdd-guard/hook.sh"
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "command": ".claude/hooks/typecheck-on-edit/hook.sh"
      }
    ]
  }
}
```

## Customization

Each hook has configurable variables at the top of `hook.sh`. See the SKILL.md in each hook's directory for details.

## License

Apache License 2.0

## Origin

Extracted from [SceneInBloom](https://sceneinbloom.com), an AI-native commerce platform. These guardrails evolved over 70+ development sessions operating AI agents in production.
