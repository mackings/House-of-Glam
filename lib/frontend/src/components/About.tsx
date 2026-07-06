import Image from "next/image";
import { images } from "@/lib/images";

export default function About() {
  return (
    <section className="mx-auto max-w-7xl px-6 py-24 lg:px-8">
      <div className="grid items-center gap-14 lg:grid-cols-2">
        <div className="relative">
          <div className="absolute -inset-4 -z-10 rounded-[2rem] bg-secondary-soft/60" />
          <div className="relative aspect-[4/5] w-full overflow-hidden rounded-[1.75rem] shadow-xl shadow-black/10">
            <Image
              src={images.about}
              alt="Woman wearing a vibrant kente headwrap and dress, celebrating African design craftsmanship"
              fill
              sizes="(min-width: 1024px) 40vw, 90vw"
              className="object-cover"
            />
          </div>
        </div>

        <div>
          <p className="text-sm font-bold uppercase tracking-[0.25em] text-secondary-deep">
            About House of GLAME
          </p>
          <h2 className="mt-4 font-display text-4xl font-bold leading-tight text-ink sm:text-5xl">
            A home for African fashion, built on trust.
          </h2>
          <p className="mt-6 text-lg leading-relaxed text-subtext">
            From Lagos to the diaspora, House of GLAME brings customers face-to-face
            with Africa&apos;s most talented tailors and designers. Share your vision,
            compare transparent quotes, and watch your outfit come to life, or
            browse ready-to-wear and pre-loved pieces already made with care.
          </p>
          <p className="mt-4 text-lg leading-relaxed text-subtext">
            Every order is backed by milestone escrow payments, verified reviews,
            and a support team ready to step in, so you can shop and create with
            confidence, wherever you are in the world.
          </p>

          <dl className="mt-10 grid grid-cols-2 gap-8 sm:grid-cols-3">
            {[
              ["Custom", "requests routed to the right designer"],
              ["Escrow", "held until delivery is confirmed"],
              ["Global", "reach across the diaspora"],
            ].map(([term, desc]) => (
              <div key={term}>
                <dt className="font-display text-2xl font-bold text-accent">{term}</dt>
                <dd className="mt-1 text-sm text-subtext">{desc}</dd>
              </div>
            ))}
          </dl>
        </div>
      </div>
    </section>
  );
}
