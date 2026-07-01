import { notFound } from "next/navigation";
import { prisma } from "@/lib/prisma";
import { ProductGallery } from "@/components/product-gallery";
import { ProductActions } from "@/components/product-actions";
import { Ruler, Layers, Package, Tag } from "lucide-react";

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const product = await prisma.product.findUnique({ where: { slug } });

  if (!product) return {};
  return {
    title: `${product.title} | Alkosphre Furniture`,
    description: product.description.slice(0, 155),
    openGraph: {
      title: product.title,
      description: product.description.slice(0, 155),
    },
  };
}

export default async function ProductPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const product = await prisma.product.findUnique({
    where: { slug },
    include: {
      images: { orderBy: { order: "asc" } },
      category: true,
    },
  });

  if (!product) notFound();

  const dims = product.dimensions as {
    width: number;
    height: number;
    depth: number;
    unit: string;
  };

  return (
    <div className="container mx-auto px-4 py-10">
      <div className="grid md:grid-cols-2 gap-12">
        <ProductGallery images={product.images} />

        <div>
          <p className="text-sm uppercase tracking-wide text-muted-foreground mb-2">
            {product.category.name}
          </p>
          <h1 className="text-3xl font-semibold mb-3">{product.title}</h1>
          <p className="text-2xl font-semibold mb-6">
            KES {Number(product.price).toLocaleString()}
          </p>

          <p className="text-muted-foreground leading-relaxed mb-8">
            {product.description}
          </p>

          <div className="space-y-4 mb-8 border-t border-border pt-6">
            <div className="flex items-start gap-3">
              <Ruler className="w-5 h-5 text-muted-foreground mt-0.5 shrink-0" />
              <div>
                <p className="text-sm font-medium">Dimensions</p>
                <p className="text-sm text-muted-foreground">
                  {dims.width} × {dims.height} × {dims.depth} {dims.unit} (W × H
                  × D)
                </p>
              </div>
            </div>
            <div className="flex items-start gap-3">
              <Layers className="w-5 h-5 text-muted-foreground mt-0.5 shrink-0" />
              <div>
                <p className="text-sm font-medium">Materials</p>
                <p className="text-sm text-muted-foreground">
                  {product.materials.join(", ")}
                </p>
              </div>
            </div>
            <div className="flex items-start gap-3">
              <Package className="w-5 h-5 text-muted-foreground mt-0.5 shrink-0" />
              <div>
                <p className="text-sm font-medium">Availability</p>
                <p className="text-sm text-muted-foreground">
                  {product.stockStatus.replace(/_/g, " ")}
                </p>
              </div>
            </div>
            <div className="flex items-start gap-3">
              <Tag className="w-5 h-5 text-muted-foreground mt-0.5 shrink-0" />
              <div>
                <p className="text-sm font-medium">Category</p>
                <p className="text-sm text-muted-foreground">
                  {product.category.name}
                </p>
              </div>
            </div>
          </div>

          <ProductActions
            productId={product.id}
            productTitle={product.title}
            productSlug={product.slug}
          />
        </div>
      </div>
    </div>
  );
}
