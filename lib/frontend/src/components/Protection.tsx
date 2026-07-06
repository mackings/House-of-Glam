const points = [
  {
    title: "Milestone escrow",
    description:
      "Deposit and balance payments are held safely and only released on delivery confirmation.",
  },
  {
    title: "Neutral oversight",
    description:
      "Designers can see funds in progress but can't release them. Payouts are platform-controlled.",
  },
  {
    title: "Dispute resolution",
    description:
      "Every dispute is tied to a real order, with a support team ready to review and resolve it.",
  },
  {
    title: "Verified reviews",
    description:
      "Reviews are only ever left by customers with a real, completed purchase. No noise, no fakes.",
  },
];

export default function Protection() {
  return (
    <section id="protection" className="bg-accent-deep py-24 text-white">
      <div className="mx-auto max-w-7xl px-6 lg:px-8">
        <div className="max-w-2xl">
          <p className="text-sm font-bold uppercase tracking-[0.25em] text-secondary-soft">
            Payment Protection
          </p>
          <h2 className="mt-4 font-display text-4xl font-bold leading-tight sm:text-5xl">
            Your money is protected, start to finish.
          </h2>
          <p className="mt-5 text-lg leading-relaxed text-white/75">
            Every custom order moves through escrow, so you only pay for what
            actually arrives.
          </p>
        </div>

        <div className="mt-14 grid gap-8 sm:grid-cols-2 lg:grid-cols-4">
          {points.map((point) => (
            <div
              key={point.title}
              className="rounded-2xl border border-white/10 bg-white/5 p-6 backdrop-blur-sm"
            >
              <div className="mb-4 flex h-10 w-10 items-center justify-center rounded-full bg-secondary/20">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="text-secondary-soft">
                  <path d="M12 2 4 5v6c0 5 3.4 8.7 8 10 4.6-1.3 8-5 8-10V5l-8-3Z" strokeLinejoin="round" />
                  <path d="m9 12 2 2 4-4" strokeLinecap="round" strokeLinejoin="round" />
                </svg>
              </div>
              <h3 className="font-bold">{point.title}</h3>
              <p className="mt-2 text-sm leading-relaxed text-white/65">
                {point.description}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
