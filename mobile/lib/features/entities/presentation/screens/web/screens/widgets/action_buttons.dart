import 'package:flutter/material.dart';

// SOLID: Single Responsibility - Widget para botones de acción de la tabla
class ActionButtons extends StatelessWidget {
  final VoidCallback onView;
  final VoidCallback onDelete;

  const ActionButtons({
    super.key,
    required this.onView,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionButton(
          icon: Icons.visibility_outlined,
          color: Colors.blue,
          tooltip: 'Ver detalles',
          onPressed: onView,
        ),
        const SizedBox(width: 4),
        _ActionButton(
          icon: Icons.delete_outline,
          color: Colors.red,
          tooltip: 'Eliminar',
          onPressed: onDelete,
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
