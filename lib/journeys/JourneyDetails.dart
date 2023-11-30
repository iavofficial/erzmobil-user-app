import 'dart:async';
import 'dart:io';

import 'package:erzmobil/debug/Logger.dart';
import 'package:erzmobil/model/Journey.dart';
import 'package:erzmobil/model/RequestState.dart';
import 'package:erzmobil/model/User.dart';
import 'package:erzmobil/utils/Utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:erzmobil/Constants.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'dart:core';

import 'package:url_launcher/url_launcher.dart';

class JourneyDetailsScreen extends StatefulWidget {
  const JourneyDetailsScreen(
      {Key? key,
      required this.currentJourneyId,
      required this.showButtonToMyJourneys})
      : super(key: key);
  final int currentJourneyId;
  final bool showButtonToMyJourneys;

  @override
  _JourneyDetailsState createState() => _JourneyDetailsState();
}

class _JourneyDetailsState extends State<JourneyDetailsScreen> {
  Journey? currentJourney;

  @override
  Widget build(BuildContext context) {
    Logger.info("JourneyDetails.build");
    return Consumer<User>(
      builder: (context, user, child) => _buildWidgets(context),
    );
  }

  bool _isFeeDue() {
    if (currentJourney == null) {
      return false;
    }
    DateTime now = DateTime.now();
    if (currentJourney!.departureTime == null) {
      return false;
    }
    DateTime journeyStart = currentJourney!.departureTime!.toLocal();
    int duration = journeyStart.difference(now).inHours.abs();

    DateTime? creationDate = currentJourney!.creationDate != null
        ? currentJourney!.creationDate!.toLocal()
        : null;
    bool wasBookedInLast10minutes = creationDate != null
        ? creationDate.difference(now).inMinutes.abs() <= 10
        : false;

    return !wasBookedInLast10minutes && duration <= 24;
  }

  void _updateTour() {
    User().loadJourneys();
  }

  Future<void> _confirmRevokeDialog(BuildContext context) async {
    RequestState resultState = RequestState.ERROR_FAILED;
    bool isFeeDue = _isFeeDue();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.dialogRevokeJourneyTitle,
              style: CustomTextStyles.title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  isFeeDue
                      ? AppLocalizations.of(context)!
                          .dialogRevokeJourneyWithFeeMessage
                      : AppLocalizations.of(context)!
                          .dialogRevokeJourneyMessage,
                  style: CustomTextStyles.bodyGrey,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                child: Text(
                  AppLocalizations.of(context)!.buttonConfirmRevoke,
                  style: CustomTextStyles.bodyMint,
                ),
                onPressed: () => Navigator.pop(context, true)),
            TextButton(
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: CustomTextStyles.bodyMint,
              ),
              onPressed: () => Navigator.pop(context, false),
            ),
          ],
        );
      },
    ).then((confirm) async {
      if (confirm) {
        resultState = await User().deleteOrder(widget.currentJourneyId);
        if (resultState != RequestState.SUCCESS) {
          if (resultState == RequestState.ERROR_TIMEOUT) {
            _showDialog(AppLocalizations.of(context)!.dialogInfoTitle,
                AppLocalizations.of(context)!.dialogTimeoutErrorText, context);
          } else if (resultState == RequestState.ERROR_FAILED_NO_INTERNET) {
            _showDialog(AppLocalizations.of(context)!.dialogErrorTitle,
                AppLocalizations.of(context)!.dialogMessageNoInternet, context);
          } else {
            _showDialog(AppLocalizations.of(context)!.dialogErrorTitle,
                AppLocalizations.of(context)!.dialogGenericErrorText, context);
          }
        }
        if (resultState == RequestState.SUCCESS) {
          Navigator.pop(context, false);
        }
      }
    });
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

  Widget _buildWidgets(BuildContext context) {
    currentJourney = User().getJourney(widget.currentJourneyId);

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
          actions: [
            IconButton(
              icon: Icon(Icons.navigation),
              onPressed: () {
                if (currentJourney != null) {
                  if (currentJourney!.startAddress != null &&
                      currentJourney!.startAddress!.location != null) {
                    _shareLocation(
                        context,
                        currentJourney!.startAddress!.location!.lat.toString(),
                        currentJourney!.startAddress!.location!.lng.toString());
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
            )
          ],
          title: Text(AppLocalizations.of(context)!.detailedJourneys),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            icon: Icon(
              Icons.arrow_back,
              color: CustomColors.backButtonIconColor,
            ),
          ),
        ),
        body: Container(
          child: Column(
            children: [_buildScaffoldContent(context)],
          ),
        ));
  }

  Widget _buildScaffoldContent(BuildContext context) {
    bool showUpdateButton = widget.showButtonToMyJourneys &&
        defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS;

    return Flexible(
      child: ListView(
        children: [
          Container(
            height: 50,
            decoration: BoxDecoration(color: CustomColors.green),
            child: _buildRow(
                Text(AppLocalizations.of(context)!.ticketCode),
                currentJourney == null
                    ? Text(Utils.NO_DATA)
                    : Text(currentJourney!.id.toString()),
                mainAxisAlignment: MainAxisAlignment.spaceBetween),
          ),
          Padding(padding: EdgeInsets.only(top: 15)),
          Container(
            alignment: Alignment.topLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildAddressRow(
                    AppLocalizations.of(context)!.selectRouteFromLabel,
                    currentJourney == null
                        ? Utils.NO_DATA
                        : currentJourney!.startAddress!.label!),
                _buildAddressRow(
                    AppLocalizations.of(context)!.selectRouteToLabel,
                    currentJourney == null
                        ? Utils.NO_DATA
                        : currentJourney!.destinationAddress!.label!),
              ],
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 15)),
          const Divider(
            height: 20,
            thickness: 1,
          ),
          _buildRow(
              Text(AppLocalizations.of(context)!.bookedOn),
              currentJourney == null
                  ? Text(Utils.NO_DATA)
                  : Text(
                      Utils().getDateAsString(currentJourney!.departureTime)),
              mainAxisAlignment: MainAxisAlignment.spaceBetween),
          const Divider(
            height: 20,
            thickness: 1,
          ),
          Offstage(
            offstage: !User().useDirectus,
            child: _buildRow(
                Text(AppLocalizations.of(context)!.estimatedArrival),
                currentJourney == null
                    ? Text(Utils.NO_DATA)
                    : Text(Utils()
                        .getDateAsString(currentJourney!.estimatedArrivalTime)),
                mainAxisAlignment: MainAxisAlignment.spaceBetween),
          ),
          Offstage(
            offstage: !User().useDirectus,
            child: const Divider(
              height: 20,
              thickness: 1,
            ),
          ),
          _buildRow(
              Text(AppLocalizations.of(context)!.journeyStatus),
              currentJourney == null
                  ? Text(Utils.NO_DATA)
                  : Text(currentJourney!.getRequestStateString(context)),
              mainAxisAlignment: MainAxisAlignment.spaceBetween),
          const Divider(
            height: 20,
            thickness: 1,
          ),
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 1,
                  child: Text(AppLocalizations.of(context)!.numberSeats),
                ),
                Flexible(
                  flex: 3,
                  child: currentJourney == null
                      ? Text(Utils.NO_DATA)
                      : Text(currentJourney!.seats.toString()),
                ),
              ],
            ),
          ),
          const Divider(
            height: 20,
            thickness: 1,
          ),
          _buildRow(
              Text(AppLocalizations.of(context)!.addionalWheelchairSeats),
              currentJourney == null
                  ? Text(Utils.NO_DATA)
                  : Text(currentJourney!.seatsWheelchair.toString()),
              mainAxisAlignment: MainAxisAlignment.spaceBetween),
          const Divider(
            height: 20,
            thickness: 1,
          ),
          Offstage(
              offstage: !showUpdateButton,
              child: Padding(padding: EdgeInsets.only(top: 10))),
          Offstage(
            offstage: !showUpdateButton,
            child: Container(
              margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
              width: double.infinity,
              child: Consumer<User>(
                builder: (context, user, child) => ElevatedButton(
                  onPressed: () async {
                    _updateTour();
                  },
                  child: User().isProcessing
                      ? CircularProgressIndicator()
                      : Text(AppLocalizations.of(context)!.updateJourney),
                ),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 10)),
          Container(
            margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
            width: double.infinity,
            child: Consumer<User>(
              builder: (context, user, child) => ElevatedButton(
                onPressed: () async {
                  _confirmRevokeDialog(context);
                },
                child: User().isProcessing
                    ? CircularProgressIndicator()
                    : Text(AppLocalizations.of(context)!.cancelJourney),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 10)),
          Offstage(
            offstage: !widget.showButtonToMyJourneys,
            child: Container(
              margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
              width: double.infinity,
              child: Consumer<User>(
                builder: (context, user, child) => ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context, true);
                  },
                  child:
                      Text(AppLocalizations.of(context)!.switchToJourneyList),
                ),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(bottom: 20)),
        ],
      ),
    );
  }

  Widget _buildAddressRow(String label, String addressLabel,
      {MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start}) {
    return Flexible(
      child: Container(
        margin: EdgeInsets.fromLTRB(15, 5, 15, 10),
        child: Row(
          children: [
            Container(
              alignment: Alignment.topLeft,
              width: 50,
              child: Text(
                label,
                style: CustomTextStyles.bodyGrey,
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Flexible(
                child: Container(
              alignment: Alignment.topLeft,
              child: Text(
                addressLabel,
                style: CustomTextStyles.bodyGreyBold2,
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
              ),
            ))
          ],
        ),
      ),
    );
  }

  Widget _buildRow(Widget widget1, Widget widget2,
      {MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start}) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 5,
      ),
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(width: 150, child: widget1),
          widget2,
        ],
      ),
    );
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
}
