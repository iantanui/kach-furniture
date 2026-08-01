import { Suspense } from "react";
import { prisma } from "@/lib/prisma";
import { ProductCard } from "@/components/product-card";
import { ShopFilters } from "@/components/shop-filters";

export const metadata = {
  title: "Shop | Alkosphre Furniture",
  description: "Browse our full collection of handcrafted furniture.",
};

export default async function ShopPage({
  searchParams,
}: {
  searchParams: Promise<{ category?: string; q?: string; min?: string; max?: string }>;
}) {
  const { category, q, min, max } = await searchParams;

  const [products, categories] = await Promise.all([
    prisma.product.findMany({
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
      include: {
        images: { orderBy: { order: "asc" }, take: 1 },
        category: true,
      },
      orderBy: { createdAt: "desc" },
    }),
    prisma.category.findMany(),
  ]);

  return (
    <div className="container mx-auto px-4 py-10">
      <h1 className="text-3xl font-semibold mb-8">Shop</h1>
      <div className="grid grid-cols-1 md:grid-cols-[240px_1fr] gap-10">
        <aside className="md:sticky md:top-24 h-fit">
          <Suspense>
            <ShopFilters categories={categories} />
          </Suspense>
        </aside>
        <div>
          {products.length === 0 ? (
            <p className="text-muted-foreground py-12 text-center">
              No products match your filters. Try adjusting your search.
            </p>
          ) : (
            <>
              <p className="text-sm text-muted-foreground mb-6">{products.length} products</p>
              <div className="grid grid-cols-2 lg:grid-cols-3 gap-6">
                {products.map((p) => (
                  <ProductCard
                    key={p.id}
                    slug={p.slug}
                    title={p.title}
                    price={p.price.toString()}
                    imageUrl={p.images[0]?.url}
                    categoryName={p.category.name}
                    stockStatus={p.stockStatus}
                  />
                ))}
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
