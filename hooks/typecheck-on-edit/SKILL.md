---
name: typecheck-on-edit
description: PostToolUse hook that runs tsc --noEmit after every TypeScript edit. Catches type errors immediately instead of waiting for CI.
---

# Typecheck on Edit

A PostToolUse hook that runs `tsc --noEmit` after every TypeScript file edit, surfacing type errors immediately.

## What It Prevents

Tests pass but CI fails on type errors. The agent says "done" but the build is broken. Multiple follow-up commits are needed to fix what should have been caught the moment the error was introduced.

## How It Works

1. Agent edits a `.ts` or `.tsx` file
2. Hook runs `tsc --noEmit` in the project root
3. If type errors exist, they're displayed immediately
4. Agent can fix them before moving on

This hook **informs but does not block** — it exits 0 regardless. The agent sees the errors and should fix them proactively.

## Configuration

Edit the variables at the top of `hook.sh`:

- `MAX_ERROR_LINES` — maximum lines of error output (default: 15)
- `TS_CONFIG` — path to tsconfig.json if non-standard (default: empty, uses project root)

## Setup

Add to `.claude/settings.json` or `.claude/settings.local.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "command": ".claude/hooks/typecheck-on-edit/hook.sh"
      }
    ]
  }
}
```

Make the hook executable: `chmod +x .claude/hooks/typecheck-on-edit/hook.sh`

## Skipped Files

- Test files (`.test.ts`, `.spec.ts`)
- Config files (`.config.ts`)
- Type declarations (`.d.ts`)
- Non-TypeScript files
