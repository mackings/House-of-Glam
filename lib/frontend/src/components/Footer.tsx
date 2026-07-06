const columns = [
  {
    title: "Customers",
    links: ["Custom Orders", "Ready-to-Wear", "Pre-Loved", "Track an Order"],
  },
  {
    title: "Designers",
    links: ["Apply as a Designer", "Subscription Plans", "Growth Analytics", "Designer Support"],
  },
  {
    title: "Company",
    links: ["About Us", "Payment Protection", "Help Center", "Contact"],
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
                    <li key={link}>
                      <a
                        href="#"
                        className="text-sm text-subtext transition-colors hover:text-accent"
                      >
                        {link}
                      </a>
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
            <a href="#" className="hover:text-accent">Privacy Policy</a>
            <a href="#" className="hover:text-accent">Terms of Service</a>
          </div>
        </div>
      </div>
    </footer>
  );
}
