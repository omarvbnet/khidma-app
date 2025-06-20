import { NextRequest, NextResponse } from 'next/server';
import { parse } from 'cookie';

export async function GET(req: NextRequest) {
  const cookie = req.headers.get('cookie');
  if (!cookie) return NextResponse.json({ user: null });
  const cookies = parse(cookie);
  if (!cookies.session) return NextResponse.json({ user: null });
  try {
    const session = JSON.parse(cookies.session);
    return NextResponse.json({ user: session });
  } catch {
    return NextResponse.json({ user: null });
  }
} 