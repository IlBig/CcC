---
name: continue
description: Reconstruct full project context after context compaction or session restart. Reads all key project files and recent git history to rebuild working memory. Always the first command when resuming work.
allowed-tools: Read Bash(cat *) Bash(git log *) Bash(git diff *) Bash(git status *) Bash(ls *)
---

# Context recovery

Re-read all project context files to reconstruct working memory.

## AGENTS.md (project rules and architecture)

```!
cat AGENTS.md 2>/dev/null || echo "No AGENTS.md found — check if the project has been initialized"
```

## SPEC.md (project specification)

```!
cat SPEC.md 2>/dev/null || echo "No SPEC.md found"
```

## IMPLEMENTATION_NOTES.md (session history)

```!
cat IMPLEMENTATION_NOTES.md 2>/dev/null || echo "No IMPLEMENTATION_NOTES.md found"
```

## RESEARCH.md (documentation dossier)

```!
cat RESEARCH.md 2>/dev/null || echo "No RESEARCH.md found"
```

## Recent git activity

```!
git log --oneline -20 2>/dev/null || echo "No git history"
```

```!
git status --short 2>/dev/null || echo "Not a git repository"
```

```!
git diff --stat 2>/dev/null || echo "No uncommitted changes"
```

## Your task

Converse with the user in the language specified in AGENTS.md. Based on the files above:

1. **Summarize the current state** of the project in 3-5 sentences.
2. **Identify where work left off** from IMPLEMENTATION_NOTES.md.
3. **List the next steps** that need to happen.
4. **Flag any open questions** or blockers from the notes.
5. **Confirm the development rules** from AGENTS.md are understood.

### Consistency checks (run silently, raise only on mismatch)

- If IMPLEMENTATION_NOTES status is `completed` but `git status --short` shows modified/untracked files → surface the conflict: "Notes say last session ended, but the worktree has changes. Did the previous session finish cleanly?"
- If the last commit is older than 7 days → flag the context as potentially stale and recommend re-verifying assumptions before writing code.
- If SPEC.md names technologies/APIs that do NOT appear in RESEARCH.md → suggest: "Run `/research <tech>` before coding; RESEARCH.md is missing coverage for: <list>."
- If AGENTS.md is missing → recommend `/spec` (first bootstrap) or tell the user the project is not initialized.

Then ask the user: "Context recovered. Ready to continue from [last checkpoint]. Shall I proceed with [next step], or do you want to redirect?"
