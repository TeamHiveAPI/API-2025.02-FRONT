import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/widgets/shimmer_placeholder.dart';

class LieutenantCard extends StatelessWidget {
  final String title;
  final String name;
  final String date;
  final String imageUrl;

  const LieutenantCard({
    super.key,
    required this.title,
    required this.name,
    required this.date,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNetworkImage = imageUrl.startsWith('http');

    Widget avatarImage;
    if (isNetworkImage) {
      avatarImage = ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              const ShimmerPlaceholder.circle(radius: 24),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      );
    } else {
      avatarImage = CircleAvatar(
        radius: 24,
        backgroundImage: AssetImage(imageUrl),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: brandBlueLight,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: brandBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    avatarImage,
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          date,
                          style: TextStyle(color: text60, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          Positioned(
            right: 16.0,
            top: 0,
            bottom: 0,
            child: Center(
              child: const Icon(
                Icons.arrow_forward_ios,
                color: brandBlue,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
