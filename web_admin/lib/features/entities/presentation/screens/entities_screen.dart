import 'package:flutter/material.dart';
import 'package:migra_ayuda_administracion/features/entities/presentation/widgets/create_entity_modal.dart';

class EntitiesScreen extends StatefulWidget {
  const EntitiesScreen({super.key});

  @override
  State<EntitiesScreen> createState() => _EntitiesScreenState();
}

class _EntitiesScreenState extends State<EntitiesScreen> {
  int _currentPage = 1;

  final List<_EntityData> _entities = const [
    _EntityData(
      name: 'Club Kiwanis nubes verdes',
      address: 'CALLE 12 #3-77',
      rating: 4.9,
      services: ['Alimentación', 'Kit Higiene'],
    ),
    _EntityData(
      name: 'Fundación Proinco',
      address: 'CALLE 8 NO, CRA. 22 F #85',
      rating: 4.8,
      services: ['Respuesta nutricional'],
    ),
    _EntityData(
      name: 'Pastoral Social - Cáritas Pasto',
      address: 'DIÓCESIS DE PASTO',
      rating: 4.9,
      services: ['Atención psicosocial', 'Albergue temporal'],
    ),
    _EntityData(
      name: 'Servicio Jesuita a Refugiados Colombia',
      address: 'CALLE 20 #24-64',
      rating: 4.7,
      services: ['Protección y accesibilidad a derechos'],
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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Entidades', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Manage and verify institutional partnerships within the MigraAyuda network.',
                      style: TextStyle(color: Colors.black54, fontSize: 14)),
                ],
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.filter_list, size: 16),
                label: const Text('Filtro'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  side: const BorderSide(color: Colors.black26),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const CreateEntityModal(),
                ),
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: const Text('Nueva Entidad', style: TextStyle(color: Colors.white)),
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
                // Header row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      const Expanded(flex: 3, child: _HeaderCell('ENTIDAD')),
                      const Expanded(flex: 2, child: _HeaderCell('DIRECCIÓN')),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            const _HeaderCell('VALORACIÓN'),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (_) =>
                                  const Icon(Icons.star, color: Colors.amber, size: 14)),
                            ),
                          ],
                        ),
                      ),
                      const Expanded(flex: 2, child: _HeaderCell('SERVICIO')),
                      const Expanded(flex: 1, child: _HeaderCell('ACCIONES')),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                ..._entities.map((e) => _EntityRow(entity: e)).toList(),
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

class _EntityData {
  final String name;
  final String address;
  final double rating;
  final List<String> services;

  const _EntityData({
    required this.name,
    required this.address,
    required this.rating,
    required this.services,
  });
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black45, letterSpacing: 0.8));
  }
}

class _EntityRow extends StatelessWidget {
  final _EntityData entity;
  const _EntityRow({required this.entity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0)))),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFE0E0E0),
                  child: const Icon(Icons.business, color: Colors.grey, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(entity.name,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFA5D6A7)),
                ),
                child: Text(entity.address,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF388E3C), fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${entity.rating}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF388E3C))),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: entity.services
                  .map((s) => Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFA5D6A7)),
                        ),
                        child: Text(s,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF388E3C), fontWeight: FontWeight.w500)),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.black45)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const _PaginationControls({required this.currentPage, required this.totalPages, required this.onPageChanged});

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
                  style: TextStyle(fontWeight: FontWeight.w600, color: isActive ? Colors.white : Colors.black54)),
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
        decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(6)),
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: onTap != null ? Colors.black54 : Colors.black26),
      ),
    );
  }
}
