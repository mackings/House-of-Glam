import 'package:hog/App/Home/Api/useractivity.dart';
import 'package:hog/App/Home/Model/historymodel.dart';
import 'package:hog/App/Home/Model/reviewModel.dart';

class OrderContext {
  final MaterialReview material;
  final Review review;

  const OrderContext({required this.material, required this.review});

  bool get hasAcceptedQuote => review.hasAcceptedOffer || review.amountPaid > 0;

  bool get hasPayment =>
      review.amountPaid > 0 || review.status == 'full payment';

  String get title {
    final attire =
        material.attireType.isNotEmpty ? material.attireType : 'Custom order';
    final designer =
        review.user.fullName.isNotEmpty ? review.user.fullName : 'Designer';
    return '$attire with $designer';
  }

  String get subtitle {
    final status = review.status.isNotEmpty ? review.status : 'quote accepted';
    return '$status • ${material.clothMaterial} • ${material.color}';
  }
}

class OrderContextService {
  static Future<List<OrderContext>> getQuotationContexts({
    bool acceptedOnly = false,
    bool paidOnly = false,
  }) async {
    final response = await UserActivityService.getAllMaterialsForReview();
    if (response == null || !response.success) {
      return const [];
    }

    final contexts = <OrderContext>[];
    for (final material in response.materials) {
      final reviewsResponse =
          await UserActivityService.getReviewsForMaterialById(material.id);
      if (reviewsResponse == null || !reviewsResponse.success) {
        continue;
      }

      for (final review in reviewsResponse.reviews) {
        final context = OrderContext(material: material, review: review);
        if (acceptedOnly && !context.hasAcceptedQuote) continue;
        if (paidOnly && !context.hasPayment) continue;
        contexts.add(context);
      }
    }

    contexts.sort(
      (a, b) => (DateTime.tryParse(b.material.createdAt) ??
              DateTime.fromMillisecondsSinceEpoch(0))
          .compareTo(
            DateTime.tryParse(a.material.createdAt) ??
                DateTime.fromMillisecondsSinceEpoch(0),
          ),
    );
    return contexts;
  }
}
