---
name: agent-reach
description: >
  Use ONLY when the user explicitly asks to read or research a specific
  social or community platform that normal web fetching can't reach well
  (e.g. "what does Reddit say about X", opinion threads, sentiment checks
  before a launch or a trade, LinkedIn job research): Reddit, Twitter/X,
  Bilibili, V2EX, XiaoHongShu, Facebook, Instagram, LinkedIn/jobs, Xueqiu
  (stocks), Xiaoyuzhou podcasts, or Exa semantic web search. Routes to the
  upstream CLI (opencli, rdt, twitter, bili, mcporter/Exa) that
  `agent-reach doctor --json` reports as the active backend.

  NOT for: plain web page URLs (use WebFetch); YouTube or other video URLs
  (the watch plugin handles those); GitHub (use gh directly); writing
  reports/analysis/translation; posting/commenting/liking (write operations);
  platforms that already have a dedicated skill installed (prefer that skill);
  general research questions where the user didn't name a platform.
metadata:
  homepage: https://github.com/Panniantong/Agent-Reach
  local-note: >
    Description trimmed from upstream SKILL_en.md (upstream claimed MUST USE
    for any research request and any URL). `agent-reach install --system` and
    `agent-reach skill --install` overwrite this file with the upstream
    version, so re-apply the trim after running either.
---

# Agent Reach — internet capability router

15 platforms, multiple backends each. For the platforms in the description,
prefer this skill's routing over inventing your own scraping approach.

## Standing rules (apply for the whole session)

1. **Health-check before acting**: for multi-backend/login-backed platforms (XiaoHongShu /
   Reddit / Bilibili / Twitter / Facebook / Instagram), run `agent-reach doctor --json` first.
   Use a populated `active_backend`; `active_backend: null` means Doctor deliberately skipped a
   live probe to avoid browser-cookie reads or remote writes, not that no backend exists. Only when
   the user's task requires that platform, run the reference's read-only command to verify it.
2. **Announce what you use**: say "using agent-reach, platform X via backend Y"
   before starting.
3. **On failure, follow the retry chains in references/** — never guess
   commands.
4. **For broad research tasks the user explicitly frames as multi-platform**:
   combine platforms (Exa for web search + Twitter/Reddit for discussions),
   collect in parallel, then synthesize.
5. **Watch versions for the user**: after finishing a substantial
   multi-platform task, run `agent-reach check-update` (fast, one API call).
   If a new version exists, append one line to the wrap-up noting the new
   version and that it can be updated via
   `uv tool upgrade agent-reach` (this machine installed it with uv, not pipx).
   Never interrupt the current task to update; never nag about the same version twice.

## Routing table

| User intent | Category | Details |
|---------|------|---------|
| Web / code search | search | [references/search.md](references/search.md) |
| XiaoHongShu / Twitter / Bilibili / V2EX / Reddit / Facebook / Instagram | social | [references/social.md](references/social.md) |
| Jobs / LinkedIn | career | [references/career.md](references/career.md) |
| GitHub / code | dev | [references/dev.md](references/dev.md) |
| Web pages / articles / RSS | web | [references/web.md](references/web.md) |
| Bilibili / podcast transcripts | video | [references/video.md](references/video.md) |
| Xueqiu / stock quotes | finance | [references/finance.md](references/finance.md) |

## Zero-config quick commands

```bash
# Exa web search
mcporter call exa.web_search_exa query="query" numResults=5

# Read any web page
curl -s "https://r.jina.ai/URL"

# GitHub search
gh search repos "query" --sort stars --limit 10

# V2EX hot topics
curl -s "https://www.v2ex.com/api/topics/hot.json" -H "User-Agent: agent-reach/1.0"

# Bilibili search (bili-cli, no login needed)
bili search "query" --type video -n 5
```

## Login-backed platforms (pick by doctor's active_backend)

Twitter boundary: cookies saved by `agent-reach configure twitter-cookies`
are used only by `doctor` to check whether explicit credentials are present.
`doctor` does not run `twitter status` or configure the current shell. Before
calling `twitter` directly, explicitly provide `TWITTER_AUTH_TOKEN` and
`TWITTER_CT0` in the child-process environment without logging their values.

XiaoHongShu boundary: Agent Reach must not log the user in or read browser
cookies. OpenCLI may use only an existing Chrome session explicitly controlled
by the user. If none exists, do not automate login; use a manual Cookie-Editor
export with xiaohongshu-mcp or a legacy tool instead.

```bash
# Twitter search (twitter-cli preferred; retry chain in social.md)
twitter search "query" -n 10

# Reddit (NO zero-config path — OpenCLI or rdt-cli, login required)
opencli reddit search "query" -f yaml   # desktop
rdt search "query" --limit 10            # legacy/server

# XiaoHongShu (desktop prefers OpenCLI)
opencli xiaohongshu search "query" -f yaml

# Facebook / Instagram (desktop OpenCLI, browser session)
opencli facebook search "query" -f yaml
opencli facebook groups -f yaml
opencli instagram search "query" -f yaml       # user search
opencli instagram user USERNAME -f yaml        # recent posts from one user
```

## Environment check

```bash
# Channel availability + which backend serves each platform
agent-reach doctor --json
```

## Discovering OpenCLI adapters

When the routing table lacks a needed platform or command, run `opencli list`,
then inspect `opencli <platform> --help`. Discovery proves only that an adapter
exists, not that authentication or target content works. Run read-only commands
only when the user's task requires that platform, and require non-empty content.

## Workspace rules

**Never create files in the project workspace.** Use the session scratchpad
directory for temporary output (on this Windows machine `/tmp/` may not map
where you expect) and `~/.agent-reach/` for persistent data.

## Detailed references

Read the matching file when you need specifics (commands above cover the
common cases; references hold per-backend command groups, caveats, retry
chains — note: reference docs are written in Chinese, commands are universal):

- [Search](references/search.md) — Exa AI search
- [Social](references/social.md) — XiaoHongShu, Twitter, Bilibili, V2EX, Reddit, Facebook, Instagram (multi-backend/login-backed groups)
- [Career](references/career.md) — LinkedIn
- [Dev](references/dev.md) — GitHub CLI
- [Web](references/web.md) — Jina Reader, RSS
- [Video](references/video.md) — Bilibili, Xiaoyuzhou
- [Finance](references/finance.md) — Xueqiu quotes, search and market content

## Configure a channel

Channel setup (cookies, extensions, system installs) changes the user's
machine or accounts — ask the user before running any `agent-reach install
--system` or `agent-reach configure` command. Setup guide:
https://raw.githubusercontent.com/Panniantong/agent-reach/main/docs/install.md
