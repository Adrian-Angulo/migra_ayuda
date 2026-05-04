/// Estado para el proceso de edición de reviews
class EditReviewState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  EditReviewState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  EditReviewState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return EditReviewState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
