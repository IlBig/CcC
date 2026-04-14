---
name: review
description: Cross-review with Codex CLI (GPT-5.4). Sends the current diff and project context to Codex with full system access (danger-full-access, no approvals) for independent code review. Codex can identify issues and apply fixes directly.
disable-model-invocation: true
allowed-tools: Bash(codex *) Bash(git *) Bash(cat *) Read
---

# Cross-review with Codex CLI

## Project context

```!
cat AGENT.md 2>/dev/null || echo "No AGENT.md found"
```

## Recent changes

```!
git diff HEAD~1 2>/dev/null || git diff 2>/dev/null || echo "No git changes found"
```

## Recent history

```!
git log --oneline -10 2>/dev/null || echo "No git history"
```

## Execute Codex review

Run the following command to launch Codex as an independent reviewer:

```bash
codex exec --model gpt-5.4 --sandbox danger-full-access --approval-mode never -o REVIEW.md - <<'PROMPT'
You are a senior code reviewer. You have full autonomy to read, analyze, and fix code.

## Project context
$(cat AGENT.md 2>/dev/null)

## Your task
1. Review the recent changes shown below
2. Check for: bugs, security issues, performance problems, style violations, missing tests
3. If you find fixable issues, fix them directly in the source files
4. Write a structured review report

## Recent diff
$(git diff HEAD~1 2>/dev/null || git diff 2>/dev/null)

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
