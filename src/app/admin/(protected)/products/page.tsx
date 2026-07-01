import Link from "next/link";
import Image from "next/image";
import { prisma } from "@/lib/prisma";
import { Button } from "@/components/ui/button";
import { Plus, Pencil } from "lucide-react";
import { DeleteProductButton } from "@/components/admin/delete-product-button";

export default async function AdminProductsPage() {
  const products = await prisma.product.findMany({
    include: {
      images: { orderBy: { order: "asc" }, take: 1 },
      category: true,
    },
    orderBy: { createdAt: "desc" },
  });

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold">Products ({products.length})</h1>
        <Link href="/admin/products/new">
          <Button><Plus className="w-4 h-4 mr-2" />Add Product</Button>
        </Link>
      </div>

      <div className="border border-border rounded-xl overflow-hidden">
        <table className="w-full text-sm">
          <thead className="bg-muted text-left">
            <tr>
              <th className="p-3">Photo</th>
              <th className="p-3">Title</th>
              <th className="p-3">Category</th>
              <th className="p-3">Price (KES)</th>
              <th className="p-3">Stock</th>
              <th className="p-3 text-right">Actions</th>
            </tr>
          </thead>
          <tbody>
            {products.map((p) => (
              <tr key={p.id} className="border-t border-border hover:bg-muted/40 transition-colors">
                <td className="p-3">
                  {p.images[0] ? (
                    <div className="relative w-12 h-12 rounded-lg overflow-hidden">
                      <Image src={p.images[0].url} alt={p.title} fill className="object-cover" />
                    </div>
                  ) : (
                    <div className="w-12 h-12 rounded-lg bg-muted flex items-center justify-center text-xs text-muted-foreground">
                      None
                    </div>
                  )}
                </td>
                <td className="p-3 font-medium">{p.title}</td>
                <td className="p-3 text-muted-foreground">{p.category.name}</td>
                <td className="p-3">{Number(p.price).toLocaleString()}</td>
                <td className="p-3">
                  <span className={`text-xs px-2 py-1 rounded-full font-medium ${
                    p.stockStatus === "IN_STOCK"
                      ? "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400"
                      : p.stockStatus === "OUT_OF_STOCK"
                      ? "bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-400"
                      : "bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-400"
                  }`}>
                    {p.stockStatus.replace(/_/g, " ")}
                  </span>
                </td>
                <td className="p-3">
                  <div className="flex justify-end gap-2">
                    <Link href={`/admin/products/${p.id}/edit`}>
                      <Button variant="ghost" size="icon">
                        <Pencil className="w-4 h-4" />
                      </Button>
                    </Link>
                    <DeleteProductButton productId={p.id} productTitle={p.title} />
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        {products.length === 0 && (
          <p className="p-8 text-center text-muted-foreground">
            No products yet.{" "}
            <Link href="/admin/products/new" className="text-primary hover:underline">
              Add your first one.
            </Link>
          </p>
        )}
      </div>
    </div>
  );
}
