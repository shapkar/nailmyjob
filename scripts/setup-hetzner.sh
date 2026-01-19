#!/bin/bash
# =============================================================================
# Hetzner Server Initial Setup Script
# =============================================================================
# Run this script on a fresh Hetzner server to prepare it for NailMyJob
#
# Usage:
#   ssh root@your-server-ip
#   curl -sSL https://raw.githubusercontent.com/your-org/nailmyjob-app/main/scripts/setup-hetzner.sh | bash
#
# Or copy and run manually
# =============================================================================

set -e

echo "🚀 Setting up Hetzner server for NailMyJob..."

# Update system
echo "📦 Updating system packages..."
apt-get update && apt-get upgrade -y

# Install required packages
echo "📦 Installing required packages..."
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git \
    unzip \
    jq \
    fail2ban \
    ufw

# Install Docker
echo "🐳 Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com | sh
    systemctl enable docker
    systemctl start docker
fi

# Install Docker Compose
echo "🐳 Installing Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r '.tag_name')
    curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# Install Bitwarden Secrets Manager CLI
echo "🔐 Installing Bitwarden Secrets Manager CLI..."
if ! command -v bws &> /dev/null; then
    BWS_VERSION="0.5.0"
    wget -qO- "https://github.com/bitwarden/sdk/releases/download/bws-v${BWS_VERSION}/bws-x86_64-unknown-linux-gnu-${BWS_VERSION}.zip" -O /tmp/bws.zip
    unzip -o /tmp/bws.zip -d /tmp
    mv /tmp/bws /usr/local/bin/
    chmod +x /usr/local/bin/bws
    rm /tmp/bws.zip
fi

# Create deploy user
echo "👤 Creating deploy user..."
if ! id "deploy" &>/dev/null; then
    useradd -m -s /bin/bash deploy
    usermod -aG docker deploy
    mkdir -p /home/deploy/.ssh
    cp /root/.ssh/authorized_keys /home/deploy/.ssh/
    chown -R deploy:deploy /home/deploy/.ssh
    chmod 700 /home/deploy/.ssh
    chmod 600 /home/deploy/.ssh/authorized_keys
fi

# Create application directory
echo "📁 Creating application directory..."
mkdir -p /opt/nailmyjob
chown deploy:deploy /opt/nailmyjob

# Configure firewall
echo "🔥 Configuring firewall..."
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow http
ufw allow https
ufw --force enable

# Configure fail2ban
echo "🛡️ Configuring fail2ban..."
systemctl enable fail2ban
systemctl start fail2ban

# Set up automatic security updates
echo "🔄 Configuring automatic security updates..."
apt-get install -y unattended-upgrades
dpkg-reconfigure -plow unattended-upgrades

# Create swap if needed (for small servers)
echo "💾 Checking swap..."
if [ ! -f /swapfile ]; then
    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

# Set timezone
echo "🕐 Setting timezone..."
timedatectl set-timezone UTC

# Print summary
echo ""
echo "✅ Server setup complete!"
echo ""
echo "Next steps:"
echo "1. Add your GitHub Actions deploy key to /home/deploy/.ssh/authorized_keys"
echo "2. Set up your secrets in Bitwarden Secrets Manager"
echo "3. Configure GitHub Actions with the following secrets:"
echo "   - HETZNER_HOST: $(curl -s ifconfig.me)"
echo "   - HETZNER_USER: deploy"
echo "   - HETZNER_SSH_KEY: (your private SSH key)"
echo "   - BWS_ACCESS_TOKEN: (from Bitwarden)"
echo ""
echo "4. Push to main branch to trigger deployment!"
