

class CategoriesModel {
  final int? id;
  final String name;

  CategoriesModel({
    this.id,
    required this.name,
  }); 

  
  factory CategoriesModel.fromJson(Map<String, dynamic> json) {
    return CategoriesModel(

      id: json['id'] as int?,
      name: json['name']?.toString() ?? 'Unknown',
    );
  }
}

