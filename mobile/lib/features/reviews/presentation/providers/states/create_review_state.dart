class CreateReviewState {
  final bool isLoading;
  final bool isSucces;
  final String? errorMensaje;

  CreateReviewState(
      {this.isLoading = false, this.isSucces = false, this.errorMensaje});

  CreateReviewState copyWith(
      {bool? isLoading, bool? isSucces, String? errorMensaje}) {
    return CreateReviewState(
        isLoading: isLoading ?? this.isLoading,
        isSucces: isSucces ?? this.isSucces,
        errorMensaje: errorMensaje ?? this.errorMensaje);
  }
}
