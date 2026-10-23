import '../repositories/tutorial_repository.dart';

class ShouldShowTutorialUseCase {
  final TutorialRepository _repository;
  ShouldShowTutorialUseCase(this._repository);
  
  Future<bool> call(String tutorialKey) async {
    final hasSeen = await _repository.hasSeenTutorial(tutorialKey);
    return !hasSeen; 
  }
}

class CompleteTutorialUseCase {
  final TutorialRepository _repository;
  CompleteTutorialUseCase(this._repository);

  Future<void> call(String tutorialKey) async {
    await _repository.markTutorialSeen(tutorialKey);
  }
}