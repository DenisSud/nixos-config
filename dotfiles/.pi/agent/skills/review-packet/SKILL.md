---
name: review-packet
description: Generate a review packet — an HTML slide deck summarizing recent changes for validation. Trigger when the user asks for a "review packet", "pitch deck", "summary of changes", or wants to see/validate recent work before committing or deploying. Captures git changes, file structure, and key decisions in a shareable, scannable format.
---

# Review Packet

Generate a self-contained HTML "slide deck" review packet summarizing the current state of changes. The goal is to make validation fast — the reviewer should be able to scan, detect bugs, and give feedback in seconds.

## Output Location

Always write to `/tmp/review-packet.html` first, then move to timestamped filename:

```bash
mv /tmp/review-packet.html "/tmp/review-packet-$(date +%Y%m%d-%H%M%S).html"
```

**Critical**: Write the HTML with NO timestamp in the content. The timestamp goes in the *filename* via the bash move command above. The model must NEVER use a tool to get the current time — it uses `$(date +...)` in the bash command after writing the file. The model should reference its own chat context timestamp (e.g., "session started at ~14:45") as an approximation in the HTML metadata.

## Session ID Limitation

The model CANNOT discover the real pi session ID from inside the agent (the session file lives on the client side, not visible to the agent subprocess). Do NOT fabricate a session ID. Instead:

- Include the hostname (`hostname` command) as a session identifier approximation
- If the user set a session name with `/session-name <label>`, use that
- Include "session ID: unknown — use /session-name to set a memorable label before generating review packet" in the cover slide metadata

Encourage the user to set a session name for traceability: `/session-name <descriptive-name>`.

## HTML Structure

Use a single self-contained HTML file. Slide-style sections with `page-break-after: always` for print friendliness. Dark theme (reference the review packet we made earlier: `--bg: #0f1117`, `--surface: #1a1d27`, `--accent: #7c5af5`, etc.).

### Required Slides

1. **Cover** — Title, session name/hostname, approximate timestamp, tags for key changes
2. **Summary** — 1-paragraph overview of what was done, artifact count, feature list
3. **File Tree** — Full tree of new/modified files under dotfiles/nixos-config
4. **Git Status + Diff Stats** — `git status --short` and `git diff --stat` output embedded
5. **Key Changes** — For each modified/new file: path, purpose, notable content
6. **Validation Checklist** — Items marked ✅ (verifiable now) and ⏳ (pending user action post-rebuild/deploy)
7. **Next Steps** — Actionable commands the reviewer can run (rebuild, test, commit, deploy)
8. **Git Commit Command** — Pre-formatted `git add` + `git commit` based on actual status

## Git Integration

Always run these commands in the relevant directory (usually `dotfiles/` or `nixos-config/`):

```bash
git status --short
git diff --stat
```

Parse the output and incorporate into the slide deck. The diff stat tells you how many lines changed per file — use that to highlight "big" vs "small" changes.

## Content Guidelines

- **Be concrete**: Use actual file paths, actual command output, actual line counts
- **Show, don't summarize**: Instead of "several files were modified", show the actual `git diff --stat`
- **Separation of concerns**: Each slide has one job. No slide should require scrolling.
- **Actionable footer**: Every "problem" slide should have a corresponding "how to verify" or "how to fix" in the Next Steps
- **No fabricated data**: If you don't know something (e.g., real session ID, real deployment URL), say so honestly — don't invent plausible-sounding placeholders

## File Size

Target 10-20 KB for a typical review packet (3-8 modified files). Include rich formatting but don't bloat with inline assets — everything should be readable with a single HTML file open in any browser.

## After Writing

1. Confirm the file was moved to the timestamped name
2. Print the final path to the user
3. List the slide count and key sections
4. Tell the user exactly what they should look at first (usually: validation checklist + next steps)
