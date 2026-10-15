// Shared types for data coming back from the House of GLAME API
// (https://hog-backend-s6w9.onrender.com/api/v1). Field shapes are taken directly
// from live responses, not just the docs — some fields are optional because
// they're genuinely absent on some records (e.g. a designer with no
// portfolio yet).

export interface AuthUser {
  _id: string;
  fullName: string;
  email: string;
  phoneNumber?: string;
  role: string;
  image?: string | null;
  address?: string;
  country?: string;
  city?: string | null;
  state?: string | null;
  isVerified?: boolean;
  isVendorEnabled?: boolean;
}

export interface LoginResponse {
  // The live API returns { message: "Login successful", token, user } on
  // success — no `success` field at all — and something like
  // { message: "Invalid credentials" } (still no `success`/`error` field,
  // and still a non-2xx status our fetch layer already throws on) on
  // failure. `success` only ever gets set locally, by login() in api.ts,
  // to give callers one boolean to check instead of "does token exist".
  success: boolean;
  message?: string;
  token?: string;
  user?: AuthUser;
  error?: string;
}

export interface PublicDesignerUser {
  _id: string;
  fullName: string;
  country?: string;
}

export interface PublicDesigner {
  _id: string;
  userId?: PublicDesignerUser;
  businessName?: string;
  businessEmail?: string;
  businessPhone?: string;
  phoneNumber?: string;
  address?: string;
  country?: string;
  state?: string;
  city?: string;
  description?: string;
  yearOfExperience?: string | number;
  totalRatings?: number;
  ratingSum?: number;
  portfolioGallery?: { imageUrl: string }[];
  categorizedWorkSections?: Record<string, string[]>;
  nepaBill?: string;
}

export interface DesignerSocialProof {
  completedOrders?: number;
  reviews?: number;
  ratings?: number;
}

export interface PublicDesignerDetail extends PublicDesigner {
  socialProof?: DesignerSocialProof;
}

// Mirrors the app's real submission schema (lib/App/Home/Views/Orders/Placeorder.dart
// + lib/App/Home/Model/historymodel.dart) — 13 fields, most sent as lowercase,
// no-space keys ("Sleeve Length" -> "sleevelength"), one field ("hip") that is
// singular despite every other body-measurement field also being singular.
// Some older/seeded records use different casing or "hips" (plural) — both
// are accepted defensively rather than silently dropping the value.
export interface Measurement {
  neck?: number;
  shoulder?: number;
  chest?: number;
  waist?: number;
  hip?: number;
  hips?: number;
  length?: number;
  armlength?: number;
  armLength?: number;
  sleevelength?: number;
  sleeveLength?: number;
  aroundarm?: number;
  aroundArm?: number;
  wrist?: number;
  collarfront?: number;
  collarFront?: number;
  collarback?: number;
  collarBack?: number;
  armType?: string;
}

export interface TrackingMaterial {
  _id: string;
  clothMaterial?: string;
  color?: string;
  brand?: string;
  attireType?: string;
  sampleImage?: string[];
  // The tracking endpoint returns this as a single object; the order-history
  // endpoint returns an array with one entry. Both shapes are kept here and
  // normalized by firstMeasurement() at the call site rather than picking
  // one and guessing wrong.
  measurement?: Measurement | Measurement[];
}

export interface TrackingRecord {
  _id: string;
  userId: string;
  vendorId: string;
  materialId?: TrackingMaterial;
  isDelivered: boolean;
  status?: string;
  carrier?: string;
  carrierTrackingNumber?: string;
  serviceType?: string;
  trackingNumber?: number;
  createdAt?: string;
  updatedAt?: string;
}

export interface OrderMaterial {
  _id: string;
  clothMaterial?: string;
  color?: string;
  brand?: string;
  attireType?: string;
  specialInstructions?: string;
  isDelivered?: boolean;
  sampleImage?: string[];
  measurement?: Measurement | Measurement[];
  settlement?: number;
  createdAt?: string;
}

export interface CarrierTrackingEvent {
  status: string;
  timestamp?: string;
  description?: string;
}

export interface CarrierTrackingInfo {
  carrier: string;
  orderNumber?: string;
  trackingNumber?: string;
  status: string;
  statusDescription?: string;
  senderName?: string;
  senderAddress?: string;
  recipientName?: string;
  recipientAddress?: string;
  recipientState?: string;
  createdAt?: string;
  proofOfDelivery?: string | null;
  events?: CarrierTrackingEvent[];
}
