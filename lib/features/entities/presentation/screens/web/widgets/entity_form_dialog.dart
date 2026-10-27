import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/errors/failure.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_crud_providers.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/widgets/entity_form.dart';

class EntityFormDialog extends ConsumerStatefulWidget {
  final EntityEntity? entity;
  const EntityFormDialog({super.key, this.entity});

  @override
  ConsumerState<EntityFormDialog> createState() => _EntityFormDialogState();
}

class _EntityFormDialogState extends ConsumerState<EntityFormDialog> {
  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<CrudOperation>>(entitiesCrudProvider,
        (previous, next) {
      if (previous?.isLoading == true && !next.isLoading) {
        if (next.hasValue && !next.hasError) {
          final op = next.value;

          if ((op == CrudOperation.register || op == CrudOperation.update) &&
              mounted) {
            Navigator.pop(context);
          }
        } else if (next.hasError && mounted) {
          final error = next.error;
          final message = error is Failure ? error.message : error.toString();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    });

    final isEdit = widget.entity != null;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final isCompact = screenWidth < 768;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 24,
        vertical: isCompact ? 16 : 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: isCompact ? double.infinity : 700,
        constraints: BoxConstraints(
          maxWidth: 700,
          maxHeight: screenHeight * 0.9,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(isCompact ? 16 : 24),
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
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(51),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.business,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEdit ? 'Editar Organización' : 'Nueva Organización',
                          style: TextStyle(
                            fontSize: isCompact ? 18 : 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isEdit
                              ? 'Modifique los datos de la Organización'
                              : 'Complete los datos de la nueva Organización',
                          style: TextStyle(
                            fontSize: isCompact ? 12 : 13,
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
                      backgroundColor: Colors.white.withAlpha(51),
                    ),
                  ),
                ],
              ),
            ),
            EntityForm(entity: widget.entity),
          ],
        ),
      ),
    );
  }
}
