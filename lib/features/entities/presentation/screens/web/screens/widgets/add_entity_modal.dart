import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_crud_providers.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/button_save_widget.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/widgets/form_register_entity.dart';

class AddEntityModal extends ConsumerStatefulWidget {
  /// Si se proporciona, el modal opera en modo edición.
  final EntityEntity? entity;

  const AddEntityModal({super.key, this.entity});

  bool get isEditing => entity != null;

  @override
  ConsumerState<AddEntityModal> createState() => _AddEntityModalState();
}

class _AddEntityModalState extends ConsumerState<AddEntityModal> {
  final _formKey = GlobalKey<FormRegisterEntityState>();

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isEditing;

    // Escucha el resultado del CRUD y cierra el modal al completar.
    // ref.listen en build es la forma correcta en Riverpod.
    ref.listen<AsyncValue<CrudOperation>>(entitiesCrudProvider,
        (previous, next) {
      if (previous?.isLoading == true && !next.isLoading) {
        if (next.hasValue && !next.hasError) {
          final op = next.value;
          final isSuccess = isEditing
              ? op == CrudOperation.update
              : op == CrudOperation.register;
          if (isSuccess && mounted) Navigator.pop(context);
        }
      }
    });

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
              color: Colors.black.withValues(alpha: 0.1),
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
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isEditing ? Icons.edit : Icons.business,
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
                          isEditing ? 'Editar Entidad' : 'Nueva Entidad',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isEditing
                              ? 'Actualice la información de la entidad'
                              : 'Complete los datos de la nueva entidad colaboradora',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
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
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ),
            ),

            // ── Formulario ───────────────────────────────────────────
            FormRegisterEntity(
              key: _formKey,
              entity: widget.entity,
            ),

            // ── Footer ───────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ButtonSaveWidget(
                      isEditing: isEditing,
                      onPressed: () => _formKey.currentState?.submit(),
                    ),
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
