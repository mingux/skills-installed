---
name: generate-image
description: Generate AI images from text prompts via the muapi.ai API using the local PowerShell script at C:\Dev\Open-Higgsfield-AI\generate-image.ps1. Use this whenever the user asks to generate, create, draw, render, or make an image, picture, illustration, wallpaper, logo concept, texture, or AI art — even if they don't say "AI" or name a tool. Also use when the user asks "can you make me an image of X" or wants concept art / reference imagery for a project. Do NOT use for HTML/CSS UI mockups, SVG diagrams, charts from data, or any operation on an EXISTING image file the user already has (background removal, resizing, cropping, retouching, format conversion, analysis) — this skill only creates new images from text.
---

# Generate Image (muapi.ai)

Claude has no built-in image generation. This machine has a working setup: a
PowerShell script that calls the muapi.ai REST API (submit → poll → download PNG).

## Scope check first

This pipeline creates NEW images from text descriptions — nothing else. If the
actual request is an operation on an image file that already exists (remove
background, resize, crop, upscale, convert, retouch, analyze), stop here and do
that with regular tools instead (Python/Pillow, ImageMagick). muapi does offer
editing endpoints (e.g. `ai-background-remover`, `ai-image-upscale`); if the
user wants those wired up, offer to extend `generate-image.ps1` rather than
forcing them through the text-to-image flow.

## Requirements (check before running)

1. Script exists: `C:\Dev\Open-Higgsfield-AI\generate-image.ps1`
2. API key: `$env:MUAPI_API_KEY` must be set.
   - If missing in the current shell, it may still be set at the user level:
     check `[Environment]::GetEnvironmentVariable('MUAPI_API_KEY','User')` and
     if present, copy it into the session: `$env:MUAPI_API_KEY = <that value>`.
   - If truly unset: stop and tell the user to get a key at https://muapi.ai
     and run `setx MUAPI_API_KEY "their-key"`, then retry. Never ask them to
     paste the key into chat.

## Usage

```powershell
C:\Dev\Open-Higgsfield-AI\generate-image.ps1 -Prompt "<prompt>" [-Model <model>] [-AspectRatio <ratio>] [-OutFile <path>]
```

- Default output: `C:\Dev\Open-Higgsfield-AI\generated\<timestamp>-<model>.png`
- Generation takes ~10–60 s (script polls up to 2 min).

## Model choice

| Model | Use for |
|---|---|
| `flux-schnell-image` (default) | drafts, quick iterations, cheapest |
| `flux-dev-image` | final quality, realism, detail |
| `nano-banana-pro` | strong general model, good text-in-image |
| `seedream-5.0` | detailed scenes, newest |

Pick `flux-schnell-image` for exploration, upgrade to `flux-dev-image` when the
user likes a direction. Aspect ratios: `1:1`, `16:9`, `9:16`, `4:3`, `3:4`.

## Prompt crafting

Users often give thin prompts ("a dragon"). Expand into: subject + style/medium
+ composition + lighting + mood + concrete details. Say what you changed.
Example: "a dragon" → "close-up portrait of an emerald dragon, studio product
photography, dark background, dramatic rim lighting, glistening scales, shallow
depth of field". Keep the user's explicit choices verbatim; only enrich what
they left unspecified.

## After generation

1. Read the saved PNG with the Read tool to verify it matches the request
   (right subject, no obvious artifacts). If it clearly failed, regenerate once
   with an adjusted prompt before showing it.
2. Tell the user the full file path. If asked for a specific destination,
   use `-OutFile` or copy the file there.
3. For multiple images, run the script once per image (sequential is fine).

## Failure handling

- `Generation failed` from the API: usually content filter or bad model name —
  rephrase the prompt or switch to `flux-dev-image` and retry once.
- HTTP 401/403: key invalid — tell the user to check their muapi.ai dashboard.
- `INSUFFICIENT_CREDITS` in the error body: key is fine, balance is empty —
  point the user to https://muapi.ai/topup and stop (don't retry).
- Script missing (machine changed): the API shape is
  `POST https://api.muapi.ai/api/v1/<model>` with header `x-api-key` and JSON
  body `{"prompt": "...", "aspect_ratio": "16:9"}` → returns `request_id` →
  poll `GET /api/v1/predictions/<id>/result` every 2 s until `status` is
  `completed`, then download `outputs[0]`. Recreate the script from this.
