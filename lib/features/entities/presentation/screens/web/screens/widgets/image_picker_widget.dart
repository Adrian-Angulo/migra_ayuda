import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

import 'package:migra_ayuda/features/entities/presentation/screens/web/providers/form_add_providers.dart';

/// Widget personalizado para seleccionar e indicar imágenes mediante la galería del dispositivo.
/// Puede manejar una imagen local seleccionada, bytes de imagen, o una URL de imagen remota existente.
/// También permite notificar al widget padre cuando una nueva imagen ha sido elegida.
class ImagePickerWidget extends ConsumerStatefulWidget {
  const ImagePickerWidget({
    super.key,
  });

  @override
  ConsumerState<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends ConsumerState<ImagePickerWidget> {
  final picker = ImagePicker();
  XFile? imagen;
  Uint8List? imagenBytes;

  @override
  void initState() {
    super.initState();
  }

  /// Abre la galería del usuario y permite seleccionar una imagen.
  /// Si se selecciona, actualiza el estado y notifica al padre si es necesario.
  Future<void> _elegirImagen() async {
    //elegir imagen de la galeria
    final resultado = await picker.pickImage(source: ImageSource.gallery);
    if (resultado == null) return; // si el usuario cancela la operacion
     final bytes = await resultado.readAsBytes();
    setState(() {
      imagen = resultado;
      imagenBytes = bytes;
    });

/*     ref.read(imagenSelectProvider.notifier).state = resultado;
    ref.read(imagenInBytesProvider.notifier).state = bytes; */
  }

  @override
  Widget build(BuildContext context) {
    // InkWell para detectar taps y mostrar un feedback visual táctil
    
    

    return FormField<XFile?>(
      initialValue: imagen,
      validator: (value) {
        if (value == null) return 'Debes seleccionar una imagen';
        ref.read(imagenSelectProvider.notifier).state = imagen;
        ref.read(imagenInBytesProvider.notifier).state = imagenBytes;
        return null;
      },
      builder: (field) =>  Center(
        child: Column(
          children: [
            InkWell(
              onTap: _elegirImagen,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 400, // Ancho fijo de la caja de la imagen
                height: 300, // Alto fijo de la caja de la imagen
                decoration: BoxDecoration(
                  border: Border.all(color: field.hasError ? Colors.red : Colors.grey.shade400, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
      
                child: imagen != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          imagenBytes!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      )
                    : _buildPlaceholder(),
              ),
            ),
            const SizedBox(height: 8),
            Text( field.hasError ? field.errorText! :
              'Tamaño recomendado: 400x400px',
              style: TextStyle(
                fontSize: 12,
                color: field.hasError ? Colors.red :  Colors.grey.shade500,
              ),
            ),
            // Error de imagen como validación de formulario
           
          ],
        ),
      ),
    );
  }

  /// Widget placeholder: se muestra cuando todavía no hay ninguna imagen seleccionada
  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.image_outlined, size: 48, color: Colors.grey.shade400),
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
    );
  }
}
