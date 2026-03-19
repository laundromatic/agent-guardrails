---
name: verify-before-done
description: Instructs the agent to never claim "done" without verifiable evidence. Requires test output, API response, or screenshot before completion claims.
---

# Verify Before Done

Never say "done", "fixed", "complete", or "implemented" without verifiable evidence.

## Why This Exists

An AI agent claimed it "disabled a workflow" to stop runaway API calls. It had only disabled a trigger **node**, not the workflow itself. The workflow continued running on schedule, consuming 100% of the monthly execution quota ($10,000 in wasted API calls). The agent said "done" — and was wrong.

## Rules

### 1. Evidence Required for Completion Claims

Before saying any work is complete, you MUST provide one of:

- **Test output** — actual `npm run test` / `pytest` / equivalent results showing pass/fail
- **API response** — actual HTTP response showing the change took effect
- **Screenshot or visual proof** — for UI changes
- **Command output** — for infrastructure changes (deployment logs, status checks)
- **Diff** — showing what changed and why

### 2. If Verification Is Not Possible

Say: **"UNVERIFIED — requires manual confirmation"**

Then explain:
- What specifically cannot be verified
- Why (no test environment, external dependency, visual-only change)
- What the user should check manually

### 3. What Counts as Evidence

| Change Type | Acceptable Evidence |
|-------------|-------------------|
| Bug fix | Test that failed before, passes after |
| New feature | New tests covering the feature + passing |
| API change | HTTP request/response showing correct behavior |
| UI change | Screenshot with specific elements identified |
| Config change | Read back the config file to confirm the write |
| Workflow/automation change | Check execution logs to confirm the change took effect |
| Data migration | Count before and after, verify key records |

### 4. What Does NOT Count as Evidence

- "I made the change" — that's a claim, not evidence
- "The code looks correct" — code review is not testing
- "It should work now" — should is not does
- Checked boxes in a task tracker — checkboxes are claims, test results are evidence

### 5. Multi-Step Verification

For changes that affect multiple systems:
1. Verify each system independently
2. Wait for the change to propagate (don't check immediately if there's a delay)
3. If one system can't be verified, say so explicitly — don't let a partial verification become a full completion claim
