import 'package:flutter/material.dart';
import 'package:migra_ayuda_administracion/features/services/presentation/widgets/create_service_modal.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  int _currentPage = 1;

  final List<_ServiceData> _services = const [
    _ServiceData(
      name: 'Primeros auxilios',
      address: 'Av. Libertad 452, Sector Norte',
      icon: Icons.medical_services_outlined,
      iconColor: Color(0xFF4A8C8C),
      iconBg: Color(0xFFE0F2F1),
    ),
    _ServiceData(
      name: 'Ayuntamiento Municipal',
      address: 'Plaza Mayor 1, Centro',
      category: 'Government',
      status: _ServiceStatus.verified,
      icon: Icons.account_balance_outlined,
      iconColor: Color(0xFF3F51B5),
      iconBg: Color(0xFFE8EAF6),
    ),
    _ServiceData(
      name: 'ONG Ayuda Social',
      address: 'Calle Esperanza 88',
      category: 'Non-Profit',
      status: _ServiceStatus.pending,
      icon: Icons.volunteer_activism_outlined,
      iconColor: Color(0xFF7C4DFF),
      iconBg: Color(0xFFEDE7F6),
    ),
    _ServiceData(
      name: 'Centro Educativo',
      address: '',
      icon: Icons.school_outlined,
      iconColor: Color(0xFFE8A020),
      iconBg: Color(0xFFFFF3E0),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF4F7F6),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Servicios', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Gestiona y verifica las alianzas institucionales dentro de MigraAyuda.',
                      style: TextStyle(color: Colors.black54, fontSize: 14)),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const CreateServiceModal(),
                ),
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: const Text('Nuevo Servicio', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6BAF6B),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              children: [
                ..._services.map((s) => _ServiceRow(service: s)).toList(),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      const Text('Showing 4 of 24 Collaborating Organizations',
                          style: TextStyle(color: Colors.black38, fontSize: 12, fontStyle: FontStyle.italic)),
                      const Spacer(),
                      _PaginationControls(
                        currentPage: _currentPage,
                        totalPages: 3,
                        onPageChanged: (p) => setState(() => _currentPage = p),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _ServiceStatus { verified, pending, none }

class _ServiceData {
  final String name;
  final String address;
  final String category;
  final _ServiceStatus status;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const _ServiceData({
    required this.name,
    required this.address,
    this.category = '',
    this.status = _ServiceStatus.none,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });
}

class _ServiceRow extends StatelessWidget {
  final _ServiceData service;
  const _ServiceRow({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0)))),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: service.iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(service.icon, color: service.iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(service.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    if (service.status == _ServiceStatus.verified) ...[
                      const SizedBox(width: 10),
                      _StatusChip(label: 'VERIFIED', color: const Color(0xFF4A8C8C), bg: const Color(0xFFE0F2F1)),
                    ],
                    if (service.status == _ServiceStatus.pending) ...[
                      const SizedBox(width: 10),
                      _StatusChip(label: 'PENDING REVIEW', color: const Color(0xFFE8A020), bg: const Color(0xFFFFF3E0)),
                    ],
                  ],
                ),
                if (service.address.isNotEmpty || service.category.isNotEmpty)
                  const SizedBox(height: 4),
                Row(
                  children: [
                    if (service.address.isNotEmpty) ...[
                      const Icon(Icons.location_on_outlined, size: 13, color: Colors.black38),
                      const SizedBox(width: 2),
                      Text(service.address, style: const TextStyle(fontSize: 12, color: Colors.black45)),
                    ],
                    if (service.category.isNotEmpty) ...[
                      const Text('  ·  ', style: TextStyle(color: Colors.black38)),
                      const Icon(Icons.people_outline, size: 13, color: Colors.black38),
                      const SizedBox(width: 2),
                      Text(service.category, style: const TextStyle(fontSize: 12, color: Colors.black45)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.black45),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  const _StatusChip({required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 7, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const _PaginationControls({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _PageBtn(icon: Icons.chevron_left, onTap: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null),
        ...List.generate(totalPages, (i) {
          final page = i + 1;
          final isActive = page == currentPage;
          return GestureDetector(
            onTap: () => onPageChanged(page),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFE8A020) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: Text('$page',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : Colors.black54,
                  )),
            ),
          );
        }),
        _PageBtn(icon: Icons.chevron_right, onTap: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null),
      ],
    );
  }
}

class _PageBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _PageBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: onTap != null ? Colors.black54 : Colors.black26),
      ),
    );
  }
}