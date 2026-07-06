const items = [
  "Escrow-Protected Payments",
  "Verified Designers",
  "Real-Time Order Tracking",
  "Global Delivery",
  "Dispute Resolution",
  "Verified-Purchase Reviews",
];

export default function TrustStrip() {
  const loop = [...items, ...items];
  return (
    <div className="overflow-hidden border-y border-border bg-surface-muted py-4">
      <div className="flex w-max animate-marquee gap-10">
        {loop.map((item, i) => (
          <div key={`${item}-${i}`} className="flex items-center gap-3 whitespace-nowrap">
            <span className="h-1.5 w-1.5 rounded-full bg-secondary" />
            <span className="text-sm font-semibold text-subtext">{item}</span>
          </div>
        ))}
      </div>
    </div>
  );
}
