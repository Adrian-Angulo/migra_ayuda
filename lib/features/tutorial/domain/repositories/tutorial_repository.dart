abstract class TutorialRepository {

  Future<bool> hasSeenTutorial(String tutorialKey);

  Future<void> markTutorialSeen(String tutorialKey);
}