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
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:erzmobil/debug/Logger.dart';
import 'package:vector_math/vector_math.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';

class Utils {
  static final int RADIUS_OF_EARTH_IN_KILOMETER = 6371;
  static final String NO_DATA = "---";
  static final String EMPTY = "";
  static final String OSM_URL = 'https://www.openstreetmap.org/copyright/de';

  String getDateAsString(DateTime? date) {
    if (date == null) {
      return NO_DATA;
    }
    return _getTimeAsString(date, 'dd.MM.yyyy kk:mm');
  }

  String getTimeAsTimeString(DateTime? date) {
    if (date == null) {
      return NO_DATA;
    }
    return _getTimeAsString(date, 'kk:mm');
  }

  String getTimeAsDayString(DateTime? date) {
    if (date == null) {
      return NO_DATA;
    }
    return _getTimeAsString(date, 'dd.MM.yyyy');
  }

  String _getTimeAsString(DateTime time, String pattern) {
    return DateFormat(pattern).format(time.toLocal());
  }

  String getFormatISOTime(DateTime date) {
    var duration = date.timeZoneOffset;
    if (duration.isNegative)
      return (DateFormat("yyyy-MM-ddTHH:mm:ss").format(date) +
          "-${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes - (duration.inHours * 60)).toString().padLeft(2, '0')}");
    else
      return (DateFormat("yyyy-MM-ddTHH:mm:ss").format(date) +
          "+${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes - (duration.inHours * 60)).toString().padLeft(2, '0')}");
  }

  static double getDistanceBetweenTwoPointsInKilometer(
      LatLng startPoint, LatLng endPoint) {
    if (startPoint == null || endPoint == null) {
      Logger.e("get Distance to null location");
      return 0;
    }

    double lat1 = startPoint.latitude;
    double lat2 = endPoint.latitude;
    double lon1 = startPoint.longitude;
    double lon2 = endPoint.longitude;
    double dLat = radians(lat2 - lat1);
    double dLon = radians(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(radians(lat1)) * cos(radians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * asin(sqrt(a));
    double result = RADIUS_OF_EARTH_IN_KILOMETER * c;
    return result;
  }

  static launchOsmLicenceInfo() async {
    if (await canLaunch(OSM_URL)) {
      await launch(OSM_URL);
    } else {
      Logger.info('Could not launch $OSM_URL');
    }
  }
}
