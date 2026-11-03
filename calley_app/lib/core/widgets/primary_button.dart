import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// The one solid call-to-action per screen: a pill with a hard 3 px edge
/// underneath that presses flat on tap. Shows its own spinner while `busy`
/// and refuses taps meanwhile, so a request cannot be sent twice.
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.busy = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final IconData? icon;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final enabled = !widget.busy && widget.onPressed != null;
    const edge = 3.0;
    final lift = enabled && !_down ? edge : 0.0;
    final bg = enabled ? c.primary : c.skeleton;
    final fg = enabled ? c.onPrimary : c.textMuted;

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.busy ? '${widget.label}, please wait' : widget.label,
      child: ExcludeSemantics(
        child: GestureDetector(
          onTapDown: enabled ? (_) => setState(() => _down = true) : null,
          onTapUp: enabled ? (_) => setState(() => _down = false) : null,
          onTapCancel: enabled ? () => setState(() => _down = false) : null,
          onTap: enabled ? widget.onPressed : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 70),
            height: Dims.buttonHeight + edge,
            padding: EdgeInsets.only(bottom: edge - lift, top: edge - lift),
            child: Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  if (enabled)
                    BoxShadow(color: c.primaryDeep, offset: Offset(0, lift)),
                ],
              ),
              alignment: Alignment.center,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                child: widget.busy
                    ? SizedBox(
                        key: const ValueKey('busy'),
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: fg,
                        ),
                      )
                    : Row(
                        key: const ValueKey('label'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, size: 20, color: fg),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.label,
                            style: context.body(
                              15.5,
                              weight: FontWeight.w600,
                              color: fg,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Round WhatsApp button beside the main action (Figma 05/06).
class WhatsAppButton extends StatelessWidget {
  const WhatsAppButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(
      button: true,
      label: 'Chat on WhatsApp',
      child: Material(
        color: c.card,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            height: Dims.buttonHeight + 3,
            width: Dims.buttonHeight + 3,
            child: Icon(Icons.chat_rounded, color: c.whatsapp, size: 26),
          ),
        ),
      ),
    );
  }
}
