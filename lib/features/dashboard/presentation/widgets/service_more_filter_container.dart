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
        height: 350,
        child: const Center(
          child: Text('servicios mas filtrados'),
        ));
  }
}
