"use client";

import { useCallback, useEffect, useState, useSyncExternalStore } from "react";
import {
  clearSession,
  getSessionServerSnapshot,
  getSessionSnapshot,
  subscribeToSession,
} from "./auth";

/**
 * Reactive read of the current browser session. Backed by
 * useSyncExternalStore (the React-correct way to read a mutable external
 * store like localStorage) rather than an effect + setState, so it updates
 * immediately across every mounted consumer — including other tabs, via the
 * native "storage" event.
 *
 * useSyncExternalStore already renders the server snapshot (null) on the
 * first client pass to avoid a hydration mismatch, then swaps in the real
 * value right after. `ready` flips true on that same tick via a plain mount
 * flag, purely so callers can distinguish "definitely signed out" from
 * "still resolving" without needing to duplicate that logic themselves.
 */
export function useSession() {
  const session = useSyncExternalStore(
    subscribeToSession,
    getSessionSnapshot,
    getSessionServerSnapshot,
  );
  const [ready, setReady] = useState(false);

  useEffect(() => {
    // Intentional exception to react-hooks/set-state-in-effect: this is the
    // standard SSR "mounted" guard, not state derived from props/other
    // state. It can only ever run once (empty deps) and exists specifically
    // to flip after the render pass useSyncExternalStore already made
    // hydration-safe above — there's no non-effect way to know "hydration
    // has committed" from inside a component.
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setReady(true);
  }, []);

  const signOut = useCallback(() => {
    clearSession();
  }, []);

  return { session, ready, signOut };
}
