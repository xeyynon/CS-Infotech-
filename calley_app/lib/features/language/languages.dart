/// The nine languages on the first screen, in Figma order, with the native
/// greeting shown under each name.
class AppLanguage {
  const AppLanguage(this.code, this.name, this.greeting);

  final String code;
  final String name;
  final String greeting;
}

const List<AppLanguage> kLanguages = [
  AppLanguage('en', 'English', 'Hi'),
  AppLanguage('hi', 'Hindi', 'नमस्ते'),
  AppLanguage('bn', 'Bengali', 'হ্যালো'),
  AppLanguage('kn', 'Kannada', 'ನಮಸ್ಕಾರ'),
  AppLanguage('pa', 'Punjabi', 'ਸਤ ਸ੍ਰੀ ਅਕਾਲ'),
  AppLanguage('ta', 'Tamil', 'வணக்கம்'),
  AppLanguage('te', 'Telugu', 'హలో'),
  AppLanguage('fr', 'French', 'Bonjour'),
  AppLanguage('es', 'Spanish', 'Hola'),
];

AppLanguage languageFor(String? code) => kLanguages.firstWhere(
  (l) => l.code == code,
  orElse: () => kLanguages.first,
);
