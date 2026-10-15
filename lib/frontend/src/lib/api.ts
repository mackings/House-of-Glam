import type {
  CarrierTrackingInfo,
  LoginResponse,
  OrderMaterial,
  PublicDesigner,
  PublicDesignerDetail,
  TrackingRecord,
} from "./types";

// Same backend the Flutter app talks to (lib/constants/api_config.dart).
const BASE_URL = "https://hog-backend-s6w9.onrender.com/api/v1";

async function apiFetch<T>(
  path: string,
  options: { token?: string; method?: string; body?: unknown } = {},
): Promise<T> {
  const headers: Record<string, string> = {
    "Content-Type": "application/json",
  };
  if (options.token) {
    headers["Authorization"] = `Bearer ${options.token}`;
  }

  const res = await fetch(`${BASE_URL}${path}`, {
    method: options.method ?? "GET",
    headers,
    body: options.body ? JSON.stringify(options.body) : undefined,
    cache: "no-store",
  });

  const data = await res.json().catch(() => ({}));
  if (!res.ok) {
    const message =
      (data as { message?: string; error?: string })?.message ||
      (data as { message?: string; error?: string })?.error ||
      `Request failed (${res.status})`;
    throw new Error(message);
  }
  return data as T;
}

export async function login(
  email: string,
  password: string,
): Promise<LoginResponse> {
  try {
    // The API itself never sends a `success` flag — a 2xx response with a
    // token and user IS the success case, and a failed login is a non-2xx
    // status that apiFetch already turns into a thrown Error below. So
    // `success` is computed here, not trusted from the response body.
    const data = await apiFetch<Omit<LoginResponse, "success">>(
      "/user/login",
      { method: "POST", body: { email, password } },
    );
    return { ...data, success: Boolean(data.token && data.user) };
  } catch (err) {
    return {
      success: false,
      error: err instanceof Error ? err.message : "Unable to sign in.",
    };
  }
}

export async function getPublicDesigners(): Promise<PublicDesigner[]> {
  const data = await apiFetch<{ success: boolean; data: PublicDesigner[] }>(
    "/discovery/public/designers",
  );
  return data.data ?? [];
}

export async function getPublicDesigner(
  id: string,
): Promise<PublicDesignerDetail | null> {
  const data = await apiFetch<{
    success: boolean;
    data: PublicDesignerDetail;
  }>(`/discovery/public/designers/${id}`);
  return data.data ?? null;
}

export async function getOrderHistory(
  token: string,
): Promise<OrderMaterial[]> {
  const data = await apiFetch<{ success: boolean; materials: OrderMaterial[] }>(
    "/review/getAllMaterialsForReview",
    { token },
  );
  return data.materials ?? [];
}

export async function getTrackingRecords(
  token: string,
): Promise<TrackingRecord[]> {
  const data = await apiFetch<{ success: boolean; data: TrackingRecord[] }>(
    "/tracking/getAllTracking",
    { token },
  );
  return data.data ?? [];
}

export async function trackCarrierShipment(
  token: string,
  carrierTrackingNumber: string,
  carrier: string = "fez",
): Promise<CarrierTrackingInfo> {
  const data = await apiFetch<{ success: boolean; data: CarrierTrackingInfo }>(
    `/tracking/carrier/${carrierTrackingNumber}?carrier=${carrier}`,
    { token },
  );
  return data.data;
}
