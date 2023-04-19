import 'package:flutter/material.dart';

enum OnlineStatus { online, away, offline }

extension ToString on OnlineStatus {
  String toDisplayString() {
    switch (this) {
      case OnlineStatus.online:
        return "Online";
      case OnlineStatus.away:
        return "Away";
      case OnlineStatus.offline:
        return "Offline";
      default:
        return "Offline";
    }
  }
}

extension ToWidget on OnlineStatus {
  Widget toDisplayIcon([double iconSize = 6.0]) {
    switch (this) {
      case OnlineStatus.online:
        return Icon(Icons.check, weight: 5, color: Colors.white, size: iconSize);//Colors.green
      case OnlineStatus.away:
        return Icon(Icons.access_time_rounded, weight: 10, color: Colors.white, size: iconSize);//Color(0xFFD7B70E)
      case OnlineStatus.offline:
        return Icon(Icons.close, weight: 10, color: Colors.white, size: iconSize);//Color(0xFF3F3F3F)
    }
  }

  Color toBadgeColor() {
    switch (this) {
      case OnlineStatus.online:
        return Colors.green;
      case OnlineStatus.away:
        return const Color(0xFFD7B70E);
      case OnlineStatus.offline:
        return const Color(0xFF3F3F3F);
    }
  }
}

OnlineStatus toOnlineStatusEnumValue(String value) {
  switch (value) {
    case "Online":
      return OnlineStatus.online;
    case "Away":
      return OnlineStatus.away;
    case "Offline":
      return OnlineStatus.offline;
    default:
      return OnlineStatus.offline;
  }
}
