import 'enums/subscription.dart';

class UserModel {
  String email, name, username;
  String? fcmToken;
  Subscription currentPackage = Subscription.free;

  UserModel({required this.email, required this.name, required this.username, this.fcmToken});

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'username': username,
      'fcmToken': fcmToken,
      'currentPackage': currentPackage.toDisplayString(),
    };
  }

  UserModel.fromMap(Map<String, dynamic> map)
      : email = map["email"],
        name = map["name"],
        fcmToken = map["fcmToken"],
        currentPackage =
            map["currentPackage"] == null ? Subscription.free : toSubscriptionEnumValue(map["currentPackage"]),
        username = map["username"];
}