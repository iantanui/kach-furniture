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
      dimensions: { unit: "cm", length: 0, width: 0, height: 0},
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
          <label className="text-sm font-medium">Length (cm)</label>
          <Input type="number" step="0.1" {...register("dimensions.length")} />
        </div>
        <div className="space-y-2">
          <label className="text-sm font-medium">Width (cm)</label>
          <Input type="number" step="0.1" {...register("dimensions.width")} />
        </div>
        <div className="space-y-2">
          <label className="text-sm font-medium">Height (cm)</label>
          <Input type="number" step="0.1" {...register("dimensions.height")} />
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
