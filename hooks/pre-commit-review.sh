#!/bin/bash
# =============================================================================
# Git pre-commit hook — Codex CLI autonomous review (BLOCKING)
#
# This hook runs before every git commit. It sends the staged diff to
# Codex CLI (GPT-5.4) with full system access (danger-full-access, no approvals).
# Codex reviews the code and can apply fixes directly. If critical issues
# remain unfixed, the commit is blocked.
#
# Install: cp hooks/pre-commit-review.sh .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit
# Bypass:  git commit --no-verify  (for emergencies only)
# =============================================================================

set -euo pipefail

# --- Configuration ---
CODEX_MODEL="${CODEX_MODEL:-gpt-5.4}"
REVIEW_FILE="REVIEW.md"
MAX_DIFF_LINES=5000

# --- Colors ---
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

# --- Check if codex is installed ---
if ! command -v codex &>/dev/null; then
    echo -e "${YELLOW}[pre-commit] Codex CLI not found. Skipping review.${NC}"
    exit 0
fi

# --- Get staged diff ---
DIFF=$(git diff --cached)

if [ -z "$DIFF" ]; then
    echo -e "${CYAN}[pre-commit] No staged changes. Skipping review.${NC}"
    exit 0
fi

# --- Check diff size ---
DIFF_LINES=$(echo "$DIFF" | wc -l)
if [ "$DIFF_LINES" -gt "$MAX_DIFF_LINES" ]; then
    echo -e "${YELLOW}[pre-commit] Diff too large (${DIFF_LINES} lines > ${MAX_DIFF_LINES}). Skipping review.${NC}"
    exit 0
fi

# --- Read project context ---
AGENT_CONTEXT=""
if [ -f "AGENT.md" ]; then
    AGENT_CONTEXT=$(cat AGENT.md)
fi

# --- Build review prompt ---
REVIEW_PROMPT="You are a senior code reviewer performing a pre-commit review.
You have FULL AUTONOMY to read and fix files.

## Project context
${AGENT_CONTEXT}

## Staged changes to review
${DIFF}

## Instructions
1. Review the staged diff for: bugs, security issues, logic errors, style violations
2. If you find fixable issues, FIX THEM directly in the source files
3. Write your review verdict as the LAST LINE of your response in this exact format:
   VERDICT: PASS
   or
   VERDICT: WARN — [brief reason]
   or
   VERDICT: FAIL — [brief reason]

PASS = no issues found
WARN = minor issues found (fixed or cosmetic) — commit should proceed
FAIL = critical issues that could not be auto-fixed — commit should be blocked"

echo -e "${CYAN}[pre-commit] Running Codex review (${CODEX_MODEL})...${NC}"

# --- Run Codex ---
CODEX_OUTPUT=$(echo "$REVIEW_PROMPT" | codex exec --model "$CODEX_MODEL" --sandbox danger-full-access --approval-mode never -o "$REVIEW_FILE" - 2>&1) || true

# --- Parse verdict from REVIEW.md ---
VERDICT="PASS"
if [ -f "$REVIEW_FILE" ]; then
    VERDICT_LINE=$(grep -i "^VERDICT:" "$REVIEW_FILE" | tail -1 || echo "VERDICT: PASS")
    if echo "$VERDICT_LINE" | grep -qi "FAIL"; then
        VERDICT="FAIL"
    elif echo "$VERDICT_LINE" | grep -qi "WARN"; then
        VERDICT="WARN"
    fi
fi

# --- Act on verdict ---
case "$VERDICT" in
    "PASS")
        echo -e "${GREEN}[pre-commit] Review PASSED. Committing.${NC}"
        # Re-stage any files Codex may have fixed
        git diff --name-only | while read -r file; do
            if git diff --cached --name-only | grep -q "^${file}$"; then
                git add "$file"
            fi
        done
        exit 0
        ;;
    "WARN")
        echo -e "${YELLOW}[pre-commit] Review WARNING. See ${REVIEW_FILE} for details. Committing anyway.${NC}"
        # Re-stage any files Codex may have fixed
        git diff --name-only | while read -r file; do
            if git diff --cached --name-only | grep -q "^${file}$"; then
                git add "$file"
            fi
        done
        exit 0
        ;;
    "FAIL")
        echo -e "${RED}[pre-commit] Review FAILED. Commit blocked.${NC}"
        echo -e "${RED}See ${REVIEW_FILE} for details.${NC}"
        echo -e "${YELLOW}Fix the issues and try again, or use 'git commit --no-verify' to bypass.${NC}"
        exit 1
        ;;
esac
