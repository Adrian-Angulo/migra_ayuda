import 'package:migra_ayuda/features/dashboard/domain/entities/category_data.dart';
import 'package:migra_ayuda/features/dashboard/domain/entities/destination_data.dart';

abstract class DashboardRepository {
  Future<int> getUsersCount();
  Future<int> getEntitiesCount();
  Future<int> getReviewCount();
  Future<int> getServicesCount();
  Future<List<CategoryData>> getCategoryData();
  Stream<List<DestinationData>> getDetinations();
}
