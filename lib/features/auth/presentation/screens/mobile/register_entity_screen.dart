import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/app_constants.dart';
import 'package:migra_ayuda/core/utils/validators/email_validator.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/register_notifier.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/header_form_auth.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/widgets/inputs/button_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/widgets/inputs/text_field_password_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/widgets/inputs/text_field_widget.dart';
import 'package:migra_ayuda/l10n/app_localizations.dart';

class RegisterEntityScreen extends ConsumerStatefulWidget {
  const RegisterEntityScreen({
    super.key,
  });

  @override
  ConsumerState<RegisterEntityScreen> createState() => _RegisterEntityScreenState();
}

class _RegisterEntityScreenState extends ConsumerState<RegisterEntityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool acceptTerms = false;
  
  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(registerProvider);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
        appBar: AppBar(),
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const HeaderFormAuth(),
                    const SizedBox(height: UIConstants.spacingM),
                    TextFieldWidget(
                      title: l10n.emailText,
                      hintText: l10n.emailHint,
                      controller: _emailController,
                      validator: EmailValidator.validateFormat,
                    ),
                    const SizedBox(height: UIConstants.spacingM),
                    TextFieldPaswordWidget(
                      title: l10n.password,
                      controller: _passwordController,
                    ),
                    const SizedBox(height: UIConstants.spacingM),
                    TextFieldPaswordWidget(
                      title: l10n.confirmPassword,
                      controller: _confirmPasswordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.errorConfirmPasswordRequired;
                        }
                        if (value != _passwordController.text) {
                          return l10n.errorPasswordsNotMatch;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: UIConstants.spacingM),
                    Flexible(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black),
                            children: [
                              TextSpan(text: "${l10n.iAccept} "),
                              TextSpan(
                                text: l10n.termsAndConditions,
                                style:
                                    const TextStyle(color: Color(0xFF64999A)),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    // Lógica para abrir términos y condiciones
                                  },
                              ),
                              TextSpan(text: " ${l10n.and} "),
                              TextSpan(
                                text: l10n.privacyPolicy,
                                style:
                                    const TextStyle(color: Color(0xFF64999A)),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    // Lógica para abrir política de privacidad
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ButtonWidget(
                      formKey: _formKey,
                      text: l10n.registerTab,
                      loading: registerState.isLoading,
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;

                        if (!acceptTerms) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.errorAcceptTerms),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                       /*  ref.read(registerProvider.notifier).registerUser(
                            UserModel(
                                name: _nameController.text,
                                email: _emailController.text,
                                password: _passwordController.text,
                                age: _ageController.text,
                                originCountry: selectedOriginCountry,
                                destinationCountry: selectedDestinationCountry,
                                profileComplete: true)); */

                        if (!context.mounted) return;
                      }),
                  ],
                )),
          ),
        )));
  }
}
