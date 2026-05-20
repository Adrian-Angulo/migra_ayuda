import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/language/presentation/providers/language_provider.dart';
import 'package:migra_ayuda/l10n/app_localizations.dart';

class DrawerMenuItems extends ConsumerWidget {
  final VoidCallback onEditProfile;
  final VoidCallback onLogout;

  const DrawerMenuItems({
    super.key,
    required this.onEditProfile,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(languageProvider);

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Divider(),
        ),

        // Opciones del menú
        _DrawerOption(
          icon: Icons.edit_outlined,
          label: l10n.editProfile,
          onTap: onEditProfile,
        ),
        _DrawerOption(
          icon: Icons.language_rounded,
          label: l10n.changeLanguage,
          onTap: () {
            Navigator.pop(context);
            /* _showLanguagePicker(context, ref, l10n, currentLocale); */
          },
        ),

        const Spacer(),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(),
        ),

        _DrawerOption(
          icon: Icons.logout_rounded,
          label: l10n.logout,
          color: Colors.redAccent,
          onTap: onLogout,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  void _showLanguagePicker(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Locale? currentLocale,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _LanguagePickerSheet(
        currentLocale: currentLocale,
        l10n: l10n,
        onLanguageSelected: (code) async {
          Navigator.pop(ctx);
          await ref.read(languageProvider.notifier).changeLanguage(code);
        },
      ),
    );
  }
}

class _DrawerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.onSurface;

    return ListTile(
      leading: Icon(icon, color: effectiveColor),
      title: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: effectiveColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.keyboard_arrow_right_outlined),
      horizontalTitleGap: 4,
      onTap: onTap,
    );
  }
}

class _LanguagePickerSheet extends StatelessWidget {
  final Locale? currentLocale;
  final AppLocalizations l10n;
  final Future<void> Function(String code) onLanguageSelected;

  const _LanguagePickerSheet({
    required this.currentLocale,
    required this.l10n,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.selectLanguageTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.chooseLanguageHint,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 20),
          _LanguageOption(
            flag: '🇪🇸',
            name: l10n.spanish,
            subtitle: 'Spanish',
            isSelected: currentLocale?.languageCode == 'es',
            onTap: () => onLanguageSelected('es'),
          ),
          const SizedBox(height: 12),
          _LanguageOption(
            flag: '🇬🇧',
            name: l10n.english,
            subtitle: 'Inglés',
            isSelected: currentLocale?.languageCode == 'en',
            onTap: () => onLanguageSelected('en'),
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String flag;
  final String name;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.flag,
    required this.name,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF5F9EA0).withValues(alpha: 0.08)
              : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF5F9EA0) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFF5F9EA0)
                          : const Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    subtitle,
                    style:
                        const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF5F9EA0), size: 22),
          ],
        ),
      ),
    );
  }
}
