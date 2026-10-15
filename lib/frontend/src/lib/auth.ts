"use client";

import type { AuthUser } from "./types";

// Per-viewer session only — lives in this browser's localStorage, never sent
// anywhere but the Bearer header on API calls. Mirrors what the Flutter app
// keeps in SecurePrefs, just without the secure-storage encryption (this is
// a lightweight tracking companion, not the primary account surface).
const STORAGE_KEY = "hog_web_session";

export interface Session {
  token: string;
  user: AuthUser;
}

// A tiny external-store implementation so every mounted useSession() consumer
// (Navbar, /track, etc.) reacts immediately when the session changes —
// whether that's this tab writing it (sign in/out) or another tab (the
// native "storage" event). Snapshots are cached and only re-parsed when the
// underlying localStorage value actually changes, so useSyncExternalStore
// doesn't see a "new" object on every render and loop.
const listeners = new Set<() => void>();
let cachedRaw: string | null | undefined;
let cachedSession: Session | null = null;

function readRaw(): string | null {
  if (typeof window === "undefined") return null;
  try {
    return window.localStorage.getItem(STORAGE_KEY);
  } catch {
    return null;
  }
}

function notify() {
  listeners.forEach((listener) => listener());
}

export function subscribeToSession(listener: () => void) {
  listeners.add(listener);
  window.addEventListener("storage", listener);
  return () => {
    listeners.delete(listener);
    window.removeEventListener("storage", listener);
  };
}

export function getSessionSnapshot(): Session | null {
  const raw = readRaw();
  if (raw === cachedRaw) return cachedSession;

  cachedRaw = raw;
  try {
    cachedSession = raw ? (JSON.parse(raw) as Session) : null;
  } catch {
    cachedSession = null;
  }
  return cachedSession;
}

export function getSessionServerSnapshot(): Session | null {
  return null;
}

export function getSession(): Session | null {
  return getSessionSnapshot();
}

export function saveSession(session: Session) {
  if (typeof window === "undefined") return;
  try {
    window.localStorage.setItem(STORAGE_KEY, JSON.stringify(session));
  } catch {
    // Ignore storage failures (private browsing, quota, etc.) — the
    // session simply won't persist across reloads for this viewer.
  }
  notify();
}

export function clearSession() {
  if (typeof window === "undefined") return;
  try {
    window.localStorage.removeItem(STORAGE_KEY);
  } catch {
    // no-op
  }
  notify();
}
