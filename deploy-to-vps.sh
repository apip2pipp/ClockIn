#!/bin/bash

# ===================================================================
# ClockIn Admin Panel - Automated Deployment Script for VPS
# ===================================================================
# 
# Usage: bash deploy-to-vps.sh
# 
# This script will:
# 1. Upload updated files to VPS
# 2. Update .env configuration
# 3. Clear cache and optimize
# 4. Set proper permissions
# 5. Restart services
# 
# ===================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# VPS Configuration
VPS_HOST="31.97.105.63"
VPS_USER="root"
VPS_PATH="/var/www/clockin.cloud"
LOCAL_ADMIN_PATH="./admin-web"

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}ClockIn - VPS Deployment Script${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""

# Step 1: Confirm deployment
echo -e "${YELLOW}This will deploy to: ${VPS_USER}@${VPS_HOST}${NC}"
echo -e "${YELLOW}Target path: ${VPS_PATH}${NC}"
echo ""
read -p "Continue with deployment? (y/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Deployment cancelled.${NC}"
    exit 1
fi

# Step 2: Backup .env on VPS
echo ""
echo -e "${GREEN}[1/8] Creating backup of .env on VPS...${NC}"
ssh ${VPS_USER}@${VPS_HOST} "cd ${VPS_PATH} && cp .env .env.backup_\$(date +%Y%m%d_%H%M%S)" || echo "Backup skipped (file might not exist)"

# Step 3: Upload AdminPanelProvider.php
echo ""
echo -e "${GREEN}[2/8] Uploading AdminPanelProvider.php...${NC}"
scp ${LOCAL_ADMIN_PATH}/app/Providers/Filament/AdminPanelProvider.php \
    ${VPS_USER}@${VPS_HOST}:${VPS_PATH}/app/Providers/Filament/AdminPanelProvider.php

# Step 4: Upload .env.production as .env
echo ""
echo -e "${GREEN}[3/8] Uploading .env configuration...${NC}"
scp ${LOCAL_ADMIN_PATH}/.env.production ${VPS_USER}@${VPS_HOST}:${VPS_PATH}/.env

# Step 5: Update .env with correct database password
echo ""
echo -e "${YELLOW}[4/8] Please enter your MySQL password for clockin_user:${NC}"
read -s DB_PASSWORD
echo ""

ssh ${VPS_USER}@${VPS_HOST} << EOF
    cd ${VPS_PATH}
    sed -i "s/your_secure_password_here/${DB_PASSWORD}/g" .env
    echo "Database password updated in .env"
EOF

# Step 6: Clear cache and optimize
echo ""
echo -e "${GREEN}[5/8] Clearing cache and optimizing...${NC}"
ssh ${VPS_USER}@${VPS_HOST} << 'EOF'
    cd /var/www/clockin.cloud
    
    echo "→ Clearing caches..."
    php artisan cache:clear
    php artisan config:clear
    php artisan route:clear
    php artisan view:clear
    
    echo "→ Optimizing for production..."
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
    
    echo "→ Clearing old sessions..."
    rm -rf storage/framework/sessions/*
    
    echo "✓ Cache optimization complete"
EOF

# Step 7: Run migrations and seeder
echo ""
echo -e "${GREEN}[6/8] Running migrations and seeder...${NC}"
ssh ${VPS_USER}@${VPS_HOST} << 'EOF'
    cd /var/www/clockin.cloud
    
    echo "→ Running migrations..."
    php artisan migrate --force
    
    echo "→ Running user seeder..."
    php artisan db:seed --class=UserSeeder --force
    
    echo "✓ Database updated"
EOF

# Step 8: Set permissions
echo ""
echo -e "${GREEN}[7/8] Setting proper permissions...${NC}"
ssh ${VPS_USER}@${VPS_HOST} << 'EOF'
    cd /var/www/clockin.cloud
    
    echo "→ Setting ownership to www-data..."
    chown -R www-data:www-data .
    
    echo "→ Setting directory permissions..."
    chmod -R 755 .
    chmod -R 775 storage
    chmod -R 775 bootstrap/cache
    
    echo "✓ Permissions set"
EOF

# Step 9: Restart services
echo ""
echo -e "${GREEN}[8/8] Restarting services...${NC}"
ssh ${VPS_USER}@${VPS_HOST} << 'EOF'
    echo "→ Restarting PHP-FPM..."
    systemctl restart php8.3-fpm
    
    echo "→ Restarting Nginx..."
    systemctl restart nginx
    
    echo "→ Checking service status..."
    systemctl is-active php8.3-fpm && echo "✓ PHP-FPM is running"
    systemctl is-active nginx && echo "✓ Nginx is running"
EOF

# Deployment complete
echo ""
echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}✓ Deployment Complete!${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Open: https://clockin.cloud/login"
echo "2. Login with: admin@gmail.com / rahasia"
echo "3. Verify admin panel loads correctly"
echo ""
echo -e "${YELLOW}If issues occur, check logs:${NC}"
echo "  Laravel: tail -100 ${VPS_PATH}/storage/logs/laravel.log"
echo "  Nginx:   tail -100 /var/log/nginx/clockin.cloud_error.log"
echo ""
