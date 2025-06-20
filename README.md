# Khidma App

A comprehensive taxi booking application with Next.js backend and Flutter mobile app.

## Features

- **User Management**: Registration, authentication, and role-based access
- **Taxi Booking**: Real-time trip requests and driver assignment
- **Driver App**: Flutter mobile app for drivers
- **Admin Dashboard**: Web dashboard for managing users, trips, and drivers
- **OTP Authentication**: SMS-based verification using Twilio
- **Real-time Updates**: Live trip status updates

## Tech Stack

- **Backend**: Next.js 15, Prisma, PostgreSQL
- **Frontend**: React, Tailwind CSS, Shadcn/ui
- **Mobile**: Flutter
- **Authentication**: JWT, NextAuth
- **SMS**: Twilio
- **Maps**: Google Maps API

## Getting Started

### Prerequisites

- Node.js 18+
- PostgreSQL database
- Twilio account (for OTP)
- Google Maps API key

### Local Development

1. Clone the repository:
```bash
git clone <repository-url>
cd khidma-app
```

2. Install dependencies:
```bash
npm install
```

3. Set up environment variables:
```bash
cp env.example .env
# Edit .env with your configuration
```

4. Set up the database:
```bash
npx prisma generate
npx prisma db push
```

5. Create admin user:
```bash
npm run create-admin
```

6. Start the development server:
```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) to access the admin dashboard.

## Deployment

### Quick Deploy to Vercel

1. Run the deployment script:
```bash
./deploy.sh
```

2. Follow the prompts to set up your Vercel project

3. Set environment variables in Vercel dashboard

4. Create a PostgreSQL database (Vercel Postgres recommended)

### Manual Deployment

See [DEPLOYMENT.md](./DEPLOYMENT.md) for detailed deployment instructions.

## Project Structure

```
khidma-app/
├── src/                    # Next.js app
│   ├── app/               # App router pages and API routes
│   ├── components/        # React components
│   ├── contexts/          # React contexts
│   └── lib/              # Utility functions
├── waddiny/              # Flutter mobile app
├── prisma/               # Database schema and migrations
└── scripts/              # Utility scripts
```

## API Documentation

### Authentication Endpoints
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/otp` - OTP verification

### Flutter API Endpoints
- `POST /api/flutter/auth/login` - Mobile app login
- `POST /api/flutter/auth/otp/send` - Send OTP
- `POST /api/flutter/auth/otp/verify` - Verify OTP
- `GET /api/flutter/taxi-requests` - Get available trips
- `POST /api/flutter/taxi-requests/[id]/assign-driver` - Accept trip

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License.
# Updated at Fri Jun 20 22:48:25 +03 2025
