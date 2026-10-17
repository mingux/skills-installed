---
name: vibe-code-audit
description: Audit a web app for the tell-tale signs that it was "vibe-coded" or AI-generated, then fix them. Covers default/preview domains, per-page metadata and social previews, missing boring pages (404, loading, empty, error states), heading/alt/sitemap hygiene, console noise and exposed dev files, bundle bloat, responsive breakage, design-system drift, and dead buttons/links. Use this skill whenever the user asks whether their app "feels vibe-coded", "looks AI-generated", "looks like AI slop", wants a polish/production-readiness pass, a "does this look professional" check, or a pre-launch QA sweep of a web app — even if they don't use the exact phrase "vibe-coded".
---

# Vibe-Code Audit

Goal: find every small detail that makes someone look at the app for five seconds and conclude "AI-generated slop" — then fix it. The bar is a production app built by a careful human. A finding counts only if a real visitor, a crawler, a link-preview bot, or a reviewer opening DevTools could notice it.

## Inputs

Work from whatever is available, in this order of preference:
1. The source repo (uploaded, in the container, or via a connected tool).
2. The live URL (fetch pages, `robots.txt`, `sitemap.xml`, OG tags, headers).
3. Screenshots — weakest; flag that coverage is partial.

If neither source nor URL is available, ask for one before starting. Identify the framework first (Next.js, Vite/React, SvelteKit, Astro, Remix, Nuxt, plain HTML…) because metadata, 404, loading and error conventions differ per framework — see `references/framework-conventions.md`.

Run `scripts/scan.sh <repo-path>` early for the mechanical checks; it greps for the common tells and lists candidates. Treat its output as leads to verify, not findings.

## Audit checklist

Work through every section. For each item record: PASS / FAIL / N/A, the evidence (file:line or URL), and the fix.

### 1. Domain and hosting tells
- Live URL or any hardcoded URL on a default/preview host: `*.vercel.app`, `*.netlify.app`, `*.pages.dev`, `*.railway.app`, `*.onrender.com`, `*.fly.dev`, `*.herokuapp.com`, `*.lovable.app`, `*.bolt.new`, `*.replit.app`/`.repl.co`, `*.web.app`/`*.firebaseapp.com`, `*.github.io`, `*.workers.dev`, `localhost`, `127.0.0.1`.
- Check `canonical`, `og:url`, sitemap entries, `metadataBase`, auth callback URLs, email templates, and env defaults — preview hosts leak there even when the main domain is custom.
- Preview deployments indexable (no `X-Robots-Tag: noindex` / robots disallow on preview).

### 2. Per-page metadata and social preview
For every route (list them from the router/file tree, not just the homepage):
- Unique `<title>` — not the framework default ("Create Next App", "Vite + React", "React App", "My App"), not identical across pages.
- Unique meta description, 50–160 chars, not lorem ipsum or a template default.
- Favicon replaced (not the Vercel triangle, Vite logo, React atom, Next.js default); include `apple-touch-icon` and, ideally, a manifest icon.
- `og:title`, `og:description`, `og:image` (1200×630, absolute URL, actually resolves), `twitter:card=summary_large_image`.
- Canonical URL per page, absolute, on the production domain, self-referencing.
- `lang` attribute on `<html>`; `theme-color` if the app has a brand color.

### 3. The boring pages
- Custom 404 that matches the design and offers a way back. Test an actually non-existent route.
- Error boundary / 500 page — no raw stack traces or framework overlays in production.
- Loading states for every async view (skeletons or spinners, no layout jump, no flash of "undefined"/"NaN"/"[object Object]").
- Empty states for every list/table/dashboard — a zero-data user should see guidance, not a blank box.
- Error messages that say what happened and what to do; no "Something went wrong", no raw API error JSON.
- Form validation: inline, specific, preserves input.
- Legal/footer basics if public-facing: privacy, terms, contact, current-year copyright that isn't hardcoded stale.

### 4. Semantic and SEO hygiene
- Exactly one `<h1>` per page; no skipped levels (h2→h4); headings not used for styling.
- Every meaningful `<img>` has descriptive alt text; decorative images have `alt=""`; no `alt="image"`.
- Icon-only buttons have `aria-label`.
- `sitemap.xml` exists, lists real production URLs, no preview host, no 404s, sensible `lastmod`.
- `robots.txt` exists and references the sitemap; doesn't accidentally block everything.
- Structured data where relevant (Organization, Product, Article).

### 5. Code and runtime leftovers
- Console errors and warnings on load and on each main interaction (hydration mismatch, key warnings, 404'd assets, CSP errors).
- Leftover `console.log`/`debugger`, TODO/FIXME visible in UI, commented-out JSX, placeholder copy ("Lorem ipsum", "Your Company", "John Doe", "example.com", "Acme").
- Exposed dev files reachable publicly: `.env*`, `.git/`, source maps (`*.map`) in production, `/api/debug`, test routes, `README` served, seed data, storybook.
- Secrets in client bundles (API keys beyond publishable ones, service-role keys).
- Bundle size: flag any JS chunk >250 kB gzipped or a total initial JS >500 kB gzipped; look for whole-library imports (lodash, moment, full icon packs, chart libs on pages that don't chart), duplicate deps, unoptimized images (>300 kB, no width/height, no modern format).

### 6. Responsive and stress testing
Test widths: 320, 375, 414, 768, 1024, 1280, 1440, 1920, plus an ultrawide (2560) and a short-height landscape phone (e.g. 740×360).
- No horizontal scroll, no clipped text, no overlapping elements, tap targets ≥ 44 px, sticky elements not covering content.
- Long content: 80-character names, long emails, unbroken URLs, 3-line titles, large numbers, non-Latin text.
- Empty data, one item, and many items (pagination/virtualisation).
- Error states rendered at mobile width too.
- Dark mode if supported: no hardcoded white backgrounds or invisible text.

### 7. Design-system drift
Compare page to page, not just within a page:
- Spacing scale: arbitrary values (`mt-[13px]`, `padding: 17px`) vs a consistent scale.
- Typography: number of distinct font families/sizes/weights; headings sized consistently across pages.
- Buttons: same variant names render identically; consistent heights, radii, hover/focus/disabled states.
- Border radius: count distinct values; >3–4 is drift.
- Icons: one icon set, consistent stroke width and size; no emoji standing in for icons in some places only.
- Colors: hardcoded hex values bypassing tokens; near-duplicate shades.
- Generic AI aesthetic tells: purple-to-blue gradients on everything, glassmorphism cards everywhere, identical three-column feature grids with emoji, "✨" in headings, centered hero with two buttons and nothing distinctive. Flag as a judgment call, not a defect.

For grep-based counting of distinct values, `scripts/scan.sh` prints frequency tables of radii, font sizes and hex colors.

### 8. Fake functionality
Click every button and link (or trace each handler in source):
- `href="#"`, `href=""`, `onClick={() => {}}`, handlers that only `console.log`, buttons with no handler.
- Nav links to routes that don't exist; footer links to nowhere; social icons linking to the platform homepage.
- Forms that "submit" without sending anything, newsletter boxes with no backend, search bars that do nothing.
- Toggles/settings that don't persist; "Forgot password" that leads nowhere; pricing CTAs not wired.
- External links missing `rel="noopener noreferrer"` with `target="_blank"`.

## Fixing

Fix every FAIL that can be fixed in code. Rules:
- Match the existing stack and conventions; don't introduce a new library to fix a small gap.
- Prefer adding a shared component/token (e.g. one `EmptyState`, one metadata helper) over patching each page differently — the fix must not itself create drift.
- Never invent production URLs, legal text or brand assets. Where these are missing, insert a clearly marked placeholder and list it under "Needs owner input".
- Don't delete code you can't prove is dead; flag instead.
- After fixing, re-run `scripts/scan.sh` and re-check the affected items.

## Output

Lead with a verdict, then a ranked list. Rank by how quickly a visitor would notice (5-second tells first), then by severity.

```
## Verdict
<Ships as human-built / Noticeable tells / Obviously vibe-coded> — <one sentence why>

## Findings (ranked)
1. [CRITICAL|HIGH|MED|LOW] <title> — <evidence: file:line or URL> — <status: FIXED / NEEDS INPUT / FLAGGED>
...

## Fixes applied
<file-by-file summary of changes>

## Needs owner input
<production domain, OG image art, legal pages, brand colors, etc.>

## Not verified
<anything that couldn't be tested — e.g. live console errors without a running app, real-device behaviour — and how to verify it>
```

Severity guide:
- CRITICAL — exposed secrets/dev files, preview domain as the public URL, broken primary CTA, production stack traces.
- HIGH — default title/favicon/OG image, no 404, blank empty states, horizontal scroll on mobile, dead nav links.
- MED — duplicate meta descriptions, heading-level skips, missing alt text, console warnings, bundle bloat, visible drift.
- LOW — minor radius/spacing inconsistencies, generic aesthetic choices, missing structured data.

Be explicit about the "Not verified" section. Claiming a clean bill of health on something that wasn't actually tested is worse than leaving it open.
