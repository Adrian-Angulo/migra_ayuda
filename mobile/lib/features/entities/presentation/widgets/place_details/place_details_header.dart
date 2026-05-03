import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PlaceDetailsHeader extends StatelessWidget {
  final String imageUrl;
  final String name;
  final double rating;
  final int reviewCount;
  final String service;
  final double? distanceKm;

  const PlaceDetailsHeader({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.service,
    this.distanceKm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PlaceHeroImage(imageUrl: imageUrl),
        const SizedBox(height: 16),
        _PlaceHeaderInfo(
          name: name,
          rating: rating,
          reviewCount: reviewCount,
          service: service,
          distanceKm: distanceKm,
        ),
      ],
    );
  }
}

class _PlaceHeroImage extends StatelessWidget {
  final String imageUrl;

  const _PlaceHeroImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: double.infinity,
        height: 200,
        child: imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: const Color(0xFFE5E7EB),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF5F9EA0)),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => _placeholder(),
                maxHeightDiskCache: 800,
                maxWidthDiskCache: 800,
                memCacheHeight: 800,
                memCacheWidth: 800,
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFE5E7EB),
      child: const Center(
        child:
            Icon(Icons.business_outlined, size: 64, color: Color(0xFF9CA3AF)),
      ),
    );
  }
}

class _PlaceHeaderInfo extends StatelessWidget {
  final String name;
  final double rating;
  final int reviewCount;
  final String service;
  final double? distanceKm;

  const _PlaceHeaderInfo({
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.service,
    this.distanceKm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Text(
              'Valoracion: ',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            Text(
              rating.toString(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.star_outline_rounded,
                size: 16, color: Color(0xFFFBBF24)),
            const SizedBox(width: 4),
            Text(
              '($reviewCount)',
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (service.isNotEmpty) ...[
              PlaceInfoChip(
                icon: Icons.restaurant_outlined,
                label: service,
              ),
              const SizedBox(width: 10),
            ],
          ],
        ),
      ],
    );
  }
}

class PlaceInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const PlaceInfoChip({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF5F9EA0)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }
}
