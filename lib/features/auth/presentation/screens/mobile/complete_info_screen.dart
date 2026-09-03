import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:migra_ayuda/core/constants/list_countries.dart';
import 'package:migra_ayuda/core/router/routes.dart';
import 'package:migra_ayuda/core/widgets/legal/privacy_policy_widget.dart';
import 'package:migra_ayuda/core/widgets/legal/terms_and_conditions_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/login_screen.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/auth_notifier.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/widgets/inputs/dropdown_field_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/widgets/inputs/text_field_numeric_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/widgets/inputs/button_widget.dart';

class CompleteInfoScreen extends ConsumerStatefulWidget {
  const CompleteInfoScreen({super.key});

  @override
  ConsumerState<CompleteInfoScreen> createState() => _CompleteInfoScreenState();
}

class _CompleteInfoScreenState extends ConsumerState<CompleteInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _edadController = TextEditingController();
  String? originCountry;
  String? destinationCountry;
  bool acceptTerms = false;
  bool _loading = false;

  final List<String> countries = ListCountries.contries();

  @override
  void dispose() {
    _edadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      authNotifierProvider,
      (previous, next) {
        next.whenData(
          (usu) {
            if (usu == null) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ));
            }
            if (usu!.profileComplete) {
              context.go(Routes.home);
            }
          },
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Completar información'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  DropdownFieldWidget(
                    title: 'País de origen',
                    value: originCountry,
                    items: countries,
                    hint: 'Elige una opción',
                    onChanged: (value) {
                      setState(() {
                        originCountry = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownFieldWidget(
                    title: 'País de destino',
                    value: destinationCountry,
                    items: countries,
                    hint: 'Elige una opción',
                    onChanged: (value) {
                      setState(() {
                        destinationCountry = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFieldNumericWidget(
                    title: 'Edad',
                    hintText: 'Ej. 24',
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
                                text: 'términos y condiciones de uso',
                                style:
                                    const TextStyle(color: Color(0xFF64999A), fontWeight: FontWeight.bold),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const TermsAndConditionsWidget(),
                                      ),
                                    );
                                  },
                              ),
                              const TextSpan(text: " y la "),
                              TextSpan(
                                text: 'política de privacidad',
                                style:
                                    const TextStyle(color: Color(0xFF64999A), fontWeight: FontWeight.bold),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const PrivacyPolicyWidget(),
                                      ),
                                    );
                                  },
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
                    text: 'Completar Información',
                    loading: _loading,
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

                      setState(() => _loading = true);
                      try {
                        await ref
                            .read(authNotifierProvider.notifier)
                            .completeProfile(
                              originCountry: originCountry!,
                              destinationCountry: destinationCountry!,
                              age: int.parse(_edadController.text),
                            );
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context)
                            ..clearSnackBars()
                            ..showSnackBar(SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ));
                        }
                      } finally {
                        if (mounted) setState(() => _loading = false);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                      onPressed: () async {
                        await ref.read(authNotifierProvider.notifier).logout();
                      },
                      child: const Text('Cancelar'))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
