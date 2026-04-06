import 'package:flutter/material.dart';

class RatingBadge extends StatelessWidget {
  final double rating;
  final double size;

  const RatingBadge({super.key, required this.rating, this.size = 12});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(230),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: Colors.amber, size: size + 4),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1C1C),
            ),
          ),
        ],
      ),
    );
  }
}
