import 'package:flutter/material.dart';
import 'package:hog/App/Legal/Data/legal_documents.dart';
import 'package:hog/App/Legal/Model/legal_document.dart';
import 'package:hog/App/Legal/Views/legal_document_view.dart';
import 'package:hog/App/Profile/widgets/profileMenu.dart';
import 'package:hog/components/Navigator.dart';
import 'package:hog/components/customAppbar.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';

const double _kWideBreakpoint = 700;

class LegalPoliciesHome extends StatelessWidget {
  const LegalPoliciesHome({super.key});

  @override
  Widget build(BuildContext context) {
    final byCategory = <LegalCategory, List<LegalDocument>>{};
    for (final doc in legalDocuments) {
      byCategory.putIfAbsent(doc.category, () => []).add(doc);
    }

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const CustomAppBar(title: "Legal & Policies", enableAction: false),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= _kWideBreakpoint;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isWide ? 900 : double.infinity,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _IntroCard(),
                      for (final category in LegalCategory.values)
                        if (byCategory[category]?.isNotEmpty == true)
                          _CategorySection(
                            category: category,
                            documents: byCategory[category]!,
                            isWide: isWide,
                          ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(4, 8, 4, 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8F3FF), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.gavel_outlined, color: AppColors.accent),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  "Legal & Policies",
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 4),
                CustomText(
                  "Everything about how House of GLAME works, for customers and designers, in one place.",
                  fontSize: 12,
                  color: AppColors.subtext,
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final LegalCategory category;
  final List<LegalDocument> documents;
  final bool isWide;

  const _CategorySection({
    required this.category,
    required this.documents,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 2),
            child: CustomText(
              category.label,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              textAlign: TextAlign.left,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
            child: CustomText(
              category.description,
              fontSize: 12,
              color: AppColors.subtext,
              textAlign: TextAlign.left,
            ),
          ),
          if (isWide)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: 3.1,
              ),
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final doc = documents[index];
                return ProfileMenuItem(
                  icon: doc.icon,
                  text: doc.title,
                  subtitle: doc.summary,
                  onTap: () => Nav.push(context, LegalDocumentPage(slug: doc.slug)),
                );
              },
            )
          else
            ...documents.map(
              (doc) => ProfileMenuItem(
                icon: doc.icon,
                text: doc.title,
                subtitle: doc.summary,
                onTap: () => Nav.push(context, LegalDocumentPage(slug: doc.slug)),
              ),
            ),
        ],
      ),
    );
  }
}
