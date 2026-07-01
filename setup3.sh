#!/bin/bash
set -e

mkdir -p src/app/admin/login
mkdir -p src/app/admin/products/new
mkdir -p "src/app/admin/products/[id]/edit"
mkdir -p src/components/admin

# ─── NEXTAUTH TYPES ───────────────────────────────────────────

cat > src/types/next-auth.d.ts << 'EOF'
import { DefaultSession } from "next-auth";

declare module "next-auth" {
  interface Session {
    user: { id: string } & DefaultSession["user"];
  }
}
EOF

# ─── ADMIN ROOT LAYOUT (auth-gated) ───────────────────────────

cat > src/app/admin/layout.tsx << 'EOF'
import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/auth";
import { redirect } from "next/navigation";
import Link from "next/link";
import { LayoutDashboard, Package, LogOut } from "lucide-react";

export default async function AdminLayout({ children }: { children: React.ReactNode }) {
  const session = await getServerSession(authOptions);
  if (!session) redirect("/admin/login");

  return (
    <div className="min-h-screen flex">
      {/* Sidebar */}
      <aside className="w-60 border-r border-border bg-muted/30 flex flex-col">
        <div className="h-16 flex items-center px-6 border-b border-border">
          <span className="font-semibold text-sm">Alkosphere Admin</span>
        </div>
        <nav className="flex-1 p-4 space-y-1">
          <Link
            href="/admin"
            className="flex items-center gap-3 px-3 py-2 rounded-lg text-sm hover:bg-muted transition-colors"
          >
            <LayoutDashboard className="w-4 h-4" /> Dashboard
          </Link>
          <Link
            href="/admin/products"
            className="flex items-center gap-3 px-3 py-2 rounded-lg text-sm hover:bg-muted transition-colors"
          >
            <Package className="w-4 h-4" /> Products
          </Link>
        </nav>
        <div className="p-4 border-t border-border">
          <p className="text-xs text-muted-foreground mb-3">{session.user?.email}</p>
          <Link
            href="/api/auth/signout"
            className="flex items-center gap-2 text-sm text-muted-foreground hover:text-foreground transition-colors"
          >
            <LogOut className="w-4 h-4" /> Sign out
          </Link>
        </div>
      </aside>

      {/* Main */}
      <main className="flex-1 p-8 overflow-auto">{children}</main>
    </div>
  );
}
EOF

# ─── LOGIN PAGE ───────────────────────────────────────────────

cat > src/app/admin/login/page.tsx << 'EOF'
"use client";

import { useState } from "react";
import { signIn } from "next-auth/react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Loader2 } from "lucide-react";

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError("");

    const res = await signIn("credentials", {
      email,
      password,
      redirect: false,
    });

    if (res?.error) {
      setError("Invalid email or password.");
      setLoading(false);
    } else {
      router.push("/admin");
      router.refresh();
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center px-4">
      <div className="w-full max-w-sm space-y-6">
        <div>
          <h1 className="text-2xl font-semibold">Admin Login</h1>
          <p className="text-sm text-muted-foreground mt-1">Alkosphere Furniture</p>
        </div>
        <form onSubmit={handleSubmit} className="space-y-4">
          <Input
            type="email"
            placeholder="Email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
          />
          <Input
            type="password"
            placeholder="Password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
          />
          {error && <p className="text-sm text-destructive">{error}</p>}
          <Button type="submit" className="w-full" disabled={loading}>
            {loading && <Loader2 className="w-4 h-4 mr-2 animate-spin" />}
            Sign In
          </Button>
        </form>
      </div>
    </div>
  );
}
EOF

# ─── ADMIN DASHBOARD ──────────────────────────────────────────

cat > src/app/admin/page.tsx << 'EOF'
import { prisma } from "@/lib/prisma";
import { Package, MessageSquare, Star, TrendingUp } from "lucide-react";

export default async function AdminDashboard() {
  const [productCount, enquiryCount, featuredCount, recentEnquiries] = await Promise.all([
    prisma.product.count(),
    prisma.enquiry.count(),
    prisma.product.count({ where: { featured: true } }),
    prisma.enquiry.findMany({
      orderBy: { createdAt: "desc" },
      take: 5,
      include: { product: { select: { title: true } } },
    }),
  ]);

  const stats = [
    { label: "Total Products", value: productCount, icon: Package },
    { label: "Enquiries", value: enquiryCount, icon: MessageSquare },
    { label: "Featured", value: featuredCount, icon: Star },
  ];

  return (
    <div className="space-y-8">
      <h1 className="text-2xl font-semibold">Dashboard</h1>

      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        {stats.map((s) => (
          <div key={s.label} className="border border-border rounded-xl p-5 flex items-center gap-4">
            <div className="p-2 rounded-lg bg-primary/10">
              <s.icon className="w-5 h-5 text-primary" />
            </div>
            <div>
              <p className="text-2xl font-semibold">{s.value}</p>
              <p className="text-sm text-muted-foreground">{s.label}</p>
            </div>
          </div>
        ))}
      </div>

      <div>
        <h2 className="text-lg font-medium mb-4">Recent Enquiries</h2>
        {recentEnquiries.length === 0 ? (
          <p className="text-sm text-muted-foreground">No enquiries yet.</p>
        ) : (
          <div className="border border-border rounded-xl overflow-hidden">
            <table className="w-full text-sm">
              <thead className="bg-muted text-left">
                <tr>
                  <th className="p-3">Name</th>
                  <th className="p-3">Email</th>
                  <th className="p-3">Product</th>
                  <th className="p-3">Date</th>
                </tr>
              </thead>
              <tbody>
                {recentEnquiries.map((e) => (
                  <tr key={e.id} className="border-t border-border">
                    <td className="p-3 font-medium">{e.name}</td>
                    <td className="p-3 text-muted-foreground">{e.email}</td>
                    <td className="p-3 text-muted-foreground">{e.product?.title ?? "General"}</td>
                    <td className="p-3 text-muted-foreground">
                      {new Date(e.createdAt).toLocaleDateString("en-KE")}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}
EOF

# ─── ADMIN PRODUCTS LIST ──────────────────────────────────────

cat > src/app/admin/products/page.tsx << 'EOF'
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
EOF

# ─── NEW PRODUCT PAGE ─────────────────────────────────────────

cat > src/app/admin/products/new/page.tsx << 'EOF'
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
EOF

# ─── EDIT PRODUCT PAGE ────────────────────────────────────────

cat > "src/app/admin/products/[id]/edit/page.tsx" << 'EOF'
import { notFound } from "next/navigation";
import { prisma } from "@/lib/prisma";
import { ProductForm } from "@/components/admin/product-form";
import Link from "next/link";
import { ChevronLeft } from "lucide-react";

export default async function EditProductPage({ params }: { params: { id: string } }) {
  const [product, categories] = await Promise.all([
    prisma.product.findUnique({
      where: { id: params.id },
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
EOF

# ─── DELETE BUTTON COMPONENT ──────────────────────────────────

cat > src/components/admin/delete-product-button.tsx << 'EOF'
"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Trash2, Loader2 } from "lucide-react";

export function DeleteProductButton({
  productId,
  productTitle,
}: {
  productId: string;
  productTitle: string;
}) {
  const router = useRouter();
  const [loading, setLoading] = useState(false);

  const handleDelete = async () => {
    if (!confirm(`Delete "${productTitle}"? This cannot be undone.`)) return;
    setLoading(true);
    try {
      const res = await fetch(`/api/products/${productId}`, { method: "DELETE" });
      if (!res.ok) throw new Error("Delete failed");
      router.refresh();
    } catch {
      alert("Failed to delete product.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <Button
      variant="ghost"
      size="icon"
      onClick={handleDelete}
      disabled={loading}
      className="text-destructive hover:text-destructive hover:bg-destructive/10"
    >
      {loading ? <Loader2 className="w-4 h-4 animate-spin" /> : <Trash2 className="w-4 h-4" />}
    </Button>
  );
}
EOF

# ─── SEED SCRIPT (categories + first admin) ───────────────────

cat > prisma/seed.ts << 'EOF'
import { PrismaClient } from "@prisma/client";
import bcrypt from "bcryptjs";

const prisma = new PrismaClient();

async function main() {
  // Categories
  const categories = [
    { name: "Living Room", slug: "living-room" },
    { name: "Bedroom", slug: "bedroom" },
    { name: "Dining", slug: "dining" },
    { name: "Office", slug: "office" },
    { name: "Outdoor", slug: "outdoor" },
    { name: "Storage", slug: "storage" },
  ];

  for (const cat of categories) {
    await prisma.category.upsert({
      where: { slug: cat.slug },
      update: {},
      create: cat,
    });
  }

  // Admin user — change email/password before deploying
  const hashed = await bcrypt.hash("admin123", 12);
  await prisma.admin.upsert({
    where: { email: "admin@Alkosphere.co.ke" },
    update: {},
    create: {
      email: "admin@Alkosphere.co.ke",
      password: hashed,
      name: "Admin",
    },
  });

  console.log("✅ Seed complete");
  console.log("   Admin: admin@Alkosphere.co.ke / admin123");
}

main().catch(console.error).finally(() => prisma.$disconnect());
EOF

echo ""
echo "✅ Admin login page"
echo "✅ Admin layout (auth-gated sidebar)"
echo "✅ Admin dashboard with stats"
echo "✅ Products list with table"
echo "✅ New product page"
echo "✅ Edit product page"
echo "✅ Delete product button"
echo "✅ Seed script (categories + first admin)"