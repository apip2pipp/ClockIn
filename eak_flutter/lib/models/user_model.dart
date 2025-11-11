class User {
  final int id;
  final int? companyId;
  final String name;
  final String email;
  final String? phone;
  final String? position;
  final String? employeeId;
  final String? photo;
  final String role;
  final bool isActive;
  final Company? company;

  User({
    required this.id,
    this.companyId,
    required this.name,
    required this.email,
    this.phone,
    this.position,
    this.employeeId,
    this.photo,
    required this.role,
    required this.isActive,
    this.company,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      companyId: json['company_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      position: json['position'],
      employeeId: json['employee_id'],
      photo: json['photo'],
      role: json['role'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      company: json['company'] != null
          ? Company.fromJson(json['company'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'name': name,
      'email': email,
      'phone': phone,
      'position': position,
      'employee_id': employeeId,
      'photo': photo,
      'role': role,
      'is_active': isActive,
    };
  }

  String get photoUrl {
    if (photo == null) return '';
    return 'http://127.0.0.1:8000/storage/$photo';
  }
}

class Company {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final double? latitude;
  final double? longitude;
  final int radius;
  final String workStartTime;
  final String workEndTime;
  final bool isActive;
  final String? logo;

  Company({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.latitude,
    this.longitude,
    required this.radius,
    required this.workStartTime,
    required this.workEndTime,
    required this.isActive,
    this.logo,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      latitude: json['latitude'] != null
          ? double.parse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.parse(json['longitude'].toString())
          : null,
      radius: json['radius'] ?? 100,
      workStartTime: json['work_start_time'],
      workEndTime: json['work_end_time'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      logo: json['logo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'work_start_time': workStartTime,
      'work_end_time': workEndTime,
      'is_active': isActive,
      'logo': logo,
    };
  }
}
