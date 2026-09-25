import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_providers.dart';

class TextResult extends ConsumerWidget {
  const TextResult({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lista = ref.watch(getAllEntitiesProvider);
    return lista.when(
      data: (entidades) {
        if (entidades.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00897B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  size: 16,
                  color: Color(0xFF00897B),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${entidades.length} ${entidades.length == 1 ? "lugar disponible" : "lugares disponibles"}',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF334155),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

