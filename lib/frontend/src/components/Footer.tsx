import Link from "next/link";

const columns = [
  {
    title: "Customers",
    links: [
      { label: "Custom Orders", href: "/designers" },
      { label: "Ready-to-Wear", href: "/designers" },
      { label: "Pre-Loved", href: "/designers" },
      { label: "Track an Order", href: "/track" },
    ],
  },
  {
    title: "Designers",
    links: [
      { label: "Apply as a Designer", href: "/#designers" },
      { label: "Subscription Plans", href: "#" },
      { label: "Growth Analytics", href: "#" },
      { label: "Designer Support", href: "#" },
    ],
  },
  {
    title: "Company",
    links: [
      { label: "About Us", href: "/#top" },
      { label: "Payment Protection", href: "/#protection" },
      { label: "Help Center", href: "#" },
      { label: "Contact", href: "#" },
      { label: "Delete My Account", href: "/delete-account" },
    ],
  },
];

export default function Footer() {
  return (
    <footer className="border-t border-border bg-canvas">
      <div className="mx-auto max-w-7xl px-6 py-16 lg:px-8">
        <div className="grid gap-12 lg:grid-cols-[1.5fr_2fr]">
          <div>
            <span className="font-display text-xl font-bold text-ink">
              House of GLAME
            </span>
            <p className="mt-4 max-w-xs text-sm leading-relaxed text-subtext">
              Where Culture Meets Couture. Authentically African, globally
              styled: a home for custom-made, ready-to-wear, and pre-loved
              fashion.
            </p>
          </div>

          <div className="grid grid-cols-2 gap-8 sm:grid-cols-3">
            {columns.map((col) => (
              <div key={col.title}>
                <h4 className="text-sm font-bold text-ink">{col.title}</h4>
                <ul className="mt-4 space-y-3">
                  {col.links.map((link) => (
                    <li key={link.label}>
                      <Link
                        href={link.href}
                        className="text-sm text-subtext transition-colors hover:text-accent"
                      >
                        {link.label}
                      </Link>
                    </li>
                  ))}
                </ul>
              </div>
            ))}
          </div>
        </div>

        <div className="mt-14 flex flex-col items-center justify-between gap-4 border-t border-border pt-8 sm:flex-row">
          <p className="text-xs text-subtext">
            © {new Date().getFullYear()} House of GLAME. All rights reserved.
          </p>
          <div className="flex gap-5 text-xs text-subtext">
            <Link href="/privacy" className="hover:text-accent">Privacy Policy</Link>
            <a href="#" className="hover:text-accent">Terms of Service</a>
          </div>
        </div>
      </div>
    </footer>
  );
}
