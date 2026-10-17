---
name: llm-council
description: Convene an LLM council on a hard question — multiple Claude models answer independently, anonymously rank each other's answers, and a chairman synthesizes a final verdict. Use when invoked as /llm-council <question>, or when the user asks for a quick "second opinion from multiple models". (For a full structured deliberation with personas, the user runs /council instead.) Runs entirely on the user's Claude subscription via subagents — no external APIs.
user-invocable: true
---

# LLM Council

Adapted from karpathy/llm-council. Three stages, all run with the Agent tool on subscription models — never external APIs.

The question is whatever follows `/llm-council`. If it's empty, ask the user for the question and stop.

## Stage 1 — Independent answers (parallel)

Spawn THREE councillor agents **in a single message** (so they run concurrently), each with `subagent_type: "general-purpose"` and a different model:

| Councillor | model param |
|---|---|
| Councillor 1 | `opus` |
| Councillor 2 | `sonnet` |
| Councillor 3 | `haiku` |

Each councillor gets the same prompt:

> You are one member of a council of AI models answering independently. Answer the following question as well as you can. Be substantive and commit to a position — do not hedge with "it depends" unless you spell out exactly what it depends on. If the question concerns code or files in the current repository, read what you need first. Return only your answer, no preamble.
>
> QUESTION: <the question>

If the question needs repo context, append a one-paragraph summary of the relevant context to all three prompts identically, so no councillor has an information advantage.

## Stage 2 — Anonymous peer ranking (parallel)

Label the three answers **Answer A, Answer B, Answer C in random order** — do not reveal which model wrote which.

Spawn three reviewer agents in a single message (models: `opus`, `sonnet`, `haiku` again). Each gets:

> You are reviewing three anonymous answers to the same question. Rank them from best to worst on accuracy, insight, and completeness. You do not know which answer is your own — judge purely on merit. For each answer give a 1–2 sentence critique, then output your ranking as e.g. "B > A > C" with one sentence of justification.
>
> QUESTION: <the question>
> ANSWER A: <...> / ANSWER B: <...> / ANSWER C: <...>

## Stage 3 — Chairman synthesis (you)

You are the chairman. Do NOT spawn another agent for this. Using the three answers and three rankings:

1. Tally the rankings to find the consensus-best answer.
2. Write a **final synthesized answer** that leads with the strongest material, grafts in valuable points the winner missed, and drops anything a majority of reviewers criticized.
3. After the synthesis, add a short **Council report**: which model wrote each answer (de-anonymize now), the ranking tally, and any notable dissent — one reviewer strongly disagreeing with the consensus is signal worth surfacing.

## Rules

- Never call external LLM APIs (OpenRouter, OpenAI, etc.). Subscription subagents only.
- Both agent fan-outs MUST be parallel (all three Agent calls in one message per stage).
- If a councillor agent fails or returns empty, proceed with the remaining answers and note it in the report.
- Keep the final synthesis the star of the output — the report is a footer, not the headline.
