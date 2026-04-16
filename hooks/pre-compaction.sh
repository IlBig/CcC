#!/usr/bin/env bash
# =============================================================================
# Claude Code PreCompact hook handler
#
# Runs before context compaction to remind the agent to re-read project context.
# This preserves working memory that would otherwise be lost during compaction.
#
# This script is called by Claude Code via the PreCompact hook event.
# It receives JSON on stdin with the hook event data.
#
# Configure in .claude/settings.json:
# {
#   "hooks": {
#     "PreCompact": [
#       {
#         "matcher": "",
#         "hooks": [
#           {
#             "type": "command",
#             "command": "\"$CLAUDE_PROJECT_DIR\"/hooks/pre-compaction.sh",
#             "statusMessage": "Saving implementation notes before compaction..."
#           }
#         ]
#       }
#     ]
#   }
# }
# =============================================================================

set -euo pipefail

NOTES_FILE="IMPLEMENTATION_NOTES.md"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")

# --- If IMPLEMENTATION_NOTES.md doesn't exist, nothing to preserve ---
if [ ! -f "$NOTES_FILE" ]; then
    exit 0
fi

# --- Output context for Claude to include in the compacted context ---
# This JSON tells Claude to refresh notes and workflow rules after compaction
REMINDER="IMPORTANT: Context compaction is happening (IMPLEMENTATION_NOTES.md last updated at ${TIMESTAMP}). After compaction, execute in order:
1. Read AGENTS.md — confirm project rules, architecture, conversation language.
2. Read IMPLEMENTATION_NOTES.md — find last session status, open questions, next steps.
3. Run: git log --oneline -10 && git status --short
4. If the last session status is 'in progress', pick up from its Next Steps.
5. If any Open Question is unresolved, surface it to the user before writing code.
6. If anything is missing or stale, invoke /continue to rebuild full context."

# Emit JSON with jq when available so quotes in REMINDER are escaped safely; fallback to a safe manual escape.
if command -v jq >/dev/null 2>&1; then
    jq -n --arg ctx "$REMINDER" '{hookSpecificOutput: {hookEventName: "PreCompact", additionalContext: $ctx}}'
else
    ESC=$(printf '%s' "$REMINDER" | python3 -c 'import json,sys;print(json.dumps(sys.stdin.read())[1:-1])' 2>/dev/null \
        || printf '%s' "$REMINDER" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e ':a;N;$!ba;s/\n/\\n/g')
    printf '{"hookSpecificOutput":{"hookEventName":"PreCompact","additionalContext":"%s"}}\n' "$ESC"
fi

exit 0
