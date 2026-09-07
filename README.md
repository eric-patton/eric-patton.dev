# eric-patton.dev

The personal site at <https://eric-patton.dev>, plus the design system it shares with the
[RequestDesk](https://github.com/eric-patton/requestdesk) demo.

Static HTML and CSS, no framework and no build step beyond copying two directories together.
It is served by nginx in a container on a Mac Mini, reached through a Cloudflare Tunnel, which
is the same arrangement that runs the RequestDesk demo on a neighbouring hostname.

## Layout

| Path | What it is |
|---|---|
| `design-system/tokens.css` | Colours, type scale, spacing, radii, motion. The only file that names a hex code. |
| `design-system/base.css` | Reset, element defaults, type and layout utilities. |
| `design-system/components.css` | Buttons, cards, chips, fields, tables. Shared with RequestDesk. |
| `site/` | The site itself: `index.html`, `404.html`, `styles.css`, `assets/`. |
| `tools/` | The Open Graph card template and the script that renders it. Not shipped. |
| `nginx/default.conf` | Static hosting, gzip, cache headers, Cloudflare client-IP logging. |

`site/styles.css` holds only page layout. Anything reusable belongs one level up in
`design-system/`, because RequestDesk imports those three files unchanged.

## The design system

The direction is **editorial technical**: a warm off-white ground rather than grey, deep ink
blue as the single accent, and rust used sparingly for section indices and mono labels. Three
type voices, each with a job:

- **Fraunces** for display headlines, the only place with personality.
- **Inter** for working UI, chosen to stay legible in a dense table.
- **IBM Plex Mono** for technical detail: counts, stack names, indices, status codes.

Everything is prefixed `--ep-` and every class is `.ep-*`, so the files drop into an application
that already carries its own variables without colliding.

Dark mode follows the system preference and can be forced either way with `data-ep-theme` on the
root element.

## Running it locally

```bash
./build.sh                                  # joins site/ and design-system/ into dist/
python -m http.server 8123 --bind 127.0.0.1 --directory dist
```

Then open <http://127.0.0.1:8123>. Or run the container the way the Mac Mini does:

```bash
docker compose up -d --build                # http://127.0.0.1:8086
```

## Regenerating the social card

`site/assets/og.png` is rendered from `tools/og-template.html`, not drawn by hand. It needs a
Playwright install; the RequestDesk checkout next door has one:

```bash
cd ../requestdesk/web && node --input-type=module < ../../eric-patton.dev/tools/make-og.mjs
```

## Deployment

The Mac Mini runs `docker compose up -d --build` from a checkout in `~/eric-patton.dev`, and
`cloudflared` maps the apex hostname to `localhost:8086`. Updating the site is a `git pull` and
the same compose command. Full runbook: `docs/hosting.md`.

## Licence

MIT. See [LICENSE](LICENSE).
