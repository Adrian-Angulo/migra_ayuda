import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/models/user_model.dart';
import 'package:migra_ayuda/features/auth/data/repositories/auth_repository_imple2.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';

import 'package:migra_ayuda/features/auth/domain/useCases/login_user.dart';
import 'package:migra_ayuda/features/auth/domain/useCases/logout.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/auth_notifier.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) {
    return AuthRepositoryImple2();
  },
);

final authProvider =
    AsyncNotifierProvider<AuthNotifier, UserModel?>(AuthNotifier.new);

final loginUserProvider = Provider<LoginUser>(
  (ref) {
    final repo = ref.read(authRepositoryProvider);
    return LoginUser(repo);
  },
);

final logoutProvider = Provider<Logout>(
  (ref) {
    final repo = ref.read(authRepositoryProvider);
    return Logout(repo);
  },
);
