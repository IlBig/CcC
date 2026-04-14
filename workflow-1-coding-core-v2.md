# Workflow 1 — Coding Core

> A structured coding workflow for IT consulting, inspired by antirez's automatic programming method.
> Adapted for multi-project, multi-client environments where reproducibility matters.
>
> **Version:** 2.2 — April 2026
> **Stack-agnostic** — pair with stack-specific addenda for web/mobile/desktop

---

## Table of contents

0. [Philosophy](#0-philosophy)
1. [Tool setup](#1-tool-setup)
2. [Project structure](#2-project-structure)
3. [Work cycle — 6 phases](#3-work-cycle)
4. [Skills](#4-skills)
5. [Codex integration](#5-codex-integration)
6. [Hard rules](#6-hard-rules)
7. [Hooks](#7-hooks)
8. [Antipatterns](#8-antipatterns)
9. [Daily checklist](#9-daily-checklist)
10. [Quick reference](#10-quick-reference)
11. [Origin table](#11-origin-table)

---

## 0. Philosophy

**Automatic programming, not vibe coding.**

The distinction comes from antirez (Salvatore Sanfilippo, Redis creator):

- **Vibe coding** = you prompt an AI, accept whatever it outputs, don't really read the code, hope it works. The human abdicates quality control.
- **Automatic programming** = you write a precise specification, the AI generates code to that spec, a second AI independently reviews it, and you (the human) verify the result. Quality depends on the human who drives the process.

This workflow implements automatic programming. The AI writes code. You own the spec, the architecture, and the final judgment. Codex provides a second opinion. Nobody ships code they haven't read.

> Source: antirez.com/news/159

---

## 1. Tool setup

### 1.1 Claude Code (primary writer)

- **Model:** Claude Opus 4.6 (or Sonnet 4.6 for lighter tasks)
- **Plan:** Max (for extended context and tool access)
- **Install:** Already available if you're reading this

### 1.2 Codex CLI (independent reviewer)

```bash
npm i -g @openai/codex
codex login
```

Available models:

| Model | Best for |
|-------|----------|
| `gpt-5.4` (default) | Latest frontier agentic coding — primary choice |
| `gpt-5.4-mini` | Lighter tasks, faster, cheaper |
| `gpt-5.3-codex` | Codex-optimized, strong on complex refactors |
| `gpt-5.2` | Long-running agents, professional work |

Default for this workflow: **gpt-5.4**

### 1.3 Parallel sessions

For large projects, clone the working directory and run Claude Code and Codex in parallel sessions:

```bash
# Terminal 1: Claude Code generating code
cd ~/projects/myapp
claude

# Terminal 2: Codex reviewing in a cloned copy
cp -r ~/projects/myapp ~/projects/myapp-review
cd ~/projects/myapp-review
codex
```

> Source: antirez tweet on parallel sessions, March 2026

---

## 2. Project structure

### Quick start

```bash
ccc MyProject
```

The `ccc` script creates a new project with the full workflow structure, installs prerequisites (Claude Code CLI, Codex CLI) if needed, initializes git, and launches Claude Code. Install it with: `cp ccc ~/bin/ccc && chmod +x ~/bin/ccc`

### Project files

Every project using this workflow has these files:

```
project/
├── AGENT.md                    # Primary instruction file for any AI agent
├── CLAUDE.md                   # Redirect → "See AGENT.md"
├── AGENTS.md                   # Symlink → AGENT.md (Codex compatibility)
├── SPEC.md                     # Initial specification (Phase A output)
├── IMPLEMENTATION_NOTES.md     # Living development diary
├── RESEARCH.md                 # Documentation dossier (Phase B output, optional)
├── REVIEW.md                   # Latest Codex review output (auto-generated)
├── .claude/
│   ├── skills/                 # Workflow skills (spec, research, review, notes, continue)
│   └── settings.json           # PreCompact hook configuration
├── hooks/
│   └── pre-compaction.sh       # PreCompact hook handler
└── .git/hooks/pre-commit       # Automated Codex review hook
```

### AGENT.md (primary)

The single source of truth for any AI agent working on this project. Contains:
- Project overview
- File map
- Architecture
- Development rules (the 15 hard rules)
- Testing instructions
- Domain-specific notes

Named `AGENT.md` (not `CLAUDE.md`) to be agent-agnostic — works with Claude, Codex, or any future AI tool.

### CLAUDE.md (redirect)

Contains only: `See AGENT.md`

This ensures Claude Code picks up the project instructions automatically (it looks for CLAUDE.md by default), while AGENT.md remains the single source of truth.

### SPEC.md

The initial specification — the human "brain dump" that drives Phase A. Created with `/spec <topic>`. Antirez style: 50-150 lines, direct prose, no boilerplate.

### IMPLEMENTATION_NOTES.md

Living diary that survives context compaction. It must be kept current by the agent during development. The PreCompact hook injects a reminder to re-read it after compaction, and `/notes` is available to update it explicitly when needed.

Templates for all files are in `templates/`.

---

## 3. Work cycle

Six phases, executed in order. Each phase has a clear input, tool, and output.

```
A. Vision ──→ B. Research ──→ C. Generate ──→ D. Review ──→ E. Verify ──→ F. Commit
   human         Claude          Claude          Codex        human         git+hook
   /spec         /research       (coding)        (auto)       (read)        (auto-review)
   ↓              ↓               ↓               ↓            ↓             ↓
 SPEC.md      RESEARCH.md     source code     REVIEW.md    human OK     git commit
```

### 3.0 Cycle variants by work type

The full A→F cycle is not a one-shot sequence. It repeats throughout the project lifetime with different intensity depending on the type of work.

#### New feature (full cycle)

Every significant feature reopens the full cycle:

```
Feature N:  A → B → C → D → E → F
```

| Phase | First feature | Subsequent features |
|-------|--------------|---------------------|
| A — Vision | Full SPEC.md from scratch | Incremental: add section to SPEC.md or write a mini-spec |
| B — Research | Full RESEARCH.md | Only if the feature introduces new technologies; otherwise skip |
| C — Generate | Full | Full |
| D — Review | Automatic (pre-commit) | Automatic (pre-commit) |
| E — Verify | Full | Full |
| F — Commit | Automatic | Automatic |

AGENT.md is written once at project start and **updated incrementally** as the project evolves — the file map grows, known pitfalls accumulate, behavioral contracts are added. It is never rewritten from scratch.

#### Bug fix (short cycle)

Bug fixes skip Vision and Research entirely:

```
Bug fix:  C → D → E → F
```

- No spec needed — the bug is already an observable deviation from expected behavior
- No research needed — the technologies are already known
- **C**: Claude reads AGENT.md (which has behavioral contracts and known pitfalls), fixes the bug
- **D**: Codex reviews automatically at commit
- **E**: Human reads the fix and the review
- **F**: Commit proceeds if review passes

**After fixing a complex bug**, add it to AGENT.md's "Known Pitfalls" section — this prevents the agent from reintroducing it in the future. This is exactly what antirez does in iris.c and qwen-asr.

#### Small change (minimal cycle)

Cosmetic changes, config tweaks, documentation updates:

```
Small change:  C → D → E → F
```

Same as bug fix. No spec, no research. The pre-commit review still runs.

#### Summary: daily flow in practice

```
Session start:    /continue
New feature:      /spec "feature X" → /research "tech Y" (if needed) → generate → commit → read REVIEW.md
Small feature:    mini-spec inline → generate → commit → read REVIEW.md
Bug fix:          generate fix → commit → read REVIEW.md → update AGENT.md Known Pitfalls
Session end:      update IMPLEMENTATION_NOTES.md if the session state changed
```

### Phase A — Vision

**Who:** Human
**Tool:** `/spec <topic>`
**Output:** `SPEC.md`

The human writes (or is guided through) the initial specification. This is the highest-value human contribution — domain knowledge, business constraints, architectural choices that no AI can guess.

```
/spec "Inventory management app for client X — Next.js + Prisma + PostgreSQL"
```

Claude asks up to 7 targeted questions (scaled to project complexity), each with rationale and examples to help the user answer effectively. Generates SPEC.md. The human refines it.

### Phase B — Research

**Who:** Claude Code (autonomous)
**Tool:** `/research <topic>`
**Output:** `RESEARCH.md`

Claude searches official documentation, API references, best practices, and known issues for the technologies in the spec. Produces a structured dossier.

```
/research "Next.js 15 App Router + Prisma 6 + PostgreSQL 17 + NextAuth"
```

### Phase C — Generate

**Who:** Claude Code
**Tool:** Normal Claude Code session
**Input:** AGENT.md + SPEC.md + RESEARCH.md

Claude generates code following the spec and the project rules in AGENT.md. This is a normal Claude Code session — no special skill needed.

Key behaviors during generation:
- Follow the 15 hard rules in AGENT.md
- Commit after every meaningful progress
- Keep IMPLEMENTATION_NOTES.md current before commit/compaction (Rule 5)
- Do not stop to ask for confirmation

### Phase D — Cross-review

**Who:** Codex CLI (automatic)
**Tool:** Git pre-commit hook (automatic) or `/review` (manual)
**Output:** `REVIEW.md`

Codex reviews every commit automatically via the pre-commit hook. It runs in `--sandbox danger-full-access --approval-mode never` mode: it can read code, identify issues, and apply fixes directly. The hook is fail-closed: if Codex is unavailable, the review fails, or the staged diff is too large, the commit is blocked unless you bypass with `--no-verify`.

If the review finds critical unfixable issues → commit is blocked.
If minor issues are found → Codex fixes them and the commit proceeds.

For manual review at any time:
```
/review
```

### Phase E — Human verification

**Who:** Human
**Input:** Source code + REVIEW.md

The human reads the code and the review. This is non-negotiable. The AI writes, the AI reviews, but the human approves.

### Phase F — Commit

**Who:** Git (with pre-commit hook)

The commit triggers the Codex review hook automatically (Phase D). If it passes, the commit goes through with any Codex fixes included.

---

## 4. Skills

Five skills installed in the workflow. To use globally, copy to `~/.claude/skills/`.

| Skill | Invocation | Purpose |
|-------|-----------|---------|
| `/spec` | `/spec <topic>` | Guide specification creation |
| `/research` | `/research <topic>` | Autonomous documentation research |
| `/review` | `/review` | Manual cross-review with Codex |
| `/notes` | `/notes` | Manual override: update IMPLEMENTATION_NOTES.md |
| `/continue` | `/continue` | Recover context after compaction or session restart |

### Installation

```bash
# For a specific project
cp -r skills/* .claude/skills/

# For all projects (global)
cp -r skills/* ~/.claude/skills/
```

### Skill details

**`/spec <topic>`** — Guided specification creation. Claude asks up to 7 targeted questions — problem & users, acceptance criteria, out-of-scope boundaries, stack with rationale, domain truth (business rules + data), hard constraints with numbers, and pitfalls with promising directions. Each question includes WHY it matters and a concrete example of a good answer. Questions scale to project complexity — small utilities get fewer. Generates SPEC.md. Optionally scaffolds AGENT.md.

**`/research <topic>`** — Autonomous research agent. Searches official docs, API references, best practices, known issues. Produces RESEARCH.md dossier. Uses `effort: max` for thorough research.

**`/review`** — Manual Codex cross-review. Sends the project context already gathered by the skill to Codex CLI in `--sandbox danger-full-access --approval-mode never` mode. Codex can fix issues directly. Output to REVIEW.md.

**`/notes`** — Helper for updating IMPLEMENTATION_NOTES.md. Use it when you want to capture the current state explicitly (e.g., before a long break, after a design decision, or before compaction).

**`/continue`** — Context recovery after compaction or session restart. Reads AGENT.md, SPEC.md, IMPLEMENTATION_NOTES.md, RESEARCH.md, and git history. Summarizes current state and asks where to continue. **This is always the first command when resuming work.**

---

## 5. Codex integration

### How Codex is used

Codex CLI is **never used directly by the human** in this workflow. It is invoked:
1. **Automatically** by the git pre-commit hook (every commit)
2. **Manually** by the `/review` skill (when you want a review outside of a commit)

### Commands

```bash
# Full-auto review (used by hook and /review skill)
{
  printf '%s\n' "You are a senior code reviewer. Use the surrounding project context and recent diff to review the change set."
} | codex exec --model gpt-5.4 --sandbox danger-full-access --approval-mode never -o REVIEW.md -

# Quick one-shot question to Codex
codex exec --model gpt-5.4 "explain the auth flow in this project"

# Interactive Codex session (for complex exploration)
codex --model gpt-5.4
```

### AGENTS.md

If you want Codex to follow project-specific instructions (like Claude follows AGENT.md), create an `AGENTS.md` file in the project root. Codex CLI reads this automatically.

Recommendation: symlink AGENTS.md to AGENT.md to keep a single source of truth:

```bash
ln -s AGENT.md AGENTS.md
```

---

## 6. Hard rules

These rules go in every project's AGENT.md. They are the operating contract between the human and the AI agents.

### From antirez (verified from public repositories)

1. **Keep code simple and clean — no dead code.** Remove unused functions, imports, variables. Simplicity is not optional.
2. **Commit after every meaningful progress.** Don't accumulate large uncommitted changes. Each commit should be a coherent unit.
3. **Write thorough tests. Run them with the project's test runner.** Tests are not optional. Every code modification must be tested.
4. **Do not stop to ask for confirmation — the user is not at the keyboard.** Make the best decision and keep going. Log decisions in IMPLEMENTATION_NOTES.md.
5. **Maintain a work-in-progress log in IMPLEMENTATION_NOTES.md.** Update it during development, especially before commit boundaries and before context compaction. The `/notes` skill exists to make that update explicit and repeatable.
6. **Re-read AGENT.md after every context compaction.** Your first action after compaction is to reload the project rules.
7. **No additional dependencies without explicit approval.** Prefer standard library. If a dependency is needed, document why.
8. **No marginal improvements (<1%) that add complexity.** If the improvement isn't clearly worth the added complexity, skip it.
9. **Never commit unrelated or unstaged files.** Each commit is clean and focused. Stage deliberately.
10. **Read source-of-truth files before modifying.** Don't guess what a file contains — read it first.
11. **Keep AGENT.md aligned with the actual workflow and tests.** If the workflow changes, AGENT.md must be updated.
12. **Update README.md if CLI or runtime behavior changes.** User-facing changes require documentation.

### Added for consulting context

13. **Do not access the internet without explicit permission.** This prevents unintended data leakage and ensures reproducible builds.
14. **Comment code only where the logic is not self-evident.** Don't over-comment obvious code. Do comment non-obvious decisions.
15. **All project artifacts in English.** AGENT.md, SPEC.md, comments, commit messages — all in English. Conversation with the user can be in any language.

---

## 7. Hooks

### Git pre-commit hook (Codex review)

**File:** `hooks/pre-commit-review.sh`
**Install:**
```bash
cp hooks/pre-commit-review.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

**What it does:**
1. Captures `git diff --cached` (staged changes)
2. Reads AGENT.md for project context
3. Sends both to Codex CLI (`gpt-5.4`, `--sandbox danger-full-access --approval-mode never`)
4. Codex reviews and can auto-fix issues
5. Outputs verdict: PASS / WARN / FAIL
6. FAIL, Codex execution errors, or oversized diffs → commit blocked. WARN/PASS → commit proceeds.
7. Saves full review to REVIEW.md

**Configuration:**
- `CODEX_MODEL` env var overrides the model (default: `gpt-5.4`)
- `REVIEW_FILE` env var overrides the review output path (default: `REVIEW.md`)
- `MAX_DIFF_LINES` controls the max diff size before the hook blocks the commit (default: 5000)
- Worktree must be clean except for staged changes and ignored files, so Codex fixes can be re-staged safely
- `git commit --no-verify` bypasses the hook for emergencies

### Claude Code PreCompact hook

**File:** `hooks/pre-compaction.sh`
**Configure in `.claude/settings.json`:**

```json
{
  "hooks": {
    "PreCompact": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/hooks/pre-compaction.sh",
            "statusMessage": "Saving implementation notes before compaction..."
          }
        ]
      }
    ]
  }
}
```

**What it does:** Injects a reminder into the compacted context telling Claude to re-read AGENT.md and IMPLEMENTATION_NOTES.md after compaction. It does not edit the notes file for you.

### IMPLEMENTATION_NOTES discipline

IMPLEMENTATION_NOTES.md stays useful only if it is actively maintained:

1. **Rule 5 in AGENT.md** — The agent should update notes at meaningful checkpoints: before commit boundaries, before context compaction, and whenever decisions or blockers change.

2. **`/notes` skill** — Use it to generate a focused update from the current git state when you want an explicit checkpoint.

3. **PreCompact hook** — Before context compaction, the hook injects a reminder so the next session re-reads AGENT.md and IMPLEMENTATION_NOTES.md.

---

## 8. Antipatterns

| Antipattern | Why it's bad | What to do instead |
|---|---|---|
| Accepting AI output without reading it | You're vibe coding, not programming | Read every line. Question what you don't understand. |
| Skipping SPEC.md ("just start coding") | No spec = no direction = garbage output | 10 minutes on `/spec` saves hours of rework |
| Not updating IMPLEMENTATION_NOTES.md | Context compaction erases working memory | Treat notes like a required checkpoint artifact. Update them before commit/compaction, or run `/notes` explicitly. |
| Ignoring REVIEW.md | The second opinion exists for a reason | Read every review. Act on WARN and FAIL. |
| Massive uncommitted changes | Context loss, hard to review, hard to revert | Commit every meaningful progress (Rule 2) |
| Adding dependencies casually | Dependency = maintenance burden × project count | Justify in IMPLEMENTATION_NOTES.md (Rule 7) |
| Writing AGENT.md in non-English | LLMs perform measurably better with English prompts | All artifacts in English (Rule 15) |
| Using `--no-verify` habitually | Bypasses all quality gates | Emergency only. If you bypass often, your hook is misconfigured. |
| Not running `/continue` after breaks | You're working with stale context | Always `/continue` when resuming work |

---

## 9. Daily checklist

### Session start
- [ ] `cd` to project directory
- [ ] Run `/continue` to recover context
- [ ] Verify AGENT.md is current

### During work
- [ ] Follow the cycle appropriate to the work type (full for features, short for bug fixes)
- [ ] Commit regularly (small, coherent commits)
- [ ] IMPLEMENTATION_NOTES.md is current before commit/compaction (Rule 5)
- [ ] Read REVIEW.md after each commit
- [ ] After fixing a complex bug, add it to AGENT.md Known Pitfalls

### Session end
- [ ] Verify all changes are committed
- [ ] Check REVIEW.md for outstanding warnings
- [ ] (Optional) Run `/notes` if you need to capture decisions that didn't result in commits

---

## 10. Quick reference

```bash
# Phase A — Create specification
/spec "project description"

# Phase B — Research documentation
/research "technologies to research"

# Phase C — Generate code
# (normal Claude Code session)

# Phase D — Manual review (automatic review happens at commit)
/review

# Update implementation notes (manual override — normally automatic)
/notes

# Recover context after compaction or session restart
/continue

# Install pre-commit hook in a project
cp hooks/pre-commit-review.sh .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit

# Install skills globally
cp -r skills/* ~/.claude/skills/

# Bypass pre-commit hook (emergencies only)
git commit --no-verify -m "emergency fix"
```

---

## 11. Origin table

Transparency on what comes from antirez and what is our adaptation.

| Element | Source | Origin |
|---------|--------|--------|
| Philosophy: automatic vs vibe coding | antirez.com/news/159 | antirez verbatim |
| Pattern: Claude generates, Codex reviews | gist + tweet PR Redis #14661 | antirez verbatim |
| Command `cat ... \| codex exec` | gist CLAUDE_CODEX_SKILL.md | antirez verbatim |
| IMPLEMENTATION_NOTES.md with post-compaction re-read | HN comment on iris.c | antirez verbatim |
| AGENT.md as project instruction file | repos iris.c, voxtral.c, ZOT | antirez verbatim (evolved from CLAUDE.md) |
| Brain dump spec before coding | antirez.com/news/154, news/160 | antirez verbatim |
| Parallel sessions in cloned directories | tweet March 2026 | antirez verbatim |
| CLAUDE.md → AGENT.md evolution | recent repos (iris.c, qwen-asr, tgterm) | antirez verbatim |
| Rules 1-12 | CLAUDE.md/AGENT.md across repos | antirez verified |
| Skill `/spec` (interactive) | — | our adaptation |
| Skill `/research` | — | our addition (Phase B automation) |
| Skill `/notes` | — | our adaptation of antirez's IMPLEMENTATION_NOTES pattern |
| Skill `/continue` (renamed from `/resume`) | — | our adaptation of antirez's post-compaction re-read |
| Skill `/review` (Claude Code skill syntax) | gist + Claude Code docs | adaptation of gist to modern syntax |
| Git pre-commit hook with Codex | — | our addition (antirez reviews manually) |
| PreCompact hook | — | our addition (antirez uses discipline, we use automation) |
| The 6 phases A-F | implicit in antirez posts | our formalization |
| Rules 13-15 (consulting additions) | — | our additions for consulting context |
| `--sandbox danger-full-access --approval-mode never` mode for Codex | Codex CLI docs + user requirement | our choice (antirez uses default) |
| `--model gpt-5.4` explicit | user screenshot + preference | user's choice |
| AGENTS.md symlink to AGENT.md | — | our compatibility solution |
| English-only artifacts rule | antirez recommendation + LLM performance data | our formalization |
| Automatic IMPLEMENTATION_NOTES.md (Rule 5 reinforced) | antirez's WIP log pattern | our automation of antirez's manual discipline |
| Cycle variants by work type (full/short/minimal) | implicit in antirez practice | our formalization |
| Known Pitfalls accumulation pattern | iris.c, qwen-asr AGENT.md | antirez verified, our formalization as mandatory practice |

---

*Workflow 1 Coding Core v2.1 — Built on antirez's method, adapted for IT consulting at scale.*
