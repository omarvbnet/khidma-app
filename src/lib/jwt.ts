import jwt from 'jsonwebtoken';
import { NextRequest } from 'next/server';

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';

export function signJwtAccessToken(payload: any) {
  const token = jwt.sign(payload, JWT_SECRET, {
    expiresIn: '1d',
  });
  return token;
}

export function verifyJwtAccessToken(token: string) {
  try {
    const verified = jwt.verify(token, JWT_SECRET);
    return verified;
  } catch (error) {
    return null;
  }
}

export async function verifyToken(req: NextRequest) {
  try {
    const authHeader = req.headers.get('authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return null;
    }

    const token = authHeader.split(' ')[1];
    const verified = verifyJwtAccessToken(token);
    if (!verified) {
      return null;
    }

    return (verified as any).userId;
  } catch (error) {
    return null;
  }
} 