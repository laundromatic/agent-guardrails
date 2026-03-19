#!/bin/bash
# Memory Guard — PreToolUse hook
# Blocks writes to memory index files that exceed a configurable line limit.
# Prevents agent context loss from file truncation.
# Exit 2 = block with message, Exit 0 = allow.
#
# INCIDENT: Agent context file grew past the system's 200-line truncation limit.
# Critical project decisions were silently lost because they were past line 200.
# Future sessions made wrong decisions based on incomplete context.
# This hook blocks writes before they exceed the safety margin.

# --- CONFIGURABLE ---

# Maximum allowed lines in the memory index file
MAX_LINES=150

# File name to protect (matched against the end of the file path)
PROTECTED_FILE="MEMORY.md"

# --- END CONFIGURABLE ---

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only check Write tool
if [[ "$TOOL" != "Write" ]]; then
  exit 0
fi

# Check if the file being written matches the protected file
if [[ "$FILE_PATH" != *"$PROTECTED_FILE" ]]; then
  exit 0
fi

# Count lines in the content being written
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // empty')
LINE_COUNT=$(echo "$CONTENT" | wc -l | tr -d ' ')

if [[ "$LINE_COUNT" -gt "$MAX_LINES" ]]; then
  echo "MEMORY GUARD: $PROTECTED_FILE would be ${LINE_COUNT} lines (limit: $MAX_LINES)." >&2
  echo "Content past the system truncation limit becomes invisible to future sessions." >&2
  echo "" >&2
  echo "ACTION REQUIRED:" >&2
  echo "  1. Move detailed content to separate topic files" >&2
  echo "  2. Keep $PROTECTED_FILE as a lean index with 1-2 line summaries per entry" >&2
  echo "  3. Rewrite to stay under $MAX_LINES lines, then retry" >&2
  exit 2
fi

exit 0
