import { NextRequest, NextResponse } from 'next/server';
import { verify } from 'jsonwebtoken';
import { JwtPayload } from 'jsonwebtoken';

export async function POST(req: NextRequest) {
  try {
    console.log('\n🔍 DEBUGGING TOKEN VERIFICATION');
    
    const authHeader = req.headers.get('authorization');
    console.log('Authorization header:', authHeader ? 'Present' : 'Missing');
    
    if (!authHeader) {
      return NextResponse.json({
        success: false,
        error: 'No authorization header',
        details: 'The request does not include an Authorization header'
      });
    }
    
    if (!authHeader.startsWith('Bearer ')) {
      return NextResponse.json({
        success: false,
        error: 'Invalid authorization format',
        details: 'Authorization header should start with "Bearer "'
      });
    }
    
    const token = authHeader.substring(7);
    console.log('Token preview:', token.substring(0, 20) + '...');
    
    // Check JWT_SECRET
    if (!process.env.JWT_SECRET) {
      return NextResponse.json({
        success: false,
        error: 'JWT_SECRET not configured',
        details: 'The JWT_SECRET environment variable is not set'
      });
    }
    
    console.log('JWT_SECRET is configured');
    
    try {
      const decoded = verify(token, process.env.JWT_SECRET) as JwtPayload;
      console.log('✅ Token verified successfully');
      
      return NextResponse.json({
        success: true,
        message: 'Token verification successful',
        decoded: {
          userId: decoded.userId,
          role: decoded.role,
          iat: decoded.iat,
          exp: decoded.exp
        },
        tokenInfo: {
          length: token.length,
          preview: token.substring(0, 20) + '...'
        }
      });
      
    } catch (verifyError) {
      console.log('❌ Token verification failed:', verifyError);
      
      return NextResponse.json({
        success: false,
        error: 'Token verification failed',
        details: verifyError instanceof Error ? verifyError.message : 'Unknown verification error',
        tokenInfo: {
          length: token.length,
          preview: token.substring(0, 20) + '...'
        }
      });
    }
    
  } catch (error) {
    console.error('❌ Debug endpoint error:', error);
    return NextResponse.json({
      success: false,
      error: 'Debug endpoint failed',
      details: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 });
  }
}

export async function GET(req: NextRequest) {
  try {
    console.log('\n🔍 TOKEN DEBUG STATUS');
    
    const hasJwtSecret = !!process.env.JWT_SECRET;
    const jwtSecretLength = process.env.JWT_SECRET?.length || 0;
    
    return NextResponse.json({
      success: true,
      environment: {
        hasJwtSecret,
        jwtSecretLength,
        jwtSecretPreview: hasJwtSecret ? process.env.JWT_SECRET!.substring(0, 10) + '...' : 'NOT_SET'
      },
      instructions: [
        'Send a POST request with Authorization: Bearer <your-token>',
        'This endpoint will verify your token and show detailed information',
        'Use this to debug token verification issues'
      ]
    });
    
  } catch (error) {
    console.error('❌ Debug status check failed:', error);
    return NextResponse.json({
      success: false,
      error: 'Status check failed'
    }, { status: 500 });
  }
} 