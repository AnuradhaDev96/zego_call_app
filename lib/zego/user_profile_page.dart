import 'package:badges/badges.dart' as badges;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/user_model.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({Key? key, required this.currentUser}) : super(key: key);
  final UserModel currentUser;

  @override
  Widget build(BuildContext context) {
    var loggedInUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("User Profile"),
      ),
      body: Hero(
          tag: 'user_profile',
          child: ListView(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 35.0),
                  child: badges.Badge(
                    badgeStyle: const badges.BadgeStyle(
                      badgeColor: Colors.green,
                      elevation: 5.0,
                    ),
                    position: badges.BadgePosition.bottomEnd(end: 1, bottom: 1),
                    badgeContent: const Icon(
                      Icons.check,
                      weight: 5,
                      color: Colors.white,
                      size: 15.0,
                    ),
                    child: CircleAvatar(
                      backgroundColor: const Color(0xFFEE6614),
                      radius: 40.0,
                      child: Center(
                        child: Text(
                          currentUser.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 30.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
                    currentUser.email,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.0,
                      color: Color(0xFF575757),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0, top: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(children: [
                            const WidgetSpan(
                              child: Padding(
                                padding: EdgeInsets.only(right: 5.0),
                                child: Icon(
                                  Icons.access_time_outlined,
                                  size: 14.0,
                                  color: Color(0xFFEE6614),
                                ),
                              ),
                            ),
                            const TextSpan(
                              text: "Member since: ",
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: loggedInUser?.metadata.creationTime == null
                                  ? "N/A"
                                  : DateFormat("yyyy-MM-dd HH:mm:ss").format(loggedInUser!.metadata.creationTime!),
                              style: const TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ]),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0, top: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(children: [
                            const WidgetSpan(
                              child: Padding(
                                padding: EdgeInsets.only(right: 5.0),
                                child: Icon(
                                  Icons.online_prediction,
                                  size: 14.0,
                                  color: Color(0xFFEE6614),
                                ),
                              ),
                            ),
                            const TextSpan(
                              text: "Last sign in: ",
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: loggedInUser?.metadata.lastSignInTime == null
                                  ? "N/A"
                                  : DateFormat("yyyy-MM-dd HH:mm:ss").format(loggedInUser!.metadata.lastSignInTime!),
                              style: const TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ]),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => {},
                      style: ElevatedButton.styleFrom(
                        elevation: 8.0,
                        backgroundColor: const Color(0xFFFF4F4F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text("Delete Account"),
                    ),
                  )
                ],
              ),
            ],
          )),
    );
  }
}
