import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/widgets/app_bar_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/auth_notifier.dart';
import 'package:migra_ayuda/features/entities/presentation/widgets/floating_main_button.dart';
import 'package:migra_ayuda/features/entities/presentation/widgets/place_details/place_details_header.dart';
import 'package:migra_ayuda/features/entities/presentation/widgets/place_details/place_details_info.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/reviews/domain/review_entity.dart';
import 'package:migra_ayuda/features/reviews/presentation/screens/place_add_review.dart';
import 'package:migra_ayuda/features/reviews/presentation/widgets/review_item.dart';
import 'package:sembast/timestamp.dart';

class PlaceDetails extends ConsumerWidget {
  final EntityEntity entity;

  const PlaceDetails({super.key, required this.entity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.value;
    final mockReviews = [
      ReviewEntity(
        id: '1',
        idMigrante: 'migrante_001',
        idEntity: 'kiwanis_001',
        userName: 'Claudia Diaz',
        userContry: 'Venezuela',
        rating: 3.0,
        comment:
            'Buena comida y muy buena atencion por parte de los funcionarios',
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
        deletedAt: null,
        isSynced: false,
      ),
      ReviewEntity(
        id: '2',
        idMigrante: 'migrante_002',
        idEntity: 'kiwanis_001',
        userName: 'Carlos Mendez',
        userContry: 'Colombia',
        rating: 4.0,
        comment: 'Excelente servicio, muy amables y organizados.',
        createdAt: Timestamp.now(),
        updatedAt: null,
        deletedAt: null,
        isSynced: false,
      ),
      ReviewEntity(
        id: '3',
        idMigrante: 'migrante_003',
        idEntity: 'kiwanis_001',
        userName: 'Maria Torres',
        userContry: 'Ecuador',
        rating: 5.0,
        comment: 'Me ayudaron mucho cuando más lo necesitaba. Muy recomendado.',
        createdAt: Timestamp.now(),
        updatedAt: null,
        deletedAt: null,
        isSynced: false,
      ),
      ReviewEntity(
        id: '4',
        idMigrante: 'migrante_004',
        idEntity: 'kiwanis_001',
        userName: 'Luis Perez',
        userContry: 'Peru',
        rating: 4.0,
        comment: 'Buen lugar, la atención es muy humana y cercana.',
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
        deletedAt: null,
        isSynced: false,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const AppBarWidget(
        title: "Destalles de la entidad",
      ),
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
            ),
            const SizedBox(height: 16),
            PlaceDetailsInfo(
              entity: entity,
            ),
            const SizedBox(height: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${mockReviews.length} Comentarios',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    TextButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlaceAddReview(
                                entity: entity,
                                user: user,
                              ),
                            )),
                        child: const Text(
                          "Añadir comentario",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF059669),
                          ),
                        ))
                  ],
                ),
                const SizedBox(height: 8),

                //vista de comentarios
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: mockReviews.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    color: Color.fromARGB(255, 212, 212, 212),
                  ),
                  itemBuilder: (_, i) => ReviewItem(review: mockReviews[i]),
                ),
              ],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: FloatingMainButton(
          onTap: () {},
          text: 'Como llegar',
          icon: Icons.directions,
        ),
      ),
    );
  }
}
