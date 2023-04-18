import 'package:flutter/material.dart';

import '../models/user_model.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({Key? key, required this.currentUser}) : super(key: key);
  final UserModel currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Profile"),
      ),
      body: Hero(
        tag: 'user_profile',
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFEE6614),
                radius: 40.0,
                child: Center(
                  child: Text(
                    currentUser.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 30.0),
                  ),
                ),
              ),
              const SizedBox(height: 15.0),
              Text(
                currentUser.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 28.0,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10.0),
              Text(
                "${currentUser.email}",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.0,
                  color: Color(0xFF575757),
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}
