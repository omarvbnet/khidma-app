"use client";
import Link from 'next/link';
import { useAuth } from '@/contexts/AuthContext';
import { useTheme } from '@/contexts/ThemeContext';
import { Moon, Sun, Menu, X } from 'lucide-react';
import { useState } from 'react';

export default function Navigation() {
  const { user, logout } = useAuth();
  const { theme, toggleTheme } = useTheme();
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  if (!user) return null;

  const navigationItems = [
    { href: "/dashboard", label: "Dashboard" },
    { href: "/orders", label: "Orders" },
    { href: "/products", label: "Products" },
    { href: "/taxi-requests", label: "Taxi Requests" },
    { href: "/drivers", label: "Drivers" },
    { href: "/driver-requests", label: "Driver Requests" },
    { href: "/users", label: "Users" },
  ];

  return (
    <nav className="bg-card border-b border-border shadow-sm">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between h-16">
          <div className="flex items-center">
            <div className="flex-shrink-0 flex items-center">
              <Link href="/dashboard" className="text-xl font-bold text-primary">
                Khidma
              </Link>
            </div>
            
            {/* Desktop Navigation */}
            <div className="hidden md:ml-6 md:flex md:space-x-8">
              {navigationItems.map((item) => (
                <Link
                  key={item.href}
                  href={item.href}
                  className="text-muted-foreground hover:text-foreground px-3 py-2 rounded-md text-sm font-medium transition-colors"
                >
                  {item.label}
                </Link>
              ))}
            </div>
          </div>

          <div className="flex items-center space-x-4">
            {/* Theme Toggle */}
            <button
              onClick={toggleTheme}
              className="p-2 rounded-md text-muted-foreground hover:text-foreground hover:bg-accent transition-colors"
              aria-label="Toggle theme"
            >
              {theme === 'dark' ? <Sun className="h-5 w-5" /> : <Moon className="h-5 w-5" />}
            </button>

            {/* User Info */}
            <div className="hidden md:flex items-center space-x-4">
              <span className="text-sm text-muted-foreground">{user.role}</span>
              <button
                onClick={logout}
                className="bg-destructive text-destructive-foreground px-3 py-2 rounded-md text-sm font-medium hover:bg-destructive/90 transition-colors"
              >
                Logout
              </button>
            </div>

            {/* Mobile menu button */}
            <div className="md:hidden">
              <button
                onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
                className="p-2 rounded-md text-muted-foreground hover:text-foreground hover:bg-accent transition-colors"
              >
                {isMobileMenuOpen ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
              </button>
            </div>
          </div>
        </div>

        {/* Mobile Navigation */}
        {isMobileMenuOpen && (
          <div className="md:hidden">
            <div className="px-2 pt-2 pb-3 space-y-1 sm:px-3 border-t border-border">
              {navigationItems.map((item) => (
                <Link
                  key={item.href}
                  href={item.href}
                  className="text-muted-foreground hover:text-foreground block px-3 py-2 rounded-md text-base font-medium transition-colors"
                  onClick={() => setIsMobileMenuOpen(false)}
                >
                  {item.label}
                </Link>
              ))}
              <div className="pt-4 pb-3 border-t border-border">
                <div className="px-3 py-2 text-sm text-muted-foreground">{user.role}</div>
                <button
                  onClick={() => {
                    logout();
                    setIsMobileMenuOpen(false);
                  }}
                  className="w-full text-left px-3 py-2 text-sm font-medium text-destructive hover:bg-destructive/10 rounded-md transition-colors"
                >
                  Logout
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </nav>
  );
} 