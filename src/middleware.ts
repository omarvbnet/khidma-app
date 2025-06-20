import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  const session = request.cookies.get('session');
  const { pathname } = request.nextUrl;

  // Skip middleware for Flutter API routes
  if (pathname.startsWith('/api/flutter')) {
    return NextResponse.next();
  }

  // If the user is not logged in and trying to access a protected route
  if (!session && pathname !== '/login') {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  // If the user is logged in and trying to access the login page
  if (session && pathname === '/login') {
    return NextResponse.redirect(new URL('/dashboard', request.url));
  }

  // Check for admin role only for specific routes
  if (session && (
    pathname.startsWith('/users') ||
    pathname.startsWith('/drivers') ||
    pathname.startsWith('/driver-requests') ||
    pathname.startsWith('/orders') ||
    pathname.startsWith('/products')
  )) {
    try {
      const sessionData = JSON.parse(session.value);
      if (sessionData.role !== 'ADMIN') {
        return NextResponse.redirect(new URL('/unauthorized', request.url));
      }
    } catch (error) {
      // If session parsing fails, redirect to login
      return NextResponse.redirect(new URL('/login', request.url));
    }
  }

  return NextResponse.next();
}

// Configure which routes to run middleware on
export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones starting with:
     * - api (API routes)
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     * - auth/register (registration endpoint)
     */
    '/((?!api|_next/static|_next/image|favicon.ico|auth/register).*)',
  ],
}; 