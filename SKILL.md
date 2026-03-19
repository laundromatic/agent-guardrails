---
name: agent-guardrails
description: Shell-script hooks that block bad AI agent behavior at the tool level. Memory overflow protection, instant type checking, test enforcement, and evidence-based completion. Born from real incidents — $10K burned, untested code shipped, context silently lost.
globs:
---

# Agent Guardrails

Shell-script hooks that **block** bad AI agent behavior at the tool level — before damage is done.

AI agents are optimistic. They say "done" without testing, skip type checks, let context files bloat past truncation limits, and edit code that has no tests. Most skills address this with instructions the agent can forget. These guardrails use PreToolUse/PostToolUse hooks with hard exit codes — the agent **cannot proceed** until the condition is met.

Every guardrail was created after a real production incident:

- **Memory Guard**: Agent context file silently grew past the system's 200-line truncation limit. Critical project decisions vanished. Future sessions made wrong choices based on incomplete context.
- **Typecheck on Edit**: Tests passed but CI failed on type errors. Multiple follow-up commits to fix what a single `tsc --noEmit` would have caught instantly.
- **TDD Guard**: A 6-ticket feature shipped without a single test. No one noticed until production broke.
- **Verify Before Done**: Agent claimed "disabled workflow" but only disabled a node. Workflow kept running on schedule, burned $10,000 in API executions over a weekend.

## What's Included

### Hooks (Shell Scripts — Hard Enforcement)

| Hook | Type | What It Does |
|------|------|-------------|
| `memory-guard` | PreToolUse | **BLOCKS** writes to memory/context index files that exceed a configurable line limit. Prevents silent context loss from system truncation. |
| `typecheck-on-edit` | PostToolUse | Runs `tsc --noEmit` after every TypeScript edit. Surfaces type errors the moment they're introduced — not 20 minutes later in CI. |
| `tdd-guard` | PreToolUse | **BLOCKS** edits to source files that lack a corresponding test file. Lightweight check — for full TDD workflow enforcement, see [nizos/tdd-guard](https://github.com/nizos/tdd-guard). |

### Skills

| Skill | What It Does |
|-------|-------------|
| `verify-before-done` | Requires the agent to show verifiable evidence (test output, API response, screenshot) before any completion claim. Complements [obra/superpowers verification-before-completion](https://github.com/obra/superpowers) with concrete evidence tables by change type. |

### Rules (CLAUDE.md Templates)

| Rule | What It Does |
|------|-------------|
| `evidence-based-completion` | "Never say done without test output or verification" |
| `plan-vs-reality` | "When plan documents conflict with what was actually built, reality wins" — a document hierarchy for resolving architectural drift |

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

Copy the hooks you want into `.claude/hooks/` and the skills into `.claude/skills/`. See each component's SKILL.md for setup and configuration.

## Configuration

### Memory Guard
- `MAX_LINES` — line limit before blocking (default: 150)
- `PROTECTED_FILE` — file name to protect (default: `MEMORY.md`)

### Typecheck on Edit
- `MAX_ERROR_LINES` — lines of error output to show (default: 15)
- `TS_CONFIG` — custom tsconfig path (default: project root)

### TDD Guard
- `SRC_DIR` — directory to protect (default: `src`)
- `SKIP_PATTERNS` — files that don't need tests (pages, layouts, CSS, type declarations)
- `SKIP_DIRS` — directories to skip (e.g., UI library primitives)
- `TEST_SUFFIX` — test file convention (default: `.test`)

## Works With

Claude Code, Cursor, Codex, Copilot, Windsurf, Warp, Amp, Cline, Mistral Vibe, and other agents supporting the skills.sh ecosystem.

## See Also

- [nizos/tdd-guard](https://github.com/nizos/tdd-guard) — Full TDD enforcement with test reporters for Vitest, Jest, pytest, PHPUnit, Go, Rust
- [obra/superpowers](https://github.com/obra/superpowers) — Comprehensive skill collection including verification-before-completion and test-driven-development
