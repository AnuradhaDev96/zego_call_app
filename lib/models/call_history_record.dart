import 'package:cloud_firestore/cloud_firestore.dart';

import 'enums/call_type.dart';

class CallHistoryRecord {
  DateTime? time;
  CallType callResult;
  String callerUsername;

  CallHistoryRecord({required this.callResult, required this.time, required this.callerUsername});

  Map<String, dynamic> toMap() {
    return {
      'callResult': callResult.toDisplayString(),
      'time': time,
      'callerUsername': callerUsername,
    };
  }

  CallHistoryRecord.fromMap(Map<String, dynamic> map):
        callResult = toCallTypeEnumValue(map["callResult"]),
        time = map["time"] == null ? null : (map["time"] as Timestamp).toDate(),
        callerUsername = map["callerUsername"];
}