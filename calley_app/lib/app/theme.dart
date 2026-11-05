import 'package:flutter/material.dart';

/// Every colour the app paints comes from here. Light and dark define the
/// SAME token names, so a widget never changes between themes.
///
/// The palette keeps Calley's blue and navy from the Figma file and sets them
/// on warm paper instead of blue-grey, so the brand colour is the only cool
/// thing on the page.
@immutable
class CalleyColors extends ThemeExtension<CalleyColors> {
  const CalleyColors({
    required this.primary,
    required this.primaryDeep,
    required this.onPrimary,
    required this.primarySoft,
    required this.navy,
    required this.onNavy,
    required this.bg,
    required this.card,
    required this.cardAlt,
    required this.input,
    required this.border,
    required this.text,
    required this.textSecondary,
    required this.textMuted,
    required this.pending,
    required this.done,
    required this.scheduled,
    required this.danger,
    required this.success,
    required this.whatsapp,
    required this.skeleton,
  });

  /// Brand blue: the one call to action per screen, links, the Done segment.
  final Color primary;

  /// The pressed edge under the primary button.
  final Color primaryDeep;
  final Color onPrimary;

  /// Tint for selected rows and chips.
  final Color primarySoft;

  /// Dark navy section headers ("LOAD NUMBER TO CALL").
  final Color navy;
  final Color onNavy;
  final Color bg;
  final Color card;

  /// Deeper surface for things that sit on a card (inputs, nested rows).
  final Color cardAlt;
  final Color input;

  /// Hairlines only: dividers, outlined controls. Cards carry no border.
  final Color border;
  final Color text;
  final Color textSecondary;
  final Color textMuted;

  /// Call-status colours. A status is always a word with a dot, never a colour alone.
  final Color pending;
  final Color done;
  final Color scheduled;
  final Color danger;
  final Color success;
  final Color whatsapp;
  final Color skeleton;

  static const light = CalleyColors(
    primary: Color(0xFF1F5EFF),
    primaryDeep: Color(0xFF1546C9),
    onPrimary: Colors.white,
    primarySoft: Color(0xFFE7EEFF),
    navy: Color(0xFF0E1B3D),
    onNavy: Colors.white,
    bg: Color(0xFFF6F5F1),
    card: Colors.white,
    cardAlt: Color(0xFFF1F0EB),
    input: Color(0xFFEFEEE9),
    border: Color(0xFFE6E4DD),
    text: Color(0xFF15161A),
    textSecondary: Color(0xFF4D505A),
    textMuted: Color(0xFF656975), // B-11: 4.9:1 on input, 5.3:1 on paper
    pending: Color(0xFFF0B429),
    done: Color(0xFF1F5EFF),
    scheduled: Color(0xFF8B5CF6),
    danger: Color(0xFFC0302F), // B-11: 5.0:1 on white
    success: Color(0xFF167A47), // B-11: 5.1:1 on white
    whatsapp: Color(0xFF25D366),
    skeleton: Color(0xFFE8E6E0),
  );

  static const dark = CalleyColors(
    primary: Color(0xFF6B93FF),
    primaryDeep: Color(0xFF3A66E0),
    onPrimary: Color(0xFF0B1220),
    primarySoft: Color(0xFF1C2742),
    navy: Color(0xFF182650),
    onNavy: Color(0xFFF2F4F8),
    bg: Color(0xFF0E0F12),
    card: Color(0xFF17191E),
    cardAlt: Color(0xFF1E2127),
    input: Color(0xFF1B1E24),
    border: Color(0xFF2A2E36),
    text: Color(0xFFF2F2F0),
    textSecondary: Color(0xFFB5B8C0),
    textMuted: Color(0xFF8D919C), // B-11: 5.3:1 on card
    pending: Color(0xFFF5C04A),
    done: Color(0xFF6B93FF),
    scheduled: Color(0xFFA78BFA),
    danger: Color(0xFFF26B6B),
    success: Color(0xFF3DCB7E),
    whatsapp: Color(0xFF25D366),
    skeleton: Color(0xFF22252C),
  );

  @override
  CalleyColors copyWith() => this;

  @override
  CalleyColors lerp(ThemeExtension<CalleyColors>? other, double t) {
    if (other is! CalleyColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return CalleyColors(
      primary: l(primary, other.primary),
      primaryDeep: l(primaryDeep, other.primaryDeep),
      onPrimary: l(onPrimary, other.onPrimary),
      primarySoft: l(primarySoft, other.primarySoft),
      navy: l(navy, other.navy),
      onNavy: l(onNavy, other.onNavy),
      bg: l(bg, other.bg),
      card: l(card, other.card),
      cardAlt: l(cardAlt, other.cardAlt),
      input: l(input, other.input),
      border: l(border, other.border),
      text: l(text, other.text),
      textSecondary: l(textSecondary, other.textSecondary),
      textMuted: l(textMuted, other.textMuted),
      pending: l(pending, other.pending),
      done: l(done, other.done),
      scheduled: l(scheduled, other.scheduled),
      danger: l(danger, other.danger),
      success: l(success, other.success),
      whatsapp: l(whatsapp, other.whatsapp),
      skeleton: l(skeleton, other.skeleton),
    );
  }
}

/// Three families, each with one job. All bundled in assets/fonts (OFL).
abstract final class Fonts {
  /// Body copy, labels, buttons.
  static const body = 'Inter';

  /// Headings and the one big number on a screen.
  static const display = 'BricolageGrotesque';

  /// Every figure: counts, phone numbers, times. Tabular, so columns align.
  static const mono = 'IBMPlexMono';
}

/// Shape and spacing tokens.
abstract final class Dims {
  static const double page = 20;
  static const double gap = 12;
  static const double cardRadius = 20;
  static const double fieldRadius = 14;
  static const double buttonHeight = 52;

  /// Minimum hit target (WCAG 2.5.5 / Material).
  static const double tap = 48;
}

extension CalleyThemeX on BuildContext {
  CalleyColors get c => Theme.of(this).extension<CalleyColors>()!;

  /// Display face for headings and hero numbers.
  TextStyle display(
    double size, {
    FontWeight weight = FontWeight.w700,
    Color? color,
    double height = 1.05,
    double letterSpacing = -0.3,
  }) => TextStyle(
    fontFamily: Fonts.display,
    fontSize: size,
    fontWeight: weight,
    color: color ?? c.text,
    height: height,
    letterSpacing: letterSpacing,
  );

  /// Monospace figures with tabular numerals.
  TextStyle mono(
    double size, {
    FontWeight weight = FontWeight.w500,
    Color? color,
    double height = 1.1,
  }) => TextStyle(
    fontFamily: Fonts.mono,
    fontSize: size,
    fontWeight: weight,
    color: color ?? c.text,
    height: height,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  /// Small uppercase tracked label above a value ("ACTIVE LIST").
  TextStyle eyebrow({Color? color}) => TextStyle(
    fontFamily: Fonts.mono,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.4,
    color: color ?? c.textMuted,
    height: 1.2,
  );

  TextStyle body(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color? color,
    double height = 1.4,
  }) => TextStyle(
    fontFamily: Fonts.body,
    fontSize: size,
    fontWeight: weight,
    color: color ?? c.text,
    height: height,
  );
}

ThemeData buildTheme(Brightness brightness) {
  final c = brightness == Brightness.dark
      ? CalleyColors.dark
      : CalleyColors.light;
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    fontFamily: Fonts.body,
    // Scripts on the language screen. On a device the system supplies these;
    // the snapshot tests load Noto under the same names.
    fontFamilyFallback: const [
      'NotoSansDevanagari',
      'NotoSansBengali',
      'NotoSansKannada',
      'NotoSansGurmukhi',
      'NotoSansTamil',
      'NotoSansTelugu',
    ],
    colorScheme: ColorScheme.fromSeed(
      seedColor: c.primary,
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.onPrimary,
      surface: c.card,
      onSurface: c.text,
      error: c.danger,
    ),
    scaffoldBackgroundColor: c.bg,
  );
  final text = base.textTheme.apply(bodyColor: c.text, displayColor: c.text);
  OutlineInputBorder border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dims.fieldRadius),
        borderSide: BorderSide(color: color, width: width),
      );
  return base.copyWith(
    textTheme: text,
    extensions: [c],
    appBarTheme: AppBarTheme(
      backgroundColor: c.bg,
      foregroundColor: c.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: Fonts.display,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: c.text,
        letterSpacing: -0.3,
      ),
    ),
    cardTheme: CardThemeData(
      color: c.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dims.cardRadius),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.input,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: text.bodyMedium?.copyWith(color: c.textMuted),
      border: border(Colors.transparent),
      enabledBorder: border(Colors.transparent),
      focusedBorder: border(c.primary, 1.6),
      errorBorder: border(c.danger),
      focusedErrorBorder: border(c.danger, 1.6),
      disabledBorder: border(Colors.transparent),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        minimumSize: const Size.fromHeight(Dims.buttonHeight),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(
          fontFamily: Fonts.body,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: c.text,
        minimumSize: const Size.fromHeight(Dims.buttonHeight),
        side: BorderSide(color: c.border),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(
          fontFamily: Fonts.body,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: c.primary,
        minimumSize: const Size(Dims.tap, Dims.tap),
        textStyle: const TextStyle(
          fontFamily: Fonts.body,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: c.navy,
      contentTextStyle: text.bodyMedium?.copyWith(color: c.onNavy),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    dividerTheme: DividerThemeData(color: c.border, space: 1, thickness: 1),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      titleTextStyle: TextStyle(
        fontFamily: Fonts.display,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: c.text,
      ),
      contentTextStyle: text.bodyMedium?.copyWith(color: c.textSecondary),
    ),
    checkboxTheme: CheckboxThemeData(
      side: BorderSide(color: c.textMuted, width: 1.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? c.primary : c.textMuted,
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: c.textSecondary,
      textColor: c.text,
    ),
    drawerTheme: DrawerThemeData(backgroundColor: c.card),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
      },
    ),
  );
}
