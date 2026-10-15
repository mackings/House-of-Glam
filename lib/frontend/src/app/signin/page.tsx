"use client";

import Link from "next/link";
import { Suspense, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import DownloadAppPrompt from "@/components/DownloadAppPrompt";
import { login } from "@/lib/api";
import { saveSession } from "@/lib/auth";

function SignInForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const redirectTo = searchParams.get("redirect") || "/track";

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setLoading(true);

    const result = await login(email.trim(), password);
    setLoading(false);

    if (result.success && result.token && result.user) {
      saveSession({ token: result.token, user: result.user });
      router.push(redirectTo);
      return;
    }

    setError(result.error || result.message || "Invalid email or password.");
  };

  return (
    <main className="flex-1 pt-28 pb-20">
      <div className="mx-auto max-w-md px-6">
        <p className="text-center text-sm font-bold uppercase tracking-[0.25em] text-secondary-deep">
          Welcome Back
        </p>
        <h1 className="mt-3 text-center font-display text-3xl font-bold text-ink sm:text-4xl">
          Sign in to track your orders
        </h1>
        <p className="mt-3 text-center text-sm text-subtext">
          Use the same email and password as the House of GLAME app.
        </p>

        <form
          onSubmit={handleSubmit}
          className="mt-8 rounded-3xl border border-border bg-surface p-6 shadow-sm shadow-black/5"
        >
          {error && (
            <div className="mb-4 rounded-xl border border-danger/30 bg-danger/10 px-4 py-3 text-sm text-danger">
              {error}
            </div>
          )}

          <label className="block text-xs font-semibold text-ink">
            Email address
            <input
              type="email"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="you@example.com"
              className="mt-1.5 w-full rounded-xl border border-border bg-canvas px-4 py-3 text-sm text-ink outline-none focus:border-accent"
            />
          </label>

          <label className="mt-4 block text-xs font-semibold text-ink">
            Password
            <input
              type="password"
              required
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="••••••••"
              className="mt-1.5 w-full rounded-xl border border-border bg-canvas px-4 py-3 text-sm text-ink outline-none focus:border-accent"
            />
          </label>

          <button
            type="submit"
            disabled={loading}
            className="mt-6 w-full rounded-full bg-accent py-3.5 text-sm font-bold text-white transition-colors hover:bg-accent-deep disabled:opacity-60"
          >
            {loading ? "Signing in…" : "Sign In"}
          </button>
        </form>

        <div className="mt-6">
          <DownloadAppPrompt />
        </div>

        <p className="mt-6 text-center text-xs text-subtext">
          By signing in you agree to our{" "}
          <Link href="/#" className="font-semibold text-accent">
            Terms
          </Link>{" "}
          and{" "}
          <Link href="/privacy" className="font-semibold text-accent">
            Privacy Policy
          </Link>
          .
        </p>
      </div>
    </main>
  );
}

export default function SignInPage() {
  return (
    <>
      <Navbar solid />
      <Suspense fallback={null}>
        <SignInForm />
      </Suspense>
      <Footer />
    </>
  );
}
