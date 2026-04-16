import 'package:photopia/data/models/service_list_model.dart';
import 'package:photopia/data/models/category_model.dart';
import 'package:photopia/core/network/urls.dart';

class HomeDataModel {
  bool? success;
  String? message;
  HomeData? data;

  HomeDataModel({this.success, this.message, this.data});

  factory HomeDataModel.fromJson(Map<String, dynamic> json) {
    return HomeDataModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? HomeData.fromJson(json['data']) : null,
    );
  }
}

class HomeData {
  List<RecentlyViewedItem>? recentlyViewed;
  List<CategoryModel>? popularCategories;
  List<TrendingSubcategory>? trendingSubcategories;
  List<ServiceItem>? availableNow;
  List<SuperPro>? superPros;
  List<String>? styles;
  List<PopularLocation>? popularLocations;
  List<ServiceItem>? originalProjects;
  List<Inspiration>? inspirations;

  HomeData({
    this.recentlyViewed,
    this.popularCategories,
    this.trendingSubcategories,
    this.availableNow,
    this.superPros,
    this.styles,
    this.popularLocations,
    this.originalProjects,
    this.inspirations,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      recentlyViewed: json['recentlyViewed'] != null
          ? (json['recentlyViewed'] as List)
              .map((v) => RecentlyViewedItem.fromJson(v))
              .toList()
          : null,
      popularCategories: json['popularCategories'] != null
          ? (json['popularCategories'] as List)
              .map((v) => CategoryModel.fromJson(v))
              .toList()
          : null,
      trendingSubcategories: json['trendingSubcategories'] != null
          ? (json['trendingSubcategories'] as List)
              .map((v) => TrendingSubcategory.fromJson(v))
              .toList()
          : null,
      availableNow: json['availableNow'] != null
          ? (json['availableNow'] as List)
              .map((v) => ServiceItem.fromJson(v))
              .toList()
          : null,
      superPros: json['superPros'] != null
          ? (json['superPros'] as List)
              .map((v) => SuperPro.fromJson(v))
              .toList()
          : null,
      styles: json['styles'] != null
          ? List<String>.from(json['styles'])
          : null,
      popularLocations: json['popularLocations'] != null
          ? (json['popularLocations'] as List)
              .map((v) => PopularLocation.fromJson(v))
              .toList()
          : null,
      originalProjects: json['originalProjects'] != null
          ? (json['originalProjects'] as List)
              .map((v) => ServiceItem.fromJson(v))
              .toList()
          : null,
      inspirations: json['inspirations'] != null
          ? (json['inspirations'] as List)
              .map((v) => Inspiration.fromJson(v))
              .toList()
          : null,
    );
  }
}

class RecentlyViewedItem {
  String? sId;
  String? userId;
  ServiceItem? serviceId;
  String? viewedAt;

  RecentlyViewedItem({this.sId, this.userId, this.serviceId, this.viewedAt});

  factory RecentlyViewedItem.fromJson(Map<String, dynamic> json) {
    return RecentlyViewedItem(
      sId: json['_id'],
      userId: json['userId'],
      serviceId: json['serviceId'] is Map
          ? ServiceItem.fromJson(json['serviceId'])
          : null,
      viewedAt: json['viewedAt'],
    );
  }
}

class TrendingSubcategory {
  String? sId;
  String? name;
  String? trendingBadge;
  Map<String, dynamic>? parent;

  TrendingSubcategory({this.sId, this.name, this.trendingBadge, this.parent});

  factory TrendingSubcategory.fromJson(Map<String, dynamic> json) {
    return TrendingSubcategory(
      sId: json['_id'],
      name: json['name'],
      trendingBadge: json['trendingBadge'],
      parent: json['parent'] is Map ? Map<String, dynamic>.from(json['parent']) : null,
    );
  }
}

class SuperPro {
  String? sId;
  bool? isSuperPro;
  double? rating;
  SuperProUser? user;

  SuperPro({this.sId, this.isSuperPro, this.rating, this.user});

  factory SuperPro.fromJson(Map<String, dynamic> json) {
    return SuperPro(
      sId: json['_id'],
      isSuperPro: json['isSuperPro'],
      rating: double.tryParse(json['rating']?.toString() ?? '0.0') ?? 0.0,
      user: json['user'] is Map ? SuperProUser.fromJson(json['user']) : null,
    );
  }
}

class SuperProUser {
  String? name;
  String? profile;

  SuperProUser({this.name, this.profile});

  factory SuperProUser.fromJson(Map<String, dynamic> json) {
    String? profileUrl = json['profile']?.toString();
    if (profileUrl != null && !profileUrl.startsWith('http')) {
      final String base = Urls.baseUrl.endsWith('/')
          ? Urls.baseUrl.substring(0, Urls.baseUrl.length - 1)
          : Urls.baseUrl;
      final String path = profileUrl.startsWith('/') ? profileUrl : '/$profileUrl';
      profileUrl = "$base$path";
    }

    return SuperProUser(
      name: json['name']?.toString(),
      profile: profileUrl,
    );
  }
}

class PopularLocation {
  String? id;
  int? count;
  String? image;

  PopularLocation({this.id, this.count, this.image});

  factory PopularLocation.fromJson(Map<String, dynamic> json) {
    String? imageUrl = json['image']?.toString();
    if (imageUrl != null && !imageUrl.startsWith('http')) {
      final String base = Urls.baseUrl.endsWith('/')
          ? Urls.baseUrl.substring(0, Urls.baseUrl.length - 1)
          : Urls.baseUrl;
      final String path = imageUrl.startsWith('/') ? imageUrl : '/$imageUrl';
      imageUrl = "$base$path";
    }

    return PopularLocation(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      count: (json['count'] as num?)?.toInt(),
      image: imageUrl,
    );
  }
}

class Inspiration {
  String? title;
  String? description;
  String? link;
  String? icon;

  Inspiration({this.title, this.description, this.link, this.icon});

  factory Inspiration.fromJson(Map<String, dynamic> json) {
    return Inspiration(
      title: json['title'],
      description: json['description'],
      link: json['link'],
      icon: json['icon'],
    );
  }
}
