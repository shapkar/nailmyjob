# NailMyJob Environment Variables

This document lists all environment variables used by the NailMyJob application.

## Required Variables

These variables **must** be set for the application to run in production.

### Database

| Variable | Description | Example |
|----------|-------------|---------|
| `DATABASE_HOST` | PostgreSQL host | `db` or `localhost` |
| `DATABASE_PORT` | PostgreSQL port | `5432` |
| `DATABASE_USERNAME` | PostgreSQL username | `nailmyjob` |
| `DATABASE_PASSWORD` | PostgreSQL password | `secure-password` |
| `DATABASE_URL` | Full database URL (alternative) | `postgres://user:pass@host:5432/db` |

### Rails

| Variable | Description | Example |
|----------|-------------|---------|
| `SECRET_KEY_BASE` | Rails secret key (generate with `rails secret`) | `abc123...` |
| `RAILS_ENV` | Rails environment | `production` |
| `RAILS_LOG_LEVEL` | Log level | `info` |
| `RAILS_SERVE_STATIC_FILES` | Serve static files | `true` |
| `RAILS_LOG_TO_STDOUT` | Log to stdout for Docker | `true` |

### Redis

| Variable | Description | Example |
|----------|-------------|---------|
| `REDIS_URL` | Redis connection URL | `redis://redis:6379/0` |

### Application

| Variable | Description | Example |
|----------|-------------|---------|
| `APP_HOST` | Application hostname (for email links) | `app.nailmyjob.com` |

---

## Email (Mailgun)

| Variable | Description | Example |
|----------|-------------|---------|
| `MAILGUN_API_KEY` | Mailgun private API key | `key-abc123...` |
| `MAILGUN_DOMAIN` | Mailgun sending domain | `mg.nailmyjob.com` |
| `MAILGUN_SMTP_PASSWORD` | SMTP password (usually same as API key) | `key-abc123...` |
| `MAILGUN_REGION` | Mailgun region (`us` or `eu`) | `us` |
| `MAILER_FROM_ADDRESS` | Default from address | `NailMyJob <noreply@nailmyjob.com>` |

---

## AI Services (Optional)

These are optional for MVP but required for voice features.

| Variable | Description | Example |
|----------|-------------|---------|
| `OPENAI_API_KEY` | OpenAI API key for AI parsing | `sk-abc123...` |
| `DEEPGRAM_API_KEY` | Deepgram API key for voice transcription | `abc123...` |

---

## File Storage (Optional)

For production file storage (logos, PDFs, etc.).

| Variable | Description | Example |
|----------|-------------|---------|
| `AWS_ACCESS_KEY_ID` | S3-compatible access key | `AKIA...` |
| `AWS_SECRET_ACCESS_KEY` | S3-compatible secret key | `abc123...` |
| `AWS_BUCKET` | S3 bucket name | `nailmyjob-production` |
| `AWS_REGION` | S3 region | `us-east-1` |
| `AWS_ENDPOINT` | Custom S3 endpoint (for Hetzner Object Storage) | `https://fsn1.your-objectstorage.com` |

---

## Performance Tuning

| Variable | Description | Default |
|----------|-------------|---------|
| `RAILS_MAX_THREADS` | Puma threads per worker | `3` |
| `WEB_CONCURRENCY` | Puma worker processes | `2` |
| `JOB_CONCURRENCY` | Sidekiq job concurrency | `5` |
| `PORT` | Application port | `3000` |

---

## Bitwarden Secrets Manager

For automated deployments, store secrets in Bitwarden Secrets Manager with these IDs:

```
# Database
bws://nailmyjob/DATABASE_PASSWORD
bws://nailmyjob/POSTGRES_USER
bws://nailmyjob/POSTGRES_PASSWORD

# Rails
bws://nailmyjob/SECRET_KEY_BASE

# Mailgun
bws://nailmyjob/MAILGUN_API_KEY
bws://nailmyjob/MAILGUN_DOMAIN
bws://nailmyjob/MAILGUN_SMTP_PASSWORD

# AI Services
bws://nailmyjob/OPENAI_API_KEY
bws://nailmyjob/DEEPGRAM_API_KEY

# File Storage
bws://nailmyjob/AWS_ACCESS_KEY_ID
bws://nailmyjob/AWS_SECRET_ACCESS_KEY
bws://nailmyjob/AWS_BUCKET
```

---

## Quick Setup

### Development

```bash
# Copy example env file
cp .env.example .env

# Edit with your values
nano .env

# Start services
docker compose up -d
```

### Production (Hetzner)

```bash
# Pull secrets from Bitwarden
./scripts/pull-secrets.sh

# Deploy
docker compose -f docker-compose.production.yml up -d
```

---

## Generating Secrets

```bash
# Generate Rails secret key
docker compose run --rm web bin/rails secret

# Generate secure password
openssl rand -base64 32
```
