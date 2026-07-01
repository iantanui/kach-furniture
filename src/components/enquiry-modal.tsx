"use client";

import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { useState } from "react";
import { enquirySchema, EnquiryFormValues } from "@/lib/validations";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { buildWhatsAppLink } from "@/lib/whatsapp";
import { MessageCircle, Loader2 } from "lucide-react";

export function EnquiryModal({
  open,
  onOpenChange,
  productId,
  productTitle,
  productSlug,
}: {
  open: boolean;
  onOpenChange: (v: boolean) => void;
  productId: string;
  productTitle: string;
  productSlug: string;
}) {
  const [submitting, setSubmitting] = useState(false);
  const {
    register,
    handleSubmit,
    reset,
    formState: { errors },
  } = useForm<EnquiryFormValues>({
    resolver: zodResolver(enquirySchema),
    defaultValues: {
      productId,
      message: `Hi, I'm interested in the "${productTitle}". Is it available?`,
    },
  });

  const onSubmit = async (data: EnquiryFormValues) => {
    setSubmitting(true);
    try {
      await fetch("/api/enquiry", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(data),
      });

      const waLink = buildWhatsAppLink({
        phoneNumber: process.env.NEXT_PUBLIC_SHOP_WHATSAPP!,
        productTitle,
        productUrl: `${window.location.origin}/product/${productSlug}`,
        customerName: data.name,
      });

      window.open(waLink, "_blank");
      reset();
      onOpenChange(false);
    } catch {
      alert("Failed to send enquiry. Please try WhatsApp directly.");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>Enquire about {productTitle}</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          <input type="hidden" {...register("productId")} />
          <div>
            <Input placeholder="Your name" {...register("name")} />
            {errors.name && <p className="text-xs text-destructive mt-1">{errors.name.message}</p>}
          </div>
          <div>
            <Input placeholder="Phone (e.g. 0712345678)" {...register("phone")} />
            {errors.phone && <p className="text-xs text-destructive mt-1">{errors.phone.message}</p>}
          </div>
          <div>
            <Input type="email" placeholder="Email address" {...register("email")} />
            {errors.email && <p className="text-xs text-destructive mt-1">{errors.email.message}</p>}
          </div>
          <div>
            <Textarea rows={3} {...register("message")} />
            {errors.message && <p className="text-xs text-destructive mt-1">{errors.message.message}</p>}
          </div>
          <Button type="submit" className="w-full" disabled={submitting}>
            {submitting
              ? <Loader2 className="w-4 h-4 mr-2 animate-spin" />
              : <MessageCircle className="w-4 h-4 mr-2" />
            }
            Send & Continue on WhatsApp
          </Button>
        </form>
      </DialogContent>
    </Dialog>
  );
}
