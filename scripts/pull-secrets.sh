#!/bin/bash
# =============================================================================
# Pull Secrets from Bitwarden Secrets Manager
# =============================================================================
# This script fetches secrets from Bitwarden and creates a .env file
#
# Prerequisites:
#   - BWS CLI installed (https://bitwarden.com/help/secrets-manager-cli/)
#   - BWS_ACCESS_TOKEN environment variable set
#
# Usage:
#   export BWS_ACCESS_TOKEN="your-access-token"
#   ./scripts/pull-secrets.sh
# =============================================================================

set -e

# Check for BWS CLI
if ! command -v bws &> /dev/null; then
    echo "❌ Error: Bitwarden Secrets Manager CLI (bws) not found"
    echo "Install it from: https://bitwarden.com/help/secrets-manager-cli/"
    exit 1
fi

# Check for access token
if [ -z "$BWS_ACCESS_TOKEN" ]; then
    echo "❌ Error: BWS_ACCESS_TOKEN environment variable not set"
    echo "Get your access token from Bitwarden Secrets Manager"
    exit 1
fi

echo "🔐 Fetching secrets from Bitwarden..."

# Create .env file
ENV_FILE="${1:-.env}"
echo "# Auto-generated from Bitwarden Secrets Manager" > "$ENV_FILE"
echo "# Generated at: $(date -u +"%Y-%m-%dT%H:%M:%SZ")" >> "$ENV_FILE"
echo "" >> "$ENV_FILE"

# Function to fetch a secret
fetch_secret() {
    local secret_id=$1
    local env_name=$2
    local required=${3:-false}
    
    if [ -z "$secret_id" ]; then
        if [ "$required" = true ]; then
            echo "❌ Error: Secret ID for $env_name not provided"
            exit 1
        fi
        return
    fi
    
    local value=$(bws secret get "$secret_id" 2>/dev/null | jq -r '.value' 2>/dev/null)
    
    if [ -n "$value" ] && [ "$value" != "null" ]; then
        echo "$env_name=$value" >> "$ENV_FILE"
        echo "✅ $env_name"
    else
        if [ "$required" = true ]; then
            echo "❌ Error: Failed to fetch required secret $env_name"
            exit 1
        else
            echo "⚠️  $env_name (not found, skipping)"
        fi
    fi
}

# =============================================================================
# Configure your Bitwarden Secret IDs here
# =============================================================================
# Replace these with your actual secret IDs from Bitwarden Secrets Manager
# You can find these in the Bitwarden web vault under Secrets Manager

# Required secrets
echo "📦 Fetching required secrets..."
fetch_secret "${BWS_POSTGRES_USER_ID}" "POSTGRES_USER" true
fetch_secret "${BWS_POSTGRES_PASSWORD_ID}" "POSTGRES_PASSWORD" true
fetch_secret "${BWS_SECRET_KEY_BASE_ID}" "SECRET_KEY_BASE" true

# Email (Mailgun)
echo "📧 Fetching email secrets..."
fetch_secret "${BWS_MAILGUN_API_KEY_ID}" "MAILGUN_API_KEY"
fetch_secret "${BWS_MAILGUN_DOMAIN_ID}" "MAILGUN_DOMAIN"
fetch_secret "${BWS_MAILGUN_SMTP_PASSWORD_ID}" "MAILGUN_SMTP_PASSWORD"

# AI Services (optional)
echo "🤖 Fetching AI service secrets..."
fetch_secret "${BWS_OPENAI_API_KEY_ID}" "OPENAI_API_KEY"
fetch_secret "${BWS_DEEPGRAM_API_KEY_ID}" "DEEPGRAM_API_KEY"

# File Storage (optional)
echo "📁 Fetching storage secrets..."
fetch_secret "${BWS_AWS_ACCESS_KEY_ID_ID}" "AWS_ACCESS_KEY_ID"
fetch_secret "${BWS_AWS_SECRET_ACCESS_KEY_ID}" "AWS_SECRET_ACCESS_KEY"
fetch_secret "${BWS_AWS_BUCKET_ID}" "AWS_BUCKET"

# =============================================================================
# Static configuration (not secrets)
# =============================================================================
echo "" >> "$ENV_FILE"
echo "# Application Configuration" >> "$ENV_FILE"
echo "RAILS_ENV=production" >> "$ENV_FILE"
echo "RAILS_LOG_TO_STDOUT=true" >> "$ENV_FILE"
echo "RAILS_SERVE_STATIC_FILES=true" >> "$ENV_FILE"

# Add APP_HOST if provided
if [ -n "$APP_HOST" ]; then
    echo "APP_HOST=$APP_HOST" >> "$ENV_FILE"
fi

# Add MAILER_FROM_ADDRESS if provided
if [ -n "$MAILER_FROM_ADDRESS" ]; then
    echo "MAILER_FROM_ADDRESS=$MAILER_FROM_ADDRESS" >> "$ENV_FILE"
fi

echo ""
echo "✅ Secrets written to $ENV_FILE"
echo ""
echo "⚠️  Remember to:"
echo "   1. Set APP_HOST in your .env file"
echo "   2. Set MAILER_FROM_ADDRESS in your .env file"
echo "   3. Keep this file secure and never commit it to git!"
