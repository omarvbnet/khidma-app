import * as bcrypt from 'bcrypt';
import type { NextAuthConfig } from "next-auth";
import CredentialsProvider from "next-auth/providers/credentials";
import { prisma } from "@/lib/prisma";
import NextAuth from "next-auth";

export async function comparePassword(
  plainPassword: string,
  hashedPassword: string
): Promise<boolean> {
  return bcrypt.compare(plainPassword, hashedPassword);
}

export async function hashPassword(password: string): Promise<string> {
  const salt = await bcrypt.genSalt(10);
  return bcrypt.hash(password, salt);
}

export const authConfig = {
  providers: [
    CredentialsProvider({
      name: "credentials",
      credentials: {
        phoneNumber: { label: "Phone Number", type: "tel" },
        password: { label: "Password", type: "password" }
      },
      async authorize(credentials: Partial<Record<"phoneNumber" | "password", unknown>>) {
        if (!credentials?.phoneNumber || !credentials?.password) {
          return null;
        }

        const user = await prisma.user.findUnique({
          where: {
            phoneNumber: credentials.phoneNumber as string
          }
        });

        if (!user) {
          return null;
        }

        const isPasswordValid = await bcrypt.compare(
          credentials.password as string,
          user.password
        );

        if (!isPasswordValid) {
          return null;
        }

        return {
          id: user.id,
          phoneNumber: user.phoneNumber,
          name: user.fullName,
          role: user.role,
        };
      }
    })
  ],
  callbacks: {
    async jwt({ token, user }: { token: any; user: any }) {
      if (user) {
        return {
          ...token,
          id: user.id,
          role: user.role,
        };
      }
      return token;
    },
    async session({ session, token }: { session: any; token: any }) {
      return {
        ...session,
        user: {
          ...session.user,
          id: token.id,
          role: token.role,
        },
      };
    },
  },
  pages: {
    signIn: "/login",
  },
  session: {
    strategy: "jwt" as const,
  },
  secret: process.env.NEXTAUTH_SECRET || "your-secret-key",
} as NextAuthConfig;

export const { auth, signIn, signOut } = NextAuth(authConfig); 