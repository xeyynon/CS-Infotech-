import 'package:flutter/material.dart';

/// The official Calley logo, from getcalley.com (wp-content/uploads/2022/08/
/// logo_calley.webp), with its white background made transparent. A second
/// copy has the grey "AUTOMATIC CALL DIALER" tagline lightened so it reads on
/// the dark theme. The colourful "C" is unchanged in both.
///
/// [size] is the height of the artwork in logical pixels.
class CalleyLogo extends StatelessWidget {
  const CalleyLogo({super.key, this.size = 44, this.showText = true});

  final double size;

  /// false shows only the "C" mark.
  final bool showText;

  static const _logo = 'assets/brand/calley_logo.png';
  static const _logoDark = 'assets/brand/calley_logo_dark.png';
  static const _mark = 'assets/brand/calley_mark.png';

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final asset = !showText ? _mark : (dark ? _logoDark : _logo);
    return Semantics(
      label: 'Calley, automatic call dialer',
      image: true,
      child: ExcludeSemantics(
        child: Image.asset(
          asset,
          height: size,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}
