import { Resend } from "resend";
import { EnquiryFormValues } from "./validations";

const resend = new Resend(process.env.RESEND_API_KEY);

export async function sendEnquiryEmail(data: EnquiryFormValues) {
  await resend.emails.send({
    from: "Alkosphere Furniture Shop <onboarding@resend.dev>",
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
