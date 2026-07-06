"use client";

import { useEffect, useState } from "react";

const links = [
  { href: "#offerings", label: "What We Offer" },
  { href: "#how-it-works", label: "How It Works" },
  { href: "#protection", label: "Protection" },
  { href: "#designers", label: "For Designers" },
];

export default function Navbar() {
  const [scrolled, setScrolled] = useState(false);
  const [open, setOpen] = useState(false);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 16);
    onScroll();
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  return (
    <header
      className={`fixed inset-x-0 top-0 z-50 transition-colors duration-300 ${
        scrolled || open
          ? "bg-canvas/90 backdrop-blur border-b border-border shadow-sm"
          : "bg-transparent border-b border-transparent"
      }`}
    >
      <nav className="mx-auto flex max-w-7xl items-center justify-between px-6 py-4 lg:px-8">
        <a href="#top" className="flex items-center gap-2">
          <span
            className={`font-display text-xl font-bold tracking-tight ${
              scrolled || open ? "text-ink" : "text-white"
            }`}
          >
            House of GLAME
          </span>
        </a>

        <div className="hidden items-center gap-8 md:flex">
          {links.map((link) => (
            <a
              key={link.href}
              href={link.href}
              className={`text-sm font-semibold transition-colors ${
                scrolled ? "text-ink hover:text-accent" : "text-white/90 hover:text-white"
              }`}
            >
              {link.label}
            </a>
          ))}
        </div>

        <div className="hidden md:block">
          <a
            href="#cta"
            className="rounded-full bg-accent px-5 py-2.5 text-sm font-bold text-white shadow-sm transition-transform hover:-translate-y-0.5 hover:bg-accent-deep"
          >
            Join House of GLAME
          </a>
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
              <a
                key={link.href}
                href={link.href}
                onClick={() => setOpen(false)}
                className="text-base font-semibold text-ink"
              >
                {link.label}
              </a>
            ))}
            <a
              href="#cta"
              onClick={() => setOpen(false)}
              className="mt-2 rounded-full bg-accent px-5 py-3 text-center text-sm font-bold text-white"
            >
              Join House of GLAME
            </a>
          </div>
        </div>
      )}
    </header>
  );
}
