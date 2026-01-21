# NailMyJob Deployment Guide

This guide covers deploying NailMyJob to Hetzner using GitHub Actions and Bitwarden Secrets Manager.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        Hetzner Cloud                            │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                     Docker Compose                         │  │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────────┐  │  │
│  │  │  Caddy  │  │   Web   │  │ Sidekiq │  │  PostgreSQL │  │  │
│  │  │  :443   │──│  :3000  │  │  Worker │  │    :5432    │  │  │
│  │  └─────────┘  └─────────┘  └─────────┘  └─────────────┘  │  │
│  │       │            │            │              │          │  │
│  │       └────────────┴────────────┴──────┬──────┘          │  │
│  │                                        │                  │  │
│  │                                   ┌────┴────┐             │  │
│  │                                   │  Redis  │             │  │
│  │                                   │  :6379  │             │  │
│  │                                   └─────────┘             │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Prerequisites

1. **Hetzner Cloud Account** - [Sign up](https://www.hetzner.com/cloud)
2. **GitHub Repository** - Your NailMyJob fork/clone
3. **Bitwarden Account** - [Sign up](https://bitwarden.com) (with Secrets Manager)
4. **Domain Name** - Pointed to your Hetzner server

## Step 1: Set Up Hetzner Server

### Create a Server

1. Go to Hetzner Cloud Console
2. Create a new project (e.g., "NailMyJob")
3. Add a new server:
   - **Location**: Choose closest to your users (e.g., Ashburn for US)
   - **Image**: Ubuntu 22.04
   - **Type**: CX21 (2 vCPU, 4GB RAM) - good for starting
   - **SSH Key**: Add your SSH public key
   - **Name**: `nailmyjob-prod`

### Initial Server Setup

SSH into your server and run the setup script:

```bash
ssh root@your-server-ip

# Download and run setup script
curl -sSL https://raw.githubusercontent.com/YOUR_ORG/nailmyjob-app/main/scripts/setup-hetzner.sh | bash
```

Or manually:

```bash
# Update system
apt update && apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com | sh
systemctl enable docker

# Install Docker Compose
apt install docker-compose-plugin -y

# Create deploy user
useradd -m -s /bin/bash deploy
usermod -aG docker deploy

# Create app directory
mkdir -p /opt/nailmyjob
chown deploy:deploy /opt/nailmyjob

# Configure firewall
ufw allow ssh
ufw allow http
ufw allow https
ufw enable
```

## Step 2: Set Up Bitwarden Secrets Manager

### Create Secrets

1. Log in to [Bitwarden](https://vault.bitwarden.com)
2. Go to **Secrets Manager** (left sidebar)
3. Create a new **Project** called "NailMyJob"
4. Add the following secrets:

| Secret Name | Description |
|-------------|-------------|
| `DATABASE_URL` | Supabase PostgreSQL connection string |
| `SECRET_KEY_BASE` | Rails secret (run `rails secret`) |
| `MAILGUN_API_KEY` | Your Mailgun API key |
| `MAILGUN_DOMAIN` | Your Mailgun domain (e.g., `hey.nailmyjob.com`) |
| `OPENAI_API_KEY` | OpenAI API key (optional) |
| `DEEPGRAM_API_KEY` | Deepgram API key (optional) |

### Create Access Token

1. Go to **Machine Accounts** in Secrets Manager
2. Create a new machine account for "GitHub Actions"
3. Grant it read access to the NailMyJob project
4. Generate an access token and save it securely

## Step 3: Configure GitHub

### Repository Secrets

Go to your GitHub repo → Settings → Secrets and variables → Actions

Add these **Secrets**:

| Secret | Value |
|--------|-------|
| `HETZNER_HOST` | Your server IP address |
| `HETZNER_USER` | `deploy` |
| `HETZNER_SSH_KEY` | Private SSH key for deploy user |
| `BWS_ACCESS_TOKEN` | Bitwarden machine account token |

### Repository Variables

Add these **Variables**:

| Variable | Value |
|----------|-------|
| `APP_HOST` | Your domain (e.g., `app.nailmyjob.com`) |
| `MAILER_FROM_ADDRESS` | `Spase <spase@hey.nailmyjob.com>` |
| `BWS_DATABASE_URL_ID` | Bitwarden secret ID for Supabase connection string |
| `BWS_SECRET_KEY_BASE_ID` | Bitwarden secret ID |
| `BWS_MAILGUN_API_KEY_ID` | Bitwarden secret ID |
| `BWS_MAILGUN_DOMAIN_ID` | Bitwarden secret ID |

### Generate SSH Key for Deployment

```bash
# On your local machine
ssh-keygen -t ed25519 -C "github-actions-deploy" -f ~/.ssh/nailmyjob-deploy

# Copy public key to server
ssh-copy-id -i ~/.ssh/nailmyjob-deploy.pub deploy@your-server-ip

# Add private key to GitHub Secrets as HETZNER_SSH_KEY
cat ~/.ssh/nailmyjob-deploy
```

## Step 4: Configure DNS

Point your domain to your Hetzner server:

```
Type  Name              Value
A     app.nailmyjob.com YOUR_SERVER_IP
A     @                 YOUR_SERVER_IP (if using root domain)
```

## Step 5: Deploy

### Automatic Deployment

Push to the `main` branch to trigger automatic deployment:

```bash
git push origin main
```

### Manual Deployment

Trigger deployment manually from GitHub Actions:

1. Go to Actions → Deploy to Hetzner
2. Click "Run workflow"
3. Select environment and click "Run workflow"

### First Deployment

The first deployment will:

1. Build Docker image
2. Push to GitHub Container Registry
3. Copy files to server
4. Pull image on server
5. Run database migrations
6. Start all services
7. Caddy will automatically obtain SSL certificate

## Step 6: Verify Deployment

```bash
# SSH to server
ssh deploy@your-server-ip

# Check running containers
cd /opt/nailmyjob
docker compose -f docker-compose.production.yml ps

# Check logs
docker compose -f docker-compose.production.yml logs -f web

# Check Rails logs
docker compose -f docker-compose.production.yml logs -f web | grep -v healthcheck
```

Visit `https://your-domain.com` to verify the app is running.

## Maintenance

### View Logs

```bash
# All services
docker compose -f docker-compose.production.yml logs -f

# Specific service
docker compose -f docker-compose.production.yml logs -f web
docker compose -f docker-compose.production.yml logs -f sidekiq
```

### Database Backup

```bash
# Create backup
docker compose -f docker-compose.production.yml exec db pg_dump -U nailmyjob nailmyjob_production > backup.sql

# Restore backup
docker compose -f docker-compose.production.yml exec -T db psql -U nailmyjob nailmyjob_production < backup.sql
```

### Rails Console

```bash
docker compose -f docker-compose.production.yml exec web bin/rails console
```

### Update Application

Push to main branch or manually trigger the deploy workflow.

### Rollback

```bash
# On server
cd /opt/nailmyjob

# Update IMAGE_TAG in .env to previous version
nano .env

# Redeploy
docker compose -f docker-compose.production.yml up -d
```

## Troubleshooting

### Container won't start

```bash
# Check logs
docker compose -f docker-compose.production.yml logs web

# Check if database is ready
docker compose -f docker-compose.production.yml exec db pg_isready
```

### SSL Certificate Issues

```bash
# Check Caddy logs
docker compose -f docker-compose.production.yml logs caddy

# Verify DNS
dig your-domain.com
```

### Database Connection Issues

```bash
# Test connection
docker compose -f docker-compose.production.yml exec web bin/rails db:version
```

## Scaling

### Vertical Scaling

Upgrade your Hetzner server to a larger instance type.

### Horizontal Scaling

For high traffic, consider:

1. **Load Balancer**: Hetzner Load Balancer in front of multiple web servers
2. **Managed Database**: Hetzner Managed PostgreSQL
3. **Redis Cluster**: For high-volume job processing

## Security Checklist

- [ ] SSH key authentication only (password disabled)
- [ ] Firewall configured (UFW)
- [ ] Fail2ban installed
- [ ] Automatic security updates enabled
- [ ] SSL/TLS enabled (via Caddy)
- [ ] Secrets stored in Bitwarden (not in code)
- [ ] Regular database backups
- [ ] Monitoring set up (optional: Grafana, Prometheus)
