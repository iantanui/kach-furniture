"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { EnquiryModal } from "@/components/enquiry-modal";
import { MessageCircle } from "lucide-react";

export function ProductActions({
  productId,
  productTitle,
  productSlug,
}: {
  productId: string;
  productTitle: string;
  productSlug: string;
}) {
  const [open, setOpen] = useState(false);

  return (
    <>
      <Button size="lg" className="w-full" onClick={() => setOpen(true)}>
        <MessageCircle className="w-4 h-4 mr-2" /> Enquire Now
      </Button>
      <EnquiryModal
        open={open}
        onOpenChange={setOpen}
        productId={productId}
        productTitle={productTitle}
        productSlug={productSlug}
      />
    </>
  );
}
