import { Type } from "@earendil-works/pi-ai";
import type {
  ExtensionAPI,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";

const CUSTOM_CHOICE = "Type your own answer...";
const DONE_CHOICE = "Done";

const parameters = Type.Object({
  questions: Type.Array(
    Type.Object({
      question: Type.String({ description: "Complete question" }),
      header: Type.String({
        description: "Very short label (max 30 chars)",
      }),
      options: Type.Array(
        Type.Object({
          label: Type.String({
            description: "Display text (1-5 words, concise)",
          }),
          description: Type.Optional(
            Type.String({ description: "Explanation of choice" }),
          ),
        }),
        { description: "Available choices" },
      ),
      multiple: Type.Optional(
        Type.Boolean({
          description: "Allow selecting multiple choices",
        }),
      ),
      custom: Type.Optional(
        Type.Boolean({
          description: "Allow typing a custom answer (default: true)",
        }),
      ),
    }),
    { description: "Questions to ask" },
  ),
});

type QuestionPrompt = {
  question: string;
  header: string;
  options: Array<{ label: string; description?: string }>;
  multiple?: boolean;
  custom?: boolean;
};

type QuestionDetails = {
  answers: string[][];
};

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "question",
    label: "Question",
    description: `Use this tool when you need to ask the user questions during execution. This allows you to:
1. Gather user preferences or requirements
2. Clarify ambiguous instructions
3. Get decisions on implementation choices as you work
4. Offer choices to the user about what direction to take.

Usage notes:
- When \`custom\` is enabled (default), a "Type your own answer" option is added automatically; don't include "Other" or catch-all options
- Answers are returned as arrays of labels; set \`multiple: true\` to allow selecting more than one
- If you recommend a specific option, make that the first option in the list and add "(Recommended)" at the end of the label`,
    promptSnippet: "Ask the user questions with predefined options",
    promptGuidelines: [
      "Use question when requirements are ambiguous or a choice affects the implementation direction.",
      "Prefer a small number of focused questions with a few concrete options each.",
    ],
    parameters,
    executionMode: "sequential",
    async execute(_toolCallId, params, signal, _onUpdate, ctx) {
      if (!ctx.hasUI) {
        return {
          content: [
            {
              type: "text",
              text: "UI is not available (running in non-interactive mode). Proceed with your best judgment.",
            },
          ],
          details: { answers: [] } satisfies QuestionDetails,
        };
      }

      if (params.questions.length === 0) {
        throw new Error("No questions provided");
      }

      const answers: string[][] = [];
      for (const [index, item] of params.questions.entries()) {
        answers.push(
          await askOne(item, index, params.questions.length, ctx, signal),
        );
      }

      return {
        content: [
          {
            type: "text",
            text: toModelOutput(
              params.questions.map((item) => item.question),
              answers,
            ),
          },
        ],
        details: { answers } satisfies QuestionDetails,
      };
    },
  });
}

async function askOne(
  item: QuestionPrompt,
  index: number,
  total: number,
  ctx: ExtensionContext,
  signal: AbortSignal | undefined,
): Promise<string[]> {
  const title =
    total > 1
      ? `[${index + 1}/${total}] ${item.header}: ${item.question}`
      : `${item.header}: ${item.question}`;
  const customEnabled = item.custom !== false;
  if (item.multiple === true) {
    return askMultiple(title, item, customEnabled, ctx, signal);
  }
  return askSingle(title, item, customEnabled, ctx, signal);
}

async function askSingle(
  title: string,
  item: QuestionPrompt,
  customEnabled: boolean,
  ctx: ExtensionContext,
  signal: AbortSignal | undefined,
): Promise<string[]> {
  if (item.options.length === 0) {
    if (!customEnabled) return [];
    const text = await askCustom(title, ctx, signal);
    return text === undefined ? [] : [text];
  }

  const choices = item.options.map(formatOption);
  if (customEnabled) choices.push(CUSTOM_CHOICE);

  const picked = await ctx.ui.select(title, choices, dialogOptions(signal));
  if (picked === undefined) return [];
  if (picked === CUSTOM_CHOICE && customEnabled) {
    const text = await askCustom(title, ctx, signal);
    return text === undefined ? [] : [text];
  }

  const match = item.options.find((option) => formatOption(option) === picked);
  return match ? [match.label] : [];
}

async function askMultiple(
  title: string,
  item: QuestionPrompt,
  customEnabled: boolean,
  ctx: ExtensionContext,
  signal: AbortSignal | undefined,
): Promise<string[]> {
  const remaining = [...item.options];
  const picked: string[] = [];

  while (true) {
    const choices = remaining.map(formatOption);
    if (customEnabled) choices.push(CUSTOM_CHOICE);
    if (picked.length > 0) choices.push(DONE_CHOICE);
    if (choices.length === 0) return picked;

    const prompt =
      picked.length > 0
        ? `${title}\nPicked so far: ${picked.join(", ")} (select all that apply)`
        : `${title} (select all that apply)`;
    const selection = await ctx.ui.select(
      prompt,
      choices,
      dialogOptions(signal),
    );
    if (selection === undefined) return picked;
    if (selection === DONE_CHOICE) return picked;

    if (selection === CUSTOM_CHOICE && customEnabled) {
      const text = await askCustom(title, ctx, signal);
      if (text !== undefined && !picked.includes(text)) picked.push(text);
      continue;
    }

    const matchIndex = remaining.findIndex(
      (option) => formatOption(option) === selection,
    );
    if (matchIndex === -1) return picked;
    const [match] = remaining.splice(matchIndex, 1);
    if (match && !picked.includes(match.label)) picked.push(match.label);
  }
}

async function askCustom(
  title: string,
  ctx: ExtensionContext,
  signal: AbortSignal | undefined,
): Promise<string | undefined> {
  const text = await ctx.ui.input(
    title,
    "Type your answer...",
    dialogOptions(signal),
  );
  const trimmed = text?.trim();
  return trimmed ? trimmed : undefined;
}

function dialogOptions(signal: AbortSignal | undefined) {
  return signal ? { signal } : undefined;
}

function formatOption(option: { label: string; description?: string }): string {
  return option.description
    ? `${option.label} — ${option.description}`
    : option.label;
}

function toModelOutput(questions: string[], answers: string[][]): string {
  const formatted = questions
    .map(
      (question, index) =>
        `"${question}"="${answers[index]?.length ? answers[index].join(", ") : "Unanswered"}"`,
    )
    .join(", ");
  return `User has answered your questions: ${formatted}. You can now continue with the user's answers in mind.`;
}
