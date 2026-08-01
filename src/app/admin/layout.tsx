import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Admin | Alkosphere Furniture",
};

export default function AdminRootLayout({ children }: { children: React.ReactNode }) {
  return children;
}
