# Workflow 1 — Coding Core

<!-- AUTO-MANAGED: project-description -->
Stack-agnostic IT consulting coding workflow based on antirez's "automatic programming" method. Uses Claude Code (writer) + Codex CLI (independent reviewer) in a 6-phase cycle.
<!-- END AUTO-MANAGED -->

<!-- AUTO-MANAGED: architecture -->
## Repository structure

```
workflow/
├── ccc                             # Bootstrap script: creates new projects with full workflow
├── workflow-1-coding-core-v2.md    # Primary workflow documentation
├── skills/
│   ├── spec/SKILL.md               # /spec — guided SPEC.md creation
│   ├── research/SKILL.md           # /research — autonomous doc research → RESEARCH.md
│   ├── review/SKILL.md             # /review — manual Codex cross-review → REVIEW.md
│   ├── notes/SKILL.md              # /notes — update IMPLEMENTATION_NOTES.md
│   └── continue/SKILL.md           # /continue — context recovery after compaction
├── hooks/
│   ├── pre-commit-review.sh        # Git pre-commit: auto Codex review on every commit
│   └── pre-compaction.sh           # Claude PreCompact hook: injects context recovery reminder
└── templates/
    ├── AGENTS.md.template            # Primary AI instruction file template
    ├── CLAUDE.md.template           # Redirect template ("See AGENTS.md")
    ├── SPEC.md.template             # Project specification template
    └── IMPLEMENTATION_NOTES.md.template  # Living session diary template
```
<!-- END AUTO-MANAGED -->

<!-- AUTO-MANAGED: conventions -->
## Conventions

- **AGENTS.md is primary** — contains all AI instructions; CLAUDE.md in projects contains only `See AGENTS.md`
- **New project:** `ccc MyProject` — bootstraps everything automatically (installs tools if needed, clones repo, copies files, inits git, launches Claude Code)
- **Manual skills install:** copy `skills/*` to `.claude/skills/` (project) or `~/.claude/skills/` (global)
- **Manual hook install:** `cp hooks/pre-commit-review.sh .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit`
- **PreCompact hook** configured in `.claude/settings.json` under `hooks.PreCompact`
- All project artifacts written in English
<!-- END AUTO-MANAGED -->

<!-- AUTO-MANAGED: patterns -->
## Workflow phases

```
A. Vision → B. Research → C. Generate → D. Review → E. Verify → F. Commit
  /spec       /research    Claude Code   Codex auto   human       git hook
```

- **Phase A:** `/spec <topic>` — Claude asks up to 7 research-backed questions (with rationale and examples), produces `SPEC.md`
- **Phase B:** `/research <topic>` — Claude fetches docs, produces `RESEARCH.md`
- **Phase C:** Claude Code generates code per `AGENTS.md` + `SPEC.md` + `RESEARCH.md`
- **Phase D:** Codex auto-reviews every commit via pre-commit hook; verdicts: PASS / WARN / FAIL
- **Phase E:** Human reads code and `REVIEW.md` — mandatory, non-negotiable
- **Phase F:** `git commit` triggers hook; FAIL blocks commit, WARN/PASS proceeds

## Hooks

- **pre-commit-review.sh:** Sends staged diff + `AGENTS.md` to Codex (`gpt-5.4`, `--sandbox danger-full-access --approval-mode never`); commit is blocked if Codex is unavailable, the review fails, or the diff exceeds `MAX_DIFF_LINES`; requires a clean worktree so Codex fixes can be re-staged safely; `CODEX_MODEL`, `REVIEW_FILE`, and `MAX_DIFF_LINES` can be overridden via env vars
- **pre-compaction.sh:** On `PreCompact`, injects a reminder to re-read `AGENTS.md` and `IMPLEMENTATION_NOTES.md` after compaction; no-op if `IMPLEMENTATION_NOTES.md` absent

## Skills

| Skill | Output | Key tools |
|-------|--------|-----------|
| `/spec` | `SPEC.md` (+ optional `AGENTS.md`) | WebSearch, WebFetch |
| `/research` | `RESEARCH.md` (effort: max) | WebSearch, WebFetch |
| `/review` | `REVIEW.md` | `codex exec --sandbox danger-full-access --approval-mode never` |
| `/notes` | `IMPLEMENTATION_NOTES.md` update helper | git log, git diff |
| `/continue` | Summary + next-step prompt | git log/status/diff |
<!-- END AUTO-MANAGED -->
