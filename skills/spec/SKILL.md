---
name: spec
description: Guide the user through creating a project specification (SPEC.md). Asks up to 7 research-backed questions scaled to project complexity, with examples and rationale for each. Generates a structured spec draft.
argument-hint: [project-topic]
allowed-tools: Read Write Bash(ls *) Bash(cat *) WebSearch WebFetch
---

# Create project specification

You are guiding the user through creating a SPEC.md for: **$ARGUMENTS**

## Step 1 — Gather context

Read AGENT.md if it exists in the current directory for additional context.

```!
cat AGENT.md 2>/dev/null || echo "No AGENT.md found"
```

## Step 2 — Ask targeted questions

Ask the user these questions **one at a time**. Wait for each answer before proceeding.
For each question, explain WHY you are asking it and give a concrete EXAMPLE of a good answer.
Adapt based on answers — skip questions already answered by context, topic argument, or previous answers.
Converse in the user's language, but write SPEC.md in English.

**Core questions (always ask 1-4):**

1. **Problem & users**: What problem does this solve? For whom? Describe a concrete scenario — a real user doing a real thing.
   _Why:_ Without a clear problem statement, the AI builds for the wrong audience or use case. Every subsequent decision anchors on this. (Spolsky scenarios, Amazon PR/FAQ, Shape Up)
   _Example:_ "A warehouse manager at client X needs to check inventory levels from a tablet while walking the floor. Currently they use a shared Excel file that's always out of date."

2. **Acceptance criteria**: What does "working" look like? Describe key behaviors as GIVEN [context] WHEN [action] THEN [result].
   _Why:_ This is the single most actionable spec content — without it, no one can verify the AI shipped correct code vs. plausible code. (ETH Zurich study, Kiro EARS, Beck TDD)
   _Example:_ "GIVEN a product with stock < 10 WHEN the manager views the dashboard THEN it shows a red low-stock alert with reorder suggestion."

3. **Out of scope**: What is explicitly NOT part of this version? What should the agent avoid building?
   _Why:_ Scope drift is the #1 agent problem — without boundaries, the AI over-builds and adds unrequested features. Every major methodology includes this: Google Non-Goals, Spolsky Nongoals, Shape Up No-Gos.
   _Example:_ "V1 does NOT include: user authentication (everyone uses a shared login), barcode scanning, export to PDF. Those are V2."

4. **Stack & commands**: What tech stack and WHY each choice? What are the exact commands to build, test, run, deploy?
   _Why:_ The ETH Zurich study proved that exact commands are the ONLY context file content with clear measurable value. And "React project" fails where "Next.js 15 with App Router because we need SSR for SEO" succeeds. (Osmani specificity principle)
   _Example:_ "Next.js 15 (App Router, SSR for SEO) + Prisma 6 + PostgreSQL 17 + Tailwind. Commands: `npm run dev`, `npm test`, `npx prisma migrate dev`, `npm run build && npm start`."

**Deep questions (ask 5-7 for complex projects; skip for small utilities/scripts):**

5. **Domain truth**: What business rules govern behavior? Give concrete examples with real values. What data entities exist and how do they relate?
   _Why:_ AI agents implement "statistically likely" behavior instead of YOUR correct behavior. Business logic mismatch and data errors are failure patterns #3 and #4 from Columbia DAPLab research.
   _Example:_ "IF order > 500 EUR AND customer is new THEN require manager approval before processing. Entities: Product (SKU, name, price, stock), Order (items, total, status), Customer (type: new/returning, credit limit)."

6. **Hard constraints**: Concrete limits — performance targets with numbers, security requirements, compatibility needs, budget, timeline?
   _Why:_ AI code has 1.5-2x more security vulnerabilities than human code. Vague "make it fast" fails; concrete "p95 < 200ms, Chrome 120+, Safari 17+" succeeds. (Columbia DAPLab failure #6, Google cross-cutting concerns)
   _Example:_ "Dashboard must load in < 2s on 4G. HTTPS only. Role-based access: viewer/editor/admin. Must work on iPad Safari 17+."

7. **Pitfalls & directions**: What looks right but is wrong? Previous failed approaches? And: any promising solution directions worth exploring?
   _Why:_ antirez insists on this — "hints about bad solutions that may look good, and why they could be suboptimal" + "hints about very good potential solutions, even if not totally elaborated." AI agents systematically fall into known traps. (antirez news/154, Shape Up Rabbit Holes)
   _Example:_ "We tried polling for real-time updates — caused too many DB queries under load. WebSocket approach looks promising. Also: the legacy API returns dates as strings in DD/MM/YYYY, not ISO 8601 — don't trust the format."

## Step 3 — Generate SPEC.md

Based on the answers, generate a complete SPEC.md with these sections (omit empty ones):

- Scope & value (problem, users, out of scope)
- Decisions & rationale (stack with WHY, architecture pattern)
- Executable detail (commands, data model, project structure)
- Hard constraints (performance, security, compatibility — with numbers)
- Business logic (rules with examples, edge cases)
- Acceptance criteria (GIVEN/WHEN/THEN, test strategy)
- Domain pitfalls (traps, failed approaches, promising directions)

Write the file to `SPEC.md` in the project root.

## Step 4 — Offer to scaffold AGENT.md

After writing SPEC.md, ask the user if they also want to generate the initial AGENT.md.
If yes, generate it using the AGENT.md template, pre-filled with information from the spec.

## Rules

- All output files must be written in English (conversation in the user's language)
- Scale the spec to the project: 30 lines for a utility, up to 150 for a complex app. Omit sections that don't apply.
- Prefer direct prose over boilerplate. No filler. One code example > three paragraphs of rules.
- If the user already has partial answers in their topic argument, acknowledge and skip those questions
