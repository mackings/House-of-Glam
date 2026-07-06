import Image from "next/image";
import { images } from "@/lib/images";

const badges = ["Custom-Made", "Ready-to-Wear", "Pre-Loved"];

export default function Hero() {
  return (
    <section id="top" className="relative isolate flex min-h-screen items-center overflow-hidden bg-accent-deep">
      <Image
        src={images.hero}
        alt="Model wearing an ornate gold couture look, representing House of GLAME's curated designer fashion"
        fill
        preload
        sizes="100vw"
        className="object-cover object-top opacity-70"
      />
      <div className="absolute inset-0 bg-gradient-to-t from-accent-deep via-accent-deep/70 to-accent-deep/30" />
      <div className="absolute inset-0 bg-gradient-to-r from-accent-deep/80 via-transparent to-transparent" />

      <div className="relative mx-auto flex w-full max-w-7xl flex-col px-6 pt-32 pb-20 lg:px-8">
        <p className="animate-fade-up text-sm font-bold uppercase tracking-[0.3em] text-secondary-soft">
          Where Culture Meets Couture
        </p>
        <h1 className="mt-6 max-w-2xl animate-fade-up font-display text-5xl font-bold leading-[1.05] text-white sm:text-6xl lg:text-7xl">
          Authentically African.
          <br />
          Globally Styled.
        </h1>
        <p className="mt-6 max-w-xl animate-fade-up text-lg leading-relaxed text-white/85">
          House of GLAME connects you with Africa&apos;s finest fashion designers
          for custom-made pieces, curated ready-to-wear, and pre-loved finds,
          with every payment protected from quote to delivery.
        </p>

        <div className="mt-10 flex flex-wrap items-center gap-4 animate-fade-up">
          <a
            href="#offerings"
            className="rounded-full bg-secondary px-7 py-3.5 text-sm font-bold text-accent-deep shadow-lg shadow-black/20 transition-transform hover:-translate-y-0.5"
          >
            Explore the Collection
          </a>
          <a
            href="#designers"
            className="rounded-full border border-white/40 px-7 py-3.5 text-sm font-bold text-white transition-colors hover:bg-white/10"
          >
            Become a Designer
          </a>
        </div>

        <div className="mt-14 flex flex-wrap gap-3 animate-fade-up">
          {badges.map((badge) => (
            <span
              key={badge}
              className="rounded-full border border-white/25 bg-white/10 px-4 py-2 text-xs font-semibold uppercase tracking-wide text-white/90 backdrop-blur"
            >
              {badge}
            </span>
          ))}
        </div>
      </div>
    </section>
  );
}
