enum PredefinedCategory {
  promotions('Promotions', ['sale', 'discount', 'offer', 'promo']),
  social('Social', ['liked', 'commented', 'followed', 'friend request']),
  news('News', ['breaking', 'newsletter', 'headline']),
  shipping('Shipping', ['shipped', 'delivery', 'tracking', 'package']);

  const PredefinedCategory(this.label, this.defaultKeywords);

  final String label;
  final List<String> defaultKeywords;

  static PredefinedCategory? fromName(String name) {
    for (final category in PredefinedCategory.values) {
      if (category.name == name) {
        return category;
      }
    }
    return null;
  }
}
