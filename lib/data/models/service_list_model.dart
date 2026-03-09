class ServiceListModel {
  int? statusCode;
  bool? success;
  String? message;
  ServicePagination? data;

  ServiceListModel({this.statusCode, this.success, this.message, this.data});

  ServiceListModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
    message = json['message'];
    data = json['data'] != null
        ? ServicePagination.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusCode'] = statusCode;
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class ServicePagination {
  Meta? meta;
  List<ServiceItem>? data;

  ServicePagination({this.meta, this.data});

  ServicePagination.fromJson(Map<String, dynamic> json) {
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    if (json['data'] != null) {
      data = <ServiceItem>[];
      json['data'].forEach((v) {
        data!.add(ServiceItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (meta != null) {
      data['meta'] = meta!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['page'] = page;
    data['limit'] = limit;
    data['total'] = total;
    data['totalPages'] = totalPages;
    return data;
  }
}

class ServiceItem {
  String? sId;
  ProviderInfo? providerId;
  String? title;
  CategoryInfo? category;
  int? price;
  String? currency;
  String? duration;
  LocationInfo? location;
  String? coverMedia;
  String? status;
  bool? isActive;
  double? rating;
  int? reviews;

  ServiceItem({
    this.sId,
    this.providerId,
    this.title,
    this.category,
    this.price,
    this.currency,
    this.duration,
    this.location,
    this.coverMedia,
    this.status,
    this.isActive,
    this.rating,
    this.reviews,
  });

  ServiceItem.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    providerId = json['providerId'] != null
        ? ProviderInfo.fromJson(json['providerId'])
        : null;
    title = json['title'];
    category = json['category'] != null
        ? CategoryInfo.fromJson(json['category'])
        : null;
    price = json['price'];
    currency = json['currency'];
    duration = json['duration'];
    location = json['location'] != null
        ? LocationInfo.fromJson(json['location'])
        : null;
    coverMedia = json['coverMedia'];
    status = json['status'];
    isActive = json['isActive'];
    rating = (json['rating'] ?? 0.0).toDouble();
    reviews = json['reviews'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    if (providerId != null) {
      data['providerId'] = providerId!.toJson();
    }
    data['title'] = title;
    if (category != null) {
      data['category'] = category!.toJson();
    }
    data['price'] = price;
    data['currency'] = currency;
    data['duration'] = duration;
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['coverMedia'] = coverMedia;
    data['status'] = status;
    data['isActive'] = isActive;
    data['rating'] = rating;
    data['reviews'] = reviews;
    return data;
  }
}

class ProviderInfo {
  String? sId;
  String? name;
  String? email;
  String? profile;

  ProviderInfo({this.sId, this.name, this.email, this.profile});

  ProviderInfo.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    profile = json['profile'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['email'] = email;
    data['profile'] = profile;
    return data;
  }
}

class CategoryInfo {
  String? sId;
  String? name;
  String? image;

  CategoryInfo({this.sId, this.name, this.image});

  CategoryInfo.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['image'] = image;
    return data;
  }
}

class LocationInfo {
  String? type;
  String? country;
  String? city;
  String? address;
  int? serviceRadiusKm;

  LocationInfo({
    this.type,
    this.country,
    this.city,
    this.address,
    this.serviceRadiusKm,
  });

  LocationInfo.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    country = json['country'];
    city = json['city'];
    address = json['address'];
    serviceRadiusKm = json['serviceRadiusKm'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['country'] = country;
    data['city'] = city;
    data['address'] = address;
    data['serviceRadiusKm'] = serviceRadiusKm;
    return data;
  }
}
