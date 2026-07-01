import { prisma } from "@/lib/prisma";
import { ProductForm } from "@/components/admin/product-form";
import Link from "next/link";
import { ChevronLeft } from "lucide-react";

export default async function NewProductPage() {
  const categories = await prisma.category.findMany({ orderBy: { name: "asc" } });

  return (
    <div className="space-y-6">
      <div>
        <Link
          href="/admin/products"
          className="flex items-center gap-1 text-sm text-muted-foreground hover:text-foreground mb-4"
        >
          <ChevronLeft className="w-4 h-4" /> Back to products
        </Link>
        <h1 className="text-2xl font-semibold">Add New Product</h1>
      </div>
      <ProductForm categories={categories} />
    </div>
  );
}
