String toSlug(String label) =>
    label.toLowerCase().trim()
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'[^\w\-]'), '');
