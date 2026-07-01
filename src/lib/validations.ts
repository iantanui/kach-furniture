import { z } from "zod";

export const productSchema = z.object({
  title: z.string().min(3, "Title too short"),
  description: z.string().min(20, "Description too short"),
  price: z.coerce.number().positive("Price must be positive"),
  categoryId: z.string().min(1, "Select a category"),
  materials: z.array(z.string()).min(1, "Add at least one material"),
  dimensions: z.object({
    length: z.coerce.number().positive(),
    width: z.coerce.number().positive(),
    height: z.coerce.number().positive(),
    unit: z.enum(["cm", "in"]).default("cm"),
  }),
  stockStatus: z.enum(["IN_STOCK", "OUT_OF_STOCK", "MADE_TO_ORDER"]),
  featured: z.boolean().default(false),
  images: z.array(z.object({ url: z.string(), publicId: z.string() })).min(1, "Add at least one image"),
});

export type ProductFormValues = z.infer<typeof productSchema>;

export const enquirySchema = z.object({
  name: z.string().min(2),
  phone: z.string().min(10, "Enter a valid phone number"),
  email: z.string().email(),
  message: z.string().min(5),
  productId: z.string().optional(),
});

export type EnquiryFormValues = z.infer<typeof enquirySchema>;
