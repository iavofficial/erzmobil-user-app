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
import 'package:erzmobil/debug/Logger.dart';
import 'package:erzmobil/journeys/QrCodeScreen.dart';
import 'package:erzmobil/model/Journey.dart';
import 'package:erzmobil/model/RequestState.dart';
import 'package:erzmobil/model/User.dart';
import 'package:erzmobil/model/VehicleType.dart';
import 'package:erzmobil/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:erzmobil/Constants.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'dart:core';
import '../map/UserMap.dart';

class JourneyDetailsScreen extends StatefulWidget {
  JourneyDetailsScreen.singleJourney(
      {Key? key,
      required this.currentJourneyId,
      this.selectedIndex = -1,
      this.numberTotalJourneys = -1,
      this.showSingleJourney = true,
      required this.showButtonToMyJourneys})
      : super(key: key);

  JourneyDetailsScreen.multipleJourneys(
      {Key? key,
      required this.currentJourneyId,
      required this.selectedIndex,
      required this.numberTotalJourneys,
      this.showSingleJourney = false,
      required this.showButtonToMyJourneys})
      : super(key: key);

  final int currentJourneyId;
  final int selectedIndex;
  final int numberTotalJourneys;
  final bool showSingleJourney;
  final bool showButtonToMyJourneys;

  @override
  _JourneyDetailsState createState() => _JourneyDetailsState();
}

class _JourneyDetailsState extends State<JourneyDetailsScreen> {
  Journey? currentJourney;
  PageController? pageController;
  int visibleIndex = -1;
  final List<Journey> allJourneys = User().journeyList!.bookedJourneys!;

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

  List<Widget> buildJourneys() {
    List<Widget> journeyWidgets = List.empty(growable: true);
    int numberJourneys = User().journeyList!.bookedJourneys!.length;
    int index = 1;
    for (var journey in User().journeyList!.bookedJourneys!) {
      Widget w = _buildScaffoldContent(context, journey, index, numberJourneys);
      index++;
      journeyWidgets.add(w);
    }
    Logger.info(journeyWidgets.length.toString());
    return journeyWidgets;
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

  Widget _buildWidgets(BuildContext context) {
    currentJourney = User().getJourney(widget.currentJourneyId);
    Widget journeyDetailsWidget;

    if (widget.showSingleJourney) {
      visibleIndex = 0;
      journeyDetailsWidget = Container(
          child: Column(
        children: [_buildScaffoldContent(context, currentJourney, 0, 1)],
      ));
    } else {
      pageController = PageController(
        initialPage: widget.selectedIndex,
        viewportFraction: 1,
      );

      visibleIndex = widget.selectedIndex;

      journeyDetailsWidget = PageView(
        controller: pageController,
        scrollDirection: Axis.horizontal,
        onPageChanged: (value) => visibleIndex = value,
        children: buildJourneys(),
      );
    }

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
          actions: [
            IconButton(
              icon: Icon(Icons.map),
              onPressed: () {
                _showMap(context, false);
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
        body: journeyDetailsWidget);
  }

  void _showMap(BuildContext context, bool showBusStopMarkers) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) => new UserMap(
          currentJourney: allJourneys[visibleIndex], showBusStopMarkers: false),
    ));
  }

  Widget _buildScaffoldContent(
      BuildContext context, journey, int indexJourney, int numberJourneys) {
    bool showUpdateButton = widget.showButtonToMyJourneys &&
        defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS;
    currentJourney = journey;

    Widget listView = ListView(
      children: [
        _buildHeaderContainer(indexJourney, numberJourneys),
        _buildPaddingTop(15),
        _buildStartDestinationContainer(),
        _buildPaddingTop(15),
        _buildDivider(),
        _buildDepartureTimeRow(currentJourney),
        _buildDivider(),
        _buildEstimatedArrivalContainer(),
        Offstage(
          offstage: !User().useDirectus,
          child: _buildDivider(),
        ),
        _buildRequestStateRow(currentJourney),
        _buildDivider(),
        _buildSeatsContainer(),
        _buildDivider(),
        _buildWheelcairRow(currentJourney),
        _buildDivider(),
        _buildRequestedVehicleTypeRow(currentJourney),
        _buildDivider(),
        Offstage(offstage: !showUpdateButton, child: _buildPaddingTop(10)),
        _buildUpdateTourButton(showUpdateButton),
        _buildPaddingTop(10),
        _buildButtonContainer(),
        _buildPaddingTop(10),
        _buildMyJourneysButton(),
        _buildPaddingBottom(20),
      ],
    );

    if (numberJourneys > 1) {
      return listView;
    }

    return Flexible(child: listView);
  }

  Widget _buildPaddingTop(double padding) {
    return Padding(padding: EdgeInsets.only(top: padding));
  }

  Widget _buildPaddingBottom(double padding) {
    return Padding(padding: EdgeInsets.only(bottom: padding));
  }

  Widget _buildRequestedVehicleTypeRow(Journey? currentJourney) {
    return _buildRow(
        Text(AppLocalizations.of(context)!.vehicle),
        currentJourney == null
            ? Text(Utils.NO_DATA)
            : Text(currentJourney!.getRequestVehicletypeString(context)),
        mainAxisAlignment: MainAxisAlignment.spaceBetween);
  }

  Widget _buildWheelcairRow(Journey? currentJourney) {
    return _buildRow(
        Text(AppLocalizations.of(context)!.addionalWheelchairSeats),
        currentJourney == null
            ? Text(Utils.NO_DATA)
            : Text(currentJourney!.seatsWheelchair.toString()),
        mainAxisAlignment: MainAxisAlignment.spaceBetween);
  }

  Widget _buildDepartureTimeRow(Journey? currentJourney) {
    return _buildRow(
        Text(AppLocalizations.of(context)!.bookedOn),
        currentJourney == null
            ? Text(Utils.NO_DATA)
            : Text(Utils().getDateAsString(currentJourney!.departureTime)),
        mainAxisAlignment: MainAxisAlignment.spaceBetween);
  }

  Widget _buildRequestStateRow(Journey? currentJourney) {
    return _buildRow(
        Text(AppLocalizations.of(context)!.journeyStatus),
        currentJourney == null
            ? Text(Utils.NO_DATA)
            : Text(currentJourney!.getRequestStateString(context)),
        mainAxisAlignment: MainAxisAlignment.spaceBetween);
  }

  Widget _buildUpdateTourButton(bool showUpdateButton) {
    return Offstage(
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
    );
  }

  Widget _buildHeaderContainer(int indexJourney, int numberJourneys) {
    return Container(
      height: 50,
      decoration: BoxDecoration(color: CustomColors.green),
      child: _getBookingCode(indexJourney, numberJourneys),
    );
  }

  Widget _buildMyJourneysButton() {
    return Offstage(
      offstage: !widget.showButtonToMyJourneys,
      child: Container(
        margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
        width: double.infinity,
        child: Consumer<User>(
          builder: (context, user, child) => ElevatedButton(
            onPressed: () async {
              Navigator.pop(context, true);
            },
            child: Text(AppLocalizations.of(context)!.switchToJourneyList),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 20,
      thickness: 1,
    );
  }

  Widget _buildStartDestinationContainer() {
    return Container(
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
    );
  }

  Widget _buildButtonContainer() {
    return Container(
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
    );
  }

  Widget _buildEstimatedArrivalContainer() {
    return Offstage(
      offstage: !User().useDirectus,
      child: _buildRow(
          Text(AppLocalizations.of(context)!.estimatedArrival),
          currentJourney == null
              ? Text(Utils.NO_DATA)
              : Text(Utils()
                  .getDateAsString(currentJourney!.estimatedArrivalTime)),
          mainAxisAlignment: MainAxisAlignment.spaceBetween),
    );
  }

  Widget _buildSeatsContainer() {
    return Container(
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
    );
  }

  Widget _getBookingCode(int index, int numberJourneys) {
    bool showQrCode = (currentJourney!.bus != null &&
        currentJourney!.bus!.vehicletype == VehicleType.autonomousShuttle);

    if (widget.showSingleJourney) {
      return InkWell(
        child: _buildRow(
          Text(AppLocalizations.of(context)!.ticketCode),
          currentJourney == null
              ? Text(Utils.NO_DATA)
              : showQrCode
                  ? Icon(
                      Icons.arrow_forward_ios_outlined,
                      color: CustomColors.black,
                      size: 20,
                    )
                  : Text(currentJourney!.id.toString()),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
        onTap: () {
          if (showQrCode) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  new QrCodeScreen(currentJourney: currentJourney),
            ));
          }
        },
      );
    }

    return InkWell(
      child: _buildHeadRow(
        Text(AppLocalizations.of(context)!.ticketCode),
        currentJourney == null
            ? Text(Utils.NO_DATA)
            : showQrCode
                ? Icon(
                    Icons.arrow_forward_ios_outlined,
                    color: CustomColors.black,
                    size: 20,
                  )
                : Text(currentJourney!.id.toString()),
        Text("($index / $numberJourneys)"),
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      ),
      onTap: () {
        if (showQrCode) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) =>
                new QrCodeScreen(currentJourney: currentJourney),
          ));
        }
      },
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
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
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

  Widget _buildHeadRow(Widget widget1, Widget widget2, Widget widget3,
      {MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(width: 150, child: widget1),
          Container(width: 150, child: widget2),
          widget3,
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
