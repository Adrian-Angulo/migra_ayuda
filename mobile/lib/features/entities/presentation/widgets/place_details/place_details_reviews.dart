import 'package:flutter/material.dart';

class ReviewData {
  final String name;
  final String country;
  final String timeAgo;
  final String entityName;
  final int rating;
  final String comment;

  const ReviewData({
    required this.name,
    required this.country,
    required this.timeAgo,
    required this.entityName,
    required this.rating,
    required this.comment,
  });
}

const mockReviews = [
  ReviewData(
    name: 'Claudia Diaz',
    country: 'Venezuela',
    timeAgo: 'Hoy',
    entityName: 'Fundacion Kiwanis',
    rating: 5,
    comment: 'Buena comida y muy buena atencion por parte de los funcionarios',
  ),
  ReviewData(
    name: 'Carlos Mendez',
    country: 'Colombia',
    timeAgo: 'Ayer',
    entityName: 'Fundacion Kiwanis',
    rating: 4,
    comment: 'Excelente servicio, muy amables y organizados.',
  ),
  ReviewData(
    name: 'Maria Torres',
    country: 'Ecuador',
    timeAgo: 'Hace 3 días',
    entityName: 'Fundacion Kiwanis',
    rating: 5,
    comment: 'Me ayudaron mucho cuando más lo necesitaba. Muy recomendado.',
  ),
  ReviewData(
    name: 'Luis Perez',
    country: 'Peru',
    timeAgo: 'Hace 1 semana',
    entityName: 'Fundacion Kiwanis',
    rating: 4,
    comment: 'Buen lugar, la atención es muy humana y cercana.',
  ),
];

class PlaceDetailsReviews extends StatelessWidget {
  final List<ReviewData> reviews;

  const PlaceDetailsReviews({
    super.key,
    this.reviews = mockReviews,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                '${reviews.length} reseñas',
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
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            color: Color.fromARGB(255, 212, 212, 212),
          ),
          itemBuilder: (_, i) => _ReviewItem(review: reviews[i]),
        ),
      ],
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final ReviewData review;

  const _ReviewItem({required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
