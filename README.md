# Codedevza AI Vault

Self-hosted [Vaultwarden](https://github.com/dani-garcia/vaultwarden) — a Bitwarden-compatible server in Rust — deployed on Railway, rebranded as **Codedevza AI Vault**. Forked from the [Railway starter](https://github.com/railwayapp-starters/vaultwarden) so we control the image version, branding and config.

Any Bitwarden client (browser extension, desktop, mobile) works — point it at our server URL.

## Layout

| File | Purpose |
|---|---|
| `Dockerfile` | Pins `vaultwarden/server` and wires Railway's `PORT` to Rocket. This is what Railway builds. |
| `docker-compose.yml` | Local dev stack: Vaultwarden + Postgres, same shape as the Railway project. |
| `.env.example` | Config reference. Copy to `.env` locally; set as Variables on Railway. |
| `branding/` | Logo sources (`src/`), `build.sh`, and the generated `web-vault/` image set copied over the stock web-vault at build. |
| `templates/` | Handlebars overrides: branded emails, admin panel, 404 page, and `scss/user.vaultwarden.scss.hbs` (custom CSS). Missing templates fall back to the binary's built-ins. |

## Branding

The image is `vaultwarden/server` with three layers of branding applied in the `Dockerfile`:

1. **Images** — `branding/web-vault/` overwrites the web-vault's logos, icons and favicons. Regenerate from the SVGs with `./branding/build.sh` (needs `rsvg-convert` + ImageMagick).
2. **Text** — every "Vaultwarden" in the compiled web-vault (page title, footer, manifest, TOTP issuer) is rewritten to "Codedevza AI Vault" with `sed`. The build fails if any remain.
3. **Templates** — `templates/` overrides email header/footer (logo inlined as base64, so it renders regardless of `DOMAIN`), the emails that mention the product name, the admin panel and 404 page. `SMTP_FROM_NAME` defaults to `Codedevza AI Vault`.

"Bitwarden" strings are left alone — the clients are Bitwarden clients and users need to recognise them.

## Organizations

`ORG_CREATION_USERS` (default baked into the image: `usama@codedevza.com`) is the only account that may create organizations; invited users get *"User not allowed to create organizations"* from the API. The **New organization** button is hidden for everyone via CSS; allowed admins go to `/#/create-organization` directly. To add admins, set the variable to a comma-separated list on Railway.

## Local dev

```bash
cp .env.example .env
docker compose up -d --build
open http://localhost:8080
```

Data persists in the `vw-data` / `pg-data` volumes. `docker compose down -v` wipes them.

## Railway

The Vaultwarden service builds from this repo (`main`). Push to `main` → Railway redeploys.

Required variables on the service:

- `DATABASE_URL` — reference the Postgres service: `${{Postgres.DATABASE_URL}}`
- `DOMAIN` — the public URL, e.g. `https://vault.codedevza.com`
- `ADMIN_TOKEN` — argon2 hash (see `.env.example`), or unset to disable `/admin`
- `SIGNUPS_ALLOWED` — `false` once accounts exist (invites still work)
- `SMTP_*` — required for invites and 2FA emails; see `.env.example`
- `ORG_CREATION_USERS` — override the baked default if more admins should create orgs

Mount a volume at `/data` — attachments, icons, RSA keys, and admin-panel overrides live there.

## Upgrading

1. Check the [release notes](https://github.com/dani-garcia/vaultwarden/releases).
2. Bump the tag in `Dockerfile` (and the `hash` command in `.env.example`).
3. Re-sync `templates/` with the new version's `src/static/templates/` (diff, re-apply the brand edits) — email/admin templates occasionally change shape.
4. `docker compose up -d --build` locally; the build's grep check will tell you if a new file mentions Vaultwarden.
5. Sanity-check login, an email (Mailpit works well locally), then push.
