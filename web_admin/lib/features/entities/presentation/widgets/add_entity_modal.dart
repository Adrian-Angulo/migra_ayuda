import 'package:flutter/material.dart';
import 'package:migra_ayuda_administracion/features/entities/presentation/widgets/image_picker_widget.dart';
import 'package:migra_ayuda_administracion/features/entities/presentation/widgets/day_selector_widget.dart';
import 'package:migra_ayuda_administracion/features/entities/presentation/widgets/time_input_widget.dart';
import 'package:migra_ayuda_administracion/features/entities/presentation/widgets/service_type_checklist_widget.dart';

class AddEntityModal extends StatefulWidget {
  const AddEntityModal({super.key});

  @override
  State<AddEntityModal> createState() => _AddEntityModalState();
}

class _AddEntityModalState extends State<AddEntityModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _openingTime1Controller = TextEditingController(text: '08:00');
  final _closingTime1Controller = TextEditingController(text: '12:00');
  final _openingTime2Controller = TextEditingController(text: '14:00');
  final _closingTime2Controller = TextEditingController(text: '18:00');

  List<String> selectedDays = ['Lu', 'Ma', 'Mi', 'Ju', 'Vi'];
  List<String> selectedServices = [];

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
              color: Colors.black.withOpacity(0.1),
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
                      color: Colors.white.withOpacity(0.2),
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
                            color: Colors.white.withOpacity(0.9),
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
                      backgroundColor: Colors.white.withOpacity(0.2),
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
                      // Image Picker mejorado
                      Center(
                        child: Column(
                          children: [
                            const ImagePickerWidget(),
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

                      // Descripción Section con diseño mejorado
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
                        icon: Icons.description_outlined,
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
                      _buildTextField(
                        controller: _addressController,
                        label: 'Dirección',
                        hint: 'Buscar dirección...',
                        icon: Icons.search,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'La dirección es requerida';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Map Placeholder mejorado
                      Container(
                        height: 180,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF2D5F4F).withOpacity(0.1),
                              const Color(0xFF10B981).withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.map_outlined,
                                  size: 32,
                                  color: Color(0xFF2D5F4F),
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () {
                                  // TODO: Abrir mapa
                                },
                                icon: const Icon(Icons.location_on, size: 18),
                                label: const Text('Seleccionar en el mapa'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2D5F4F),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                      const SizedBox(height: 12),
                      Text(
                        'Días de atención',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DaySelectorWidget(
                        selectedDays: selectedDays,
                        onDaysChanged: (days) {
                          setState(() {
                            selectedDays = days;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // Horarios en cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildScheduleCard(
                              'Primer Horario',
                              _openingTime1Controller,
                              _closingTime1Controller,
                              const Color(0xFF3B82F6),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildScheduleCard(
                              'Segundo Horario',
                              _openingTime2Controller,
                              _closingTime2Controller,
                              const Color(0xFF8B5CF6),
                            ),
                          ),
                        ],
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
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // TODO: Guardar entidad
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(width: 12),
                                  Text('Entidad guardada exitosamente'),
                                ],
                              ),
                              backgroundColor: Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.save, size: 20),
                      label: const Text(
                        'Guardar Entidad',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
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
            color: const Color(0xFF2D5F4F).withOpacity(0.1),
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
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
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

  Widget _buildScheduleCard(
    String title,
    TextEditingController openingController,
    TextEditingController closingController,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: accentColor),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TimeInputWidget(label: 'Apertura', controller: openingController),
          const SizedBox(height: 12),
          TimeInputWidget(label: 'Cierre', controller: closingController),
        ],
      ),
    );
  }
}
