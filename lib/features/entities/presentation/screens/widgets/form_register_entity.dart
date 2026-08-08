import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:migra_ayuda/core/constants/services_utils.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/web/widgets/button_widget.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_crud_providers.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/image_picker_widget.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/service_type_checklist_widget.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/widgets/build_section_title.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/widgets/build_text_field.dart';

class FormRegisterEntity extends ConsumerStatefulWidget {
  /// Si se proporciona, el formulario opera en modo edición prellenando los campos.
  final EntityEntity? entity;

  const FormRegisterEntity({super.key, this.entity});

  bool get isEditing => entity != null;

  @override
  ConsumerState<FormRegisterEntity> createState() => FormRegisterEntityState();
}

class FormRegisterEntityState extends ConsumerState<FormRegisterEntity> {
  /// Expuesto para que el modal padre pueda llamarlo desde el footer.
  void submit() => _submit();

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _addressController;
  late final TextEditingController _latitudController;
  late final TextEditingController _longitudController;
  late final TextEditingController _phoneController;
  late final TextEditingController _scheduleController;

  final _mapController = MapController();
  bool _isSearching = false;
  bool _addressNotFound = false;

  late List<String> selectedServices;
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  bool _imageChanged = false;
  LatLng? location;

  String seleted = services[1];

  @override
  void initState() {
    super.initState();
    final e = widget.entity;

    _nameController = TextEditingController(text: e?.name ?? '');
    _descriptionController = TextEditingController(text: e?.description ?? '');
    _addressController = TextEditingController(text: e?.address ?? '');
    _latitudController = TextEditingController(
      text: e != null ? e.localitation.latitude.toString() : '',
    );
    _longitudController = TextEditingController(
      text: e != null ? e.localitation.longitude.toString() : '',
    );
    _phoneController = TextEditingController(text: e?.phone ?? '');
    _scheduleController = TextEditingController(text: e?.schedule ?? '');
    selectedServices = e != null ? List.from(e.services) : [];

    // Inicializar mapa si hay coordenadas
    if (e != null) {
      location = LatLng(e.localitation.latitude, e.localitation.longitude);
    }
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

  Future<LatLng?> _getCoordinates(String address) async {
    try {
      final encoded = Uri.encodeComponent(address);
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=$encoded&format=json&limit=1',
      );
      final response = await http.get(url, headers: {
        'User-Agent': 'MigraAyuda Flutter App',
        'Accept': 'application/json',
      });
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
      debugPrint('ERROR: $e');
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
    final coords = await _getCoordinates(_addressController.text);
    if (!mounted) return;
    setState(() {
      location = coords;
      _isSearching = false;
      _addressNotFound = coords == null;
    });
    if (coords != null) {
      _latitudController.text = coords.latitude.toString();
      _longitudController.text = coords.longitude.toString();
    }
  }

  /// Valida y ejecuta la operación (crear o actualizar).
  /// El cierre del modal es responsabilidad del padre via [ref.listen].
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Imagen obligatoria solo al crear
    if (!widget.isEditing && _selectedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Por favor seleccione una imagen'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    if (selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Por favor seleccione al menos un servicio'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    if (_latitudController.text.isEmpty || _longitudController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Debes buscar y confirmar la dirección en el mapa'),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    final notifier = ref.read(entitiesCrudProvider.notifier);

    if (widget.isEditing) {
      final updated = EntityEntity(
        id: widget.entity!.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        services: selectedServices,
        address: _addressController.text.trim(),
        localitation: GeoPoint(
          double.parse(_latitudController.text),
          double.parse(_longitudController.text),
        ),
        phone: _phoneController.text.trim(),
        imageUrl: widget.entity!.imageUrl,
        schedule: _scheduleController.text.trim(),
      );
      await notifier.updateEntity(
        entity: updated,
        imagenBytes: _selectedImageBytes,
        fileName: _selectedImage?.name,
      );
    } else {
      final newEntity = EntityEntity(
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
        imageUrl: '',
        schedule: _scheduleController.text.trim(),
      );
      await notifier.registerEntity(
        entity: newEntity,
        imagenBytes: _selectedImageBytes!,
        fileName: _selectedImage?.name ?? '',
      );
    }
    // El modal escucha entitiesCrudProvider y se cierra solo.
    // En mobile (sin modal) cerramos aquí.
    if (!kIsWeb && mounted) {
      final state = ref.read(entitiesCrudProvider);
      if (state.hasValue && !state.hasError) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return _buildForm();
    return Scaffold(
      appBar: AppBar(title: const Text('Completar información')),
      body: _buildForm(),
    );
  }

  Expanded _buildForm() {
    final crudState = ref.watch(entitiesCrudProvider);

    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Imagen ───────────────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    ImagePickerWidget(
                      imagen: _selectedImage,
                      imagenBytes: _selectedImageBytes,
                      existingImageUrl:
                          _imageChanged ? null : widget.entity?.imageUrl,
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
                      widget.isEditing
                          ? (_imageChanged
                              ? 'Nueva imagen seleccionada'
                              : 'Imagen actual — selecciona una nueva para cambiar')
                          : 'Tamaño recomendado: 400x400px',
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

              // ── Información básica ───────────────────────────────────
              const BuildSectionTitle(
                title: 'Información Básica',
                icon: Icons.info_outline,
              ),
              const SizedBox(height: 20),
              BuildTextField(
                controller: _nameController,
                label: 'Nombre de la entidad',
                hint: 'Ej: Centro de Salud Norte',
                icon: Icons.business_outlined,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'El nombre es requerido' : null,
              ),
              const SizedBox(height: 20),
              BuildTextField(
                controller: _descriptionController,
                label: 'Descripción',
                hint:
                    'Describa brevemente los servicios que ofrece esta entidad',
                icon: null,
                maxLines: 4,
              ),
              const SizedBox(height: 32),

              // ── Tipos de servicio ────────────────────────────────────
              const BuildSectionTitle(
                title: 'Tipos de Servicio',
                icon: Icons.category_outlined,
              ),
              const SizedBox(height: 12),
              Text(
                'Seleccione los servicios que ofrece esta entidad (máximo 2)',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              ServiceTypeChecklistWidget(
                selectedServices: selectedServices,
                onServicesChanged: (s) => setState(() => selectedServices = s),
              ),
              const SizedBox(height: 32),

              // ── Ubicación y contacto ─────────────────────────────────
              const BuildSectionTitle(
                title: 'Ubicación y Contacto',
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 20),
              BuildTextField(
                controller: _addressController,
                label: 'Dirección',
                hint: 'Ej. Calle 123 #45-67, Pasto',
                icon: Icons.location_on_outlined,
                suffixIcon: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(11),
                      bottomRight: Radius.circular(11),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isSearching ? null : _searchAddress,
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Center(
                          child: _isSearching
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.search, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                onChanged: (_) {
                  if (_addressNotFound)
                    setState(() => _addressNotFound = false);
                  if (location != null) {
                    setState(() {
                      location = null;
                      _latitudController.clear();
                      _longitudController.clear();
                    });
                  }
                },
                validator: (v) => (v == null || v.isEmpty)
                    ? 'La dirección es requerida'
                    : null,
              ),
              if (_addressNotFound)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          size: 14, color: Colors.red),
                      const SizedBox(width: 6),
                      Text(
                        'No se encontró la dirección. Intenta ser más específico.',
                        style:
                            TextStyle(fontSize: 12, color: Colors.red.shade700),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              if (location != null)
                SizedBox(
                  height: 250,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: location!,
                        initialZoom: 14,
                        minZoom: 14,
                        maxZoom: 14,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.migraayuda.app',
                        ),
                        MarkerLayer(
                          markers: [
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
              const SizedBox(height: 20),
              BuildTextField(
                controller: _phoneController,
                label: 'Teléfono de contacto',
                hint: '(57+) 3225321234',
                icon: Icons.phone_outlined,
                validator: (v) => (v == null || v.isEmpty)
                    ? 'El teléfono es requerido'
                    : null,
              ),
              const SizedBox(height: 32),

              // ── Horario ──────────────────────────────────────────────
              const BuildSectionTitle(
                title: 'Horario de Atención',
                icon: Icons.access_time,
              ),
              const SizedBox(height: 12),
              BuildTextField(
                controller: _scheduleController,
                label: '',
                hint: 'Ej. Lunes a viernes 8:30 AM a 12:00 PM',
                icon: null,
                maxLines: 4,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'El horario es requerido' : null,
              ),
              const SizedBox(height: 32),

              // ── Botón solo en mobile ─────────────────────────────────
              if (!kIsWeb)
                ButtonWidget(
                  formKey: _formKey,
                  text: crudState.isLoading
                      ? (widget.isEditing
                          ? 'Actualizando...'
                          : 'Registrando...')
                      : (widget.isEditing ? 'Guardar Cambios' : 'Registrarse'),
                  onPressed: crudState.isLoading ? null : _submit,
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
