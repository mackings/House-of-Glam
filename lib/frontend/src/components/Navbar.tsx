"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import { useSession } from "@/lib/useSession";

const links = [
  { href: "/designers", label: "Designers" },
  { href: "/#how-it-works", label: "How It Works" },
  { href: "/#designers", label: "For Designers" },
  { href: "/#protection", label: "Protection" },
];

export default function Navbar({ solid = false }: { solid?: boolean }) {
  const [scrolledPast, setScrolledPast] = useState(false);
  const [open, setOpen] = useState(false);
  const { session, ready, signOut } = useSession();

  useEffect(() => {
    if (solid) return;
    const onScroll = () => setScrolledPast(window.scrollY > 16);
    onScroll();
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, [solid]);

  // Only the homepage renders a dark hero image directly under the navbar,
  // so only it gets the transparent-over-dark-image treatment that turns
  // opaque on scroll. Every other page (signin, track, designers, ...) has
  // a light background from the very top, so it always asks for the solid,
  // dark-text navbar — otherwise the white hero-style text is unreadable.
  const scrolled = solid || scrolledPast;

  const isSignedIn = ready && Boolean(session);

  return (
    <header
      className={`fixed inset-x-0 top-0 z-50 transition-colors duration-300 ${
        scrolled || open
          ? "bg-canvas/90 backdrop-blur border-b border-border shadow-sm"
          : "bg-transparent border-b border-transparent"
      }`}
    >
      <nav className="mx-auto flex max-w-7xl items-center justify-between px-6 py-4 lg:px-8">
        <Link href="/" className="flex items-center gap-2">
          <span
            className={`font-display text-xl font-bold tracking-tight ${
              scrolled || open ? "text-ink" : "text-white"
            }`}
          >
            House of GLAME
          </span>
        </Link>

        <div className="hidden items-center gap-8 md:flex">
          {links.map((link) => (
            <Link
              key={link.href}
              href={link.href}
              className={`text-sm font-semibold transition-colors ${
                scrolled ? "text-ink hover:text-accent" : "text-white/90 hover:text-white"
              }`}
            >
              {link.label}
            </Link>
          ))}
        </div>

        <div className="hidden items-center gap-3 md:flex">
          {isSignedIn ? (
            <>
              <Link
                href="/track"
                className={`text-sm font-semibold transition-colors ${
                  scrolled ? "text-ink hover:text-accent" : "text-white/90 hover:text-white"
                }`}
              >
                My Orders
              </Link>
              <button
                onClick={signOut}
                className="rounded-full border border-current px-5 py-2.5 text-sm font-bold transition-colors"
                style={{ color: scrolled ? "#153B2F" : "#fff" }}
              >
                Sign Out
              </button>
            </>
          ) : (
            <>
              <Link
                href="/signin"
                className={`text-sm font-semibold transition-colors ${
                  scrolled ? "text-ink hover:text-accent" : "text-white/90 hover:text-white"
                }`}
              >
                Sign In
              </Link>
              <Link
                href="/track"
                className="rounded-full bg-accent px-5 py-2.5 text-sm font-bold text-white shadow-sm transition-transform hover:-translate-y-0.5 hover:bg-accent-deep"
              >
                Track Order
              </Link>
            </>
          )}
        </div>

        <button
          type="button"
          onClick={() => setOpen((v) => !v)}
          aria-label="Toggle menu"
          aria-expanded={open}
          className={`md:hidden inline-flex h-10 w-10 items-center justify-center rounded-full border ${
            scrolled || open
              ? "border-border text-ink"
              : "border-white/40 text-white"
          }`}
        >
          {open ? (
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <path d="M6 6l12 12M18 6L6 18" strokeLinecap="round" />
            </svg>
          ) : (
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <path d="M4 7h16M4 12h16M4 17h16" strokeLinecap="round" />
            </svg>
          )}
        </button>
      </nav>

      {open && (
        <div className="border-t border-border bg-canvas px-6 pb-6 pt-2 md:hidden">
          <div className="flex flex-col gap-4">
            {links.map((link) => (
              <Link
                key={link.href}
                href={link.href}
                onClick={() => setOpen(false)}
                className="text-base font-semibold text-ink"
              >
                {link.label}
              </Link>
            ))}
            {isSignedIn ? (
              <>
                <Link
                  href="/track"
                  onClick={() => setOpen(false)}
                  className="text-base font-semibold text-ink"
                >
                  My Orders
                </Link>
                <button
                  onClick={() => {
                    signOut();
                    setOpen(false);
                  }}
                  className="mt-2 rounded-full border border-border px-5 py-3 text-center text-sm font-bold text-ink"
                >
                  Sign Out
                </button>
              </>
            ) : (
              <>
                <Link
                  href="/signin"
                  onClick={() => setOpen(false)}
                  className="text-base font-semibold text-ink"
                >
                  Sign In
                </Link>
                <Link
                  href="/track"
                  onClick={() => setOpen(false)}
                  className="mt-2 rounded-full bg-accent px-5 py-3 text-center text-sm font-bold text-white"
                >
                  Track Order
                </Link>
              </>
            )}
          </div>
        </div>
      )}
    </header>
  );
}
