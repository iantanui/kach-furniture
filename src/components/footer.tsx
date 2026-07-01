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
            <li>Kachibora, Kenya</li>
            <li>
              <a
                href={"https://wa.me/" + process.env.NEXT_PUBLIC_SHOP_WHATSAPP}
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
    </footer >
  );
}
