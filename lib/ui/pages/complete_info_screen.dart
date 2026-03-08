import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:migra_ayuda/ui/pages/widget/dropdown_field_widget.dart';
import 'package:migra_ayuda/ui/pages/widget/text_fiel_widget.dart';
import 'package:migra_ayuda/ui/pages/widget/text_field_numeric_widget.dart';
import 'package:migra_ayuda/ui/widgets/button_widget.dart';


class CompleteInfoScreen extends StatefulWidget {
  const CompleteInfoScreen({super.key});

  @override
  State<CompleteInfoScreen> createState() => _CompleteInfoScreenState();
}

class _CompleteInfoScreenState extends State<CompleteInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _edadController = TextEditingController();

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
    _edadController.clear();

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
    _edadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completar información'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
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
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 16),
                  TextFieldNumericWidget(
                    title: "Edad",
                    hintText: "Ej. 24",
                    controller: _edadController,
                  ),
                  const SizedBox(height: 16),
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
                                text: "términos y condiciones de uso",
                                style:
                                    const TextStyle(color: Color(0xFF64999A)),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {},
                              ),
                              const TextSpan(text: " y la "),
                              TextSpan(
                                text: "política de privacidad",
                                style:
                                    const TextStyle(color: Color(0xFF64999A)),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {},
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ButtonWidget(
                    formKey: _formKey,
                    text: 'Completar info',
                    loading: isLoading,
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
