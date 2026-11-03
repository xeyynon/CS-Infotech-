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

  static String? mobile(String? v) {
    final r = required(v, 'Mobile number');
    if (r != null) return r;
    final digits = v!.replaceAll(RegExp(r'\D'), '');
    return digits.length == 10 ? null : 'Enter a 10-digit mobile number';
  }

  static String? otp(String v) =>
      RegExp(r'^\d{6}$').hasMatch(v) ? null : 'Enter the 6-digit code';
}
