import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/widgets/app_bar_widget.dart';
import 'package:migra_ayuda/core/widgets/snackbar_widget.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/widgets/place_details/floating_main_button.dart';
import 'package:migra_ayuda/features/reviews/domain/entities/review_entity.dart';
import 'package:migra_ayuda/features/reviews/presentation/providers/review_providers.dart';

class PlaceAddReview extends ConsumerStatefulWidget {
  final EntityEntity entity;
  final UserModel? user;
  const PlaceAddReview({
    super.key,
    required this.entity,
    required this.user,
  });

  @override
  ConsumerState<PlaceAddReview> createState() => _PlaceAddReviewState();
}

class _PlaceAddReviewState extends ConsumerState<PlaceAddReview> {
  double rating = 1;
  final formkey = GlobalKey<FormState>();
  final commetController = TextEditingController();

  @override
  void dispose() {
    commetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UserModel user = widget.user!;

    // Escucha el estado de creación de review
    ref.listen(
      reviewNotifierProvider,
      (previous, next) {
        if (previous?.isLoading == true && !next.isLoading) {
          if (next.value == ReviewState.creating) {
            SnackbarWidget.success(
                context, 'Comentario publicado exitosamente');
            Future.delayed(const Duration(seconds: 1), () {
              if (context.mounted) Navigator.pop(context);
            });
          } else if (next.hasError) {
            SnackbarWidget.error(context, next.error.toString());
          }
        }
      },
    );

    final state = ref.watch(reviewNotifierProvider);
    final isLoading = state.isLoading;

    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBarWidget(title: widget.entity.name),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
          child: Form(
            key: formkey,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: 8,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5F9EA0), Color(0xFF3D7A7C)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: widget.user?.name != null
                            ? Text(
                                widget.user!.name
                                    .trim()
                                    .split(' ')
                                    .take(2)
                                    .map((w) =>
                                        w.isNotEmpty ? w[0].toUpperCase() : '')
                                    .join(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              )
                            : const Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.user?.name ?? 'no data',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          Text(
                            widget.user?.originCountry ?? 'no data',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  const Text(
                    '¿Cómo calificarías esta entidad?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  Center(
                    child: RatingBar.builder(
                      initialRating: rating,
                      maxRating: 5,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: const EdgeInsetsGeometry.all(8),
                      itemBuilder: (context, index) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (value) {
                        setState(() {
                          rating = value;
                        });
                      },
                    ),
                  ),
                  const Text(
                    'Describe tu experiencia para ayudar a otros usuarios',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor escribe un comentario';
                      }
                      if (value.trim().length < 10) {
                        return 'El comentario debe tener al menos 10 caracteres';
                      }
                      if (value.trim().length > 500) {
                        return 'El comentario no puede exceder 500 caracteres';
                      }
                      return null;
                    },
                    controller: commetController,
                    maxLines: 5,
                    minLines: 5,
                    maxLength: 500,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1A1A1A),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Escribe tu comentario aquí...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          width: 1.5,
                          color: Color(0xFFD1E8E8),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          width: 2,
                          color: Color(0xFF5F9EA0),
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          width: 1.5,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          width: 2,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                      errorStyle: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FloatingMainButton(
                    onTap: () async {
                      final review = ReviewEntity(
                          idMigrante: user.id,
                          idEntity: widget.entity.id,
                          userName: user.name,
                          userCountry: user.originCountry!,
                          rating: rating,
                          comment: commetController.text,
                          isSynced: false,
                          nameEntity: widget.entity.name);
                      await ref
                          .read(reviewNotifierProvider.notifier)
                          .createReview(review);
                    },
                    text: isLoading ? 'Publicando...' : 'Publicar Comentario',
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
