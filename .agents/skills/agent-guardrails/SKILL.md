---
name: agent-guardrails
description: Battle-tested hooks and rules for AI coding agents. Enforcement gates that block bad patterns — not suggestions agents can ignore. Born from real production incidents.
globs:
---

# Agent Guardrails

Hooks and rules that **enforce** quality in AI-assisted development. These aren't suggestions — they're hard gates that block bad patterns before they cause damage.

Every guardrail here was born from a real production incident:
- **TDD Guard**: Code shipped without tests. Feature broke in production. Now edits are blocked until tests exist.
- **Verify Before Done**: Agent claimed "disabled workflow" but only disabled a node. Workflow kept running, burned $10K in API executions. Now agents must show evidence before claiming completion.
- **Typecheck on Edit**: Tests passed but CI failed on type errors. Multiple follow-up commits to fix what should have been caught immediately.
- **Memory Guard**: Agent context file grew past the system's truncation limit. Future sessions lost critical decisions. Now writes are blocked if the file exceeds the limit.

## What's Included

### Hooks (Shell Scripts — Hard Enforcement)

| Hook | Type | What It Does |
|------|------|-------------|
| `tdd-guard` | PreToolUse | BLOCKS edits to source files that lack corresponding test files |
| `typecheck-on-edit` | PostToolUse | Runs `tsc --noEmit` after every TypeScript edit, surfaces errors immediately |
| `memory-guard` | PreToolUse | BLOCKS writes to memory index files that exceed a configurable line limit |

### Skills

| Skill | What It Does |
|-------|-------------|
| `verify-before-done` | Instructs the agent to never claim "done" without verifiable evidence (test output, API response, screenshot) |

### Rules (CLAUDE.md Templates)

| Rule | What It Does |
|------|-------------|
| `evidence-based-completion` | "Never say done without test output or verification" |
| `plan-vs-reality` | "When plan documents conflict with what was actually built, reality wins" |

## Installation

```bash
npx skills add laundromatic/agent-guardrails
```

Or install individual components:
```bash
npx skills add laundromatic/agent-guardrails --skill tdd-guard
npx skills add laundromatic/agent-guardrails --skill verify-before-done
```

## Manual Installation

Copy the hooks you want into your project's `.claude/hooks/` directory and the skills into `.claude/skills/`. See each component's SKILL.md for configuration details.

## Configuration

### TDD Guard

By default, TDD Guard expects test files alongside source files with `.test.ts` / `.test.tsx` extensions. Edit the `TEST_PATTERNS` variable in `hook.sh` to match your project's convention:

```bash
# Default: src/lib/foo.ts → src/lib/foo.test.ts
# Jest style: src/lib/foo.ts → __tests__/foo.test.ts
# Vitest style: src/lib/foo.ts → test/foo.spec.ts
```

### Memory Guard

Default line limit is 150. Change `MAX_LINES` in `hook.sh` to your preference.

## Philosophy

**Enforcement, not advice.** AI agents are helpful but optimistic — they'll say "done" when things aren't done, skip tests when they're in a hurry, and let type errors slide. These guardrails make bad patterns structurally impossible rather than relying on the agent to remember rules.

The hierarchy (from most to least durable):
1. **Automated tests** — catch regressions forever
2. **Pre-commit hooks** — block bad code at commit time
3. **Agent hooks** (this package) — block bad patterns during AI-assisted development
4. **Rules and memory** — guide behavior but require the agent to remember
