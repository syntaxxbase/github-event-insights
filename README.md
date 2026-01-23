# StrongMind GitHub Push Event Ingestion Service

## Overview

This service ingests GitHub Push events from the public API, enriches them with actor and repository details, and persists them for analysis.

## Prerequisites

- Docker Desktop
- Ruby 3.3.4 (optional, for local dev)

## Implementation Details

- **Framework**: Rails 7.1 (API mode)
- **Database**: PostgreSQL
- **Background Jobs**: Sidekiq + Redis
- **Rate Limiting**: Checks `X-RateLimit-Remaining` and `X-RateLimit-Reset` headers.
- **Idempotency**: Prevents duplicate events using unique constraints on `github_id`.

## Start the System

```bash
docker compose up --build
```

This starts:

- Rails API (port 3000)
- Sidekiq (background worker)
- Postgres (port 5432)
- Redis (port 6379)

**IMPORTANT**: On the first run, you must initialize the database:

```bash
docker compose run --rm web bin/rails db:migrate
```

## Run Ingestion

To manually run the ingestion process:

```bash
docker compose run --rm ingest
```

This executes `IngestionJob.perform_now` via `rails runner`.

## Verification

### Check Logs

Watch the logs for ingestion activity:

```bash
docker compose logs -f ingest
# or
docker compose logs -f sidekiq
```

You should see:

- `Starting GitHub Event Ingestion...`
- `Found X PushEvents...`
- `Enriching actor X...`

### Verify Data

Connect to the database and check records:

```bash
docker compose exec db psql -U postgres -d active_storage_db
```

Query count of events:

```sql
SELECT count(*) FROM events;
```

Query enriched actors:

```sql
SELECT login, details FROM actors WHERE details != '{}' LIMIT 5;
```

## Running Tests

To run the test suite:

```bash
docker compose run --rm test
```
