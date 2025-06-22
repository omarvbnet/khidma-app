# Firebase Environment Variables Setup for Vercel

## Overview
To enable Firebase Admin SDK for server-side push notifications, you need to add Firebase environment variables to your Vercel deployment.

## Required Environment Variables

You need to add these 3 environment variables to Vercel:

1. **FIREBASE_PROJECT_ID** - Your Firebase project ID
2. **FIREBASE_CLIENT_EMAIL** - Service account email
3. **FIREBASE_PRIVATE_KEY** - Service account private key

## Step-by-Step Setup

### 1. Get Firebase Service Account Credentials

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Project Settings** (gear icon)
4. Go to **Service accounts** tab
5. Click **Generate new private key**
6. Download the JSON file

### 2. Extract Values from Service Account JSON

The downloaded JSON file will look like this:
```json
{
  "type": "service_account",
  "project_id": "your-project-id",
  "private_key_id": "...",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-xxxxx@your-project-id.iam.gserviceaccount.com",
  "client_id": "...",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "..."
}
```

Extract these values:
- **FIREBASE_PROJECT_ID**: `your-project-id`
- **FIREBASE_CLIENT_EMAIL**: `firebase-adminsdk-xxxxx@your-project-id.iam.gserviceaccount.com`
- **FIREBASE_PRIVATE_KEY**: The entire private key (including `-----BEGIN PRIVATE KEY-----` and `-----END PRIVATE KEY-----`)

### 3. Add Environment Variables to Vercel

1. Go to your [Vercel Dashboard](https://vercel.com/dashboard)
2. Select your project (`khidma-app`)
3. Go to **Settings** tab
4. Click **Environment Variables**
5. Add each variable:

#### Add FIREBASE_PROJECT_ID
- **Name**: `FIREBASE_PROJECT_ID`
- **Value**: Your Firebase project ID (e.g., `your-project-id`)
- **Environment**: Production, Preview, Development
- Click **Add**

#### Add FIREBASE_CLIENT_EMAIL
- **Name**: `FIREBASE_CLIENT_EMAIL`
- **Value**: Service account email (e.g., `firebase-adminsdk-xxxxx@your-project-id.iam.gserviceaccount.com`)
- **Environment**: Production, Preview, Development
- Click **Add**

#### Add FIREBASE_PRIVATE_KEY
- **Name**: `FIREBASE_PRIVATE_KEY`
- **Value**: The entire private key including newlines:
```
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC...
... (full private key content) ...
-----END PRIVATE KEY-----
```
- **Environment**: Production, Preview, Development
- Click **Add**

### 4. Redeploy Your Application

1. After adding all environment variables, go to **Deployments** tab
2. Click **Redeploy** on your latest deployment
3. Or push a new commit to trigger automatic deployment

## Verification

After deployment, you can verify the environment variables are working by:

1. **Check Vercel Logs** - Look for Firebase initialization messages
2. **Test Push Notifications** - Try sending a notification from your app
3. **Check Console Logs** - Look for "✅ Firebase Admin SDK initialized" messages

## Expected Logs

When working correctly, you should see:
```
✅ Firebase Admin SDK initialized
✅ Push notification sent successfully
```

## Troubleshooting

### Common Issues:

1. **"Service account object must contain a string 'project_id' property"**
   - Check that `FIREBASE_PROJECT_ID` is set correctly
   - Ensure no extra spaces or characters

2. **"Invalid private key"**
   - Make sure `FIREBASE_PRIVATE_KEY` includes the full key with `-----BEGIN PRIVATE KEY-----` and `-----END PRIVATE KEY-----`
   - Ensure newlines are preserved

3. **"Invalid client email"**
   - Verify `FIREBASE_CLIENT_EMAIL` matches the service account email exactly

### Security Notes:

- ✅ Environment variables are encrypted in Vercel
- ✅ Never commit service account keys to Git
- ✅ Use different service accounts for different environments
- ✅ Regularly rotate service account keys

## Local Development

For local development, create a `.env.local` file in your project root:

```env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@your-project-id.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
```

## Next Steps

After setting up the environment variables:

1. **Redeploy** your application
2. **Test notifications** from your Flutter app
3. **Monitor logs** for any issues
4. **Verify device tokens** are being updated correctly

Your push notification system should now work end-to-end! 🚀 