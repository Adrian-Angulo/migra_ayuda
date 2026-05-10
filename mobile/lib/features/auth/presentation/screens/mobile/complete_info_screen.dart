import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/home/presentation/screens/home_screen.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/auth_page.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/auth_notifier.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/widgets/inputs/dropdown_field_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/widgets/inputs/text_field_numeric_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/widgets/inputs/button_widget.dart';
import 'package:migra_ayuda/l10n/app_localizations.dart';

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
    _edadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    ref.listen(
      authNotifierProvider,
      (previous, next) {
        next.whenData(
          (usu) {
            if (usu == null) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AuthPage(),
                  ));
            }
            if (usu!.profileComplete) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ));
            }
          },
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.completeInfoTitle),
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
                    title: l10n.originCountry,
                    value: originCountry,
                    items: countries,
                    hint: l10n.chooseAnOption,
                    onChanged: (value) {
                      setState(() {
                        originCountry = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownFieldWidget(
                    title: l10n.destinationCountry,
                    value: destinationCountry,
                    items: countries,
                    hint: l10n.chooseAnOption,
                    onChanged: (value) {
                      setState(() {
                        destinationCountry = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFieldNumericWidget(
                    title: l10n.age,
                    hintText: l10n.ageHint,
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
                              TextSpan(text: "${l10n.iAccept} "),
                              TextSpan(
                                text: l10n.termsAndConditions,
                                style:
                                    const TextStyle(color: Color(0xFF64999A)),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {},
                              ),
                              TextSpan(text: " ${l10n.and} "),
                              TextSpan(
                                text: l10n.privacyPolicy,
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
                    text: l10n.completeInfoButton,
                    loading: _loading,
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
                      child: Text(l10n.cancelButton))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
