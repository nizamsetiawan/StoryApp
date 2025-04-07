class UserModel {
  final String id;
  final String name;
  final String email;
  final String token;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['userId'] ?? '',
      name: json['name'] ?? '',
      email: '',
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': id,
    'name': name,
    'token': token,
  };

  static UserModel empty() => UserModel(
    id: '',
    name: '',
    email: '',
    token: '',
  );
}