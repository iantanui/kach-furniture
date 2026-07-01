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
          <span className="font-semibold text-sm">Maridadi Admin</span>
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
