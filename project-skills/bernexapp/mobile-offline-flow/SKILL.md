---
name: mobile-offline-flow
description: Implement, debug, or extend the offline-first flow for user-submitted content in the Bernex mobile app — drafts persisted to AsyncStorage and flushed when the network returns. Use whenever the user asks about offline drafts, AsyncStorage queues, signalements offline, retry logic, or adding offline support to a new mobile feature. Triggers include "offline support", "offline queue", "AsyncStorage", "drafts when offline", "retry on reconnect", "signalement offline", "make X work offline".
---

# Bernex mobile offline-first flow

Bernex's signalement (report) flow drafts content offline and flushes on next launch. The pattern lives in `apps/mobile/lib/offlineQueue.ts` and is the template for any new offline-capable feature.

## Existing pattern (reports)

`OfflineQueue` is a singleton-style object with four operations:

- `list()` — read all queued items from AsyncStorage key `@bernex/offline_reports`.
- `enqueue(input)` — append a `QueuedReport` (id, input, queuedAt, attempts) and persist.
- `remove(id)` — drop one item.
- `flush()` — iterate the queue, POST each to `/api/reports` via `apiFetch`, increment attempts on failure, remove on success. Returns `{ sent, failed }`.

The queue stores the **typed input** (`CreateReportInput` from `@bernex/shared-types`), not a serialized request — so the Zod contract stays the source of truth even for offline data.

## Adding offline support to a new feature

1. **Pick a new AsyncStorage key** with the `@bernex/offline_<feature>` namespace.
2. **Type the queued item** using the existing `Create*Input` from `@bernex/shared-types`. Do not invent a new shape.
3. **Mirror the four operations** (`list`, `enqueue`, `remove`, `flush`) — copy `offlineQueue.ts` as the template.
4. **Wire the flush trigger**:
   - On app launch (existing flushes happen here — check the navigation root or root layout).
   - On reconnect (use NetInfo if not already wired).
   - Optionally on a manual "retry" button.
5. **Show queue status in UI** so users know drafts are pending. The reports flow already does this — copy the pattern.

## Common pitfalls

- **Don't store auth tokens** in the queue — re-auth on flush, since tokens expire while offline.
- **Cap `attempts`** (e.g. drop after 10 retries) so a permanently invalid draft doesn't loop forever. The current `OfflineQueue` increments attempts but doesn't cap them — worth fixing if you're touching it.
- **AsyncStorage is unencrypted** — never queue sensitive data (passwords, tokens, raw photos with EXIF). Photos go through `/api/upload` and the queue stores the resulting URL, not bytes.
- **Don't flush in a render path** — flushing from a screen's `useEffect` causes duplicate POSTs on remount. Flush from a single top-level effect or a background task.
- **Schema changes break queued items** — if you change `CreateReportInput`, existing queued drafts deserialize wrong on next launch. Either version the queue key or run a migration in `list()`.

## When NOT to use this pattern

- Read-only data — use a query cache (TanStack Query persistence) instead.
- Real-time features (chat, presence) — offline queueing isn't the right model.
- Large binary uploads — handle via a dedicated upload queue with resumable transfers, not generic JSON queue.
