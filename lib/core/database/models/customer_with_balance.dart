class CustomerWithBalance {
  final int id;
  final String name;
  final String flatNumber;
  final String? phone;
  final int? societyId;
  final int totalBilled;
  final int totalPaid;
  final DateTime? lastEntryDate;

  const CustomerWithBalance({
    required this.id,
    required this.name,
    required this.flatNumber,
    this.phone,
    this.societyId,
    required this.totalBilled,
    required this.totalPaid,
    this.lastEntryDate,
  });

  int get balance => totalBilled - totalPaid;

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
