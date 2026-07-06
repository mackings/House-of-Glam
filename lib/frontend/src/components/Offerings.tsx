import Image from "next/image";
import { images } from "@/lib/images";

const offerings = [
  {
    title: "Custom-Made",
    image: images.customMade,
    alt: "Tailor's hands guiding fabric through a sewing machine",
    description:
      "Share your vision, save your measurements, and get matched with designers who bring it to life, with quotes you can compare before you commit.",
  },
  {
    title: "Ready-to-Wear",
    image: images.readyToWear,
    alt: "Model wearing a flowing pink ready-to-wear dress",
    description:
      "Browse and order already-published pieces straight from designer collections. No waiting on a custom build when you want it now.",
  },
  {
    title: "Pre-Loved",
    image: images.preLoved,
    alt: "Curated rack of pre-loved clothing in a boutique",
    description:
      "Discover curated, gently-worn fashion finds: a sustainable way to shop standout pieces at a fraction of the price.",
  },
];

export default function Offerings() {
  return (
    <section id="offerings" className="bg-surface-muted py-24">
      <div className="mx-auto max-w-7xl px-6 lg:px-8">
        <div className="max-w-2xl">
          <p className="text-sm font-bold uppercase tracking-[0.25em] text-secondary-deep">
            What You Can Do
          </p>
          <h2 className="mt-4 font-display text-4xl font-bold leading-tight text-ink sm:text-5xl">
            Three ways to wear House of GLAME.
          </h2>
        </div>

        <div className="mt-14 grid gap-8 md:grid-cols-3">
          {offerings.map((item) => (
            <div
              key={item.title}
              className="group overflow-hidden rounded-3xl bg-surface shadow-sm shadow-black/5 ring-1 ring-border transition-shadow hover:shadow-lg"
            >
              <div className="relative aspect-[4/3] w-full overflow-hidden">
                <Image
                  src={item.image}
                  alt={item.alt}
                  fill
                  sizes="(min-width: 768px) 33vw, 100vw"
                  className="object-cover transition-transform duration-500 group-hover:scale-105"
                />
              </div>
              <div className="p-7">
                <h3 className="font-display text-xl font-bold text-ink">{item.title}</h3>
                <p className="mt-3 text-sm leading-relaxed text-subtext">
                  {item.description}
                </p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
