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
import 'package:erzmobil/LifeCycleManager.dart';
import 'package:erzmobil/splashScreen/SplashScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:overlay_support/overlay_support.dart';
import 'Constants.dart';
import 'package:erzmobil/debug/Logger.dart';

class ERZmobilUserApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Logger.info("App Start");

    return LifeCycleManager(
      child: OverlaySupport.global(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          title: 'ERZmobil App',
          supportedLocales: [
            const Locale('en'),
            const Locale('de'),
          ],
          highContrastTheme: ThemeData(
            dialogBackgroundColor: CustomColors.white,
            inputDecorationTheme: InputDecorationTheme(
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: CustomColors.lightGrey))),
            brightness: Brightness.light,
            primaryColor: CustomColors.black,
            primarySwatch:
                CustomColors.white, //createMaterialColor(Color(0xff419eb1)),
            primaryTextTheme:
                TextTheme(titleLarge: CustomTextStyles.titleWhite),
            colorScheme: ColorScheme.fromSwatch()
                .copyWith(secondary: CustomColors.white),
            scaffoldBackgroundColor: CustomColors.white,
            cardTheme: CardTheme(
              color: CustomColors.black,
            ),
            dividerTheme: const DividerThemeData(
              color: CustomColors.lightGrey,
            ),
            iconTheme: IconThemeData(
                color: CustomColors.white, opacity: 1.0, size: 40.0),
            textTheme: TextTheme(
              titleLarge: CustomTextStyles.title,
              bodyMedium: CustomTextStyles.bodyBlack,
              labelLarge: CustomTextStyles.bodyWhite,
            ),
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: CustomColors.anthracite,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(5.0)),
                  backgroundColor: CustomColors.marine,
                  foregroundColor: Colors.white),
            ),
            fontFamily: 'SourceSansPro',
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          theme: ThemeData(
            dialogBackgroundColor: CustomColors.white,
            inputDecorationTheme: InputDecorationTheme(
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: CustomColors.lightGrey))),
            brightness: Brightness.light,
            primaryColor: CustomColors.darkGrey,
            primarySwatch:
                CustomColors.white, //createMaterialColor(Color(0xff419eb1)),
            primaryTextTheme:
                TextTheme(titleLarge: CustomTextStyles.titleWhite),
            colorScheme:
                ColorScheme.fromSwatch().copyWith(secondary: CustomColors.mint),
            scaffoldBackgroundColor: CustomColors.white,
            cardTheme: CardTheme(
              color: CustomColors.anthracite,
            ),
            dividerTheme: const DividerThemeData(
              color: CustomColors.lightGrey,
            ),
            iconTheme: IconThemeData(
                color: CustomColors.white, opacity: 1.0, size: 40.0),
            textTheme: TextTheme(
              titleLarge: CustomTextStyles.title,
              bodyMedium: CustomTextStyles.bodyGrey,
              labelLarge: CustomTextStyles.bodyWhite,
            ),
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: CustomColors.anthracite,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(5.0)),
                  backgroundColor: CustomColors.mint,
                  foregroundColor: CustomColors.white),
            ),
            fontFamily: 'SourceSansPro',
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: SplashScreen(),
        ),
      ),
    );
  }

  MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    strengths.forEach((strength) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    });
    return MaterialColor(color.value, swatch);
  }
}
