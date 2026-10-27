import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:migra_ayuda/core/utils/validators/address_validator.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_crud_providers.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_providers.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/widgets/dialog/form_bottom_bar.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/widgets/dialog/search_address_button.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/widgets/entity_address_map.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/widgets/entity_image_picker.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/widgets/entity_text_field.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/widgets/section_title.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/widgets/service_type_checklist.dart';
import 'package:migra_ayuda/features/map/presentation/providers/map_providers.dart';

class EntityForm extends ConsumerStatefulWidget {
  final EntityEntity? entity;
  const EntityForm({super.key, this.entity});

  @override
  ConsumerState<EntityForm> createState() => EntityFormState();
}

class EntityFormState extends ConsumerState<EntityForm> {
  static const String _defaultUnavailableText = 'no disponible';

  final _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState> _addressFieldKey =
      GlobalKey<FormFieldState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _scheduleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(imagenSelectProvider.notifier).state = null;
      ref.read(imagenInBytesProvider.notifier).state = null;
    });
    if (widget.entity != null) {
      _populateFields(widget.entity!);
    }
  }

  @override
  void didUpdateWidget(covariant EntityForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.entity != null && oldWidget.entity != widget.entity) {
      _populateFields(widget.entity!);
    }
  }

  void _populateFields(EntityEntity entity) {
    _nameController.text = entity.name;
    _descriptionController.text = entity.description;
    _addressController.text = entity.address;
    _phoneController.text = entity.phone;
    _scheduleController.text = entity.schedule;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(listSelectedServicesFormProviders.notifier).state =
          List<String>.from(entity.services);
          
      ref.read(coordinatesNotifierProvider.notifier).setCoordinate(
            LatLng(
              entity.localitation.latitude,
              entity.localitation.longitude,
            ),
            placeName: entity.address,
          );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _scheduleController.dispose();
    super.dispose();
  }

  void _onSearchAddress() {
    final formatError = AddressValidator.validate(_addressController.text);
    if (formatError != null) {
      _addressFieldKey.currentState?.validate();
      return;
    }
    ref
        .read(coordinatesNotifierProvider.notifier)
        .getCoordinates(_addressController.text.trim());
  }

  void _handleSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _formKey.currentState?.save();

    final geocodingResult = ref.read(coordinatesNotifierProvider).value;
    if (geocodingResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, busca y confirma la ubicación en el mapa.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final imageBytes = ref.read(imagenInBytesProvider);
    final isEdit = widget.entity != null;

    if (!isEdit && imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona una imagen para la entidad.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final selectedServices = ref.read(listSelectedServicesFormProviders);
    final phone = _phoneController.text.trim();
    final schedule = _scheduleController.text.trim();

    final entity = EntityEntity(
      id: isEdit ? widget.entity!.id : '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      services: selectedServices,
      address: _addressController.text.trim(),
      localitation: GeoPoint(
        geocodingResult.point.latitude,
        geocodingResult.point.longitude,
      ),
      phone: phone.isEmpty ? _defaultUnavailableText : phone,
      imageUrl: isEdit ? widget.entity!.imageUrl : '',
      schedule: schedule.isEmpty ? _defaultUnavailableText : schedule,
    );

    final fileName = _buildImageFileName(_nameController.text.trim());

    if (isEdit) {
      ref.read(entitiesCrudProvider.notifier).updateEntity(
            entity: entity,
            imagenBytes: imageBytes,
            fileName: fileName,
          );
    } else {
      ref.read(entitiesCrudProvider.notifier).registerEntity(
            entity: entity,
            imagenBytes: imageBytes!,
            fileName: fileName,
          );
    }
  }

  String _buildImageFileName(String entityName) {
    final sanitizedName = entityName.replaceAll(RegExp(r'\s+'), '_');
    return 'entity_$sanitizedName';
  }

  @override
  Widget build(BuildContext context) {
    final coordinates = ref.watch(coordinatesNotifierProvider);

    /* ref.listen(coordinatesNotifierProvider, (_, __) {
      _addressFieldKey.currentState?.validate();
    }); */

    return Expanded(
        child: Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EntityImagePicker(
                    imagenUrl: widget.entity?.imageUrl,
                  ),
                  const SizedBox(height: 32),
                  const SectionTitle(
                    title: 'Información Básica',
                    icon: Icons.info_outline,
                  ),
                  const SizedBox(height: 20),
                  EntityTextField(
                    controller: _nameController,
                    label: 'Nombre de la Organización',
                    hint: 'Ej: Centro de Salud Norte',
                    icon: Icons.business_outlined,
                    maxLength: 20,
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'El nombre es requerido'
                            : null,
                  ),
                  const SizedBox(height: 20),
                  EntityTextField(
                    controller: _descriptionController,
                    label: 'Descripción',
                    hint:
                        'Describa brevemente los servicios que ofrece esta entidad',
                    icon: null,
                    maxLines: 4,
                    maxLength: 500,
                  ),
                  const SizedBox(height: 32),
                  const SectionTitle(
                    title: 'Tipos de Servicio',
                    icon: Icons.category_outlined,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Seleccione los servicios que ofrece esta Organización (máximo 2)',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const ServiceTypeChecklist(),
                  const SizedBox(height: 32),
                  const SectionTitle(
                    title: 'Ubicación y Contacto',
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 20),
                  EntityTextField(
                    inputKey: _addressFieldKey,
                    controller: _addressController,
                    label: 'Dirección o Punto de Referencia',
                    hint: 'Ej. Calle 18 # 25-30, Pasto o Plaza de Nariño',
                    icon: Icons.location_on_outlined,
                    suffixIcon: SearchAddressButton(
                      isLoading: coordinates.isLoading,
                      onTap: _onSearchAddress,
                    ),
                    validator: (value) {
                      final formatError = AddressValidator.validate(value);
                      if (formatError != null) return formatError;

                      if (coordinates.hasError) {
                        return 'No se encontró la ubicación dentro de Pasto. Verifica la dirección o selecciónala en el mapa.';
                      }

                      if (coordinates.value == null && !coordinates.isLoading) {
                        return 'Debe buscar y confirmar la ubicación en el mapa';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  if (coordinates.value != null) 
                  EntityAddressMap(
                    location: coordinates.value!.point,
                    onLocationChanged: (newPoint) {
                      ref
                          .read(coordinatesNotifierProvider.notifier)
                          .setCoordinate(newPoint, isManual: true);
                    },
                  ),
                  const SizedBox(height: 20),
                  EntityTextField(
                    controller: _phoneController,
                    label: 'Teléfono de contacto',
                    hint: '(57+) 3225321234',
                    icon: Icons.phone_outlined,
                    maxLength: 10,
                    onlyNumbers: true,
                  ),
                  const SizedBox(height: 32),
                  const SectionTitle(
                    title: 'Horario de Atención',
                    icon: Icons.access_time,
                  ),
                  const SizedBox(height: 12),
                  EntityTextField(
                    controller: _scheduleController,
                    label: '',
                    hint: 'Ej. Lunes a viernes 8:30 AM a 12:00 PM',
                    icon: null,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          FormBottomBar(
            onCancel: () => Navigator.pop(context),
            onSave: _handleSubmit,
          ),
        ],
      ),
    ));
  }
}
