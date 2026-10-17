#!/usr/bin/env bash
# Static scan for common vibe-coding tells. Output = leads to verify, not findings.
# Usage: scan.sh <repo-path>
set -u
ROOT="${1:-.}"
cd "$ROOT" || { echo "No such dir: $ROOT"; exit 1; }

EXCL="--exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next --exclude-dir=dist --exclude-dir=build --exclude-dir=.svelte-kit --exclude-dir=.astro --exclude-dir=.output --exclude-dir=coverage --exclude=*.lock --exclude=package-lock.json --exclude=*.min.js"
SRC="--include=*.js --include=*.jsx --include=*.ts --include=*.tsx --include=*.vue --include=*.svelte --include=*.astro --include=*.html --include=*.css --include=*.scss --include=*.json --include=*.md --include=*.mdx --include=*.toml --include=*.yml --include=*.yaml --include=*.env*"

section() { printf '\n==== %s ====\n' "$1"; }
g() { grep -rnI $EXCL $SRC -E "$@" . 2>/dev/null | head -n 40; }

section "Preview / default hosts"
g '([a-z0-9-]+\.)(vercel\.app|netlify\.app|pages\.dev|railway\.app|onrender\.com|fly\.dev|herokuapp\.com|lovable\.app|bolt\.new|replit\.app|repl\.co|web\.app|firebaseapp\.com|github\.io|workers\.dev)|https?://(localhost|127\.0\.0\.1)'

section "Framework default titles / names"
g 'Create Next App|Vite \+ React|React App|Vite \+ Vue|SvelteKit app|Welcome to Astro|My App|Untitled'

section "Default favicon / starter assets present"
find . -path ./node_modules -prune -o \( -name 'vite.svg' -o -name 'next.svg' -o -name 'vercel.svg' -o -name 'react.svg' -o -name 'logo192.png' -o -name 'logo512.png' -o -name 'file.svg' -o -name 'globe.svg' -o -name 'window.svg' \) -print 2>/dev/null

section "Placeholder copy"
g -i 'lorem ipsum|your company|john doe|jane doe|acme( inc| corp)?|example\.com|placeholder text|coming soon|TODO|FIXME|XXX|HACK'

section "Console / debugger leftovers"
g 'console\.(log|debug|info|table|dir)\(|\bdebugger\b' --include=*.js --include=*.jsx --include=*.ts --include=*.tsx --include=*.vue --include=*.svelte

section "Dead links / no-op handlers"
g 'href=["'"'"'](#|)["'"'"']|href=\{["'"'"']#["'"'"']\}|onClick=\{\s*\(\)\s*=>\s*\{\s*\}\s*\}|onClick=\{\s*\(\)\s*=>\s*console\.'

section "target=_blank without rel"
grep -rnI $EXCL $SRC -E 'target=["'"'"']_blank' . 2>/dev/null | grep -v 'noopener' | head -n 30

section "Images: missing or lazy alt"
grep -rnI $EXCL $SRC -E '<(img|Image)\b' . 2>/dev/null | grep -v 'alt=' | head -n 30
g -i 'alt=["'"'"'](image|img|photo|picture|icon|logo)["'"'"']'

section "Icon-only buttons possibly missing aria-label (heuristic)"
grep -rnI $EXCL $SRC -E '<button[^>]*>\s*<(svg|[A-Z][A-Za-z]*Icon|Icon)' . 2>/dev/null | grep -v 'aria-label' | head -n 30

section "Heading tags count per file (h1 should be 1 per page)"
grep -roI $EXCL $SRC -E '<h1\b' . 2>/dev/null | cut -d: -f1 | sort | uniq -c | awk '$1>1' | head -n 30

section "Env / dev files that might be committed or served"
find . -path ./node_modules -prune -o \( -name '.env' -o -name '.env.local' -o -name '.env.production' -o -name '*.map' -o -name '*.sql' -o -name '*.sqlite' -o -name 'seed*.json' \) -print 2>/dev/null | grep -v node_modules | head -n 30
[ -d public ] && find public \( -name '.env*' -o -name '*.map' -o -name '*.bak' -o -name '*.log' \) -print 2>/dev/null

section "Possible secrets in client code"
g '(sk_live_|sk_test_|service_role|SUPABASE_SERVICE|OPENAI_API_KEY|ANTHROPIC_API_KEY|AKIA[0-9A-Z]{16}|-----BEGIN (RSA |EC )?PRIVATE KEY)'

section "Metadata / SEO files"
for f in public/robots.txt public/sitemap.xml app/robots.ts app/sitemap.ts src/app/robots.ts src/app/sitemap.ts static/robots.txt; do [ -e "$f" ] && echo "found: $f"; done
for f in app/not-found.tsx src/app/not-found.tsx pages/404.tsx src/pages/404.tsx src/pages/404.astro src/routes/+error.svelte error.vue app/error.tsx src/app/error.tsx; do [ -e "$f" ] && echo "found: $f"; done
echo "(missing entries above = candidate gaps; verify per framework)"

section "Design drift: distinct border-radius values"
grep -rhoI $EXCL $SRC -E 'rounded(-[a-z0-9]+)?(-\[[^]]+\])?|border-radius:\s*[^;]+' . 2>/dev/null | sort | uniq -c | sort -rn | head -n 20

section "Design drift: arbitrary Tailwind values"
grep -rhoI $EXCL $SRC -E '\b(m|p|mt|mb|ml|mr|mx|my|pt|pb|pl|pr|px|py|gap|w|h|text|leading|tracking)-\[[^]]+\]' . 2>/dev/null | sort | uniq -c | sort -rn | head -n 25

section "Design drift: raw font sizes"
grep -rhoI $EXCL $SRC -E 'font-size:\s*[^;]+|text-(xs|sm|base|lg|xl|[2-9]xl)\b' . 2>/dev/null | sort | uniq -c | sort -rn | head -n 20

section "Design drift: hardcoded hex colors (top 25)"
grep -rhoI $EXCL $SRC -E '#[0-9a-fA-F]{6}\b|#[0-9a-fA-F]{3}\b' . 2>/dev/null | tr 'A-F' 'a-f' | sort | uniq -c | sort -rn | head -n 25

section "Font families declared"
grep -rhoI $EXCL $SRC -E "font-family:\s*[^;]+|next/font/google['\"]?\)?|from ['\"]next/font/google['\"]|fonts\.googleapis\.com/css2\?family=[^&\"']+" . 2>/dev/null | sort | uniq -c | sort -rn | head -n 15

section "Heavy imports"
g "from ['\"](lodash|moment|@mui/icons-material|react-icons|chart\.js|three|@fortawesome/fontawesome-free)['\"]|import \* as [A-Za-z]+ from ['\"](lucide-react|react-icons/[a-z]+)['\"]"

section "Large images in public/static (>300 kB)"
find . -path ./node_modules -prune -o \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.gif' \) -size +300k -print 2>/dev/null | head -n 20

echo
echo "Done. Verify each lead in context before reporting it as a finding."
