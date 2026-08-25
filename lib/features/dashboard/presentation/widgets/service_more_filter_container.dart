import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/app_constants.dart';
import 'package:migra_ayuda/features/dashboard/domain/entities/destination_data.dart';
import 'package:migra_ayuda/features/dashboard/presentation/providers/dashboard_providers.dart';

class ServiceMoreFilterContainer extends ConsumerWidget {
  const ServiceMoreFilterContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateDestianations = ref.watch(getDestinationsProvider);
    final userLength = ref.watch(getUserLength);

    return stateDestianations.when(
      error: (error, stackTrace) => Center(
        child: Text('Ha ocurrido un error inesperado: ${error.toString()}'),
      ),
      loading: () => FadeInUp(
        child: Container(
           decoration: ContainerDecorationBorder.decorationBox(),
            height: 350,
          child: const SizedBox(
            height: 50,
            width: 50,
            child: CircularProgressIndicator())),
      ),
      data: (list) {
        return FadeInUp(
          child: Container(
              decoration: ContainerDecorationBorder.decorationBox(),
              padding: const EdgeInsets.all(20),
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
                          itemCount: list.length > 5 ? 5 : list.length,
                          itemBuilder: (context, index) {
                            final item = list[index];
                            return DestinoBarRow(
                                stat: DestinationData(
                                    nombre: item.nombre, cantidad: item.cantidad),
                                maxValue: userLength);
                          }))
                ],
              )),
        );
      },
    );
  }
}

class DestinoBarRow extends StatelessWidget {
  final DestinationData stat;
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
              '${(porcentaje * 100).round()} %',
         
         
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
