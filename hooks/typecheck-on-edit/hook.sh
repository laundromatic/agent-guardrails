#!/bin/bash
# Typecheck on Edit — PostToolUse hook
# Runs tsc --noEmit after every TypeScript file edit.
# Surfaces type errors immediately instead of waiting for CI.
# Informational only — does not block.
#
# INCIDENT: Vitest tests passed but CI failed on TypeScript type errors.
# Multiple follow-up commits needed to fix what should have been caught immediately.
# This hook catches type errors the moment they're introduced.

# --- CONFIGURABLE ---

# Maximum lines of error output to show
MAX_ERROR_LINES=15

# TypeScript config file (empty = use default tsconfig.json)
TS_CONFIG=""

# --- END CONFIGURABLE ---

FILE_PATH="${CLAUDE_TOOL_INPUT_FILE_PATH:-}"
if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

# Skip non-TypeScript files
case "$FILE_PATH" in
  *.ts|*.tsx) ;;
  *) exit 0 ;;
esac

# Skip test files and config files
case "$FILE_PATH" in
  *.test.ts|*.test.tsx|*.spec.ts|*.spec.tsx) exit 0 ;;
  *.config.*|*.d.ts) exit 0 ;;
esac

# Build tsc command
TSC_CMD="npx tsc --noEmit"
if [[ -n "$TS_CONFIG" ]]; then
  TSC_CMD="$TSC_CMD --project $TS_CONFIG"
fi

# Run typecheck
cd "$CLAUDE_PROJECT_DIR" || exit 0
OUTPUT=$($TSC_CMD 2>&1 | head -$MAX_ERROR_LINES)

if [ $? -ne 0 ]; then
  echo "TypeScript errors detected after edit:"
  echo "$OUTPUT"
fi

# Always exit 0 — this hook informs, it doesn't block
exit 0
