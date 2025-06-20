#!/bin/bash

echo "🚀 Starting Khidma App Deployment to Vercel"
echo "=============================================="

# Check if Vercel CLI is installed
if ! command -v vercel &> /dev/null; then
    echo "❌ Vercel CLI not found. Installing..."
    npm install -g vercel
fi

# Check if user is logged in
if ! vercel whoami &> /dev/null; then
    echo "🔐 Please login to Vercel..."
    vercel login
fi

echo "📦 Installing dependencies..."
npm install

echo "🔧 Generating Prisma client..."
npx prisma generate

echo "🚀 Deploying to Vercel..."
vercel --prod

echo "✅ Deployment completed!"
echo ""
echo "📋 Next steps:"
echo "1. Set up environment variables in Vercel dashboard"
echo "2. Create a PostgreSQL database (Vercel Postgres recommended)"
echo "3. Set DATABASE_URL in environment variables"
echo "4. Run 'npm run create-admin' to create admin user"
echo ""
echo "📖 See DEPLOYMENT.md for detailed instructions" 