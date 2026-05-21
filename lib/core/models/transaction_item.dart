/// Unified display row for the customer detail transaction timeline.
/// Merges entries (You Gave) and payments (You Got) into one sorted list.
enum TransactionType { gave, got }

class TransactionItem {
  const TransactionItem({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    this.description,
    required this.runningBalance,
    this.editCount = 0,
  });

  final String id;
  final TransactionType type;
  final int amount;

  /// entry_date / payment_date — a DATE value parsed as local midnight.
  final DateTime date;
  final String? description;

  /// Running balance after this transaction (positive = customer owes).
  final int runningBalance;

  /// Number of times this entry has been edited (always 0 for payments).
  final int editCount;

  bool get isGave => type == TransactionType.gave;
}

class AppEntry {
  const AppEntry({
    required this.id,
    required this.customerId,
    required this.totalAmount,
    required this.entryDate,
    this.description,
    required this.createdAt,
    required this.createdBy,
    this.editCount = 0,
  });

  final String id;
  final String customerId;
  final int totalAmount;
  final DateTime entryDate;
  final String? description;
  final DateTime createdAt;
  final String createdBy;
  final int editCount;

  factory AppEntry.fromJson(Map<String, dynamic> json) => AppEntry(
        id: json['id'] as String,
        customerId: json['customer_id'] as String,
        totalAmount: json['total_amount'] as int,
        entryDate: DateTime.parse(json['entry_date'] as String),
        description: json['description'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        createdBy: json['created_by'] as String,
        editCount: (json['edit_count'] as int?) ?? 0,
      );
}

class AppPayment {
  const AppPayment({
    required this.id,
    required this.customerId,
    required this.amount,
    required this.mode,
    required this.paymentDate,
    this.notes,
    required this.createdAt,
    required this.createdBy,
  });

  final String id;
  final String customerId;
  final int amount;
  final String mode;
  final DateTime paymentDate;
  final String? notes;
  final DateTime createdAt;
  final String createdBy;

  factory AppPayment.fromJson(Map<String, dynamic> json) => AppPayment(
        id: json['id'] as String,
        customerId: json['customer_id'] as String,
        amount: json['amount'] as int,
        mode: json['mode'] as String,
        paymentDate: DateTime.parse(json['payment_date'] as String),
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        createdBy: json['created_by'] as String,
      );
}
