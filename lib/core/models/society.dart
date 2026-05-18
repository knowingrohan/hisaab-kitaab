class Society {
  const Society({
    required this.id,
    required this.name,
    required this.sortOrder,
  });

  final String id;
  final String name;
  final int sortOrder;

  factory Society.fromJson(Map<String, dynamic> json) => Society(
        id: json['id'] as String,
        name: json['name'] as String,
        sortOrder: json['sort_order'] as int? ?? 0,
      );
}
