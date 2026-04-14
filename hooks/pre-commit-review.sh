#!/usr/bin/env bash
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
REVIEW_FILE="${REVIEW_FILE:-REVIEW.md}"
MAX_DIFF_LINES="${MAX_DIFF_LINES:-5000}"

# --- Colors ---
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

fail_commit() {
    echo -e "${RED}[pre-commit] $*${NC}"
    echo -e "${YELLOW}Install/fix Codex, split the commit, or use 'git commit --no-verify' to bypass.${NC}"
    exit 1
}

# --- Check if codex is installed ---
if ! command -v codex &>/dev/null; then
    fail_commit "Codex CLI not found. Review is mandatory for this workflow."
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
    fail_commit "Diff too large (${DIFF_LINES} lines > ${MAX_DIFF_LINES}). Split the change set or raise MAX_DIFF_LINES."
fi

# --- Require a clean worktree so auto-fixes can be safely re-staged ---
if ! git diff --quiet; then
    fail_commit "Unstaged tracked changes detected. Stage or stash them before committing."
fi

UNTRACKED_FILES=$(git ls-files --others --exclude-standard | grep -vxF "$REVIEW_FILE" || true)
if [ -n "$UNTRACKED_FILES" ]; then
    echo -e "${RED}[pre-commit] Untracked files detected. Clean the worktree before commit so Codex fixes can be staged safely.${NC}"
    echo "$UNTRACKED_FILES"
    echo -e "${YELLOW}Add them, ignore them, or stash them first.${NC}"
    exit 1
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
REVIEW_FILE_TRACKED=0
if git ls-files --error-unmatch -- "$REVIEW_FILE" >/dev/null 2>&1; then
    REVIEW_FILE_TRACKED=1
fi

TMP_REVIEW_FILE=$(mktemp "${TMPDIR:-/tmp}/codex-review.XXXXXX")
cleanup() {
    rm -f "$TMP_REVIEW_FILE"
}
trap cleanup EXIT

set +e
echo "$REVIEW_PROMPT" | codex exec --model "$CODEX_MODEL" --sandbox danger-full-access --approval-mode never -o "$TMP_REVIEW_FILE" - 2>&1
CODEX_STATUS=$?
set -e

if [ -s "$TMP_REVIEW_FILE" ]; then
    mv "$TMP_REVIEW_FILE" "$REVIEW_FILE"
fi

if [ "$CODEX_STATUS" -ne 0 ]; then
    fail_commit "Codex review process failed (exit code ${CODEX_STATUS})."
fi

if [ ! -f "$REVIEW_FILE" ]; then
    fail_commit "Codex review did not produce ${REVIEW_FILE}."
fi

# --- Parse verdict from the fresh review output ---
VERDICT_LINE=$(grep -i "^VERDICT:" "$REVIEW_FILE" | tail -1 || true)
if [ -z "$VERDICT_LINE" ]; then
    fail_commit "Review output is missing the VERDICT line."
fi

VERDICT=""
if echo "$VERDICT_LINE" | grep -qiE '^VERDICT:[[:space:]]*FAIL([[:space:]]|$)'; then
    VERDICT="FAIL"
elif echo "$VERDICT_LINE" | grep -qiE '^VERDICT:[[:space:]]*WARN([[:space:]]|$)'; then
    VERDICT="WARN"
elif echo "$VERDICT_LINE" | grep -qiE '^VERDICT:[[:space:]]*PASS([[:space:]]|$)'; then
    VERDICT="PASS"
else
    fail_commit "Unrecognized verdict line: ${VERDICT_LINE}"
fi

restage_codex_changes() {
    git add -A
    if [ "$REVIEW_FILE_TRACKED" -eq 0 ]; then
        git rm --cached -q --ignore-unmatch -- "$REVIEW_FILE" 2>/dev/null || true
    fi
}

# --- Act on verdict ---
case "$VERDICT" in
    "PASS")
        echo -e "${GREEN}[pre-commit] Review PASSED. Committing.${NC}"
        restage_codex_changes
        exit 0
        ;;
    "WARN")
        echo -e "${YELLOW}[pre-commit] Review WARNING. See ${REVIEW_FILE} for details. Committing anyway.${NC}"
        restage_codex_changes
        exit 0
        ;;
    "FAIL")
        echo -e "${RED}[pre-commit] Review FAILED. Commit blocked.${NC}"
        echo -e "${RED}See ${REVIEW_FILE} for details.${NC}"
        echo -e "${YELLOW}Fix the issues and try again, or use 'git commit --no-verify' to bypass.${NC}"
        exit 1
        ;;
esac
