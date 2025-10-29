#!/bin/bash
set -e

echo "=== After Install Script ==="
echo "Installing Node.js application dependencies..."

cd /home/ec2-user/nodejs-app

# Install Node.js if not already installed
if ! command -v node &> /dev/null; then
    echo "Node.js not found. Installing Node.js..."
    curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
    yum install -y nodejs
fi

# Display Node.js version
echo "Node.js version: $(node --version)"
echo "NPM version: $(npm --version)"

# Install application dependencies
echo "Installing npm packages..."
npm install --production

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "Creating .env file..."
    cp .env.example .env 2>/dev/null || echo "PORT=3000" > .env
    echo "NODE_ENV=production" >> .env
fi

# Set proper permissions
echo "Setting file permissions..."
chown -R ec2-user:ec2-user /home/ec2-user/nodejs-app
chmod -R 755 /home/ec2-user/nodejs-app

echo "After install completed successfully"

