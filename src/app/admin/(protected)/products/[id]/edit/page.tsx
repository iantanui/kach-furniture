import { notFound } from "next/navigation";
import { prisma } from "@/lib/prisma";
import { ProductForm } from "@/components/admin/product-form";
import Link from "next/link";
import { ChevronLeft } from "lucide-react";

export default async function EditProductPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const [product, categories] = await Promise.all([
    prisma.product.findUnique({
      where: { id },
      include: { images: { orderBy: { order: "asc" } } },
    }),
    prisma.category.findMany({ orderBy: { name: "asc" } }),
  ]);

  if (!product) notFound();

  const dims = product.dimensions as {
    width: number; height: number; depth: number; unit: "cm" | "in";
  };

  return (
    <div className="space-y-6">
      <div>
        <Link
          href="/admin/products"
          className="flex items-center gap-1 text-sm text-muted-foreground hover:text-foreground mb-4"
        >
          <ChevronLeft className="w-4 h-4" /> Back to products
        </Link>
        <h1 className="text-2xl font-semibold">Edit: {product.title}</h1>
      </div>
      <ProductForm
        categories={categories}
        productId={product.id}
        initialData={{
          title: product.title,
          description: product.description,
          price: Number(product.price),
          categoryId: product.categoryId,
          materials: product.materials,
          dimensions: dims,
          stockStatus: product.stockStatus,
          featured: product.featured,
          images: product.images.map((img) => ({
            url: img.url,
            publicId: img.publicId,
          })),
        }}
      />
    </div>
  );
}
