import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/filter_providers.dart';

class TextResult extends ConsumerWidget {
  const TextResult({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lista = ref.watch(listaEntidades);
    return lista.when(
      data: (entidades) {
        if (entidades.isEmpty) return const SizedBox.shrink();
        return Row(
          spacing: 8,
          children: [
            Icon(
              Icons.business,
              color: Theme.of(context).colorScheme.primary,
            ),
            Text(
              '${entidades.length} ${entidades.length == 1 ? 'entidad encontrada' : 'entidades encontradas'}',
              textAlign: TextAlign.left,
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
