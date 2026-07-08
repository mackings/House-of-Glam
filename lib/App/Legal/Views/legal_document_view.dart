import 'package:flutter/material.dart';
import 'package:hog/App/Legal/Data/legal_documents.dart';
import 'package:hog/App/Legal/Model/legal_document.dart';
import 'package:hog/App/Legal/Widgets/legal_content_parser.dart';
import 'package:hog/App/Legal/Widgets/legal_content_view.dart';
import 'package:hog/components/customAppbar.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';

const double _kWideBreakpoint = 760;
const double _kMaxReadingWidth = 720;

class LegalDocumentPage extends StatefulWidget {
  final String slug;

  const LegalDocumentPage({super.key, required this.slug});

  @override
  State<LegalDocumentPage> createState() => _LegalDocumentPageState();
}

class _LegalDocumentPageState extends State<LegalDocumentPage> {
  final ScrollController _scrollController = ScrollController();
  late final LegalDocument? _document;
  late final ParsedLegalDocument _parsed;
  late final Map<String, GlobalKey> _sectionKeys;
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();
    _document = findLegalDocument(widget.slug);
    _parsed = parseLegalContent(_document?.body ?? '');
    _sectionKeys = {for (final s in _parsed.sections) s.id: GlobalKey()};
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final show = _scrollController.offset > 420;
    if (show != _showBackToTop) {
      setState(() => _showBackToTop = show);
    }
  }

  void _jumpToSection(String id) {
    final key = _sectionKeys[id];
    final sectionContext = key?.currentContext;
    if (sectionContext != null) {
      Scrollable.ensureVisible(
        sectionContext,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.06,
      );
    }
  }

  void _openContentsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder:
          (sheetContext) => _ContentsSheet(
            sections: _parsed.sections,
            onSelect: (id) {
              Navigator.pop(sheetContext);
              Future.delayed(
                const Duration(milliseconds: 220),
                () => _jumpToSection(id),
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final document = _document;

    if (document == null) {
      return Scaffold(
        backgroundColor: AppColors.canvas,
        appBar: const CustomAppBar(title: "Document", enableAction: false),
        body: const Center(
          child: CustomText("This document could not be found."),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: CustomAppBar(
        title: document.title,
        enableAction: _parsed.sections.length > 2,
        actionIcon: Icons.toc_rounded,
        onAction: _openContentsSheet,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= _kWideBreakpoint;
            return Stack(
              children: [
                isWide ? _buildWideLayout(document) : _buildNarrowLayout(document),
                if (_showBackToTop)
                  Positioned(
                    right: 18,
                    bottom: 18,
                    child: FloatingActionButton.small(
                      heroTag: 'legal-back-to-top',
                      backgroundColor: AppColors.accent,
                      elevation: 2,
                      onPressed:
                          () => _scrollController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOut,
                          ),
                      child: const Icon(
                        Icons.arrow_upward_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNarrowLayout(LegalDocument document) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DocumentHeader(document: document),
          const SizedBox(height: 6),
          LegalContentView(blocks: _parsed.blocks, sectionKeys: _sectionKeys),
        ],
      ),
    );
  }

  Widget _buildWideLayout(LegalDocument document) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 260,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 8, 18),
            child: _TableOfContents(
              sections: _parsed.sections,
              onSelect: _jumpToSection,
            ),
          ),
        ),
        const VerticalDivider(width: 1, color: AppColors.border),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(28, 18, 28, 64),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _kMaxReadingWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DocumentHeader(document: document),
                    const SizedBox(height: 6),
                    LegalContentView(
                      blocks: _parsed.blocks,
                      sectionKeys: _sectionKeys,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DocumentHeader extends StatelessWidget {
  final LegalDocument document;

  const _DocumentHeader({required this.document});

  @override
  Widget build(BuildContext context) {
    final hasMeta = document.entity != null || document.effectiveDate != null;
    if (!hasMeta) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (document.entity != null)
            CustomText(
              document.entity!,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
              textAlign: TextAlign.left,
            ),
          if (document.entity != null) const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (document.effectiveDate != null)
                _MetaChip(
                  icon: Icons.event_outlined,
                  label: "Effective ${document.effectiveDate}",
                ),
              if (document.version != null)
                _MetaChip(
                  icon: Icons.bookmark_outline_rounded,
                  label: "Version ${document.version}",
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.secondaryDeep),
          const SizedBox(width: 5),
          CustomText(
            label,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.secondaryDeep,
          ),
        ],
      ),
    );
  }
}

class _TableOfContents extends StatelessWidget {
  final List<LegalSection> sections;
  final ValueChanged<String> onSelect;

  const _TableOfContents({required this.sections, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 10, left: 4),
            child: CustomText(
              "Contents",
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.subtext,
              textAlign: TextAlign.left,
            ),
          ),
          ...sections.map(
            (section) => InkWell(
              onTap: () => onSelect(section.id),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
                child: CustomText(
                  section.title,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                  textAlign: TextAlign.left,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentsSheet extends StatelessWidget {
  final List<LegalSection> sections;
  final ValueChanged<String> onSelect;

  const _ContentsSheet({required this.sections, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, controller) {
        return Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 14, 20, 6),
              child: CustomText(
                "Contents",
                fontSize: 16,
                fontWeight: FontWeight.w800,
                textAlign: TextAlign.left,
              ),
            ),
            Expanded(
              child: ListView.separated(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                itemCount: sections.length,
                separatorBuilder:
                    (_, _) => const Divider(height: 1, color: AppColors.border),
                itemBuilder: (context, index) {
                  final section = sections[index];
                  return InkWell(
                    onTap: () => onSelect(section.id),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: CustomText(
                        section.title,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
