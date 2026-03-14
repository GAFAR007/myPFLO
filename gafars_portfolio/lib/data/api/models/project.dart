class PortfolioProject {
  const PortfolioProject({
    required this.id,
    required this.title,
    this.subtitle,
    this.description,
    this.url,
    this.tags = const <String>[],
    this.isActive = true,
    this.sortOrder = 0,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String? description;
  final String? url;
  final List<String> tags;
  final bool isActive;
  final int sortOrder;

  factory PortfolioProject.fromMap(Map<String, dynamic> map) {
    return PortfolioProject(
      id: (map['id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      subtitle: _toNullableString(map['subtitle']),
      description: _toNullableString(map['description']),
      url: _toNullableString(map['url']),
      tags: (map['tags'] as List<dynamic>? ?? const <dynamic>[])
          .map((tag) => tag.toString().trim())
          .where((tag) => tag.isNotEmpty)
          .toList(),
      isActive: map['isActive'] == null
          ? (map['is_active'] == null ? true : map['is_active'] as bool)
          : map['isActive'] as bool,
      sortOrder: map['sortOrder'] == null
          ? (map['sort_order'] as num? ?? 0).toInt()
          : (map['sortOrder'] as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'url': url,
      'tags': tags,
      'isActive': isActive,
      'sortOrder': sortOrder,
    }..removeWhere((_, value) => value == null);
  }

  static String? _toNullableString(dynamic value) {
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
