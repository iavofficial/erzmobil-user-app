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
import 'package:flutter/material.dart';

class Expressions {
  static final RegExp regExpName = RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
}

class Strings {
  Strings._();

  static const String appName = 'ERZmobil';
  static const String cancellationFee = "0,50€";
  static const int cancellationHours = 24;

  static const String assetPathBus = 'assets/ic_bus.png';
  static const String assetPathLogo = 'assets/Logo_4c_mitverlauf.png';
  static const String assetPathRoute = 'assets/outline_route_black_36dp.png';
  static const String assetPathLocationMarker = 'assets/location_on.png';
  static const String assetPathLocationEndMarker = 'assets/flag_fill.png';

  static const String prefKeyCode = 'verificationCodeMode';

  static const String IMPRINT_URL = 'https://smartcity-zwoenitz.de/impressum/';
  static const String ABOUT_ERZMOBIL_URL = 'https://www.erzmobil.de/';
  static const String MAILTO_URL = 'mailto:erzmobil@smartcity-zwoenitz.de';
  static const String BLOCKED_USER_ERZMOBIL_URL =
      'https://sperrung.erzmobil.de';
  static const String DATAPRIVACY_URL =
      'https://smartcity-zwoenitz.de/erzmobil-info/#privacy';
  static const String TERMS_OF_TRANSPORTATION =
      '';

  static const String ACCESSIBILITY_LINK =
      'https://smartcity-zwoenitz.de/erzmobil-info/#barrierefreiheit';

  static const String SUPPORT_PHONE_NUMBER = "";

  /// The following part contains the custom endpoints for the backend communication

  static const String COGNITO_DATA_URL_DIRECTUS = "/customendpoints/cognito";
  static const String USER_CAN_BOOK_URL_DIRECTUS = "/customendpoints/canbook";

  static const String STOPS_URL_BACKEND = "/stops";
  static const String STOPS_URL_DIRECTUS = "/items/stop";
  static const String TOKENS_URL_BACKEND = "/tokens";
  static const String TOKENS_URL_DIRECTUS = "/customendpoints/token";
  static const String BUS_POSITIONS_URL_BACKEND = "/Buses/positions";
  static const String BUS_POSITIONS_URL_DIRECTUS =
      "/items/bus?fields=id,last_position,last_position_updated_at";
  static const String ORDERS_URL_BACKEND = '/orders';
  static const String ORDERS_DELETE_URL_DIRECTUS = "/items/order";
  static const String ORDERS_URL_DIRECTUS =
      "/items/order?fields=*.*&limit=9999";

  static const String TICKET_TYPES_URL = "/items/tickettype?sort[]=sortId";
  static const String USERID_URL_DIRECTUS = "/users/me";
  static const String NEW_BACKEND_AVAILABILITY =
      "/items/NewBackendAvailability";

  static const String DEFAULT_TICKET_TYPE = 'keines';

  static const String FLEXIBLE_OPTION_EARLIER = "earlier";
  static const String FLEXIBLE_OPTION_LATER = "later";
}

class CustomIconThemeData {
  CustomIconThemeData._();

  static const IconThemeData navigationIconMint =
      const IconThemeData(color: CustomColors.mint, opacity: 1.0, size: 30.0);
  static const IconThemeData navigationIconGrey = const IconThemeData(
      color: CustomColors.darkGrey, opacity: 1.0, size: 30.0);
  static const IconThemeData navigationIconWhite =
      const IconThemeData(color: Colors.white, opacity: 1.0, size: 30.0);
  static const IconThemeData navigationIconMarine =
      const IconThemeData(color: CustomColors.marine, opacity: 1.0, size: 30.0);
}

class CustomButtonStyles {
  CustomButtonStyles._();

  static final ButtonStyle flatButtonStyle = TextButton.styleFrom(
    padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 15.0),
    disabledBackgroundColor: CustomColors.lightGrey,
    shape: new RoundedRectangleBorder(
      borderRadius: new BorderRadius.circular(10.0),
    ),
    backgroundColor: CustomColors.mint,
  );
}

class CustomTextStyles {
  CustomTextStyles._();

  static const TextStyle title = const TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
      color: CustomColors.darkGrey);
  static const TextStyle titleWhite = const TextStyle(
      fontSize: 16.0, fontWeight: FontWeight.bold, color: CustomColors.white);
  static const TextStyle titleGrey = const TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
      color: CustomColors.darkGrey);
  static const TextStyle headlineGrey = const TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.normal,
      color: CustomColors.darkGrey);
  static const TextStyle headlineWhite = const TextStyle(
      fontSize: 18.0, fontWeight: FontWeight.normal, color: CustomColors.white);
  static const TextStyle bodyGrey = const TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      color: CustomColors.darkGrey);
  static const TextStyle bodyGrey2 = const TextStyle(
      fontSize: 15.0,
      fontWeight: FontWeight.normal,
      color: CustomColors.darkGrey);
  static const TextStyle bodyGreyBold2 = const TextStyle(
      fontSize: 15.0,
      fontWeight: FontWeight.bold,
      color: CustomColors.darkGrey);
  static const TextStyle bodyGreyUnderlined = const TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      decoration: TextDecoration.underline,
      color: CustomColors.darkGrey);
  static const TextStyle bodyGreyBold = const TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.bold,
    color: CustomColors.darkGrey,
  );
  static const TextStyle bodyMintSmallBold = const TextStyle(
      fontSize: 12.0, fontWeight: FontWeight.bold, color: CustomColors.mint);
  static const TextStyle bodyMintBold = const TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.bold,
    color: CustomColors.mint,
  );
  static const TextStyle bodyMintBold2 = const TextStyle(
      fontSize: 16.0, fontWeight: FontWeight.bold, color: CustomColors.mint);
  static const TextStyle bodyWhiteBold = const TextStyle(
      fontSize: 14.0, fontWeight: FontWeight.bold, color: CustomColors.white);
  static const TextStyle bodyBlackBold = const TextStyle(
      fontSize: 13.0, fontWeight: FontWeight.bold, color: CustomColors.black);
  static const TextStyle bodyBlackHeadlineBold = const TextStyle(
      fontSize: 15.0, fontWeight: FontWeight.bold, color: CustomColors.black);
  static const TextStyle bodyGreySmall = const TextStyle(
      fontSize: 12.0,
      fontWeight: FontWeight.normal,
      color: CustomColors.lightGrey);
  static const TextStyle bodyGreyVerySmall = const TextStyle(
      fontSize: 10.0,
      fontWeight: FontWeight.normal,
      color: CustomColors.darkGrey);
  static const TextStyle bodyMint = const TextStyle(
      fontSize: 14.0, fontWeight: FontWeight.bold, color: CustomColors.mint);
  static const TextStyle bodyRedVerySmall = const TextStyle(
      fontSize: 10.0, fontWeight: FontWeight.normal, color: Colors.red);
  static const TextStyle bodyLightGrey = const TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      color: CustomColors.lightGrey);
  static const TextStyle bodyBlack = const TextStyle(
      fontSize: 14.0, fontWeight: FontWeight.normal, color: CustomColors.black);
  static const TextStyle bodyWhite = const TextStyle(
      fontSize: 14.0, fontWeight: FontWeight.normal, color: CustomColors.white);
  static const TextStyle navigationMint = const TextStyle(
      fontSize: 10.0, fontWeight: FontWeight.bold, color: CustomColors.mint);
  static const TextStyle navigationGrey = const TextStyle(
      fontSize: 10.0,
      fontWeight: FontWeight.normal,
      color: CustomColors.darkGrey);
  static const TextStyle navigationWhite = const TextStyle(
      fontSize: 10.0, fontWeight: FontWeight.normal, color: CustomColors.white);
}

class CustomColors {
  CustomColors._();

  static const MaterialColor white = const MaterialColor(
    0xFFFFFFFF,
    const <int, Color>{
      50: const Color(0xFFFFFFFF),
      100: const Color(0xFFFFFFFF),
      200: const Color(0xFFFFFFFF),
      300: const Color(0xFFFFFFFF),
      400: const Color(0xFFFFFFFF),
      500: const Color(0xFFFFFFFF),
      600: const Color(0xFFFFFFFF),
      700: const Color(0xFFFFFFFF),
      800: const Color(0xFFFFFFFF),
      900: const Color(0xFFFFFFFF),
    },
  );

  static const MaterialColor backButtonIconColor = const MaterialColor(
    0xFFFFFFFF,
    const <int, Color>{
      50: const Color(0xFFFFFFFF),
      100: const Color(0xFFFFFFFF),
      200: const Color(0xFFFFFFFF),
      300: const Color(0xFFFFFFFF),
      400: const Color(0xFFFFFFFF),
      500: const Color(0xFFFFFFFF),
      600: const Color(0xFFFFFFFF),
      700: const Color(0xFFFFFFFF),
      800: const Color(0xFFFFFFFF),
      900: const Color(0xFFFFFFFF),
    },
  );

  // logo color
  static const MaterialColor sulfurYellow = const MaterialColor(
    0xFFFADE52,
    const <int, Color>{
      50: const Color(0xFFFADE52),
      100: const Color(0xFFFADE52),
      200: const Color(0xFFFADE52),
      300: const Color(0xFFFADE52),
      400: const Color(0xFFFADE52),
      500: const Color(0xFFFADE52),
      600: const Color(0xFFFADE52),
      700: const Color(0xFFFADE52),
      800: const Color(0xFFFADE52),
      900: const Color(0xFFFADE52),
    },
  );

  static const MaterialColor anthracite = const MaterialColor(
    0xFF313D47,
    const <int, Color>{
      50: const Color(0xFF313D47),
      100: const Color(0xFF313D47),
      200: const Color(0xFF313D47),
      300: const Color(0xFF313D47),
      400: const Color(0xFF313D47),
      500: const Color(0xFF313D47),
      600: const Color(0xFF313D47),
      700: const Color(0xFF313D47),
      800: const Color(0xFF313D47),
      900: const Color(0xFF313D47),
    },
  );

  static const MaterialColor black = const MaterialColor(
    0xFF000000,
    const <int, Color>{
      50: const Color(0xFF000000),
      100: const Color(0xFF000000),
      200: const Color(0xFF000000),
      300: const Color(0xFF000000),
      400: const Color(0xFF000000),
      500: const Color(0xFF000000),
      600: const Color(0xFF000000),
      700: const Color(0xFF000000),
      800: const Color(0xFF000000),
      900: const Color(0xFF000000),
    },
  );

  static const MaterialColor darkGrey = const MaterialColor(
    0xFF4d4d4d,
    const <int, Color>{
      50: const Color(0xFF4d4d4d),
      100: const Color(0xFF4d4d4d),
      200: const Color(0xFF4d4d4d),
      300: const Color(0xFF4d4d4d),
      400: const Color(0xFF4d4d4d),
      500: const Color(0xFF4d4d4d),
      600: const Color(0xFF4d4d4d),
      700: const Color(0xFF4d4d4d),
      800: const Color(0xFF4d4d4d),
      900: const Color(0xFF4d4d4d),
    },
  );

  static const MaterialColor lightGrey = const MaterialColor(
    0xFFb3b1b2,
    const <int, Color>{
      50: const Color(0xFFb3b1b2),
      100: const Color(0xFFb3b1b2),
      200: const Color(0xFFb3b1b2),
      300: const Color(0xFFb3b1b2),
      400: const Color(0xFFb3b1b2),
      500: const Color(0xFFb3b1b2),
      600: const Color(0xFFb3b1b2),
      700: const Color(0xFFb3b1b2),
      800: const Color(0xFFb3b1b2),
      900: const Color(0xFFb3b1b2),
    },
  );

  static const MaterialColor highlightColor = const MaterialColor(
    0xFF0060A7,
    const <int, Color>{
      50: const Color(0xFF0060A7),
      100: const Color(0xFF0060A7),
      200: const Color(0xFF0060A7),
      300: const Color(0xFF0060A7),
      400: const Color(0xFF0060A7),
      500: const Color(0xFF0060A7),
      600: const Color(0xFF0060A7),
      700: const Color(0xFF0060A7),
      800: const Color(0xFF0060A7),
      900: const Color(0xFF0060A7),
    },
  );

  static const MaterialColor marine = const MaterialColor(
    0xFF1E1D49,
    const <int, Color>{
      50: const Color(0xFF1E1D49),
      100: const Color(0xFF1E1D49),
      200: const Color(0xFF1E1D49),
      300: const Color(0xFF1E1D49),
      400: const Color(0xFF1E1D49),
      500: const Color(0xFF1E1D49),
      600: const Color(0xFF1E1D49),
      700: const Color(0xFF1E1D49),
      800: const Color(0xFF1E1D49),
      900: const Color(0xFF1E1D49),
    },
  );

  static const MaterialColor mint = const MaterialColor(
    0xFF65C1BE,
    const <int, Color>{
      50: const Color(0xFF65C1BE),
      100: const Color(0xFF65C1BE),
      200: const Color(0xFF65C1BE),
      300: const Color(0xFF65C1BE),
      400: const Color(0xFF65C1BE),
      500: const Color(0xFF65C1BE),
      600: const Color(0xFF65C1BE),
      700: const Color(0xFF65C1BE),
      800: const Color(0xFF65C1BE),
      900: const Color(0xFF65C1BE),
    },
  );

  static const MaterialColor green = const MaterialColor(
    0xFFC0D000,
    const <int, Color>{
      50: const Color(0xFFC0D000),
      100: const Color(0xFFC0D000),
      200: const Color(0xFFC0D000),
      300: const Color(0xFFC0D000),
      400: const Color(0xFFC0D000),
      500: const Color(0xFFC0D000),
      600: const Color(0xFFC0D000),
      700: const Color(0xFFC0D000),
      800: const Color(0xFFC0D000),
      900: const Color(0xFFC0D000),
    },
  );

  static const MaterialColor orange = const MaterialColor(
    0xFFef7b10,
    const <int, Color>{
      50: const Color(0xFFef7b10),
      100: const Color(0xFFef7b10),
      200: const Color(0xFFef7b10),
      300: const Color(0xFFef7b10),
      400: const Color(0xFFef7b10),
      500: const Color(0xFFef7b10),
      600: const Color(0xFFef7b10),
      700: const Color(0xFFef7b10),
      800: const Color(0xFFef7b10),
      900: const Color(0xFFef7b10),
    },
  );

  static const MaterialColor neongreen = const MaterialColor(
    0xFF91C63E,
    const <int, Color>{
      50: const Color(0xFF91C63E),
      100: const Color(0xFF91C63E),
      200: const Color(0xFF91C63E),
      300: const Color(0xFF91C63E),
      400: const Color(0xFF91C63E),
      500: const Color(0xFF91C63E),
      600: const Color(0xFF91C63E),
      700: const Color(0xFF91C63E),
      800: const Color(0xFF91C63E),
      900: const Color(0xFF91C63E),
    },
  );

  static const Color splashScreenColor = Colors.white;
}
