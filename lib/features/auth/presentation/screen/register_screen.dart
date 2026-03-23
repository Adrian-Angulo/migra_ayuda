import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:migra_ayuda/core/utils/constants.dart';
import 'package:migra_ayuda/core/utils/validation/email_validator.dart';
import 'package:migra_ayuda/provider/auth_provider.dart';

import 'package:migra_ayuda/features/auth/presentation/widgets/dropdown_field_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/widgets/text_fiel_pasword_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/widgets/text_fiel_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/widgets/text_field_numeric_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/widgets/button_widget.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
  bool isLoading = false;

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
  Widget build(BuildContext context) {
    final error = context.watch<AuthProvider>().error;
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
                loading: context.watch<AuthProvider>().isLoading,
                onPressed: () async {
                  // 1. Validar formulario
                  if (!_formKey.currentState!.validate()) return;

                  // 2. Validar términos
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

                  // 3. Llamar al provider (él maneja isLoading y error)
                  final authProvider = context.read<AuthProvider>();
                  await authProvider.register(
                    _nombreController.text.trim(),
                    _apellidoController.text.trim(),
                    _correoController.text,
                    _passwordController.text,
                    selectedOriginCountry ?? 'No especificado',
                    selectedDestinationCountry ?? 'No especificado',
                    int.tryParse(_edadController.text) ?? 0,
                    
                  );

                  if (!context.mounted) return;

                  // 4. Revisar resultado DESPUÉS del registro
                  if (authProvider.error == null) {
                    _clearControllers(); // ✅ limpias solo si fue exitoso
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('¡Registro completado exitosamente!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(authProvider.error!),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }),
            const SizedBox(height: UIConstants.spacingM),
          ],
        ),
      ),
    );
  }
}
