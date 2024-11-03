class Tag {
  final String? id;
  final String tagName;
  final String tagDescription;

  Tag({
    this.id,
    required this.tagName,
    required this.tagDescription,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tagName': tagName,
      'tagDescription': tagDescription,
    };
  }

  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      id: map['id'],
      tagName: map['tagName'],
      tagDescription: map['tagDescription'],
    );
  }
}
