// ============================================================
// FILE: lib/widgets/cake_card.dart
// PURPOSE: Shows one cake in the browse grid
//          Used in browse_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:numexpress/views/model/cake.dart';
import 'package:numexpress/views/theme/colors.dart';


class CakeCard extends StatelessWidget {
  final Cake cake;
  final VoidCallback onTap;

  const CakeCard({
    super.key,
    required this.cake,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(16),
          // Soft shadow
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cake Image ──────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: cake.imageUrl,
                    height:   120,
                    width:    double.infinity,
                    fit:      BoxFit.cover,
                    // Show pink background while image loads
                    placeholder: (context, url) => Container(
                      height: 120,
                      color: kRoseLight,
                      child: const Center(
                        child: Text('🎂', style: TextStyle(fontSize: 36)),
                      ),
                    ),
                    // Show emoji if image fails to load
                    errorWidget: (context, url, error) => Container(
                      height: 120,
                      color: kRoseLight,
                      child: const Center(
                        child: Text('🎂', style: TextStyle(fontSize: 36)),
                      ),
                    ),
                  ),
                ),
                // HOT badge for bestsellers
                if (cake.isBestseller)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: kRose,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'HOT',
                        style: TextStyle(
                          color: kWhite,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // ── Cake Info ───────────────────────────
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cake name
                  Text(
                    cake.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: kBrown,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Short description
                  Text(
                    cake.description,
                    style: const TextStyle(
                      fontSize: 11,
                      color: kGray,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Price and rating on same row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${cake.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: kRose,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: kGold, size: 13),
                          const SizedBox(width: 2),
                          Text(
                            '${cake.rating}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: kBrown,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}