import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PushNotificationService {
  static const String vapidKey =
      'BJ1lDwjL7ca9STDtqMzTJngTlQbtmpBDar_ORlOt_0m5ngILHhEwE5p1jddWSHE3N9OQF_vSddjw8tCiAwIjXGg';

  static Future<bool> initializeAndSaveToken() async {
    try {
      final messaging = FirebaseMessaging.instance;

      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        return false;
      }

      if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
        return false;
      }

      final token = await messaging.getToken(vapidKey: vapidKey);

      if (token == null || token.isEmpty) {
        return false;
      }

      final prefs = await SharedPreferences.getInstance();

      final eventId = prefs.getString('eventId') ?? 'zurich_2026';
      final guestId = prefs.getString('guestId') ?? '';
      final guestName = prefs.getString('guestName') ?? '';
      final guestCode = prefs.getString('guestCode') ?? '';
      final whatsappNumber = prefs.getString('whatsappNumber') ?? '';

      await FirebaseFirestore.instance
          .collection('event_push_tokens')
          .doc(token)
          .set({
        'token': token,
        'eventId': eventId,
        'guestId': guestId,
        'guestName': guestName,
        'guestCode': guestCode,
        'whatsappNumber': whatsappNumber,
        'platform': 'web',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    } catch (error) {
      return false;
    }
  }
}