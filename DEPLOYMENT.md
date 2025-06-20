# Vercel Deployment Guide

This guide will help you deploy your Khidma app to Vercel with a PostgreSQL database.

## Prerequisites

1. **Vercel Account**: Sign up at [vercel.com](https://vercel.com)
2. **GitHub/GitLab Account**: Your code should be in a Git repository
3. **PostgreSQL Database**: You'll need a PostgreSQL database (we'll use Vercel Postgres)

## Step 1: Set Up Database

### Option A: Vercel Postgres (Recommended)

1. Go to your Vercel dashboard
2. Create a new project or select existing project
3. Go to "Storage" tab
4. Click "Create Database" → "Postgres"
5. Choose a plan (Hobby is free)
6. Select a region close to your users
7. Note down the connection string

### Option B: External PostgreSQL

You can use any PostgreSQL provider:
- **Supabase** (free tier available)
- **Neon** (free tier available)
- **Railway** (free tier available)
- **AWS RDS**
- **Google Cloud SQL**

## Step 2: Deploy to Vercel

### Method 1: Vercel CLI

1. Install Vercel CLI:
```bash
npm i -g vercel
```

2. Login to Vercel:
```bash
vercel login
```

3. Deploy:
```bash
vercel --prod
```

### Method 2: GitHub Integration

1. Push your code to GitHub
2. Go to [vercel.com](https://vercel.com)
3. Click "New Project"
4. Import your GitHub repository
5. Configure the project settings

## Step 3: Environment Variables

In your Vercel project dashboard, go to "Settings" → "Environment Variables" and add:

### Required Variables:

```
DATABASE_URL=your_postgres_connection_string
JWT_SECRET=your-super-secret-jwt-key-here
NEXTAUTH_SECRET=your-nextauth-secret-key-here
NEXTAUTH_URL=https://your-domain.vercel.app
```

### Optional Variables (for OTP functionality):

```
TWILIO_ACCOUNT_SID=your-twilio-account-sid
TWILIO_AUTH_TOKEN=your-twilio-auth-token
TWILIO_PHONE_NUMBER=+1234567890
GOOGLE_MAPS_API_KEY=your-google-maps-api-key
```

## Step 4: Build Configuration

The project is configured with:
- `vercel.json`: Build settings and function configuration
- `package.json`: Updated build script with Prisma commands
- `postinstall` script: Generates Prisma client

## Step 5: Database Migration

After deployment:

1. The build process will automatically run `prisma db push`
2. This will create all tables in your database
3. You can also run migrations manually if needed

## Step 6: Create Admin User

After deployment, you can create an admin user using the script:

```bash
npm run create-admin
```

Or manually via the API endpoint.

## Troubleshooting

### Common Issues:

1. **Build Fails**: Check if all environment variables are set
2. **Database Connection**: Verify DATABASE_URL is correct
3. **Prisma Errors**: Check if database is accessible from Vercel
4. **Function Timeout**: API routes are configured for 30s max duration

### Debugging:

1. Check Vercel build logs
2. Monitor function logs in Vercel dashboard
3. Test database connection locally with production DATABASE_URL

## Post-Deployment

1. Update your Flutter app's API base URL to point to your Vercel domain
2. Test all functionality (auth, trips, etc.)
3. Set up monitoring and alerts
4. Configure custom domain if needed

## Security Notes

- Use strong, unique secrets for JWT_SECRET and NEXTAUTH_SECRET
- Never commit .env files to Git
- Use environment variables for all sensitive data
- Enable HTTPS (automatic with Vercel) 