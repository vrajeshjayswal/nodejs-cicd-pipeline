#!/bin/bash
set -e

echo "=== Validating Service ==="

# Wait for application to start
sleep 10

# Check if application is responding
RESPONSE=$(curl -s http://localhost:3000/api/health || echo "failed")

if [[ $RESPONSE == *"healthy"* ]]; then
    echo "✓ Service validation successful!"
    echo "Application is running and healthy"
    exit 0
else
    echo "✗ Service validation failed!"
    echo "Application is not responding correctly"
    exit 1
fi

