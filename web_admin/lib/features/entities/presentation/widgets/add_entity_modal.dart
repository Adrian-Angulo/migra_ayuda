import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:migra_ayuda_administracion/features/entities/presentation/providers/register_entity_notifier.dart';
import 'package:migra_ayuda_administracion/features/entities/presentation/widgets/button_save_widget.dart';
import 'package:migra_ayuda_administracion/features/entities/presentation/widgets/image_picker_widget.dart';
import 'package:migra_ayuda_administracion/features/entities/presentation/widgets/service_type_checklist_widget.dart';

class AddEntityModal extends ConsumerStatefulWidget {
  const AddEntityModal({super.key});

  @override
  ConsumerState<AddEntityModal> createState() => _AddEntityModalState();
}

class _AddEntityModalState extends ConsumerState<AddEntityModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  LatLng? location;
  final _latitudController = TextEditingController();
  final _longitudController = TextEditingController();
  final _phoneController = TextEditingController();
  final _scheduleController = TextEditingController();
  final _openingTime1Controller = TextEditingController(text: '08:00');
  final _closingTime1Controller = TextEditingController(text: '12:00');
  final _openingTime2Controller = TextEditingController(text: '14:00');
  final _closingTime2Controller = TextEditingController(text: '18:00');
  final _mapController = MapController();
  bool _isSearching = false;
  bool _addressNotFound = false;
  List<String> selectedDays = ['Lu', 'Ma', 'Mi', 'Ju', 'Vi'];
  List<String> selectedServices = [];
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _openingTime1Controller.dispose();
    _closingTime1Controller.dispose();
    _openingTime2Controller.dispose();
    _closingTime2Controller.dispose();
    super.dispose();
  }

  Future<LatLng?> getCoordinates(String address) async {
    final encoded = Uri.encodeComponent(address);
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search'
      '?q=$encoded&format=json&limit=1',
    );

    final response = await http.get(
      url,
      headers: {
        'User-Agent': 'MigraAyuda/1.0', // Nominatim requiere esto
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        return LatLng(
          double.parse(data[0]['lat']),
          double.parse(data[0]['lon']),
        );
      }
    }
    return null;
  }

  Future<void> _searchAddress() async {
    if (_addressController.text.trim().isEmpty) return;
    setState(() {
      _isSearching = true;
      _addressNotFound = false;
    });

    final coords = await getCoordinates(_addressController.text);

    if (!mounted) return;

    setState(() {
      location = coords;
      _isSearching = false;
      _addressNotFound = coords == null;
    });

    if (coords != null) {
      _mapController.move(coords, 15);
    }
  }

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(registerEntityNotifierProvider);

    // Escuchar cambios en el estado del registro
    ref.listen<AsyncValue<void>>(registerEntityNotifierProvider, (
      previous,
      next,
    ) {
      next.when(
        data: (_) {
          // Éxito - cerrar modal y mostrar mensaje
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Entidad registrada exitosamente'),
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
            // Header mejorado
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
                      Icons.business,
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
                          'Nueva Entidad',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Complete los datos de la nueva entidad colaboradora',
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
                              onImageSelected: (imagen, bytes) {
                                setState(() {
                                  _selectedImage = imagen;
                                  _selectedImageBytes = bytes;
                                });
                              },
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tamaño recomendado: 400x400px',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
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
                            child: _buildTextField(
                              controller: _addressController,
                              label: 'Dirección',
                              hint: 'Ej. Calle 123 #45-67, Pasto',
                              icon: Icons.location_on_outlined,
                              onChanged: (_) {
                                if (_addressNotFound) {
                                  setState(() => _addressNotFound = false);
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'La dirección es requerida';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: ElevatedButton(
                              onPressed: _isSearching ? null : _searchAddress,
                              child: _isSearching
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Buscar'),
                            ),
                          ),
                        ],
                      ),
                      if (_addressNotFound)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 14,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'No se encontró la dirección. Intenta ser más específico.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 12),

                      SizedBox(
                        height: 250,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: FlutterMap(
                            mapController: _mapController,
                            options: const MapOptions(
                              initialCenter: LatLng(1.2136, -77.2811),
                              initialZoom: 15,
                              minZoom: 5,
                              maxZoom: 18,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.migraayuda.app',
                              ),
                              MarkerLayer(
                                markers: [
                                  if (location != null)
                                    Marker(
                                      point: location!,
                                      child: const Icon(
                                        Icons.location_pin,
                                        color: Colors.red,
                                        size: 40,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (location != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 14,
                                color: Color(0xFF2D5F4F),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Lat: ${location!.latitude.toStringAsFixed(5)},  Lng: ${location!.longitude.toStringAsFixed(5)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
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

            // Footer mejorado
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
                      onPressed: () => Navigator.pop(context),
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
                    child: ButtonSaveWidget(
                      registerState: registerState,
                      formKey: _formKey,
                      selectedImageBytes: _selectedImageBytes,
                      selectedServices: selectedServices,
                      nameController: _nameController,
                      descriptionController: _descriptionController,
                      addressController: _addressController,
                      latitudController: _latitudController,
                      longitudController: _longitudController,
                      phoneController: _phoneController,
                      scheduleController: _scheduleController,
                      ref: ref,
                      selectedImage: _selectedImage,
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
    void Function(String)? onChanged,
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
          onChanged: onChanged,
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
