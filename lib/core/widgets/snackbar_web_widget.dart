import 'package:flutter/material.dart';

enum SnackbarPosition {
  topLeft,
  topCenter,
  topRight,
  bottomLeft,
  bottomCenter,
  bottomRight
}

class SnackbarWebWidget {
  static void success(
    BuildContext context,
    String message, {
    SnackbarPosition position = SnackbarPosition.bottomRight,
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      context,
      message,
      backgroundColor: const Color(0xFF2E7D32),
      icon: Icons.check_circle_rounded,
      position: position,
      duration: duration,
    );
  }

  static void error(
    BuildContext context,
    String message, {
    SnackbarPosition position = SnackbarPosition.bottomRight,
    Duration duration = const Duration(seconds: 5),
  }) {
    _show(
      context,
      message,
      backgroundColor: const Color(0xFFC62828),
      icon: Icons.error_rounded,
      position: position,
      duration: duration,
    );
  }

  static void warning(
    BuildContext context,
    String message, {
    SnackbarPosition position = SnackbarPosition.bottomRight,
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      context,
      message,
      backgroundColor: const Color(0xFFE65100),
      icon: Icons.warning_rounded,
      position: position,
      duration: duration,
    );
  }

  static void info(
    BuildContext context,
    String message, {
    SnackbarPosition position = SnackbarPosition.bottomRight,
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      context,
      message,
      backgroundColor: const Color(0xFF1565C0),
      icon: Icons.info_rounded,
      position: position,
      duration: duration,
    );
  }

  static void _show(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required IconData icon,
    required SnackbarPosition position,
    required Duration duration,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _SnackbarOverlay(
        message: message,
        backgroundColor: backgroundColor,
        icon: icon,
        position: position,
        duration: duration,
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }
}

class _SnackbarOverlay extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final IconData icon;
  final SnackbarPosition position;
  final Duration duration;
  final VoidCallback onDismiss;

  const _SnackbarOverlay({
    required this.message,
    required this.backgroundColor,
    required this.icon,
    required this.position,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_SnackbarOverlay> createState() => _SnackbarOverlayState();
}

class _SnackbarOverlayState extends State<_SnackbarOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    final isTop = widget.position.name.startsWith('top');
    _slide = Tween<Offset>(
      begin: Offset(0, isTop ? -0.3 : 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    Future.delayed(widget.duration, _dismiss);
  }

  void _dismiss() async {
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  AlignmentGeometry get _alignment {
    switch (widget.position) {
      case SnackbarPosition.topLeft:
        return Alignment.topLeft;
      case SnackbarPosition.topCenter:
        return Alignment.topCenter;
      case SnackbarPosition.topRight:
        return Alignment.topRight;
      case SnackbarPosition.bottomLeft:
        return Alignment.bottomLeft;
      case SnackbarPosition.bottomCenter:
        return Alignment.bottomCenter;
      case SnackbarPosition.bottomRight:
        return Alignment.bottomRight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: _alignment,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: FadeTransition(
            opacity: _opacity,
            child: SlideTransition(
              position: _slide,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  constraints:
                      const BoxConstraints(maxWidth: 380, minWidth: 260),
                  decoration: BoxDecoration(
                    color: widget.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
                        child: Icon(
                          widget.icon,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 4),
                          child: Text(
                            widget.message,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _dismiss,
                        icon: const Icon(Icons.close,
                            color: Colors.white70, size: 18),
                        splashRadius: 16,
                        tooltip: 'Cerrar',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
