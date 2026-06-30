class Category {
  final String slug;
  final String label;

  const Category({required this.slug, required this.label});
}

const seedCategories = [
  Category(slug: 'work',     label: 'work'),
  Category(slug: 'personal', label: 'cá nhân'),
  Category(slug: 'startup',  label: 'startup'),
  Category(slug: 'buy',      label: 'mua đồ'),
];
