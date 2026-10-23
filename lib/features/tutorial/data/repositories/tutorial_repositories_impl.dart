import '../../domain/repositories/tutorial_repository.dart';
import '../datasources/tutorial_local_datasource.dart';
class TutorialRepositoryImpl implements TutorialRepository {
  final TutorialLocalDatasource _datasource;
  TutorialRepositoryImpl(this._datasource);

  @override
  Future<bool> hasSeenTutorial(String tutorialKey) {
    return _datasource.isTutorialSeen(tutorialKey);
  }

  @override
  Future<void> markTutorialSeen(String tutorialKey) {
    return _datasource.setTutorialSeen(tutorialKey);
  }
}