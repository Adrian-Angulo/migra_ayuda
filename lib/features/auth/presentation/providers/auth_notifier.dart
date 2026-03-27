import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/providers.dart';

class AuthNotifier extends AsyncNotifier<Usuario?> {
  @override
  Future<Usuario?> build() async {
    return await ref.read(usuarioAutenticadoProvider).call();
  }

  Future<void> iniciarSesion(String correo, String contrasena) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () async {
        await ref.read(iniciarSesionProvider).call(correo, contrasena);
        return ref.read(usuarioAutenticadoProvider).call();
      },
    );
  }

  Future<void> cerrarSesion() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () async {
        await ref.read(cerrarSesionProvider).call();
        return ref.read(usuarioAutenticadoProvider).call();
      },
    );
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, Usuario?>(AuthNotifier.new);
