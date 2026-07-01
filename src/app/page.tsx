import Link from "next/link";
import Image from "next/image";
import { prisma } from "@/lib/prisma";
import { ProductCard } from "@/components/product-card";
import { Button } from "@/components/ui/button";
import { ArrowRight, Quote } from "lucide-react";

export const metadata = {
  title: "Alkosphre Furniture | Handcrafted Furniture in Kenya",
  description: "Elegant, handcrafted furniture made in Kenya. Browse our collection.",
};

const testimonials = [
  { name: "Wanjiru K.", text: "The dining table exceeded my expectations. Solid craftsmanship and smooth delivery to Nairobi." },
  { name: "David M.", text: "Ordered a bed frame made to order — quality wood, fair price, and great communication throughout." },
  { name: "Amina S.", text: "Beautiful pieces, true to the photos. Will definitely order again for my next home project." },
];

export default async function HomePage() {
  const [featured, categories] = await Promise.all([
    prisma.product.findMany({
      where: { featured: true },
      include: {
        images: { orderBy: { order: "asc" }, take: 1 },
        category: true,
      },
      take: 8,
    }),
    prisma.category.findMany({ take: 6 }),
  ]);

  return (
    <div>
      {/* Hero */}
      <section className="relative h-[85vh] min-h-[500px] flex items-end">
        <div className="absolute inset-0 bg-gradient-to-br from-stone-900 via-stone-800 to-stone-700 -z-10" />
        <div className="container mx-auto px-4 pb-16 text-white">
          <p className="text-sm tracking-widest uppercase mb-3 opacity-80">Handcrafted in Kenya</p>
          <h1 className="text-4xl md:text-6xl font-semibold max-w-2xl leading-tight">
            Furniture made to last a lifetime
          </h1>
          <p className="mt-4 max-w-lg text-white/75 text-lg">
            Solid wood, honest craftsmanship, designed for the modern East African home.
          </p>
          <Link href="/shop">
            <Button size="lg" className="mt-8">
              Shop the Collection <ArrowRight className="w-4 h-4 ml-2" />
            </Button>
          </Link>
        </div>
      </section>

      {/* Categories */}
      {categories.length > 0 && (
        <section className="container mx-auto px-4 py-16">
          <h2 className="text-2xl font-semibold mb-8">Shop by Category</h2>
          <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
            {categories.map((cat) => (
              <Link
                key={cat.id}
                href={`/shop?category=${cat.slug}`}
                className="relative aspect-[16/10] rounded-xl overflow-hidden bg-muted flex items-end p-5 group"
              >
                <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />
                <span className="relative text-white font-medium text-lg group-hover:underline">
                  {cat.name}
                </span>
              </Link>
            ))}
          </div>
        </section>
      )}

      {/* Featured products */}
      {featured.length > 0 && (
        <section className="container mx-auto px-4 py-16">
          <div className="flex items-center justify-between mb-8">
            <h2 className="text-2xl font-semibold">Featured Pieces</h2>
            <Link href="/shop" className="text-sm text-primary hover:underline flex items-center gap-1">
              View all <ArrowRight className="w-4 h-4" />
            </Link>
          </div>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
            {featured.map((p) => (
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
        </section>
      )}

      {/* Empty state if no products yet */}
      {featured.length === 0 && categories.length === 0 && (
        <section className="container mx-auto px-4 py-24 text-center">
          <p className="text-muted-foreground">Products coming soon. Check back shortly.</p>
        </section>
      )}

      {/* Testimonials */}
      <section className="bg-muted/50 py-16">
        <div className="container mx-auto px-4">
          <h2 className="text-2xl font-semibold mb-8 text-center">What Our Customers Say</h2>
          <div className="grid md:grid-cols-3 gap-6">
            {testimonials.map((t, i) => (
              <div key={i} className="bg-background rounded-xl p-6 border border-border">
                <Quote className="w-6 h-6 text-primary mb-3" />
                <p className="text-sm text-muted-foreground mb-4 leading-relaxed">{t.text}</p>
                <p className="text-sm font-medium">{t.name}</p>
              </div>
            ))}
          </div>
        </div>
      </section>
    </div>
  );
}
