
import 'package:product_app/modules/post/post_category.dart';

import 'user.dart';

class PostResponse {
  PostResponse({
    this.createAt,
    this.createBy,
    this.updateAt,
    this.updateBy,
    this.id,
    this.title,
    this.description,
    this.totalView,
    this.status,
    this.image,
    this.category,
    this.user,
  });

  PostResponse.fromJson(dynamic json) {
    createAt = json['createAt'] as String?;
    createBy = json['createBy'] as String?;

    // Check if updateAt and updateBy are valid fields
    updateAt = json['updateAt'] is String ? json['updateAt'] : null;
    updateBy = json['updateBy'] is String ? json['updateBy'] : null;

    // Handle ID and totalView as integers
    id = json['id'] is int ? json['id'] : null;
    totalView = json['totalView'] is int ? json['totalView'] : 0;

    status = json['status'] as String?;
    image = json['image'] as String?;
    title = json['title'] as String?;
    description = json['description'] as String?;

    // Handle category as a nested map
    category = json['category'] is Map<String, dynamic>
        ? PostCategory.fromJson(json['category'])
        : null;

    // Handle user as a nested map
    user = json['user'] is Map<String, dynamic> ? User.fromJson(json['user']) : null;

  }

  String? createAt;
  String? createBy;
  dynamic updateAt;
  dynamic updateBy;
  int? id;
  String? title;
  String? description;
  int? totalView;
  String? status;
  String? image;
  PostCategory? category;
  User? user;

  // Getter to retrieve userId from the User object, converting int? to String?
  String? get userId => user?.id?.toString();

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['createAt'] = createAt;
    map['createBy'] = createBy;
    map['updateAt'] = updateAt;
    map['updateBy'] = updateBy;
    map['id'] = id;
    map['title'] = title;
    map['description'] = description;
    map['totalView'] = totalView;
    map['status'] = status;
    map['image'] = image;
    if (category != null) {
      map['category'] = category?.toJson();
    }
    if (user != null) {
      map['user'] = user?.toJson();
    }
    return map;
  }
}
