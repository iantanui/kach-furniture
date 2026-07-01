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
