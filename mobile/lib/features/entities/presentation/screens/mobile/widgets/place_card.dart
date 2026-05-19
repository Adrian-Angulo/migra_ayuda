import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/activity_actions.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/auth_notifier.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/place_details_screen.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';

import 'package:migra_ayuda/features/userActivity/presentation/providers/create_activity_notifier.dart';

class PlaceCard extends ConsumerWidget {
  final String title;
  final String category;
  final EntityEntity entity;
  final double rating;
  final bool isOpen;
  final String? imageUrl;
  final VoidCallback? onTap;

  const PlaceCard({
    super.key,
    required this.title,
    required this.category,
    required this.rating,
    required this.isOpen,
    this.imageUrl,
    this.onTap,
    required this.entity,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).value;
    return GestureDetector(
      onTap: () async {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlaceDetails(
                entity: entity,
              ),
            ));

        await ref.read(createActivityNotifier.notifier).createActivity(
            user: user!.id,
            accion: ActivityActions.entityViewed(),
            nombre: user.name,
            correo: user.email,
            pais: user.originCountry!,
            metadata: {"Service": category, "EntityName": title});
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 7,
              offset: const Offset(0, 0),
            )
          ],
        ),
        child: Row(
          children: [
            _buildImage(),
            const SizedBox(width: 12),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 90,
        height: 90,
        color: Colors.grey[200],
        child: imageUrl == null || imageUrl!.isEmpty
            ? const Icon(Icons.image_not_supported,
                size: 40, color: Colors.grey)
            : CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.broken_image,
                  size: 40,
                  color: Colors.grey,
                ),
                // Configuración de caché
                maxHeightDiskCache: 400,
                maxWidthDiskCache: 400,
                memCacheHeight: 400,
                memCacheWidth: 400,
              ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 6),
        _buildSubtitle(),
        const SizedBox(height: 6),
        _buildStatus(),
        const SizedBox(height: 10),
        _buildButton(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.star, size: 16, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                rating.toString(),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSubtitle() {
    return Row(
      children: [
        const Icon(Icons.restaurant, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          category,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildStatus() {
    return Row(
      children: [
        Icon(
          Icons.circle,
          size: 10,
          color: isOpen ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 6),
        Text(
          isOpen ? "Abierto ahora" : "Cerrado",
          style: TextStyle(
            color: isOpen ? Colors.green : Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.directions),
        label: const Text("Cómo llegar"),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5F9EA0),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
