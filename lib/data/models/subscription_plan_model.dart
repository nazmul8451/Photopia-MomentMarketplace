class SubscriptionPlanModel {
  int? statusCode;
  bool? success;
  String? message;
  List<SubscriptionPlanData>? data;

  SubscriptionPlanModel({this.statusCode, this.success, this.message, this.data});

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    List<SubscriptionPlanData> plans = [];
    if (json['data'] != null) {
      json['data'].forEach((v) {
        plans.add(SubscriptionPlanData.fromJson(v));
      });
    }
    return SubscriptionPlanModel(
      statusCode: json['statusCode'],
      success: json['success'],
      message: json['message'],
      data: plans,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusCode'] = statusCode;
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SubscriptionPlanData {
  String? sId;
  String? name;
  String? description;
  double? price;
  String? currency;
  String? interval;
  int? intervalCount;
  int? trialPeriodDays;
  List<String>? features;
  int? maxTeamMembers;
  int? maxServices;
  bool? isActive;
  String? stripePriceId;
  String? stripeProductId;
  List<String>? userTypes;
  int? priority;
  String? createdAt;
  String? updatedAt;

  SubscriptionPlanData({
    this.sId,
    this.name,
    this.description,
    this.price,
    this.currency,
    this.interval,
    this.intervalCount,
    this.trialPeriodDays,
    this.features,
    this.maxTeamMembers,
    this.maxServices,
    this.isActive,
    this.stripePriceId,
    this.stripeProductId,
    this.userTypes,
    this.priority,
    this.createdAt,
    this.updatedAt,
  });

  factory SubscriptionPlanData.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanData(
      sId: json['_id'],
      name: json['name'],
      description: json['description'],
      price: double.tryParse(json['price']?.toString() ?? '0.0'),
      currency: json['currency'],
      interval: json['interval'],
      intervalCount: json['intervalCount'],
      trialPeriodDays: json['trialPeriodDays'],
      features: json['features'] != null ? List<String>.from(json['features']) : [],
      maxTeamMembers: json['maxTeamMembers'],
      maxServices: json['maxServices'],
      isActive: json['isActive'],
      stripePriceId: json['stripePriceId'],
      stripeProductId: json['stripeProductId'],
      userTypes: json['userTypes'] != null ? List<String>.from(json['userTypes']) : [],
      priority: json['priority'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['description'] = description;
    data['price'] = price;
    data['currency'] = currency;
    data['interval'] = interval;
    data['intervalCount'] = intervalCount;
    data['trialPeriodDays'] = trialPeriodDays;
    data['features'] = features;
    data['maxTeamMembers'] = maxTeamMembers;
    data['maxServices'] = maxServices;
    data['isActive'] = isActive;
    data['stripePriceId'] = stripePriceId;
    data['stripeProductId'] = stripeProductId;
    data['userTypes'] = userTypes;
    data['priority'] = priority;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }

  String get formattedPrice {
    String currencySymbol = '\$';
    final String currentCurrency = (currency ?? 'usd').toLowerCase();
    
    if (currentCurrency == 'usd') currencySymbol = '\$';
    if (currentCurrency == 'eur') currencySymbol = '€';
    if (currentCurrency == 'bdt') currencySymbol = '৳';
    
    return '$currencySymbol${price?.toStringAsFixed(2) ?? '0.00'}';
  }

  String get formattedInterval {
    if (interval == 'month') return '/month';
    if (interval == 'year') return '/year';
    return '/${interval ?? ''}';
  }
}
