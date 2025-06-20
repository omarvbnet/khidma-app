"use client";
import { AuthProvider } from '@/contexts/AuthContext';
import Header from '@/components/layout/Header';

export default function ClientRoot({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <AuthProvider>
      <Header />
      <main className="py-10">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          {children}
        </div>
      </main>
    </AuthProvider>
  );
} 