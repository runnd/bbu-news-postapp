class BasePostRequest {
  BasePostRequest({
    this.limit=10,
    this.page=0,
    this.userId=0,
    this.status="ALL",
    this.id=0,
    this.categoryId=0,
    this.name=""
  });

  BasePostRequest.fromJson(dynamic json) {
    limit = json['limit'];
    page = json['page'];
    userId = json['userId'];
    status = json['status'];
    id = json['id'];
    categoryId = json['categoryId'];
    name = json['name'];
  }
  int? limit;
  int? page;
  int? userId;
  String? status;
  int? id;
  int? categoryId;
  String? name;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['limit'] = limit;
    map['page'] = page;
    map['userId'] = userId;
    map['status'] = status;
    map['id'] = id;
    map['categoryId'] = categoryId;
    map['name'] = name;
    return map;
  }

}