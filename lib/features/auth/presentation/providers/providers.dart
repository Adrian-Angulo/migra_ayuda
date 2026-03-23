import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/models/user_model.dart';
import 'package:migra_ayuda/features/auth/data/repositories/auth_repository_imple2.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository2.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/auth_notifier.dart';

final authRepositoryProvider = Provider<AuthRepository2>(
  (ref) {
    return AuthRepositoryImple2();
  },
);

final authProvider =
    AsyncNotifierProvider<AuthNotifier, UserModel?>(AuthNotifier.new);
