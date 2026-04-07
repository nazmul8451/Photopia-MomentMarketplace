class StatisticsResponse {
  int? statusCode;
  bool? success;
  String? message;
  StatisticsData? data;

  StatisticsResponse({this.statusCode, this.success, this.message, this.data});

  StatisticsResponse.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? StatisticsData.fromJson(json['data']) : null;
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

class StatisticsData {
  bool? isPremium;
  ProfileViews? profileViews;
  RatingStats? rating;
  List<RegionStats>? viewsByRegion;
  RevenueAnalytics? revenueAnalytics;
  PremiumMetrics? premiumMetrics;

  StatisticsData({
    this.isPremium,
    this.profileViews,
    this.rating,
    this.viewsByRegion,
    this.revenueAnalytics,
    this.premiumMetrics,
  });

  StatisticsData.fromJson(Map<String, dynamic> json) {
    isPremium = json['isPremium'];
    profileViews = json['profileViews'] != null
        ? ProfileViews.fromJson(json['profileViews'])
        : null;
    rating = json['rating'] != null ? RatingStats.fromJson(json['rating']) : null;
    if (json['viewsByRegion'] != null) {
      viewsByRegion = <RegionStats>[];
      json['viewsByRegion'].forEach((v) {
        viewsByRegion!.add(RegionStats.fromJson(v));
      });
    }
    revenueAnalytics = json['revenueAnalytics'] != null
        ? RevenueAnalytics.fromJson(json['revenueAnalytics'])
        : null;
    premiumMetrics = json['premiumMetrics'] != null
        ? PremiumMetrics.fromJson(json['premiumMetrics'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isPremium'] = isPremium;
    if (profileViews != null) {
      data['profileViews'] = profileViews!.toJson();
    }
    if (rating != null) {
      data['rating'] = rating!.toJson();
    }
    if (viewsByRegion != null) {
      data['viewsByRegion'] = viewsByRegion!.map((v) => v.toJson()).toList();
    }
    if (revenueAnalytics != null) {
      data['revenueAnalytics'] = revenueAnalytics!.toJson();
    }
    if (premiumMetrics != null) {
      data['premiumMetrics'] = premiumMetrics!.toJson();
    }
    return data;
  }
}

class PremiumMetrics {
  MostViewedProject? mostViewedProject;
  num? conversionRate;
  num? bounceRate;
  AvgRevenueVsCategory? avgRevenueVsCategory;
  num? averageOrderValue;
  num? repeatRate;
  num? avgConversionTime;

  PremiumMetrics({
    this.mostViewedProject,
    this.conversionRate,
    this.bounceRate,
    this.avgRevenueVsCategory,
    this.averageOrderValue,
    this.repeatRate,
    this.avgConversionTime,
  });

  PremiumMetrics.fromJson(Map<String, dynamic> json) {
    mostViewedProject = json['mostViewedProject'] != null
        ? MostViewedProject.fromJson(json['mostViewedProject'])
        : null;
    conversionRate = json['conversionRate'];
    bounceRate = json['bounceRate'];
    avgRevenueVsCategory = json['avgRevenueVsCategory'] != null
        ? AvgRevenueVsCategory.fromJson(json['avgRevenueVsCategory'])
        : null;
    averageOrderValue = json['averageOrderValue'];
    repeatRate = json['repeatRate'];
    avgConversionTime = json['avgConversionTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (mostViewedProject != null) {
      data['mostViewedProject'] = mostViewedProject!.toJson();
    }
    data['conversionRate'] = conversionRate;
    data['bounceRate'] = bounceRate;
    if (avgRevenueVsCategory != null) {
      data['avgRevenueVsCategory'] = avgRevenueVsCategory!.toJson();
    }
    data['averageOrderValue'] = averageOrderValue;
    data['repeatRate'] = repeatRate;
    data['avgConversionTime'] = avgConversionTime;
    return data;
  }
}

class MostViewedProject {
  String? serviceId;
  String? title;
  int? views;

  MostViewedProject({this.serviceId, this.title, this.views});

  MostViewedProject.fromJson(Map<String, dynamic> json) {
    serviceId = json['serviceId'];
    title = json['title'];
    views = json['views'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['serviceId'] = serviceId;
    data['title'] = title;
    data['views'] = views;
    return data;
  }
}

class AvgRevenueVsCategory {
  num? userAvg;
  num? categoryAvg;
  String? categoryName;

  AvgRevenueVsCategory({this.userAvg, this.categoryAvg, this.categoryName});

  AvgRevenueVsCategory.fromJson(Map<String, dynamic> json) {
    userAvg = json['userAvg'];
    categoryAvg = json['categoryAvg'];
    categoryName = json['categoryName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userAvg'] = userAvg;
    data['categoryAvg'] = categoryAvg;
    data['categoryName'] = categoryName;
    return data;
  }
}

class ProfileViews {
  int? count;
  int? change;
  PerformanceVsCategoryViews? performanceVsCategory;

  ProfileViews({this.count, this.change, this.performanceVsCategory});

  ProfileViews.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    change = json['change'];
    performanceVsCategory = json['performanceVsCategory'] != null
        ? PerformanceVsCategoryViews.fromJson(json['performanceVsCategory'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['count'] = count;
    data['change'] = change;
    if (performanceVsCategory != null) {
      data['performanceVsCategory'] = performanceVsCategory!.toJson();
    }
    return data;
  }
}

class PerformanceVsCategoryViews {
  int? categoryAverage;
  int? percentageAbove;

  PerformanceVsCategoryViews({this.categoryAverage, this.percentageAbove});

  PerformanceVsCategoryViews.fromJson(Map<String, dynamic> json) {
    categoryAverage = json['categoryAverage'];
    percentageAbove = json['percentageAbove'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['categoryAverage'] = categoryAverage;
    data['percentageAbove'] = percentageAbove;
    return data;
  }
}

class RatingStats {
  num? score;
  int? reviews;
  PerformanceVsCategoryRating? performanceVsCategory;

  RatingStats({this.score, this.reviews, this.performanceVsCategory});

  RatingStats.fromJson(Map<String, dynamic> json) {
    score = json['score'];
    reviews = json['reviews'];
    performanceVsCategory = json['performanceVsCategory'] != null
        ? PerformanceVsCategoryRating.fromJson(json['performanceVsCategory'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['score'] = score;
    data['reviews'] = reviews;
    if (performanceVsCategory != null) {
      data['performanceVsCategory'] = performanceVsCategory!.toJson();
    }
    return data;
  }
}

class PerformanceVsCategoryRating {
  num? categoryAverage;
  int? percentageHigher;

  PerformanceVsCategoryRating({this.categoryAverage, this.percentageHigher});

  PerformanceVsCategoryRating.fromJson(Map<String, dynamic> json) {
    categoryAverage = json['categoryAverage'];
    percentageHigher = json['percentageHigher'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['categoryAverage'] = categoryAverage;
    data['percentageHigher'] = percentageHigher;
    return data;
  }
}

class RegionStats {
  String? city;
  num? percentage;
  int? count;

  RegionStats({this.city, this.percentage, this.count});

  RegionStats.fromJson(Map<String, dynamic> json) {
    city = json['city'];
    percentage = json['percentage'];
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['city'] = city;
    data['percentage'] = percentage;
    data['count'] = count;
    return data;
  }
}

class RevenueAnalytics {
  num? currentMonth;
  num? previousMonth;
  num? percentageChange;
  List<dynamic>? weeklyBreakdown;
  num? averagePerPeriod;
  num? bestPerforming;

  RevenueAnalytics(
      {this.currentMonth,
      this.previousMonth,
      this.percentageChange,
      this.weeklyBreakdown,
      this.averagePerPeriod,
      this.bestPerforming});

  RevenueAnalytics.fromJson(Map<String, dynamic> json) {
    currentMonth = json['currentMonth'];
    previousMonth = json['previousMonth'];
    percentageChange = json['percentageChange'];
    if (json['weeklyBreakdown'] != null) {
      weeklyBreakdown = <dynamic>[];
      json['weeklyBreakdown'].forEach((v) {
        weeklyBreakdown!.add(v);
      });
    }
    averagePerPeriod = json['averagePerPeriod'];
    bestPerforming = json['bestPerforming'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['currentMonth'] = currentMonth;
    data['previousMonth'] = previousMonth;
    data['percentageChange'] = percentageChange;
    if (weeklyBreakdown != null) {
      data['weeklyBreakdown'] = weeklyBreakdown!.toList();
    }
    data['averagePerPeriod'] = averagePerPeriod;
    data['bestPerforming'] = bestPerforming;
    return data;
  }
}
