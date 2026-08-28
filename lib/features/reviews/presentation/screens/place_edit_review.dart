import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/widgets/mobil/snackbar_widget.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';

import 'package:migra_ayuda/features/entities/presentation/screens/mobile/widgets/place_details/floating_main_button.dart';
import 'package:migra_ayuda/features/reviews/domain/entities/review_entity.dart';
import 'package:migra_ayuda/features/reviews/presentation/providers/review_providers.dart';

class PlaceEditReview extends ConsumerStatefulWidget {
  final EntityEntity entity;
  final ReviewEntity existingReview;

  const PlaceEditReview({
    super.key,
    required this.existingReview,
    required this.entity,
  });

  @override
  ConsumerState<PlaceEditReview> createState() => _PlaceEditReviewState();
}

class _PlaceEditReviewState extends ConsumerState<PlaceEditReview> {
  late double rating;
  final formkey = GlobalKey<FormState>();
  late TextEditingController commentController;

  @override
  void initState() {
    super.initState();
    // Pre-llena los campos con los datos existentes
    rating = widget.existingReview.rating;
    commentController =
        TextEditingController(text: widget.existingReview.comment);
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  bool isloading =  ref.watch(reviewNotifierProvider).isLoading;
    ref.listen(
      reviewNotifierProvider,
      (previous, next) async {
        // Solo reacciona cuando termina de cargar (igual que en place_add_review)
        if (previous?.isLoading == true && !next.isLoading) {
          if (next.hasError) {
            SnackbarWidget.error(context, next.error);
          } else if( next.value == ReviewState.updating) {
            SnackbarWidget.success(context, 'Reseña actualizada exitosamente');
            await Future.delayed(const Duration(seconds: 1));
            if (context.mounted) Navigator.pop(context);
          }
        }
      },
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
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
        title: Text(
          widget.entity.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        actions: [
          // Botón de eliminar en el AppBar
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
            onPressed:
                () {} /* state.isLoading ? null : _showDeleteConfirmation */,
            tooltip: 'Eliminar comentario',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
        child: Form(
          key: formkey,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner informativo
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDEF7EC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF84E1BC),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFF059669),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Estás editando tu comentario existente',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.green[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Información del usuario
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
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.existingReview.userName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        Text(
                          widget.existingReview.userCountry,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Rating
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

                // Comentario
                const Text(
                  'Describe tu experiencia para ayudar a otros usuarios',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor escribe un comentario';
                    }
                    if (value.trim().length < 5) {
                      return 'El comentario debe tener al menos 5 caracteres';
                    }
                    if (value.trim().length > 500) {
                      return 'El comentario no puede exceder 500 caracteres';
                    }
                    return null;
                  },
                  controller: commentController,
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

                // Botón de actualizar
                FloatingMainButton(
                  onTap: () async {
                    if (!formkey.currentState!.validate()) {
                      debugPrint('❌ Validación falló');
                      return;
                    }
                    // ✅ Construye la review con los datos EDITADOS
                    final updatedReview = widget.existingReview.copyWith(
                        rating: rating,
                        comment: commentController.text.trim(),
                        updatedAt: DateTime.now(),
                        isSynced: false);

        
                    await ref
                        .read(reviewNotifierProvider.notifier)
                        .updateReview(updatedReview);
                  },
                  text: isloading ? 'Actualizando...' : 'Actualizar Comentario',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
