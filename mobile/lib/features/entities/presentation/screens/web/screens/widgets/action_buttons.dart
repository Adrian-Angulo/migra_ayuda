import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:migra_ayuda/core/widgets/snackbar_web_widget.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/delete_entity_notifier.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_providers.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/delete_confirmation_dialog.dart';

// SOLID: Single Responsibility - Widget para botones de acción de la tabla
class ActionButtons extends ConsumerWidget {
  final EntityEntity entity;

  const ActionButtons({
    super.key,
    required this.entity,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionButton(
          icon: Icons.visibility_outlined,
          color: Colors.blue,
          tooltip: 'Ver detalles',
          onPressed: () {
            context.push('/dashboard/entities/${entity.id}');
          },
        ),
        const SizedBox(width: 4),
        _ActionButton(
          icon: Icons.delete_outline,
          color: Colors.red,
          tooltip: 'Eliminar',
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => DeleteConfirmationDialog(
                entityName: entity.name,
                onConfirm: () async {
                  await ref
                      .read(deleteEntityNotifierProvider.notifier)
                      .eliminar(entity.id);

                  // Invalidar el stream para forzar recarga
                  ref.invalidate(entitiesStreamProvider);

                  if (context.mounted) {
                    SnackbarWebWidget.success(
                        context, "Sea eliminado una entidad correctamente");
                  }
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _isHovered
                  ? widget.color.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isHovered
                    ? widget.color.withOpacity(0.3)
                    : Colors.transparent,
              ),
            ),
            child: Icon(
              widget.icon,
              size: 18,
              color: _isHovered ? widget.color : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }
}
