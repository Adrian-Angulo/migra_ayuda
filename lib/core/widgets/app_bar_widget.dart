import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/widgets.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final EntityEntity? entity;

  const AppBarWidget({super.key, required this.title, this.entity});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(kIsWeb ? Icons.close : Icons.arrow_back_ios_new,
            size: 18, color: Color(0xFF1A1A1A)),
        style: IconButton.styleFrom(
          backgroundColor: const Color(0xFFF1F5F9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A1A),
        ),
      ),
    );
  }
}
