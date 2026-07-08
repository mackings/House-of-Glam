import 'package:flutter/material.dart';
import 'package:hog/App/Legal/Widgets/legal_content_parser.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class LegalContentView extends StatelessWidget {
  final List<LegalBlock> blocks;
  final Map<String, GlobalKey> sectionKeys;

  const LegalContentView({
    super.key,
    required this.blocks,
    required this.sectionKeys,
  });

  Future<void> _launchContact(
    BuildContext context,
    String contactType,
    String value,
  ) async {
    final uri =
        contactType == 'email'
            ? Uri.parse('mailto:$value')
            : Uri.parse(value.startsWith('http') ? value : 'https://$value');
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open ${contactType == 'email' ? 'email app' : 'browser'}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks.map((block) => _buildBlock(context, block)).toList(),
    );
  }

  Widget _buildBlock(BuildContext context, LegalBlock block) {
    switch (block.type) {
      case LegalBlockType.heading:
        return Container(
          key:
              block.sectionId != null ? sectionKeys[block.sectionId] : null,
          margin: const EdgeInsets.only(top: 26, bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 22,
                margin: const EdgeInsets.only(top: 2, right: 10),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Expanded(
                child: CustomText(
                  block.text ?? '',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        );

      case LegalBlockType.subheading:
        return Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 6),
          child: CustomText(
            block.text ?? '',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.accent,
            textAlign: TextAlign.left,
          ),
        );

      case LegalBlockType.paragraph:
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: CustomText(
            block.text ?? '',
            fontSize: 14,
            color: AppColors.subtext,
            textAlign: TextAlign.left,
          ),
        );

      case LegalBlockType.bullets:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                (block.items ?? [])
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 7),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 7, right: 10),
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: AppColors.secondaryDeep,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: CustomText(
                                item,
                                fontSize: 14,
                                color: AppColors.subtext,
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
          ),
        );

      case LegalBlockType.contact:
        final isEmail = block.contactType == 'email';
        return Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 6),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _launchContact(context, block.contactType!, block.text!),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isEmail ? Icons.email_outlined : Icons.public_outlined,
                    size: 16,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 8),
                  CustomText(
                    block.text ?? '',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}
