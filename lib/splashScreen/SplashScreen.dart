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
import 'package:erzmobil/push/PushNotificationService.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:erzmobil/Constants.dart';
import 'package:erzmobil/home/HomeScreen.dart';
import 'package:erzmobil/model/PreferenceHolder.dart';
import 'package:erzmobil/model/User.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _loadStorage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.splashScreenColor,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Center(
          child: new Image.asset(
            Strings.assetPathLogo,
            fit: BoxFit.cover,
            repeat: ImageRepeat.noRepeat,
          ),
        ),
      ),
    );
  }

  void _loadStorage() async {
    await PreferenceHolder().init();
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      await PushNotificationService().initializeFirebase();
    }
    await User().checkBackendConnection();
    await User().loadCognitoData();
    await User().loadUser();
    await User().restoreSessionFromStore();
    await User().loadPublicDataFromBE();
    Timer(Duration(seconds: 3), _pushMeasuredRoute);
  }

  void _pushMeasuredRoute() {
    Widget widgetToPush = new ChangeNotifierProvider(
      create: (context) => User(),
      child: HomeScreen(),
    );

    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => widgetToPush));
  }
}
