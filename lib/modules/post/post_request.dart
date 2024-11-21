import 'package:product_app/models/category/category.dart';
import 'package:product_app/modules/post/login/user.dart';

class PostRequest {
  PostRequest({
    this.createAt,
    this.image,
    this.createBy,
    this.updateAt,
    this.updateBy,
    this.id,
    this.title,
    this.description,
    this.totalView,
    this.status,
    this.category,
    this.user,});

  PostRequest.fromJson(dynamic json) {
    createAt = json['createAt'];
    image = json['image'];
    createBy = json['createBy'];
    updateAt = json['updateAt'];
    updateBy = json['updateBy'];
    id = json['id'];
    title = json['title'];
    description = json['description'];
    totalView = json['totalView'];
    status = json['status'];
    category = json['category'] != null ? Category.fromJson(json['category']) : null;
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }
  String? createAt;
  String? image;
  String? createBy;
  String? updateAt;
  String? updateBy;
  int? id;
  String? title;
  String? description;
  int? totalView;
  String? status;
  Category? category;
  User? user;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['createAt'] = createAt;
    map['image'] = image;
    map['createBy'] = createBy;
    map['updateAt'] = updateAt;
    map['updateBy'] = updateBy;
    map['id'] = id;
    map['title'] = title;
    map['description'] = description;
    map['totalView'] = totalView;
    map['status'] = status;
    if (category != null) {
      map['category'] = category?.toJson();
    }
    if (user != null) {
      map['user'] = user?.toJson();
    }
    return map;
  }

}