import { NextResponse } from "next/server";
import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/auth";
import { prisma } from "@/lib/prisma";
import { productSchema } from "@/lib/validations";
import slugify from "slugify";

export async function GET(req: Request) {
  const { searchParams } = new URL(req.url);
  const category = searchParams.get("category");
  const q = searchParams.get("q");
  const min = searchParams.get("min");
  const max = searchParams.get("max");

  const products = await prisma.product.findMany({
    where: {
      ...(category && { category: { slug: category } }),
      ...(q && { title: { contains: q, mode: "insensitive" } }),
      ...((min || max) && {
        price: {
          gte: min ? Number(min) : undefined,
          lte: max ? Number(max) : undefined,
        },
      }),
    },
    include: { images: { orderBy: { order: "asc" } }, category: true },
    orderBy: { createdAt: "desc" },
  });

  return NextResponse.json(products);
}

export async function POST(req: Request) {
  const session = await getServerSession(authOptions);
  if (!session) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

  const body = await req.json();
  const parsed = productSchema.safeParse(body);
  if (!parsed.success)
    return NextResponse.json({ error: parsed.error.flatten() }, { status: 400 });

  const data = parsed.data;
  const baseSlug = slugify(data.title, { lower: true, strict: true });
  let slug = baseSlug;
  let counter = 1;
  while (await prisma.product.findUnique({ where: { slug } })) {
    slug = `${baseSlug}-${counter++}`;
  }

  const product = await prisma.product.create({
    data: {
      title: data.title,
      slug,
      description: data.description,
      price: data.price,
      categoryId: data.categoryId,
      materials: data.materials,
      dimensions: data.dimensions,
      stockStatus: data.stockStatus,
      featured: data.featured,
      images: {
        create: data.images.map((img, idx) => ({
          url: img.url,
          publicId: img.publicId,
          order: idx,
        })),
      },
    },
  });

  return NextResponse.json(product, { status: 201 });
}
