---
name: pre-deploy-check
description: Verify the Bernex deploy checklist before shipping the API, mobile app, or admin to production. Use whenever the user asks to deploy, ship, release, push to production, build for production, prepare a release, or run pre-flight checks. Triggers include "deploy", "ship it", "release", "production build", "ready to deploy", "pre-deploy check", "deploy checklist".
---

# Bernex pre-deploy verification

Run through this list before any production deploy. Bernex has Swiss data residency requirements and several env vars that silently break things if misconfigured.

## Checklist

For each item, check the relevant config and report PASS/FAIL with the actual value seen (redact secrets — show only host/length, not full value).

### Data residency (hard requirement)

1. **`DATABASE_URL`** points to Exoscale ch-gva-2 (Geneva)
   - Check `apps/api/.env` and any deploy config (Terraform in `infra/`, CI secrets).
   - FAIL if the host is AWS, GCP, Azure, or any non-CH region. This violates the residency rule in CLAUDE.md.

2. **`REDIS_URL`** points to Exoscale ch-gva-2
   - Same rule as DATABASE_URL.

3. **`STORAGE_ENDPOINT`** is a Swiss object storage host
   - Default in `.env.example` is Infomaniak (`s3.swiss-object-storage.infomaniak.com`) — anything else needs explicit confirmation.
   - `STORAGE_BUCKET`, `STORAGE_ACCESS_KEY`, `STORAGE_SECRET_KEY` are all set (non-empty).

### Push notifications

4. **`EXPO_ACCESS_TOKEN`** is set (non-empty)
   - Without it, push fan-out from `apps/api/src/workers/pushFanout.ts` silently fails.

### Scraper integration

5. **`SCRAPER_SECRET`** is set and identical between API and `scrapers/`
   - Both sides read it; mismatch causes 401 on `/internal` routes.

### Mobile / store submission

6. **Privacy policy URL** in `apps/mobile/app.json` under `extra.privacyPolicyUrl`
   - Required by Apple and Google review.

7. **`apps/mobile/eas.json` `submit.production`** has real Apple/Google IDs
   - The committed file uses placeholders (`TODO_APP_STORE_ID`, `TODO_TEAM_ID`). FAIL if any value still starts with `TODO_`.
   - `serviceAccountKeyPath` file actually exists on the build machine.

### Build sanity

8. `pnpm typecheck` passes across the workspace.
9. `pnpm test` passes (requires Postgres + Redis running).
10. `pnpm --filter @bernex/shared-types build` has been run since the last schema change (no stale `dist/`).

## Output format

Report as a markdown checklist with PASS/FAIL/SKIP per item, then a one-line verdict: SHIP or BLOCK.
Do NOT proceed with any deploy command — only verify and report. The user runs the actual deploy.
