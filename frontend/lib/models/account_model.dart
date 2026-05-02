class accountModel {
  final int id;
  final String name;
  final String email;
  final String? password;
  final String? role;
  final List phone_number;
  // final List? permissions;

  accountModel({
    required this.id,
    required this.email,
    this.password,
    this.role,
    required this.name,
    required this.phone_number,
    // this.permissions,
  });

  factory accountModel.fromJson(Map<String, dynamic> json) {
    return accountModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      phone_number: json['phone_numbers'],
      role: json['role'],
      // permissions: json['permissions']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'phone_numbers': phone_number,
    };
  }
}

class PermissionsModel {
  final List<String> permissions; 

  PermissionsModel({
     required this.permissions
  });

  factory PermissionsModel.fromJson(Map<String, dynamic> json) {
    return PermissionsModel(
      permissions: List<String>.from(json['permissions'] ?? []),
    );
  }
  bool can(String permissionName) {
    return permissions.contains(permissionName);
  }//much much better now imma set the same in the ui

}


class ChangePasswordModel {
  final dynamic oldPassword;
  final dynamic newPassword;

  ChangePasswordModel({this.oldPassword, this.newPassword});

  Map<String, dynamic> toJson() {
    return {'old_password': oldPassword, 'new_password': newPassword};
  }
}
