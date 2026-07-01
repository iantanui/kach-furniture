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
    where: { email: "admin@maridadi.co.ke" },
    update: {},
    create: {
      email: "admin@maridadi.co.ke",
      password: hashed,
      name: "Admin",
    },
  });

  console.log("✅ Seed complete");
  console.log("   Admin: admin@maridadi.co.ke / admin123");
}

main().catch(console.error).finally(() => prisma.$disconnect());
