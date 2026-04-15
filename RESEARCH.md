# RESEARCH — Writing Specifications for AI Coding Agents

> Comprehensive research on best practices for writing specs that LLMs use to generate code.
> Sources: 30+ articles, research papers, HN discussions, tool docs (2025-2026 era).

---

## 1. The Core Insight: Context Engineering > Prompt Engineering

The industry shifted in mid-2025 from "prompt engineering" (crafting the right words) to **context engineering** (designing the right information architecture). Anthropic's engineering team defines it as finding "the smallest possible set of high-signal tokens that maximize the likelihood of some desired outcome."

Key principle: **context is a finite resource with diminishing returns**. Research shows that as context window tokens increase, the model's ability to accurately recall information decreases ("context rot"). LLMs have an "attention budget" that depletes with each token.

> "Building with language models is becoming less about finding the right words and more about answering: what configuration of context is most likely to generate the desired behavior?"
> — Anthropic, "Effective Context Engineering for AI Agents"

### The Curse of Instructions

Research confirmed that as instructions pile up, model performance in adhering to each one drops significantly. Even GPT-4 and Claude struggle when asked to satisfy many requirements simultaneously. Frontier LLMs handle ~150-200 instructions reliably; smaller models degrade exponentially. Claude Code's system prompt already contains ~50 instructions, leaving limited budget for user specs.

**Implication for specs**: modular, focused, minimal. Not a monolith.

Sources:
- [Anthropic — Effective Context Engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [Neo4j — Context Engineering vs Prompt Engineering](https://neo4j.com/blog/agentic-ai/context-engineering-vs-prompt-engineering/)
- [Elastic — Context Engineering](https://www.elastic.co/search-labs/blog/context-engineering-vs-prompt-engineering)

---

## 2. ETH Zurich Study: What Actually Works in Context Files

A 2026 ETH Zurich study tested 138 repository instances across 5,694 pull requests with 4 different agents (Claude 3.5 Sonnet, GPT-5.2, GPT-5.1 mini, Qwen Code). Findings:

| Context file type | Success rate impact | Inference cost impact |
|---|---|---|
| LLM-generated (auto) | **-3%** (worse) | **+20%** (more expensive) |
| Human-written | **+4%** (marginal gain) | **+19%** (more expensive) |
| No context file | Baseline | Baseline |

### Why LLM-generated files hurt
Agents followed instructions faithfully but *inefficiently*: excess testing, reading unnecessary files, executing additional grep searches. Thorough but wasteful — didn't improve resolution rates.

### Why human-written files barely help
Architectural overviews and repository structure explanations didn't meaningfully reduce file-location time. **The only content with clear value was non-inferable details**: highly specific tooling commands and custom build steps.

### Recommendations from the study
1. **Omit LLM-generated context files entirely**
2. Limit human-written instructions to **non-inferable details** only
3. Keep files **under 300 lines** (under 60 lines ideal, per HumanLayer)
4. Don't document what the agent can discover by reading the code

Sources:
- [MarkTechPost — ETH Zurich Study](https://www.marktechpost.com/2026/02/25/new-eth-zurich-study-proves-your-ai-coding-agents-are-failing-because-your-agents-md-files-are-too-detailed/)
- [InfoQ — Reassessing AGENTS.md](https://www.infoq.com/news/2026/03/agents-context-file-value-review/)
- [HumanLayer — Writing a Good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md)

---

## 3. The 9 Critical Failure Patterns of AI Coding Agents

Columbia University's DAPLab identified 9 failure patterns. Each one maps to specific spec content that would prevent it:

### 3.1 UI/Layout Grounding Mismatch
Agents cannot visually perceive interfaces. **Spec need**: explicit spatial coordinates, CSS grid specs, component positioning with concrete values.

### 3.2 State Management Failures
Agents lose track of shared state between components. **Spec need**: state architecture, explicit state definitions with types, component dependency maps, mutation rules.

### 3.3 Business Logic Mismatch
Agents produce syntactically correct code that implements wrong logic. **Spec need**: formal business rules with examples, decision trees, calculation formulas with test cases, boundary conditions.

### 3.4 Data Management Errors
Redundant columns, wrong field queries, schema drift. **Spec need**: complete schema documentation with relationships, field usage specs, migration rules, data validation constraints.

### 3.5 API Integration Failures
Hallucinated credentials, placeholder implementations. **Spec need**: real API endpoints, auth mechanisms, error handling requirements, request/response examples.

### 3.6 Security Vulnerabilities
Exposed keys, missing access controls (1.5-2x higher rate than human coders). **Spec need**: security requirements, role/permission matrices, data classification, credential management.

### 3.7 Code Duplication
Duplicate functions instead of abstraction. **Spec need**: shared utility inventory, architectural patterns, reuse guidelines.

### 3.8 Codebase Awareness Loss
As files grow, agents lose architectural awareness. **Spec need**: architecture docs, module dependency graphs, existing library inventory, file organization.

### 3.9 Error Suppression
Agents suppress errors to produce "runnable" code. **Spec need**: error handling requirements, logging standards, failure recovery procedures, edge case documentation.

Source:
- [DAPLab Columbia — 9 Critical Failure Patterns](https://daplab.cs.columbia.edu/general/2026/01/08/9-critical-failure-patterns-of-coding-agents.html)

---

## 4. Addy Osmani's Framework (O'Reilly, 2,500+ Agent Configs Analyzed)

### Six essential areas for agent specs

1. **Commands** — Full executable commands with flags (e.g., `npm test`, `pytest -v`)
2. **Testing** — Framework, file locations, coverage expectations
3. **Project Structure** — Explicit paths (`src/` for code, `tests/` for tests)
4. **Code Style** — One real code snippet beats three paragraphs of description
5. **Git Workflow** — Branch naming, commit formats, PR requirements
6. **Boundaries** — Critical constraints (never commit secrets, etc.)

### Three-Tier Boundary System
- **Always do** — Safe actions requiring no approval
- **Ask first** — High-impact changes needing human review
- **Never do** — Categorical prohibitions

### Spec-Driven Development Phases
1. **Specify** — Define what you're building and why (user experience focus)
2. **Plan** — Generate technical implementation approach
3. **Tasks** — Break plan into small reviewable chunks
4. **Implement** — Execute with validation at each phase

### Key finding
> "Most agent files fail because they are too vague."

The "curse of instructions" means you need to be specific but not verbose. One real code example is worth more than three paragraphs of rules.

Sources:
- [Addy Osmani — How to Write a Good Spec for AI Agents](https://addyosmani.com/blog/good-spec/)
- [O'Reilly — How to Write a Good Spec](https://www.oreilly.com/radar/how-to-write-a-good-spec-for-ai-agents/)
- [Addy Osmani — My LLM Coding Workflow Going into 2026](https://medium.com/@addyosmani/my-llm-coding-workflow-going-into-2026-52fe1681325e)

---

## 5. CLAUDE.md / AGENTS.md: What Practitioners Learned

### What MUST be in the file (per HumanLayer + practitioners)

Three sections only:
1. **WHAT** — Project structure and tech stack. Give the agent a map.
2. **WHY** — What components accomplish and their role in the system.
3. **HOW** — Build commands, test execution, verification methods.

### What MUST NOT be in the file

- Code style guidelines (use a linter instead — deterministic, faster, cheaper)
- Task-specific instructions (schemas, feature workflows — they distract during unrelated work)
- Auto-generated content (the ETH Zurich study proves this hurts)
- Anything the agent already does correctly without the instruction
- Anything the agent can infer from reading the code

### Progressive disclosure pattern

Don't tell the agent everything. Tell it **how to find** information:
```
# Architecture
See `docs/architecture.md` for component diagrams.
See `docs/api-contracts/` for API specifications.
```

Create separate files in an `agent_docs/` directory and reference them. Agent loads only what it needs, preserving context budget.

### Positioning matters
LLMs bias toward instructions at the peripheries of the prompt (beginning and end). Put critical rules at the top.

### AGENTS.md as open standard
Used by 60k+ open-source projects. Supported by 20+ tools (Claude, Codex, Cursor, Windsurf, Gemini CLI, etc.). Linux Foundation's Agentic AI Foundation adopted it as a founding project alongside MCP.

Hierarchical: nested files in subdirectories override parent. Nearest file in directory tree takes precedence. OpenAI's repo uses 88 AGENTS.md files across subcomponents.

Sources:
- [HumanLayer — Writing a Good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md)
- [AGENTS.md Specification](https://agents.md/)
- [Builder.io — Improve Your AI Code Output with AGENTS.md](https://www.builder.io/blog/agents-md)
- [JetBrains — Coding Guidelines for AI Agents](https://blog.jetbrains.com/idea/2025/05/coding-guidelines-for-your-ai-agents/)
- [Stack Overflow — Coding Guidelines for AI and People](https://stackoverflow.blog/2026/03/26/coding-guidelines-for-ai-agents-and-people-too/)

---

## 6. Spec-Driven Development Tools Compared

### GitHub Spec-Kit

Workflow: Constitution -> Specify -> Plan -> Tasks -> Implement

**Spec template sections**:
- Feature name
- Problem (what problem does this solve?)
- Users (who needs this feature?)
- Desired outcome (what should happen when it works well?)
- Functional requirements
- Non-goals (what is excluded from this version?)
- Edge cases (what could go wrong?)
- Acceptance criteria (how do we verify it's complete?)

Clarification phase: `/speckit.clarify` — sequential, coverage-based questioning that records answers.

The "constitution" file encodes project-level principles (style, test coverage, non-functional requirements). Every AI-generated plan must pass a constitutional check.

### Kiro (AWS)

Workflow: Requirements -> Design -> Tasks

- **Requirements**: User stories (As a...) with acceptance criteria (GIVEN... WHEN... THEN...)
- **Design**: Component architecture, data flow, data models, error handling, testing strategy
- **Tasks**: Implementation checklist traced back to requirement numbers

Uses EARS format (Easy Approach to Requirements Syntax) for structured, testable requirements.

### Martin Fowler's critique (spec-driven dev tools)

Three levels identified:
1. **Spec-first** — specs precede code, then discarded
2. **Spec-anchored** — specs persist for evolution
3. **Spec-as-source** — specs ARE the primary artifact; humans never edit code

Critical observations:
- Fixed workflows don't accommodate diverse problem sizes (a small bug became 4 user stories with 16 acceptance criteria — "sledgehammer to crack a nut")
- "I'd rather review code than all these markdown files" — spec tools can generate verbose overhead
- Despite comprehensive templates, agents frequently ignored or over-followed instructions
- Historical parallel to 1990s Model-Driven Development failures

Sources:
- [GitHub Blog — Spec-Driven Development](https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/)
- [GitHub Spec-Kit](https://github.com/github/spec-kit)
- [Kiro](https://kiro.dev/)
- [Martin Fowler — SDD Tools Analysis](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html)

---

## 7. BMAD Method

Breakthrough Method for Agile AI Driven Development. Multi-agent framework implementing agents as self-contained markdown files with embedded YAML configs.

### Agent roles
Analyst, Product Manager, Architect, Scrum Master, Product Owner, Developer, QA — each a specialized agent.

### Artifact chain
1. Product Brief (human + AI ideation)
2. Product Requirements Document (PRD)
3. Full-stack Architecture Document
4. Story files for development

Each artifact committed to git for auditability. The Scrum Master agent generates detailed stories ensuring "zero context loss" for Dev and QA agents.

### Key principle
Workflows are YAML-based blueprints orchestrating tasks across agents with specific sequences, dependencies, and handoff points.

Sources:
- [BMAD Method Docs](https://docs.bmad-method.org/)
- [BMAD GitHub](https://github.com/bmad-code-org/BMAD-METHOD)
- [Medium — What is BMAD-METHOD](https://medium.com/@visrow/what-is-bmad-method-a-simple-guide-to-the-future-of-ai-driven-development-412274f91419)

---

## 8. Antirez's Automatic Programming Philosophy

The Redis creator distinguishes **automatic programming** from vibe coding:

- **Vibe coding**: describe goals vaguely, accept whatever the AI generates
- **Automatic programming**: actively steer the AI with vision, detailed specs, continuous evaluation

> "Automatic programming produces vastly different results with the same LLMs depending on the human guiding the process with their intuition, design, continuous steering and idea of software."

### Key workflow principles
- Human provides vision, constraints, and detailed technical specs
- Multi-level intervention: from architecture down to individual functions
- Continuous evaluation and course correction
- "Programming is now automatic. Vision is not (yet)."

For the Z80 emulator built with Claude Code: antirez provided complete technical documentation and clear specifications. The result was successful specifically because of thorough preparation.

Sources:
- [Antirez — Automatic Programming](https://antirez.com/news/159)
- [HN Discussion](https://news.ycombinator.com/item?id=46835208)

---

## 9. Hacker News Community Insights

### "A sufficiently detailed spec is code" (HN, 2026)

> "There is no world where you input a document lacking clarity and detail and get a coding agent to reliably fill in that missing clarity."

LLMs succeed with "permutations of existing patterns" — standard CRUD, boilerplate, well-known algorithms. Novel problems requiring domain judgment remain problematic.

Senior engineers succeed because they "understand the tech and its limitations" and "ask good questions." The spec alone is insufficient; human judgment about "what happens when..." scenarios matters.

### LLM Coding Workflows (HN, 2026)

Structured workflow: "shaping specs, break into tasks, implement, then manually test." Two unresolved tensions:
1. **Spec completeness**: How detailed must specs be? Single source of truth, or enable agent self-guidance?
2. **Human oversight balance**: Iterative validation checkpoints vs. autonomous implementation?

> "LLMs often skip edge cases or take suboptimal paths when given too much autonomy."

Sources:
- [HN — A Sufficiently Detailed Spec is Code](https://news.ycombinator.com/item?id=47434047)
- [HN — LLM Coding Workflow 2026](https://news.ycombinator.com/item?id=46570115)
- [HN — Spec AI Coding](https://news.ycombinator.com/item?id=44262598)

---

## 10. Common Failure Modes When Specs Are Bad

### From IEEE Spectrum (2025-2026)
- AI coding performance plateaued then declined in 2025
- Newer model versions produced MORE counterproductive output
- Agents prioritize runnable code over correctness
- Error suppression chosen over communicating mistakes

### Specification Drift
When instructions are ambiguous, the model fills gaps with statistically likely completions. Over many interactions, small deviations compound — slight reinterpretation becomes substantially different behavior.

### What agents most commonly lack
1. **Real credentials and API keys** (they use placeholders that silently fail)
2. **Business rules and domain constraints** (they implement "likely" behavior)
3. **Schema awareness** (they create redundant/incorrect data structures)
4. **Security understanding** (1.5-2x more vulnerabilities than humans)
5. **Codebase-wide architectural awareness** (degrades with file count)
6. **Error handling philosophy** (defaults to suppression)

Sources:
- [IEEE Spectrum — AI Coding Degrades](https://spectrum.ieee.org/ai-coding-degrades)
- [Stack Overflow — Bugs Inevitable with AI Agents?](https://stackoverflow.blog/2026/01/28/are-bugs-and-incidents-inevitable-with-ai-coding-agents/)
- [Columbia DAPLab — Failure Patterns](https://daplab.cs.columbia.edu/general/2026/01/08/9-critical-failure-patterns-of-coding-agents.html)

---

## 11. Synthesized Findings: The Optimal Spec for AI Coding Agents

### Governing principles

1. **Less is more** — ETH Zurich proved that verbose specs hurt. Include only non-inferable information.
2. **Specificity over volume** — One code example > three paragraphs of rules.
3. **Modular, not monolithic** — Break into focused sections, feed only what's relevant per task.
4. **Progressive disclosure** — Tell the agent where to find info, not all the info itself.
5. **Test-driven** — Acceptance criteria are the most actionable part of any spec.
6. **Human vision is irreplaceable** — The spec encodes YOUR design decisions, not generic best practices.

### The optimal spec structure

```
# SPEC — [Project Name]

## 1. WHAT (Scope & Value)
- What problem does this solve?
- Who are the users?
- What does success look like? (observable behavior)
- What is explicitly OUT OF SCOPE for this version?

## 2. WHY (Decisions & Rationale)
- Tech stack with WHY each choice was made
- Architecture pattern and WHY it fits
- Key trade-offs acknowledged

## 3. HOW (Executable Detail)
- Commands: build, test, lint, deploy (full commands with flags)
- Project structure: explicit directory layout
- Data model: schema with relationships and constraints
- API contracts: endpoints, request/response examples
- State management: what state exists, where it lives, how it flows

## 4. CONSTRAINTS (Hard Boundaries)
- Performance targets (concrete numbers)
- Security requirements (auth, encryption, data classification)
- Compatibility (browsers, OS, versions)
- Never do: categorical prohibitions
- Ask first: high-impact actions requiring human review

## 5. BUSINESS LOGIC (Domain Truth)
- Business rules with concrete examples
- Calculation formulas with expected inputs/outputs
- Decision trees for conditional logic
- Edge cases with expected behavior

## 6. ACCEPTANCE CRITERIA (Verification)
- GIVEN... WHEN... THEN... for each feature
- Test strategy: unit, integration, e2e
- What "done" looks like (observable, testable)

## 7. DOMAIN PITFALLS (Non-Obvious Knowledge)
- Known gotchas and previous failed approaches
- Things that LOOK right but are wrong
- Environment-specific quirks
- Dependencies on external systems (real endpoints, auth methods)
```

### The optimal question list for /spec

Based on all research, these are the questions that matter most — ordered by information value:

| # | Question | Why it matters | Failure if missing |
|---|----------|---------------|-------------------|
| 1 | What problem does this solve? Who are the users? | Anchors every subsequent decision | Agent builds for wrong audience/use case |
| 2 | What does "working" look like? (acceptance criteria) | Most actionable spec content per ETH Zurich | No verification possible, agent ships plausible but wrong code |
| 3 | What is OUT OF SCOPE? | Prevents scope drift, the #1 agent problem | Agent over-builds, adds unrequested features |
| 4 | What are the exact commands to build, test, run? | Only non-inferable content that proved valuable | Agent guesses commands, wastes cycles |
| 5 | What business rules govern behavior? (with examples) | Business logic mismatch is failure pattern #3 | Agent implements statistically likely behavior instead of correct behavior |
| 6 | What data model/schema? (with relationships) | Data errors are failure pattern #4 | Redundant columns, wrong queries, schema drift |
| 7 | What tech stack and WHY? | Prevents agent from choosing different libraries | Agent hallucates dependencies or uses wrong versions |
| 8 | What are the hard constraints? (security, perf, compat) | Security vulns are 1.5-2x more common in AI code | Exposed keys, missing auth, insecure defaults |
| 9 | What has been tried before and failed? | Prevents repeating known-bad approaches | Agent rediscovers failure modes you already know |
| 10 | What external systems/APIs are involved? (real endpoints) | API failure is pattern #5 — placeholder credentials | Silent failures with hardcoded responses |

### What NOT to put in specs

1. **Generic best practices** the model already knows (DRY, SOLID, etc.)
2. **Code style rules** — use a linter, not context tokens
3. **Architectural descriptions the agent can infer** from reading the code
4. **Auto-generated content** — proven to reduce success rates by 3%
5. **Vague directives** ("build something robust", "make it scalable")
6. **Everything at once** — modular specs loaded per-task outperform monoliths

---

## 12. Key Quotes

> "Most agent files fail because they are too vague."
> — Addy Osmani, analysis of 2,500+ agent configurations

> "Never send an LLM to do a linter's job."
> — HumanLayer, CLAUDE.md best practices

> "Programming is now automatic. Vision is not (yet)."
> — antirez, creator of Redis

> "The smallest possible set of high-signal tokens that maximize the likelihood of some desired outcome."
> — Anthropic, on context engineering

> "There is no world where you input a document lacking clarity and detail and get a coding agent to reliably fill in that missing clarity."
> — HN commenter on spec completeness

> "Context files have only a marginal effect on agent behavior and are likely only desirable when manually written."
> — ETH Zurich, AGENTS.md study 2026

> "I'd rather review code than all these markdown files."
> — Martin Fowler's critique of spec-driven development tools

---

## Sources

### Primary research
- [Anthropic — Effective Context Engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [ETH Zurich / MarkTechPost — AGENTS.md Study](https://www.marktechpost.com/2026/02/25/new-eth-zurich-study-proves-your-ai-coding-agents-are-failing-because-your-agents-md-files-are-too-detailed/)
- [InfoQ — Reassessing AGENTS.md](https://www.infoq.com/news/2026/03/agents-context-file-value-review/)
- [Columbia DAPLab — 9 Failure Patterns](https://daplab.cs.columbia.edu/general/2026/01/08/9-critical-failure-patterns-of-coding-agents.html)
- [IEEE Spectrum — AI Coding Degrades](https://spectrum.ieee.org/ai-coding-degrades)
- [ArXiv — Guidelines to Prompt LLMs for Code Generation](https://arxiv.org/html/2601.13118v1)

### Practitioner guides
- [Addy Osmani — How to Write a Good Spec](https://addyosmani.com/blog/good-spec/)
- [Addy Osmani / O'Reilly](https://www.oreilly.com/radar/how-to-write-a-good-spec-for-ai-agents/)
- [HumanLayer — Writing a Good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md)
- [Stack Overflow — Coding Guidelines for AI](https://stackoverflow.blog/2026/03/26/coding-guidelines-for-ai-agents-and-people-too/)
- [Builder.io — AGENTS.md Tips](https://www.builder.io/blog/agents-md)
- [JetBrains — Coding Guidelines for AI Agents](https://blog.jetbrains.com/idea/2025/05/coding-guidelines-for-your-ai-agents/)
- [antirez — Automatic Programming](https://antirez.com/news/159)

### Tools & frameworks
- [AGENTS.md Specification](https://agents.md/)
- [GitHub Spec-Kit](https://github.com/github/spec-kit)
- [Kiro SDD](https://kiro.dev/)
- [BMAD Method](https://docs.bmad-method.org/)
- [Martin Fowler — SDD Tools Analysis](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html)

### HN discussions
- [A Sufficiently Detailed Spec is Code](https://news.ycombinator.com/item?id=47434047)
- [LLM Coding Workflow 2026](https://news.ycombinator.com/item?id=46570115)
- [Automatic Programming (antirez)](https://news.ycombinator.com/item?id=46835208)
- [Spec AI Coding](https://news.ycombinator.com/item?id=44262598)

### Standards & industry
- [Claude Code Best Practices](https://code.claude.com/docs/en/best-practices)
- [Anthropic Prompt Engineering Docs](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview)
- [GitHub Blog — Spec-Driven Development](https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/)
