class Customer {
  const Customer({
    required this.id,
    required this.name,
    required this.flatNumber,
    required this.societyId,
    required this.societyName,
    this.phone,
    this.email,
    this.userId,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String flatNumber;
  final String societyId;
  final String societyName;
  final String? phone;
  final String? email;
  final String? userId;
  final bool isActive;
  final DateTime createdAt;

  factory Customer.fromJson(Map<String, dynamic> json) {
    final society = json['societies'] as Map<String, dynamic>?;
    return Customer(
      id: json['id'] as String,
      name: json['name'] as String,
      flatNumber: json['flat_number'] as String,
      societyId: json['society_id'] as String,
      societyName: society?['name'] as String? ?? '',
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      userId: json['user_id'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class CustomerWithBalance {
  const CustomerWithBalance({
    required this.customer,
    required this.balance,
    required this.totalGave,
    required this.totalGot,
  });

  final Customer customer;

  /// Positive = customer owes money. Negative = overpaid (rare).
  final int balance;
  final int totalGave;
  final int totalGot;

  String get id => customer.id;
  String get name => customer.name;
  String get flatNumber => customer.flatNumber;
  String get societyId => customer.societyId;
  String get societyName => customer.societyName;
  String? get phone => customer.phone;
  String? get email => customer.email;

  /// Total amount billed (alias for totalGave).
  int get totalBilled => totalGave;

  /// Total amount paid (alias for totalGot).
  int get totalPaid => totalGot;

  /// First letter of each word in the name, up to 2 characters.
  String get initials {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
}
