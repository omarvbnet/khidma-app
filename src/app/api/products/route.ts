import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function GET(req: NextRequest) {
  const { searchParams } = new URL(req.url);
  const query = searchParams.get('query');

  const where: any = {};
  if (query) {
    where.OR = [
      { name: { contains: query } },
      { description: { contains: query } },
    ];
  }

  const products = await prisma.product.findMany({
    where,
    orderBy: { createdAt: 'desc' },
  });
  return NextResponse.json(products);
}

export async function POST(req: NextRequest) {
  const { name, price, description } = await req.json();
  if (!name || !price) {
    return NextResponse.json({ error: 'Missing required fields' }, { status: 400 });
  }
  const product = await prisma.product.create({
    data: {
      name,
      price,
      description,
    },
  });
  return NextResponse.json(product);
} 