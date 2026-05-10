import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/auth_notifier.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/widgets/inputs/dropdown_field_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/widgets/inputs/text_field_numeric_widget.dart';
import 'package:migra_ayuda/l10n/app_localizations.dart';

const _countries = [
  'Afghanistan',
  'Albania',
  'Algeria',
  'Argentina',
  'Australia',
  'Bolivia',
  'Brasil',
  'Canada',
  'Chile',
  'China',
  'Colombia',
  'Costa Rica',
  'Cuba',
  'Ecuador',
  'El Salvador',
  'España',
  'Estados Unidos',
  'Francia',
  'Guatemala',
  'Haiti',
  'Honduras',
  'Italia',
  'Jamaica',
  'México',
  'Nicaragua',
  'Panamá',
  'Paraguay',
  'Perú',
  'Portugal',
  'Puerto Rico',
  'República Dominicana',
  'Uruguay',
  'Venezuela',
];

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();

  String? _originCountry;
  String? _destinationCountry;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).value;
    if (user != null) {
      _originCountry =
          _countries.contains(user.originCountry) ? user.originCountry : null;
      _destinationCountry = _countries.contains(user.destinationCountry)
          ? user.destinationCountry
          : null;
      _ageController.text = user.age ?? '';
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await ref.read(authNotifierProvider.notifier).completeProfile(
            originCountry: _originCountry!,
            destinationCountry: _destinationCountry!,
            age: int.parse(_ageController.text.trim()),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Text('Perfil actualizado correctamente'),
              ],
            ),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _EditProfileAppBar(title: l10n.editProfile),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Aviso informativo
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 18, color: Color(0xFF3B82F6)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Solo puedes editar tu país de origen, destino y edad.',
                        style:
                            TextStyle(fontSize: 13, color: Color(0xFF1D4ED8)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              _SectionLabel(
                  label: l10n.originCountry,
                  icon: Icons.flight_takeoff_rounded),
              const SizedBox(height: 8),
              DropdownFieldWidget(
                title: '',
                value: _originCountry,
                items: _countries,
                hint: l10n.chooseAnOption,
                onChanged: (v) => setState(() => _originCountry = v),
              ),
              const SizedBox(height: 24),

              _SectionLabel(
                  label: l10n.destinationCountry,
                  icon: Icons.flight_land_rounded),
              const SizedBox(height: 8),
              DropdownFieldWidget(
                title: '',
                value: _destinationCountry,
                items: _countries,
                hint: l10n.chooseAnOption,
                onChanged: (v) => setState(() => _destinationCountry = v),
              ),
              const SizedBox(height: 24),

              _SectionLabel(label: l10n.age, icon: Icons.cake_rounded),
              const SizedBox(height: 8),
              TextFieldNumericWidget(
                title: '',
                hintText: l10n.ageHint,
                controller: _ageController,
              ),
              const SizedBox(height: 40),

              _SaveButton(loading: _loading, onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}

// ── AppBar ────────────────────────────────────────────────────────────────────
class _EditProfileAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  const _EditProfileAppBar({required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: Color(0xFF1A1A1A)),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A1A),
        ),
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SectionLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF5F9EA0)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
      ],
    );
  }
}

// ── Save Button ───────────────────────────────────────────────────────────────
class _SaveButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onPressed;

  const _SaveButton({required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5F9EA0),
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          disabledBackgroundColor:
              const Color(0xFF5F9EA0).withValues(alpha: 0.5),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.save_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    l10n.editProfile,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }
}
