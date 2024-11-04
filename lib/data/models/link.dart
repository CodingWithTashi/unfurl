class UnfurlLink {
  final int? id;
  final String title;
  final String description;
  final String link;
  final DateTime createdDate;
  final DateTime updatedDate;
  final String status; // 'archive' or 'active'

  UnfurlLink({
    this.id,
    required this.title,
    required this.description,
    required this.link,
    required this.createdDate,
    required this.updatedDate,
    required this.status,
  });

  factory UnfurlLink.fromMap(Map<String, dynamic> map) {
    return UnfurlLink(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      link: map['link'],
      createdDate: DateTime.parse(map['createdDate']),
      updatedDate: DateTime.parse(map['updatedDate']),
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'link': link,
      'createdDate': createdDate.toIso8601String(),
      'updatedDate': updatedDate.toIso8601String(),
      'status': status,
    };
  }

  UnfurlLink copyWith({
    int? id,
    String? title,
    String? description,
    String? link,
    DateTime? createdDate,
    DateTime? updatedDate,
    String? status,
  }) {
    return UnfurlLink(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      link: link ?? this.link,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      status: status ?? this.status,
    );
  }
}
