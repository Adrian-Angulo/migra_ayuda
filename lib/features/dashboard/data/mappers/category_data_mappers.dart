import '../models/category_data_model.dart';
import '../../domain/entities/category_data.dart';

class CategoryDataMappers {
  
  


  static CategoryData toDomain(CategoryDataModel model) {
    return CategoryData(
      name: model.name,
      value: model.value,
      
    );
  }

  static CategoryDataModel toModel(CategoryData entity) {
    return CategoryDataModel(
      name: entity.name,
      value: entity.value,
    
    );
  }
}