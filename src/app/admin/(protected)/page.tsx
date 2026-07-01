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
