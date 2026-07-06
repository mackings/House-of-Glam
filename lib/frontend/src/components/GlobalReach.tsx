import Image from "next/image";
import { images } from "@/lib/images";

export default function GlobalReach() {
  return (
    <section className="bg-surface-muted py-24">
      <div className="mx-auto max-w-7xl px-6 lg:px-8">
        <div className="grid items-center gap-14 lg:grid-cols-2">
          <div className="relative aspect-[4/5] w-full overflow-hidden rounded-[1.75rem] shadow-xl shadow-black/10">
            <Image
              src={images.global}
              alt="Smiling woman wearing a vibrant printed African dress"
              fill
              sizes="(min-width: 1024px) 40vw, 90vw"
              className="object-cover"
            />
          </div>

          <div>
            <p className="text-sm font-bold uppercase tracking-[0.25em] text-secondary-deep">
              Built for a Global Community
            </p>
            <h2 className="mt-4 font-display text-4xl font-bold leading-tight text-ink sm:text-5xl">
              From Nigeria to the diaspora.
            </h2>
            <p className="mt-6 text-lg leading-relaxed text-subtext">
              Discover designers, explore styles, and connect with a global
              community of fashion lovers, wherever culture and couture take
              you.
            </p>

            <div className="mt-10 grid grid-cols-3 gap-6 border-t border-border pt-8">
              {[
                ["Designers", "Verified, local & diaspora"],
                ["Styles", "Custom, ready-to-wear, pre-loved"],
                ["Reach", "Local & international delivery"],
              ].map(([label, desc]) => (
                <div key={label}>
                  <p className="font-display text-lg font-bold text-accent">{label}</p>
                  <p className="mt-1 text-xs text-subtext">{desc}</p>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
