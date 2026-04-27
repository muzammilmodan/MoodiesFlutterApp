// Add this widget at the bottom of home_kids_screen.dart or its own file

import 'package:flutter/material.dart';

class GameTile extends StatefulWidget {
  final String       emoji;
  final String       label;
  final String       subtitle;
  final Color        cardColor;
  final Color        iconBgColor;
  final VoidCallback onTap;
  final bool         isNew;

  const GameTile({
    required this.emoji,
    required this.label,
    required this.subtitle,
    required this.cardColor,
    required this.iconBgColor,
    required this.onTap,
    this.isNew = false,
  });

  @override
  State<GameTile> createState() => GameTileState();
}

class GameTileState extends State<GameTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 90));
    _scale = Tween<double>(begin: 1.0, end: 0.93)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown:   (_) => _ctrl.forward(),
    onTapUp:     (_) { _ctrl.reverse(); widget.onTap(); },
    onTapCancel:  ()  => _ctrl.reverse(),
    child: AnimatedBuilder(
      animation: _scale,
      builder: (_, child) =>
          Transform.scale(scale: _scale.value, child: child),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox.expand(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 25, horizontal: 25),
              decoration: BoxDecoration(
                color: widget.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: widget.cardColor.withOpacity(0.7),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: widget.iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(widget.emoji,
                          style: const TextStyle(fontSize: 26)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(widget.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'ChocoCooky',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A2E),
                      )),
                  const SizedBox(height: 3),
                  Text(widget.subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'ChocoCooky',
                        fontSize: 11,
                        color: Color(0xFF888888),
                      )),
                ],
              ),
            ),
          ),
          if (widget.isNew)
            Positioned(
              top: -7, right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5252),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('NEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    )),
              ),
            ),
        ],
      ),
    ),
  );
}