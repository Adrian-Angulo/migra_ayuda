import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:migra_ayuda/core/constants/constants.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/tabla.dart';


final searchControllerProvider = StateProvider<String>(
  (ref) => "",
);

final seletedServiceProvider = StateProvider<String>(
  (ref) => services[0],
);

final datasourceProvider = Provider<EntityDataSource>(
  (ref) {
    return EntityDataSource();
  },
);
