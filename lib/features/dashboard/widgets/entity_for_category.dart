import 'package:flutter/material.dart';
import 'package:migra_ayuda/core/constants/app_constants.dart';

class EntityForCategoryContainer extends StatelessWidget {
  const EntityForCategoryContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      decoration: ContainerDecorationBorder.decorationBox(),
      child: const Center(
        child: Text('Grafico'),
      ),
    );
  }
}
