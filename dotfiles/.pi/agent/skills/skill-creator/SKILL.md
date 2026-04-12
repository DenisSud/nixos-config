---
name: skill-creator
description: Create or improve a skill from the current conversation. Use at the end of a session where the agent completed a task (possibly with failures and retries) and the user wants to capture that knowledge as a reusable skill. Also use when the user explicitly asks to create, write, or improve a skill.
---

# Skill Creator

Extract reusable operational knowledge from the current conversation and compress it into a SKILL.md.

The core idea: by the time this skill is invoked, the conversation already contains everything needed — the steps that worked, the things that failed, the environment-specific details, the validation that confirmed success. Your job is to distill that into something a future agent can follow without needing to rediscover any of it.

---

## When this skill is invoked

Two common entry points:

**End-of-session capture** — The user just finished a task (possibly with failures and retries) and wants to turn the session into a reusable skill. The conversation is your primary source. Don't ask the user to re-explain things you can infer from the transcript.

**Fresh skill creation** — The user wants to define a skill for a task that hasn't been done yet. In this case, interview them to extract the steps, failure modes, and environment details before writing anything.

---

## Step 1: Extract from the conversation

Before writing anything, read the conversation and identify:

- **The task** — what was the user ultimately trying to accomplish?
- **The successful path** — which sequence of steps actually worked?
- **Failures and recoveries** — what went wrong, and how was it resolved? Only document failures that are meaningful — ones where the fix is non-obvious or where a future agent would likely hit the same wall.
- **Environment specifics** — host addresses, file paths, service names, config locations, tool versions. These are often implicit in the conversation; make them explicit in the skill.
- **Validation** — how did the user confirm success? What did a good outcome look like?

If anything critical is ambiguous or missing, ask the user to fill the gap. Keep it targeted — one or two questions at most.

---

## Step 2: Choose the right structure

Scale the skill's structure to the complexity of the task.

**Simple tasks** (1-5 steps, low failure risk) — a format spec and a numbered steps list is enough. See the `commit` skill as a reference. Keep it under ~50 lines.

**Complex tasks** (multi-step, ordering constraints, real failure modes, environment-specific config) — use named sections. A deploy or migration skill might need:

```
## Environment
## Pre-flight checks
## Steps
## Rollback / failure handling
## Validation
```

The test for complexity: would a future agent need to make non-obvious decisions during execution? If yes, the skill needs to encode those decision points explicitly.

Don't default to the complex structure just because the current conversation was messy. A messy session can still produce a clean, simple skill if the underlying task is straightforward.

---

## Step 3: Write the SKILL.md

### Frontmatter

```yaml
---
name: skill-name
description: What this skill does and when to trigger it. Be specific enough that the agent reliably picks it up. Mention key trigger phrases.
---
```

Make the description slightly "pushy" — err toward over-triggering rather than under-triggering. E.g. instead of "Deploy the Django app", write "Deploy the Django app to production. Use whenever the user mentions deploying, releasing, pushing to prod, or restarting the service."

### Body

Write in imperative form. Prefer explaining *why* a step matters over just listing what to do — this lets the agent handle edge cases the skill didn't anticipate.

Document failure modes inline with the step they belong to, not in a separate section (unless there are many). Example:

```markdown
3. Run migrations: `python manage.py migrate`
   - Run `showmigrations` first and show the pending list to the user before applying.
   - If this fails mid-way, do NOT restart the service — tell the user and wait for instructions.
```

Keep the skill as short as it can be while remaining complete. If you find yourself writing long prose, ask whether the agent actually needs that context or whether a shorter instruction would suffice.

### Validation section

Always include a validation step or acceptance criteria at the end — even for simple skills. This is often the most valuable part, since it's what confirms the task actually succeeded.

---

## Step 4: Save the skill

Skills live at:
```
~/nixos-config/dotfiles/.pi/agent/skills/<skill-name>/SKILL.md
```

If the skill has bundled resources (reusable scripts, reference configs, templates), save them as subdirectories:
```
skills/<skill-name>/
├── SKILL.md
└── scripts/   ← only if there's genuinely reusable code worth bundling
```

Don't create subdirectories speculatively — only if there's something concrete to put in them.

After saving, tell the user the skill path and give a one-line summary of what it captures.

---

## Improving an existing skill

If the user wants to update a skill after a new session where something changed or broke:

1. Read the existing skill
2. Read the new conversation for what changed
3. Update only what's different — don't rewrite things that still hold
4. If a previously-documented failure mode was resolved, update or remove it
5. If a new failure mode appeared, add it inline with the relevant step

Preserve the original skill's name and directory.
