# agent-guardrails

Shell-script hooks that block bad AI agent behavior at the tool level. Memory overflow protection, instant type checking, test enforcement, and evidence-based completion.

[![Install with skills CLI](https://img.shields.io/badge/install-npx%20skills%20add-blue)](https://skills.sh)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

```bash
npx skills add laundromatic/agent-guardrails
```

## The Problem

AI coding agents are optimistic. They say "done" without evidence, skip type checks, edit files that have no tests, and let context files grow past system truncation limits. Most skills address this with instructions — but instructions are suggestions the agent can forget or ignore mid-task.

## The Solution

Shell-script hooks with hard exit codes. The agent **cannot proceed** until the condition is met.

## Why These Exist

Every guardrail was created after a real production incident:

| Incident | What Happened | Cost | Guardrail |
|----------|--------------|------|-----------|
| Context overflow | Agent memory file grew past 200-line system truncation limit | Lost critical project decisions across sessions | **Memory Guard** |
| Silent type errors | Tests passed, CI failed on TypeScript errors | Multiple follow-up commits | **Typecheck on Edit** |
| Untested feature | 6-ticket feature shipped without a single test | Production regression | **TDD Guard** |
| False completion | Agent said "disabled workflow" — only disabled a node | $10,000 in wasted API executions | **Verify Before Done** |

## Components

### Memory Guard (`hooks/memory-guard/`)

**PreToolUse hook — BLOCKS writes exceeding line limit**

AI agents maintain context in memory files. These files have system-level truncation limits — content past the limit is silently invisible to future sessions. This hook blocks writes before they cross the safety threshold.

- Configurable line limit (default: 150)
- Configurable file name to protect (default: `MEMORY.md`)
- Forces the agent to refactor: move detail to topic files, keep the index lean

### Typecheck on Edit (`hooks/typecheck-on-edit/`)

**PostToolUse hook — runs tsc after every TypeScript edit**

Catches type errors the moment they're introduced instead of waiting for CI. Shows the first N lines of errors immediately after each edit.

- Configurable error output limit (default: 15 lines)
- Skips test files, config files, type declarations
- Informational — doesn't block, but surfaces errors proactively

### TDD Guard (`hooks/tdd-guard/`)

**PreToolUse hook — BLOCKS edits to files without tests**

A lightweight test-file existence check. If the source file has no corresponding test file, the edit is blocked.

- Configurable source directory, skip patterns, test naming convention
- Skips pages, layouts, CSS, type declarations, UI library primitives

> For full TDD workflow enforcement (red-green-refactor with test reporters for Vitest, Jest, pytest, Go, Rust, etc.), see [nizos/tdd-guard](https://github.com/nizos/tdd-guard) (1.9K stars).

### Verify Before Done (`skills/verify-before-done/`)

**Skill — requires evidence before completion claims**

Instructs the agent to never say "done", "fixed", or "complete" without verifiable evidence. Includes a concrete evidence table mapping change types to required proof.

> For a complementary instructional approach, see [obra/superpowers verification-before-completion](https://github.com/obra/superpowers) (21K installs).

### Rules (`rules/`)

CLAUDE.md templates you can drop into any project:

- **evidence-based-completion.md** — "Never say done without test output or verification"
- **plan-vs-reality.md** — Establishes a document hierarchy for when plan docs conflict with what was actually built. Session notes and code reflect reality; plans reflect intentions.

## How Hooks Work

Claude Code and compatible agents support hooks at specific lifecycle points:

- **PreToolUse**: Runs before the agent uses a tool. **Exit code 2 blocks the action** with an error message.
- **PostToolUse**: Runs after the agent uses a tool. Cannot block, but surfaces information.

Configure in `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "command": ".claude/hooks/tdd-guard/hook.sh"
      },
      {
        "matcher": "Write",
        "command": ".claude/hooks/memory-guard/hook.sh"
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

## Works With

Claude Code, Cursor, Codex, Copilot, Windsurf, Warp, Amp, Cline, Mistral Vibe, and other agents supporting the [skills.sh](https://skills.sh) ecosystem.

## License

Apache License 2.0

## Origin

Extracted from [SceneInBloom](https://sceneinbloom.com), an AI-native commerce platform built over 70+ development sessions with AI coding agents. Each guardrail maps to a specific production incident — not theory, but hard-won operational lessons.
