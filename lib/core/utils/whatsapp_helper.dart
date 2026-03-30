import 'package:url_launcher/url_launcher.dart';

class WhatsAppHelper {
  /// Builds a reminder message from the stored template.
  /// Template variables: {customer_name}, {amount}, {business_name}
  static String buildMessage({
    required String template,
    required String customerName,
    required int balance,
    required String businessName,
    String upiLink = '',
  }) {
    String msg = template
        .replaceAll('{customer_name}', customerName)
        .replaceAll('{amount}', '₹$balance')
        .replaceAll('{business_name}', businessName);

    if (upiLink.isNotEmpty) {
      msg += '\n\nPayment link: $upiLink';
    }
    return msg;
  }

  /// Launches WhatsApp with a pre-filled message to the given phone number.
  /// Phone must be a valid Indian mobile number (with or without +91 prefix).
  static Future<bool> sendReminder({
    required String phone,
    required String message,
  }) async {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return false;

    final phoneWithCode =
        digits.startsWith('91') && digits.length == 12 ? digits : '91$digits';

    final encoded = Uri.encodeComponent(message);
    final waUrl = Uri.parse('whatsapp://send?phone=$phoneWithCode&text=$encoded');

    if (await canLaunchUrl(waUrl)) {
      await launchUrl(waUrl);
      return true;
    }

    // Fallback: wa.me web link
    final webUrl =
        Uri.parse('https://wa.me/$phoneWithCode?text=$encoded');
    if (await canLaunchUrl(webUrl)) {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      return true;
    }

    return false;
  }
}
