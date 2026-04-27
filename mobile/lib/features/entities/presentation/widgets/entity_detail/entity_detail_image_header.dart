import 'package:flutter/material.dart';
import 'package:migra_ayuda/core/widgets/cached_image_widget.dart';

class EntityDetailImageHeader extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onClose;

  const EntityDetailImageHeader({
    super.key,
    required this.imageUrl,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Imagen
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: imageUrl.isNotEmpty
              ? CachedImageWidget(
                  imageUrl: imageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 64,
                    color: Colors.grey,
                  ),
                ),
        ),

        // Botón cerrar
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: onClose,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.close,
                size: 24,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
