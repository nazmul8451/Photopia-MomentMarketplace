class MyListingModel {
  int? statusCode;
  bool? success;
  String? message;
  ListingPagination? data;

  MyListingModel({this.statusCode, this.success, this.message, this.data});

  MyListingModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
    message = json['message'];
    data = json['data'] != null
        ? new ListingPagination.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class ListingPagination {
  Meta? meta;
  List<Listing>? data;

  ListingPagination({this.meta, this.data});

  ListingPagination.fromJson(Map<String, dynamic> json) {
    meta = json['meta'] != null ? new Meta.fromJson(json['meta']) : null;
    if (json['data'] != null) {
      data = <Listing>[];
      json['data'].forEach((v) {
        data!.add(new Listing.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.meta != null) {
      data['meta'] = this.meta!.toJson();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['page'] = this.page;
    data['limit'] = this.limit;
    data['total'] = this.total;
    data['totalPages'] = this.totalPages;
    return data;
  }
}

class Listing {
  String? sId;
  ProviderId? providerId;
  String? title;
  Category? category;
  int? price;
  String? currency;
  String? duration;
  Location? location;
  String? coverMedia;
  String? status;
  bool? isActive;
  String? pricingType;
  ListingPricingModel? pricingModel;

  Listing({
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
    this.pricingType,
    this.pricingModel,
  });

  Listing.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    providerId = json['providerId'] != null
        ? new ProviderId.fromJson(json['providerId'])
        : null;
    title = json['title'];
    category = json['category'] != null
        ? new Category.fromJson(json['category'])
        : null;
    price = json['price'];
    currency = json['currency'];
    duration = json['duration'];
    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;
    coverMedia =
        json['coverMedia'] ??
        json['cover_media'] ??
        json['image'] ??
        (json['gallery'] != null && (json['gallery'] as List).isNotEmpty
            ? (json['gallery'] as List).first
            : null);

    status = json['status'];
    isActive = json['isActive'];
    pricingType = json['pricingType'];
    pricingModel = json['pricingModel'] != null
        ? new ListingPricingModel.fromJson(json['pricingModel'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    if (this.providerId != null) {
      data['providerId'] = this.providerId!.toJson();
    }
    data['title'] = this.title;
    if (this.category != null) {
      data['category'] = this.category!.toJson();
    }
    data['price'] = this.price;
    data['currency'] = this.currency;
    data['duration'] = this.duration;
    if (this.location != null) {
      data['location'] = this.location!.toJson();
    }
    data['coverMedia'] = this.coverMedia;
    data['status'] = this.status;
    data['isActive'] = this.isActive;
    data['pricingType'] = this.pricingType;
    if (this.pricingModel != null) {
      data['pricingModel'] = this.pricingModel!.toJson();
    }
    return data;
  }
}

class ListingPricingModel {
  String? type;
  double? dailyRate;
  int? dailyHours;
  double? weekdayHourlyRate;
  double? weekendHourlyRate;
  List<ListingPackage>? packages;

  ListingPricingModel({
    this.type,
    this.dailyRate,
    this.dailyHours,
    this.weekdayHourlyRate,
    this.weekendHourlyRate,
    this.packages,
  });

  ListingPricingModel.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    dailyRate = (json['dailyRate'] as num?)?.toDouble();
    dailyHours = json['dailyHours'];
    weekdayHourlyRate = (json['weekdayHourlyRate'] as num?)?.toDouble();
    weekendHourlyRate = (json['weekendHourlyRate'] as num?)?.toDouble();
    if (json['packages'] != null) {
      packages = <ListingPackage>[];
      json['packages'].forEach((v) {
        packages!.add(new ListingPackage.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['dailyRate'] = this.dailyRate;
    data['dailyHours'] = this.dailyHours;
    data['weekdayHourlyRate'] = this.weekdayHourlyRate;
    data['weekendHourlyRate'] = this.weekendHourlyRate;
    if (this.packages != null) {
      data['packages'] = this.packages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ListingPackage {
  String? name;
  double? price;
  int? duration;
  String? description;
  List<String>? includes;

  ListingPackage({
    this.name,
    this.price,
    this.duration,
    this.description,
    this.includes,
  });

  ListingPackage.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    price = (json['price'] as num?)?.toDouble();
    duration = json['duration'];
    description = json['description'];
    includes = json['includes'] != null
        ? List<String>.from(json['includes'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['price'] = this.price;
    data['duration'] = this.duration;
    data['description'] = this.description;
    data['includes'] = this.includes;
    return data;
  }
}

class Category {
  String? sId;
  String? name;
  String? image;

  Category({this.sId, this.name, this.image});

  Category.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['image'] = this.image;
    return data;
  }
}

class ProviderId {
  String? sId;
  String? name;
  String? email;
  String? profile;

  ProviderId({this.sId, this.name, this.email, this.profile});

  ProviderId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    profile = json['profile'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['profile'] = this.profile;
    return data;
  }
}

class Location {
  String? type;
  String? country;
  String? city;
  String? address;
  int? serviceRadiusKm;
  String? nId;

  Location({
    this.type,
    this.country,
    this.city,
    this.address,
    this.serviceRadiusKm,
    this.nId,
  });

  Location.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    country = json['country'];
    city = json['city'];
    address = json['address'];
    serviceRadiusKm = json['serviceRadiusKm'];
    nId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['country'] = this.country;
    data['city'] = this.city;
    data['address'] = this.address;
    data['serviceRadiusKm'] = this.serviceRadiusKm;
    data['_id'] = this.nId;
    return data;
  }
}
