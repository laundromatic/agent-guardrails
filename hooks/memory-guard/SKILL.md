---
name: memory-guard
description: PreToolUse hook that blocks writes to memory index files exceeding a configurable line limit. Prevents context loss from system truncation.
---

# Memory Guard

A PreToolUse hook that **blocks** writes to memory files that would exceed a configurable line limit.

## What It Prevents

AI coding agents maintain context in memory files (like `MEMORY.md`). These files have system-level truncation limits — content past a certain line count is silently invisible to future sessions. Without this guard, the agent keeps appending content until critical decisions are lost.

## How It Works

1. Agent tries to write to `MEMORY.md`
2. Hook counts lines in the proposed content
3. If content exceeds limit (default: 150 lines) → **BLOCKED** (exit code 2)
4. Agent must refactor: move detailed content to topic files, keep the index lean

## Configuration

Edit the variables at the top of `hook.sh`:

- `MAX_LINES` — maximum allowed lines (default: 150)
- `PROTECTED_FILE` — file name to protect (default: `MEMORY.md`)

## Setup

Add to `.claude/settings.json` or `.claude/settings.local.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write",
        "command": ".claude/hooks/memory-guard/hook.sh"
      }
    ]
  }
}
```

Make the hook executable: `chmod +x .claude/hooks/memory-guard/hook.sh`

## Memory Architecture Pattern

This hook works best with a two-tier memory structure:

```
memory/
├── MEMORY.md          ← Protected by this hook (lean index, <150 lines)
├── decisions-log.md   ← Detailed: chronological decisions and pivots
├── topic-a.md         ← Detailed: domain-specific knowledge
└── topic-b.md         ← Detailed: domain-specific knowledge
```

`MEMORY.md` is the index — one line per entry pointing to topic files. Topic files hold the detail. The guard ensures the index stays navigable.
