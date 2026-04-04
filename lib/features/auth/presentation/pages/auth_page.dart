import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:migra_ayuda/core/utils/constants.dart';
import 'package:migra_ayuda/core/utils/widgets/mensajesWidget.dart';
import 'package:migra_ayuda/features/auth/presentation/pages/HomeScreen/home_screen.dart';
import 'package:migra_ayuda/features/auth/presentation/pages/admin/home_screen_admin.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/auth_notifier.dart';
import 'package:migra_ayuda/features/auth/presentation/screen/complete_info_screen.dart';
import 'package:migra_ayuda/features/auth/presentation/screen/login_screen.dart';
import 'package:migra_ayuda/features/auth/presentation/screen/register_screen.dart';
import 'package:migra_ayuda/features/auth/presentation/widgets/switch_button.dart';
import 'package:migra_ayuda/l10n/app_localizations.dart';

enum AuthMode { login, register }

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  String? selectedCountry;
  AuthMode mode = AuthMode.login;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    ref.listen(
      authNotifierProvider,
      (previous, next) {
        next.whenOrNull(data: (data) {
          if (data != null) {
            if (data.profileComplete == false) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CompleteInfoScreen(),
                  ));
            } else if (data.role == 'Admin') {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreenAdmin(),
                  ));
            } else {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ));
            }
          }
        }, error: (error, stackTrace) {
          Mensajeswidget.mostrarError(context, error.toString());
        });
      },
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      const SizedBox(
                        height: 16,
                      ),
                      Image.asset(
                        'assets/logo/Logo.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      Image.asset(
                        "assets/logo/MigraAyuda.png",
                        width: 200,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Text(
                        textAlign: TextAlign.center,
                        l10n.authWelcomeText,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color.fromRGBO(108, 114, 120, 1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: UIConstants.spacingM),
                  // -----------------botones iniciar session y registro-------------
                  Container(
                    width: double.infinity,
                    height: 60,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SwitchButton(
                            text: l10n.loginTab,
                            isActive: mode == AuthMode.login,
                            onTap: () => setState(() {
                              mode = AuthMode.login;
                            }),
                          ),
                        ),
                        Expanded(
                          child: SwitchButton(
                              text: l10n.registerTab,
                              isActive: mode == AuthMode.register,
                              onTap: () => setState(() {
                                    mode = AuthMode.register;
                                  })),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (mode == AuthMode.login)
                    const LoginScreen()
                  else
                    const RegisterScreen(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
