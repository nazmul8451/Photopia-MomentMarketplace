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
  final Statistics? statistics;

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
    this.statistics,
  });

  factory ProfessionalProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfessionalProfileModel(
      profileViews: json['profileViews'],
      projects: json['projects'],
      responseRate: json['responseRate'],
      id: json['_id'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      specialties: json['specialties'],
      portfolio: json['portfolio'],
      language: json['language'],
      isVerified: json['isVerified'],
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'],
      statistics: json['statistics'] != null
          ? Statistics.fromJson(json['statistics'])
          : null,
    );
  }
}

class User {
  final String? id;
  final String? name;
  final String? email;
  final String? profile;
  final String? description;
  final bool? verified;

  User({
    this.id,
    this.name,
    this.email,
    this.profile,
    this.description,
    this.verified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      profile: json['profile'],
      description: json['description'],
      verified: json['verified'],
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
