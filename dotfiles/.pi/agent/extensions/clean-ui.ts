import type { AssistantMessage } from "@mariozechner/pi-ai";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@mariozechner/pi-tui";

export default function (pi: ExtensionAPI) {
	pi.on("session_start", async (_event, ctx) => {
		if (!ctx.hasUI) return;

		// ── 1. Kill the header — no keybinding hints, no logo ──
		ctx.ui.setHeader(() => ({
			render(_width: number): string[] {
				return [];
			},
			invalidate() {},
		}));

		// ── 2. Compact footer — single line, all signal ──
		ctx.ui.setFooter((tui, theme, footerData) => {
			const unsub = footerData.onBranchChange(() => tui.requestRender());

			return {
				dispose: unsub,
				invalidate() {},
				render(width: number): string[] {
					// Token usage across all entries
					let totalInput = 0;
					let totalOutput = 0;
					let totalCost = 0;
					for (const e of ctx.sessionManager.getEntries()) {
						if (e.type === "message" && e.message.role === "assistant") {
							const m = e.message as AssistantMessage;
							totalInput += m.usage.input;
							totalOutput += m.usage.output;
							totalCost += m.usage.cost.total;
						}
					}

					const fmt = (n: number) =>
						n < 1000 ? `${n}` : `${(n / 1000).toFixed(1)}k`;

					// Context usage
					const contextUsage = ctx.getContextUsage();
					const contextWindow =
						contextUsage?.contextWindow ?? ctx.model?.contextWindow ?? 0;
					const pct = contextUsage?.percent ?? 0;
					const pctStr =
						contextUsage?.percent !== null ? pct.toFixed(1) : "?";

					let ctxDisplay: string;
					if (pct > 90) {
						ctxDisplay = theme.fg(
							"error",
							`${pctStr}%/${fmt(contextWindow)}`,
						);
					} else if (pct > 70) {
						ctxDisplay = theme.fg(
							"warning",
							`${pctStr}%/${fmt(contextWindow)}`,
						);
					} else {
						ctxDisplay = `${pctStr}%/${fmt(contextWindow)}`;
					}

					// PWD + branch
					const home = process.env.HOME || process.env.USERPROFILE;
					let pwd = process.cwd();
					if (home && pwd.startsWith(home))
						pwd = `~${pwd.slice(home.length)}`;
					const branch = footerData.getGitBranch();
					const pwdDisplay = branch ? `${pwd}:${branch}` : pwd;

					// Model
					const modelId = ctx.model?.id || "no-model";
					const provider = ctx.model?.provider;
					const thinking = pi.getThinkingLevel();
					let modelStr = modelId;
					if (thinking !== "off" && ctx.model?.reasoning) {
						modelStr += ` · ${thinking}`;
					}
					if (
						footerData.getAvailableProviderCount() > 1 &&
						provider
					) {
						modelStr = `${provider} ${modelStr}`;
					}

					// Left side: pwd · tokens · ctx
					const dim = (s: string) => theme.fg("dim", s);
					const muted = (s: string) => theme.fg("muted", s);
					const dot = dim("·");

					const leftParts: string[] = [];
					leftParts.push(muted(pwdDisplay));
					if (totalInput || totalOutput) {
						leftParts.push(
							dim(`↑${fmt(totalInput)}↓${fmt(totalOutput)}`),
						);
					}
					if (totalCost > 0) {
						leftParts.push(dim(`$${totalCost.toFixed(3)}`));
					}
					leftParts.push(dim(ctxDisplay));

					const leftRaw = leftParts.join(` ${dot} `);
					const rightRaw = dim(modelStr);
					const rightWidth = visibleWidth(rightRaw);

					// Truncate left if necessary
					const maxLeft = width - rightWidth - 2;
					const left =
						visibleWidth(leftRaw) > maxLeft
							? truncateToWidth(leftRaw, maxLeft, dim("…"))
							: leftRaw;

					const pad = Math.max(
						1,
						width - visibleWidth(left) - rightWidth,
					);
					return [left + " ".repeat(pad) + rightRaw];
				},
			};
		});

		// ── 3. Resource widget above editor ──
		ctx.ui.setWidget("resources", (_tui, theme) => {
			const commands = pi.getCommands();
			const skills = commands.filter((c) => c.source === "skill");
			const prompts = commands.filter((c) => c.source === "prompt");

			if (skills.length === 0 && prompts.length === 0) {
				return { render: () => [], invalidate: () => {} };
			}

			const dim = (s: string) => theme.fg("dim", s);
			const muted = (s: string) => theme.fg("muted", s);
			const sep = dim("·");

			const lines: string[] = [];

			if (skills.length > 0) {
				lines.push(
					muted("skills") +
						" " +
						skills.map((s) => dim(s.name)).join(` ${sep} `),
				);
			}
			if (prompts.length > 0) {
				lines.push(
					muted("prompts") +
						" " +
						prompts
							.map((p) => dim(`/${p.name}`))
							.join(` ${sep} `),
				);
			}

			return { render: () => lines, invalidate: () => {} };
		});
	});
}