import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:badges/badges.dart' as badges;
import '../change_notifiers/call_state_change_notifier.dart';
import '../common/common_utils.dart';
import '../models/enums/online_status.dart';
import '../models/enums/subscription.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import 'call_history_page.dart';
import 'upgrade_to_premium_page.dart';
import 'user_card.dart';
import 'user_profile_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sam Caller"),
        actions: [
          StreamBuilder(
              stream: FirebaseService.currentUserSnapshot,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
                  return const SizedBox.shrink();
                }

                print("snapshot of doc: ${snapshot.data?.data() as Map<String, dynamic>}");
                var currentUser = UserModel.fromMap(snapshot.data?.data() as Map<String, dynamic>);
                if (currentUser.currentPackage == Subscription.premium) {
                  return const SizedBox.shrink();
                } else {
                  return IconButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => UpgradeToPremiumPage()));
                    },
                    icon: const Icon(Icons.star, size: 20.0),
                  );
                }
              }),
          IconButton(
            onPressed: () {
              CommonUtils.navigateToPageBasedOnSubscription(context, const CallHistoryPage());
            },
            icon: const Icon(Icons.history, size: 20.0),
          ),
          IconButton(
            onPressed: () {
              FirebaseService.logout();
            },
            icon: const Icon(Icons.logout, size: 20.0),
          ),
        ],
      ),
      body: Consumer<CallStateChangeNotifier>(
          builder: (BuildContext context, CallStateChangeNotifier callStatusNotifier, child) {
        return Stack(
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: StreamBuilder(
                          stream: FirebaseService.currentUserSnapshot,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
                              return const SizedBox.shrink();
                            }

                            print("snapshot of doc: ${snapshot.data?.data() as Map<String, dynamic>}");
                            var currentUser = UserModel.fromMap(snapshot.data?.data() as Map<String, dynamic>);
                            Color accountColor =
                                currentUser.currentPackage == Subscription.premium ? Colors.amber : Colors.white;
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Material(
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8.0),
                                    topRight: Radius.circular(8.0),
                                    bottomRight: Radius.circular(32.0),
                                    bottomLeft: Radius.circular(8.0),
                                  ),
                                ),
                                elevation: 4.0,
                                // color: const Color(0xFFF5E0B7),
                                child: Ink(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: [Color(0xFFB4B4B4), Color(0xFF464646)],
                                        begin: Alignment.topRight,
                                        end: Alignment.bottomLeft),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8.0),
                                      topRight: Radius.circular(8.0),
                                      bottomRight: Radius.circular(32.0),
                                      bottomLeft: Radius.circular(8.0),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (_) => UserProfilePage(
                                                      currentUser: currentUser,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Hero(
                                                tag: 'user_profile',
                                                child: badges.Badge(
                                                  badgeStyle: badges.BadgeStyle(
                                                    badgeColor: currentUser.onlineStatus.toBadgeColor(),
                                                    elevation: 5.0,
                                                  ),
                                                  position: badges.BadgePosition.bottomEnd(end: 0.5, bottom: 0.5),
                                                  badgeContent: currentUser.onlineStatus.toDisplayIcon(10.0),
                                                  child: CircleAvatar(
                                                    backgroundColor: const Color(0xFFEE6614),
                                                    radius: 30.0,
                                                    child: Center(
                                                      child: Text(
                                                        currentUser.name.substring(0, 1).toUpperCase(),
                                                        style: const TextStyle(color: Colors.white, fontSize: 20.0),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10.0),
                                            Text(
                                              currentUser.name,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w900, fontSize: 22.0, color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10.0),
                                        Text(
                                          "Email: ${currentUser.email}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16.0,
                                            color: Color(0xFFFCFCFC),
                                          ),
                                        ),
                                        const SizedBox(height: 5.0),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            DecoratedBox(
                                              decoration: BoxDecoration(
                                                // color: Colors.amber,

                                                borderRadius: BorderRadius.circular(8.0),
                                                gradient: LinearGradient(
                                                  stops: const [0.05, 0.05],
                                                  colors: [accountColor, const Color(0xFF1D62B7)],
                                                  begin: Alignment.centerRight,
                                                  end: Alignment.centerLeft,
                                                ),
                                                // border: Border(right: BorderSide(width: 1.0, color: Colors.red))
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: Text(
                                                  "${currentUser.currentPackage.toDisplayString()} Account",
                                                  style: TextStyle(
                                                      shadows: [
                                                        Shadow(
                                                            color: accountColor.withOpacity(0.3),
                                                            offset: const Offset(0.9, -1.2))
                                                      ],
                                                      color: accountColor,
                                                      fontSize: 12.0,
                                                      fontWeight: FontWeight.w500,
                                                      letterSpacing: 0.8),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                  ],
                ),
                const SizedBox(height: 5.0),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseService.buildViews,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final List<QueryDocumentSnapshot>? documents = snapshot.data?.docs;

                    if (documents == null || documents.isEmpty) {
                      return const Text("No Data");
                    }

                    var userList =
                        documents.map((model) => UserModel.fromMap(model.data() as Map<String, dynamic>)).toList();

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        // final model = UserModel.fromMap(documents[index].data() as Map<String, dynamic>);
                        final model = userList[index];
                        if (!FirebaseService.isCurrentUser(model.email)) {
                          return UserCard(userModel: model);
                        }
                        return const SizedBox.shrink();
                      },
                    );
                  },
                ),
              ],
            ),
            Visibility(
              visible: callStatusNotifier.isIncomingCall,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 200.0),
                child: Card(
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                  color: const Color(0xFF2D3B29),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Column(
                      children: [
                        const Text(
                          "Incoming Call",
                          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 20.0),
                        CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          radius: 35.0,
                          child: Center(
                            child: Text(
                              callStatusNotifier.caller == null
                                  ? "N/A"
                                  : callStatusNotifier.caller!.name.substring(0, 1).toUpperCase(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              callStatusNotifier.caller == null ? "N/A" : callStatusNotifier.caller!.name,
                              style: const TextStyle(
                                fontSize: 18.0,
                                // fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

// @override
// Widget build(BuildContext context) {
//   return FutureBuilder<UserModel?>(
//       future: FirebaseService.currentUser,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         if (snapshot.hasData) {
//           UserModel? currentUser = snapshot.data;
//
//           if (currentUser == null) {
//             return const Center(child: Text("Problem in authorization. Please login again"));
//           }
//           return CallInvitationPage(
//             username: currentUser.username,
//             child: Scaffold(
//               appBar: AppBar(
//                 title: const Text("Sam Caller"),
//                 actions: [
//                   IconButton(
//                     onPressed: () {
//                       FirebaseService.logout();
//                     },
//                     icon: const Icon(Icons.logout, size: 20.0),
//                   ),
//                 ],
//               ),
//               body: Center(
//                 child: StreamBuilder<QuerySnapshot>(
//                   stream: FirebaseService.buildViews,
//                   builder: (context, snapshot) {
//                     if (!snapshot.hasData) {
//                       return const Center(child: CircularProgressIndicator());
//                     }
//
//                     final List<QueryDocumentSnapshot>? documents = snapshot.data?.docs;
//
//                     if (documents == null || documents.isEmpty) {
//                       return const Text("No Data");
//                     }
//
//                     return ListView.builder(
//                       shrinkWrap: true,
//                       itemCount: documents.length,
//                       itemBuilder: (context, index) {
//                         final model = UserModel.fromMap(documents[index].data() as Map<String, dynamic>);
//                         if (!FirebaseService.isCurrentUser(model.email)) {
//                           return UserCard(userModel: model);
//                         }
//                         return const SizedBox.shrink();
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ),
//           );
//         }
//
//         return const Center(child: Text("Please wait. We are setting things up."));
//       }
//   );
// }
}
