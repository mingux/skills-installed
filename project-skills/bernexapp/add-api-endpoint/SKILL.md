---
name: add-api-endpoint
description: Add a new REST endpoint to the Bernex API end-to-end. Use whenever the user asks to add, expose, or wire up a new API route, server action, or backend endpoint that the mobile app or admin should call. Triggers include "add an endpoint", "new API route", "expose X to the app", "wire up Y from mobile", "add a backend route for Z".
---

# Add a new Bernex API endpoint

Bernex shares contracts between API, mobile, and admin via Zod schemas in `packages/shared-types`. Skipping any step here causes silent type drift between client and server.

## The four steps (in order)

1. **Define the contract** in `packages/shared-types/src/<domain>.ts`
   - Add a Zod schema for request input and response output.
   - Export inferred TypeScript types (`z.infer<typeof X>`).
   - Re-export from `packages/shared-types/src/index.ts` if the file is new.

2. **Implement the router** in `apps/api/src/router/<domain>.ts`
   - Follow the existing pattern (see `news.ts`, `events.ts`): `Router()` from Express, `prisma` from `../lib/prisma`, parse input with the shared Zod schema using `safeParse`, return the typed response.
   - Handle the unauthenticated public case and the `/internal` (scraper) or `/admin/api` (admin CRUD) cases separately if applicable — see `apps/api/src/router/internal/` and `apps/api/src/router/internal/admin.ts`.

3. **Mount the router** in `apps/api/src/index.ts`
   - Import the router at the top.
   - Mount under the matching prefix: `app.use('/api/<domain>', <domain>Router)`.
   - For internal/admin routes, mount under `/internal` or `/admin/api` instead.

4. **Wire the client call** in `apps/mobile/lib/api.ts` (and/or `apps/admin/`)
   - Use `apiFetch<ResponseType>(path, init?)` with the response type imported from `@bernex/shared-types`.
   - If the call is read-heavy and used in screens, also add a query key to `apps/mobile/lib/queryKeys.ts`.

## After the four steps

- Run `pnpm --filter @bernex/shared-types build` so mobile and admin pick up the new types.
- Run `pnpm typecheck` to verify all three apps compile against the new contract.
- If a Prisma model changed, run the `db-schema-change` skill instead of editing schema.prisma here.

## Common mistakes to avoid

- Forgetting the shared-types rebuild — mobile/admin will compile against stale types.
- Defining types inline in the router instead of in `packages/shared-types` — breaks the single source of truth.
- Mounting public routes under `/internal` — those require `SCRAPER_SECRET` and will reject app traffic.
- Returning Prisma rows directly when nullable columns differ from the Zod schema (use `?? undefined` mapping like `news.ts:34` does).
