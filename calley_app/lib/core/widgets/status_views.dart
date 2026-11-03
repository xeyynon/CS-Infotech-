import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../network/api_client.dart';
import '../providers.dart';
import 'cards.dart';

/// Loading is not "nothing here": a block the shape of what will arrive.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    this.height = 16,
    this.width,
    this.radius = 10,
  });

  final double height;
  final double? width;
  final double radius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !MediaQuery.disableAnimationsOf(context)) {
        _c.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) => Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: c.skeleton.withValues(alpha: 0.6 + 0.4 * _c.value),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

/// Something the server could not give us. Says what happened, offers Retry,
/// and (only when talking to the real server) offers labelled sample data.
class ErrorView extends ConsumerWidget {
  const ErrorView({
    super.key,
    required this.error,
    this.onRetry,
    this.compact = false,
  });

  final Object error;
  final VoidCallback? onRetry;
  final bool compact;

  static String messageOf(Object e) =>
      e is ApiException ? e.message : 'Something went wrong.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final remote = ref.watch(dataSourceProvider) == DataSource.remote;
    final msg = messageOf(error);
    final isServerDown =
        error is ApiException &&
        (error as ApiException).kind != ApiErrorKind.badRequest &&
        (error as ApiException).kind != ApiErrorKind.unauthorized;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: c.danger.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.cloud_off_rounded, color: c.danger, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isServerDown
                          ? 'The Calley server did not answer'
                          : 'Request refused',
                      style: context.display(17, weight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      msg,
                      style: context.body(13.5, color: c.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!compact) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (onRetry != null)
                  OutlinedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Retry'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                if (remote && isServerDown)
                  FilledButton.tonalIcon(
                    onPressed: () => ref
                        .read(dataSourceProvider.notifier)
                        .set(DataSource.sample),
                    icon: const Icon(Icons.dataset_outlined, size: 18),
                    label: const Text('Use sample data'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      backgroundColor: c.cardAlt,
                      foregroundColor: c.text,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// "Ran and found nothing" — neutral, not an error.
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.icon,
    required this.title,
    this.body,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: c.cardAlt,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: c.textSecondary, size: 28),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.display(18, weight: FontWeight.w700),
            ),
            if (body != null) ...[
              const SizedBox(height: 6),
              Text(
                body!,
                textAlign: TextAlign.center,
                style: context.body(13.5, color: c.textSecondary),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}

/// Shown on every data screen while sample data is active, so nobody
/// mistakes the bundled JSON for a live server.
class SampleDataBanner extends ConsumerWidget {
  const SampleDataBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    if (ref.watch(dataSourceProvider) != DataSource.sample) {
      return const SizedBox.shrink();
    }
    return Material(
      color: c.pending.withValues(alpha: 0.18),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 10, 8),
        child: Row(
          children: [
            Icon(Icons.dataset_outlined, size: 18, color: c.text),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                kForceMock
                    ? 'Sample data (USE_MOCK build)'
                    : 'Sample data — the Calley server could not be reached',
                style: context.body(12.5, weight: FontWeight.w600),
              ),
            ),
            if (!kForceMock)
              TextButton(
                onPressed: () => ref
                    .read(dataSourceProvider.notifier)
                    .set(DataSource.remote),
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  foregroundColor: c.text,
                ),
                child: const Text('Try server'),
              ),
          ],
        ),
      ),
    );
  }
}
