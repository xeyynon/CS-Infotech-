import 'package:flutter/services.dart';

/// Pure validators. Return null when valid, else a message for the field.
abstract final class Validators {
  static final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  static String? required(String? v, [String label = 'This field']) =>
      (v == null || v.trim().isEmpty) ? '$label is required' : null;

  static String? name(String? v) {
    final r = required(v, 'Name');
    if (r != null) return r;
    return v!.trim().length < 2 ? 'Enter your full name' : null;
  }

  static String? email(String? v) {
    final r = required(v, 'Email');
    if (r != null) return r;
    return _email.hasMatch(v!.trim()) ? null : 'Enter a valid email address';
  }

  static String? password(String? v) {
    final r = required(v, 'Password');
    if (r != null) return r;
    return v!.length < 6 ? 'Use at least 6 characters' : null;
  }

  /// Sign-in only checks that a password was typed: the server's own
  /// example account uses "123" (Postman collection), so a length rule
  /// here would block real accounts. The 6-character rule is for sign-up.
  static String? loginPassword(String? v) => required(v, 'Password');

  static String? mobile(String? v) {
    final r = required(v, 'Mobile number');
    if (r != null) return r;
    final digits = v!.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) return 'Enter a 10-digit mobile number';
    // B-15: Indian mobile numbers start with 6, 7, 8 or 9.
    return RegExp(r'^[6-9]').hasMatch(digits)
        ? null
        : 'Indian mobile numbers start with 6, 7, 8 or 9';
  }

  static String? otp(String v) =>
      RegExp(r'^\d{6}$').hasMatch(v) ? null : 'Enter the 6-digit code';
}

/// B-24: keeps the national 10 digits of an Indian mobile number however it
/// arrives: typed, pasted or autofilled as "+91 98711 25588" or
/// "098711 25588". Drops a leading 91 or 0 only when there are too many
/// digits for a national number, then caps at 10.
class IndianMobileFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var d = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (d.length > 10 && d.startsWith('91')) d = d.substring(2);
    if (d.length > 10 && d.startsWith('0')) d = d.substring(1);
    if (d.length > 10) d = d.substring(0, 10);
    return TextEditingValue(
      text: d,
      selection: TextSelection.collapsed(offset: d.length),
    );
  }
}
