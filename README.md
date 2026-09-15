# Vaultwarden (CodeDevza)

Self-hosted [Vaultwarden](https://github.com/dani-garcia/vaultwarden) — a Bitwarden-compatible server in Rust — deployed on Railway. Forked from the [Railway starter](https://github.com/railwayapp-starters/vaultwarden) so we control the image version and config.

## Layout

| File | Purpose |
|---|---|
| `Dockerfile` | Pins `vaultwarden/server` and wires Railway's `PORT` to Rocket. This is what Railway builds. |
| `docker-compose.yml` | Local dev stack: Vaultwarden + Postgres, same shape as the Railway project. |
| `.env.example` | Config reference. Copy to `.env` locally; set as Variables on Railway. |

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
- `SIGNUPS_ALLOWED` — `false` once accounts exist

Mount a volume at `/data` — attachments, icons, RSA keys, and admin-panel overrides live there.

## Upgrading

1. Check the [release notes](https://github.com/dani-garcia/vaultwarden/releases).
2. Bump the tag in `Dockerfile` (and the `hash` command in `.env.example`).
3. `docker compose up -d --build` locally, sanity-check, push.
