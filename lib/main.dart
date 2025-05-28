/**
 * Copyright © 2025 IAV GmbH Ingenieurgesellschaft Auto und Verkehr, All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 */
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
