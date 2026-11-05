import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/providers.dart';
import '../core/storage/session_store.dart';
import '../core/widgets/calley_loader.dart';
import 'app.dart';
import 'theme.dart';

/// What the app does between "the process started" and "the first screen":
/// read the saved preferences. Instead of Flutter's blank white start-up,
/// the Calley loading animation plays on the page colour while that happens.
///
/// The splash stays for at least [minimumShow] so the animation is seen as a
/// moment and not a flicker, and it is skipped when the phone is set to
/// remove animations. [load] is a parameter so a test can hand in its own.
class Bootstrap extends StatefulWidget {
  const Bootstrap({
    super.key,
    this.load = SharedPreferences.getInstance,
    this.minimumShow = const Duration(milliseconds: 900),
  });

  final Future<SharedPreferences> Function() load;
  final Duration minimumShow;

  @override
  State<Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<Bootstrap> {
  SharedPreferences? _prefs;
  Object? _error;
  bool _waited = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final started = DateTime.now();
    try {
      final prefs = await widget.load();
      if (!mounted) return;
      // Whoever asked for no animation does not wait for one.
      final still = MediaQueryData.fromView(View.of(context)).disableAnimations;
      final left = widget.minimumShow - DateTime.now().difference(started);
      if (!still && left > Duration.zero) await Future<void>.delayed(left);
      if (!mounted) return;
      setState(() {
        _prefs = prefs;
        _waited = true;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = _prefs;
    if (prefs != null && _waited) {
      return ProviderScope(
        overrides: [
          sessionStoreProvider.overrideWithValue(SessionStore(prefs)),
        ],
        // No automatic retry: a failed request shows its error at once with
        // a Retry button, instead of skeletons while Riverpod backs off.
        retry: (_, _) => null,
        child: const CalleyApp(),
      );
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      home: _Splash(failed: _error != null),
    );
  }
}

/// The loading animation, centred on the page colour. If the saved
/// preferences cannot be read the person is told so in plain words rather
/// than left watching the animation forever.
class _Splash extends StatelessWidget {
  const _Splash({required this.failed});

  final bool failed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: failed
            ? Padding(
                padding: const EdgeInsets.all(Dims.page * 1.5),
                child: Text(
                  'Calley could not start. Close the app and open it again.',
                  textAlign: TextAlign.center,
                  style: context.body(15),
                ),
              )
            : const CalleyLoader(size: 150),
      ),
    );
  }
}
