import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../change_notifiers/call_state_change_notifier.dart';
import '../models/call_history_record.dart';
import '../models/enums/call_type.dart';
import '../services/firebase_service.dart';

class CallHistoryPage extends StatelessWidget {
  const CallHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Call History"),
      ),
      body: Consumer<CallStateChangeNotifier>(
        builder: (BuildContext context, CallStateChangeNotifier callStatusNotifier, child) {
          return Stack(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseService.buildCallHistoryOfCurrentUser,
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
                      final historyRecord = CallHistoryRecord.fromMap(documents.reversed.toList()[index].data() as Map<String, dynamic>);
                      return historyRecordCard(historyRecord);
                    },
                  );
                },
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
        },
      ),
    );
  }

  Widget historyRecordCard(CallHistoryRecord record) {
    return Card(
      color: const Color(0xFFF2F8F4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
      elevation: 5.0,
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 10.0,
          left: 8.0,
          right: 8.0,
          top: 5.0,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
                  radius: 20.0,
                  child: Center(
                    child: Text(
                      record.callerUsername.substring(0, 1).toUpperCase(),
                    ),
                  ),
                ),
                const SizedBox(width: 15.0),
                Text(
                  record.callerUsername,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                const Spacer(),
                actionButton(isVideoCall: false, calleeUsername: record.callerUsername),
                actionButton(calleeUsername: record.callerUsername),
              ],
            ),
            const SizedBox(height: 5.0),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(children: [
                        WidgetSpan(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: record.callResult.toDisplayIcon(),
                          ),
                        ),
                        TextSpan(
                            text: record.callResult.toDisplayString(),
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600))
                      ]),
                    ),
                    Text(
                      record.time == null ? "N/A" : DateFormat("yyyy-MM-dd HH:mm:ss").format(record.time!),
                      style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  ZegoSendCallInvitationButton actionButton({
    required String calleeUsername,
    bool isVideoCall = true,
  }) =>
      ZegoSendCallInvitationButton(
        isVideoCall: isVideoCall,
        invitees: [
          ZegoUIKitUser(
            id: calleeUsername,
            name: calleeUsername,
          )
        ],
        buttonSize: const Size(50.0, 50.0),
        iconSize: const Size(35.0, 35.0),
        onPressed: (String code, String message, List<String> invitees) async {
          CallHistoryRecord record =
              CallHistoryRecord(callResult: CallType.outgoing, time: DateTime.now(), callerUsername: calleeUsername);
          await FirebaseService.saveCallHistoryRecord(record);
        },
        timeoutSeconds: 10,
      );
}
