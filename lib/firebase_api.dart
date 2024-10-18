import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
  //create an instance of Firebase Msg
  final _firebaseMessaging = FirebaseMessaging.instance;

  //function to init notification
  Future<void> initNotifications() async {
    //request permission from user (will prompt user)
    await _firebaseMessaging.requestPermission(
        badge: true,
        alert: true,
        sound: true
    );

    //fetch the FCM token for this device
    final FCMToken = await _firebaseMessaging.getToken();

    //print the token (normally you would send this to your server)
    print('Token: $FCMToken');
  }
}