sealed class TransactionItem {
  DateTime get date;
}

class EntryTransaction extends TransactionItem {
  final int entryId;
  final DateTime entryDate;
  final int totalAmount;
  final List<EntryLineItem> items;

  EntryTransaction({
    required this.entryId,
    required this.entryDate,
    required this.totalAmount,
    required this.items,
  });

  @override
  DateTime get date => entryDate;
}

class PaymentTransaction extends TransactionItem {
  final int paymentId;
  final DateTime paymentDate;
  final int amount;
  final String mode;
  final String? notes;

  PaymentTransaction({
    required this.paymentId,
    required this.paymentDate,
    required this.amount,
    required this.mode,
    this.notes,
  });

  @override
  DateTime get date => paymentDate;
}

class EntryLineItem {
  final String name;
  final int quantity;
  final String iconName;

  const EntryLineItem({
    required this.name,
    required this.quantity,
    required this.iconName,
  });
}
