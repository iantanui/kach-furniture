#!/bin/bash
set -e

mkdir -p src/lib
mkdir -p src/components/ui
mkdir -p src/components/admin
mkdir -p "src/app/(shop)/shop"
mkdir -p "src/app/(shop)/product/[slug]"
mkdir -p src/app/admin/products
mkdir -p src/app/api/products
mkdir -p src/app/api/upload
mkdir -p src/app/api/enquiry
mkdir -p src/app/api/auth/\[...nextauth\]

# lib/prisma.ts
cat > src/lib/prisma.ts << 'EOF'
import { PrismaClient } from "@prisma/client";

const globalForPrisma = globalThis as unknown as { prisma: PrismaClient };

export const prisma = globalForPrisma.prisma || new PrismaClient();

if (process.env.NODE_ENV !== "production") globalForPrisma.prisma = prisma;
EOF

# lib/cloudinary.ts
cat > src/lib/cloudinary.ts << 'EOF'
import { v2 as cloudinary } from "cloudinary";

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

export default cloudinary;

export async function deleteCloudinaryImage(publicId: string) {
  return cloudinary.uploader.destroy(publicId);
}
EOF

# lib/auth.ts
cat > src/lib/auth.ts << 'EOF'
import { NextAuthOptions } from "next-auth";
import CredentialsProvider from "next-auth/providers/credentials";
import { prisma } from "@/lib/prisma";
import bcrypt from "bcryptjs";

export const authOptions: NextAuthOptions = {
  session: { strategy: "jwt" },
  pages: { signIn: "/admin/login" },
  providers: [
    CredentialsProvider({
      name: "credentials",
      credentials: {
        email: { label: "Email", type: "email" },
        password: { label: "Password", type: "password" },
      },
      async authorize(credentials) {
        if (!credentials?.email || !credentials?.password) return null;
        const admin = await prisma.admin.findUnique({ where: { email: credentials.email } });
        if (!admin) return null;
        const valid = await bcrypt.compare(credentials.password, admin.password);
        if (!valid) return null;
        return { id: admin.id, email: admin.email, name: admin.name };
      },
    }),
  ],
  callbacks: {
    async jwt({ token, user }) {
      if (user) token.id = (user as any).id;
      return token;
    },
    async session({ session, token }) {
      if (session.user) (session.user as any).id = token.id;
      return session;
    },
  },
};
EOF

# lib/whatsapp.ts
cat > src/lib/whatsapp.ts << 'EOF'
export function buildWhatsAppLink({
  phoneNumber,
  productTitle,
  productUrl,
  customerName,
}: {
  phoneNumber: string;
  productTitle?: string;
  productUrl?: string;
  customerName?: string;
}) {
  const lines = [
    `Hi, I'm ${customerName ?? "interested in"} this product:`,
    productTitle ? `*${productTitle}*` : "",
    productUrl ? productUrl : "",
    "Could you share more details and availability?",
  ].filter(Boolean);

  const text = encodeURIComponent(lines.join("\n"));
  return `https://wa.me/${phoneNumber}?text=${text}`;
}
EOF

# lib/validations.ts
cat > src/lib/validations.ts << 'EOF'
import { z } from "zod";

export const productSchema = z.object({
  title: z.string().min(3, "Title too short"),
  description: z.string().min(20, "Description too short"),
  price: z.coerce.number().positive("Price must be positive"),
  categoryId: z.string().min(1, "Select a category"),
  materials: z.array(z.string()).min(1, "Add at least one material"),
  dimensions: z.object({
    width: z.coerce.number().positive(),
    height: z.coerce.number().positive(),
    depth: z.coerce.number().positive(),
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
EOF

# lib/email.ts
cat > src/lib/email.ts << 'EOF'
import { Resend } from "resend";
import { EnquiryFormValues } from "./validations";

const resend = new Resend(process.env.RESEND_API_KEY);

export async function sendEnquiryEmail(data: EnquiryFormValues) {
  await resend.emails.send({
    from: "Furniture Shop <enquiries@yourdomain.com>",
    to: process.env.SHOP_NOTIFICATION_EMAIL!,
    subject: `New Enquiry from ${data.name}`,
    html: `
      <h2>New Product Enquiry</h2>
      <p><strong>Name:</strong> ${data.name}</p>
      <p><strong>Phone:</strong> ${data.phone}</p>
      <p><strong>Email:</strong> ${data.email}</p>
      <p><strong>Message:</strong> ${data.message}</p>
    `,
  });
}
EOF

echo "✅ lib files created"
echo "✅ Folder structure created"
echo "Next: paste schema.prisma, .env.example, and run npm installs"
