import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/app_constants.dart';
import 'package:migra_ayuda/core/constants/list_countries.dart';
import 'package:migra_ayuda/core/utils/validators/email_validator.dart';
import 'package:migra_ayuda/core/widgets/snackbar_widget.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/register_notifier.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/widgets/inputs/dropdown_field_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/widgets/inputs/text_field_password_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/widgets/inputs/text_field_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/widgets/inputs/text_field_numeric_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/widgets/inputs/button_widget.dart';
import 'package:migra_ayuda/l10n/app_localizations.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? selectedOriginCountry;
  String? selectedDestinationCountry;
  bool acceptTerms = false;

  void _clearControllers() {
    _nameController.clear();
    _emailController.clear();
    _ageController.clear();
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
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
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
            /* SnackbarWidget.success(context, l10n.successRegistration); */
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                contentPadding: const EdgeInsets.all(24),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F5F5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline_rounded,
                        color: Color(0xFF64999A),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.successRegistration,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2C2C),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF64999A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          l10n.continueButton,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          error: (error, stackTrace) {
            SnackbarWidget.error(context, error.toString());
          },
        );
      },
    );

    final registerState = ref.watch(registerProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/logo/Fondo.png',
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Hero(
                              tag: 'app-logo',
                              child: Image.asset(
                                'assets/logo/Logo.png',
                                width: 110,
                                height: 110,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Image.asset(
                              "assets/logo/MigraAyuda.png",
                              width: 180,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Crear Cuenta",
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1B1B1B),
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Únete a MigraAyuda y accede a sus recursos",
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  ),
                  //--------------- Seccion nombre y apellido---------------
                  TextFieldWidget(
                    title: "Nombre completo",
                    hintText: "Ej. Juan Perez",
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.errorLastNameRequired;
                      }
                      return null;
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
                            controller: _emailController,
                            validator: EmailValidator.validateFormat),
                      ),
                      Expanded(
                        child: TextFieldNumericWidget(
                          title: l10n.age,
                          hintText: l10n.ageHint,
                          controller: _ageController,
                        ),
                      ),
                    ],
                  ),
                  //--------------------- Seccion pais de origen y destino -----------------------

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
                  DropdownFieldWidget(
                    title: l10n.originCountry,
                    value: selectedOriginCountry,
                    items: ListCountries.contries(),
                    hint: l10n.chooseAnOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOriginCountry = value;
                      });
                    },
                  ),
                  const SizedBox(height: UIConstants.spacingM),
                  DropdownFieldWidget(
                    title: l10n.destinationCountry,
                    value: selectedDestinationCountry,
                    items: ListCountries.contries(),
                    hint: l10n.chooseAnOption,
                    onChanged: (value) {
                      setState(() {
                        selectedDestinationCountry = value;
                      });
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
                                name: _nameController.text,
                                email: _emailController.text,
                                password: _passwordController.text,
                                age: _ageController.text,
                                originCountry: selectedOriginCountry,
                                destinationCountry: selectedDestinationCountry,
                                profileComplete: true));

                        if (!context.mounted) return;
                      }),
                  const SizedBox(height: UIConstants.spacingM),

                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                      children: [
                        const TextSpan(text: "¿Ya tienes cuenta? "),
                        TextSpan(
                          text: 'Iniciar sesión',
                          style: const TextStyle(
                            color: Color(0xFF64999A),
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.of(context).pop();
                            },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: UIConstants.spacingL),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
