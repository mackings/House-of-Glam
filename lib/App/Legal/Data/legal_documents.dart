import 'package:flutter/material.dart';
import 'package:hog/App/Legal/Data/content/community_guidelines.dart';
import 'package:hog/App/Legal/Data/content/cookie_policy.dart';
import 'package:hog/App/Legal/Data/content/customer_conduct.dart';
import 'package:hog/App/Legal/Data/content/customer_summary.dart';
import 'package:hog/App/Legal/Data/content/designer_conduct.dart';
import 'package:hog/App/Legal/Data/content/designer_summary.dart';
import 'package:hog/App/Legal/Data/content/designer_terms.dart';
import 'package:hog/App/Legal/Data/content/privacy_policy.dart';
import 'package:hog/App/Legal/Data/content/refunds_policy.dart';
import 'package:hog/App/Legal/Data/content/terms_conditions.dart';
import 'package:hog/App/Legal/Data/content/trust_safety.dart';
import 'package:hog/App/Legal/Model/legal_document.dart';

const String _effectiveDate = "28 October 2025";
const String _version = "1.0";
const String _entity = "House of GLAME Ltd";

final List<LegalDocument> legalDocuments = [
  const LegalDocument(
    slug: "customer-summary",
    title: "Customer Summary",
    summary: "Your quick guide to shopping safely and confidently",
    icon: Icons.auto_stories_outlined,
    category: LegalCategory.quickGuide,
    body: customerSummaryBody,
  ),
  const LegalDocument(
    slug: "designer-summary",
    title: "Designer Onboarding Summary",
    summary: "A simple guide to how things work for designers",
    icon: Icons.palette_outlined,
    category: LegalCategory.quickGuide,
    body: designerSummaryBody,
  ),
  const LegalDocument(
    slug: "terms-conditions",
    title: "Terms & Conditions",
    summary: "The rules that govern your use of House of GLAME",
    entity: _entity,
    effectiveDate: _effectiveDate,
    version: _version,
    icon: Icons.gavel_outlined,
    category: LegalCategory.policy,
    body: termsConditionsBody,
  ),
  const LegalDocument(
    slug: "privacy-policy",
    title: "Privacy Policy",
    summary: "How we collect, use, and protect your information",
    entity: _entity,
    effectiveDate: _effectiveDate,
    version: _version,
    icon: Icons.privacy_tip_outlined,
    category: LegalCategory.policy,
    body: privacyPolicyBody,
  ),
  const LegalDocument(
    slug: "refunds-policy",
    title: "Refunds, Returns & Buyer Protection",
    summary: "When refunds apply and how disputes are handled",
    entity: _entity,
    effectiveDate: _effectiveDate,
    version: _version,
    icon: Icons.verified_user_outlined,
    category: LegalCategory.policy,
    body: refundsPolicyBody,
  ),
  const LegalDocument(
    slug: "designer-terms",
    title: "Designer Terms, Subscription & Commission",
    summary: "Legal obligations, fees, and payouts for designers",
    entity: _entity,
    effectiveDate: _effectiveDate,
    version: _version,
    icon: Icons.storefront_outlined,
    category: LegalCategory.policy,
    body: designerTermsBody,
  ),
  const LegalDocument(
    slug: "cookie-policy",
    title: "Cookie Policy",
    summary: "How we use cookies across the platform",
    entity: _entity,
    effectiveDate: _effectiveDate,
    version: _version,
    icon: Icons.cookie_outlined,
    category: LegalCategory.policy,
    body: cookiePolicyBody,
  ),
  const LegalDocument(
    slug: "trust-safety",
    title: "Trust & Safety Policy",
    summary: "How we keep the marketplace safe and fair",
    icon: Icons.shield_outlined,
    category: LegalCategory.community,
    body: trustSafetyBody,
  ),
  const LegalDocument(
    slug: "community-guidelines",
    title: "Community Guidelines",
    summary: "How everyone is expected to behave on the platform",
    icon: Icons.diversity_3_outlined,
    category: LegalCategory.community,
    body: communityGuidelinesBody,
  ),
  const LegalDocument(
    slug: "customer-conduct",
    title: "Customer Code of Conduct",
    summary: "What's expected of customers on House of GLAME",
    icon: Icons.person_outline_rounded,
    category: LegalCategory.community,
    body: customerConductBody,
  ),
  const LegalDocument(
    slug: "designer-conduct",
    title: "Designer Code of Conduct",
    summary: "Professional standards expected of every designer",
    icon: Icons.design_services_outlined,
    category: LegalCategory.community,
    body: designerConductBody,
  ),
];

LegalDocument? findLegalDocument(String slug) {
  for (final doc in legalDocuments) {
    if (doc.slug == slug) return doc;
  }
  return null;
}
