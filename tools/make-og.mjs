/*
 * Renders tools/og-template.html at 1200x630 into site/assets/og.png.
 *
 * Run from a directory that can resolve @playwright/test, piping this file in so Node resolves
 * the import against that directory rather than against tools/:
 *
 *   cd ../requestdesk/web && node --input-type=module < ../../eric-patton.dev/tools/make-og.mjs
 */
import { chromium } from '@playwright/test';
import { pathToFileURL } from 'node:url';
import { resolve } from 'node:path';

const repo = process.env.SITE_REPO ?? 'C:/repos/eric-patton.dev';
const template = pathToFileURL(resolve(repo, 'tools/og-template.html')).href;
const out = resolve(repo, 'site/assets/og.png');

const browser = await chromium.launch();
const page = await browser.newPage({
  viewport: { width: 1200, height: 630 },
  deviceScaleFactor: 1,
});
await page.goto(template, { waitUntil: 'networkidle' });
await page.evaluate(() => document.fonts.ready);
await page.waitForTimeout(250);
await page.screenshot({ path: out });
await browser.close();
console.log(`wrote ${out}`);
