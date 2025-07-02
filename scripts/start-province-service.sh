#!/bin/bash

# Province Tracking Service Startup Script
# This script starts the background service that checks user provinces every 2 minutes

echo "🚀 Starting Province Tracking Service..."
echo "📍 This service will check user provinces every 2 minutes"
echo "📊 Monitoring location changes and updating provinces automatically"
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js first."
    exit 1
fi

# Check if the script exists
if [ ! -f "scripts/check-user-provinces.js" ]; then
    echo "❌ Province checking script not found. Please ensure scripts/check-user-provinces.js exists."
    exit 1
fi

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "⚠️  .env file not found. Please ensure your environment variables are set."
fi

echo "✅ Starting service..."
echo "📝 Logs will appear below. Press Ctrl+C to stop the service."
echo ""

# Start the province checking service
node scripts/check-user-provinces.js 