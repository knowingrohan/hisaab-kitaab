class UpiHelper {
  /// Builds a UPI deep-link that opens any UPI payment app.
  /// Returns empty string if upiId is empty.
  static String buildLink({
    required String upiId,
    required String payeeName,
    required int amount,
  }) {
    if (upiId.trim().isEmpty) return '';

    final pa = Uri.encodeComponent(upiId.trim());
    final pn = Uri.encodeComponent(payeeName.trim());
    return 'upi://pay?pa=$pa&pn=$pn&am=$amount&cu=INR';
  }
}
