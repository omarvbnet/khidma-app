"use client";
import { useAuth } from '@/contexts/AuthContext';
import { useRouter, usePathname } from 'next/navigation';
import { useEffect } from 'react';
import Navigation from '@/components/Navigation';

interface DashboardLayoutProps {
  children: React.ReactNode;
}

// Pages that should not show navigation
const EXCLUDED_PATHS = ['/login', '/unauthorized'];

export default function DashboardLayout({ children }: DashboardLayoutProps) {
  const { user, loading } = useAuth();
  const router = useRouter();
  const pathname = usePathname();

  const shouldShowNavigation = !EXCLUDED_PATHS.includes(pathname);

  useEffect(() => {
    if (!loading && !user && shouldShowNavigation) {
      router.push('/login');
    }
  }, [user, loading, router, shouldShowNavigation]);

  // Show loading while checking authentication
  if (loading) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
      </div>
    );
  }

  // For excluded paths (like login), render children without navigation
  if (!shouldShowNavigation) {
    return <>{children}</>;
  }

  // Don't render anything if user is not authenticated
  if (!user) {
    return null;
  }

  return (
    <div className="min-h-screen bg-background">
      <Navigation />
      <main className="p-8">
        <div className="mx-auto max-w-7xl">
          {children}
        </div>
      </main>
    </div>
  );
} 