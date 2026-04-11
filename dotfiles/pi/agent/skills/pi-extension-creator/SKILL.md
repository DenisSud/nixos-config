---
name: pi-extension-creator
description: Guide for creating/modifying pi extensions.
license: MIT
---

# Pi Extension Creator

Guide for creating and modifying pi extensions.

## Core Principle

**Reference official documentation, don't duplicate it.** This skill provides decision-making guidance and workflow steps. For API details, always read:

- `docs/extensions.md` in the pi installation
- `examples/extensions/` in the pi installation

## Quick Decision Tree

### File Structure

**Single file** (`~/.pi/agent/extensions/my-extension.ts`):
- No external npm dependencies
- Simple, focused functionality
- Easy to maintain

**Package** (`~/.pi/agent/extensions/my-extension/`):
- Needs npm packages (beyond pi's built-ins)
- Multiple helper modules
- Has `package.json` with `pi.extensions` field

**Rule:** If you remove all dependencies, convert back to single file.

### Extension Type

- **Permission gate**: Block/allow tool calls → Use `tool_call` event
- **Custom tool**: Add LLM-callable function → Use `pi.registerTool()`
- **UI customization**: Widgets, themes, footers → Use `ctx.ui.*` methods
- **Workflow automation**: Hooks into agent lifecycle → Use `agent_start`, `turn_end` events
- **Input transformation**: Rewrite user prompts → Use `input` event
- **State tracking**: Persist across turns → Store in tool result `details`

## Workflow

### 1. Read Documentation

Before writing code:
1. Read `extensions.md` (Quick Start, Events, ExtensionAPI sections)
2. Find similar example in `examples/extensions/`:
   - Permission gates: `permission-gate.ts`, `protected-paths.ts`
   - Custom tools: `todo.ts`, `tools.ts`
   - UI: `custom-footer.ts`, `widget-placement.ts`
   - Input: `input-transform.ts`

### 2. Start with Template

```typescript
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  // Subscribe to events
  pi.on("event_name", async (event, ctx) => {
    // Your logic
  });
  
  // Or register tools/commands
  pi.registerTool({ ... });
}
```

### 3. Test Iteratively

- Quick test: `pi -e ./my-extension.ts`
- Hot reload: `/reload` (if in auto-discovered location)
- Check console for load errors

### 4. Add Dependencies (Only if Needed)

1. Create directory and move file to `index.ts`
2. Create `package.json` with `pi.extensions` field (see `examples/extensions/with-deps/package.json`)
3. Run `npm install`
4. **If you remove deps later, convert back to single file**

## Essential Patterns

### Event Handling

**Always check UI availability**
```typescript
if (!ctx.hasUI) {
  return undefined; // Non-interactive mode
}
```

**Reset per-turn state**
```typescript
let yoloMode = false;
pi.on("agent_start", async () => {
  yoloMode = false; // Reset each turn
});
```

**Block tool calls**
```typescript
pi.on("tool_call", async (event, ctx) => {
  if (shouldBlock(event)) {
    return { block: true, reason: "Reason here" };
  }
  return undefined; // Allow
});
```

### UI Best Practices

**Don't truncate unless necessary**
Let TUI handle wrapping naturally. Only truncate for compact previews.

**Remove unnecessary helpers**
Don't create wrappers like `const add = (s) => lines.push(s)`. Just use `lines.push()` directly.

**For custom components, read `tui.md`**

### Custom Tools

**Use `StringEnum` for string enums**
```typescript
import { StringEnum } from "@mariozechner/pi-ai";
// Not Type.Union or Type.Literal (Google API incompatible)
```

**Truncate output (50KB/2000 lines max)**
Read `extensions.md#output-truncation` for required truncation patterns.

### State Management

Store in tool result `details` for session persistence:
```typescript
return {
  content: [{ type: "text", text: "Result" }],
  details: { myState: value } // Persisted
};
```

Reconstruct on `session_start` by reading `ctx.sessionManager.getBranch()`.

See `extensions.md#state-management` for full pattern.

## Documentation Reference

| Topic | File |
|-------|------|
| Extension API | `docs/extensions.md` |
| Events & lifecycle | `docs/extensions.md#events` |
| Custom tools | `docs/extensions.md#custom-tools` |
| UI methods | `docs/extensions.md#custom-ui` |
| TUI components | `docs/tui.md` |
| Session storage | `docs/session.md` |
| Examples | `examples/extensions/` |

All files are in the pi installation directory.

## Common Pitfalls

1. **Module not found**: Need `package.json` for npm dependencies
2. **UI in non-interactive mode**: Check `ctx.hasUI` first
3. **Blocking without reason**: Include `reason` field
4. **Missing `return undefined`**: Explicit return to allow operations
5. **Duplicating built-in preview**: Pi already shows diffs for edit/write
6. **Over-abstracting**: Keep it simple

## When to Read What

- **New extension**: `extensions.md` Quick Start, Events, ExtensionAPI
- **Custom tool**: `extensions.md#custom-tools` + `examples/extensions/tools.ts`
- **UI work**: `extensions.md#custom-ui` + `tui.md`
- **State persistence**: `extensions.md#state-management` + `session.md`
- **Stuck**: Browse similar examples in `examples/extensions/`