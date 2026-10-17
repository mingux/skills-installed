# Framework conventions

Where each check lives per framework. Read only the section for the detected stack.

## Next.js (App Router)
- Metadata: `export const metadata` or `generateMetadata` in each `page.tsx`/`layout.tsx`; set `metadataBase` in root layout to the production domain. Default title to replace: "Create Next App".
- OG image: `opengraph-image.(png|tsx)` per route segment, or `openGraph.images` in metadata.
- Icons: `app/icon.png`, `app/apple-icon.png`, `app/favicon.ico` (default is the Vercel/Next icon).
- 404: `app/not-found.tsx`. Errors: `app/error.tsx` (client component), `app/global-error.tsx`.
- Loading: `loading.tsx` per segment, or Suspense boundaries.
- Sitemap/robots: `app/sitemap.ts`, `app/robots.ts`.
- Bundle: `next build` output table; `@next/bundle-analyzer`. Source maps off by default (`productionBrowserSourceMaps`).

## Next.js (Pages Router)
- Metadata: `next/head` per page; `_document.tsx` for `lang`.
- 404: `pages/404.tsx`; 500: `pages/500.tsx`; `_error.tsx`.

## Vite + React (SPA)
- Single `index.html`: default title "Vite + React", default favicon `vite.svg`. Per-route titles need `react-helmet-async` or equivalent; note SPA OG tags are not seen by most link-preview bots unless prerendered/SSR — flag this.
- 404: catch-all route (`path="*"`) plus host rewrite config (`vercel.json`, `_redirects`, etc.) so deep links don't 404 at the host.
- Source maps: `build.sourcemap` in `vite.config`.
- Bundle: `vite build` output; `rollup-plugin-visualizer`.

## Create React App (legacy)
- Default title "React App", favicon React logo, `manifest.json` with "React App" name, `logo192.png`/`logo512.png`.
- `GENERATE_SOURCEMAP=false` to drop maps.

## SvelteKit
- `<svelte:head>` per page; `+error.svelte` for 404/errors; `+page.ts` load functions for loading data. `static/favicon.png` default.

## Astro
- Layout `<head>` with props per page; `src/pages/404.astro`; `@astrojs/sitemap` integration.

## Remix / React Router v7
- `meta` export per route; `ErrorBoundary` export per route; root `CatchBoundary`/`ErrorBoundary`.

## Nuxt
- `useHead`/`useSeoMeta`; `error.vue` at root; `@nuxtjs/sitemap`.

## Hosts — preview/indexing controls
- Vercel: preview deployments get `X-Robots-Tag: noindex` by default; check custom domain is primary and `*.vercel.app` redirects.
- Netlify: deploy previews on `deploy-preview-*--site.netlify.app`; set primary domain redirect.
- Cloudflare Pages: `*.pages.dev` stays live; add redirect or `noindex` header via `_headers`.
