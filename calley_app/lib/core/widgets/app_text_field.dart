import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';

/// Filled field with a trailing icon. The fill is the edge; a border appears
/// only on focus or error.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.hint,
    this.controller,
    this.icon,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.validator,
    this.autofillHints,
    this.inputFormatters,
    this.maxLength,
    this.onSubmitted,
    this.autofocus = false,
    this.enabled = true,
    this.prefix,
    this.mono = false,
    this.textCapitalization = TextCapitalization.none,
  });

  final String hint;
  final TextEditingController? controller;
  final IconData? icon;
  final Widget? suffix;
  final Widget? prefix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final bool enabled;

  /// Numbers (phone, OTP) are set in the mono face.
  final bool mono;

  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      validator: validator,
      autofillHints: autofillHints,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      onFieldSubmitted: onSubmitted,
      autofocus: autofocus,
      enabled: enabled,
      textCapitalization: textCapitalization,
      autocorrect: keyboardType != TextInputType.emailAddress,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: mono ? context.mono(15.5) : context.body(15.5),
      decoration: InputDecoration(
        hintText: hint,
        counterText: '',
        prefixIcon: prefix,
        suffixIcon:
            suffix ??
            (icon == null ? null : Icon(icon, size: 20, color: c.textMuted)),
      ),
    );
  }
}

/// Password field with its own show/hide toggle.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    this.hint = 'Password',
    this.textInputAction,
    this.onSubmitted,
    this.validator,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final Iterable<String>? autofillHints;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return AppTextField(
      controller: widget.controller,
      hint: widget.hint,
      obscureText: _hidden,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      validator: widget.validator,
      autofillHints: widget.autofillHints,
      suffix: IconButton(
        tooltip: _hidden ? 'Show password' : 'Hide password',
        onPressed: () => setState(() => _hidden = !_hidden),
        icon: Icon(
          _hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 20,
          color: c.textMuted,
        ),
      ),
    );
  }
}
