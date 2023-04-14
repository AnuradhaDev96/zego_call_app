class UserModel {
  String email, name, username;
  String? fcmToken;

  UserModel({required this.email, required this.name, required this.username, this.fcmToken});

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'username': username,
      'fcmToken': fcmToken,
    };
  }

  UserModel.fromMap(Map<String, dynamic> map):
      email = map["email"],
      name = map["name"],
      fcmToken = map["fcmToken"],
      username = map["username"];
}