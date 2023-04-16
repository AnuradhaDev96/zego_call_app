import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../change_notifiers/call_state_change_notifier.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import 'call_history_page.dart';
import 'upgrade_to_premium_page.dart';
import 'user_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sam Caller"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => UpgradeToPremiumPage()));
            },
            icon: const Icon(Icons.star, size: 20.0),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CallHistoryPage()));
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
                Center(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseService.buildViews,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final List<QueryDocumentSnapshot>? documents = snapshot.data?.docs;

                      if (documents == null || documents.isEmpty) {
                        return const Text("No Data");
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: documents.length,
                        itemBuilder: (context, index) {
                          final model = UserModel.fromMap(documents[index].data() as Map<String, dynamic>);
                          if (!FirebaseService.isCurrentUser(model.email)) {
                            return UserCard(userModel: model);
                          }
                          return const SizedBox.shrink();
                        },
                      );
                    },
                  ),
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