import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/utils/constants.dart';
import 'package:migra_ayuda/core/utils/validation/email_validator.dart';
import 'package:migra_ayuda/core/utils/widgets/mensajesWidget.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/register_notifier.dart';
import 'package:migra_ayuda/features/auth/presentation/widgets/dropdown_field_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/widgets/text_fiel_pasword_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/widgets/text_fiel_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/widgets/text_field_numeric_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/widgets/button_widget.dart';
import 'package:migra_ayuda/l10n/app_localizations.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _correoController = TextEditingController();
  final _edadController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? selectedOriginCountry;
  String? selectedDestinationCountry;
  bool acceptTerms = false;

  final List<String> countries = [
    'México',
    'Estados Unidos',
    'Guatemala',
    'Honduras',
    'El Salvador',
    'Nicaragua',
    'Costa Rica',
    'Panamá',
  ];

  void _clearControllers() {
    _nombreController.clear();
    _apellidoController.clear();
    _correoController.clear();
    _edadController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    setState(() {
      selectedOriginCountry = null;
      selectedDestinationCountry = null;
      acceptTerms = false;
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _edadController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    ref.listen(
      registerProvider,
      (previous, next) {
        next.whenOrNull(
          data: (_) {
            _clearControllers();
            Mensajeswidget.mostrarExito(context, l10n.successRegistration);
          },
          error: (error, stackTrace) {
            Mensajeswidget.mostrarError(context, error.toString());
          },
        );
      },
    );

    final registerState = ref.watch(registerProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: UIConstants.spacingL),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            //--------------- Seccion nombre y apellido---------------
            Row(
              spacing: 10,
              children: [
                Expanded(
                  child: TextFieldWidget(
                    title: l10n.firstName,
                    hintText: l10n.firstNameHint,
                    controller: _nombreController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.errorFirstNameRequired;
                      }
                      return null;
                    },
                  ),
                ),
                Expanded(
                  child: TextFieldWidget(
                    title: l10n.lastName,
                    hintText: l10n.lastNameHint,
                    controller: _apellidoController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.errorLastNameRequired;
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            //--------------------- Seccion pais de origen y destino -----------------------
            const SizedBox(height: UIConstants.spacingM),
            DropdownFieldWidget(
              title: l10n.originCountry,
              value: selectedOriginCountry,
              items: countries,
              hint: l10n.chooseAnOption,
              onChanged: (value) {
                setState(() {
                  selectedOriginCountry = value;
                });
              },
            ),
            const SizedBox(width: UIConstants.spacingS),
            DropdownFieldWidget(
              title: l10n.destinationCountry,
              value: selectedDestinationCountry,
              items: countries,
              hint: l10n.chooseAnOption,
              onChanged: (value) {
                setState(() {
                  selectedDestinationCountry = value;
                });
              },
            ),
            const SizedBox(height: UIConstants.spacingM),
            Row(
              spacing: 10,
              children: [
                Expanded(
                  flex: 3,
                  child: TextFieldWidget(
                      title: l10n.emailText,
                      hintText: l10n.emailHint,
                      controller: _correoController,
                      validator: EmailValidator.validateFormat),
                ),
                Expanded(
                  child: TextFieldNumericWidget(
                    title: l10n.age,
                    hintText: l10n.ageHint,
                    controller: _edadController,
                  ),
                ),
              ],
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
            Row(
              children: [
                Checkbox(
                  value: acceptTerms,
                  onChanged: (bool? value) {
                    setState(() {
                      acceptTerms = value ?? false;
                    });
                  },
                ),
                Flexible(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                      children: [
                        TextSpan(text: "${l10n.iAccept} "),
                        TextSpan(
                          text: l10n.termsAndConditions,
                          style: const TextStyle(color: Color(0xFF64999A)),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Lógica para abrir términos y condiciones
                            },
                        ),
                        TextSpan(text: " ${l10n.and} "),
                        TextSpan(
                          text: l10n.privacyPolicy,
                          style: const TextStyle(color: Color(0xFF64999A)),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Lógica para abrir política de privacidad
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.spacingM),
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

                  await ref.read(registerProvider.notifier).registerUser(
                      UserModel(
                          name: _nombreController.text,
                          lastname: _apellidoController.text,
                          email: _correoController.text,
                          password: _passwordController.text,
                          age: _edadController.text,
                          originCountry: selectedOriginCountry,
                          destinationCountry: selectedDestinationCountry,
                          profileComplete: true));

                  if (!context.mounted) return;
                }),
            const SizedBox(height: UIConstants.spacingM),
          ],
        ),
      ),
    );
  }
}
