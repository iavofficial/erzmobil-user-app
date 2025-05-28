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
import 'package:erzmobil/debug/Logger.dart';
import 'package:erzmobil/location/LocationManager.dart';
import 'package:erzmobil/model/BusStop.dart';
import 'package:erzmobil/utils/Utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:erzmobil/model/BusPosition.dart';
import 'package:erzmobil/model/User.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Constants.dart';
import '../model/Journey.dart';

class UserMap extends StatefulWidget {
  final bool showBusStopMarkers;
  final bool showStartEndStation;
  final Journey? currentJourney;

  const UserMap(
      {Key? key,
      this.currentJourney,
      this.showBusStopMarkers = true,
      this.showStartEndStation = true})
      : super(key: key);

  @override
  _UserMapState createState() => _UserMapState();
}

class _UserMapState extends State<UserMap>
    with WidgetsBindingObserver, LocationListener {
  List<BusPosition>? _busPositions;
  Timer? _busPositionsTimer;
  List<BusStop>? _busStops;
  List<Marker>? busStopMarkers;
  List<Marker>? _markers;

  List<LatLng> points = <LatLng>[];
  List<Marker>? busPositionMarkers;

  Position? _currentLocation;
  String? _serviceError = '';
  BusStop? selectedBusStop;
  AppLifecycleState lifecycleState = AppLifecycleState.resumed;

  var bounds;

  late final MapController mapController;

  void _initLocationService() async {
    LocationManager().register(this);
    LocationManager().initLocationService();
  }

  Future<void> _updateBusPositions() async {
    if (User().hasActiveJourney()) {
      List<BusPosition>? positions = await User().loadCurrentBusPositions();
      if (positions != null) {
        _busPositions = positions;
        _convertBusPositionsToMarkers();
        setState(() {
          Logger.info('setState: _updateBusPositions()');
          _updateMarkers();
        });
      }
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    checkInternetConnection();
    _markers = [];
    _updateBusPositions();
    _busStops = User().stopList!.data.cast<BusStop>();
    _convertStopsToMarkers();
    _updateMarkers();
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      _initLocationService();
    }
    mapController = MapController();

    Logger.info("initState() done");

    super.initState();
  }

  void _startTimer() {
    _busPositionsTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      if (User().hasActiveJourney()) {
        if (_busPositionsTimer != null) {
          List<BusPosition>? positions = await User().loadCurrentBusPositions();
          if (positions != null) {
            _busPositions = positions;
            _convertBusPositionsToMarkers();
            setState(() {
              _markers!.clear();
              _updateMarkers();
            });
          }
        }
      }
    });
  }

  void _convertStopsToMarkers() {
    Logger.info("_convertStopsToMarkers");
    busStopMarkers = [];
    if (busStopMarkers == null) {
      busStopMarkers = [];
    } else {
      busStopMarkers!.clear();
    }

    void _addMarker(BusStop stop, {startFlag = true}) {
      var icon;
      bool isCurrentNode = selectedBusStop == stop;
      if (startFlag == true) {
        icon = Image.asset(Strings.assetPathLocationMarker,
            scale: 1, color: Colors.blue[900]);
      } else {
        icon = Image.asset(Strings.assetPathLocationEndMarker,
            scale: 1, color: Colors.blue[900]);
      }

      Marker stopMarker = Marker(
        width: isCurrentNode ? 100.0 : 70.0,
        height: isCurrentNode ? 100.0 : 70.0,
        anchorPos: AnchorPos.align(AnchorAlign.center),
        point: stop.position!,
        builder: (ctx) => Container(
          child: IconButton(
              alignment: Alignment.bottomCenter,
              icon: icon,
              onPressed: () {
                onMarkerClicked(stop);
              }),
        ),
      );
      busStopMarkers!.add(stopMarker);
    }

    if (_busStops != null) {
      _busStops!.forEach((BusStop stop) {
        if (stop.position != null) {
          if (widget.showStartEndStation == true &&
              (stop.position!.latitude ==
                      widget.currentJourney!.startAddress!.location!.lat &&
                  stop.position!.longitude ==
                      widget.currentJourney!.startAddress!.location!.lng)) {
            _addMarker(stop, startFlag: true);
          } else if (widget.showStartEndStation == true &&
              stop.position!.latitude ==
                  widget.currentJourney!.destinationAddress!.location!.lat &&
              stop.position!.longitude ==
                  widget.currentJourney!.destinationAddress!.location!.lng) {
            _addMarker(stop, startFlag: false);
          } else {
            if (widget.showBusStopMarkers) {
              bool isCurrentNode = selectedBusStop == stop;
              Marker stopMarker = Marker(
                width: isCurrentNode ? 100.0 : 70.0,
                height: isCurrentNode ? 100.0 : 70.0,
                anchorPos: AnchorPos.align(AnchorAlign.center),
                point: stop.position!,
                builder: (ctx) => Container(
                  child: IconButton(
                      alignment: Alignment.bottomCenter,
                      icon: Image.asset(
                        Strings.assetPathLocationMarker,
                        scale: 1,
                      ),
                      onPressed: () {
                        onMarkerClicked(stop);
                      }),
                ),
              );
              busStopMarkers!.add(stopMarker);
            }
          }
        }
      });

      _markers!.addAll(busStopMarkers!);
    }
  }

  void _convertBusPositionsToMarkers() {
    if (busPositionMarkers == null) {
      busPositionMarkers = [];
    } else {
      busPositionMarkers!.clear();
    }
    if (_busPositions != null) {
      _busPositions!.forEach((BusPosition busPosition) {
        if (busPosition.updatedAt != null) {
          Marker busPositionMarker = Marker(
            width: 80.0,
            height: 80.0,
            anchorPos: AnchorPos.align(AnchorAlign.center),
            point: LatLng(busPosition.position!.lat, busPosition.position!.lng),
            builder: (ctx) => Container(
              child: Image.asset(Strings.assetPathBus),
            ),
          );

          busPositionMarkers!.add(busPositionMarker);
        }
      });
    }
  }

  void _updateMarkers() {
    _markers = [];
    if (busStopMarkers != null && busStopMarkers!.length > 0) {
      _markers!.addAll(busStopMarkers!);
    }
    if (busPositionMarkers != null && busPositionMarkers!.length > 0) {
      _markers!.addAll(busPositionMarkers!);
    }
    if (_currentLocation != null &&
        Utils.getDistanceBetweenTwoPointsInKilometer(
                LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
                LatLng(50.630258002681295, 12.813692902587027)) <=
            3) {
      _markers!.add(Marker(
        width: 80.0,
        height: 80.0,
        anchorPos: AnchorPos.align(AnchorAlign.center),
        point: LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
        builder: (ctx) => Container(
          child: Icon(
            Icons.my_location,
            color: Colors.black,
            size: 30,
          ),
        ),
      ));
    }
  }

  @override
  void onLocationChanged(Position location) {
    if (lifecycleState == AppLifecycleState.resumed) {
      if (mounted) {
        setState(() {
          Logger.info("onLocationChanged: " + location.toString());
          _currentLocation = location;
          _updateMarkers();
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    Logger.debug('state = $state');
    lifecycleState = state;

    if (state == AppLifecycleState.paused) {
      _cancelStateTimer();
    } else if (state == AppLifecycleState.resumed) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    LocationManager().unregister(this);
    super.dispose();
  }

  @override
  void deactivate() {
    _cancelStateTimer();
    super.deactivate();
  }

  void _cancelStateTimer() {
    if (_busPositionsTimer != null) {
      _busPositionsTimer!.cancel();
      _busPositionsTimer = null;
    }
  }

  void _devicePositionButtonClicked(BuildContext context) {
    if (_currentLocation == null ||
        Utils.getDistanceBetweenTwoPointsInKilometer(
                LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
                LatLng(50.630258002681295, 12.813692902587027)) >=
            3) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          AppLocalizations.of(context)!.noPosition,
        ),
      ));
    } else {
      mapController.move(
          LatLng(_currentLocation!.latitude, _currentLocation!.longitude), 16);
    }
  }

  void onMarkerClicked(BusStop busStop) {
    Logger.info('Marker was clicked: ' + busStop.toString());
    if (selectedBusStop != busStop) {
      setState(() {
        selectedBusStop = busStop;
        _convertStopsToMarkers();
        _updateMarkers();
      });
    }
  }

  void checkInternetConnection() async {
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      final bool isConnected = await InternetConnectionChecker().hasConnection;
      if (!isConnected) {
        Logger.info("Missing Internet connection in map");
      }
    }
  }

  Future<void> _shareLocation(
      BuildContext context, String lat, String lng) async {
    Logger.debug("shareLocation: " + lat + ", " + lng);
    if (defaultTargetPlatform == TargetPlatform.android) {
      assert(lat.isNotEmpty);
      final params = <String, String>{
        'lat': lat,
        'lng': lng,
      };

      const platform = MethodChannel('erzmobil.native/share');
      try {
        await platform.invokeMethod('shareLocation', params);
      } on PlatformException catch (e) {
        _showDialog(AppLocalizations.of(context)!.dialogErrorTitle,
            AppLocalizations.of(context)!.dialogGenericErrorText, context);
        Logger.e("Sharing location failed");
      }
    } else {
      String GOOGLE_MAPS_DIRECTIONS_URI =
          "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng";

      if (!await launch(
        GOOGLE_MAPS_DIRECTIONS_URI,
        forceSafariVC: false,
        forceWebView: false,
      )) {
        Logger.info('Could not launch $GOOGLE_MAPS_DIRECTIONS_URI');
      }
    }
  }

  Future<void> _showDialog(
      String title, String message, BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: CustomTextStyles.title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  message,
                  style: CustomTextStyles.bodyGrey,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                AppLocalizations.of(context)!.okay,
                style: CustomTextStyles.bodyMint,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Logger.info('Widget build');

    return Scaffold(
      appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[CustomColors.mint, CustomColors.marine])),
          ),
          automaticallyImplyLeading: true,
          centerTitle: true,
          foregroundColor: CustomColors.white,
          title: Text(AppLocalizations.of(context)!.map),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: CustomColors.backButtonIconColor,
            ),
          ),
          actions: [
            if (widget.currentJourney != null)
              IconButton(
                icon: Icon(Icons.navigation),
                onPressed: () {
                  if (widget.currentJourney != null) {
                    if (widget.currentJourney!.startAddress != null &&
                        widget.currentJourney!.startAddress!.location != null) {
                      _shareLocation(
                          context,
                          widget.currentJourney!.startAddress!.location!.lat
                              .toString(),
                          widget.currentJourney!.startAddress!.location!.lng
                              .toString());
                    } else {
                      _showDialog(
                          AppLocalizations.of(context)!.dialogErrorTitle,
                          AppLocalizations.of(context)!.dialogGenericErrorText,
                          context);
                    }
                  } else {
                    _showDialog(
                        AppLocalizations.of(context)!.dialogErrorTitle,
                        AppLocalizations.of(context)!.dialogGenericErrorText,
                        context);
                  }
                },
              ),
          ]),
      body: _buildMap(),
    );
  }

  Widget _buildMap() {
    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            center: LatLng(50.631811, 12.810148),
            maxZoom: 18.0,
            interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            zoom: 13.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://karte.erzmobil.de/tile/{z}/{x}/{y}.png',
            ),
            MarkerLayer(
              markers: _markers!,
            )
          ],
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.fromLTRB(0.0, 15.0, 5.0, 0.0),
            ),
            child: Text(
              Utils.OSM_URL,
              style: CustomTextStyles.bodyBlackBold,
            ),
            onPressed: () {
              Utils.launchOsmLicenceInfo();
            },
          ),
        ),
        (defaultTargetPlatform == TargetPlatform.android ||
                defaultTargetPlatform == TargetPlatform.iOS)
            ? Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 110),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      shadowColor: MaterialStateProperty.all(
                          Colors.transparent.withOpacity(0.0)),
                      backgroundColor: MaterialStateProperty.all(
                          Colors.transparent.withOpacity(0.0)),
                    ),
                    onPressed: () {
                      _devicePositionButtonClicked(context);
                    },
                    child: Icon(
                      Icons.gps_not_fixed,
                      color: Colors.black,
                    ),
                  ),
                ),
              )
            : Container(),
        Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(25.0, 30.0, 25.0, 40.0),
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.fromLTRB(15.0, 15.0, 5.0, 15.0),
                    backgroundColor: CustomColors.mint,
                    disabledBackgroundColor: CustomColors.mint,
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                    ),
                  ),
                  child: selectedBusStop == null
                      ? Text(
                          AppLocalizations.of(context)!.chooseStop,
                          style: CustomTextStyles.bodyWhite,
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Text(
                            selectedBusStop!.name!,
                            style: CustomTextStyles.bodyWhite,
                          ),
                        ),
                  onPressed: null,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
