import 'dart:convert';

class ProviderServiceModel {
  int? statusCode;
  bool? success;
  String? message;
  Data? data;

  ProviderServiceModel({
    this.statusCode,
    this.success,
    this.message,
    this.data,
  });

  ProviderServiceModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
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

class Data {
  ProviderId? providerId;
  String? title;
  String? description;
  Category? category;
  List<String>? tags;
  List<String>? equipment;
  int? price;
  String? currency;
  String? pricingType;
  double? travelFeePerKm;
  bool? allowOutsideRadius;
  int? maxTravelFee;
  double? depositPercentage;
  CancellationPolicy? cancellationPolicy;
  PricingModel? pricingModel;
  String? duration;
  Location? location;
  List<dynamic>? gallery;
  String? status;
  bool? isVerified;
  bool? isActive;
  String? sId;
  List<PricingRules>? pricingRules;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? id;

  Data({
    this.providerId,
    this.title,
    this.description,
    this.category,
    this.tags,
    this.equipment,
    this.price,
    this.currency,
    this.pricingType,
    this.travelFeePerKm,
    this.allowOutsideRadius,
    this.maxTravelFee,
    this.depositPercentage,
    this.cancellationPolicy,
    this.pricingModel,
    this.duration,
    this.location,
    this.gallery,
    this.status,
    this.isVerified,
    this.isActive,
    this.sId,
    this.pricingRules,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.id,
  });

  Data.fromJson(Map<String, dynamic> json) {
    providerId = json['providerId'] != null
        ? new ProviderId.fromJson(json['providerId'])
        : null;
    title = json['title'];
    description = json['description'];
    category = json['category'] != null
        ? new Category.fromJson(json['category'])
        : null;
    tags = json['tags'] != null ? List<String>.from(json['tags']) : null;
    equipment = json['equipment'] != null
        ? List<String>.from(json['equipment'])
        : null;
    price = json['price'];
    currency = json['currency'];
    pricingType = json['pricingType'];
    travelFeePerKm = json['travelFeePerKm']?.toDouble();
    allowOutsideRadius = json['allowOutsideRadius'];
    maxTravelFee = json['maxTravelFee'];
    depositPercentage = json['depositPercentage']?.toDouble();
    cancellationPolicy = json['cancellationPolicy'] != null
        ? new CancellationPolicy.fromJson(json['cancellationPolicy'])
        : null;
    pricingModel = json['pricingModel'] != null
        ? new PricingModel.fromJson(json['pricingModel'])
        : null;
    duration = json['duration'];
    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;
    gallery = json['gallery'] != null
        ? List<dynamic>.from(json['gallery'])
        : null;
    status = json['status'];
    isVerified = json['isVerified'];
    isActive = json['isActive'];
    sId = json['_id'];
    if (json['pricingRules'] != null) {
      pricingRules = <PricingRules>[];
      json['pricingRules'].forEach((v) {
        pricingRules!.add(new PricingRules.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.providerId != null) {
      data['providerId'] = this.providerId!.toJson();
    }
    data['title'] = this.title;
    data['description'] = this.description;
    if (this.category != null) {
      data['category'] = this.category!.toJson();
    }
    data['tags'] = this.tags;
    data['equipment'] = this.equipment;
    data['price'] = this.price;
    data['currency'] = this.currency;
    data['pricingType'] = this.pricingType;
    data['travelFeePerKm'] = this.travelFeePerKm;
    data['allowOutsideRadius'] = this.allowOutsideRadius;
    data['maxTravelFee'] = this.maxTravelFee;
    data['depositPercentage'] = this.depositPercentage;
    if (this.cancellationPolicy != null) {
      data['cancellationPolicy'] = this.cancellationPolicy!.toJson();
    }
    if (this.pricingModel != null) {
      data['pricingModel'] = this.pricingModel!.toJson();
    }
    data['duration'] = this.duration;
    if (this.location != null) {
      data['location'] = this.location!.toJson();
    }
    if (this.gallery != null) {
      data['gallery'] = this.gallery!.toList();
    }
    data['status'] = this.status;
    data['isVerified'] = this.isVerified;
    data['isActive'] = this.isActive;
    data['_id'] = this.sId;
    if (this.pricingRules != null) {
      data['pricingRules'] = this.pricingRules!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['id'] = this.id;
    return data;
  }
}

class PricingModel {
  String? type;
  List<Packages>? packages;

  PricingModel({this.type, this.packages});

  PricingModel.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    if (json['packages'] != null) {
      packages = <Packages>[];
      json['packages'].forEach((v) {
        packages!.add(new Packages.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    if (this.packages != null) {
      data['packages'] = this.packages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Packages {
  String? name;
  int? price;
  int? duration;
  String? description;
  List<String>? includes;

  Packages({
    this.name,
    this.price,
    this.duration,
    this.description,
    this.includes,
  });

  Packages.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    price = json['price'];
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

class PricingRules {
  String? ruleType;
  String? modifierType;
  int? modifierValue;
  int? priority;

  PricingRules({
    this.ruleType,
    this.modifierType,
    this.modifierValue,
    this.priority,
  });

  PricingRules.fromJson(Map<String, dynamic> json) {
    ruleType = json['ruleType'];
    modifierType = json['modifierType'];
    modifierValue = json['modifierValue'];
    priority = json['priority'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ruleType'] = this.ruleType;
    data['modifierType'] = this.modifierType;
    data['modifierValue'] = this.modifierValue;
    data['priority'] = this.priority;
    return data;
  }
}

class ProviderId {
  String? sId;
  String? name;
  String? email;
  String? profile;
  String? id;

  ProviderId({this.sId, this.name, this.email, this.profile, this.id});

  ProviderId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    profile = json['profile'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['profile'] = this.profile;
    data['id'] = this.id;
    return data;
  }
}

class Category {
  String? sId;
  String? name;
  String? image;
  String? id;

  Category({this.sId, this.name, this.image, this.id});

  Category.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    image = json['image'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['image'] = this.image;
    data['id'] = this.id;
    return data;
  }
}

class CancellationPolicy {
  int? freeCancellationHours;
  int? partialRefundHours;
  int? noRefundHours;

  CancellationPolicy({
    this.freeCancellationHours,
    this.partialRefundHours,
    this.noRefundHours,
  });

  CancellationPolicy.fromJson(Map<String, dynamic> json) {
    freeCancellationHours = json['freeCancellationHours'];
    partialRefundHours = json['partialRefundHours'];
    noRefundHours = json['noRefundHours'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['freeCancellationHours'] = this.freeCancellationHours;
    data['partialRefundHours'] = this.partialRefundHours;
    data['noRefundHours'] = this.noRefundHours;
    return data;
  }
}

class Location {
  String? type;
  String? country;
  String? city;
  String? address;
  int? serviceRadiusKm;
  String? sId;

  Location({
    this.type,
    this.country,
    this.city,
    this.address,
    this.serviceRadiusKm,
    this.sId,
  });

  Location.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    country = json['country'];
    city = json['city'];
    address = json['address'];
    serviceRadiusKm = json['serviceRadiusKm'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['country'] = this.country;
    data['city'] = this.city;
    data['address'] = this.address;
    data['serviceRadiusKm'] = this.serviceRadiusKm;
    data['_id'] = this.sId;
    return data;
  }
}
