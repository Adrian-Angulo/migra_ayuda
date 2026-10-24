import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_crud_providers.dart';

class DeleteConfirmationDialog extends ConsumerStatefulWidget {
  final String entityName;
  final Future<void> Function() onConfirm;

  const DeleteConfirmationDialog({
    super.key,
    required this.entityName,
    required this.onConfirm,
  });

  @override
  ConsumerState<DeleteConfirmationDialog> createState() =>
      _DeleteConfirmationDialogState();
}

class _DeleteConfirmationDialogState
    extends ConsumerState<DeleteConfirmationDialog> {
  @override
  Widget build(BuildContext context) {
    final crudState = ref.watch(entitiesCrudProvider);
    final isLoading = crudState.isLoading;

    // Cierra el diálogo cuando la operación delete completa con éxito
    ref.listen<AsyncValue<CrudOperation>>(entitiesCrudProvider,
        (previous, next) {
      if (previous?.isLoading == true && !next.isLoading) {
        if (next.hasValue && next.value == CrudOperation.delete && mounted) {
          Navigator.of(context).pop();
        }
      }
    });

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 480;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: isCompact ? double.infinity : 450,
        constraints: const BoxConstraints(maxWidth: 450),
        padding: EdgeInsets.all(isCompact ? 20 : 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Ícono ────────────────────────────────────────────────
            Container(
              width: isCompact ? 64 : 80,
              height: isCompact ? 64 : 80,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                size: isCompact ? 32 : 40,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 20),

            Text(
              '¿Eliminar Organización?',
              style: TextStyle(
                fontSize: isCompact ? 20 : 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111827),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: isCompact ? 13 : 15,
                  color: const Color(0xFF6B7280),
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: 'Está a punto de eliminar la Organización '),
                  TextSpan(
                    text: '"${widget.entityName}"',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const TextSpan(
                    text:
                        '. Esta acción no se puede deshacer y toda la información asociada se perderá permanentemente.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Botones ──────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        isLoading ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () => widget.onConfirm(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: Colors.grey.shade400,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Eliminar',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
