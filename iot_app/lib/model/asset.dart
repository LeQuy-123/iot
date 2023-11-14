class Asset {
  String id;
  int version;
  int createdOn;
  String name;
  bool accessPublicRead;
  String parentId;
  String realm;
  String type;

  Asset({
    required this.id,
    required this.version,
    required this.createdOn,
    required this.name,
    required this.accessPublicRead,
    required this.parentId,
    required this.realm,
    required this.type,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'],
      version: json['version'],
      createdOn: json['createdOn'],
      name: json['name'],
      accessPublicRead: json['accessPublicRead'],
      parentId: json['parentId'],
      realm: json['realm'],
      type: json['type'],
    );
  }
}
