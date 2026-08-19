import 'package:flutter/material.dart';
import 'package:migra_ayuda/core/constants/app_constants.dart';

class ServiceMoreFilterContainer extends StatelessWidget {
  const ServiceMoreFilterContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: ContainerDecorationBorder.decorationBox(),
        padding: const EdgeInsets.all(16),
        height: 350,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Destinos mas requeridos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Expanded(
                child: ListView.builder(
                    itemCount: 4,
                    itemBuilder: (context, index) => const DestinoBarRow(
                        stat: DestinoStat(nombre: 'Venezuela', cantidad: 10),
                        maxValue: 100)))
          ],
        ));
  }
}

class DestinoStat {
  final String nombre;
  final int cantidad;

  const DestinoStat({required this.nombre, required this.cantidad});
}

class DestinoBarRow extends StatelessWidget {
  final DestinoStat stat;
  final int maxValue;

  const DestinoBarRow({
    super.key,
    required this.stat,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    final double porcentaje = maxValue == 0 ? 0 : stat.cantidad / maxValue;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Nombre del país
          SizedBox(
            width: 90,
            child: Text(
              stat.nombre,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          // La barra en sí
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // "Tubo" gris de fondo
                    Container(
                      height: 10,
                      width: constraints.maxWidth,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDEDED),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    // Relleno azul proporcional
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      height: 10,
                      width: constraints.maxWidth * porcentaje,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          // Número al final
          SizedBox(
            width: 40,
            child: Text(
              '${stat.cantidad}',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
