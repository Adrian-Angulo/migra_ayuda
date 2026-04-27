import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/auth_notifier.dart';
import 'package:migra_ayuda/l10n/app_localizations.dart';

class ButtonGoogleWidget extends ConsumerWidget {
  const ButtonGoogleWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return ElevatedButton.icon(
      onPressed: () async {
        ref.read(authNotifierProvider.notifier).authWithGoogle();
      },
      icon: Image.asset(
        'assets/icons/google.png',
        height: 24,
        width: 24,
      ),
      label: Text(
        l10n.googleText,
        style: const TextStyle(
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
        minimumSize: const Size(double.infinity, 48),
      ),
    );
  }
}
