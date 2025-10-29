#!/bin/bash
set -e

echo "=== Stop Application Script ==="

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

echo "Stop application completed"

