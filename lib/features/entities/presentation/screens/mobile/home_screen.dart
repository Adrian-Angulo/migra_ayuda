import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/app_constants.dart';
import 'package:migra_ayuda/features/auth/presentation/widgets/drawer/app_drawer.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/mapbox_widget.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/widgets/homeCardWidgets/filter_container.dart';


class HomeScreen extends ConsumerWidget {
  HomeScreen({super.key});

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          title: Image.asset(
            "assets/logo/MigraAyuda.png",
            width: 180,
          ),
          actions: [
            IconButton(
              icon: const CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Icon(
                    Icons.person_rounded,
                    color: ColorConstants.grey200,
                  )),
              onPressed: () => scaffoldKey.currentState?.openEndDrawer(),
            ),
          ],
        ),
        key: scaffoldKey,
        endDrawer: const AppDrawer(),
        body: const Column(
          children: [
            FilterContainer(),
            Expanded(
              child: MapboxWidget(
                key: ValueKey('mapbox_main'),
              ),
            ),
          ],
        ));
  }
}
