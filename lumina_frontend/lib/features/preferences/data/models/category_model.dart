import 'package:equatable/equatable.dart';

class CategoryModel extends Equatable {
  const CategoryModel({required this.id, required this.name, this.slug});

  final String id;
  final String name;
  final String? slug;

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    id: json['id'].toString(),
    name: json['name']?.toString() ?? '',
    slug: json['slug']?.toString(),
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'slug': slug};

  @override
  List<Object?> get props => [id, name, slug];
}
