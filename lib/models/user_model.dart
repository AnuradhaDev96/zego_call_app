class UserModel {
  String email, name, username;

  UserModel({required this.email, required this.name, required this.username});

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'username': username,
    };
  }

  UserModel.fromMap(Map<String, dynamic> map):
      email = map["email"],
      name = map["name"],
      username = map["username"];
}