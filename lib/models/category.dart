class Category {
  String? sId;
  String? name;
  String? image;
  String? createdAt;
  String? updatedAt;
  bool? showName; // ← الحقل الجديد

  Category({
    this.sId,
    this.name,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.showName, // ← الحقل الجديد
  });

  Category.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    image = json['image'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    showName = json['show_name']; // ← التحويل من JSON
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['image'] = image;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['show_name'] = showName; // ← التحويل إلى JSON
    return data;
  }
}
