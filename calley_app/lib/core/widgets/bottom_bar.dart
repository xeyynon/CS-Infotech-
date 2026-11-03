import 'package:flutter/material.dart';

import '../../app/theme.dart';

enum BottomTab { home, contacts, play, phone, calendar }

/// Five slots from Figma 06/08: home, contacts, a raised play button in the
/// centre, phone, calendar. Every slot is labelled for assistive tech and
/// has a 48 px hit target.
class CalleyBottomBar extends StatelessWidget {
  const CalleyBottomBar({
    super.key,
    required this.current,
    required this.onTap,
  });

  final BottomTab current;
  final ValueChanged<BottomTab> onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    Widget slot(
      BottomTab tab,
      IconData icon,
      IconData selectedIcon,
      String label,
    ) {
      final selected = tab == current;
      return Expanded(
        child: Semantics(
          button: true,
          selected: selected,
          label: label,
          child: InkWell(
            onTap: () => onTap(tab),
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 56,
              child: Icon(
                selected ? selectedIcon : icon,
                size: 24,
                color: selected ? c.text : c.textMuted,
              ),
            ),
          ),
        ),
      );
    }

    return Material(
      color: c.card,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
          child: Row(
            children: [
              slot(
                BottomTab.home,
                Icons.home_outlined,
                Icons.home_rounded,
                'Dashboard',
              ),
              slot(
                BottomTab.contacts,
                Icons.contact_page_outlined,
                Icons.contact_page_rounded,
                'Calling queue',
              ),
              // Fixed height: a bare Center would take every pixel the
              // Scaffold offers and starve the body.
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: Center(
                    child: Semantics(
                      button: true,
                      label: 'Start calling',
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: c.primaryDeep,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Material(
                          color: c.primary,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => onTap(BottomTab.play),
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: Icon(
                                Icons.play_arrow_rounded,
                                color: c.onPrimary,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              slot(
                BottomTab.phone,
                Icons.phone_outlined,
                Icons.phone_rounded,
                'Dial next pending',
              ),
              slot(
                BottomTab.calendar,
                Icons.calendar_month_outlined,
                Icons.calendar_month_rounded,
                'Scheduled calls',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
