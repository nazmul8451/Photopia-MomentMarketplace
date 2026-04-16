class CategoryModel {
  final String id;
  final String name;
  final String? description;
  final String? image;
  final String? icon;
  final String? parent; // Parent category ID
  final String type; // 'category' or 'subcategory'
  final bool isPopular;
  final bool isActive;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.icon,
    this.parent,
    required this.type,
    this.isPopular = false,
    this.isActive = true,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      image: json['image'],
      icon: json['icon'],
      parent: json['parent'] is Map ? json['parent']['_id'] : json['parent'],
      type: json['type'] ?? 'category',
      isPopular: json['isPopular'] ?? false,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'image': image,
      'icon': icon,
      'parent': parent,
      'type': type,
      'isPopular': isPopular,
      'isActive': isActive,
    };
  }
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
