class accountModel {
  final int? id;
  final String? name;
  final String email;
  final String? password;
  final String? role;

  accountModel({
    this.id,
    required this.email,
    this.password,
    this.role,
    this.name,
  });

  factory accountModel.fromJson(Map<String, dynamic> json) {
    return accountModel(
      id: json['id'],
      email: json['email'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    };
  }
}
