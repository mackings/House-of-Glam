import type { Metadata } from "next";
import { Plus_Jakarta_Sans, Playfair_Display } from "next/font/google";
import "./globals.css";

const jakarta = Plus_Jakarta_Sans({
  variable: "--font-jakarta",
  subsets: ["latin"],
  display: "swap",
});

const playfair = Playfair_Display({
  variable: "--font-playfair",
  subsets: ["latin"],
  display: "swap",
});

export const metadata: Metadata = {
  title: "House of GLAME | Where Culture Meets Couture",
  description:
    "House of GLAME is a marketplace connecting you with Africa's finest fashion designers for custom-made, ready-to-wear, and pre-loved clothing, with escrow-protected payments and real-time order tracking.",
  keywords: [
    "House of GLAME",
    "African fashion",
    "custom tailoring",
    "bespoke fashion",
    "African designers",
    "ready-to-wear",
    "fashion marketplace",
  ],
  openGraph: {
    title: "House of GLAME | Where Culture Meets Couture",
    description:
      "Authentically African. Globally Styled. Discover custom-made, ready-to-wear, and pre-loved fashion from Africa's finest designers.",
    type: "website",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="en"
      className={`${jakarta.variable} ${playfair.variable} h-full antialiased`}
    >
      <body className="min-h-full flex flex-col bg-canvas text-ink">
        {children}
      </body>
    </html>
  );
}
