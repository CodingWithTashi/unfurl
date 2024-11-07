class QRCodeData {
  final String packageName;
  final String type;
  final String id;
  // Link specific fields
  final String? title;
  final String? description;
  final String? link;
  final DateTime? createdDate; // Link created date
  final DateTime? updatedDate; // Link updated date
  final String? status; // Link status
  final int? tagId;
  // Tag specific fields
  final String? tagName;
  final String? tagDescription;
  final DateTime? tagCreatedDate; // Tag created date
  final DateTime? tagUpdatedDate; // Tag updated date
  final String? tagStatus; // Tag status

  QRCodeData({
    required this.packageName,
    required this.type,
    required this.id,
    this.title,
    this.description,
    this.link,
    this.createdDate,
    this.updatedDate,
    this.status,
    this.tagId,
    this.tagName,
    this.tagDescription,
    this.tagCreatedDate,
    this.tagUpdatedDate,
    this.tagStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'packageName': packageName,
      'type': type,
      'id': id,
      'title': title,
      'description': description,
      'link': link,
      'createdDate': createdDate?.toIso8601String(),
      'updatedDate': updatedDate?.toIso8601String(),
      'status': status,
      'tagId': tagId,
      'tagName': tagName,
      'tagDescription': tagDescription,
      'tagCreatedDate': tagCreatedDate?.toIso8601String(),
      'tagUpdatedDate': tagUpdatedDate?.toIso8601String(),
      'tagStatus': tagStatus,
    };
  }

  factory QRCodeData.fromJson(Map<String, dynamic> json) {
    return QRCodeData(
      packageName: json['packageName'],
      type: json['type'],
      id: json['id'],
      title: json['title'],
      description: json['description'],
      link: json['link'],
      createdDate: json['createdDate'] != null
          ? DateTime.parse(json['createdDate'])
          : null,
      updatedDate: json['updatedDate'] != null
          ? DateTime.parse(json['updatedDate'])
          : null,
      status: json['status'],
      tagId: json['tagId'],
      tagName: json['tagName'],
      tagDescription: json['tagDescription'],
      tagCreatedDate: json['tagCreatedDate'] != null
          ? DateTime.parse(json['tagCreatedDate'])
          : null,
      tagUpdatedDate: json['tagUpdatedDate'] != null
          ? DateTime.parse(json['tagUpdatedDate'])
          : null,
      tagStatus: json['tagStatus'],
    );
  }
}
