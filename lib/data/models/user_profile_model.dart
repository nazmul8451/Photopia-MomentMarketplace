class UserProfileModel {
  final String? id;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? profile;
  final String? location;
  final String? role;

  UserProfileModel({
    this.id,
    this.fullName,
    this.email,
    this.phone,
    this.profile,
    this.location,
    this.role,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    // Handling location if it's an object from API
    String? tempLocation;
    if (json['location'] != null) {
      if (json['location'] is String) {
        tempLocation = json['location'];
      } else if (json['location'] is Map) {
        tempLocation =
            'Custom Location'; // Or format latitude/longitude logic if needed
      }
    }

    return UserProfileModel(
      id: json['_id'],
      fullName: json['name'] ?? json['fullName'],
      email: json['email'],
      phone: json['phone'],
      profile: json['profile'],
      location: tempLocation ?? json['location']?.toString(), // Ensure fallback
      role: json['activeRole'] ?? json['role'],
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
    };
  }
}
