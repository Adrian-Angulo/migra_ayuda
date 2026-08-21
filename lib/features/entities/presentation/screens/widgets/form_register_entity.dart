
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:migra_ayuda/core/constants/services_utils.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_crud_providers.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/providers/form_add_providers.dart';
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
  final GlobalKey<FormFieldState> _addressFieldKey = GlobalKey<FormFieldState>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _latitudController = TextEditingController();
  final TextEditingController _longitudController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _scheduleController =
      TextEditingController();

  bool? errorCoridenates;

  



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
    final cordinates = ref.watch(geocodingProvider);

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

                     const ServiceTypeChecklistWidget(), 
                    
                    const SizedBox(height: 32), 

                    // ── Ubicación y contacto ─────────────────────────────────
                    const BuildSectionTitle(
                      title: 'Ubicación y Contacto',
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 20),
                    BuildTextField(
                      inputKey: _addressFieldKey,
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
                                onTap: ()  {
                                  //TODO: IMPLEMENTAR FUNCION DE BUSQUEDA
                                  ref.read(geocodingProvider.notifier).search(_addressController.text.trim());
                                  _addressFieldKey.currentState!.validate();
                                  
                                },
                                child:  SizedBox(
                                  width: 48,
                                  height: 48,
                                  child:  Center(
                                    child: cordinates.isLoading ? const CircularProgressIndicator()  :
                                        const Icon(Icons.search, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      validator: (v) {
                        // Validar formato
                        final regExp = RegExp(
                          r'^(Calle|Carrera)\s+\d+\s*#\d+-\d+,\s*Pasto$',
                          caseSensitive: false,
                        );
                        if (v == null || v.isEmpty ) {
                          return 'La dirección es requerida';
                        } else if (!regExp.hasMatch(v.trim())) {
                          return 'La dirección debe tener el formato: Calle/Carrera 123 #45-67, Pasto';
                        } else if (cordinates.value == null) {
                          return 'No se encontró la ubicación para esta dirección. Por favor, verifica que esté escrita correctamente e intenta de nuevo.';
                        } else if(cordinates.hasError){
                          return 'Ha ocurrido un error inesperado';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    if (cordinates.value != null)
                      ContainerMapAddress(location: cordinates.value),

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

                        
                        final imagenbytes = ref.read(imagenInBytesProvider);
                        final selectServices = ref.read(listSelectedServicesFormProviders);
                       // final entity = EntityEntity(id: '', name: _nameController.text.trim(), description: _descriptionController.text.trim(), services: selectServices, address: _addressController.text.trim(), localitation: localitation, phone: _phoneController.text.trim(), imageUrl: , schedule: _scheduleController.text.trim())
                       // ref.read(entitiesCrudProvider.notifier).registerEntity(entity: entity, imagenBytes: imagenbytes!, fileName: 'Abc${_nameController.text}');

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
