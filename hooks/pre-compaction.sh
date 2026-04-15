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
cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreCompact",
    "additionalContext": "IMPORTANT: Context compaction is happening. IMPLEMENTATION_NOTES.md was last updated at ${TIMESTAMP}. After compaction, re-read AGENTS.md and IMPLEMENTATION_NOTES.md to recover context. Use /continue if needed."
  }
}
EOF

exit 0
