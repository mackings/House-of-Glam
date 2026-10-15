"use client";

import Link from "next/link";
import { useParams } from "next/navigation";
import { useEffect, useState } from "react";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import DownloadAppPrompt from "@/components/DownloadAppPrompt";
import { getPublicDesigner } from "@/lib/api";
import type { PublicDesignerDetail } from "@/lib/types";

function initialsAvatar(name: string) {
  const initials = name
    .split(" ")
    .filter(Boolean)
    .slice(0, 2)
    .map((w) => w[0]?.toUpperCase())
    .join("");
  return initials || "?";
}

export default function DesignerDetailPage() {
  const params = useParams<{ id: string }>();
  const [designer, setDesigner] = useState<PublicDesignerDetail | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        const data = await getPublicDesigner(params.id);
        if (!cancelled) setDesigner(data);
      } catch (err) {
        if (!cancelled) {
          setError(
            err instanceof Error
              ? err.message
              : "Unable to load this designer's profile.",
          );
        }
      } finally {
        if (!cancelled) setLoading(false);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [params.id]);

  const name = designer?.businessName || designer?.userId?.fullName || "Designer";
  const location = designer
    ? [designer.city, designer.state, designer.country].filter(Boolean).join(", ")
    : "";
  const rating =
    designer?.totalRatings && designer.totalRatings > 0 && designer.ratingSum
      ? (designer.ratingSum / designer.totalRatings).toFixed(1)
      : null;
  const gallery = designer?.portfolioGallery ?? [];

  return (
    <>
      <Navbar solid />
      <main className="flex-1 pt-28 pb-20">
        <div className="mx-auto max-w-4xl px-6">
          <Link
            href="/designers"
            className="text-sm font-semibold text-subtext hover:text-accent"
          >
            ← All Designers
          </Link>

          {loading && (
            <p className="mt-8 text-sm text-subtext">Loading profile…</p>
          )}
          {error && (
            <div className="mt-8 rounded-xl border border-danger/30 bg-danger/10 px-4 py-3 text-sm text-danger">
              {error}
            </div>
          )}

          {!loading && !error && designer && (
            <>
              <div className="mt-6 flex flex-col items-start gap-6 sm:flex-row sm:items-center">
                <div className="flex h-24 w-24 shrink-0 items-center justify-center rounded-3xl bg-accent-soft">
                  <span className="font-display text-3xl font-bold text-accent">
                    {initialsAvatar(name)}
                  </span>
                </div>
                <div>
                  <h1 className="font-display text-3xl font-bold text-ink sm:text-4xl">
                    {name}
                  </h1>
                  {location && (
                    <p className="mt-1 text-sm text-subtext">{location}</p>
                  )}
                  <div className="mt-3 flex flex-wrap items-center gap-4 text-sm">
                    {rating && (
                      <span className="font-semibold text-secondary-deep">
                        ★ {rating} ({designer.totalRatings} reviews)
                      </span>
                    )}
                    {designer.yearOfExperience && (
                      <span className="text-subtext">
                        {designer.yearOfExperience} years of experience
                      </span>
                    )}
                    {designer.socialProof?.completedOrders != null && (
                      <span className="text-subtext">
                        {designer.socialProof.completedOrders} orders completed
                      </span>
                    )}
                  </div>
                </div>
              </div>

              {designer.description && (
                <p className="mt-8 max-w-2xl text-lg leading-relaxed text-subtext">
                  {designer.description}
                </p>
              )}

              {gallery.length > 0 && (
                <div className="mt-10">
                  <h2 className="font-display text-xl font-bold text-ink">
                    Portfolio
                  </h2>
                  <div className="mt-4 grid grid-cols-2 gap-4 sm:grid-cols-3">
                    {gallery.map((item, i) => (
                      // eslint-disable-next-line @next/next/no-img-element
                      <img
                        key={i}
                        src={item.imageUrl}
                        alt={`${name} portfolio ${i + 1}`}
                        className="aspect-square w-full rounded-2xl object-cover"
                      />
                    ))}
                  </div>
                </div>
              )}

              <div className="mt-12 max-w-md">
                <DownloadAppPrompt
                  title={`Want to order from ${name}?`}
                  description="Request a custom fit, compare quotes, and pay securely — all from the House of GLAME app."
                />
              </div>
            </>
          )}
        </div>
      </main>
      <Footer />
    </>
  );
}
