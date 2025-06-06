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

import 'package:erzmobil/model/User.dart';
import 'package:erzmobil/debug/Logger.dart';
import 'package:geolocator/geolocator.dart';

class LocationManager {
  static final LocationManager _instance = new LocationManager._internal();

  StreamSubscription<Position>? positionStream;
  bool serviceEnabled = false;
  bool hasPermissions = false;
  Position? _currentLocation;
  List<LocationListener> listeners = [];

  factory LocationManager() {
    return _instance;
  }

  LocationManager._internal();

  void register(LocationListener listener) {
    if (!listeners.contains(listener)) {
      listeners.add(listener);
    }
  }

  void unregister(LocationListener listener) {
    if (listeners.contains(listener)) {
      listeners.remove(listener);
    }
  }

  Future<Position?> _determinePosition() async {
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Logger.info('Location services are disabled.');
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Logger.info('Location permissions are denied');
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    hasPermissions = true;

    _currentLocation = await Geolocator.getCurrentPosition();
    return _currentLocation;
  }

  Position? getCurrentLocation() {
    return _currentLocation;
  }

  void initLocationService() async {
    await _determinePosition();

    if (serviceEnabled && hasPermissions && positionStream == null ||
        positionStream!.isPaused) {
      final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 10,
      );

      Logger.info("start listening for location updates");
      positionStream =
          Geolocator.getPositionStream(locationSettings: locationSettings)
              .listen((Position? position) {
        if (position != null && User().isLoggedIn() && listeners.isNotEmpty) {
          Logger.info("onLocationChanged: " +
              position.latitude.toString() +
              ', ' +
              position.longitude.toString());
          _notifyListeners(position);
          _currentLocation = position;
        }
      });
    } else if (positionStream != null && positionStream!.isPaused) {
      resumeLocationUpdates();
    }
  }

  void pauseLocationUpdates() {
    if (positionStream != null) {
      Logger.info("pause listening for location updates");
      positionStream!.pause();
    }
  }

  void resumeLocationUpdates() {
    if (positionStream != null) {
      Logger.info("resume listening for location updates");
      positionStream!.resume();
    }
  }

  void _notifyListeners(Position newLocation) {
    listeners.forEach((listener) {
      listener.onLocationChanged(newLocation);
    });
  }
}

class LocationListener {
  void onLocationChanged(Position location) {}
}
