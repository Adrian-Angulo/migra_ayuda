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

final sortOrderUserProvider = StateProvider(
  (ref) => const SortState(),
);

final usersFilterProvider =
    StateProvider.autoDispose<AsyncValue<List<UserModel>>>(
  (ref) {
    final usersAsync = ref.watch(usersNotifierProvider);
    final query = ref.watch(queryUserProvider);

    return usersAsync.when(
      data: (listUser) {
        List<UserModel> listC = listUser;
        if (query.isNotEmpty) {
          listC = listUser
              .where(
                (usu) =>
                    usu.name.toLowerCase().contains(query.toLowerCase()) ||
                    (usu.originCountry
                            ?.toLowerCase()
                            .contains(query.toLowerCase()) ??
                        false) ||
                    (usu.destinationCountry
                            ?.toLowerCase()
                            .contains(query.toLowerCase()) ??
                        false),
              )
              .toList();
        }

        return AsyncValue.data(listC);
      },
      loading: () => const AsyncValue.loading(),
      error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
    );
  },
);
