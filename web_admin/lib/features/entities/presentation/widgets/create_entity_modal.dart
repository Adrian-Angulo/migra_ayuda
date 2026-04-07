import 'package:flutter/material.dart';

class CreateEntityModal extends StatefulWidget {
  const CreateEntityModal({super.key});

  @override
  State<CreateEntityModal> createState() => _CreateEntityModalState();
}

class _CreateEntityModalState extends State<CreateEntityModal> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  final List<bool> _days = List.filled(7, false);
  final List<String> _dayLabels = ['Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sa', 'Do'];

  TimeOfDay _open1 = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _close1 = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _open2 = const TimeOfDay(hour: 14, minute: 0);
  TimeOfDay _close2 = const TimeOfDay(hour: 18, minute: 0);

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'a. m.' : 'p. m.';
    return '$h:$m $period';
  }

  Future<void> _pickTime(TimeOfDay initial, ValueChanged<TimeOfDay> onPicked) async {
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 16, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Información Básica',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Complete los datos de la nueva entidad',
                            style: TextStyle(color: Colors.black45, fontSize: 13)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.black45),
                  ),
                ],
              ),
            ),
            const Divider(height: 20),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 160,
                          height: 130,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F7F6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black26, width: 1.5),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_outlined, size: 40, color: Colors.black38),
                              SizedBox(height: 8),
                              Text('Agregar Foto', style: TextStyle(color: Colors.black45, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const _Label('Descripción'),
                    const SizedBox(height: 8),
                    _Field(controller: _nameController, hint: 'Nombre entidad'),
                    const SizedBox(height: 16),
                    const _Label('Descripción'),
                    const SizedBox(height: 8),
                    _Field(
                      controller: _descController,
                      hint: 'Describa brevemente los servicios que ofrece esta entidad',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 28),
                    const Text('Ubicación y Contacto',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    const _Label('Dirección'),
                    const SizedBox(height: 8),
                    _Field(
                      controller: _addressController,
                      hint: 'Buscar entidad ...',
                      prefixIcon: const Icon(Icons.search, color: Colors.black38, size: 18),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB2DFDB), Color(0xFFE0F2F1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.location_on_outlined, size: 16),
                        label: const Text('Confirmar ubicación'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _Label('Teléfono de contacto'),
                    const SizedBox(height: 8),
                    _Field(
                      controller: _phoneController,
                      hint: '(57+) 3225321234',
                      prefixIcon: const Icon(Icons.phone_outlined, color: Colors.black38, size: 18),
                    ),
                    const SizedBox(height: 28),
                    const Text('Horario de Atención',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    const Text('Días de atención',
                        style: TextStyle(color: Colors.black45, fontSize: 13)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (i) {
                        return GestureDetector(
                          onTap: () => setState(() => _days[i] = !_days[i]),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _days[i] ? const Color(0xFF6BAF6B) : const Color(0xFFF0F0F0),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _dayLabels[i],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _days[i] ? Colors.white : Colors.black54,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    const Text('Primer Horario',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _TimeField(
                            label: 'Apertura',
                            time: _open1,
                            onTap: () => _pickTime(_open1, (t) => setState(() => _open1 = t)),
                            formatTime: _formatTime,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _TimeField(
                            label: 'Cierre',
                            time: _close1,
                            onTap: () => _pickTime(_close1, (t) => setState(() => _close1 = t)),
                            formatTime: _formatTime,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('Segundo Horario',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _TimeField(
                            label: 'Apertura',
                            time: _open2,
                            onTap: () => _pickTime(_open2, (t) => setState(() => _open2 = t)),
                            formatTime: _formatTime,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _TimeField(
                            label: 'Cierre',
                            time: _close2,
                            onTap: () => _pickTime(_close2, (t) => setState(() => _close2 = t)),
                            formatTime: _formatTime,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6BAF6B),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: const Text('Crear Entidad',
                            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar', style: TextStyle(color: Colors.black54)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) =>
      Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600));
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final Widget? prefixIcon;

  const _Field({required this.controller, required this.hint, this.maxLines = 1, this.prefixIcon});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black26, fontSize: 13),
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;
  final String Function(TimeOfDay) formatTime;

  const _TimeField({required this.label, required this.time, required this.onTap, required this.formatTime});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Icon(Icons.access_time, size: 14, color: Colors.black45),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black45)),
        ]),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFDDDDDD)),
            ),
            child: Text(formatTime(time), style: const TextStyle(fontSize: 13)),
          ),
        ),
      ],
    );
  }
}
