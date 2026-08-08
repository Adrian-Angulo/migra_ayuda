import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_crud_providers.dart';

/// Botón de guardar genérico para el modal de entidad.
///
/// Recibe [onPressed] como callback, tipicamente el método `_submit`
/// expuesto desde [FormRegisterEntity] a través de su GlobalKey.
class ButtonSaveWidget extends ConsumerWidget {
  const ButtonSaveWidget({
    super.key,
    required this.onPressed,
    required this.isEditing,
  });

  final VoidCallback onPressed;

  /// Si es true muestra "Guardar Cambios", si no "Guardar Entidad".
  final bool isEditing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final crudState = ref.watch(entitiesCrudProvider);

    return ElevatedButton.icon(
      onPressed: crudState.isLoading ? null : onPressed,
      icon: crudState.isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.save, size: 20),
      label: Text(
        crudState.isLoading
            ? (isEditing ? 'Actualizando...' : 'Guardando...')
            : (isEditing ? 'Guardar Cambios' : 'Guardar Entidad'),
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isEditing ? const Color(0xFF2D5F4F) : const Color(0xFF10B981),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
        disabledBackgroundColor: Colors.grey.shade400,
      ),
    );
  }
}
