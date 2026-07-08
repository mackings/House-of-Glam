import 'package:flutter/material.dart';

enum LegalCategory { quickGuide, policy, community }

extension LegalCategoryLabel on LegalCategory {
  String get label {
    switch (this) {
      case LegalCategory.quickGuide:
        return "Quick Guides";
      case LegalCategory.policy:
        return "Legal Policies";
      case LegalCategory.community:
        return "Community & Safety";
    }
  }

  String get description {
    switch (this) {
      case LegalCategory.quickGuide:
        return "Plain-English summaries of how things work";
      case LegalCategory.policy:
        return "The full legal terms that govern House of GLAME";
      case LegalCategory.community:
        return "Standards that keep the community safe and fair";
    }
  }
}

class LegalDocument {
  final String slug;
  final String title;
  final String summary;
  final String? entity;
  final String? effectiveDate;
  final String? version;
  final IconData icon;
  final LegalCategory category;
  final String body;

  const LegalDocument({
    required this.slug,
    required this.title,
    required this.summary,
    this.entity,
    this.effectiveDate,
    this.version,
    required this.icon,
    required this.category,
    required this.body,
  });
}
