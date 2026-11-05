import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Links the design points at. Kept in one place.
abstract final class Links {
  /// Shown in the copy as app.getcalley.com, as in the Figma file.
  static const webPanel = 'https://app.getcalley.com';

  /// Calley's support WhatsApp, as published on csquaretech.com.
  static const whatsapp = 'https://wa.me/919971125511';

  /// Calley's own "Full setup of Calley Personal" tutorial.
  static const tutorialVideo = 'https://www.youtube.com/watch?v=hzwSizmvMD0';

  // Real pages on getcalley.com (checked 2026-11-05).
  static const terms = 'https://www.getcalley.com/terms-of-services/';
  static const privacy = 'https://www.getcalley.com/privacy-policy/';
  static const about =
      'https://www.getcalley.com/what-is-calley-sales-auto-dialer/';
  static const support = 'https://www.getcalley.com/contact-us/';
  static const download =
      'https://www.getcalley.com/download-sales-call-auto-dialer/';
}

typedef LaunchFn = Future<bool> Function(Uri uri, {LaunchMode mode});

/// Opens things outside the app. Behind a provider so tests can swap the
/// platform call for a stub.
class Launcher {
  const Launcher([this._launch = launchUrl]);

  final LaunchFn _launch;

  /// Opens a URL in the matching external app. Tells the user when nothing
  /// can open it instead of failing silently.
  Future<void> open(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final ok = await _safe(uri, LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Nothing on this device can open ${uri.host.isEmpty ? url : uri.host}.',
          ),
        ),
      );
    }
  }

  /// Opens the phone dialer with the number filled in. Does not place the
  /// call itself: that needs CALL_PHONE permission and the user's consent.
  /// Returns whether the dialer opened, so callers do not ask "how did the
  /// call go?" about a call that never started (B-27).
  Future<bool> dial(BuildContext context, String phone) async {
    final digits = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (digits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number on this record.')),
      );
      return false;
    }
    final ok = await _safe(
      Uri(scheme: 'tel', path: digits),
      LaunchMode.platformDefault,
    );
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This device has no phone dialer.')),
      );
    }
    return ok;
  }

  /// `launchUrl` throws on platforms with no url_launcher implementation.
  /// Treat that the same as "could not open".
  Future<bool> _safe(Uri uri, LaunchMode mode) async {
    try {
      return await _launch(uri, mode: mode);
    } on Exception {
      return false;
    } on Error {
      return false;
    }
  }
}

final launcherProvider = Provider<Launcher>((_) => const Launcher());
