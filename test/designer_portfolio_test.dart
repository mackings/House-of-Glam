import 'package:flutter_test/flutter_test.dart';
import 'package:hog/App/Tailors/details.dart';

void main() {
  test(
    'designer portfolio parser supports nested profiles and hidden items',
    () {
      final items = designerPortfolioItems({
        'profile': {
          'portfolioGallery': [
            {
              'imageUrl': 'https://example.com/visible.jpg',
              'caption': 'Visible work',
              'isVisible': true,
            },
            {'imageUrl': 'https://example.com/hidden.jpg', 'isVisible': false},
          ],
          'categorizedWorkSections': {
            'nativeWear': [
              'https://example.com/native.jpg',
              'https://example.com/visible.jpg',
            ],
          },
        },
      });

      expect(
        items.map((item) => item.imageUrl),
        containsAll([
          'https://example.com/visible.jpg',
          'https://example.com/native.jpg',
        ]),
      );
      expect(
        items.map((item) => item.imageUrl),
        isNot(contains('https://example.com/hidden.jpg')),
      );
      expect(items, hasLength(2));
      expect(items.first.caption, 'Visible work');
    },
  );
}
