import 'package:flutter/material.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/register_entity_screen.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/register_migrante_screen.dart';


class SeletedRegister extends StatefulWidget {
  const SeletedRegister({super.key});

  @override
  State<SeletedRegister> createState() => _SeletedRegisterState();
}

class _SeletedRegisterState extends State<SeletedRegister> {
  String? selectedType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear cuenta'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              'Selecciona el tipo de cuenta que deseas crear',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 30),
            _optionCard(
              title: 'Entidad',
              subtitle: 'Registrar una organización o institución',
              icon: Icons.business,
              value: 'entidad',
            ),
            const SizedBox(height: 16),
            _optionCard(
              title: 'Migrante',
              subtitle: 'Crear una cuenta como usuario',
              icon: Icons.person,
              value: 'migrante',
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: selectedType == null
                    ? null
                    : () {
                        debugPrint('Seleccionado: $selectedType');
                        if (selectedType == 'migrante') {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ));
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const RegisterEntityScreen()));
                        }
                      },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    'Continuar',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
  }) {
    final isSelected = selectedType == value;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        setState(() {
          selectedType = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade200,
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isSelected
                  ? Icon(
                      Icons.check_circle,
                      key: const ValueKey(true),
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    )
                  : const Icon(
                      Icons.radio_button_unchecked,
                      key: ValueKey(false),
                      color: Colors.grey,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

