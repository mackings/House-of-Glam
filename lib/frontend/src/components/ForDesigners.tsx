import Image from "next/image";
import { images } from "@/lib/images";

const tools = [
  "Portfolio & media showcase",
  "Quote & order workflow",
  "Growth analytics dashboard",
  "Escrow wallet visibility",
  "Flexible subscription plans",
  "Direct customer messaging",
];

export default function ForDesigners() {
  return (
    <section id="designers" className="mx-auto max-w-7xl px-6 py-24 lg:px-8">
      <div className="grid items-center gap-14 lg:grid-cols-2">
        <div className="order-2 lg:order-1">
          <p className="text-sm font-bold uppercase tracking-[0.25em] text-secondary-deep">
            For Designers &amp; Tailors
          </p>
          <h2 className="mt-4 font-display text-4xl font-bold leading-tight text-ink sm:text-5xl">
            Build and grow your fashion brand.
          </h2>
          <p className="mt-6 text-lg leading-relaxed text-subtext">
            Showcase your craft, manage orders seamlessly, and reach a global
            audience of customers actively looking for work like yours.
          </p>

          <ul className="mt-8 grid grid-cols-1 gap-3 sm:grid-cols-2">
            {tools.map((tool) => (
              <li key={tool} className="flex items-center gap-3 text-sm font-medium text-ink">
                <span className="flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-accent-soft text-accent">
                  <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3">
                    <path d="m5 13 4 4L19 7" strokeLinecap="round" strokeLinejoin="round" />
                  </svg>
                </span>
                {tool}
              </li>
            ))}
          </ul>

          <a
            href="#cta"
            className="mt-10 inline-block rounded-full bg-accent px-7 py-3.5 text-sm font-bold text-white shadow-sm transition-transform hover:-translate-y-0.5 hover:bg-accent-deep"
          >
            Apply as a Designer
          </a>
        </div>

        <div className="order-1 relative aspect-[4/5] w-full overflow-hidden rounded-[1.75rem] shadow-xl shadow-black/10 lg:order-2">
          <Image
            src={images.designers}
            alt="Smiling woman wearing a colorful African-print dashiki top"
            fill
            sizes="(min-width: 1024px) 40vw, 90vw"
            className="object-cover"
          />
        </div>
      </div>
    </section>
  );
}
