import 'package:photopia/data/models/professional_profile_model.dart';

class ReviewResponse {
  int? statusCode;
  bool? success;
  String? message;
  ReviewData? data;

  ReviewResponse({this.statusCode, this.success, this.message, this.data});

  ReviewResponse.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? ReviewData.fromJson(json['data']) : null;
  }
}

class ReviewData {
  Meta? meta;
  List<ReviewItem>? reviews;

  ReviewData({this.meta, this.reviews});

  ReviewData.fromJson(Map<String, dynamic> json) {
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    if (json['data'] != null) {
      reviews = <ReviewItem>[];
      json['data'].forEach((v) {
        reviews!.add(ReviewItem.fromJson(v));
      });
    }
  }
}

class Meta {
  int? page;
  int? limit;
  int? total;
  int? totalPages;

  Meta({this.page, this.limit, this.total, this.totalPages});

  Meta.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    limit = json['limit'];
    total = json['total'];
    totalPages = json['totalPages'];
  }
}

class ReviewItem {
  String? sId;
  ReviewUser? user;
  num? rating;
  String? comment;
  String? createdAt;
  ReviewService? service;

  ReviewItem({
    this.sId,
    this.user,
    this.rating,
    this.comment,
    this.createdAt,
    this.service,
  });

  ReviewItem.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    user = json['user'] != null ? ReviewUser.fromJson(json['user']) : (json['reviewer'] != null ? ReviewUser.fromJson(json['reviewer']) : null);
    rating = json['rating'] ?? 0;
    comment = json['comment'] ?? "";
    createdAt = json['createdAt'];
    service = json['serviceId'] != null ? ReviewService.fromJson(json['serviceId']) : null;
  }
}

class ReviewUser {
  String? sId;
  String? name;
  String? profile;

  ReviewUser({this.sId, this.name, this.profile});

  ReviewUser.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    final rawProfile = json['profile'] ?? json['avatar'];
    profile = ProfessionalProfileModel.formatUrl(rawProfile);
  }
}

class ReviewService {
  String? sId;
  String? title;

  ReviewService({this.sId, this.title});

  ReviewService.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
  }
}
