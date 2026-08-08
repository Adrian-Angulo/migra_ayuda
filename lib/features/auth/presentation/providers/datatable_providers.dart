import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/providers.dart';

class SortState {
  final int columnIndex;
  final bool ascending;
  const SortState({this.columnIndex = 0, this.ascending = true});
}

final queryUserProvider = StateProvider<String>(
  (ref) => '',
);

final userRoleFilterProvider = StateProvider<String>(
  (ref) => 'Todos',
);

final sortOrderUserProvider = StateProvider(
  (ref) => const SortState(),
);

final usersFilterProvider =
    StateProvider.autoDispose<AsyncValue<List<UserModel>>>(
  (ref) {
    final usersAsync = ref.watch(usersNotifierProvider);
    final query = ref.watch(queryUserProvider).trim().toLowerCase();
    final filterRole = ref.watch(userRoleFilterProvider);

    // Manejar los estados del AsyncValue de los usuarios
    return usersAsync.when(
      // Cuando los datos están disponibles
      data: (listUser) {
        // Filtrar la lista de usuarios según la búsqueda y el filtro por rol
        List<UserModel> filteredList = listUser.where((usu) {
          // Verificamos si el usuario coincide con el texto de búsqueda
          final matchesQuery = query.isEmpty
              ? true
              : (
                  (usu.name.toLowerCase().contains(query)) ||
                  (usu.originCountry?.toLowerCase().contains(query) ?? false) ||
                  (usu.destinationCountry?.toLowerCase().contains(query) ?? false) ||
                  (usu.role.toLowerCase().contains(query))
                );

          // Verificamos si el usuario coincide con el filtro de rol (si está activado)
          final matchesRole = filterRole == 'Todos'
              ? true
              : usu.role.toLowerCase() == filterRole.toLowerCase();

          // El usuario debe coincidir tanto con la búsqueda como el filtro de rol
          return matchesQuery && matchesRole;
        }).toList();

        // Devolver la lista filtrada envuelta en AsyncValue.data
        return AsyncValue.data(filteredList);
      },
      // Cuando los datos están cargando
      loading: () => const AsyncValue.loading(),
      // Si ocurre un error al cargar los datos
      error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
    );
  },
);
