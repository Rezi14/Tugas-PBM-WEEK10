// Model untuk data Role pengguna
class Role {
  final int id;
  final String name;

  Role({required this.id, required this.name});

  /// Membuat objek Role dari JSON response API
  factory Role.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is String) return int.tryParse(val) ?? 0;
      return (val as num).toInt();
    }
    return Role(
      id: parseInt(json['id']),
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

// Model untuk data Kelas pengguna
class ClassData {
  final int id;
  final String name;

  ClassData({required this.id, required this.name});

  /// Membuat objek ClassData dari JSON response API
  factory ClassData.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is String) return int.tryParse(val) ?? 0;
      return (val as num).toInt();
    }
    return ClassData(
      id: parseInt(json['id']),
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

// Model untuk data User yang login
class User {
  final int id;
  final String name;
  final String username;
  final Role role;
  final ClassData classData;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.role,
    required this.classData,
  });

  /// Membuat objek User dari JSON response API
  factory User.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is String) return int.tryParse(val) ?? 0;
      return (val as num).toInt();
    }

    return User(
      id: parseInt(json['id']),
      name: json['name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      role: Role.fromJson(json['role'] ?? {}),
      classData: ClassData.fromJson(json['class'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'username': username,
        'role': role.toJson(),
        'class': classData.toJson(),
      };
}

extension RoleParser on Role {
  static int parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is String) return int.tryParse(val) ?? 0;
    return (val as num).toInt();
  }
}
