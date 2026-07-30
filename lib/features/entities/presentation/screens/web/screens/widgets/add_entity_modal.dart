import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:migra_ayuda/core/constants/services_utils.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/button_save_widget.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/image_picker_widget.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/service_type_checklist_widget.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/widgets/form_register_entity.dart';

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

  final _mapController = MapController();
  bool _isSearching = false;
  bool _addressNotFound = false;

  List<String> selectedServices = [];
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;

  String seleted = services[1];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  Future<LatLng?> getCoordinates(String address) async {
    try {
      final encoded = Uri.encodeComponent(address);

      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=$encoded&format=json&limit=1',
      );

      debugPrint("Consultando: $url");

      final response = await http.get(url);

      debugPrint("Status: ${response.statusCode}");
      debugPrint(response.body);

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
    } catch (e, s) {
      debugPrint("ERROR:");
      debugPrint(e.toString());

      debugPrint("STACK:");
      debugPrintStack(stackTrace: s);

      rethrow;
    }
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
      _latitudController.text = coords.latitude.toString();
      _longitudController.text = coords.longitude.toString();
      //_mapController.move(coords, 15);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            const FormRegisterEntity(),

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
}
