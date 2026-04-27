import 'package:flutter/material.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/presentation/widgets/entity_detail/entity_detail_image_header.dart';
import 'package:migra_ayuda/features/entities/presentation/widgets/entity_detail/entity_detail_info.dart';

class EntityDetailCard extends StatelessWidget {
  final EntityEntity entity;
  final VoidCallback onClose;

  const EntityDetailCard({
    super.key,
    required this.entity,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barra de arrastre
          Center(
            child: Container(
              width: 60,
              height: 4,
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen con botón de cerrar
                  EntityDetailImageHeader(
                    imageUrl: entity.imageUrl,
                    onClose: onClose,
                  ),

                  // Información de la entidad
                  EntityDetailInfo(entity: entity),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
