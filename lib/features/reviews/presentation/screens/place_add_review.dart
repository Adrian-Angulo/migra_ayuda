import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/widgets/mobil/app_bar_widget.dart';
import 'package:migra_ayuda/core/widgets/mobil/snackbar_widget.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/widgets/place_details/floating_main_button.dart';
import 'package:migra_ayuda/features/reviews/domain/entities/review_entity.dart';
import 'package:migra_ayuda/features/reviews/presentation/config/review_constants.dart';
import 'package:migra_ayuda/features/reviews/presentation/providers/review_providers.dart';
import 'package:migra_ayuda/features/users/domain/entities/migrant.dart';

class PlaceAddReview extends ConsumerStatefulWidget {
  final EntityEntity entity;
  final Migrant? user;

  const PlaceAddReview({
    super.key,
    required this.entity,
    required this.user,
  });

  @override
  ConsumerState<PlaceAddReview> createState() => _PlaceAddReviewState();
}

class _PlaceAddReviewState extends ConsumerState<PlaceAddReview> {
  double _rating = 3;
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _listenReviewState(BuildContext context) {
    ref.listen(
      reviewNotifierProvider,
      (previous, next) {
        if (previous?.isLoading == true && !next.isLoading) {
          if (next.value == ReviewState.creating) {
            SnackbarWidget.success(context, '¡Reseña publicada exitosamente!');

            Navigator.pop(context);
          } else if (next.hasError) {
            SnackbarWidget.error(context, next.error);
          }
        }
      },
    );
  }

  Widget _buildUserAvatar() {
    final user = widget.user;
    final String initials = (user?.name ?? "")
        .trim()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    return Container(
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
      child: user?.name != null && initials.isNotEmpty
          ? Text(
              initials,
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
    );
  }

  Widget _buildUserInfo() {
    final user = widget.user;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user?.name ?? 'no data',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        Text(
          user?.originCountry ?? 'no data',
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingBar() {
    return Center(
      child: RatingBar.builder(
        initialRating: _rating,
        maxRating: 5,
        minRating: 1,
        direction: Axis.horizontal,
        allowHalfRating: true,
        itemCount: 5,
        itemPadding: const EdgeInsets.all(8),
        itemBuilder: (context, index) => const Icon(
          Icons.star,
          color: Colors.amber,
        ),
        onRatingUpdate: (value) {
          setState(() {
            _rating = value;
          });
        },
      ),
    );
  }

  Widget _buildCommentField() {
    return TextFormField(
      validator: (value) {
        if (value == null) return null;
        if (value.trim().length > 200) {
          return 'El comentario no puede exceder los 200 caracteres';
        }
        return null;
      },
      controller: _commentController,
      maxLines: 5,
      minLines: 5,
      maxLength: 200,
      keyboardType: TextInputType.multiline,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF1A1A1A),
      ),
      decoration: InputDecoration(
        hintText: 'Escribe tu comentario...',
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
    );
  }

  Future<void> _handleSubmit(BuildContext context, bool isLoading) async {
    final user = widget.user;
    if (user == null) {
      SnackbarWidget.error(
          context, 'Debes iniciar sesión para publicar una reseña');
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    final review = ReviewEntity(
      idMigrante: user.id,
      idEntity: widget.entity.id,
      userName: user.name,
      userCountry: user.originCountry,
      rating: _rating,
      comment: _commentController.text,
      isSynced: false,
      nameEntity: widget.entity.name,
    );
    await ref.read(reviewNotifierProvider.notifier).createReview(review);
  }

  @override
  Widget build(BuildContext context) {
    _listenReviewState(context);

    final state = ref.watch(reviewNotifierProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBarWidget(title: widget.entity.name),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Information Row
                Row(
                  children: [
                    _buildUserAvatar(),
                    const SizedBox(width: 8),
                    _buildUserInfo(),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  '¿Cómo calificarías esta entidad?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                _buildRatingBar(),
                const Text(
                  'Describe tu experiencia para ayudar a otros usuarios',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 16),
                _buildCommentField(),
                const SizedBox(height: 10),
                FloatingMainButton(
                  onTap: isLoading
                      ? () {}
                      : () async {
                          await _handleSubmit(context, isLoading);
                        },
                  text: 'Enviar reseña',
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
