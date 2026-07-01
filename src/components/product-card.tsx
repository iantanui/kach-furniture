import Link from "next/link";
import Image from "next/image";
import { cn } from "@/lib/utils";

interface ProductCardProps {
  slug: string;
  title: string;
  price: number | string;
  imageUrl?: string;
  categoryName: string;
  stockStatus: string;
}

export function ProductCard({ slug, title, price, imageUrl, categoryName, stockStatus }: ProductCardProps) {
  return (
    <Link href={`/product/${slug}`} className="group block">
      <div className="relative aspect-[4/5] overflow-hidden rounded-xl bg-muted">
        {imageUrl ? (
          <Image
            src={imageUrl}
            alt={title}
            fill
            sizes="(max-width: 768px) 50vw, (max-width: 1200px) 33vw, 25vw"
            className="object-cover transition-transform duration-500 group-hover:scale-105"
          />
        ) : (
          <div className="absolute inset-0 flex items-center justify-center text-muted-foreground text-xs">
            No image
          </div>
        )}
        {stockStatus === "OUT_OF_STOCK" && (
          <span className="absolute top-3 left-3 bg-background/90 text-xs font-medium px-2 py-1 rounded-full">
            Out of Stock
          </span>
        )}
        {stockStatus === "MADE_TO_ORDER" && (
          <span className="absolute top-3 left-3 bg-amber-500/90 text-white text-xs font-medium px-2 py-1 rounded-full">
            Made to Order
          </span>
        )}
      </div>
      <div className="mt-3 space-y-1">
        <p className="text-xs uppercase tracking-wide text-muted-foreground">{categoryName}</p>
        <h3 className="font-medium leading-snug group-hover:text-primary transition-colors">{title}</h3>
        <p className="text-sm font-semibold">KES {Number(price).toLocaleString()}</p>
      </div>
    </Link>
  );
}
