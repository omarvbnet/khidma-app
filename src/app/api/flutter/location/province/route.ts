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

// Get province from coordinates
export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const lat = searchParams.get('lat');
  const lng = searchParams.get('lng');

  if (!lat || !lng) {
    return NextResponse.json(
      { error: 'Latitude and longitude are required' },
      { status: 400 }
    );
  }

  try {
    // Enhanced province determination based on coordinates for Iraq
    const latitude = parseFloat(lat);
    const longitude = parseFloat(lng);

    // Comprehensive province mapping for Iraq
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

    return NextResponse.json({ province });
  } catch (error) {
    console.error('Error getting province from coordinates:', error);
    return NextResponse.json(
      { error: 'Failed to get province from coordinates' },
      { status: 500 }
    );
  }
}

// Update user province with coordinates
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

    // Get province from coordinates
    const latitude = parseFloat(lat);
    const longitude = parseFloat(lng);

    // Basic province mapping for Iraq (simplified)
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

    // Update user's province
    const user = await prisma.user.update({
      where: { id: userId },
      data: { province },
    });

    console.log(`🔄 Updated user ${userId} province to ${province} based on coordinates (${lat}, ${lng})`);

    return NextResponse.json({ 
      user,
      province,
      coordinates: { lat: latitude, lng: longitude }
    });
  } catch (error) {
    console.error('Error updating user province with coordinates:', error);
    return NextResponse.json(
      { error: 'Failed to update user province' },
      { status: 500 }
    );
  }
} 