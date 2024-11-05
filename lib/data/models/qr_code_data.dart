class QRCodeData {
  final String? packageName;
  final String type; // 'Tag' or 'Link'
  final String id;
  final String title;
  final String description;
  final String link;
  final String tagName;
  final String tagDescription;
  final DateTime createdDate;
  final DateTime updatedDate;
  final String status;

  QRCodeData({
    required this.packageName,
    required this.type,
    required this.id,
    required this.title,
    required this.description,
    required this.link,
    required this.tagName,
    required this.tagDescription,
    required this.createdDate,
    required this.updatedDate,
    required this.status,
  });
}
