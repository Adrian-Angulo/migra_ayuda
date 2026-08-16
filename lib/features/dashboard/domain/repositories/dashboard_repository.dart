abstract class DashboardRepository {
  Future<int> getUsersCount();
  Future<int> getEntitiesCount();
  Future<int> getReviewCount();
  Future<int> getServicesCount();
}
