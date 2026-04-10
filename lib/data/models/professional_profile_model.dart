import 'package:photopia/core/network/urls.dart';

class ProfessionalProfileModel {
  final int? profileViews;
  final int? projects;
  final int? responseRate;
  final String? id;
  final User? user;
  final List<dynamic>? specialties;
  final List<dynamic>? portfolio;
  final List<dynamic>? language;
  final bool? isVerified;
  final double? rating;
  final int? reviewCount;
  final String? bio;
  final String? specialty;
  final String? coverPhoto;
  final Statistics? statistics;
  final bool isSubscribed;
  final String? subscriptionStatus;
  final List<dynamic>? documents;

  ProfessionalProfileModel({
    this.profileViews,
    this.projects,
    this.responseRate,
    this.id,
    this.user,
    this.specialties,
    this.portfolio,
    this.language,
    this.isVerified,
    this.rating,
    this.reviewCount,
    this.bio,
    this.specialty,
    this.coverPhoto,
    this.statistics,
    this.isSubscribed = false,
    this.subscriptionStatus,
    this.documents,
  });

  factory ProfessionalProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfessionalProfileModel(
      profileViews: json['profileViews'],
      projects: json['projects'],
      responseRate: json['responseRate'],
      id: json['_id'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      specialties: json['specialties'],
      portfolio: (json['portfolio'] as List?)?.map((e) => formatUrl(e)).toList(),
      language: json['language'],
      isVerified: json['isVerified'] == true,
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'],
      bio: json['bio'],
      specialty: json['specialty'],
      coverPhoto: formatUrl(json['coverPhoto']),
      statistics: json['statistics'] != null
          ? Statistics.fromJson(json['statistics'])
          : null,
      isSubscribed: json['isStripeConnected'] == true || json['isVerified'] == true || json['isSubscribed'] == true,
      subscriptionStatus: json['subscriptionStatus']?.toString(),
      documents: (json['documents'] as List?)?.map((e) => formatUrl(e)).toList(),
    );
  }

  static String? formatUrl(dynamic url) {
    if (url == null) return null;
    String urlString = url.toString();
    if (urlString.isEmpty) return null;
    if (urlString.startsWith('http') || urlString.startsWith('assets/')) return urlString;
    
    final String base = Urls.baseUrl.endsWith('/') 
        ? Urls.baseUrl.substring(0, Urls.baseUrl.length - 1) 
        : Urls.baseUrl;
    
    // Most backends serve static files at /uploads/ or directly. 
    // Based on your JSON, it starts with /images, /portfolio, etc.
    final String path = urlString.startsWith('/') ? urlString : '/$urlString';
    return "$base$path";
  }
}

class User {
  final String? id;
  final String? name;
  final String? email;
  final String? profile;
  final String? description;
  final bool? verified;
  final bool isSubscribed;
  final String? subscriptionStatus;

  User({
    this.id,
    this.name,
    this.email,
    this.profile,
    this.description,
    this.verified,
    this.isSubscribed = false,
    this.subscriptionStatus,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      profile: ProfessionalProfileModel.formatUrl(json['profile']),
      description: json['description'],
      verified: json['verified'] == true,
      isSubscribed: json['subscription'] != null || json['isSubscribed'] == true,
      subscriptionStatus: json['subscriptionStatus']?.toString(),
    );
  }
}

class Statistics {
  final Bookings? bookings;
  final Revenue? revenue;

  Statistics({this.bookings, this.revenue});

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      bookings: json['bookings'] != null
          ? Bookings.fromJson(json['bookings'])
          : null,
      revenue: json['revenue'] != null
          ? Revenue.fromJson(json['revenue'])
          : null,
    );
  }
}

class Bookings {
  final int? count;
  final int? thisWeek;

  Bookings({this.count, this.thisWeek});

  factory Bookings.fromJson(Map<String, dynamic> json) {
    return Bookings(
      count: json['count'],
      thisWeek: json['thisWeek'],
    );
  }
}

class Revenue {
  final int? amount;
  final int? percentageChange;

  Revenue({this.amount, this.percentageChange});

  factory Revenue.fromJson(Map<String, dynamic> json) {
    return Revenue(
      amount: json['amount'],
      percentageChange: json['percentageChange'],
    );
  }
}
