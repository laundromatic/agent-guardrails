# Evidence-Based Completion

> Add this to your project's CLAUDE.md or .claude/rules/ directory.

## Rule

NEVER say "done", "fixed", "complete", or "implemented" without verifiable evidence.

### Required Evidence by Change Type

| Change Type | Required Evidence |
|-------------|-------------------|
| Bug fix | Test that previously failed now passes |
| New feature | New tests + passing test output |
| API change | Actual HTTP response showing correct behavior |
| UI change | Screenshot with specific elements identified |
| Config/env change | Read back the file after writing to confirm |
| Data operation | Count before AND after. Verify key records. |

### If Verification Is Not Possible

Say **"UNVERIFIED — requires manual confirmation"** and explain what cannot be tested and why.

### What Does NOT Count

- "I made the change" (claim, not evidence)
- "The code looks correct" (review is not testing)
- Checked boxes in issue trackers (claims, not evidence)
- "It should work now" (should is not does)
