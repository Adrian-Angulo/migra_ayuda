import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:migra_ayuda/features/entities/presentation/widgets/place_details/place_details_header.dart';
import 'package:migra_ayuda/features/entities/presentation/widgets/place_details/place_details_info.dart';
import 'package:migra_ayuda/features/entities/presentation/widgets/place_details/place_details_reviews.dart';
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
            PlaceDetailsHeader(
              imageUrl: entity.imageUrl,
              name: entity.name,
              rating: 4.4,
              reviewCount: 20,
              service: entity.services.isNotEmpty ? entity.services.first : '',
              distanceKm: distanceKm,
            ),
            const SizedBox(height: 16),
            PlaceDetailsInfo(
              description: entity.description,
              phone: entity.phone,
              address: entity.address,
            ),
            const SizedBox(height: 28),
            const PlaceDetailsReviews(),
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
