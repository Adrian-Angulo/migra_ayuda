import 'package:flutter/material.dart';
import 'package:migra_ayuda/l10n/app_localizations.dart';

class InicioScreen extends StatelessWidget {

  const InicioScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Center(
      child: Text(
        l10n.welcomeToHome,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
