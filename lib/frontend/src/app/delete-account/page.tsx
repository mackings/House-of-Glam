"use client";

import { useMemo, useState } from "react";
import Link from "next/link";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import { useSession } from "@/lib/useSession";

const SUPPORT_EMAIL = "support@houseofglame.com";

const DELETED_ITEMS = [
  "Your profile, login credentials, and saved preferences",
  "Measurements, style preferences, and saved designs",
  "Designer portfolio and business listings (for designer accounts)",
  "Messages and order history visible in your account",
];

const RETAINED_ITEMS = [
  "Financial and transaction records, kept for tax and accounting law",
  "Records needed to resolve an open dispute, order, or payout",
  "Information we're required to keep for fraud prevention and legal compliance",
];

function buildMailtoHref(email: string | null) {
  const subject = "Account Deletion Request";
  const body = [
    "I would like to permanently delete my House of GLAME account.",
    "",
    `Account email: ${email ?? "(enter the email your account uses)"}`,
    "Reason for leaving (optional):",
  ].join("\n");

  return `mailto:${SUPPORT_EMAIL}?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}`;
}

export default function DeleteAccountPage() {
  const { session, ready } = useSession();
  const [copied, setCopied] = useState(false);

  const mailtoHref = useMemo(
    () => buildMailtoHref(session?.user.email ?? null),
    [session],
  );

  const handleCopyEmail = async () => {
    try {
      await navigator.clipboard.writeText(SUPPORT_EMAIL);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch {
      // Clipboard access can fail (permissions, insecure context); the
      // email is already shown as plain text right next to the button.
    }
  };

  return (
    <>
      <Navbar solid />
      <main className="flex-1 pt-28 pb-24">
        <div className="mx-auto max-w-3xl px-6 lg:px-8">
          <p className="text-sm font-bold uppercase tracking-[0.25em] text-secondary-deep">
            Account
          </p>
          <h1 className="mt-3 font-display text-4xl font-bold leading-tight text-ink sm:text-5xl">
            Delete Your Account
          </h1>
          <p className="mt-5 text-base leading-relaxed text-subtext">
            You can request permanent deletion of your House of GLAME account
            and personal data at any time. This applies to accounts created
            on the app or the website.
          </p>

          <div className="mt-10 rounded-3xl border border-border bg-surface p-6 sm:p-8">
            <p className="font-display text-lg font-bold text-ink">
              Request deletion
            </p>
            <p className="mt-2 text-sm leading-relaxed text-subtext">
              {ready && session
                ? `Signed in as ${session.user.email}. We'll include this in your request.`
                : "Send us a request from the email address your account uses, and we'll take it from there."}
            </p>

            <div className="mt-5 flex flex-col gap-3 sm:flex-row">
              <a
                href={mailtoHref}
                className="inline-flex items-center justify-center rounded-full bg-accent px-7 py-3.5 text-sm font-bold text-white transition-colors hover:bg-accent-deep"
              >
                Email us to delete my account
              </a>
              <button
                onClick={handleCopyEmail}
                className="inline-flex items-center justify-center gap-2 rounded-full border border-border px-7 py-3.5 text-sm font-bold text-ink transition-colors hover:border-accent hover:text-accent"
              >
                {copied ? "Copied!" : SUPPORT_EMAIL}
              </button>
            </div>

            <p className="mt-5 text-xs leading-relaxed text-subtext">
              We&apos;ll verify the request is really you, then process it within
              30 days. If you have an open order or payout in progress, we
              may ask you to let it settle first.
            </p>
          </div>

          <div className="mt-10 grid gap-6 sm:grid-cols-2">
            <div className="rounded-2xl border border-border p-6">
              <p className="font-display text-base font-bold text-ink">
                What gets deleted
              </p>
              <ul className="mt-3 list-disc space-y-1.5 pl-5 text-sm leading-relaxed text-subtext marker:text-accent">
                {DELETED_ITEMS.map((item) => (
                  <li key={item}>{item}</li>
                ))}
              </ul>
            </div>
            <div className="rounded-2xl border border-border bg-surface-muted p-6">
              <p className="font-display text-base font-bold text-ink">
                What we&apos;re required to keep
              </p>
              <ul className="mt-3 list-disc space-y-1.5 pl-5 text-sm leading-relaxed text-subtext marker:text-accent">
                {RETAINED_ITEMS.map((item) => (
                  <li key={item}>{item}</li>
                ))}
              </ul>
            </div>
          </div>

          <p className="mt-10 text-sm text-subtext">
            See our{" "}
            <Link href="/privacy" className="font-semibold text-accent hover:text-accent-deep">
              Privacy Policy
            </Link>{" "}
            for more on how your data is handled and retained.
          </p>
        </div>
      </main>
      <Footer />
    </>
  );
}
