import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';

// Mock data para preview
const _mockEntity = EntityEntity(
  id: '1',
  name: 'Fundacion Kiwanis',
  description:
      'Se ofrece el servicio de alimentacion para la personas que se encuentre en situacion de vulnerabilidad',
  services: ['Comida'],
  address: 'Calle 24 #32-12',
  localitation: GeoPoint(1.2136, -77.2811),
  phone: '+57 3232386890',
  serviceHours: 'Lun-Vie 8:00 AM - 12:00 PM',
  imageUrl: '',
);

class PlaceDetails extends StatelessWidget {
  final EntityEntity entity;
  final double? distanceKm;

  const PlaceDetails({
    super.key,
    this.entity = _mockEntity,
    this.distanceKm,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _PlaceAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PlaceHeroImage(imageUrl: entity.imageUrl),
            const SizedBox(height: 16),
            _PlaceHeader(
              name: entity.name,
              rating: 4.4,
              reviewCount: 20,
              service: entity.services.isNotEmpty ? entity.services.first : '',
              distanceKm: distanceKm,
            ),
            const SizedBox(height: 16),
            _PlaceDescription(description: entity.description),
            const SizedBox(height: 16),
            _PlaceScheduleCard(),
            const SizedBox(height: 16),
            _PlaceContactCard(
              icon: Icons.phone_outlined,
              label: 'Teléfono',
              value: entity.phone,
            ),
            const SizedBox(height: 12),
            _PlaceContactCard(
              icon: Icons.location_on_outlined,
              label: 'Dirección',
              value: entity.address,
            ),
            const SizedBox(height: 28),
            const _ReviewsSection(),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _PlaceDirectionsButton(),
      ),
    );
  }
}

// ── AppBar ────────────────────────────────────────────────────────────────────
class _PlaceAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: Color(0xFF1A1A1A)),
        ),
      ),
      title: const Text(
        'Detalles de la entidad',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A1A),
        ),
      ),
    );
  }
}

// ── Imagen hero ───────────────────────────────────────────────────────────────
class _PlaceHeroImage extends StatelessWidget {
  final String imageUrl;

  const _PlaceHeroImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: double.infinity,
        height: 200,
        child: imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: const Color(0xFFE5E7EB),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF5F9EA0)),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => _placeholder(),
                // Configuración de caché para imágenes grandes
                maxHeightDiskCache: 800,
                maxWidthDiskCache: 800,
                memCacheHeight: 800,
                memCacheWidth: 800,
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFE5E7EB),
      child: const Center(
        child:
            Icon(Icons.business_outlined, size: 64, color: Color(0xFF9CA3AF)),
      ),
    );
  }
}

// ── Header: nombre, rating, chips ────────────────────────────────────────────
class _PlaceHeader extends StatelessWidget {
  final String name;
  final double rating;
  final int reviewCount;
  final String service;
  final double? distanceKm;

  const _PlaceHeader({
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.service,
    this.distanceKm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Text(
              'Valoracion: ',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            Text(
              rating.toString(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.star_outline_rounded,
                size: 16, color: Color(0xFFFBBF24)),
            const SizedBox(width: 4),
            Text(
              '($reviewCount)',
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (service.isNotEmpty) ...[
              _InfoChip(
                icon: Icons.restaurant_outlined,
                label: service,
              ),
              const SizedBox(width: 10),
            ],
            if (distanceKm != null)
              _InfoChip(
                icon: Icons.near_me_outlined,
                label: '${distanceKm!.toStringAsFixed(1)} km',
              ),
            if (distanceKm == null)
              const _InfoChip(
                icon: Icons.near_me_outlined,
                label: '2.3 km',
              ),
          ],
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF5F9EA0)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Descripción ───────────────────────────────────────────────────────────────
class _PlaceDescription extends StatelessWidget {
  final String description;

  const _PlaceDescription({required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descripción',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

// ── Card de horario ───────────────────────────────────────────────────────────
class _PlaceScheduleCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'HORARIO DE HOY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.access_time_rounded,
                    size: 16, color: Color(0xFF6B7280)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Abierto Ahora',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 12),
          _ScheduleRow(day: 'Lun - Vie', hours: '8:00 AM - 12:00 PM'),
          const SizedBox(height: 8),
          _ScheduleRow(day: 'Sab - Dom', hours: 'Cerrado', isClosed: true),
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final String day;
  final String hours;
  final bool isClosed;

  const _ScheduleRow({
    required this.day,
    required this.hours,
    this.isClosed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          day,
          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
        Text(
          hours,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isClosed ? const Color(0xFFEF4444) : const Color(0xFF374151),
          ),
        ),
      ],
    );
  }
}

// ── Botón Cómo llegar ─────────────────────────────────────────────────────────
class _PlaceDirectionsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5F9EA0), Color(0xFF3D7A7C)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5F9EA0).withValues(alpha: 0.45),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {},
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.navigation_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text(
                'Cómo llegar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Cards de contacto ─────────────────────────────────────────────────────────
class _PlaceContactCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _PlaceContactCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF5F9EA0).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF5F9EA0)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.north_east_rounded,
                size: 16, color: Color(0xFF374151)),
          ),
        ],
      ),
    );
  }
}

// ── Modelo de reseña ──────────────────────────────────────────────────────────
class _ReviewData {
  final String name;
  final String country;
  final String timeAgo;
  final String entityName;
  final int rating;
  final String comment;

  const _ReviewData({
    required this.name,
    required this.country,
    required this.timeAgo,
    required this.entityName,
    required this.rating,
    required this.comment,
  });
}

const _mockReviews = [
  _ReviewData(
    name: 'Claudia Diaz',
    country: 'Venezuela',
    timeAgo: 'Hoy',
    entityName: 'Fundacion Kiwanis',
    rating: 5,
    comment: 'Buena comida y muy buena atencion por parte de los funcionarios',
  ),
  _ReviewData(
    name: 'Carlos Mendez',
    country: 'Colombia',
    timeAgo: 'Ayer',
    entityName: 'Fundacion Kiwanis',
    rating: 4,
    comment: 'Excelente servicio, muy amables y organizados.',
  ),
  _ReviewData(
    name: 'Maria Torres',
    country: 'Ecuador',
    timeAgo: 'Hace 3 días',
    entityName: 'Fundacion Kiwanis',
    rating: 5,
    comment: 'Me ayudaron mucho cuando más lo necesitaba. Muy recomendado.',
  ),
  _ReviewData(
    name: 'Luis Perez',
    country: 'Peru',
    timeAgo: 'Hace 1 semana',
    entityName: 'Fundacion Kiwanis',
    rating: 4,
    comment: 'Buen lugar, la atención es muy humana y cercana.',
  ),
];

// ── Sección de reseñas ────────────────────────────────────────────────────────
class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Comentarios',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_mockReviews.length} reseñas',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF059669),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Lista de reseñas
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _mockReviews.length,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            color: Color.fromARGB(255, 212, 212, 212),
          ),
          itemBuilder: (_, i) => _ReviewItem(review: _mockReviews[i]),
        ),
      ],
    );
  }
}

// ── Item de reseña ────────────────────────────────────────────────────────────
class _ReviewItem extends StatelessWidget {
  final _ReviewData review;

  const _ReviewItem({required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila superior: nombre + país + fecha/entidad
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      review.country,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${review.timeAgo}  a  ${review.entityName}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFFB0B7C3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Estrellas
          Row(
            children: List.generate(5, (i) {
              return Icon(
                i < review.rating
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                size: 18,
                color: i < review.rating
                    ? const Color(0xFFFBBF24)
                    : const Color(0xFFD1D5DB),
              );
            }),
          ),
          const SizedBox(height: 8),

          // Comentario
          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF374151),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
