import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { verify } from 'jsonwebtoken';

async function verifyToken(req: NextRequest) {
  const authHeader = req.headers.get('authorization');
  if (!authHeader?.startsWith('Bearer ')) {
    return null;
  }

  const token = authHeader.split(' ')[1];
  try {
    const decoded = verify(token, process.env.JWT_SECRET || 'your-secret-key') as { userId: string };
    return decoded.userId;
  } catch (error) {
    return null;
  }
}

// Update user location with coordinates
export async function POST(request: NextRequest) {
  const userId = await verifyToken(request);
  if (!userId) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const { lat, lng } = await request.json();

    if (!lat || !lng) {
      return NextResponse.json(
        { error: 'Latitude and longitude are required' },
        { status: 400 }
      );
    }

    const latitude = parseFloat(lat);
    const longitude = parseFloat(lng);

    // Validate coordinates
    if (isNaN(latitude) || isNaN(longitude)) {
      return NextResponse.json(
        { error: 'Invalid coordinates' },
        { status: 400 }
      );
    }

    // Determine province from coordinates
    let province = 'Baghdad'; // Default

    if (latitude >= 33.0 && latitude <= 34.0 && longitude >= 44.0 && longitude <= 45.0) {
      province = 'Baghdad';
    } else if (latitude >= 36.0 && latitude <= 37.0 && longitude >= 43.0 && longitude <= 44.0) {
      province = 'Erbil';
    } else if (latitude >= 36.0 && latitude <= 37.0 && longitude >= 42.0 && longitude <= 42.5) {
      province = 'Duhok';
    } else if (latitude >= 35.0 && latitude <= 36.0 && longitude >= 45.0 && longitude <= 46.0) {
      province = 'Sulaymaniyah';
    } else if (latitude >= 32.0 && latitude <= 33.0 && longitude >= 44.0 && longitude <= 45.0) {
      province = 'Babil';
    } else if (latitude >= 31.0 && latitude <= 32.0 && longitude >= 44.0 && longitude <= 45.0) {
      province = 'Karbala';
    } else if (latitude >= 32.0 && latitude <= 33.0 && longitude >= 45.0 && longitude <= 46.0) {
      province = 'Wasit';
    } else if (latitude >= 30.0 && latitude <= 31.0 && longitude >= 47.0 && longitude <= 48.0) {
      province = 'Basra';
    } else if (latitude >= 33.0 && latitude <= 34.0 && longitude >= 43.0 && longitude <= 44.0) {
      province = 'Anbar';
    } else if (latitude >= 35.0 && latitude <= 36.0 && longitude >= 43.5 && longitude <= 44.5) {
      province = 'Kirkuk';
    } else if (latitude >= 34.0 && latitude <= 35.0 && longitude >= 44.5 && longitude <= 45.5) {
      province = 'Diyala';
    } else if (latitude >= 34.0 && latitude <= 35.0 && longitude >= 43.0 && longitude <= 44.0) {
      province = 'Salahaddin';
    } else if (latitude >= 36.0 && latitude <= 37.0 && longitude >= 42.5 && longitude <= 43.0) {
      province = 'Nineveh';
    } else if (latitude >= 36.0 && latitude <= 37.0 && longitude >= 37.0 && longitude <= 38.0) {
      province = 'Aleppo';
    } else if (latitude >= 33.0 && latitude <= 34.0 && longitude >= 36.0 && longitude <= 37.0) {
      province = 'Damascus';
    }

    // Update user's location and province
    const user = await prisma.user.update({
      where: { id: userId },
      data: {
        lastKnownLatitude: latitude,
        lastKnownLongitude: longitude,
        lastLocationUpdate: new Date(),
        province: province
      },
    });

    console.log(`📍 Updated user ${userId} location: (${latitude}, ${longitude}) → ${province}`);

    return NextResponse.json({ 
      success: true,
      user: {
        id: user.id,
        fullName: user.fullName,
        province: user.province,
        lastKnownLatitude: user.lastKnownLatitude,
        lastKnownLongitude: user.lastKnownLongitude,
        lastLocationUpdate: user.lastLocationUpdate
      },
      province,
      coordinates: { lat: latitude, lng: longitude }
    });
  } catch (error) {
    console.error('Error updating user location:', error);
    return NextResponse.json(
      { error: 'Failed to update user location' },
      { status: 500 }
    );
  }
}

// Get user's current location
export async function GET(request: NextRequest) {
  const userId = await verifyToken(request);
  if (!userId) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        fullName: true,
        province: true,
        lastKnownLatitude: true,
        lastKnownLongitude: true,
        lastLocationUpdate: true
      }
    });

    if (!user) {
      return NextResponse.json({ error: 'User not found' }, { status: 404 });
    }

    return NextResponse.json({
      user,
      hasLocation: !!(user.lastKnownLatitude && user.lastKnownLongitude)
    });
  } catch (error) {
    console.error('Error getting user location:', error);
    return NextResponse.json(
      { error: 'Failed to get user location' },
      { status: 500 }
    );
  }
} 