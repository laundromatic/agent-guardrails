# Plan vs Reality

> Add this to your project's CLAUDE.md or .claude/rules/ directory.

## Rule

When plan documents conflict with what was actually built, **reality wins**.

### Document Hierarchy

| Document | What It Captures | Can Be Stale? |
|----------|-----------------|---------------|
| **Code + tests** | What IS built | No (it's the system) |
| **Session notes / changelogs** | What WAS built and why | No (written after implementation) |
| **Plan documents** | What was INTENDED to be built | **YES** |
| **Issue descriptions** | What was REQUESTED | **YES** |

### Before Implementing Any Plan

1. Identify the systems/components the plan touches
2. Check session notes, changelogs, or git history for those components
3. Look for conflicts: Did the architecture change? Did responsibilities move?
4. **If conflicts found**: Do NOT proceed with the stale plan. Flag the discrepancy and ask for guidance.

### Why This Matters

Plans capture intent at a point in time. Codebases evolve. Implementing a stale plan can break systems that were restructured after the plan was written. The cost of checking is minutes; the cost of implementing a stale plan is hours of debugging.
