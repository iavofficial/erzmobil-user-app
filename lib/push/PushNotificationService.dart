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
import 'dart:io';

import 'package:erzmobil/Constants.dart';
import 'package:erzmobil/debug/Logger.dart';
import 'package:erzmobil/model/User.dart';
import 'package:erzmobil/utils/Utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:overlay_support/overlay_support.dart';

class PushNotificationService {
  static final PushNotificationService _instance =
      new PushNotificationService._internal();

  factory PushNotificationService() {
    return _instance;
  }

  late void Function(int) changePage;
  late BuildContext context;
  bool isFirebaseInitialized = false;
  bool isMessageHandlingInitialized = false;
  bool isAuthorized = false;
  String? fcmToken;

  PushNotificationService._internal();

  Future initializeFirebase() async {
    if (!isFirebaseInitialized) {
      isFirebaseInitialized = true;

      NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      Logger.debug(
          "FirebaseMessaging: User granted permission: ${settings.authorizationStatus}");

      // If you want to test the push notification locally,
      // you need to get the token and input to the Firebase console
      // https://console.firebase.google.com/project/YOUR_PROJECT_ID/notification/compose

      isAuthorized =
          settings.authorizationStatus == AuthorizationStatus.authorized;

      if (isAuthorized) {
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          Logger.info('FlutterFire Messaging: Got APNs token: $apnsToken');
        }

        try {
          fcmToken = await FirebaseMessaging.instance.getToken();
          Logger.info("FirebaseMessaging token: $fcmToken");
        } catch (e) {
          final bool isConnected =
              await InternetConnectionChecker().hasConnection;
          if (!isConnected) {
            Logger.info("ERROR_FAILED_NO_INTERNET");
          }
        }
      }
    }
  }

  Future initialisePushMessageHandling(
      BuildContext context, Function(int) changePage) async {
    this.changePage = changePage;
    this.context = context;

    if (isAuthorized && !isMessageHandlingInitialized) {
      isMessageHandlingInitialized = true;

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        Logger.info(
            "FirebaseMessaging: push message received: " + message.toString());
        handleMessage(message, this.context);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        Logger.info("FirebaseMessaging: App opened via push message");
        RemoteNotification? notification = message.notification;

        if ((message.data["id"] != null && message.data["id"] == 4)) {
          changePage(1);
          handleSystemMessage(message);
        }

        if (User().isLoggedIn() &&
            notification != null &&
            notification.titleLocKey != null &&
            notification.bodyLocKey != null) {
          if (defaultTargetPlatform == TargetPlatform.android) {
            if ((notification.titleLocKey ==
                        "notification_title_journey_update" ||
                    notification.titleLocKey ==
                        "notification_title_journey_cancelled") &&
                (notification.bodyLocKey ==
                        "notification_message_journey_update" ||
                    notification.bodyLocKey ==
                        "notification_message_journey_cancelled")) {
              User().loadJourneys();
              changePage(1);
            }
          } else if (defaultTargetPlatform == TargetPlatform.iOS) {
            if ((notification.titleLocKey == "notificationTitleJourneyUpdate" ||
                    notification.titleLocKey ==
                        "notificationTitleJourneyCancelled") &&
                (notification.bodyLocKey ==
                        "notificationMessageJourneyUpdate" ||
                    notification.bodyLocKey ==
                        "notificationMessageJourneyCancelled")) {
              User().loadJourneys();
              changePage(1);
            }
          }
        }
      });
    }
  }

  Future<String?> getFCMToken() async {
    if (isFirebaseInitialized) {
      if (fcmToken != null) {
        return fcmToken;
      } else {
        final bool isConnected =
            await InternetConnectionChecker().hasConnection;
        if (!isConnected) {
          Logger.info("ERROR_FAILED_NO_INTERNET");
          return null;
        }

        return FirebaseMessaging.instance.getToken();
      }
    } else
      return null;
  }

  void handleMessage(RemoteMessage message, BuildContext buildContext) {
    RemoteNotification? notification = message.notification;

    if (User().isLoggedIn() && notification != null) {
      String title = "";
      String messageText = "";

      if (notification.titleLocKey != null && notification.bodyLocKey != null) {
        DateTime? date = message.data["date"] != null
            ? DateTime.parse(message.data["date"] as String)
            : null;

        if (message.data["id"] != null) {
          String id = message.data["id"];

          switch (id) {
            case "2":
              title = AppLocalizations.of(buildContext)!
                  .notificationTitleJourneyUpdate;
              User().loadJourneys();
              if (checkStartStopData(message)) {
                messageText = AppLocalizations.of(buildContext)!
                    .notificationMessageJourneyUpdate(message.data["start"],
                        message.data["stop"], Utils().getDateAsString(date));
              }
              break;
            case "3":
              title = AppLocalizations.of(buildContext)!
                  .notificationTitleJourneyCancelled;
              User().loadJourneys();
              if (checkStartStopData(message)) {
                messageText = AppLocalizations.of(buildContext)!
                    .notificationMessageJourneyCancelled(message.data["start"],
                        message.data["stop"], Utils().getDateAsString(date));
              }
              break;
            case "4":
              handleSystemMessage(message);
              break;
            case "6":
              title = AppLocalizations.of(buildContext)!
                  .notificationTitleDelayInformation;
              if (checkStartStopData(message)) {
                messageText = AppLocalizations.of(buildContext)!
                    .notificationMessageDelayInformation(
                        message.data["start"],
                        message.data["stop"],
                        Utils().getDateAsString(date),
                        message.data["min"]);
              }
              break;
            case "8":
              title = AppLocalizations.of(buildContext)!
                  .notificationTitleJourneyReminder;
              if (checkStartStopData(message) && message.data["min"] != null) {
                messageText = AppLocalizations.of(buildContext)!
                    .notificationMessageJourneyReminder(message.data["start"],
                        message.data["stop"], Utils().getDateAsString(date));
              }
              break;
            default:
          }
        }

        if (title.isNotEmpty && messageText.isNotEmpty) {
          _logMessage(title, messageText);

          _showNotification(messageText);
        }
      }
    }
  }

  void handleSystemMessage(RemoteMessage message) {
    Locale currentLocale = Localizations.localeOf(context);
    if (currentLocale.languageCode == "de") {
      _showNotification(message.data["systemInformation_de"]);
    } else {
      _showNotification(message.data["systemInformation_en"]);
    }
    Logger.info(currentLocale.languageCode);
  }

  void _showNotification(String messageText) {
    showSimpleNotification(
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            messageText,
            style: CustomTextStyles.bodyBlack,
          ),
        ), trailing: Builder(builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 0),
        child: IconButton(
          icon: Icon(
            Icons.close,
            color: CustomColors.black,
          ),
          onPressed: () {
            OverlaySupportEntry.of(context)!.dismiss();
          },
        ),
      );
    }),
        background: CustomColors.green,
        autoDismiss: false,
        slideDismissDirection: DismissDirection.up);
  }

  bool checkStartStopData(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    return notification != null &&
        message.data["start"] != null &&
        message.data["stop"] != null;
  }

  void _logMessage(String title, String message) {
    try {
      Logger.info("FirebaseMessaging: $title - $message");
    } catch (e) {}
  }
}
