// ---------------------------------------------------------------------------
// Skeleton loading placeholder
// ---------------------------------------------------------------------------
import 'package:flutter/material.dart';

class SkeletonBox extends StatelessWidget {
  final double radius;
  const SkeletonBox({this.radius = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}