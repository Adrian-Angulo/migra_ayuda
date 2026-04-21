import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:migra_ayuda_administracion/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda_administracion/features/entities/presentation/providers/register_entity_notifier.dart';

class ButtonSaveWidget extends StatelessWidget {
  const ButtonSaveWidget({
    super.key,
    required this.registerState,
    required GlobalKey<FormState> formKey,
    required Uint8List? selectedImageBytes,
    required this.selectedServices,
    required TextEditingController nameController,
    required TextEditingController descriptionController,
    required TextEditingController addressController,
    required TextEditingController latitudController,
    required TextEditingController longitudController,
    required TextEditingController phoneController,
    required TextEditingController scheduleController,
    required this.ref,
    required XFile? selectedImage,
  }) : _formKey = formKey,
       _selectedImageBytes = selectedImageBytes,
       _nameController = nameController,
       _descriptionController = descriptionController,
       _addressController = addressController,
       _latitudController = latitudController,
       _longitudController = longitudController,
       _phoneController = phoneController,
       _scheduleController = scheduleController,
       _selectedImage = selectedImage;

  final AsyncValue<void> registerState;
  final GlobalKey<FormState> _formKey;
  final Uint8List? _selectedImageBytes;
  final List<String> selectedServices;
  final TextEditingController _nameController;
  final TextEditingController _descriptionController;
  final TextEditingController _addressController;
  final TextEditingController _latitudController;
  final TextEditingController _longitudController;
  final TextEditingController _phoneController;
  final TextEditingController _scheduleController;
  final WidgetRef ref;
  final XFile? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: registerState.isLoading
          ? null
          : () {
              if (_formKey.currentState!.validate()) {
                if (_selectedImageBytes == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor seleccione una imagen'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (selectedServices.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Por favor seleccione al menos un servicio',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Crear entidad con los valores del formulario
                final entity = EntityEntity(
                  id: '',
                  name: _nameController.text.trim(),
                  description: _descriptionController.text.trim(),
                  services: selectedServices,
                  address: _addressController.text.trim(),
                  localitation: GeoPoint(
                    double.parse(_latitudController.text),
                    double.parse(_longitudController.text),
                  ),

                  phone: _phoneController.text.trim(),
                  serviceHours: _scheduleController.text.trim(),
                  imageUrl: "",
                );

                // Llamar al notifier (el listener manejará el resultado)
                ref
                    .read(registerEntityNotifierProvider.notifier)
                    .registrar(
                      entity: entity,
                      imagenBytes: _selectedImageBytes!,
                      fileName: _selectedImage!.name,
                    );
              }
            },
      icon: registerState.isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.save, size: 20),
      label: Text(
        registerState.isLoading ? 'Guardando...' : 'Guardar Entidad',
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
        disabledBackgroundColor: Colors.grey.shade400,
      ),
    );
  }
}
