import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class ImagePickerWidget extends StatefulWidget {
  const ImagePickerWidget({super.key});

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final picker = ImagePicker();
  XFile? imagen;
  Uint8List? imagenBytes;

  Future<void> _elegirImagen() async {
    final resultado = await picker.pickImage(source: ImageSource.gallery);
    if (resultado == null) return;

    final bytes = await resultado.readAsBytes();

    setState(() {
      imagen = resultado;
      imagenBytes = bytes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _elegirImagen,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: imagenBytes == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Agregar Foto',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(
                  // ✅ funciona en web
                  imagenBytes!,
                  fit: BoxFit.cover,
                  width: 180,
                  height: 180,
                ),
              ),
      ),
    );
  }
}
