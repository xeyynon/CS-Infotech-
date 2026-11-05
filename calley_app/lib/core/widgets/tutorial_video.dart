import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../app/theme.dart';
import '../utils/launchers.dart';
import 'cards.dart';

/// Builds the in-app player for a YouTube video id. Behind a provider because
/// a web view cannot run under `flutter test`; tests swap in a plain box.
typedef PlayerBuilder = Widget Function(BuildContext context, String videoId);

final playerBuilderProvider = Provider<PlayerBuilder>(
  (ref) =>
      (context, videoId) => _YoutubeEmbed(videoId: videoId),
);

/// The "2 Minute Challenge" card on Getting Started.
///
/// A poster with two ways to watch: **Play here** swaps the poster for the
/// player inside the card (no navigation, so the "Start Calling Now" button
/// stays where it is), and **Open in YouTube** hands the video to the
/// YouTube app or the browser. The play disc on the poster plays in the app
/// too, so the obvious tap does the obvious thing.
class TutorialVideoCard extends ConsumerStatefulWidget {
  const TutorialVideoCard({super.key});

  @override
  ConsumerState<TutorialVideoCard> createState() => _TutorialVideoCardState();
}

class _TutorialVideoCardState extends ConsumerState<TutorialVideoCard> {
  bool _playing = false;

  void _toggle() => setState(() => _playing = !_playing);

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedSwitcher(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 180),
            child: _playing
                ? ref.watch(playerBuilderProvider)(
                    context,
                    Links.tutorialVideoId,
                  )
                : _Poster(onPlay: _toggle),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: FilledButton.tonalIcon(
                    onPressed: _toggle,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, Dims.tap),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      textStyle: context.body(14, weight: FontWeight.w600),
                      backgroundColor: c.primary.withValues(alpha: 0.12),
                      foregroundColor: c.primary,
                    ),
                    icon: Icon(
                      _playing
                          ? Icons.close_rounded
                          : Icons.play_circle_outline_rounded,
                      size: 20,
                    ),
                    label: Text(_playing ? 'Hide video' : 'Play here'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: OutlinedButton.icon(
                    onPressed: () => ref
                        .read(launcherProvider)
                        .open(context, Links.tutorialVideo),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, Dims.tap),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      textStyle: context.body(14, weight: FontWeight.w600),
                      foregroundColor: c.text,
                      side: BorderSide(color: c.border),
                    ),
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: const Text('Open in YouTube'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A poster drawn in the display face. It is at least as tall as a 16:9
/// player, so the card does not jump much when the video starts.
class _Poster extends StatelessWidget {
  const _Poster({required this.onPlay});

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(
      button: true,
      label: 'Play the 2 minute challenge video here',
      excludeSemantics: true,
      onTap: onPlay,
      child: InkWell(
        onTap: onPlay,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 190),
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          color: c.cardAlt,
          child: Column(
            children: [
              Text('TUTORIAL · 5:13', style: context.eyebrow()),
              const SizedBox(height: 10),
              Text(
                '2 Minute Challenge',
                textAlign: TextAlign.center,
                style: context.display(28, weight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Upload a list, sync, dial. Watch how.',
                textAlign: TextAlign.center,
                style: context.body(13.5, color: c.textSecondary),
              ),
              const SizedBox(height: 16),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: c.card,
                  shape: BoxShape.circle,
                  border: Border.all(color: c.border, width: 1.5),
                ),
                child: Icon(Icons.play_arrow_rounded, color: c.text, size: 30),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The real player: YouTube's embedded iframe in a web view. It starts at
/// once (the person just asked for it) and is closed with the card.
class _YoutubeEmbed extends StatefulWidget {
  const _YoutubeEmbed({required this.videoId});

  final String videoId;

  @override
  State<_YoutubeEmbed> createState() => _YoutubeEmbedState();
}

class _YoutubeEmbedState extends State<_YoutubeEmbed> {
  late final YoutubePlayerController _controller =
      YoutubePlayerController.fromVideoId(
        videoId: widget.videoId,
        autoPlay: true,
        params: const YoutubePlayerParams(
          showFullscreenButton: true,
          strictRelatedVideos: true,
        ),
      );

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Tutorial video player',
      container: true,
      child: YoutubePlayer(controller: _controller, aspectRatio: 16 / 9),
    );
  }
}
