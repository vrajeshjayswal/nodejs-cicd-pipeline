#!/bin/bash
set -e

echo "=== Restart Server Script ==="

# This script restarts the Node.js application
# It's a combination of stop and start operations

echo "Stopping existing application..."

# Check if application is running using PM2
if command -v pm2 &> /dev/null; then
    echo "Stopping application with PM2..."
    pm2 stop nodejs-app || echo "Application not running with PM2"
    pm2 delete nodejs-app || echo "Application not found in PM2"
else
    echo "PM2 not found, checking for running Node.js processes..."
    # Find and kill the Node.js process
    pkill -f "node server.js" || echo "No running Node.js process found"
fi

echo "Starting application..."

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

echo "Restart server completed successfully"
echo "Application is running on port 3000"
