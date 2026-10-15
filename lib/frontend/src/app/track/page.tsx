"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import DownloadAppPrompt from "@/components/DownloadAppPrompt";
import OrderDetailModal, {
  type OrderDetailData,
} from "@/components/OrderDetailModal";
import { useSession } from "@/lib/useSession";
import { getOrderHistory, getTrackingRecords, trackCarrierShipment } from "@/lib/api";
import { measurementEntries, normalizeMeasurements } from "@/lib/measurements";
import type {
  CarrierTrackingInfo,
  Measurement,
  OrderMaterial,
  TrackingRecord,
} from "@/lib/types";

// Garment thumbnails: falls back to a neutral icon tile, both when there's
// no image at all and when the URL fails to load (test data uses an
// unreachable https://example.com/placeholder.jpg for every sample).
function GarmentThumb({ src, alt }: { src?: string; alt: string }) {
  const [failed, setFailed] = useState(false);
  if (!src || failed) {
    return (
      <div className="flex h-16 w-16 shrink-0 items-center justify-center rounded-xl border border-border bg-surface-muted sm:h-20 sm:w-20">
        <svg
          width="26"
          height="26"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          strokeWidth="1.5"
          className="text-subtext/70"
        >
          <rect x="3" y="4" width="18" height="16" rx="2" strokeLinejoin="round" />
          <circle cx="8.5" cy="9.5" r="1.5" />
          <path d="m4 17 5-5 4 4 3-3 4 4" strokeLinecap="round" strokeLinejoin="round" />
        </svg>
      </div>
    );
  }
  return (
    // eslint-disable-next-line @next/next/no-img-element
    <img
      src={src}
      alt={alt}
      onError={() => setFailed(true)}
      className="h-16 w-16 shrink-0 rounded-xl border border-border object-cover sm:h-20 sm:w-20"
    />
  );
}

// Quick-glance summary on the card — the full set (all 13 possible fields,
// across every measurement entry) is what OrderDetailModal shows on click.
function MeasurementSummary({ measurement }: { measurement?: Measurement }) {
  if (!measurement) return null;
  const entries = measurementEntries(measurement);
  if (entries.length === 0) return null;

  return (
    <div className="mt-3 flex flex-wrap gap-x-4 gap-y-1">
      {entries.slice(0, 4).map(({ label, value }) => (
        <span key={label} className="text-xs text-subtext">
          <span className="font-semibold text-ink">{value}</span> {label}
        </span>
      ))}
      {entries.length > 4 && (
        <span className="text-xs font-semibold text-accent">
          +{entries.length - 4} more
        </span>
      )}
    </div>
  );
}

function statusLabel(status?: string) {
  if (!status) return "Processing";
  return status
    .split(/[_\s]+/)
    .map((w) => (w ? w[0].toUpperCase() + w.slice(1).toLowerCase() : w))
    .join(" ");
}

function formatDate(iso?: string) {
  if (!iso) return "";
  try {
    return new Date(iso).toLocaleDateString(undefined, {
      year: "numeric",
      month: "short",
      day: "numeric",
    });
  } catch {
    return "";
  }
}

function TrackingCard({
  record,
  token,
  onOpenDetails,
}: {
  record: TrackingRecord;
  token: string;
  onOpenDetails: (data: OrderDetailData) => void;
}) {
  const [expanded, setExpanded] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [live, setLive] = useState<CarrierTrackingInfo | null>(null);

  const canTrackLive = Boolean(record.carrier && record.carrierTrackingNumber);

  const handleToggle = async (e: React.MouseEvent) => {
    e.stopPropagation();
    if (expanded) {
      setExpanded(false);
      return;
    }
    setExpanded(true);
    if (live || !canTrackLive) return;

    setLoading(true);
    setError(null);
    try {
      const info = await trackCarrierShipment(
        token,
        record.carrierTrackingNumber!,
        record.carrier,
      );
      setLive(info);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Unable to fetch live tracking.");
    } finally {
      setLoading(false);
    }
  };

  const material = record.materialId;
  const delivered = record.isDelivered;
  const title = material?.attireType || material?.clothMaterial || "Custom order";

  const openDetails = () =>
    onOpenDetails({
      title,
      images: material?.sampleImage,
      attireType: material?.attireType,
      clothMaterial: material?.clothMaterial,
      color: material?.color,
      brand: material?.brand,
      isDelivered: delivered,
      statusText: delivered ? "Delivered" : statusLabel(record.status),
      waybill: record.carrierTrackingNumber,
      carrier: record.carrier,
      measurement: material?.measurement,
      createdAt: record.createdAt,
    });

  return (
    <div
      className="cursor-pointer rounded-2xl border border-border bg-surface p-5 transition-shadow hover:shadow-md"
      onClick={openDetails}
    >
      <div className="flex flex-wrap items-start gap-4 sm:flex-nowrap">
        <GarmentThumb src={material?.sampleImage?.[0]} alt={title} />
        <div className="min-w-0 flex-1">
          <div className="flex flex-wrap items-start justify-between gap-2">
            <div className="min-w-0">
              <p className="font-display text-base font-bold text-ink">{title}</p>
              <p className="mt-1 text-xs text-subtext">
                {[material?.clothMaterial, material?.color, material?.brand]
                  .filter(Boolean)
                  .join(" · ")}
              </p>
            </div>
            <span
              className={`shrink-0 rounded-full px-3 py-1 text-xs font-bold ${
                delivered
                  ? "bg-accent-soft text-accent"
                  : "bg-secondary-soft text-secondary-deep"
              }`}
            >
              {delivered ? "Delivered" : statusLabel(record.status)}
            </span>
          </div>
          {record.carrierTrackingNumber && (
            <p className="mt-1 text-xs text-subtext">
              Waybill: <span className="font-semibold text-ink">{record.carrierTrackingNumber}</span>
            </p>
          )}
          <MeasurementSummary
            measurement={normalizeMeasurements(material?.measurement)[0]}
          />

          <div className="mt-4 flex flex-wrap items-center gap-x-5 gap-y-2">
            {canTrackLive && (
              <button
                onClick={handleToggle}
                className="text-sm font-bold text-accent hover:text-accent-deep"
              >
                {expanded ? "Hide live tracking ▲" : "Track live shipment ▼"}
              </button>
            )}
            <span className="text-sm font-bold text-ink underline decoration-border underline-offset-2 hover:decoration-ink">
              View full details
            </span>
          </div>
        </div>
      </div>

      {expanded && (
        <div
          className="mt-4 border-t border-border pt-4"
          onClick={(e) => e.stopPropagation()}
        >
          {loading && <p className="text-sm text-subtext">Loading live tracking…</p>}
          {error && <p className="text-sm text-danger">{error}</p>}
          {live && (
            <div>
              <p className="text-sm font-bold text-ink">
                {live.statusDescription || statusLabel(live.status)}
              </p>
              {live.recipientAddress && (
                <p className="mt-1 text-xs text-subtext">
                  Shipping to: {live.recipientAddress}
                </p>
              )}
              {live.events && live.events.length > 0 && (
                <ol className="mt-4 space-y-3 border-l-2 border-border pl-4">
                  {live.events.map((event, i) => (
                    <li key={i} className="relative">
                      <span className="absolute -left-[21px] top-1 h-2.5 w-2.5 rounded-full bg-accent" />
                      <p className="text-xs font-bold text-ink">
                        {statusLabel(event.status)}
                      </p>
                      {event.description && (
                        <p className="text-xs text-subtext">{event.description}</p>
                      )}
                      {event.timestamp && (
                        <p className="text-[11px] text-subtext">
                          {formatDate(event.timestamp)}
                        </p>
                      )}
                    </li>
                  ))}
                </ol>
              )}
            </div>
          )}
        </div>
      )}
    </div>
  );
}

function OrderCard({
  order,
  onOpenDetails,
}: {
  order: OrderMaterial;
  onOpenDetails: (data: OrderDetailData) => void;
}) {
  const title = order.attireType || order.clothMaterial || "Custom request";

  const openDetails = () =>
    onOpenDetails({
      title,
      images: order.sampleImage,
      attireType: order.attireType,
      clothMaterial: order.clothMaterial,
      color: order.color,
      brand: order.brand,
      isDelivered: order.isDelivered,
      settlement: order.settlement,
      measurement: order.measurement,
      specialInstructions: order.specialInstructions,
      createdAt: order.createdAt,
    });

  return (
    <div
      className="cursor-pointer rounded-2xl border border-border bg-surface p-5 transition-shadow hover:shadow-md"
      onClick={openDetails}
    >
      <div className="flex flex-wrap items-start gap-4 sm:flex-nowrap">
        <GarmentThumb src={order.sampleImage?.[0]} alt={title} />
        <div className="min-w-0 flex-1">
          <div className="flex flex-wrap items-start justify-between gap-2">
            <div className="min-w-0">
              <p className="font-display text-base font-bold text-ink">{title}</p>
              <p className="mt-1 text-xs text-subtext">
                {[order.clothMaterial, order.color, order.brand]
                  .filter(Boolean)
                  .join(" · ")}
              </p>
            </div>
            <span
              className={`shrink-0 rounded-full px-3 py-1 text-xs font-bold ${
                order.isDelivered
                  ? "bg-accent-soft text-accent"
                  : "bg-surface-muted text-subtext"
              }`}
            >
              {order.isDelivered ? "Delivered" : "In Progress"}
            </span>
          </div>

          {order.specialInstructions && (
            <p className="mt-2 text-xs italic text-subtext">
              &ldquo;{order.specialInstructions}&rdquo;
            </p>
          )}

          <MeasurementSummary
            measurement={normalizeMeasurements(order.measurement)[0]}
          />

          <div className="mt-3 flex flex-wrap items-center justify-between gap-2">
            {order.createdAt ? (
              <p className="text-xs text-subtext">
                Requested {formatDate(order.createdAt)}
              </p>
            ) : (
              <span />
            )}
            <span className="text-sm font-bold text-ink underline decoration-border underline-offset-2 hover:decoration-ink">
              View full details
            </span>
          </div>
        </div>
      </div>
    </div>
  );
}

export default function TrackPage() {
  const { session, ready, signOut } = useSession();
  const [orders, setOrders] = useState<OrderMaterial[]>([]);
  const [tracking, setTracking] = useState<TrackingRecord[]>([]);
  // No session means we render the "sign in" branch instead of this data at
  // all, so there's nothing to load for that case — starts false and is
  // only ever flipped true right as a real fetch begins, below.
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [selectedOrder, setSelectedOrder] = useState<OrderDetailData | null>(
    null,
  );

  useEffect(() => {
    if (!ready || !session) return;

    let cancelled = false;
    (async () => {
      setLoading(true);
      setError(null);
      try {
        const [orderList, trackingList] = await Promise.all([
          getOrderHistory(session.token),
          getTrackingRecords(session.token),
        ]);
        if (cancelled) return;
        setOrders(orderList);
        setTracking(trackingList);
      } catch (err) {
        if (!cancelled) {
          setError(
            err instanceof Error
              ? err.message
              : "Unable to load your orders right now.",
          );
        }
      } finally {
        if (!cancelled) setLoading(false);
      }
    })();

    return () => {
      cancelled = true;
    };
  }, [ready, session]);

  if (!ready) {
    return (
      <>
        <Navbar solid />
        <main className="flex-1 pt-28 pb-20" />
        <Footer />
      </>
    );
  }

  if (!session) {
    return (
      <>
        <Navbar solid />
        <main className="flex-1 pt-28 pb-20">
          <div className="mx-auto max-w-md px-6 text-center">
            <div className="mx-auto flex h-14 w-14 items-center justify-center rounded-2xl bg-accent-soft">
              <svg
                width="24"
                height="24"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                strokeWidth="2"
                className="text-accent"
              >
                <rect x="3" y="11" width="18" height="10" rx="2" />
                <path d="M7 11V7a5 5 0 0 1 10 0v4" />
              </svg>
            </div>
            <h1 className="mt-5 font-display text-2xl font-bold text-ink sm:text-3xl">
              Sign in to track your orders
            </h1>
            <p className="mt-3 text-sm text-subtext">
              Your delivery status, live shipment tracking, and order history
              are all here once you sign in with your House of GLAME account.
            </p>
            <Link
              href="/signin?redirect=/track"
              className="mt-6 inline-block rounded-full bg-accent px-7 py-3.5 text-sm font-bold text-white transition-colors hover:bg-accent-deep"
            >
              Sign In
            </Link>
            <div className="mt-8 text-left">
              <DownloadAppPrompt />
            </div>
          </div>
        </main>
        <Footer />
      </>
    );
  }

  return (
    <>
      <Navbar solid />
      <main className="flex-1 pt-28 pb-20">
        <div className="mx-auto max-w-3xl px-6">
          <div className="flex items-center justify-between gap-4">
            <div>
              <p className="text-sm font-bold uppercase tracking-[0.25em] text-secondary-deep">
                Welcome back
              </p>
              <h1 className="mt-2 font-display text-3xl font-bold text-ink">
                {session.user.fullName?.split(" ")[0] || "Your"}&apos;s Orders
              </h1>
            </div>
            <button
              onClick={signOut}
              className="rounded-full border border-border px-4 py-2 text-xs font-semibold text-subtext hover:border-danger hover:text-danger"
            >
              Sign Out
            </button>
          </div>

          {loading && (
            <p className="mt-10 text-center text-sm text-subtext">
              Loading your orders…
            </p>
          )}

          {error && (
            <div className="mt-8 rounded-xl border border-danger/30 bg-danger/10 px-4 py-3 text-sm text-danger">
              {error}
            </div>
          )}

          {!loading && !error && (
            <>
              <section className="mt-8">
                <h2 className="font-display text-lg font-bold text-ink">
                  Shipment Tracking
                </h2>
                {tracking.length === 0 ? (
                  <p className="mt-3 text-sm text-subtext">
                    No shipments yet — once a designer dispatches an order,
                    it&apos;ll show up here with live tracking.
                  </p>
                ) : (
                  <div className="mt-4 space-y-4">
                    {tracking.map((record) => (
                      <TrackingCard
                        key={record._id}
                        record={record}
                        token={session.token}
                        onOpenDetails={setSelectedOrder}
                      />
                    ))}
                  </div>
                )}
              </section>

              <section className="mt-12">
                <h2 className="font-display text-lg font-bold text-ink">
                  My Custom Orders
                </h2>
                {orders.length === 0 ? (
                  <p className="mt-3 text-sm text-subtext">
                    You haven&apos;t placed a custom order yet.
                  </p>
                ) : (
                  <div className="mt-4 space-y-4">
                    {orders.map((order) => (
                      <OrderCard
                        key={order._id}
                        order={order}
                        onOpenDetails={setSelectedOrder}
                      />
                    ))}
                  </div>
                )}
              </section>
            </>
          )}
        </div>
      </main>
      <Footer />
      <OrderDetailModal
        order={selectedOrder}
        onClose={() => setSelectedOrder(null)}
      />
    </>
  );
}
