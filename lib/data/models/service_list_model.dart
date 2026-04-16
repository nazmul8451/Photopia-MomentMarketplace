import 'package:photopia/core/network/urls.dart';
import 'package:photopia/data/models/category_model.dart';

class ServiceListModel {
  int? statusCode;
  bool? success;
  String? message;
  ServicePagination? data;

  ServiceListModel({this.statusCode, this.success, this.message, this.data});

  factory ServiceListModel.fromJson(Map<String, dynamic> json) {
    return ServiceListModel(
      statusCode: json['statusCode'],
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? ServicePagination.fromJson(json['data'])
          : null,
    );
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

  factory ServicePagination.fromJson(Map<String, dynamic> json) {
    List<ServiceItem> fetchItems = [];
    if (json['data'] != null) {
      json['data'].forEach((v) {
        fetchItems.add(ServiceItem.fromJson(v));
      });
    }
    return ServicePagination(
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
      data: fetchItems,
    );
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

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      page: json['page'],
      limit: json['limit'],
      total: json['total'],
      totalPages: json['totalPages'],
    );
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
  CategoryModel? category;
  String? subCategory;
  int? price;
  String? currency;
  String? duration;
  LocationInfo? location;
  String? coverMedia;
  String? status;
  bool? isActive;
  bool? isVerified;
  double? rating;
  int? reviews;
  String? description;
  List<String>? tags;
  List<String>? equipment;
  List<dynamic>? gallery;
  String? responseTime;
  int? completedProjects;
  String? serviceType;
  String? theme;
  // Pricing
  String? pricingType; // "HOURLY", "DAILY", "PACKAGE"
  ServicePricingModel? pricingModel;
  List<PricingRule>? pricingRules;
  CancellationPolicy? cancellationPolicy;

  // Travel & Fees
  double? travelFeePerKm;
  bool? allowOutsideRadius;
  double? maxTravelFee;
  int? depositPercentage;

  ServiceItem({
    this.sId,
    this.providerId,
    this.title,
    this.category,
    this.subCategory,
    this.price,
    this.currency,
    this.duration,
    this.location,
    this.coverMedia,
    this.status,
    this.isActive,
    this.isVerified,
    this.rating,
    this.reviews,
    this.description,
    this.tags,
    this.equipment,
    this.gallery,
    this.responseTime,
    this.completedProjects,
    this.serviceType,
    this.theme,
    this.pricingType,
    this.pricingModel,
    this.pricingRules,
    this.cancellationPolicy,
    this.travelFeePerKm,
    this.allowOutsideRadius,
    this.maxTravelFee,
    this.depositPercentage,
  });

  /// Returns true if this service has at least one package defined
  bool get hasPackages {
    return pricingType == 'PACKAGE' &&
        pricingModel != null &&
        (pricingModel!.packages?.isNotEmpty ?? false);
  }

  static String? _formatUrl(dynamic url) {
    if (url == null) return null;

    String? urlString;
    if (url is String) {
      urlString = url;
    } else if (url is Map && url.containsKey('url')) {
      urlString = url['url']?.toString();
    } else {
      urlString = url.toString();
    }

    if (urlString == null || urlString.isEmpty) return null;
    if (urlString.startsWith('http')) return urlString;

    // Ensure exactly one slash between baseUrl and urlString
    final String base = Urls.baseUrl.endsWith('/')
        ? Urls.baseUrl.substring(0, Urls.baseUrl.length - 1)
        : Urls.baseUrl;
    final String path = urlString.startsWith('/') ? urlString : '/$urlString';

    return "$base$path";
  }

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      sId: json['_id'],
      providerId: json['providerId'] != null
          ? ProviderInfo.fromJson(json['providerId'])
          : null,
      title: json['title'],
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'])
          : null,
      subCategory: json['subCategory']?.toString(),
      price: json['price'],
      currency: json['currency'],
      duration: json['duration'],
      location: json['location'] != null
          ? LocationInfo.fromJson(json['location'])
          : null,
      coverMedia: _formatUrl(
        json['coverMedia'] ??
            json['cover_media'] ??
            json['image'] ??
            (json['gallery'] != null && (json['gallery'] as List).isNotEmpty
                ? (json['gallery'] as List).first
                : null),
      ),
      status: json['status']?.toString(),
      isActive: json['isActive'] == true || json['isActive'] == 'true',
      isVerified: json['isVerified'] == true || json['isVerified'] == 'true',
      rating: double.tryParse(json['rating']?.toString() ?? '0.0') ?? 0.0,
      reviews: int.tryParse(json['reviews']?.toString() ?? '0') ?? 0,
      description: json['description'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      equipment: json['equipment'] != null
          ? List<String>.from(json['equipment'])
          : null,
      gallery: json['gallery'] != null
          ? (json['gallery'] as List)
                .map((e) => _formatUrl(e))
                .where((e) => e != null && e.isNotEmpty)
                .toList()
          : null,
      responseTime: json['responseTime']?.toString(),
      completedProjects: int.tryParse(
        json['completedProjects']?.toString() ?? '',
      ),
      serviceType: json['serviceType']?.toString(),
      theme: json['theme']?.toString(),
      pricingType: json['pricingType']?.toString(),
      pricingModel: json['pricingModel'] != null
          ? ServicePricingModel.fromJson(json['pricingModel'])
          : null,
      pricingRules: json['pricingRules'] != null
          ? (json['pricingRules'] as List)
                .map((r) => PricingRule.fromJson(r))
                .toList()
          : null,
      cancellationPolicy: json['cancellationPolicy'] != null
          ? CancellationPolicy.fromJson(json['cancellationPolicy'])
          : null,
      travelFeePerKm: (json['travelFeePerKm'] as num?)?.toDouble(),
      allowOutsideRadius: json['allowOutsideRadius'] ?? false,
      maxTravelFee: (json['maxTravelFee'] as num?)?.toDouble(),
      depositPercentage: json['depositPercentage'] ?? 50,
    );
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
    data['subCategory'] = subCategory;
    data['price'] = price;
    data['currency'] = currency;
    data['duration'] = duration;
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['coverMedia'] = coverMedia;
    data['status'] = status;
    data['isActive'] = isActive;
    data['isVerified'] = isVerified;
    data['rating'] = rating;
    data['reviews'] = reviews;
    data['description'] = description;
    data['tags'] = tags;
    data['equipment'] = equipment;
    data['gallery'] = gallery;
    data['responseTime'] = responseTime;
    data['completedProjects'] = completedProjects;
    data['serviceType'] = serviceType;
    data['theme'] = theme;
    data['pricingType'] = pricingType;
    if (pricingModel != null) {
      data['pricingModel'] = pricingModel!.toJson();
    }
    if (pricingRules != null) {
      data['pricingRules'] = pricingRules!.map((r) => r.toJson()).toList();
    }
    if (cancellationPolicy != null) {
      data['cancellationPolicy'] = cancellationPolicy!.toJson();
    }
    data['travelFeePerKm'] = travelFeePerKm;
    data['allowOutsideRadius'] = allowOutsideRadius;
    data['maxTravelFee'] = maxTravelFee;
    data['depositPercentage'] = depositPercentage;
    return data;
  }
}

class ServicePricingModel {
  String? type;
  double? dailyRate;
  int? dailyHours;
  double? weekdayHourlyRate;
  double? weekendHourlyRate;
  List<ServicePackage>? packages;

  ServicePricingModel({
    this.type,
    this.dailyRate,
    this.dailyHours,
    this.weekdayHourlyRate,
    this.weekendHourlyRate,
    this.packages,
  });

  factory ServicePricingModel.fromJson(Map<String, dynamic> json) {
    return ServicePricingModel(
      type: json['type'],
      dailyRate: (json['dailyRate'] as num?)?.toDouble(),
      dailyHours: json['dailyHours'],
      weekdayHourlyRate: (json['weekdayHourlyRate'] as num?)?.toDouble(),
      weekendHourlyRate: (json['weekendHourlyRate'] as num?)?.toDouble(),
      packages: json['packages'] != null
          ? (json['packages'] as List)
                .map((p) => ServicePackage.fromJson(p))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'dailyRate': dailyRate,
    'dailyHours': dailyHours,
    'weekdayHourlyRate': weekdayHourlyRate,
    'weekendHourlyRate': weekendHourlyRate,
    if (packages != null) 'packages': packages!.map((p) => p.toJson()).toList(),
  };
}

class ServicePackage {
  String? name;
  double? price;
  int? duration;
  String? description;
  List<String>? includes;

  ServicePackage({
    this.name,
    this.price,
    this.duration,
    this.description,
    this.includes,
  });

  factory ServicePackage.fromJson(Map<String, dynamic> json) {
    return ServicePackage(
      name: json['name'],
      price: (json['price'] as num?)?.toDouble(),
      duration: json['duration'],
      description: json['description'],
      includes: json['includes'] != null
          ? List<String>.from(json['includes'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'price': price,
    'duration': duration,
    'description': description,
    'includes': includes,
  };
}

class PricingRule {
  final String ruleType; // 'peak_hour', 'weekend', 'holiday', etc.
  final String modifierType; // 'percentage', 'fixed', 'multiplier'
  final double modifierValue;
  final int priority;

  PricingRule({
    required this.ruleType,
    required this.modifierType,
    required this.modifierValue,
    required this.priority,
  });

  factory PricingRule.fromJson(Map<String, dynamic> json) {
    return PricingRule(
      ruleType: json['ruleType'],
      modifierType: json['modifierType'],
      modifierValue: (json['modifierValue'] as num).toDouble(),
      priority: json['priority'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'ruleType': ruleType,
    'modifierType': modifierType,
    'modifierValue': modifierValue,
    'priority': priority,
  };
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

  factory CancellationPolicy.fromJson(Map<String, dynamic> json) {
    return CancellationPolicy(
      freeCancellationHours: json['freeCancellationHours'],
      partialRefundHours: json['partialRefundHours'],
      noRefundHours: json['noRefundHours'],
    );
  }

  Map<String, dynamic> toJson() => {
    'freeCancellationHours': freeCancellationHours,
    'partialRefundHours': partialRefundHours,
    'noRefundHours': noRefundHours,
  };
}

class ProviderInfo {
  String? sId;
  String? name;
  String? email;
  String? profile;

  ProviderInfo({this.sId, this.name, this.email, this.profile});

  static String? _formatUrl(dynamic url) {
    if (url == null) return null;
    String? urlString;
    if (url is String) {
      urlString = url;
    } else if (url is Map && url.containsKey('url')) {
      urlString = url['url']?.toString();
    } else {
      urlString = url.toString();
    }

    if (urlString == null || urlString.isEmpty) return null;
    if (urlString.startsWith('http')) return urlString;

    // Ensure exactly one slash between baseUrl and urlString
    final String base = Urls.baseUrl.endsWith('/')
        ? Urls.baseUrl.substring(0, Urls.baseUrl.length - 1)
        : Urls.baseUrl;
    final String path = urlString.startsWith('/') ? urlString : '/$urlString';

    return "$base$path";
  }

  factory ProviderInfo.fromJson(Map<String, dynamic> json) {
    return ProviderInfo(
      sId: json['_id'],
      name: json['name'],
      email: json['email'],
      profile: _formatUrl(json['profile']),
    );
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

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      type: json['type'],
      country: json['country'],
      city: json['city'],
      address: json['address'],
      serviceRadiusKm: json['serviceRadiusKm'],
    );
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
