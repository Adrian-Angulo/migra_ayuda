import 'package:flutter/material.dart';
import 'package:migra_ayuda/features/auth/presentation/widgets/drawer/app_drawer.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      appBar: AppBar(),
      key: scaffoldKey,
      drawer: const AppDrawer(),
      body: const SafeArea(
          child: Center(
        child: Text("Inicio"),
      )),
    );
  }
}
