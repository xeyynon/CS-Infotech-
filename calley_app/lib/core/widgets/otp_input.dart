import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';

/// Six boxes drawn over ONE real text field (B-03, B-04, B-16).
///
/// A single field means typing, backspace on any soft keyboard, paste and
/// SMS/one-time-code autofill all behave the way the platform already does,
/// and assistive tech meets one labelled input instead of six blank ones.
/// Tapping any box focuses the field.
class OtpInput extends StatefulWidget {
  const OtpInput({
    super.key,
    required this.onChanged,
    this.onCompleted,
    this.length = 6,
    this.enabled = true,
  });

  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCompleted;
  final int length;
  final bool enabled;

  @override
  State<OtpInput> createState() => OtpInputState();
}

class OtpInputState extends State<OtpInput> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  String _last = '';

  String get value => _ctrl.text;

  void clear() {
    _ctrl.clear();
    _focus.requestFocus();
  }

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onText);
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onText() {
    final v = _ctrl.text;
    if (v == _last) return;
    _last = v;
    setState(() {});
    widget.onChanged(v);
    if (v.length == widget.length) {
      _focus.unfocus();
      widget.onCompleted?.call(v);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final v = _ctrl.text;
    final focused = _focus.hasFocus;
    // The box that the next digit goes into.
    final active = v.length.clamp(0, widget.length - 1);

    return Stack(
      children: [
        // The real field: present for input and assistive tech, invisible.
        Positioned.fill(
          child: Opacity(
            opacity: 0,
            // Without this, Opacity(0) drops the field from the semantics tree.
            alwaysIncludeSemantics: true,
            child: TextField(
              controller: _ctrl,
              focusNode: _focus,
              enabled: widget.enabled,
              autofocus: true,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.oneTimeCode],
              maxLength: widget.length,
              showCursor: false,
              enableInteractiveSelection: false,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(widget.length),
              ],
              decoration: InputDecoration(
                counterText: '',
                labelText: 'One-time code, ${widget.length} digits',
              ),
            ),
          ),
        ),
        // The drawn boxes. Hidden from assistive tech: the field above
        // already says what it is and what has been typed.
        ExcludeSemantics(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.enabled ? () => _focus.requestFocus() : null,
            child: Row(
              children: [
                for (var i = 0; i < widget.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      height: 58,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: c.input,
                        borderRadius: BorderRadius.circular(Dims.fieldRadius),
                        border: Border.all(
                          color:
                              focused && i == active && v.length < widget.length
                              ? c.primary
                              : Colors.transparent,
                          width: 1.6,
                        ),
                      ),
                      child: Text(
                        i < v.length ? v[i] : '',
                        style: context.mono(22, weight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
