import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/activity_actions.dart';
import 'package:migra_ayuda/core/constants/app_constants.dart';
import 'package:migra_ayuda/core/localitation/location_provider.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/map_provider.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/widgets/homeCardWidgets/service_tag.dart';
import 'package:migra_ayuda/features/reviews/presentation/providers/review_providers.dart';
import 'package:migra_ayuda/features/userActivity/presentation/providers/activities_providers.dart';

class EntityCardWidget extends ConsumerWidget {
  const EntityCardWidget({
    super.key,
    required this.entity,
  });

  final EntityEntity entity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRating = ref.watch(meanReviewByEntity(entity.id));

    return GestureDetector(
      onTap: () async {
        ref.read(mapProvider.notifier).selectEntity(entity);
        await ref.read(activityProvider.notifier).create(
            accion: ActivityActions.entityViewed(),
            metadata: {'service': entity.services[0]});
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              )
            ]),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //contenedor de imagen
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: entity.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: entity.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.business,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.business,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entity.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 20, color: Colors.grey),
                      const SizedBox(width: 2),
                      Text(
                        entity.address,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF98A2B3),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  DistanceAndRating(
                    asyncRating: asyncRating,
                    entity: entity,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: entity.services
                        .map((service) => ServiceTag(label: service))
                        .toList(),
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

class DistanceAndRating extends ConsumerWidget {
  const DistanceAndRating({
    super.key,
    required this.asyncRating,
    required this.entity,
  });

  final AsyncValue<Map<String, dynamic>> asyncRating;
  final EntityEntity entity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final distanceState = ref.watch(distanceProvider(entity));
    return Row(
      spacing: 5,
      children: [
        const Icon(Icons.straighten, size: 20, color: Color(0xFF667085)),
        Text(
          distanceState,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF667085),
          ),
        ),
        Container(
          width: 1,
          height: 15,
          color: ColorConstants.grey400,
        ),
        const Icon(Icons.star_rounded, size: 20, color: Colors.amber),
        Text(
          asyncRating.when(
            data: (data) => (data['mean'] as num).toStringAsFixed(1),
            error: (error, stackTrace) => '0.0',
            loading: () => '---',
          ),
          style: const TextStyle(
            fontSize: 12,
            color: Colors.blueGrey,
          ),
        ),
      ],
    );
  }
}
