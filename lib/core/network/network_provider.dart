import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'network_info.dart';

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl();
});

