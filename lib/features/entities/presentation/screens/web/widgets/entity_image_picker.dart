import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_crud_providers.dart';

class EntityImagePicker extends ConsumerStatefulWidget {
  final String? imagenUrl;

  const EntityImagePicker({
    super.key,
    this.imagenUrl,
  });

  @override
  ConsumerState<EntityImagePicker> createState() => _EntityImagePickerState();
}

class _EntityImagePickerState extends ConsumerState<EntityImagePicker> {
  final _picker = ImagePicker();
  XFile? _imagen ;
  Uint8List? _imagenBytes;

  Future<void> _elegirImagen(FormFieldState<XFile?> field) async {
    final resultado = await _picker.pickImage(source: ImageSource.gallery);
    if (resultado == null) return;
    final bytes = await resultado.readAsBytes();
    setState(() {
      _imagen = resultado;
      _imagenBytes = bytes;
    });
    ref.read(imagenSelectProvider.notifier).state = resultado;
    ref.read(imagenInBytesProvider.notifier).state = bytes;
    field.didChange(resultado);
  }

  @override
  Widget build(BuildContext context) {
    return FormField<XFile?>(
      initialValue: _imagen,
      validator: (value) {
        if (value == null &&
            (widget.imagenUrl == null || widget.imagenUrl!.isEmpty)) {
          return 'Debes seleccionar una imagen';
        }
        return null;
      },
      builder: (field) => Center(
        child: Column(
          children: [
            InkWell(
              onTap: () => _elegirImagen(field),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 400,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: field.hasError ? Colors.red : Colors.grey.shade400,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _buildImageToShow(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              field.hasError
                  ? field.errorText!
                  : 'Tamaño recomendado: 400x400px',
              style: TextStyle(
                fontSize: 12,
                color: field.hasError ? Colors.red : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageToShow() {
    if (_imagen != null && _imagenBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(
          _imagenBytes!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    } else if (widget.imagenUrl != null && widget.imagenUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          widget.imagenUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      );
    } else {
      return _buildPlaceholder();
    }
  }

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
