"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import { getPublicDesigners } from "@/lib/api";
import type { PublicDesigner } from "@/lib/types";

function initialsAvatar(name: string) {
  const initials = name
    .split(" ")
    .filter(Boolean)
    .slice(0, 2)
    .map((w) => w[0]?.toUpperCase())
    .join("");
  return initials || "?";
}

function DesignerCard({ designer }: { designer: PublicDesigner }) {
  const name = designer.businessName || designer.userId?.fullName || "Designer";
  const location = [designer.city, designer.state, designer.country]
    .filter(Boolean)
    .join(", ");
  const rating =
    designer.totalRatings && designer.totalRatings > 0 && designer.ratingSum
      ? (designer.ratingSum / designer.totalRatings).toFixed(1)
      : null;
  const cover = designer.portfolioGallery?.[0]?.imageUrl;

  return (
    <Link
      href={`/designers/${designer._id}`}
      className="group block overflow-hidden rounded-3xl border border-border bg-surface transition-shadow hover:shadow-lg"
    >
      <div className="relative flex aspect-[4/3] items-center justify-center overflow-hidden bg-surface-muted">
        {cover ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img
            src={cover}
            alt={name}
            className="h-full w-full object-cover transition-transform duration-500 group-hover:scale-105"
          />
        ) : (
          <span className="font-display text-4xl font-bold text-accent/40">
            {initialsAvatar(name)}
          </span>
        )}
      </div>
      <div className="p-5">
        <p className="font-display text-lg font-bold text-ink">{name}</p>
        {location && <p className="mt-1 text-xs text-subtext">{location}</p>}
        {designer.description && (
          <p className="mt-2 line-clamp-2 text-sm text-subtext">
            {designer.description}
          </p>
        )}
        <div className="mt-3 flex items-center gap-3 text-xs text-subtext">
          {rating && (
            <span className="flex items-center gap-1 font-semibold text-secondary-deep">
              ★ {rating}
            </span>
          )}
          {designer.yearOfExperience && (
            <span>{designer.yearOfExperience} yrs experience</span>
          )}
        </div>
      </div>
    </Link>
  );
}

export default function DesignersPage() {
  const [designers, setDesigners] = useState<PublicDesigner[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        const list = await getPublicDesigners();
        if (!cancelled) setDesigners(list);
      } catch (err) {
        if (!cancelled) {
          setError(
            err instanceof Error ? err.message : "Unable to load designers.",
          );
        }
      } finally {
        if (!cancelled) setLoading(false);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, []);

  return (
    <>
      <Navbar solid />
      <main className="flex-1 pt-28 pb-20">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="max-w-2xl">
            <p className="text-sm font-bold uppercase tracking-[0.25em] text-secondary-deep">
              Browse Designers
            </p>
            <h1 className="mt-4 font-display text-4xl font-bold leading-tight text-ink sm:text-5xl">
              Meet the designers of House of GLAME.
            </h1>
            <p className="mt-5 text-lg text-subtext">
              Explore verified designers and tailors from Nigeria and beyond.
              Sign in on the app to request a custom order or shop their
              ready-to-wear pieces.
            </p>
          </div>

          {loading && (
            <p className="mt-12 text-sm text-subtext">Loading designers…</p>
          )}
          {error && (
            <div className="mt-12 rounded-xl border border-danger/30 bg-danger/10 px-4 py-3 text-sm text-danger">
              {error}
            </div>
          )}
          {!loading && !error && designers.length === 0 && (
            <p className="mt-12 text-sm text-subtext">
              No designers to show yet — check back soon.
            </p>
          )}

          {!loading && designers.length > 0 && (
            <div className="mt-12 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
              {designers.map((designer) => (
                <DesignerCard key={designer._id} designer={designer} />
              ))}
            </div>
          )}
        </div>
      </main>
      <Footer />
    </>
  );
}
