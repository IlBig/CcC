---
name: review
description: Cross-review with Codex CLI. Sends the current diff and project context to Codex with full system access (danger-full-access, no approvals) for independent code review. Codex can identify issues and apply fixes directly. Model is taken from $CODEX_MODEL (default matches the pre-commit hook).
disable-model-invocation: true
allowed-tools: Bash(codex *) Bash(git *) Bash(cat *) Read
---

# Cross-review with Codex CLI

## Project context

```!
cat AGENTS.md 2>/dev/null || echo "No AGENTS.md found"
```

## Recent changes (commits not on upstream + uncommitted worktree)

```!
has_changes=0

UPSTREAM_DIFF=""
if git rev-parse --verify "@{upstream}" >/dev/null 2>&1; then
    UPSTREAM_DIFF=$(git diff "@{upstream}..HEAD")
fi

if [ -n "$UPSTREAM_DIFF" ]; then
    printf '### Committed changes not on upstream\n%s\n' "$UPSTREAM_DIFF"
    has_changes=1
fi

WORKTREE_DIFF=$(git diff HEAD 2>/dev/null || git diff 2>/dev/null || true)
if [ -n "$WORKTREE_DIFF" ]; then
    if [ "$has_changes" -eq 1 ]; then
        printf '\n'
    fi
    printf '### Uncommitted changes in working tree\n%s\n' "$WORKTREE_DIFF"
    has_changes=1
fi

[ "$has_changes" -eq 1 ] || echo "No git changes found"
```

## Recent history

```!
git log --oneline -10 2>/dev/null || echo "No git history"
```

## Execute Codex review

Model defaults to `${CODEX_MODEL:-gpt-5.4}`; override with `CODEX_MODEL=<model> /review`.

Run the following command to launch Codex as an independent reviewer:

```bash
codex exec --model "${CODEX_MODEL:-gpt-5.4}" --sandbox danger-full-access --approval-mode never -o REVIEW.md - <<'PROMPT'
You are a senior code reviewer. You have full autonomy to read, analyze, and fix code.

## Your task
1. Use the project context, recent changes, and recent history already included earlier in this prompt
2. Check for: bugs, security issues, performance problems, style violations, missing tests
3. If you find fixable issues, fix them directly in the source files
4. Write a structured review report

## Review format
Rate each category: PASS / WARN / FAIL
- Correctness:
- Security:
- Performance:
- Style:
- Test coverage:

Overall: PASS / WARN / FAIL

### Issues found
[list each issue with file, line, severity, description]

### Fixes applied
[list each fix with file, what was changed, why]

### Recommendations
[suggestions that weren't auto-fixed]
PROMPT
```

After Codex finishes, read and display `REVIEW.md` to the user.
