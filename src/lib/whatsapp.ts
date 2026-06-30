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
