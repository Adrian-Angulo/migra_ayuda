import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_crud_providers.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/widgets/form_register_entity.dart';

class ModalFormEntity extends ConsumerStatefulWidget {
  final EntityEntity? entity;
  const ModalFormEntity({super.key, this.entity});

  @override
  ConsumerState<ModalFormEntity> createState() => _AddEntityModalState();
}

class _AddEntityModalState extends ConsumerState<ModalFormEntity> {
  @override
  Widget build(BuildContext context) {
    // Escucha el resultado del CRUD y cierra el modal al completar.
    ref.listen<AsyncValue<CrudOperation>>(entitiesCrudProvider, (previous, next) {
      if (previous?.isLoading == true && !next.isLoading) {
        if (next.hasValue && !next.hasError) {
          final op = next.value;
          // Cierra el modal tanto para editar como para registrar
          if ((op == CrudOperation.register || op == CrudOperation.update) && mounted) {
            Navigator.pop(context);
          }
        }
      }
    });

    final isEdit = widget.entity != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 700,
        constraints: const BoxConstraints(maxHeight: 850),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26), // .withValues is not a valid method for Color; used withAlpha(26) for ~10%
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header dinámico ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2D5F4F), Color(0xFF1E4438)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(51), // 20% opacity
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.business,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEdit ? 'Editar Entidad' : 'Nueva Entidad',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isEdit
                            ? 'Modifique los datos de la entidad colaboradora'
                            : 'Complete los datos de la nueva entidad colaboradora',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: Colors.white,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withAlpha(51), // 20% opacity
                    ),
                  ),
                ],
              ),
            ),

            // ── Formulario ───────────────────────────────────────────
            FormEntity(entity: widget.entity),
          ],
        ),
      ),
    );
  }
}
