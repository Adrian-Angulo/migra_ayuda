import 'package:flutter/material.dart';

class CategoryDataModel {
  final String name;
  final int value;
 

  const CategoryDataModel({
    required this.name,
    required this.value,

  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'value': value,
    
    };
  }

  factory CategoryDataModel.fromMap(Map<String, dynamic> map) {
    return CategoryDataModel(
      name: map['name'] ?? '',
      value: map['value'] ?? 0,
    
    );
  }

  CategoryDataModel copyWith({
    String? name,
    int? value,
    Color? color,
  }) {
    return CategoryDataModel(
      name: name ?? this.name,
      value: value ?? this.value,
     
    );
  }
}
