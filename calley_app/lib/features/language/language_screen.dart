import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/providers.dart';
import '../../core/widgets/calley_logo.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/primary_button.dart';
import 'languages.dart';

/// Figma 01. Also reached from Settings → App Language, in which case it
/// pops back instead of moving on to Register.
class LanguageScreen extends ConsumerStatefulWidget {
  const LanguageScreen({super.key});

  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen> {
  late String _code = ref.read(languageProvider) ?? kLanguages.first.code;

  Future<void> _select() async {
    await ref.read(languageProvider.notifier).set(_code);
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.register);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final changing = context.canPop();
    return Scaffold(
      appBar: changing ? AppBar(title: const Text('App language')) : null,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                Dims.page,
                changing ? 4 : 20,
                Dims.page,
                14,
              ),
              // Centred heading block, as in Figma 01; the list below stays
              // left-aligned for scanning.
              child: Column(
                children: [
                  if (!changing) ...[
                    const CalleyLogo(size: 40),
                    const SizedBox(height: 28),
                    Semantics(
                      header: true,
                      child: Text(
                        'Choose Your Language', // B-43: Figma wording
                        textAlign: TextAlign.center,
                        style: context.display(30, weight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    changing
                        ? 'Pick the language the app should use.'
                        : 'You can change this later in Settings.',
                    textAlign: TextAlign.center,
                    style: context.body(14, color: c.textSecondary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: Dims.page),
                child: AppCard(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: RadioGroup<String>(
                    groupValue: _code,
                    onChanged: (v) => setState(() => _code = v ?? _code),
                    child: Column(
                      children: [
                        for (var i = 0; i < kLanguages.length; i++) ...[
                          if (i > 0) const Divider(indent: 18, endIndent: 18),
                          _LanguageRow(
                            language: kLanguages[i],
                            selected: kLanguages[i].code == _code,
                            onTap: () =>
                                setState(() => _code = kLanguages[i].code),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(Dims.page, 12, Dims.page, 16),
              child: PrimaryButton(
                label: changing ? 'Save' : 'Select', // B-43
                onPressed: _select,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  final AppLanguage language;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    // B-42: one node per row, read once, with its own tap.
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      label: '${language.name}, ${language.greeting}',
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 10, 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.name,
                      style: context.body(15, weight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      language.greeting,
                      style: context.body(13, color: c.textMuted),
                    ),
                  ],
                ),
              ),
              ExcludeSemantics(child: Radio<String>(value: language.code)),
            ],
          ),
        ),
      ),
    );
  }
}
