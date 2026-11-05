import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../app/theme.dart';

/// The branded wait: the Calley "C" inside a turning arc (Lottie, from
/// `calley_loading_assets/`, with the logo's white background made
/// transparent so it also sits on the dark theme).
///
/// Use it for a WHOLE-SCREEN or whole-section wait (a list loading, a queue
/// loading). Small inline placeholders keep using [SkeletonBox], and a button
/// that is busy keeps its own spinner: one loader per wait, sized to the wait.
///
/// With the device's "remove animations" setting on it holds a still frame
/// instead of turning. It is announced to screen readers as a live region.
class CalleyLoader extends StatelessWidget {
  const CalleyLoader({super.key, this.label, this.size = 104});

  /// What is loading, in the user's words ("Loading your list…").
  final String? label;
  final double size;

  static const asset = 'assets/loading/calley_loading_animation.json';

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final still = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      liveRegion: true,
      container: true,
      label: label ?? 'Loading',
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              asset,
              width: size,
              height: size,
              fit: BoxFit.contain,
              animate: !still,
              repeat: true,
              // If the animation cannot be read, a plain spinner still says
              // "working" rather than leaving an empty screen.
              errorBuilder: (_, _, _) => SizedBox(
                width: size,
                height: size,
                child: Center(
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: c.primary,
                    ),
                  ),
                ),
              ),
            ),
            if (label != null) ...[
              const SizedBox(height: 4),
              Text(
                label!,
                textAlign: TextAlign.center,
                style: context.body(13.5, color: c.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A loader centred in the space it is given, with a floor on the height so
/// the screen does not jump when the content arrives.
class CalleyLoaderBlock extends StatelessWidget {
  const CalleyLoaderBlock({super.key, this.label, this.minHeight = 320});

  final String? label;
  final double minHeight;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(minHeight: minHeight),
    child: Center(child: CalleyLoader(label: label)),
  );
}
