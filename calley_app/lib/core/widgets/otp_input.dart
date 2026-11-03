import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';

/// Six boxes that behave like one field: typing advances, backspace retreats,
/// a pasted 6-digit code fills all boxes. The value is reported whole.
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
  late final List<TextEditingController> _ctrls = List.generate(
    widget.length,
    (_) => TextEditingController(),
  );
  late final List<FocusNode> _nodes = List.generate(
    widget.length,
    (_) => FocusNode(),
  );

  String get value => _ctrls.map((c) => c.text).join();

  void clear() {
    for (final c in _ctrls) {
      c.clear();
    }
    _nodes.first.requestFocus();
    widget.onChanged('');
  }

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _onChanged(int i, String text) {
    final digits = text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 1) {
      // Paste: spread the digits from this box onwards.
      for (var k = 0; k < digits.length && i + k < widget.length; k++) {
        _ctrls[i + k].text = digits[k];
      }
      final next = (i + digits.length).clamp(0, widget.length - 1);
      _nodes[next].requestFocus();
    } else {
      _ctrls[i].text = digits;
      if (digits.isNotEmpty && i < widget.length - 1) {
        _nodes[i + 1].requestFocus();
      }
    }
    final v = value;
    widget.onChanged(v);
    if (v.length == widget.length) {
      FocusScope.of(context).unfocus();
      widget.onCompleted?.call(v);
    }
  }

  KeyEventResult _onKey(int i, FocusNode node, KeyEvent e) {
    if (e is KeyDownEvent &&
        e.logicalKey == LogicalKeyboardKey.backspace &&
        _ctrls[i].text.isEmpty &&
        i > 0) {
      _ctrls[i - 1].clear();
      _nodes[i - 1].requestFocus();
      widget.onChanged(value);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'One-time code, ${widget.length} digits',
      child: Row(
        children: [
          for (var i = 0; i < widget.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 58,
                child: Focus(
                  onKeyEvent: (node, e) => _onKey(i, node, e),
                  child: TextField(
                    controller: _ctrls[i],
                    focusNode: _nodes[i],
                    enabled: widget.enabled,
                    autofocus: i == 0,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    textInputAction: i == widget.length - 1
                        ? TextInputAction.done
                        : TextInputAction.next,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: context.mono(22, weight: FontWeight.w600),
                    onChanged: (t) => _onChanged(i, t),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
