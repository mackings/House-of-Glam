// Lightweight markup parser for legal document bodies — mirrors the grammar
// used by the app's own legal docs (lib/App/Legal/Widgets/legal_content_parser.dart)
// so the web page renders the exact same source text the app does, not a
// re-authored copy that can drift out of sync.
//
// `## `  major section (also becomes a table-of-contents entry)
// `### ` subsection heading
// `- `   bullet item (consecutive lines group into one list)
// `📧 `  contact row, rendered as a mailto: link
// `🌐 `  contact row, rendered as a website link
// blank line: paragraph/bullet-group break
// anything else: paragraph text

export type LegalBlock =
  | { type: "heading"; text: string; sectionId: string }
  | { type: "subheading"; text: string }
  | { type: "paragraph"; text: string }
  | { type: "bullets"; items: string[] }
  | { type: "contact"; contactType: "email" | "web"; text: string };

export interface LegalSection {
  id: string;
  title: string;
}

export interface ParsedLegalDocument {
  blocks: LegalBlock[];
  sections: LegalSection[];
}

export function parseLegalContent(raw: string): ParsedLegalDocument {
  const lines = raw.split("\n");
  const blocks: LegalBlock[] = [];
  const sections: LegalSection[] = [];
  let bulletBuffer: string[] = [];
  let headingCount = 0;

  const flushBullets = () => {
    if (bulletBuffer.length > 0) {
      blocks.push({ type: "bullets", items: bulletBuffer });
      bulletBuffer = [];
    }
  };

  for (const rawLine of lines) {
    const line = rawLine.trim();

    if (line.length === 0) {
      flushBullets();
      continue;
    }

    if (line.startsWith("## ")) {
      flushBullets();
      const text = line.slice(3).trim();
      headingCount++;
      const id = `section-${headingCount}`;
      sections.push({ id, title: text });
      blocks.push({ type: "heading", text, sectionId: id });
      continue;
    }

    if (line.startsWith("### ")) {
      flushBullets();
      blocks.push({ type: "subheading", text: line.slice(4).trim() });
      continue;
    }

    if (line.startsWith("- ")) {
      bulletBuffer.push(line.slice(2).trim());
      continue;
    }

    if (line.startsWith("📧")) {
      flushBullets();
      blocks.push({
        type: "contact",
        contactType: "email",
        text: line.replace("📧", "").trim(),
      });
      continue;
    }

    if (line.startsWith("🌐")) {
      flushBullets();
      blocks.push({
        type: "contact",
        contactType: "web",
        text: line.replace("🌐", "").trim(),
      });
      continue;
    }

    flushBullets();
    blocks.push({ type: "paragraph", text: line });
  }

  flushBullets();
  return { blocks, sections };
}
