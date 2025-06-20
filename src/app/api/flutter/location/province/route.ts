import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const lat = searchParams.get('lat');
    const lng = searchParams.get('lng');

    if (!lat || !lng) {
      return NextResponse.json(
        { error: 'Latitude and longitude are required' },
        { status: 400 }
      );
    }

    // Use OpenStreetMap Nominatim API for reverse geocoding
    const response = await fetch(
      `https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lng}&addressdetails=1`,
      {
        headers: {
          'User-Agent': 'KhidmaApp/1.0'
        }
      }
    );

    if (!response.ok) {
      throw new Error('Failed to fetch location data');
    }

    const data = await response.json();
    const address = data.address;
    const province = address.state || address.county || 'Unknown';

    return NextResponse.json({ province });
  } catch (error) {
    console.error('Error getting province:', error);
    return NextResponse.json(
      { error: 'Failed to get province' },
      { status: 500 }
    );
  }
} 