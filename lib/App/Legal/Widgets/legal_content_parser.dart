enum LegalBlockType { heading, subheading, paragraph, bullets, contact }

class LegalBlock {
  final LegalBlockType type;
  final String? text;
  final List<String>? items;
  final String? contactType;
  final String? sectionId;

  const LegalBlock._({
    required this.type,
    this.text,
    this.items,
    this.contactType,
    this.sectionId,
  });

  factory LegalBlock.heading(String text, String sectionId) => LegalBlock._(
    type: LegalBlockType.heading,
    text: text,
    sectionId: sectionId,
  );

  factory LegalBlock.subheading(String text) =>
      LegalBlock._(type: LegalBlockType.subheading, text: text);

  factory LegalBlock.paragraph(String text) =>
      LegalBlock._(type: LegalBlockType.paragraph, text: text);

  factory LegalBlock.bullets(List<String> items) =>
      LegalBlock._(type: LegalBlockType.bullets, items: items);

  factory LegalBlock.contact(String contactType, String text) => LegalBlock._(
    type: LegalBlockType.contact,
    contactType: contactType,
    text: text,
  );
}

class LegalSection {
  final String id;
  final String title;
  const LegalSection(this.id, this.title);
}

class ParsedLegalDocument {
  final List<LegalBlock> blocks;
  final List<LegalSection> sections;
  const ParsedLegalDocument(this.blocks, this.sections);
}

/// Parses a lightweight markup used for legal document bodies:
/// `## ` major numbered section (also becomes a table-of-contents entry)
/// `### ` subsection heading
/// `- ` bullet item (consecutive lines are grouped into one list)
/// `📧 ` / `🌐 ` contact rows (rendered as tappable email/website links)
/// blank line: paragraph/bullet-group break
/// anything else: paragraph text
ParsedLegalDocument parseLegalContent(String raw) {
  final lines = raw.split('\n');
  final blocks = <LegalBlock>[];
  final sections = <LegalSection>[];
  var bulletBuffer = <String>[];
  var headingCount = 0;

  void flushBullets() {
    if (bulletBuffer.isNotEmpty) {
      blocks.add(LegalBlock.bullets(List.of(bulletBuffer)));
      bulletBuffer = [];
    }
  }

  for (final rawLine in lines) {
    final line = rawLine.trim();

    if (line.isEmpty) {
      flushBullets();
      continue;
    }

    if (line.startsWith('## ')) {
      flushBullets();
      final text = line.substring(3).trim();
      headingCount++;
      final id = 'section-$headingCount';
      sections.add(LegalSection(id, text));
      blocks.add(LegalBlock.heading(text, id));
      continue;
    }

    if (line.startsWith('### ')) {
      flushBullets();
      blocks.add(LegalBlock.subheading(line.substring(4).trim()));
      continue;
    }

    if (line.startsWith('- ')) {
      bulletBuffer.add(line.substring(2).trim());
      continue;
    }

    if (line.startsWith('📧')) {
      flushBullets();
      blocks.add(
        LegalBlock.contact('email', line.replaceFirst('📧', '').trim()),
      );
      continue;
    }

    if (line.startsWith('🌐')) {
      flushBullets();
      blocks.add(LegalBlock.contact('web', line.replaceFirst('🌐', '').trim()));
      continue;
    }

    flushBullets();
    blocks.add(LegalBlock.paragraph(line));
  }

  flushBullets();
  return ParsedLegalDocument(blocks, sections);
}
