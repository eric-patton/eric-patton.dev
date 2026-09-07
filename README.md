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

The direction is **imagery-led**, with a near-black dark theme and a cool off-white light one.
Amber is the single accent, warm against a cold ground and the colour the cover art is lit with,
with two supporting hues: ice blue as the cool counterweight in the headline gradient, lime for
anything that means live or passing.

Three type voices, each with a job:

- **Bricolage Grotesque** for display headlines, the only place with personality.
- **Inter** for working UI, legible at 13px in a dense table row.
- **JetBrains Mono** for technical detail: counts, stack names, labels, status codes.

### Theming

Every colour is declared once, as a `light-dark()` pair. The browser resolves which half applies
from the element's `color-scheme`, so switching the entire product is one attribute:

```html
<html>                       <!-- follows the operating system -->
<html data-ep-theme="light"> <!-- forced light -->
<html data-ep-theme="dark">  <!-- forced dark -->
```

No duplicated palette blocks, no class to toggle on every component, and no JavaScript at all for
the default case. `light-dark()` only accepts colours, so the few non-colour tokens that differ by
theme (shadow strength, artwork opacity) are set in two small blocks at the end of `tokens.css`,
and composite values like `box-shadow` are built from a colour token instead of being duplicated.

RequestDesk imports the same file and gets both themes from it, Angular Material included.

Everything is prefixed `--ep-` and every class is `.ep-*`, so the files drop into an application
that already carries its own variables without colliding.

### Cache busting

Assets are referenced with a `?v=<content hash>` appended at image build time by
`nginx/fingerprint-assets.sh`, and the HTML is served `no-cache`. This is not decoration: the site
once shipped a front page that looked broken because a returning visitor's browser paired freshly
fetched markup with the previous release's stylesheet, and nothing in the response told it the two
no longer belonged together.

## The artwork

`site/assets/gen/` holds seven generated pieces: the hero and six repository covers. They are a
deliberate set, dark studio photographs of abstract physical objects with one accent hue each, so
the grid reads as a series rather than six unrelated pictures.

**None of it pretends to be a screenshot.** RequestDesk and From Scratch show real captures of the
real things in browser frames. Everything else gets abstract cover art, because inventing UI
screenshots for software would be a claim a buyer could check and catch.

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
