import 'package:flutter/material.dart';

import '../services/firebase_service.dart';
import '../zego/upgrade_to_premium_page.dart';

class CommonUtils {
  static Future<void> navigateToPageBasedOnSubscription(BuildContext context, Widget child) async {
    await FirebaseService.isPremiumAccount.then((isPremium) => isPremium
        ? Navigator.of(context).push(MaterialPageRoute(builder: (_) => child))
        : Navigator.of(context).push(MaterialPageRoute(builder: (_) => UpgradeToPremiumPage())));
  }
}