import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:migra_ayuda/core/router/app_router_notifier.dart';
import 'package:migra_ayuda/core/router/guards/web_redirect_guard.dart';

export 'package:migra_ayuda/core/router/app_router_notifier.dart';

/// Notificador de compatibilidad para el router Web.
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref);

  String? redirect(BuildContext context, GoRouterState state) {
    return webRedirectGuard(context, state, _ref);
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  final notifier = RouterNotifier(ref);
  ref.watch(appRouterNotifierProvider);
  return notifier;
});
