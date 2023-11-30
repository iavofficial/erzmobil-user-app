import 'dart:io';

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

import '../Constants.dart';

class UserMap extends StatefulWidget {
  const UserMap({Key? key}) : super(key: key);

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

    if (_busStops != null) {
      _busStops!.forEach((BusStop stop) {
        if (stop.position != null) {
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
      ),
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
