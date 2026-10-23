import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/tutorial/data/repositories/tutorial_repositories_impl.dart';
import 'package:migra_ayuda/features/tutorial/domain/usecases/tutorial_usecase.dart';
import '../../data/datasources/tutorial_local_datasource.dart';
import '../../domain/repositories/tutorial_repository.dart';

final tutorialLocalDataSourceProvider = Provider<TutorialLocalDatasource>((ref) {
  return TutorialLocalDatasource();
});

final tutorialRepositoryProvider = Provider<TutorialRepository>((ref) {
  final dataSource = ref.watch(tutorialLocalDataSourceProvider);
  return TutorialRepositoryImpl(dataSource);
});

final shouldShowTutorialUseCaseProvider = Provider<ShouldShowTutorialUseCase>((ref) {
  final repo = ref.watch(tutorialRepositoryProvider);
  return ShouldShowTutorialUseCase(repo);
});

final completeTutorialUseCaseProvider = Provider<CompleteTutorialUseCase>((ref) {
  final repo = ref.watch(tutorialRepositoryProvider);
  return CompleteTutorialUseCase(repo);
});