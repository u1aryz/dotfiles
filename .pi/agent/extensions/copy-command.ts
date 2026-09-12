import { spawn } from "node:child_process";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

type Candidate = {
  command: string;
  language: string;
};

type TextPart = {
  type: "text";
  text: string;
};

type SessionContext = {
  sessionManager: {
    getBranch(): Array<{
      type?: unknown;
      message?: {
        role?: unknown;
        content?: unknown;
      };
    }>;
  };
};

const SHELL_LANGUAGES = new Set(["fish"]);

function isTextPart(part: unknown): part is TextPart {
  if (!part || typeof part !== "object") return false;

  const candidate = part as { type?: unknown; text?: unknown };
  return candidate.type === "text" && typeof candidate.text === "string";
}

function messageText(message: unknown): string {
  if (!message || typeof message !== "object") return "";

  const content = (message as { content?: unknown }).content;
  if (typeof content === "string") return content;
  if (!Array.isArray(content)) return "";

  return content
    .filter(isTextPart)
    .map((part) => part.text)
    .join("\n");
}

function extractCommands(markdown: string): Candidate[] {
  const candidates: Candidate[] = [];
  const fencePattern = /```([^\n`]*)\n([\s\S]*?)```/g;

  for (const match of markdown.matchAll(fencePattern)) {
    const language = (match[1] ?? "").trim().toLowerCase();
    const command = (match[2] ?? "").trim();
    if (SHELL_LANGUAGES.has(language) && command) {
      candidates.push({ command, language: language || "shell" });
    }
  }

  return candidates;
}

function latestAssistantText(ctx: SessionContext): string {
  const branch = ctx.sessionManager.getBranch();
  for (let index = branch.length - 1; index >= 0; index -= 1) {
    const entry = branch[index];
    if (entry?.type === "message" && entry.message?.role === "assistant") {
      return messageText(entry.message);
    }
  }
  return "";
}

function preview(command: string): string {
  const lines = command.split("\n");
  const firstLine = lines[0]?.trim() ?? "";
  const summary =
    firstLine.length <= 60 ? firstLine : `${firstLine.slice(0, 57)}...`;

  return lines.length === 1 ? summary : `${summary}（${lines.length}行）`;
}

async function copyToClipboard(command: string): Promise<void> {
  await new Promise<void>((resolve, reject) => {
    const child = spawn("pbcopy", [], { stdio: ["pipe", "ignore", "pipe"] });
    let stderr = "";

    child.stderr.setEncoding("utf8");
    child.stderr.on("data", (chunk: string) => {
      stderr += chunk;
    });
    child.on("error", reject);
    child.on("close", (code) => {
      if (code === 0) {
        resolve();
        return;
      }
      reject(new Error(stderr.trim() || `pbcopy exited with code ${code}`));
    });
    child.stdin.on("error", reject);
    child.stdin.end(command);
  });
}

export default function copyCommandExtension(pi: ExtensionAPI): void {
  pi.registerCommand("copy-command", {
    description: "fishで実行するコマンドをクリップボードへコピー",
    handler: async (args, ctx) => {
      let command = args.trim();

      if (!command) {
        const candidates = extractCommands(latestAssistantText(ctx));
        if (candidates.length === 0) {
          ctx.ui.notify(
            "直前の回答にfishのコードブロックがありません",
            "warning",
          );
          return;
        }

        if (candidates.length === 1) {
          command = candidates[0].command;
        } else {
          const choices = candidates.map(
            (candidate, index) =>
              `${index + 1}. [${candidate.language}] ${preview(candidate.command)}`,
          );
          const selected = await ctx.ui.select(
            "コピーするコマンドを選択",
            choices,
          );
          if (!selected) return;
          command = candidates[choices.indexOf(selected)]?.command ?? "";
        }
      }

      try {
        await copyToClipboard(command);
        ctx.ui.notify("コマンドをクリップボードへコピーしました", "info");
      } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        ctx.ui.notify(
          `クリップボードへのコピーに失敗しました: ${message}`,
          "error",
        );
      }
    },
  });
}
