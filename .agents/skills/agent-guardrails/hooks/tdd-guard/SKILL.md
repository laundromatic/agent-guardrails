---
name: tdd-guard
description: PreToolUse hook that blocks edits to source files without corresponding test files. Hard enforcement — exit code 2 blocks the action.
---

# TDD Guard

A PreToolUse hook that **blocks** edits to source files that don't have corresponding test files. The agent cannot proceed until tests exist.

## What It Prevents

A feature ships without tests. It breaks in production. Nobody knows because there are no tests to catch the regression. This hook makes untested code structurally impossible to write.

## How It Works

1. Agent tries to edit `src/lib/foo.ts`
2. Hook checks for `src/lib/foo.test.ts`
3. If test file doesn't exist → **BLOCKED** (exit code 2)
4. Agent must write `src/lib/foo.test.ts` first, then retry the edit

## Configuration

Edit the variables at the top of `hook.sh`:

- `SRC_DIR` — directory to protect (default: `src`)
- `SKIP_PATTERNS` — file patterns that don't need tests (test files, CSS, page components, type declarations)
- `SKIP_DIRS` — directories to skip entirely (e.g., UI library primitives like `components/ui`)
- `TEST_SUFFIX` — test file naming convention (default: `.test`)

## Setup

Add to `.claude/settings.json` or `.claude/settings.local.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "command": ".claude/hooks/tdd-guard/hook.sh"
      }
    ]
  }
}
```

Make the hook executable: `chmod +x .claude/hooks/tdd-guard/hook.sh`

## Supported Test Conventions

| Source File | Default Test File |
|-------------|-------------------|
| `src/lib/foo.ts` | `src/lib/foo.test.ts` |
| `src/app/api/bar/route.ts` | `src/app/api/bar/route.test.ts` |
| `src/components/Card.tsx` | `src/components/Card.test.tsx` |

Change `TEST_SUFFIX` to `.spec` for Jest/Vitest spec convention.
