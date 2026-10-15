import type { Measurement } from "./types";

// The order-history endpoint returns `measurement` as an array (matching the
// app's `List<Measurement>` model — normally one entry, but never assumed to
// be exactly one); the tracking endpoint returns the same field as a single
// object. Both shapes are normalized to an array here rather than picked
// between and guessed wrong.
export function normalizeMeasurements(
  m?: Measurement | Measurement[],
): Measurement[] {
  if (!m) return [];
  return Array.isArray(m) ? m : [m];
}

// Same order and labels as the app's own measurement summary
// (lib/components/Orders/details.dart _MeasurementCard), including its one
// irregular key ("hip", singular, despite chest/waist/length pattern) and
// the multi-word fields the app strips spaces + lowercases before sending
// ("Sleeve Length" -> "sleevelength"). Both the lowercase-no-space key and a
// camelCase fallback are checked, plus "hips" for older/seeded records that
// used the plural.
export function measurementEntries(
  m: Measurement,
): { label: string; value: string }[] {
  const pick = (...values: Array<number | string | undefined>) =>
    values.find((v) => v !== undefined && v !== null && v !== "");

  const rows: [string, number | string | undefined][] = [
    ["Neck", pick(m.neck)],
    ["Shoulder", pick(m.shoulder)],
    ["Chest", pick(m.chest)],
    ["Waist", pick(m.waist)],
    ["Hip", pick(m.hip, m.hips)],
    ["Length", pick(m.length)],
    ["Arm Length", pick(m.armlength, m.armLength)],
    ["Sleeve Length", pick(m.sleevelength, m.sleeveLength)],
    ["Around Arm", pick(m.aroundarm, m.aroundArm)],
    ["Wrist", pick(m.wrist)],
    ["Collar Front", pick(m.collarfront, m.collarFront)],
    ["Collar Back", pick(m.collarback, m.collarBack)],
    ["Arm Type", pick(m.armType)],
  ];

  return rows
    .filter(([, value]) => value !== undefined)
    .map(([label, value]) => ({
      label,
      value: typeof value === "number" ? `${value}"` : String(value),
    }));
}
