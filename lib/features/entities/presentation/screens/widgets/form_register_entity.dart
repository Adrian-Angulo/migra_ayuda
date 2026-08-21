
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:migra_ayuda/core/constants/services_utils.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/button_save_widget.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/image_picker_widget.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/service_type_checklist_widget.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/widgets/build_section_title.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/widgets/build_text_field.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/widgets/container_map_address.dart';

class FormRegisterEntity extends ConsumerStatefulWidget {
  /// Si se proporciona, el formulario opera en modo edición prellenando los campos.

  const FormRegisterEntity({super.key});

  @override
  ConsumerState<FormRegisterEntity> createState() => FormRegisterEntityState();
}

class FormRegisterEntityState extends ConsumerState<FormRegisterEntity> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _nameController = TextEditingController();
  late final TextEditingController _descriptionController =
      TextEditingController();
  late final TextEditingController _addressController = TextEditingController();
  late final TextEditingController _latitudController = TextEditingController();
  late final TextEditingController _longitudController =
      TextEditingController();
  late final TextEditingController _phoneController = TextEditingController();
  late final TextEditingController _scheduleController =
      TextEditingController();
  bool _addressNotFound = false;
  late List<String>? selectedServices;
  LatLng? location;
  String seleted = services[1];
  String? _servicesErrorMsg;

  @override
  void initState() {
    super.initState();
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
    return Expanded(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Imagen ───────────────────────────────────────────────
                    const ImagePickerWidget(),

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
                      maxLength: 20,
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'El nombre es requerido'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    BuildTextField(
                      controller: _descriptionController,
                      label: 'Descripción',
                      hint:
                          'Describa brevemente los servicios que ofrece esta entidad',
                      icon: null,
                      maxLines: 4,
                      maxLength: 500,
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
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 16),

                     const ServiceTypeChecklistWidget(
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
                      suffixIcon: Builder(
                        builder: (context) {
                          return Container(
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
                                onTap: () async {},
                                child: const SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: Center(
                                    child:
                                        Icon(Icons.search, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      onChanged: (_) {
                        if (location != null) {
                          setState(() {
                            location = null;
                            _latitudController.clear();
                            _longitudController.clear();
                            _addressNotFound = false;
                          });
                        }
                      },
                      validator: (v) {
                        // Validar formato
                        final regExp = RegExp(
                          r'^(Calle|Carrera)\s+\d+\s*#\d+-\d+,\s*Pasto$',
                          caseSensitive: false,
                        );

                        if (v == null || v.isEmpty) {
                          return 'La dirección es requerida';
                        } else if (!regExp.hasMatch(v.trim())) {
                          return 'La dirección debe tener el formato: Calle/Carrera 123 #45-67, Pasto';
                        } else if (location == null) {
                          return 'Haz clic en el botón de la lupa para buscar y confirmar la dirección';
                        } else if (_addressNotFound) {
                          return 'No se encontró la ubicación para esta dirección. Por favor, verifica que esté escrita correctamente e intenta de nuevo.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    //Mostrar imagen del mapa cuando se realice la busqueda
                    if (location != null)
                      ContainerMapAddress(location: location),

                    const SizedBox(height: 20),
                    BuildTextField(
                      controller: _phoneController,
                      label: 'Teléfono de contacto',
                      hint: '(57+) 3225321234',
                      icon: Icons.phone_outlined,
                      maxLength: 10,
                      onlyNumbers: true,
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
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'El horario es requerido'
                          : null,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
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
                      onPressed: () {
                        //TODO: VALIDAR IMAGEN NO SELECCIONADA
                        if (!_formKey.currentState!.validate()) return;
                        _formKey.currentState!.save();

                        
                       /*  final imagenbytes = ref.read(imagenInBytesProvider);
                        final selectServices = ref.read(selectServiceProvider);
                        final entity = EntityEntity(id: '', name: _nameController.text.trim(), description: _descriptionController.text.trim(), services: services, address: address, localitation: localitation, phone: phone, imageUrl: imageUrl, schedule: schedule)

                        ref.read(entitiesCrudProvider.notifier).registerEntity(entity: entity, imagenBytes: imagenBytes, fileName: fileName)
 */
                      },
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
