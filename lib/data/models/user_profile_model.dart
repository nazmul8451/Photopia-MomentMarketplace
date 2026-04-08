class UserProfileModel {
  final String? id;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? profile;
  final String? location;
  final String? role;
  final String? description;
  final String? specialty;
  final List<String>? languages;
  final String? createdAt;
  final bool isSubscribed;
  final String? subscriptionStatus;

  UserProfileModel({
    this.id,
    this.fullName,
    this.email,
    this.phone,
    this.profile,
    this.location,
    this.role,
    this.description,
    this.specialty,
    this.languages,
    this.createdAt,
    this.isSubscribed = false,
    this.subscriptionStatus,
  });

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
    
    // Basic prefixing logic if needed, but UserProfileModel doesn't have Urls.baseUrl imported.
    // However, the API should return relative paths.
    // For now, let's keep it simple and just return the string.
    return urlString;
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    // Handling location if it's an object from API
    String? tempLocation;
    if (json['location'] != null) {
      if (json['location'] is String) {
        tempLocation = json['location'];
      } else if (json['location'] is Map) {
        tempLocation = json['location']['city']?.toString() ?? 'Custom Location';
      }
    }

    return UserProfileModel(
      id: json['_id']?.toString(),
      fullName: (json['name'] ?? json['fullName'])?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      profile: _formatUrl(json['profile']),
      location: tempLocation ?? json['location']?.toString(),
      role: (json['activeRole'] ?? json['role'])?.toString(),
      description: json['description']?.toString(),
      specialty: json['specialty']?.toString(),
      languages: json['languages'] != null ? List<String>.from(json['languages']) : null,
      createdAt: json['createdAt']?.toString(),
      isSubscribed: json['subscription'] != null || json['isSubscribed'] == true,
      subscriptionStatus: json['subscriptionStatus']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'profile': profile,
      'location': location,
      'role': role,
      'description': description,
      'specialty': specialty,
      'languages': languages,
      'createdAt': createdAt,
    };
  }
}
