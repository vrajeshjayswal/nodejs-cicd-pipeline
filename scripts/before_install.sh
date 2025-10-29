#!/bin/bash
set -e

echo "=== Before Install Script ==="
echo "Cleaning up old application files..."

# Remove old application directory if exists
if [ -d "/home/ec2-user/nodejs-app" ]; then
    echo "Removing old application directory..."
    rm -rf /home/ec2-user/nodejs-app
fi

# Create application directory
echo "Creating application directory..."
mkdir -p /home/ec2-user/nodejs-app

echo "Before install completed successfully"

