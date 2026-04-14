---
name: notes
description: Update IMPLEMENTATION_NOTES.md with current session progress. Captures what was done, decisions made, and next steps. Critical for surviving context compaction.
allowed-tools: Read Write Edit Bash(git log *) Bash(git diff *)
---

# Update implementation notes

## Current state

```!
cat IMPLEMENTATION_NOTES.md 2>/dev/null || echo "No IMPLEMENTATION_NOTES.md found"
```

```!
git log --oneline -5 2>/dev/null || echo "No git history"
```

```!
git diff --stat 2>/dev/null || echo "No changes"
```

## Your task

Update `IMPLEMENTATION_NOTES.md` with the current session's progress.

If the file does not exist, create it using this structure:

```markdown
# Implementation Notes — [Project Name]

> Living document. Updated during development to survive context compaction.
> Each entry should capture: what was done, why, and any decisions made.

---
```

Add a new entry at the top of the session log (most recent first) with:

1. **Date and session number** (infer from existing entries or start at 1)
2. **Status**: in progress / completed / blocked
3. **What was done**: concrete list of changes, referencing files and functions
4. **Decisions made**: architectural choices, trade-offs accepted, alternatives rejected
5. **Open questions**: unresolved issues that need human input
6. **Next steps**: what should happen next in the implementation

## Rules

- Be specific — reference actual file names, function names, line numbers
- Keep entries concise but complete enough to reconstruct context from scratch
- Do not delete or modify previous entries
- If the user provides `$ARGUMENTS`, use that as additional context for what to log
- Write in English
