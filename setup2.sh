#!/bin/bash
set -e

mkdir -p src/components/admin
mkdir -p "src/app/(shop)/shop"
mkdir -p "src/app/(shop)/product/[slug]"
mkdir -p src/app/api/upload
mkdir -p src/app/api/products
mkdir -p src/app/api/enquiry
mkdir -p "src/app/api/auth/[...nextauth]"

# ─── COMPONENTS ───────────────────────────────────────────────

cat > src/components/theme-toggle.tsx << 'EOF'
"use client";

import { useTheme } from "next-themes";
import { Moon, Sun } from "lucide-react";
import { Button } from "@/components/ui/button";

export function ThemeToggle() {
  const { theme, setTheme } = useTheme();
  return (
    <Button
      variant="ghost"
      size="icon"
      onClick={() => setTheme(theme === "dark" ? "light" : "dark")}
      aria-label="Toggle theme"
    >
      <Sun className="h-5 w-5 rotate-0 scale-100 transition-all dark:-rotate-90 dark:scale-0" />
      <Moon className="absolute h-5 w-5 rotate-90 scale-0 transition-all dark:rotate-0 dark:scale-100" />
    </Button>
  );
}
EOF

cat > src/components/header.tsx << 'EOF'
"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { ThemeToggle } from "./theme-toggle";
import { cn } from "@/lib/utils";
import { Menu, X } from "lucide-react";
import { useState } from "react";

const navLinks = [
  { label: "Home", href: "/" },
  { label: "Shop", href: "/shop" },
  { label: "Living Room", href: "/shop?category=living-room" },
  { label: "Bedroom", href: "/shop?category=bedroom" },
  { label: "Dining", href: "/shop?category=dining" },
];

export function Header() {
  const pathname = usePathname();
  const [menuOpen, setMenuOpen] = useState(false);

  return (
    <header className="sticky top-0 z-40 border-b border-border bg-background/80 backdrop-blur">
      <div className="container mx-auto flex h-16 items-center justify-between px-4">
        <Link href="/" className="text-xl font-semibold tracking-tight">
          Alkosphre Furniture
        </Link>

        {/* Desktop nav */}
        <nav className="hidden md:flex items-center gap-8 text-sm">
          {navLinks.map((link) => (
            <Link
              key={link.href}
              href={link.href}
              className={cn(
                "transition-colors hover:text-primary",
                pathname === link.href ? "text-primary font-medium" : "text-muted-foreground"
              )}
            >
              {link.label}
            </Link>
          ))}
        </nav>

        <div className="flex items-center gap-2">
          <ThemeToggle />
          <button
            className="md:hidden p-2"
            onClick={() => setMenuOpen(!menuOpen)}
            aria-label="Toggle menu"
          >
            {menuOpen ? <X className="w-5 h-5" /> : <Menu className="w-5 h-5" />}
          </button>
        </div>
      </div>

      {/* Mobile nav */}
      {menuOpen && (
        <div className="md:hidden border-t border-border bg-background px-4 py-4 flex flex-col gap-4 text-sm">
          {navLinks.map((link) => (
            <Link
              key={link.href}
              href={link.href}
              onClick={() => setMenuOpen(false)}
              className={cn(
                "transition-colors hover:text-primary",
                pathname === link.href ? "text-primary font-medium" : "text-muted-foreground"
              )}
            >
              {link.label}
            </Link>
          ))}
        </div>
      )}
    </header>
  );
}
EOF

cat > src/components/footer.tsx << 'EOF'
import Link from "next/link";

export function Footer() {
  return (
    <footer className="border-t border-border bg-muted/30 mt-20">
      <div className="container mx-auto px-4 py-12 grid grid-cols-1 md:grid-cols-3 gap-8 text-sm">
        <div>
          <p className="font-semibold text-base mb-2">Alkosphre Furniture</p>
          <p className="text-muted-foreground">
            Handcrafted furniture made in Kenya. Built to last, designed to inspire.
          </p>
        </div>
        <div>
          <p className="font-medium mb-3">Shop</p>
          <ul className="space-y-2 text-muted-foreground">
            <li><Link href="/shop" className="hover:text-primary transition-colors">All Products</Link></li>
            <li><Link href="/shop?category=living-room" className="hover:text-primary transition-colors">Living Room</Link></li>
            <li><Link href="/shop?category=bedroom" className="hover:text-primary transition-colors">Bedroom</Link></li>
            <li><Link href="/shop?category=dining" className="hover:text-primary transition-colors">Dining</Link></li>
          </ul>
        </div>
        <div>
          <p className="font-medium mb-3">Contact</p>
          <ul className="space-y-2 text-muted-foreground">
            <li>Nairobi, Kenya</li>
            <li>
              
                href={`https://wa.me/${process.env.NEXT_PUBLIC_SHOP_WHATSAPP}`}
                className="hover:text-primary transition-colors"
                target="_blank"
                rel="noopener noreferrer"
              >
                WhatsApp Us
              </a>
            </li>
          </ul>
        </div>
      </div>
      <div className="border-t border-border text-center text-xs text-muted-foreground py-4">
        © {new Date().getFullYear()} Alkosphre Furniture. All rights reserved.
      </div>
    </footer>
  );
}
EOF

cat > src/components/product-card.tsx << 'EOF'
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
EOF

cat > src/components/product-gallery.tsx << 'EOF'
"use client";

import { useState } from "react";
import Image from "next/image";
import { cn } from "@/lib/utils";
import { ChevronLeft, ChevronRight } from "lucide-react";

export function ProductGallery({ images }: { images: { url: string }[] }) {
  const [active, setActive] = useState(0);

  const prev = () => setActive((i) => (i === 0 ? images.length - 1 : i - 1));
  const next = () => setActive((i) => (i === images.length - 1 ? 0 : i + 1));

  if (!images.length) return (
    <div className="aspect-square rounded-xl bg-muted flex items-center justify-center text-muted-foreground">
      No images
    </div>
  );

  return (
    <div className="space-y-3">
      <div className="relative aspect-square rounded-xl overflow-hidden bg-muted group">
        <Image
          src={images[active].url}
          alt="Product image"
          fill
          priority
          sizes="(max-width: 768px) 100vw, 50vw"
          className="object-cover"
        />
        {images.length > 1 && (
          <>
            <button
              onClick={prev}
              className="absolute left-3 top-1/2 -translate-y-1/2 bg-background/80 rounded-full p-1.5 opacity-0 group-hover:opacity-100 transition-opacity"
            >
              <ChevronLeft className="w-5 h-5" />
            </button>
            <button
              onClick={next}
              className="absolute right-3 top-1/2 -translate-y-1/2 bg-background/80 rounded-full p-1.5 opacity-0 group-hover:opacity-100 transition-opacity"
            >
              <ChevronRight className="w-5 h-5" />
            </button>
          </>
        )}
      </div>

      {images.length > 1 && (
        <div className="grid grid-cols-5 gap-2">
          {images.map((img, idx) => (
            <button
              key={idx}
              onClick={() => setActive(idx)}
              className={cn(
                "relative aspect-square rounded-lg overflow-hidden border-2 transition-colors",
                active === idx ? "border-primary" : "border-transparent"
              )}
            >
              <Image src={img.url} alt={`Thumbnail ${idx + 1}`} fill className="object-cover" />
            </button>
          ))}
        </div>
      )}
    </div>
  );
}
EOF

cat > src/components/enquiry-modal.tsx << 'EOF'
"use client";

import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { useState } from "react";
import { enquirySchema, EnquiryFormValues } from "@/lib/validations";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { buildWhatsAppLink } from "@/lib/whatsapp";
import { MessageCircle, Loader2 } from "lucide-react";

export function EnquiryModal({
  open,
  onOpenChange,
  productId,
  productTitle,
  productSlug,
}: {
  open: boolean;
  onOpenChange: (v: boolean) => void;
  productId: string;
  productTitle: string;
  productSlug: string;
}) {
  const [submitting, setSubmitting] = useState(false);
  const {
    register,
    handleSubmit,
    reset,
    formState: { errors },
  } = useForm<EnquiryFormValues>({
    resolver: zodResolver(enquirySchema),
    defaultValues: {
      productId,
      message: `Hi, I'm interested in the "${productTitle}". Is it available?`,
    },
  });

  const onSubmit = async (data: EnquiryFormValues) => {
    setSubmitting(true);
    try {
      await fetch("/api/enquiry", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(data),
      });

      const waLink = buildWhatsAppLink({
        phoneNumber: process.env.NEXT_PUBLIC_SHOP_WHATSAPP!,
        productTitle,
        productUrl: `${window.location.origin}/product/${productSlug}`,
        customerName: data.name,
      });

      window.open(waLink, "_blank");
      reset();
      onOpenChange(false);
    } catch {
      alert("Failed to send enquiry. Please try WhatsApp directly.");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>Enquire about {productTitle}</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          <input type="hidden" {...register("productId")} />
          <div>
            <Input placeholder="Your name" {...register("name")} />
            {errors.name && <p className="text-xs text-destructive mt-1">{errors.name.message}</p>}
          </div>
          <div>
            <Input placeholder="Phone (e.g. 0712345678)" {...register("phone")} />
            {errors.phone && <p className="text-xs text-destructive mt-1">{errors.phone.message}</p>}
          </div>
          <div>
            <Input type="email" placeholder="Email address" {...register("email")} />
            {errors.email && <p className="text-xs text-destructive mt-1">{errors.email.message}</p>}
          </div>
          <div>
            <Textarea rows={3} {...register("message")} />
            {errors.message && <p className="text-xs text-destructive mt-1">{errors.message.message}</p>}
          </div>
          <Button type="submit" className="w-full" disabled={submitting}>
            {submitting
              ? <Loader2 className="w-4 h-4 mr-2 animate-spin" />
              : <MessageCircle className="w-4 h-4 mr-2" />
            }
            Send & Continue on WhatsApp
          </Button>
        </form>
      </DialogContent>
    </Dialog>
  );
}
EOF

cat > src/components/product-actions.tsx << 'EOF'
"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { EnquiryModal } from "@/components/enquiry-modal";
import { MessageCircle } from "lucide-react";

export function ProductActions({
  productId,
  productTitle,
  productSlug,
}: {
  productId: string;
  productTitle: string;
  productSlug: string;
}) {
  const [open, setOpen] = useState(false);

  return (
    <>
      <Button size="lg" className="w-full" onClick={() => setOpen(true)}>
        <MessageCircle className="w-4 h-4 mr-2" /> Enquire Now
      </Button>
      <EnquiryModal
        open={open}
        onOpenChange={setOpen}
        productId={productId}
        productTitle={productTitle}
        productSlug={productSlug}
      />
    </>
  );
}
EOF

cat > src/components/shop-filters.tsx << 'EOF'
"use client";

import { useRouter, useSearchParams, usePathname } from "next/navigation";
import { useState, useTransition } from "react";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Search, SlidersHorizontal } from "lucide-react";

interface Category { id: string; name: string; slug: string }

export function ShopFilters({ categories }: { categories: Category[] }) {
  const router = useRouter();
  const pathname = usePathname();
  const searchParams = useSearchParams();
  const [isPending, startTransition] = useTransition();
  const [search, setSearch] = useState(searchParams.get("q") ?? "");
  const [min, setMin] = useState(searchParams.get("min") ?? "");
  const [max, setMax] = useState(searchParams.get("max") ?? "");

  const updateParams = (updates: Record<string, string | null>) => {
    const params = new URLSearchParams(searchParams.toString());
    Object.entries(updates).forEach(([key, value]) => {
      if (value) params.set(key, value);
      else params.delete(key);
    });
    startTransition(() => router.push(`${pathname}?${params.toString()}`));
  };

  const activeCategory = searchParams.get("category");

  return (
    <div className="space-y-6">
      <form
        onSubmit={(e) => {
          e.preventDefault();
          updateParams({ q: search || null });
        }}
        className="relative"
      >
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
        <Input
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Search products..."
          className="pl-9"
        />
      </form>

      <div>
        <h3 className="text-sm font-medium mb-3 flex items-center gap-2">
          <SlidersHorizontal className="w-4 h-4" /> Category
        </h3>
        <div className="flex flex-wrap gap-2">
          <Button
            variant={!activeCategory ? "default" : "outline"}
            size="sm"
            onClick={() => updateParams({ category: null })}
          >
            All
          </Button>
          {categories.map((cat) => (
            <Button
              key={cat.id}
              variant={activeCategory === cat.slug ? "default" : "outline"}
              size="sm"
              onClick={() => updateParams({ category: cat.slug })}
            >
              {cat.name}
            </Button>
          ))}
        </div>
      </div>

      <div>
        <h3 className="text-sm font-medium mb-3">Price Range (KES)</h3>
        <div className="flex items-center gap-2">
          <Input
            type="number"
            placeholder="Min"
            value={min}
            onChange={(e) => setMin(e.target.value)}
            onBlur={() => updateParams({ min: min || null })}
          />
          <span className="text-muted-foreground">–</span>
          <Input
            type="number"
            placeholder="Max"
            value={max}
            onChange={(e) => setMax(e.target.value)}
            onBlur={() => updateParams({ max: max || null })}
          />
        </div>
      </div>

      {isPending && <p className="text-xs text-muted-foreground animate-pulse">Updating...</p>}
    </div>
  );
}
EOF

cat > src/components/admin/image-uploader.tsx << 'EOF'
"use client";

import { useState, useCallback } from "react";
import Image from "next/image";
import { X, Upload, Loader2 } from "lucide-react";

export interface UploadedImage {
  url: string;
  publicId: string;
}

interface Props {
  images: UploadedImage[];
  onChange: (images: UploadedImage[]) => void;
  maxImages?: number;
}

export function ImageUploader({ images, onChange, maxImages = 8 }: Props) {
  const [uploading, setUploading] = useState(false);
  const [progress, setProgress] = useState(0);

  const uploadFiles = useCallback(
    async (files: FileList) => {
      if (images.length + files.length > maxImages) {
        alert(`Max ${maxImages} images allowed`);
        return;
      }
      setUploading(true);
      try {
        const sigRes = await fetch("/api/upload");
        const { signature, timestamp, folder, apiKey, cloudName } = await sigRes.json();
        const uploaded: UploadedImage[] = [];

        for (let i = 0; i < files.length; i++) {
          const formData = new FormData();
          formData.append("file", files[i]);
          formData.append("api_key", apiKey);
          formData.append("timestamp", timestamp);
          formData.append("signature", signature);
          formData.append("folder", folder);

          const res = await fetch(
            `https://api.cloudinary.com/v1_1/${cloudName}/image/upload`,
            { method: "POST", body: formData }
          );
          const data = await res.json();
          uploaded.push({ url: data.secure_url, publicId: data.public_id });
          setProgress(Math.round(((i + 1) / files.length) * 100));
        }
        onChange([...images, ...uploaded]);
      } catch (err) {
        console.error("Upload failed", err);
        alert("Image upload failed. Try again.");
      } finally {
        setUploading(false);
        setProgress(0);
      }
    },
    [images, maxImages, onChange]
  );

  const removeImage = (publicId: string) =>
    onChange(images.filter((img) => img.publicId !== publicId));

  return (
    <div className="space-y-3">
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
        {images.map((img, idx) => (
          <div
            key={img.publicId}
            className="relative aspect-square rounded-lg overflow-hidden border border-border group"
          >
            <Image src={img.url} alt={`Product ${idx + 1}`} fill className="object-cover" />
            <button
              type="button"
              onClick={() => removeImage(img.publicId)}
              className="absolute top-1 right-1 bg-black/60 text-white rounded-full p-1 opacity-0 group-hover:opacity-100 transition-opacity"
            >
              <X className="w-3 h-3" />
            </button>
            {idx === 0 && (
              <span className="absolute bottom-1 left-1 text-xs bg-primary text-primary-foreground px-2 py-0.5 rounded">
                Cover
              </span>
            )}
          </div>
        ))}

        {images.length < maxImages && (
          <label className="aspect-square rounded-lg border-2 border-dashed border-border flex flex-col items-center justify-center cursor-pointer hover:border-primary transition-colors">
            {uploading ? (
              <>
                <Loader2 className="w-5 h-5 animate-spin mb-1 text-muted-foreground" />
                <span className="text-xs text-muted-foreground">{progress}%</span>
              </>
            ) : (
              <>
                <Upload className="w-5 h-5 mb-1 text-muted-foreground" />
                <span className="text-xs text-muted-foreground">Add photos</span>
              </>
            )}
            <input
              type="file"
              accept="image/*"
              multiple
              className="hidden"
              disabled={uploading}
              onChange={(e) => e.target.files && uploadFiles(e.target.files)}
            />
          </label>
        )}
      </div>
      <p className="text-xs text-muted-foreground">First image is the cover photo. Max {maxImages} images.</p>
    </div>
  );
}
EOF

cat > src/components/admin/product-form.tsx << 'EOF'
"use client";

import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { productSchema, ProductFormValues } from "@/lib/validations";
import { ImageUploader } from "./image-uploader";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Loader2 } from "lucide-react";

interface Category { id: string; name: string }

export function ProductForm({
  categories,
  initialData,
  productId,
}: {
  categories: Category[];
  initialData?: Partial<ProductFormValues>;
  productId?: string;
}) {
  const router = useRouter();
  const [submitting, setSubmitting] = useState(false);

  const {
    register,
    handleSubmit,
    watch,
    setValue,
    formState: { errors },
  } = useForm<ProductFormValues>({
    resolver: zodResolver(productSchema),
    defaultValues: initialData ?? {
      stockStatus: "IN_STOCK",
      featured: false,
      images: [],
      materials: [],
      dimensions: { unit: "cm", width: 0, height: 0, depth: 0 },
    },
  });

  const images = watch("images");

  const onSubmit = async (data: ProductFormValues) => {
    setSubmitting(true);
    try {
      const res = await fetch(
        productId ? `/api/products/${productId}` : "/api/products",
        {
          method: productId ? "PUT" : "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(data),
        }
      );
      if (!res.ok) throw new Error("Save failed");
      router.push("/admin/products");
      router.refresh();
    } catch {
      alert("Failed to save product. Check all required fields.");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-6 max-w-2xl">
      <div className="space-y-2">
        <label className="text-sm font-medium">Product Photos *</label>
        <ImageUploader
          images={images}
          onChange={(imgs) => setValue("images", imgs, { shouldValidate: true })}
        />
        {errors.images && (
          <p className="text-sm text-destructive">{errors.images.message as string}</p>
        )}
      </div>

      <div className="space-y-2">
        <label className="text-sm font-medium">Title *</label>
        <Input {...register("title")} placeholder="e.g. Oak Dining Table" />
        {errors.title && <p className="text-sm text-destructive">{errors.title.message}</p>}
      </div>

      <div className="space-y-2">
        <label className="text-sm font-medium">Description *</label>
        <Textarea {...register("description")} rows={5} placeholder="Detailed product description..." />
        {errors.description && <p className="text-sm text-destructive">{errors.description.message}</p>}
      </div>

      <div className="grid grid-cols-2 gap-4">
        <div className="space-y-2">
          <label className="text-sm font-medium">Price (KES) *</label>
          <Input type="number" step="0.01" {...register("price")} />
          {errors.price && <p className="text-sm text-destructive">{errors.price.message}</p>}
        </div>
        <div className="space-y-2">
          <label className="text-sm font-medium">Category *</label>
          <Select
            onValueChange={(v) => setValue("categoryId", v)}
            defaultValue={initialData?.categoryId}
          >
            <SelectTrigger><SelectValue placeholder="Select category" /></SelectTrigger>
            <SelectContent>
              {categories.map((c) => (
                <SelectItem key={c.id} value={c.id}>{c.name}</SelectItem>
              ))}
            </SelectContent>
          </Select>
          {errors.categoryId && <p className="text-sm text-destructive">{errors.categoryId.message}</p>}
        </div>
      </div>

      <div className="grid grid-cols-4 gap-4">
        <div className="space-y-2">
          <label className="text-sm font-medium">Width (cm)</label>
          <Input type="number" step="0.1" {...register("dimensions.width")} />
        </div>
        <div className="space-y-2">
          <label className="text-sm font-medium">Height (cm)</label>
          <Input type="number" step="0.1" {...register("dimensions.height")} />
        </div>
        <div className="space-y-2">
          <label className="text-sm font-medium">Depth (cm)</label>
          <Input type="number" step="0.1" {...register("dimensions.depth")} />
        </div>
        <div className="space-y-2">
          <label className="text-sm font-medium">Stock</label>
          <Select
            onValueChange={(v) => setValue("stockStatus", v as any)}
            defaultValue={initialData?.stockStatus ?? "IN_STOCK"}
          >
            <SelectTrigger><SelectValue /></SelectTrigger>
            <SelectContent>
              <SelectItem value="IN_STOCK">In Stock</SelectItem>
              <SelectItem value="OUT_OF_STOCK">Out of Stock</SelectItem>
              <SelectItem value="MADE_TO_ORDER">Made to Order</SelectItem>
            </SelectContent>
          </Select>
        </div>
      </div>

      <div className="space-y-2">
        <label className="text-sm font-medium">Materials (comma separated) *</label>
        <Input
          placeholder="Oak wood, Brass, Leather"
          defaultValue={initialData?.materials?.join(", ")}
          onChange={(e) =>
            setValue(
              "materials",
              e.target.value.split(",").map((m) => m.trim()).filter(Boolean)
            )
          }
        />
        {errors.materials && <p className="text-sm text-destructive">{errors.materials.message as string}</p>}
      </div>

      <label className="flex items-center gap-2 text-sm cursor-pointer">
        <input type="checkbox" {...register("featured")} className="w-4 h-4 rounded" />
        Feature this product on the homepage
      </label>

      <Button type="submit" disabled={submitting} className="w-full">
        {submitting && <Loader2 className="w-4 h-4 mr-2 animate-spin" />}
        {productId ? "Update Product" : "Create Product"}
      </Button>
    </form>
  );
}
EOF

# ─── APP LAYOUT ───────────────────────────────────────────────

cat > src/app/layout.tsx << 'EOF'
import type { Metadata } from "next";
import { GeistSans } from "geist/font/sans";
import "./globals.css";
import { ThemeProvider } from "next-themes";
import { Header } from "@/components/header";
import { Footer } from "@/components/footer";

export const metadata: Metadata = {
  title: "Alkosphre Furniture | Handcrafted Furniture in Kenya",
  description: "Elegant, handcrafted furniture made in Kenya.",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className={GeistSans.className}>
        <ThemeProvider attribute="class" defaultTheme="light" enableSystem>
          <Header />
          <main className="min-h-screen">{children}</main>
          <Footer />
        </ThemeProvider>
      </body>
    </html>
  );
}
EOF

# ─── HOMEPAGE ─────────────────────────────────────────────────

cat > src/app/page.tsx << 'EOF'
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
EOF

# ─── SHOP PAGE ────────────────────────────────────────────────

cat > "src/app/(shop)/shop/page.tsx" << 'EOF'
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
  searchParams: { category?: string; q?: string; min?: string; max?: string };
}) {
  const { category, q, min, max } = searchParams;

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
EOF

# ─── PRODUCT DETAIL PAGE ──────────────────────────────────────

cat > "src/app/(shop)/product/[slug]/page.tsx" << 'EOF'
import { notFound } from "next/navigation";
import { prisma } from "@/lib/prisma";
import { ProductGallery } from "@/components/product-gallery";
import { ProductActions } from "@/components/product-actions";
import { Ruler, Layers, Package, Tag } from "lucide-react";

export async function generateMetadata({ params }: { params: { slug: string } }) {
  const product = await prisma.product.findUnique({ where: { slug: params.slug } });
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

export default async function ProductPage({ params }: { params: { slug: string } }) {
  const product = await prisma.product.findUnique({
    where: { slug: params.slug },
    include: {
      images: { orderBy: { order: "asc" } },
      category: true,
    },
  });

  if (!product) notFound();

  const dims = product.dimensions as {
    width: number; height: number; depth: number; unit: string;
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

          <p className="text-muted-foreground leading-relaxed mb-8">{product.description}</p>

          <div className="space-y-4 mb-8 border-t border-border pt-6">
            <div className="flex items-start gap-3">
              <Ruler className="w-5 h-5 text-muted-foreground mt-0.5 shrink-0" />
              <div>
                <p className="text-sm font-medium">Dimensions</p>
                <p className="text-sm text-muted-foreground">
                  {dims.width} × {dims.height} × {dims.depth} {dims.unit} (W × H × D)
                </p>
              </div>
            </div>
            <div className="flex items-start gap-3">
              <Layers className="w-5 h-5 text-muted-foreground mt-0.5 shrink-0" />
              <div>
                <p className="text-sm font-medium">Materials</p>
                <p className="text-sm text-muted-foreground">{product.materials.join(", ")}</p>
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
                <p className="text-sm text-muted-foreground">{product.category.name}</p>
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
EOF

# ─── API ROUTES ───────────────────────────────────────────────

cat > src/app/api/auth/\[...nextauth\]/route.ts << 'EOF'
import NextAuth from "next-auth";
import { authOptions } from "@/lib/auth";

const handler = NextAuth(authOptions);
export { handler as GET, handler as POST };
EOF

cat > src/app/api/upload/route.ts << 'EOF'
import { NextResponse } from "next/server";
import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/auth";
import cloudinary from "@/lib/cloudinary";

export async function GET() {
  const session = await getServerSession(authOptions);
  if (!session) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

  const timestamp = Math.round(Date.now() / 1000);
  const folder = "furniture-shop/products";

  const signature = cloudinary.utils.api_sign_request(
    { timestamp, folder },
    process.env.CLOUDINARY_API_SECRET!
  );

  return NextResponse.json({
    signature,
    timestamp,
    folder,
    apiKey: process.env.CLOUDINARY_API_KEY,
    cloudName: process.env.CLOUDINARY_CLOUD_NAME,
  });
}
EOF

cat > src/app/api/products/route.ts << 'EOF'
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
EOF

cat > "src/app/api/products/[id]/route.ts" << 'EOF'
import { NextResponse } from "next/server";
import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/auth";
import { prisma } from "@/lib/prisma";
import { productSchema } from "@/lib/validations";

export async function PUT(req: Request, { params }: { params: { id: string } }) {
  const session = await getServerSession(authOptions);
  if (!session) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

  const body = await req.json();
  const parsed = productSchema.safeParse(body);
  if (!parsed.success)
    return NextResponse.json({ error: parsed.error.flatten() }, { status: 400 });

  const data = parsed.data;

  // Replace images: delete old, insert new
  await prisma.productImage.deleteMany({ where: { productId: params.id } });

  const product = await prisma.product.update({
    where: { id: params.id },
    data: {
      title: data.title,
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

  return NextResponse.json(product);
}

export async function DELETE(_req: Request, { params }: { params: { id: string } }) {
  const session = await getServerSession(authOptions);
  if (!session) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

  await prisma.product.delete({ where: { id: params.id } });
  return NextResponse.json({ success: true });
}
EOF

cat > src/app/api/enquiry/route.ts << 'EOF'
import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { enquirySchema } from "@/lib/validations";
import { sendEnquiryEmail } from "@/lib/email";

export async function POST(req: Request) {
  const body = await req.json();
  const parsed = enquirySchema.safeParse(body);
  if (!parsed.success)
    return NextResponse.json({ error: parsed.error.flatten() }, { status: 400 });

  const enquiry = await prisma.enquiry.create({ data: parsed.data });
  sendEnquiryEmail(parsed.data).catch(console.error);

  return NextResponse.json(enquiry, { status: 201 });
}
EOF

echo ""
echo "✅ All components created"
echo "✅ App layout created"
echo "✅ Homepage created"
echo "✅ Shop page created"
echo "✅ Product detail page created"
echo "✅ All API routes created"
echo ""
echo "Next: install geist font → npm install geist"
echo "Then: npm run dev"