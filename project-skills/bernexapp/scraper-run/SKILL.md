---
name: scraper-run
description: Run a Bernex scraper that imports content from bernex.ch into the moderation queue, then report what was staged. Use whenever the user asks to scrape, ingest, refresh, or import bernex.ch data — news, events, or the waste calendar. Triggers include "scrape news", "run the scraper", "import events", "refresh waste schedule", "ingest from bernex.ch", "stage new articles".
---

# Run a Bernex scraper

Scrapers in `scrapers/` fetch from bernex.ch and POST to `/internal` API routes for human moderation. Nothing they ingest is published until approved in the admin.

## Available scrapers

| Command | Source | Target |
|---|---|---|
| `pnpm --filter @bernex/scrapers scrape:news` | bernex.ch news pages | `/internal/news` (staging — needs admin approval) |
| `pnpm --filter @bernex/scrapers scrape:events` | bernex.ch events | `/internal/events` (staging — needs admin approval) |
| `pnpm --filter @bernex/scrapers scrape:waste` | waste calendar PDF | `/internal/waste` (waste schedule, no moderation queue) |

## Pre-run checks

Before running, verify:

1. **API is running** at the URL the scraper expects (default `http://localhost:3001` in dev).
2. **`SCRAPER_SECRET`** is identical between `scrapers/.env` and `apps/api/.env`. Mismatch returns 401 on every POST.
3. **`DATABASE_URL`** in the API points to the right DB (dev DB for dev runs — never prod from a local scraper unless explicitly intended).

## Running

1. Ask the user which scraper to run if not specified — don't assume.
2. Run the matching `pnpm --filter @bernex/scrapers scrape:*` command.
3. Capture stdout/stderr. The scraper prints how many items it staged.

## Reporting

After the run, report:

- Number of items staged (new vs duplicate vs skipped).
- Any errors or rejected items (parse failures, validation errors from the Zod schema in `packages/shared-types`).
- The next step for the user: open the admin (`apps/admin`, port 3002) and review the moderation queue. Nothing is live yet.

## Common failures

- **401 from `/internal/*`** → `SCRAPER_SECRET` mismatch. Compare both `.env` files.
- **Connection refused** → API isn't running. Start it with `pnpm dev` from the repo root, or `pnpm --filter @bernex/api dev`.
- **Zod validation errors** → bernex.ch markup changed. The scraper's selector/parser needs updating before it can stage. Open the relevant file in `scrapers/src/` (e.g. `bernexNews.ts`, `wasteCalendar.ts`) and inspect.
- **Duplicate-skip logs** → expected; scrapers dedupe on slug/URL.
