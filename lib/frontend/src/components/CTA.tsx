import Image from "next/image";
import { images } from "@/lib/images";

export default function CTA() {
  return (
    <section id="cta" className="relative isolate overflow-hidden py-28">
      <Image
        src={images.fabricTexture}
        alt="Rolls of colorful African print fabric"
        fill
        sizes="100vw"
        className="object-cover"
      />
      <div className="absolute inset-0 bg-accent-deep/90" />

      <div className="relative mx-auto max-w-3xl px-6 text-center lg:px-8">
        <h2 className="font-display text-4xl font-bold leading-tight text-white sm:text-5xl">
          Ready to step into House of GLAME?
        </h2>
        <p className="mx-auto mt-5 max-w-xl text-lg text-white/80">
          Whether you&apos;re here to create your next look or grow your fashion
          brand, your journey starts with one step.
        </p>
        <div className="mt-10 flex flex-wrap items-center justify-center gap-4">
          <a
            href="#offerings"
            className="rounded-full bg-secondary px-8 py-3.5 text-sm font-bold text-accent-deep shadow-lg shadow-black/20 transition-transform hover:-translate-y-0.5"
          >
            Start Shopping
          </a>
          <a
            href="#designers"
            className="rounded-full border border-white/40 px-8 py-3.5 text-sm font-bold text-white transition-colors hover:bg-white/10"
          >
            Build Your Brand
          </a>
        </div>
      </div>
    </section>
  );
}
