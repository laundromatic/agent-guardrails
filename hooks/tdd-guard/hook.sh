#!/bin/bash
# TDD Guard — PreToolUse hook
# Blocks Edit/Write on source files that lack corresponding test files.
# Exit 2 = block the action, Exit 0 = allow.
#
# INCIDENT: A feature (Trudy Rewrite, 6 tickets) shipped without a single test.
# TDD Guard existed but wasn't enforced. This hook closes that gap — it's a hard block,
# not a suggestion the agent can ignore.
#
# CONFIGURATION: Edit the variables below to match your project.

# --- CONFIGURABLE ---

# Directory containing source files to protect
SRC_DIR="src"

# Glob patterns to SKIP (won't require tests)
# Add patterns for files that don't need tests in your project
SKIP_PATTERNS=(
  "*.test.ts"
  "*.test.tsx"
  "*.spec.ts"
  "*.spec.tsx"
  "*.d.ts"
  "*.css"
  "*.scss"
  "*/layout.tsx"
  "*/loading.tsx"
  "*/not-found.tsx"
  "*/error.tsx"
  "*/page.tsx"
)

# Directories to skip entirely (e.g., UI library primitives)
SKIP_DIRS=(
  "components/ui"
)

# Test file extension mapping
# source.ts → source.test.ts, source.tsx → source.test.tsx
TEST_SUFFIX=".test"

# --- END CONFIGURABLE ---

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only check files in the source directory
if [[ "$FILE_PATH" != *"/$SRC_DIR/"* ]]; then
  exit 0
fi

# Check skip patterns
for pattern in "${SKIP_PATTERNS[@]}"; do
  case "$FILE_PATH" in
    $pattern) exit 0 ;;
  esac
done

# Check skip directories
for dir in "${SKIP_DIRS[@]}"; do
  if [[ "$FILE_PATH" == *"/$dir/"* ]]; then
    exit 0
  fi
done

# Determine expected test file path
if [[ "$FILE_PATH" == *.tsx ]]; then
  TEST_FILE="${FILE_PATH%.tsx}${TEST_SUFFIX}.tsx"
elif [[ "$FILE_PATH" == *.ts ]]; then
  TEST_FILE="${FILE_PATH%.ts}${TEST_SUFFIX}.ts"
else
  exit 0  # Not a TypeScript file
fi

# Check if test file exists
if [[ ! -f "$TEST_FILE" ]]; then
  RELATIVE_PATH="${FILE_PATH##*/$SRC_DIR/}"
  RELATIVE_TEST="${TEST_FILE##*/$SRC_DIR/}"
  echo "TDD GUARD: No test file found for $SRC_DIR/$RELATIVE_PATH" >&2
  echo "Expected: $SRC_DIR/$RELATIVE_TEST" >&2
  echo "Write tests first, then implement." >&2
  exit 2
fi

exit 0
