---
name: research
description: Autonomous documentation research agent. Given a topic (technologies, APIs, frameworks), searches official docs, best practices, and known issues, then produces a structured RESEARCH.md dossier.
argument-hint: [technologies-or-topic]
allowed-tools: Read Write WebSearch WebFetch Bash(ls *) Bash(cat *)
effort: max
---

# Research dossier for: $ARGUMENTS

## Context

```!
cat AGENTS.md 2>/dev/null || echo "No AGENTS.md found"
```

```!
cat SPEC.md 2>/dev/null || echo "No SPEC.md found"
```

## Your task

You are a technical research agent. Your job is to produce a comprehensive, structured dossier about: **$ARGUMENTS**

This dossier will be used by a coding agent (Claude Code) as reference material during implementation. It must be accurate, actionable, and cite sources.

## Research process

1. **Identify the technologies** mentioned in the topic and in SPEC.md/AGENTS.md. Resolve version conflicts with this priority: `$ARGUMENTS` > SPEC.md > AGENTS.md > "latest stable". If a conflict exists (e.g. SPEC says React 16, topic says React 19), surface it to the user before researching.
2. **Search in parallel first**: batch WebSearch queries for all identified technologies. Once you have authoritative URLs, batch WebFetch calls for those URLs. Do not invent URLs just to satisfy WebFetch, and do not research serially when the questions are independent.
3. **For each technology**, gather:
   - Official documentation (getting started, API reference, configuration)
   - Best practices and recommended patterns
   - Known issues, breaking changes, gotchas
   - Version-specific notes
4. **For integration points** between technologies:
   - How they connect (adapters, middleware, configuration)
   - Common integration patterns
   - Known compatibility issues (produce a short compatibility matrix: tech × version × notes)
5. **Cross-reference** findings to eliminate contradictions. If two authoritative sources disagree, keep both and say "Source A says X; Source B says Y — unresolved" rather than picking silently.

## Confidence labeling

Every non-trivial fact in the dossier must be prefixed with a confidence tag:
- `[HIGH]` — primary official docs, reproducible via public source
- `[MED]` — multiple independent sources agree, or recent reputable blog
- `[LOW]` — single source, older than 1 year, or inferred from examples

If a source could not be fetched, write `[UNVERIFIED: <url>]` and explain what was missing.

## Output format

Write `RESEARCH.md` in the project root with this structure:

```markdown
# Research Dossier — [Topic]

> Generated on [date]. Verify links and versions before relying on this.

## Technologies covered
- [list with versions]

## [Technology 1]
### Overview
### Key APIs / Configuration
### Best practices
### Known issues and gotchas
### Sources

## [Technology 2]
...

## Integration notes
### [Tech 1] + [Tech 2]
...

## Summary of critical findings
[Bullet list of the most important things the coding agent must know]
```

## Rules

- Converse with the user in the language specified in AGENTS.md. Write output files in English.
- Always cite sources with URLs
- Distinguish between verified facts and inferences
- If you cannot access a source, say so explicitly — do not invent content
- Write everything in English
- Prefer official documentation over blog posts or Stack Overflow
- If a technology has multiple major versions, focus on the version specified in SPEC.md or the latest stable
- Target: 200-500 lines of structured, actionable content
