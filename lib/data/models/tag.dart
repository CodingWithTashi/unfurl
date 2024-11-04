import 'package:equatable/equatable.dart';

class Tag extends Equatable {
  final int? id;
  final String tagName;
  final String tagDescription;
  final DateTime createdDate;
  final DateTime updatedDate;
  final String status; // 'active' or 'archived'

  Tag({
    this.id,
    required this.tagName,
    required this.tagDescription,
    DateTime? createdDate,
    DateTime? updatedDate,
    this.status = 'active',
  })  : createdDate = createdDate ?? DateTime.now(),
        updatedDate = updatedDate ?? DateTime.now();

  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      id: map['id'],
      tagName: map['tagName'],
      tagDescription: map['tagDescription'],
      createdDate: DateTime.parse(map['createdDate']),
      updatedDate: DateTime.parse(map['updatedDate']),
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tagName': tagName,
      'tagDescription': tagDescription,
      'createdDate': createdDate.toIso8601String(),
      'updatedDate': updatedDate.toIso8601String(),
      'status': status,
    };
  }

  Tag copyWith({
    int? id,
    String? tagName,
    String? tagDescription,
    DateTime? createdDate,
    DateTime? updatedDate,
    String? status,
  }) {
    return Tag(
      id: id ?? this.id,
      tagName: tagName ?? this.tagName,
      tagDescription: tagDescription ?? this.tagDescription,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        id,
        tagName,
        tagDescription,
        createdDate,
        updatedDate,
        status,
      ];
}
