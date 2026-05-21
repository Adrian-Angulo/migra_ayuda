import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:migra_ayuda/features/auth/presentation/providers/auth_notifier.dart';

import 'package:migra_ayuda/features/auth/presentation/screens/mobile/reset_password/send_email_screen.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/widgets/inputs/button_google_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/widgets/inputs/button_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/widgets/inputs/text_field_password_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/widgets/inputs/text_field_widget.dart';
import 'package:migra_ayuda/l10n/app_localizations.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  void cleanControllar() {
    emailController.clear();
    passController.clear();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authNotifierProvider);

    return Form(
      key: formKey,
      child: Column(
        children: [
          const SizedBox(height: 16),
          TextFieldWidget(
            title: l10n.emailText,
            hintText: l10n.emailHint,
            controller: emailController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.errorEmailRequired;
              }
              final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value.trim())) {
                return l10n.errorEmailInvalid;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFieldPaswordWidget(
            title: l10n.password,
            controller: passController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.errorPasswordRequired;
              }
              if (value.length < 8) {
                return l10n.errorPasswordMinLength;
              }

              return null;
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SendEmailScreen(),
                      ));
                },
                child: Text(l10n.resetPassword),
              ),
            ],
          ),
          ButtonWidget(
            formKey: formKey,
            loading: authState.isLoading,
            text: l10n.loginButton,
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await ref
                    .read(authNotifierProvider.notifier)
                    .login(emailController.text, passController.text);
                /* cleanControllar(); */
              }
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(child: Divider(height: 2)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(l10n.orDivider),
              ),
              const Expanded(child: Divider(height: 2)),
            ],
          ),
          const SizedBox(height: 16),
          const ButtonGoogleWidget(),
        ],
      ),
    );
  }
}
