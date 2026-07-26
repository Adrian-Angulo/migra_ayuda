import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_providers.dart';
import 'package:migra_ayuda/l10n/app_localizations.dart';


class TextResult extends ConsumerWidget {
  const TextResult({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lista = ref.watch(getAllEntitiesProvider);
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
              '${entidades.length} ${entidades.length == 1 ? l10n.entitiesSearchOne : l10n.entitiesSearch}',
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
