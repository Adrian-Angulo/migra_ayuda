import 'dart:typed_data';

import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';

final imagenSelectProvider = StateProvider<XFile?>((ref) => null);
final imagenInBytesProvider = StateProvider<Uint8List?>((ref) => null);
final messageErrorImageProvider = StateProvider<String?>(
  (ref) => null,
);
