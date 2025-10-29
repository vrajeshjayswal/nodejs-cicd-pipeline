#!/bin/bash
set -e

echo "=== Start Application Script ==="

cd /home/ec2-user/nodejs-app

# Install PM2 globally if not already installed
if ! command -v pm2 &> /dev/null; then
    echo "Installing PM2..."
    npm install -g pm2
fi

# Start the application using PM2
echo "Starting application with PM2..."
pm2 start server.js --name nodejs-app --update-env

# Save PM2 process list and configure auto-start
echo "Configuring PM2 startup..."
pm2 save
pm2 startup systemd -u ec2-user --hp /home/ec2-user || true

# Display PM2 status
echo "Application status:"
pm2 status

echo "Start application completed successfully"
echo "Application is running on port 3000"

