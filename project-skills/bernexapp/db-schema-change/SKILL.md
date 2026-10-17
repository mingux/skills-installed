---
name: db-schema-change
description: Change the Bernex Prisma database schema safely and propagate the change to all consumers. Use whenever the user asks to add, modify, or remove a column, table, relation, enum, or index in the database. Triggers include "add a field to X", "new table", "change the schema", "add a column", "rename a model", "add an index", "modify the Prisma schema", "update the data model".
---

# Change the Bernex database schema

The Prisma schema is the source of truth for the DB, but the API, mobile, and admin all consume Zod types from `packages/shared-types`. A schema change without updating Zod silently breaks client validation.

## The four steps (in order)

1. **Edit the schema** in `apps/api/prisma/schema.prisma`
   - Add/modify the model, enum, or relation.
   - Match existing conventions (camelCase fields, `@id @default(cuid())`, `createdAt`/`updatedAt` timestamps, `@@index` for query patterns).

2. **Apply the change to the local DB**
   - Dev: `pnpm --filter @bernex/api db:push` (no migration file, fast iteration).
   - Production-bound change: `pnpm --filter @bernex/api db:migrate -- --name <descriptive_name>` (creates a versioned migration in `apps/api/prisma/migrations/`). Use this when the change must replay on Exoscale.
   - Both run `prisma generate` automatically; the API's `@prisma/client` types update in place.

3. **Update the Zod schema** in `packages/shared-types/src/<domain>.ts`
   - Mirror the new field/model in the matching Zod schema.
   - Update the inferred TypeScript types if column types changed (e.g. `string | null` → `string | undefined` mapping).
   - If a column became required, every place that constructs the type now needs the field.

4. **Rebuild shared types**
   - `pnpm --filter @bernex/shared-types build`
   - Then `pnpm typecheck` across the workspace to surface every consumer that needs updating (router responses, mobile screens, admin forms).

## After the four steps

- Update any seed files in `apps/api/src/seeds/` if the new column is required.
- Update routers in `apps/api/src/router/` that read or write the changed model — both the public router and any matching `internal/` (scraper) or `admin.ts` route.
- Update mobile screens / admin pages that render the changed shape.
- If the change affects scraped data, check `scrapers/` for fields it needs to populate.

## Common mistakes to avoid

- `db:push` on a production DB — use `db:migrate` for anything that must ship.
- Forgetting the shared-types rebuild — `pnpm typecheck` will pass in `apps/api` but fail in mobile/admin.
- Adding a NOT NULL column without a default to a table with existing rows — `db:push` will refuse; either add `@default(...)` or run a migration with a backfill.
- Renaming a column with `db:push` — Prisma treats it as drop + create and loses data; use a migration with a manual SQL `ALTER TABLE ... RENAME COLUMN` step.
- Updating the Zod schema but forgetting Prisma migrations — production DB diverges from types.
