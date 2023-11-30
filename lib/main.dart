import 'dart:async';

import 'package:erzmobil/ERZmobilUserApp.dart';
import 'package:erzmobil/debug/Logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Logger.init();

  FlutterError.onError = (FlutterErrorDetails details) {
    print("Error From INSIDE FRAME_WORK");
    Logger.info('Uncaught Exception: ');
    if (details.stack != null) {
      String exception = details.exception.toString();
      Logger.e(exception);
      Logger.e(details.stack!.toString());
    }
  };

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    try {
      if (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS) {
        runZonedGuarded(() async {
          await Firebase.initializeApp();

          await FirebaseMessaging.instance
              .setForegroundNotificationPresentationOptions(
            alert: false,
            badge: false,
            sound: false,
          );

          runApp(ERZmobilUserApp());
        }, (error, stackTrace) {
          Logger.info('Uncaught Exception: ');
          Logger.e(error.toString());
          String exception = error.toString();
          Logger.e(exception);
          Logger.e(stackTrace.toString());

          Logger.error(error, stackTrace);
        });
      } else {
        runApp(ERZmobilUserApp());
      }
    } catch (e) {
      Logger.info('Uncaught Exception: ');
      Logger.e(e.toString());
      Logger.error(e, StackTrace.current);
    }
  });
}
