import 'package:flutter/material.dart';

enum CallType {
  missed,
  outgoing,
  received
}

extension ToString on CallType {
  String toDisplayString() {
    switch (this) {
      case CallType.missed:
        return "Missed call";
      case CallType.outgoing:
        return "Outgoing call";
      case CallType.received:
        return "Received";
    }
  }
}

extension ToWidget on CallType {
  Widget toDisplayIcon() {
    switch(this) {
      case CallType.missed:
        return const Icon(Icons.call_missed, size: 18.0, color: Color(0xFFE70404));
      case CallType.outgoing:
        return const Icon(Icons.call_made_outlined, size: 18.0, color: Color(0xFF0B8804));
      case CallType.received:
        return const Icon(Icons.call_received_rounded, size: 18.0, color: Color(0xFF0E2DE8));
    }
  }
}

CallType toCallTypeEnumValue(String value) {
  switch(value) {
    case "Missed call":
      return CallType.missed;
    case "Outgoing call":
      return CallType.outgoing;
    case "Received":
      return CallType.received;
    default:
      throw Exception("Unknown type");
  }
}