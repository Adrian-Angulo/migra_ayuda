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
    ref.listen(
      registerProvider,
      (previous, next) {
        next.whenOrNull(
          data: (_) {
            _clearControllers();
            Mensajeswidget.mostrarExito(context,
                "¡Registro exitoso! Verifica tu correo para iniciar sesión. Si no lo encuentras, revisa tu carpeta de spam.");
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
                    title: "Nombre",
                    hintText: "Juan",
                    controller: _nombreController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu nombre';
                      }
                      return null;
                    },
                  ),
                ),
                Expanded(
                  child: TextFieldWidget(
                    title: "Apellido",
                    hintText: "Castillo",
                    controller: _apellidoController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu apellido';
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
              title: 'Pais de origen',
              value: selectedOriginCountry,
              items: countries,
              hint: "Elige una opcion",
              onChanged: (value) {
                setState(() {
                  selectedOriginCountry = value;
                });
              },
            ),
            const SizedBox(width: UIConstants.spacingS),
            DropdownFieldWidget(
              title: 'Pais de destino',
              value: selectedDestinationCountry,
              items: countries,
              hint: "Elige una opcion",
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
                      title: "Correo electrònico",
                      hintText: "Ej. usuario@gmail.com",
                      controller: _correoController,
                      validator: EmailValidator.validateFormat),
                ),
                Expanded(
                  child: TextFieldNumericWidget(
                    title: "Edad",
                    hintText: "Ej. 24",
                    controller: _edadController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.spacingM),
            TextFieldPaswordWidget(
              title: "Contraseña",
              controller: _passwordController,
            ),
            const SizedBox(height: UIConstants.spacingM),
            TextFieldPaswordWidget(
              title: "Confirmar contraseña",
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
                        const TextSpan(text: "Acepto los "),
                        TextSpan(
                          text: "términos y condiciones de uso",
                          style: const TextStyle(color: Color(0xFF64999A)),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Lógica para abrir términos y condiciones
                            },
                        ),
                        const TextSpan(text: " y la "),
                        TextSpan(
                          text: "política de privacidad",
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
                text: 'Registrarse',
                loading: registerState.isLoading,
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  if (!acceptTerms) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Debes aceptar los términos y condiciones'),
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
