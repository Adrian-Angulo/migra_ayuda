import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/app_constants.dart';
import 'package:migra_ayuda/core/constants/list_countries.dart';
import 'package:migra_ayuda/core/utils/validators/email_validator.dart';
import 'package:migra_ayuda/core/widgets/legal/privacy_policy_widget.dart';
import 'package:migra_ayuda/core/widgets/legal/terms_and_conditions_widget.dart';
import 'package:migra_ayuda/core/widgets/mobil/snackbar_widget.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/register_notifier.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/header_form_auth.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/widgets/inputs/alert_success_register.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/widgets/inputs/dropdown_field_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/widgets/inputs/text_field_password_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/widgets/inputs/text_field_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/widgets/inputs/text_field_numeric_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/widgets/inputs/button_widget.dart';

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
  Widget build(BuildContext context) {
    ref.listen(
      registerProvider,
      (previous, next) {
        next.whenOrNull(
          data: (success) {
            if (success == true) {
              _clearControllers();
              /* SnackbarWidget.success(context, '¡Registro exitoso! Verifica tu correo para iniciar sesión. Si no lo encuentras, revisa tu carpeta de spam.'); */
              showDialog(
                context: context,
                builder: (context) => const AlertSuccessRegister(),
              );
            }
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
                  const HeaderFormAuth(),
                  //--------------- Seccion nombre y apellido---------------
                  TextFieldWidget(
                    title: "Nombre completo",
                    hintText: "Ej. Juan Perez",
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu nombre completo';
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
                            title: 'Correo electrónico',
                            hintText: 'Ej. usuario@gmail.com',
                            controller: _emailController,
                            validator: EmailValidator.validateFormat),
                      ),
                      Expanded(
                        child: TextFieldNumericWidget(
                          title: 'Edad',
                          hintText: 'Ej. 24',
                          controller: _ageController,
                        ),
                      ),
                    ],
                  ),
                  //--------------------- Seccion pais de origen y destino -----------------------

                  const SizedBox(height: UIConstants.spacingM),
                  TextFieldPaswordWidget(
                    title: 'Contraseña',
                    controller: _passwordController,
                  ),
                  const SizedBox(height: UIConstants.spacingM),
                  TextFieldPaswordWidget(
                    title: 'Confirmar contraseña',
                    controller: _confirmPasswordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor confirma tu contraseña';
                      }
                      if (value != _passwordController.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: UIConstants.spacingM),
                  DropdownFieldWidget(
                    title: 'País de origen',
                    value: selectedOriginCountry,
                    items: ListCountries.contries(),
                    hint: 'Elige una opción',
                    onChanged: (value) {
                      setState(() {
                        selectedOriginCountry = value;
                      });
                    },
                  ),
                  const SizedBox(height: UIConstants.spacingM),
                  DropdownFieldWidget(
                    title: 'País de destino',
                    value: selectedDestinationCountry,
                    items: ListCountries.contries(),
                    hint: 'Elige una opción',
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
                              const TextSpan(text: "Acepto los "),
                              TextSpan(
                                text: 'términos y condiciones de uso',
                                style:
                                    const TextStyle(color: Color(0xFF64999A), fontWeight: FontWeight.bold),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsAndConditionsWidget(),));
                                  },
                              ),
                              const TextSpan(text: " y la "),
                              TextSpan(
                                text: 'política de privacidad',
                                style:
                                     const TextStyle(color: Color(0xFF64999A), fontWeight: FontWeight.bold),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                     Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyWidget(),));
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
                      text: 'Registrarse',
                      loading: registerState.isLoading,
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;

                        if (!acceptTerms) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Debes aceptar los términos y condiciones'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        ref.read(registerProvider.notifier).registerUser(
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
