import Image from "next/image";
import { images } from "@/lib/images";

const steps = [
  {
    number: "01",
    title: "Share your vision",
    description:
      "Save fitted, casual, native, or custom sizing profiles and tell designers exactly what you're picturing.",
  },
  {
    number: "02",
    title: "Compare smart quotes",
    description:
      "Review refined quotes from designers, ask questions, and choose the one that fits your vision and budget.",
  },
  {
    number: "03",
    title: "Approve & pay securely",
    description:
      "Pay a deposit or balance into escrow. Funds are held safely until your order is confirmed delivered.",
  },
  {
    number: "04",
    title: "Track to delivery",
    description:
      "Follow every step from design approval to delivery with real-time updates, locally and globally.",
  },
];

export default function HowItWorks() {
  return (
    <section id="how-it-works" className="mx-auto max-w-7xl px-6 py-24 lg:px-8">
      <div className="grid gap-16 lg:grid-cols-2 lg:items-center">
        <div>
          <p className="text-sm font-bold uppercase tracking-[0.25em] text-secondary-deep">
            How It Works
          </p>
          <h2 className="mt-4 font-display text-4xl font-bold leading-tight text-ink sm:text-5xl">
            From vision to masterpiece.
          </h2>
          <p className="mt-5 max-w-md text-lg text-subtext">
            Simple, transparent, and refined: every custom order moves through
            the same trusted flow.
          </p>

          <ol className="mt-10 space-y-8">
            {steps.map((step) => (
              <li key={step.number} className="flex gap-5">
                <span className="flex h-11 w-11 shrink-0 items-center justify-center rounded-full bg-accent font-display text-sm font-bold text-white">
                  {step.number}
                </span>
                <div>
                  <h3 className="font-bold text-ink">{step.title}</h3>
                  <p className="mt-1 text-sm leading-relaxed text-subtext">
                    {step.description}
                  </p>
                </div>
              </li>
            ))}
          </ol>
        </div>

        <div className="relative aspect-[4/5] w-full overflow-hidden rounded-[1.75rem] shadow-xl shadow-black/10 lg:aspect-auto lg:h-[640px]">
          <Image
            src={images.howItWorks}
            alt="Close-up of hands guiding teal fabric through a sewing machine"
            fill
            sizes="(min-width: 1024px) 45vw, 90vw"
            className="object-cover"
          />
        </div>
      </div>
    </section>
  );
}
