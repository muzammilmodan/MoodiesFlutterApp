
// ─── Colorful Kids Menu Card ─────────────────────────────────────────────────

import 'package:flutter/material.dart';

class KidsMenuCard extends StatefulWidget {
  final String       label;
  final String       subtitle;
  final String       emoji;
  final Color        cardColor;
  final Color        iconBgColor;
  final VoidCallback onTap;
  final bool         isNew;      // shows a red "NEW" badge

  const KidsMenuCard({
    super.key,
    required this.label,
    required this.subtitle,
    required this.emoji,
    required this.cardColor,
    required this.iconBgColor,
    required this.onTap,
    this.isNew = false,
  });

  @override
  State<KidsMenuCard> createState() => _KidsMenuCardState();
}

class _KidsMenuCardState extends State<KidsMenuCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 90));
    _scale = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
    child: GestureDetector(
      onTapDown:  (_) => _ctrl.forward(),
      onTapUp:    (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: ()  => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ── card body ────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: widget.cardColor,
                borderRadius: BorderRadius.circular(20),
                // colored shadow that matches the card — key visual upgrade
                boxShadow: [
                  BoxShadow(
                    color: widget.cardColor.withOpacity(0.75),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // emoji circle
                  Container(
                    width: 54, height: 54,
                    decoration: BoxDecoration(
                      color: widget.iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(widget.emoji,
                          style: const TextStyle(fontSize: 26)),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.label,
                            style: const TextStyle(
                              fontFamily: 'ChocoCooky',
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A2E),
                            )),
                        const SizedBox(height: 2),
                        Text(widget.subtitle,
                            style: const TextStyle(
                              fontFamily: 'ChocoCooky',
                              fontSize: 12,
                              color: Color(0xFF888888),
                            )),
                      ],
                    ),
                  ),

                  // arrow circle
                  Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_forward_ios_rounded,
                        size: 13, color: Color(0xFF666666)),
                  ),
                ],
              ),
            ),

            // ── NEW badge (top-right, overflows card) ────────────
            if (widget.isNew)
              Positioned(
                top: -7, right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5252),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF5252).withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: const Text('NEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      )),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}