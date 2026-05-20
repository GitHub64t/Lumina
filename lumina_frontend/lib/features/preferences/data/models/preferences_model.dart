import 'package:equatable/equatable.dart';

class PreferencesModel extends Equatable {
  const PreferencesModel({required this.categoryIds});

  final List<String> categoryIds;

  factory PreferencesModel.fromJson(Map<String, dynamic> json) =>
      PreferencesModel(
        categoryIds:
            ((json['categoryIds'] ?? json['categories']) as List? ?? const [])
                .map((item) => item.toString())
                .toList(),
      );

  Map<String, dynamic> toJson() => {'categoryIds': categoryIds};

  @override
  List<Object?> get props => [categoryIds];
}
