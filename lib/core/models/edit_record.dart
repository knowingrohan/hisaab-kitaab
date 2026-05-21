import 'package:intl/intl.dart';

class EditRecord {
  const EditRecord({
    required this.id,
    required this.entryId,
    required this.editedById,
    required this.editedByName,
    required this.editedAt,
    required this.amountBefore,
    required this.amountAfter,
    this.descriptionBefore,
    this.descriptionAfter,
    required this.dateBefore,
    required this.dateAfter,
  });

  final String id;
  final String entryId;
  final String editedById;
  final String editedByName;
  final DateTime editedAt;
  final int amountBefore;
  final int amountAfter;
  final String? descriptionBefore;
  final String? descriptionAfter;
  final DateTime dateBefore;
  final DateTime dateAfter;

  bool get amountChanged => amountBefore != amountAfter;
  bool get descriptionChanged => descriptionBefore != descriptionAfter;
  bool get dateChanged => !_isSameDay(dateBefore, dateAfter);

  String get formattedEditedAt =>
      DateFormat('d MMM yy • hh:mm a').format(editedAt.toLocal());

  factory EditRecord.fromJson(Map<String, dynamic> json) => EditRecord(
        id: json['id'] as String,
        entryId: json['entry_id'] as String,
        editedById: json['edited_by'] as String,
        editedByName: json['edited_by_name'] as String,
        editedAt: DateTime.parse(json['edited_at'] as String),
        amountBefore: json['amount_before'] as int,
        amountAfter: json['amount_after'] as int,
        descriptionBefore: json['description_before'] as String?,
        descriptionAfter: json['description_after'] as String?,
        dateBefore: DateTime.parse(json['date_before'] as String),
        dateAfter: DateTime.parse(json['date_after'] as String),
      );

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
