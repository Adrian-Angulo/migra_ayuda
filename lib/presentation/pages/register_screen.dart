import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:migra_ayuda/presentation/pages/widget/button_google_widget.dart';
import 'package:migra_ayuda/presentation/pages/widget/dropdown_field_widget.dart';
import 'package:migra_ayuda/presentation/pages/widget/text_fiel_pasword_widget.dart';
import 'package:migra_ayuda/presentation/pages/widget/text_fiel_widget.dart';
import 'package:migra_ayuda/presentation/pages/widget/text_field_numeric_widget.dart';
import 'package:migra_ayuda/presentation/widgets/button_widget.dart';

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
    return Padding(
      padding: EdgeInsets.only(bottom: 24),
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
            SizedBox(height: 16),
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
            SizedBox(width: 10),
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
            SizedBox(height: 16),
            Row(
              spacing: 10,
              children: [
                Expanded(
                  flex: 3,
                  child: TextFieldWidget(
                    title: "Correo electrònico",
                    hintText: "Ej. usuario@gmail.com",

                    controller: _correoController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu correo';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Por favor ingresa un correo válido';
                      }
                      return null;
                    },
                  ),
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
            SizedBox(height: 16),
            TextFieldPaswordWidget(
              title: "Contraseña",

              controller: _passwordController,
            ),
            SizedBox(height: 16),
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
            SizedBox(height: 16),
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
                      style: TextStyle(fontSize: 14, color: Colors.black),
                      children: [
                        TextSpan(text: "Acepto los "),
                        TextSpan(
                          text: "términos y condiciones de uso",
                          style: TextStyle(color: Color(0xFF64999A)),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Lógica para abrir términos y condiciones
                            },
                        ),
                        TextSpan(text: " y la "),
                        TextSpan(
                          text: "política de privacidad",
                          style: TextStyle(color: Color(0xFF64999A)),
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
            SizedBox(height: 16),

            ButtonWidget(formKey: _formKey, text: 'Registrarse'),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Divider(height: 2)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text("O Registrase con"),
                ),
                Expanded(child: Divider(height: 2)),
              ],
            ),

            SizedBox(height: 16),
            ButtonGoogleWidget(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
