import { NextResponse } from 'next/server'
import { prisma } from '@/lib/prisma'

export async function GET() {
  try {
    const count = await prisma.user.count({
      where: {
        role: 'DRIVER',
        status: 'ACTIVE'
      }
    })

    return NextResponse.json({ count })
  } catch (error) {
    console.error('Error counting pending drivers:', error)
    return NextResponse.json(
      { error: 'Failed to count pending drivers' },
      { status: 500 }
    )
  }
} 