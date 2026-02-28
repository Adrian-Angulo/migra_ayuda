import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:migra_ayuda/presentation/pages/widget/text_fiel_pasword_widget.dart';
import 'package:migra_ayuda/presentation/pages/widget/text_fiel_widget.dart';
import 'package:migra_ayuda/presentation/pages/widget/text_field_numeric_widget.dart';

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
                TextFieldWidget(
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
                TextFieldWidget(
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
              ],
            ),

            //--------------------- Seccion pais de origen y destino -----------------------
            SizedBox(height: 16),
            Row(
              spacing: 10,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pais de origen'),
                      DropdownButtonFormField(
                        value: selectedOriginCountry,
                        // Validación del campo
                        validator: (value) {
                          if (value == null) {
                            return "Por favor selecciona un país";
                          }
                          return null;
                        },
                        items: countries.map((country) {
                          return DropdownMenuItem<String>(
                            value: country, // Valor interno
                            child: Text(country), // Lo que se muestra
                          );
                        }).toList(),
                        // Se ejecuta cuando el usuario selecciona algo
                        onChanged: (value) {
                          setState(() {
                            selectedOriginCountry =
                                value; // Actualiza el estado
                          });
                        },
                        hint: Text("Elige una opcion"),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pais de destino'),
                      DropdownButtonFormField(
                        value: selectedDestinationCountry,
                        // Validación del campo
                        validator: (value) {
                          if (value == null) {
                            return "Por favor selecciona un país";
                          }
                          return null;
                        },
                        items: countries.map((country) {
                          return DropdownMenuItem<String>(
                            value: country, // Valor interno
                            child: Text(country), // Lo que se muestra
                          );
                        }).toList(),
                        // Se ejecuta cuando el usuario selecciona algo
                        onChanged: (value) {
                          setState(() {
                            selectedDestinationCountry =
                                value; // Actualiza el estado
                          });
                        },
                        hint: Text("Elige una opcion"),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),
            Row(
              spacing: 10,
              children: [
                TextFieldWidget(
                  title: "Correo electrònico",
                  hintText: "Ej. usuario@gmail.com",
                  flex: 3,
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
                TextFieldNumericWidget(
                  title: "Edad",
                  hintText: "Ej. 25",
                  controller: _edadController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu edad';
                    }
                    final age = int.tryParse(value);
                    if (age == null || age < 18 || age > 100) {
                      return 'Edad debe ser entre 18 y 100 años';
                    }
                    return null;
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            TextFieldPaswordWidget(
              title: "Contraseña",
              hintText: "******",
              controller: _passwordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa una contraseña';
                }
                if (value.length < 6) {
                  return 'La contraseña debe tener al menos 6 caracteres';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFieldPaswordWidget(
              title: "Confirmar contraseña",
              hintText: "******",
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

            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate() && acceptTerms) {
                  // Lógica para registrarse
                  print('Formulario válido');
                } else if (!acceptTerms) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Debes aceptar los términos y condiciones'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF64999A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: Size(double.infinity, 48),
              ),
              child: Text(
                "Registrarse",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Divider(height: 2)),
                Text("O Registrase con"),
                Expanded(child: Divider(height: 2)),
              ],
            ),

            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Lógica para autenticación con Google
                print('Autenticación con Google');
              },
              icon: Image.asset(
                'assets/icons/google.png', // Asegúrate de tener el ícono de Google
                height: 24,
                width: 24,
              ),
              label: Text(
                "Continuar con Google",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
