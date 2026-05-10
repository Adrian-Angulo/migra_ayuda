import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/update_entity_notifier.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/image_picker_widget.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/service_type_checklist_widget.dart';

class EditEntityModal extends ConsumerStatefulWidget {
  final EntityEntity entity;

  const EditEntityModal({super.key, required this.entity});

  @override
  ConsumerState<EditEntityModal> createState() => _EditEntityModalState();
}

class _EditEntityModalState extends ConsumerState<EditEntityModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _latitudController;
  late TextEditingController _longitudController;
  late TextEditingController _phoneController;
  late TextEditingController _scheduleController;

  late List<String> selectedServices;
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  bool _imageChanged = false;

  @override
  void initState() {
    super.initState();
    // Inicializar controladores con los datos de la entidad
    _nameController = TextEditingController(text: widget.entity.name);
    _descriptionController = TextEditingController(
      text: widget.entity.description,
    );
    _addressController = TextEditingController(text: widget.entity.address);
    _latitudController = TextEditingController(
      text: widget.entity.localitation.latitude.toString(),
    );
    _longitudController = TextEditingController(
      text: widget.entity.localitation.longitude.toString(),
    );
    _phoneController = TextEditingController(text: widget.entity.phone);
    _scheduleController = TextEditingController(
      text: widget.entity.serviceHours,
    );

    selectedServices = List.from(widget.entity.services);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _latitudController.dispose();
    _longitudController.dispose();
    _phoneController.dispose();
    _scheduleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final updateState = ref.watch(updateEntityNotifierProvider);

    // Escuchar cambios en el estado de actualización
    ref.listen<AsyncValue<void>>(updateEntityNotifierProvider, (
      previous,
      next,
    ) {
      next.when(
        data: (_) {
          // Éxito - cerrar modal y mostrar mensaje
          Navigator.of(context).pop(true); // Retornar true para indicar éxito
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Entidad actualizada exitosamente'),
                ],
              ),
              backgroundColor: Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        loading: () {}, // No hacer nada mientras carga
        error: (error, stack) {
          // Error - mostrar mensaje
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Error: ${error.toString()}')),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    });

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 700,
        constraints: const BoxConstraints(maxHeight: 850),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2D5F4F), Color(0xFF1E4438)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Editar Entidad',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Actualice la información de la entidad',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: Colors.white,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            ImagePickerWidget(
                              imagen: _selectedImage,
                              imagenBytes: _selectedImageBytes,
                              existingImageUrl: _imageChanged
                                  ? null
                                  : widget.entity.imageUrl,
                              onImageSelected: (imagen, bytes) {
                                setState(() {
                                  _selectedImage = imagen;
                                  _selectedImageBytes = bytes;
                                  _imageChanged = true;
                                });
                              },
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _imageChanged
                                  ? 'Nueva imagen seleccionada'
                                  : 'Imagen actual - Seleccione una nueva para cambiar',
                              style: TextStyle(
                                fontSize: 12,
                                color: _imageChanged
                                    ? const Color(0xFF10B981)
                                    : Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      _buildSectionTitle(
                        'Información Básica',
                        Icons.info_outline,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _nameController,
                        label: 'Nombre de la entidad',
                        hint: 'Ej: Centro de Salud Norte',
                        icon: Icons.business_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El nombre es requerido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Descripción',
                        hint:
                            'Describa brevemente los servicios que ofrece esta entidad',
                        icon: null,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 32),

                      // Tipos de Servicio Section
                      _buildSectionTitle(
                        'Tipos de Servicio',
                        Icons.category_outlined,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Seleccione los servicios que ofrece esta entidad',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ServiceTypeChecklistWidget(
                        selectedServices: selectedServices,
                        onServicesChanged: (services) {
                          setState(() {
                            selectedServices = services;
                          });
                        },
                      ),
                      const SizedBox(height: 32),

                      // Ubicación y Contacto Section
                      _buildSectionTitle(
                        'Ubicación y Contacto',
                        Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        spacing: 16,
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildTextField(
                              controller: _addressController,
                              label: 'Dirección',
                              hint: 'Ej. Calle 123 #45-67, Pasto',
                              icon: Icons.location_on_outlined,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'La dirección es requerida';
                                }
                                return null;
                              },
                            ),
                          ),
                          Expanded(
                            child: _buildTextField(
                              controller: _latitudController,
                              label: 'Latitud',
                              hint: 'Ej. 1.21456',
                              icon: Icons.location_on_outlined,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Requerida';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Formato inválido';
                                }
                                return null;
                              },
                            ),
                          ),
                          Expanded(
                            child: _buildTextField(
                              controller: _longitudController,
                              label: 'Longitud',
                              hint: 'Ej. -77.27846',
                              icon: Icons.location_on_outlined,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Requerida';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Formato inválido';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Teléfono de contacto',
                        hint: '(57+) 3225321234',
                        icon: Icons.phone_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El teléfono es requerido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Horario de Atención
                      _buildSectionTitle(
                        'Horario de Atención',
                        Icons.access_time,
                      ),

                      _buildTextField(
                        controller: _scheduleController,
                        label: '',
                        hint: 'Ej. Lunes a viernes 8:30 AM a 12:00 PM',
                        icon: null,
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El horario es requerido';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: updateState.isLoading
                          ? null
                          : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: updateState.isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
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

                                // Crear entidad actualizada
                                final updatedEntity = EntityEntity(
                                  id: widget.entity.id,
                                  name: _nameController.text.trim(),
                                  description: _descriptionController.text
                                      .trim(),
                                  services: selectedServices,
                                  address: _addressController.text.trim(),
                                  localitation: GeoPoint(
                                    double.parse(_latitudController.text),
                                    double.parse(_longitudController.text),
                                  ),
                                  phone: _phoneController.text.trim(),
                                  serviceHours: _scheduleController.text.trim(),
                                  imageUrl: widget.entity.imageUrl,
                                );

                                // Llamar al notifier
                                ref
                                    .read(updateEntityNotifierProvider.notifier)
                                    .actualizar(
                                      entity: updatedEntity,
                                      imagenBytes: _selectedImageBytes,
                                      fileName: _selectedImage?.name,
                                    );
                              }
                            },
                      icon: updateState.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.save, size: 20),
                      label: Text(
                        updateState.isLoading
                            ? 'Actualizando...'
                            : 'Guardar Cambios',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D5F4F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF2D5F4F).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF2D5F4F)),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData? icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
        if (label.isNotEmpty) const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: icon != null
                ? Icon(icon, color: Colors.grey.shade400, size: 20)
                : null,
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF2D5F4F), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
