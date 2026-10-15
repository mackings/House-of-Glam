import type { Metadata } from "next";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import { parseLegalContent, type LegalBlock } from "@/lib/legalContent";
import {
  PRIVACY_POLICY_EFFECTIVE_DATE,
  PRIVACY_POLICY_ENTITY,
  PRIVACY_POLICY_VERSION,
  privacyPolicyBody,
} from "@/lib/legal/privacyPolicy";

export const metadata: Metadata = {
  title: "Privacy Policy | House of GLAME",
  description:
    "How House of GLAME collects, uses, stores, and protects your personal information across our website, mobile apps, and marketplace services.",
};

function Block({ block }: { block: LegalBlock }) {
  switch (block.type) {
    case "heading":
      return (
        <h2
          id={block.sectionId}
          className="scroll-mt-28 font-display text-xl font-bold text-ink sm:text-2xl"
        >
          {block.text}
        </h2>
      );
    case "subheading":
      return (
        <h3 className="font-display text-base font-bold text-ink">
          {block.text}
        </h3>
      );
    case "paragraph":
      return (
        <p className="text-sm leading-relaxed text-subtext">{block.text}</p>
      );
    case "bullets":
      return (
        <ul className="list-disc space-y-1.5 pl-5 text-sm leading-relaxed text-subtext marker:text-accent">
          {block.items.map((item, i) => (
            <li key={i}>{item}</li>
          ))}
        </ul>
      );
    case "contact":
      return (
        <a
          href={
            block.contactType === "email"
              ? `mailto:${block.text}`
              : `https://${block.text.replace(/^https?:\/\//, "")}`
          }
          className="inline-block text-sm font-semibold text-accent hover:text-accent-deep"
        >
          {block.contactType === "email" ? "📧" : "🌐"} {block.text}
        </a>
      );
  }
}

export default function PrivacyPolicyPage() {
  const { blocks, sections } = parseLegalContent(privacyPolicyBody);

  return (
    <>
      <Navbar solid />
      <main className="flex-1 pt-28 pb-24">
        <div className="mx-auto max-w-5xl px-6 lg:px-8">
          <p className="text-sm font-bold uppercase tracking-[0.25em] text-secondary-deep">
            Legal
          </p>
          <h1 className="mt-3 font-display text-4xl font-bold leading-tight text-ink sm:text-5xl">
            Privacy Policy
          </h1>
          <div className="mt-5 flex flex-wrap gap-2">
            <span className="rounded-full bg-accent-soft px-3 py-1.5 text-xs font-bold text-accent">
              {PRIVACY_POLICY_ENTITY}
            </span>
            <span className="rounded-full bg-surface-muted px-3 py-1.5 text-xs font-semibold text-subtext">
              Effective {PRIVACY_POLICY_EFFECTIVE_DATE}
            </span>
            <span className="rounded-full bg-surface-muted px-3 py-1.5 text-xs font-semibold text-subtext">
              Version {PRIVACY_POLICY_VERSION}
            </span>
          </div>

          <div className="mt-12 grid gap-12 lg:grid-cols-[220px_1fr]">
            <nav className="hidden lg:block">
              <div className="sticky top-28">
                <p className="text-xs font-bold uppercase tracking-wide text-subtext">
                  On this page
                </p>
                <ul className="mt-4 space-y-2.5 border-l border-border pl-4">
                  {sections.map((section) => (
                    <li key={section.id}>
                      <a
                        href={`#${section.id}`}
                        className="text-xs leading-snug text-subtext hover:text-accent"
                      >
                        {section.title}
                      </a>
                    </li>
                  ))}
                </ul>
              </div>
            </nav>

            <div className="min-w-0 space-y-5 rounded-3xl border border-border bg-surface p-6 sm:p-10">
              {blocks.map((block, i) => (
                <div
                  key={i}
                  className={
                    block.type === "heading" && i !== 0
                      ? "pt-5 border-t border-border"
                      : undefined
                  }
                >
                  <Block block={block} />
                </div>
              ))}
            </div>
          </div>
        </div>
      </main>
      <Footer />
    </>
  );
}
