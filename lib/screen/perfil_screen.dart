import 'package:flutter/material.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [

              const SizedBox(height: 30),

              // Avatar
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    "CM",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Nombre
              const Text(
                "Carlos Méndez",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                "c.mendez@usuario.org",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 20),

              // Chips de información
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _InfoChip(label: "Origen", value: "Venezuela"),
                  SizedBox(width: 10),
                  _InfoChip(label: "Destino", value: "Perú"),
                  SizedBox(width: 10),
                  _InfoChip(label: "Edad", value: "24"),
                ],
              ),

              const SizedBox(height: 40),

              // Opciones
              _ProfileOption(
                icon: Icons.edit_outlined,
                text: "Editar Perfil",
                onTap: () {},
              ),

              _ProfileOption(
                icon: Icons.language_outlined,
                text: "Cambiar Idioma",
                onTap: () {},
              ),

              _ProfileOption(
                icon: Icons.logout,
                text: "Cerrar Sesión",
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//widget
class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.grey.shade700),
          title: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
        const Divider(),
      ],
    );
  }
}