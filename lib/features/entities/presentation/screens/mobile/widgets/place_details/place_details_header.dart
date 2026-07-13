import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/constants.dart';

import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/reviews/presentation/providers/review_providers.dart';

class PlaceDetailsHeader extends ConsumerWidget {
  final EntityEntity entity;

  const PlaceDetailsHeader({
    super.key,
    required this.entity,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratingMeanAndLengt = ref.watch(meanReviewByEntity(entity.id));
    

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PlaceHeroImage(imageUrl: entity.imageUrl),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entity.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 6),
            ratingMeanAndLengt.when(
              data: (data) => Row(
                children: [
                  const Text(
                    'Valoracion: ',
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                  ),
                  Text(
                    '${data['mean']}',
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
                    '(${data['count']})',
                    style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              error: (Object error, StackTrace stackTrace) =>
                  const Text('Error'),
              loading: () => const Text('-----'),
            ),
            
            const SizedBox(height: 12),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: [
                ...entity.services.map(
                  (service) => PlaceInfoChip(
                    icon: getServiceIcon(service),
                    label: service,
                  ),
                ),
              ],
            ),
          ],
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
