"use client";

import { useEffect, useState } from "react";
import { measurementEntries, normalizeMeasurements } from "@/lib/measurements";
import type { Measurement } from "@/lib/types";

export interface OrderDetailData {
  title: string;
  images?: string[];
  attireType?: string;
  clothMaterial?: string;
  color?: string;
  brand?: string;
  isDelivered?: boolean;
  // Free-form status text for shipments (e.g. "Dispatched"); orders without
  // a shipment fall back to Delivered/In Progress from isDelivered instead.
  statusText?: string;
  settlement?: number;
  waybill?: string;
  carrier?: string;
  measurement?: Measurement | Measurement[];
  specialInstructions?: string;
  createdAt?: string;
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

function InfoChip({ label }: { label: string }) {
  return (
    <span className="rounded-full bg-accent-soft px-3 py-1.5 text-xs font-bold text-accent">
      {label}
    </span>
  );
}

function GalleryImage({ src, alt }: { src: string; alt: string }) {
  const [failed, setFailed] = useState(false);
  if (failed) {
    return (
      <div className="flex h-full w-full items-center justify-center rounded-2xl border border-border bg-surface-muted text-xs text-subtext">
        Image unavailable
      </div>
    );
  }
  return (
    // eslint-disable-next-line @next/next/no-img-element
    <img
      src={src}
      alt={alt}
      onError={() => setFailed(true)}
      className="h-full w-full rounded-2xl border border-border object-cover"
    />
  );
}

export default function OrderDetailModal({
  order,
  onClose,
}: {
  order: OrderDetailData | null;
  onClose: () => void;
}) {
  useEffect(() => {
    if (!order) return;
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") onClose();
    };
    document.addEventListener("keydown", onKey);
    document.body.style.overflow = "hidden";
    return () => {
      document.removeEventListener("keydown", onKey);
      document.body.style.overflow = "";
    };
  }, [order, onClose]);

  if (!order) return null;

  const images = order.images?.filter(Boolean) ?? [];
  const measurementSets = normalizeMeasurements(order.measurement);
  const status =
    order.statusText || (order.isDelivered ? "Delivered" : "In Progress");

  return (
    <div
      className="fixed inset-0 z-[60] flex items-end justify-center bg-black/50 p-0 sm:items-center sm:p-6"
      onClick={onClose}
    >
      <div
        className="max-h-[92vh] w-full max-w-2xl overflow-y-auto rounded-t-3xl bg-surface p-6 shadow-xl sm:rounded-3xl sm:p-8"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-start justify-between gap-4">
          <div>
            <p className="font-display text-xl font-bold text-ink">
              {order.title}
            </p>
            <p className="mt-1 text-xs text-subtext">
              {order.createdAt
                ? `Requested ${formatDate(order.createdAt)}`
                : "Order details"}
            </p>
          </div>
          <button
            onClick={onClose}
            aria-label="Close"
            className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full border border-border text-ink hover:border-accent hover:text-accent"
          >
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <path d="M6 6l12 12M18 6L6 18" strokeLinecap="round" />
            </svg>
          </button>
        </div>

        {images.length > 0 ? (
          <div className="mt-6 flex gap-3 overflow-x-auto pb-1">
            {images.map((src, i) => (
              <div key={i} className="h-40 w-40 shrink-0">
                <GalleryImage src={src} alt={`${order.title} photo ${i + 1}`} />
              </div>
            ))}
          </div>
        ) : (
          <div className="mt-6 flex h-32 items-center justify-center rounded-2xl border border-border bg-surface-muted text-xs text-subtext">
            No sample images were provided for this order.
          </div>
        )}

        <div className="mt-5 flex flex-wrap gap-2">
          {[order.attireType, order.clothMaterial, order.color, order.brand]
            .filter(Boolean)
            .map((label) => (
              <InfoChip key={label} label={label as string} />
            ))}
        </div>

        <div className="mt-5 grid grid-cols-2 gap-3 sm:grid-cols-3">
          <div className="rounded-2xl border border-border p-4">
            <p className="text-[11px] font-semibold uppercase tracking-wide text-subtext">
              Status
            </p>
            <p className="mt-1 text-sm font-bold text-ink">{status}</p>
          </div>
          {order.settlement != null && (
            <div className="rounded-2xl border border-border p-4">
              <p className="text-[11px] font-semibold uppercase tracking-wide text-subtext">
                Settlement
              </p>
              <p className="mt-1 text-sm font-bold text-ink">{order.settlement}</p>
            </div>
          )}
          {order.waybill && (
            <div className="rounded-2xl border border-border p-4">
              <p className="text-[11px] font-semibold uppercase tracking-wide text-subtext">
                Waybill
              </p>
              <p className="mt-1 text-sm font-bold text-ink">{order.waybill}</p>
            </div>
          )}
        </div>

        <div className="mt-7">
          <p className="font-display text-base font-bold text-ink">
            Measurements
          </p>
          {measurementSets.length === 0 ? (
            <div className="mt-3 rounded-2xl border border-border bg-surface-muted p-4 text-xs text-subtext">
              No measurement details were attached to this order.
            </div>
          ) : (
            <div className="mt-3 space-y-3">
              {measurementSets.map((set, i) => {
                const entries = measurementEntries(set);
                if (entries.length === 0) return null;
                return (
                  <div
                    key={i}
                    className="grid grid-cols-2 gap-3 rounded-2xl border border-border p-4 sm:grid-cols-3"
                  >
                    {entries.map(({ label, value }) => (
                      <div
                        key={label}
                        className="rounded-xl bg-surface-muted px-3 py-2.5"
                      >
                        <p className="text-[11px] text-subtext">{label}</p>
                        <p className="mt-0.5 text-sm font-bold text-ink">
                          {value}
                        </p>
                      </div>
                    ))}
                  </div>
                );
              })}
            </div>
          )}
        </div>

        {order.specialInstructions && (
          <div className="mt-7">
            <p className="font-display text-base font-bold text-ink">
              Special Instructions
            </p>
            <div className="mt-3 rounded-2xl border border-border bg-surface-muted p-4 text-sm text-ink">
              {order.specialInstructions}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
