import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import os from "node:os";
import path from "node:path";
import fs from "node:fs/promises";

// Per-session host context, cleared on session_start so we re-read for new sessions
let hostContext: string | null = null;

/**
 * Sanitize hostname for path safety.
 * - Lowercase
 * - Strip .local / .lan suffixes
 * - Only allow [a-z0-9_-]+, otherwise refuse lookup and no-op
 */
function sanitizeHostname(raw: string): string | null {
  // Strip trailing .local / .lan
  const stripped = raw.replace(/\.(local|lan)$/i, "").toLowerCase();
  if (!/^[a-z0-9_-]+$/.test(stripped)) {
    return null;
  }
  return stripped;
}

export default function (pi: ExtensionAPI) {
  // Read host context file when session starts
  pi.on("session_start", async (event) => {
    // Re-read for startup/new/resume/fork; skip for "reload" (same session state)
    if (!["startup", "new", "resume", "fork"].includes(event.reason)) {
      return;
    }

    hostContext = null;

    const rawHostname = os.hostname();
    const hostname = sanitizeHostname(rawHostname);

    if (hostname === null) {
      console.error(
        `pi hostname-context: unsafe hostname "${rawHostname}" — skipping host context injection`
      );
      return;
    }

    const hostFilePath = path.join(os.homedir(), ".pi", "hosts", `${hostname}.md`);

    let content: string;
    try {
      content = await fs.readFile(hostFilePath, "utf8");
    } catch (err) {
      if ((err as NodeJS.ErrnoException).code === "ENOENT") {
        console.error(
          `pi hostname-context: no context file for host "${hostname}" at ${hostFilePath}`
        );
        return;
      }
      // Other error — log and skip silently
      console.error(
        `pi hostname-context: failed to read ${hostFilePath}: ${(err as Error).message}`
      );
      return;
    }

    // Trim trailing whitespace; append with clear separator
    hostContext = content.trim();
  });

  // Inject host context into system prompt at the start of each agent turn
  pi.on("before_agent_start", (event) => {
    if (!hostContext) return; // no file or error — keep default prompt

    return {
      systemPrompt: event.systemPrompt + "\n\n# Host: " + os.hostname() + "\n\n" + hostContext,
    };
  });
}