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

import 'package:erzmobil/Constants.dart';
import 'package:erzmobil/debug/Logger.dart';
import 'package:erzmobil/journeys/AlternateJourneyTimes.dart';
import 'package:erzmobil/map/SelectionMap.dart';
import 'package:erzmobil/model/BusStop.dart';
import 'package:erzmobil/model/Journey.dart';
import 'package:erzmobil/model/Location.dart';
import 'package:erzmobil/model/TicketType.dart';
import 'package:erzmobil/model/User.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';

import './SelectStartOrDestination.dart';
import '../utils/Utils.dart';
import 'JourneyDetails.dart';

class NewJourneyScreen extends StatefulWidget {
  const NewJourneyScreen(
      {Key? key,
      this.changePage,
      this.prefilledJourneyData,
      this.isFavoriteSelection = false,
      this.isNewFavorite = true})
      : super(key: key);

  final void Function(int)? changePage;
  final Journey? prefilledJourneyData;
  final bool isFavoriteSelection;
  final bool isNewFavorite;

  @override
  _NewJourneyScreenState createState() => _NewJourneyScreenState();
}

class _NewJourneyScreenState extends State<NewJourneyScreen> {
  List<BusStop>? stops;
  List<BusStop>? favorites;

  BusStop? start;
  BusStop? destination;
  int selectedSeats = 1;
  bool isDeparture = true;
  int selectedWheelChairs = 0;
  String ticketType = '';
  DateTime? startDate;
  TimeOfDay? startTime;

  final _favoriteNameFormKey = GlobalKey<FormState>();
  String? _favoriteName;

  String? suggestAlternativesOption;

  List<int> seatOptionsNoWheelchair = [1, 2, 3, 4, 5, 6];
  List<int> seatOptionsWithWheelchair = [0, 1, 2, 3, 4, 5];
  late List<int> allowedSeatOptions;
  List<int> wheelchairOptions = [0, 1];
  List<String> journeyOptions = [];
  List<TicketType> journeyTypes = [];
  List<String> suggestAlternatives = [];

  @override
  void initState() {
    journeyTypes = User().getTicketTypes();
    allowedSeatOptions = seatOptionsNoWheelchair;
    suggestAlternativesOption = "";
    startDate = DateTime.now();
    startTime = TimeOfDay.now();
    changeEndTime(startTime!);
    stops = User().stopList!.data.cast<BusStop>();
    if (widget.prefilledJourneyData != null) {
      Journey journey = widget.prefilledJourneyData!;
      start = User().getBusStopFromAddress(journey.startAddress);
      destination = User().getBusStopFromAddress(journey.destinationAddress);
      ticketType = journey.ticketType!;
      isDeparture = journey.isDeparture;
      selectedSeats = journey.seats;
      selectedWheelChairs = journey.seatsWheelchair;
    }

    //build up favorites from id'S
    List<int>? favoriteIds = User().favoriteStops;
    if (favoriteIds != null && stops != null) {
      favorites = [];
      //build map for fast lookup
      Map<int, BusStop> tmpMap = {};
      stops?.forEach((element) {
        tmpMap[element.id] = element;
      });
      //build usable favorite list
      favoriteIds.forEach((element) {
        BusStop? stop = tmpMap[element];
        if (stop != null) {
          favorites?.add(stop);
        }
      });
    }

    super.initState();
  }

  void changeEndTime(TimeOfDay startTimeOfDay) {
    DateTime today = DateTime.now();
    DateTime customDateTime = DateTime(today.year, today.month, today.day,
        startTimeOfDay.hour, startTimeOfDay.minute);
    startTime =
        TimeOfDay.fromDateTime(customDateTime.add(Duration(minutes: 30)));
  }

  @override
  Widget build(BuildContext context) {
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
        actions: [],
        title: Text(widget.isFavoriteSelection
            ? AppLocalizations.of(context)!.addNewFavoriteJourney
            : AppLocalizations.of(context)!.newJourney),
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
        child: _buildScaffoldContent(context),
      ),
    );
  }

  Widget _buildScaffoldContent(BuildContext context) {
    if (journeyOptions.isEmpty) {
      journeyOptions
          .add(AppLocalizations.of(context)!.dateTimeArrivalViewLabel);
      journeyOptions
          .add(AppLocalizations.of(context)!.dateTimeDepartureViewLabel);
    }
    if (suggestAlternatives.isEmpty) {
      suggestAlternativesOption =
          AppLocalizations.of(context)!.suggestAlternativesNo;
      suggestAlternatives
          .add(AppLocalizations.of(context)!.suggestAlternativesNo);
      suggestAlternatives
          .add(AppLocalizations.of(context)!.suggestAlternativesEarlier);
      suggestAlternatives
          .add(AppLocalizations.of(context)!.suggestAlternativesLater);
    }
    if (ticketType.isEmpty) {
      ticketType = journeyTypes[0].name;
    }
    return Container(
      child: Consumer<User>(
        builder: (context, user, child) => _buildWidgets(context),
      ),
    );
  }

  void _navigateAndUpdateStartAddress(BuildContext context) async {
    final BusStop? selected = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectStartOrDestination(
          stops: User().getSortedBusStops(),
          screenTitle: AppLocalizations.of(context)!.selectStart,
          favoritesMapping: User().getFavoritesMapping(),
        ),
      ),
    );

    setState(() {
      start = selected;
    });
  }

  void _navigateAndUpdateStartAddressOnMap(BuildContext context) async {
    final BusStop? selected = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectionMap(
          screenTitle: AppLocalizations.of(context)!.selectStart,
        ),
      ),
    );

    setState(() {
      start = selected;
    });
  }

  void _navigateAndUpdateDestinationAddress(BuildContext context) async {
    final BusStop? selected = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectStartOrDestination(
          stops: User().getSortedBusStops(),
          screenTitle: AppLocalizations.of(context)!.selectDestination,
          favoritesMapping: User().getFavoritesMapping(),
        ),
      ),
    );

    setState(() {
      destination = selected;
    });
  }

  void _navigateAndUpdateDestinationAddressMap(BuildContext context) async {
    final BusStop? selected = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectionMap(
          screenTitle: AppLocalizations.of(context)!.selectDestination,
        ),
      ),
    );

    setState(() {
      destination = selected;
    });
  }

  Widget _buildWidgets(BuildContext context) {
    return ListView(
      children: [
        Container(
          child: Column(children: [
            Padding(padding: EdgeInsets.only(top: 10)),
            Row(
              children: [
                Flexible(
                  child: Column(
                    children: [
                      _buildAddressRow(
                          AppLocalizations.of(context)!.selectRouteFromLabel,
                          start == null
                              ? AppLocalizations.of(context)!.selectStart
                              : start!.name!, () {
                        _navigateAndUpdateStartAddress(context);
                      }, () {
                        _navigateAndUpdateStartAddressOnMap(context);
                      }),
                      _buildAddressRow(
                          AppLocalizations.of(context)!.selectRouteToLabel,
                          destination == null
                              ? AppLocalizations.of(context)!.selectDestination
                              : destination!.name!, () {
                        _navigateAndUpdateDestinationAddress(context);
                      }, () {
                        _navigateAndUpdateDestinationAddressMap(context);
                      }),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _switchStartAndDestination,
                  icon: const Icon(
                    Icons.swap_vert,
                    color: CustomColors.mint,
                    size: 30,
                  ),
                ),
              ],
            ),
            Offstage(
              offstage: !widget.isFavoriteSelection,
              child: const Divider(
                height: 10,
                thickness: 1,
              ),
            ),
            Offstage(
              offstage: !widget.isFavoriteSelection,
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Text(AppLocalizations.of(context)!.favoriteName),
                    ),
                    Flexible(
                      flex: 2,
                      child: Form(
                        key: _favoriteNameFormKey,
                        child: Container(
                          //padding: EdgeInsets.symmetric(horizontal: 5),
                          child: TextFormField(
                            autovalidateMode: AutovalidateMode.disabled,
                            obscureText: false,
                            style: CustomTextStyles.bodyMint,
                            textAlign: TextAlign.end,
                            autocorrect: false,
                            initialValue: widget.prefilledJourneyData != null &&
                                    widget.prefilledJourneyData!.favoriteName !=
                                        null
                                ? widget.prefilledJourneyData!.favoriteName
                                : null,
                            enabled: !User().isProcessing,
                            decoration: new InputDecoration(
                                contentPadding: EdgeInsets.only(right: 24.0),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: CustomColors.mint),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: CustomColors.mint),
                                ),
                                border: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: CustomColors.mint),
                                ),
                                errorMaxLines: 0),
                            validator: null,
                            onSaved: (String? name) {
                              _favoriteName = name;
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(
              height: 20,
              thickness: 1,
            ),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: 15,
              ),
              alignment: Alignment.centerRight,
              child: _getJourneyOptionButtons(
                  AppLocalizations.of(context)!.dateTimeArrivalViewLabel,
                  AppLocalizations.of(context)!.dateTimeDepartureViewLabel),
            ),
            const Divider(
              height: 20,
              thickness: 1,
            ),
            Offstage(
              offstage: widget.isFavoriteSelection,
              child: _buildRow(
                  Text(AppLocalizations.of(context)!.dateLabel),
                  Text(
                    startDate == null
                        ? Utils().getTimeAsDayString(DateTime.now())
                        : Utils().getTimeAsDayString(startDate!),
                    style: CustomTextStyles.bodyMint,
                  ), () {
                _selectDate(context);
              }, mainAxisAlignment: MainAxisAlignment.spaceBetween),
            ),
            Offstage(
              offstage: widget.isFavoriteSelection,
              child: const Divider(
                thickness: 1,
              ),
            ),
            Offstage(
              offstage: widget.isFavoriteSelection,
              child: _buildRow(
                  Text(AppLocalizations.of(context)!.dateTimeStartViewLabel),
                  Text(
                      startTime == null
                          ? TimeOfDay.now().format(context)
                          : startTime!.format(context),
                      style: CustomTextStyles.bodyMint), () {
                _selectTime(context);
              }, mainAxisAlignment: MainAxisAlignment.spaceBetween),
            ),
            Offstage(
              offstage: widget.isFavoriteSelection,
              child: const Divider(
                thickness: 1,
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: 15,
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
                    child: _getSeatsDropDownWidget(
                        allowedSeatOptions, selectedSeats, (int value) {
                      setState(() {
                        selectedSeats = value;
                      });
                    }),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 20,
              thickness: 1,
            ),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 3,
                    child: Text(
                        AppLocalizations.of(context)!.addionalWheelchairSeats),
                  ),
                  Flexible(
                    flex: 2,
                    child: _getSeatsDropDownWidget(
                        wheelchairOptions, selectedWheelChairs, (int value) {
                      setState(() {
                        _processWheelchairSelection(value);
                      });
                    }),
                  ),
                ],
              ),
            ),
            Offstage(
              offstage:
                  !(selectedWheelChairs != 0 && !widget.isFavoriteSelection),
              child: Container(
                margin: EdgeInsets.fromLTRB(15, 10, 15, 10),
                child: RichText(
                  maxLines: 10,
                  textAlign: TextAlign.start,
                  text: TextSpan(
                    style: CustomTextStyles.bodyBlack,
                    children: <TextSpan>[
                      TextSpan(
                          style: CustomTextStyles.bodyGreySmall,
                          text:
                              AppLocalizations.of(context)!.accessibilityHint),
                      TextSpan(
                        style: CustomTextStyles.bodyMintSmallBold,
                        text: AppLocalizations.of(context)!.accessibility,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            _openAccessibilityHint();
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(
              height: 20,
              thickness: 1,
            ),
            Offstage(
              offstage: widget.isFavoriteSelection,
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Text(AppLocalizations.of(context)!
                          .suggestAlternativesText),
                    ),
                    Flexible(
                      flex: 3,
                      child: _getAlternativesDropDownWidget(
                          suggestAlternativesOption!, (String value) {
                        setState(() {
                          suggestAlternativesOption = value;
                        });
                      }),
                    ),
                  ],
                ),
              ),
            ),
            Offstage(
              offstage: widget.isFavoriteSelection,
              child: const Divider(
                thickness: 1,
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: Text(AppLocalizations.of(context)!.ticketType),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: 15,
              ),
              alignment: Alignment.centerRight,
              child: _getTicketTypeDropDownWidget(ticketType, (String value) {
                setState(() {
                  ticketType = value;
                });
              }),
            ),
            const Divider(
              height: 20,
              thickness: 1,
            )
          ]),
        ),
        Offstage(
          offstage: widget.isFavoriteSelection,
          child: Container(
              margin: EdgeInsets.fromLTRB(20, 10, 20, 5),
              width: double.infinity,
              child: Text(
                AppLocalizations.of(context)!.comfortFeeHint,
                textAlign: TextAlign.center,
              )),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.isFavoriteSelection
                ? () {
                    _saveFavorite(context);
                  }
                : isBookingPossible()
                    ? () {
                        blockBookingButton();

                        DateTime time = DateTime(
                            startDate!.year,
                            startDate!.month,
                            startDate!.day,
                            startTime!.hour,
                            startTime!.minute,
                            0,
                            0,
                            0);

                        Journey journey = _getJourney(time);
                        _bookRoute(context, journey);
                      }
                    : null,
            child: User().isProcessing
                ? CircularProgressIndicator()
                : Text(widget.isFavoriteSelection
                    ? AppLocalizations.of(context)!.saveFavorite
                    : AppLocalizations.of(context)!.createRouteButton),
          ),
        ),
        Offstage(
          offstage: widget.isNewFavorite,
          child: Container(
            margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
            width: double.infinity,
            child: ElevatedButton(
              style: ButtonStyle(
                shadowColor: MaterialStateProperty.all(
                    Colors.transparent.withOpacity(0.0)),
                backgroundColor: MaterialStateProperty.all(
                    Colors.transparent.withOpacity(0.0)),
              ),
              onPressed: () async {
                if (!widget.isNewFavorite) {
                  bool success = await User()
                      .deleteFavoriteJourney(widget.prefilledJourneyData!);
                  if (success) {
                    Navigator.of(context).pop();
                  } else {
                    _showDialog(
                        AppLocalizations.of(context)!.saveFavorite,
                        AppLocalizations.of(context)!.saveFavoriteError,
                        context,
                        null);
                  }
                }
              },
              child: User().isProcessing
                  ? CircularProgressIndicator()
                  : Text(
                      AppLocalizations.of(context)!.deleteFavorite,
                      style: CustomTextStyles.bodyMintBold,
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openAccessibilityHint() async {
    if (await canLaunch(Strings.ACCESSIBILITY_LINK)) {
      await launch(Strings.ACCESSIBILITY_LINK);
    } else {
      Logger.info('Could not launch $Strings.ACCESSIBILITY_LINK');
    }
  }

  Color getColor(Set<MaterialState> states) {
    return CustomColors.mint;
  }

  void _switchStartAndDestination() {
    BusStop? tempStart = start;
    BusStop? tempDest = destination;

    setState(() {
      start = tempDest;
      destination = tempStart;
    });
  }

  Future<void> _saveFavorite(BuildContext context) async {
    if (start == destination) {
      _showDialog(AppLocalizations.of(context)!.dialogErrorTitle,
          getBookingError(98), context, null);
      return;
    }
    Journey journey;

    _favoriteNameFormKey.currentState!.save();

    journey = Journey(
        0,
        Address(start!.id, start!.name,
            Location(start!.position!.latitude, start!.position!.longitude)),
        Address(
            destination!.id,
            destination!.name,
            Location(destination!.position!.latitude,
                destination!.position!.longitude)),
        null,
        null,
        null,
        isDeparture,
        selectedSeats,
        selectedWheelChairs,
        0,
        null,
        null,
        null,
        ticketType,
        null,
        null,
        favoriteName: _favoriteName);
    if (!widget.isNewFavorite) {
      await User().deleteFavoriteJourney(widget.prefilledJourneyData!);
    }
    bool success = await User().saveFavoriteJourney(journey);
    if (success) {
      Navigator.of(context).pop();
    } else {
      _showDialog(AppLocalizations.of(context)!.saveFavorite,
          AppLocalizations.of(context)!.saveFavoriteError, context, null);
    }
  }

  void _bookRoute(BuildContext context, Journey journey) async {
    if (start == destination) {
      _showDialog(AppLocalizations.of(context)!.dialogErrorTitle,
          getBookingError(99), context, null);
      return;
    }

    int flexibleOption = 0;
    if (suggestAlternativesOption ==
        AppLocalizations.of(context)!.suggestAlternativesEarlier) {
      flexibleOption = -1;
    } else if (suggestAlternativesOption ==
        AppLocalizations.of(context)!.suggestAlternativesLater) {
      flexibleOption = 1;
    }

    Tuple3<int, Journey, List<DateTime>?> result =
        await User().requestRoute(flexibleOption, journey, context);
    int resultCode = result.item1;
    if (resultCode == 0) {
      _showDialog(
          AppLocalizations.of(context)!.dialogInfoTitle,
          AppLocalizations.of(context)!.bookRouteHeaderJourney,
          context, () async {
        Navigator.of(context).pop();

        if (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS) {
          Timer(Duration(seconds: 5), _updateTour);
        }

        final bool switchToJourneyList = await Navigator.of(context).push(
          MaterialPageRoute(
              builder: (BuildContext context) => ChangeNotifierProvider.value(
                    value: User(),
                    child: new JourneyDetailsScreen.singleJourney(
                      currentJourneyId: result.item2.id,
                      showButtonToMyJourneys: true,
                    ),
                  )),
        );

        if (switchToJourneyList) {
          if (widget.changePage != null) {
            widget.changePage!(1);
          }
          Navigator.of(context).pop();
        }
      });
    } else if (resultCode == 10 &&
        journey.departureTime != null &&
        result.item3 != null) {
      _navigateToAlternativesScreen(context, result, journey);
    } else if (resultCode == 11 &&
        journey.departureTime != null &&
        result.item3 != null) {
      _showDialog(
          AppLocalizations.of(context)!.dialogErrorTitle,
          getBookingError(resultCode,
              optionalParameters: result.item3 as List<DateTime>),
          context,
          null);
    } else {
      _showDialog(AppLocalizations.of(context)!.dialogErrorTitle,
          getBookingError(resultCode), context, null);
    }
  }

  void _updateTour() {
    User().loadJourneys();
  }

  String getTimeAsTimeString(DateTime alternateTime) {
    return DateFormat('kk:mm').format(alternateTime.toLocal());
  }

  void _navigateToAlternativesScreen(BuildContext context,
      Tuple3<int, Journey, List<DateTime>?> result, Journey journey) async {
    final DateTime? selected =
        await Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => new AlternateJourneyTimesScreen(
                  alternateTimes: result.item3!,
                  originalTime: journey.departureTime!,
                )));

    if (selected != null) {
      DateTime time;
      if (selected.isUtc) {
        time = DateTime.utc(selected.year, selected.month, selected.day,
            selected.hour, selected.minute, 0, 0, 0);
      } else {
        time = DateTime(selected.year, selected.month, selected.day,
            selected.hour, selected.minute, 0, 0, 0);
      }

      Journey alternativeJourney = _getJourney(time);

      _bookRoute(context, alternativeJourney);
    }
  }

  Journey _getJourney(DateTime time) {
    return Journey(
        0,
        Address(start!.id, start!.name,
            Location(start!.position!.latitude, start!.position!.longitude)),
        Address(
            destination!.id,
            destination!.name,
            Location(destination!.position!.latitude,
                destination!.position!.longitude)),
        null,
        time,
        null,
        isDeparture,
        selectedSeats,
        selectedWheelChairs,
        0,
        null,
        null,
        null,
        ticketType,
        null,
        null);
  }

  String getBookingError(int reasonCode, {List<DateTime>? optionalParameters}) {
    switch (reasonCode) {
      case 0:
        return AppLocalizations.of(context)!.positiveReply;
      case 1:
        return AppLocalizations.of(context)!.negativeNoBuses;
      case 2:
        return AppLocalizations.of(context)!.negativeTimeInPast;
      case 3:
        return AppLocalizations.of(context)!.negativeNoCommunity;
      case 4:
        return AppLocalizations.of(context)!.negativeNoStopInArea;
      case 5:
        return AppLocalizations.of(context)!.negativeSameStops;
      case 6:
        return AppLocalizations.of(context)!.negativeNoRouting;
      case 7:
        return AppLocalizations.of(context)!.negativeWrongTimeFuture;
      case 8:
        return AppLocalizations.of(context)!.negativeBusesTooSmall;
      case 9:
        return AppLocalizations.of(context)!.negativeTimeBlockerNoBuses;
      case 11:
        if (optionalParameters != null && optionalParameters.length == 2) {
          DateTime from = optionalParameters[0];
          DateTime to = optionalParameters[1];
          String fromAsText;
          String toAsText;
          if (from.day == to.day) {
            fromAsText = getTimeAsTimeString(from);
            toAsText = getTimeAsTimeString(to);
          } else {
            fromAsText = Utils().getDateAsString(from);
            toAsText = Utils().getDateAsString(to);
          }

          return AppLocalizations.of(context)!
              .negativeNoBusesNoAlternativeFound(fromAsText, toAsText);
        } else {
          return AppLocalizations.of(context)!.negativeNoRouting;
        }

      case 98:
        return AppLocalizations.of(context)!.negativeSameFavoriteStops;
      case 99:
        return AppLocalizations.of(context)!.negativeSameStops;
      case 504:
        return AppLocalizations.of(context)!.dialogTimeoutErrorText;
      case 999:
        return AppLocalizations.of(context)!.dialogNoInternetErrorText;
      default:
        return AppLocalizations.of(context)!.dialogGenericErrorText;
    }
  }

  Future<void> _showDialog(String title, String message, BuildContext context,
      Function()? onPressed) async {
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
                  'OK',
                  style: CustomTextStyles.bodyMint,
                ),
                onPressed: onPressed == null
                    ? () {
                        Navigator.of(context).pop();
                      }
                    : onPressed),
          ],
        );
      },
    );
  }

  bool isBookingPossible() {
    return !isBlocked &&
        !User().isProcessing &&
        start != null &&
        (selectedSeats > 0 || selectedWheelChairs > 0) &&
        destination != null;
  }

  bool isBlocked = false;
  void blockBookingButton() {
    isBlocked = true;
    Future.delayed(Duration(seconds: 3), () async {
      isBlocked = false;
    });
  }

  Widget _getJourneyOptionButtons(String arrival, String departure) {
    return Container(
      width: double.infinity,
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Radio(
              value: true,
              activeColor: CustomColors.mint,
              groupValue: isDeparture,
              onChanged: (value) {
                setState(() {
                  isDeparture = value as bool;
                });
              }),
          Text(departure),
          Radio(
              value: false,
              activeColor: CustomColors.mint,
              groupValue: isDeparture,
              onChanged: (value) {
                setState(() {
                  isDeparture = value as bool;
                });
              }),
          Text(arrival),
        ],
      ),
    );
  }

  void _processWheelchairSelection(int numberWheelchairs) {
    selectedWheelChairs = numberWheelchairs;
    allowedSeatOptions = numberWheelchairs == 1
        ? seatOptionsWithWheelchair
        : seatOptionsNoWheelchair;
    bool noSeatsSelected = numberWheelchairs == 0 && selectedSeats == 0;
    bool tooManySeatsSelected = numberWheelchairs == 1 && selectedSeats == 6;

    if (noSeatsSelected) {
      selectedSeats = 1;
      _showSeatSelectionMismatchHint(
          AppLocalizations.of(context)!.negativeNoSeatsSelected);
    }

    if (tooManySeatsSelected) {
      selectedSeats = 5;
      _showSeatSelectionMismatchHint(
          AppLocalizations.of(context)!.negativeTooManySeatsSelected);
    }
  }

  void _showSeatSelectionMismatchHint(String message) {
    _showDialog(
        AppLocalizations.of(context)!.dialogInfoTitle, message, context, null);
  }

  Widget _getSeatsDropDownWidget(
      List<int> seats, int value, Function onChanged) {
    return Container(
      width: double.infinity,
      alignment: Alignment.centerRight,
      child: DropdownButton<int>(
        dropdownColor: CustomColors.white,
        value: value,
        icon: const Icon(
          Icons.arrow_drop_down,
          color: CustomColors.mint,
        ),
        iconSize: 24,
        elevation: 15,
        isDense: true,
        onChanged: (int? newValue) {
          onChanged(newValue);
        },
        items: seats.map<DropdownMenuItem<int>>((int value) {
          return DropdownMenuItem<int>(
            value: value,
            child: Text(
              value.toString(),
              style: CustomTextStyles.bodyMint,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _getAlternativesDropDownWidget(String value, Function onChanged) {
    return Container(
      width: double.infinity,
      alignment: Alignment.centerRight,
      child: DropdownButton<String>(
        dropdownColor: CustomColors.white,
        value: value,
        icon: const Icon(
          Icons.arrow_drop_down,
          color: CustomColors.mint,
        ),
        iconSize: 24,
        elevation: 15,
        isDense: true,
        onChanged: (String? newValue) {
          onChanged(newValue);
        },
        items:
            suggestAlternatives.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: CustomTextStyles.bodyMint,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _getTicketTypeDropDownWidget(String value, Function onChanged) {
    return Container(
      width: double.infinity,
      alignment: Alignment.centerRight,
      child: DropdownButton<String>(
        dropdownColor: CustomColors.white,
        value: value,
        icon: const Icon(
          Icons.arrow_drop_down,
          color: CustomColors.mint,
        ),
        iconSize: 24,
        elevation: 15,
        isDense: true,
        onChanged: (String? newValue) {
          onChanged(newValue);
        },
        items: journeyTypes.map<DropdownMenuItem<String>>((TicketType value) {
          return DropdownMenuItem<String>(
            value: value.name,
            child: Text(
              value.name,
              style: CustomTextStyles.bodyMint,
            ),
          );
        }).toList(),
      ),
    );
  }

  _selectDate(BuildContext context) async {
    DateTime today = DateTime.now();
    DateTime selectableEndDate = today.add(const Duration(days: 27));

    final DateTime? selected = await showDatePicker(
        context: context,
        initialDate: startDate!,
        firstDate: today,
        lastDate: selectableEndDate,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: CustomColors.mint, // header background color
                onPrimary: CustomColors.white, // header text color
                onSurface: CustomColors.marine, // body text color
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: CustomColors.marine, // button text color
                ),
              ),
            ),
            child: child!,
          );
        });
    if (selected != null && selected != startDate)
      setState(() {
        startDate = selected;
      });
  }

  _selectTime(BuildContext context) async {
    final TimeOfDay? selected = await showTimePicker(
        context: context,
        initialTime: startTime!,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: CustomColors.mint, // header background color
                onPrimary: CustomColors.white, // header text color
                onSurface: CustomColors.marine, // body text color
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  backgroundColor: CustomColors.marine, // button text color
                ),
              ),
            ),
            child: child!,
          );
        });
    if (selected != null && selected != startTime)
      setState(() {
        startTime = selected;
      });
  }

  Widget _buildAddressRow(String label, String addressLabel,
      Function()? onPressedAddressField, Function()? onPressedMapIcon) {
    return InkWell(
      onTap: onPressedAddressField,
      child: Container(
        margin: EdgeInsets.fromLTRB(15, 5, 0, 10),
        child: Row(
          children: [
            Flexible(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5),
                      bottomLeft: Radius.circular(5),
                      bottomRight: Radius.circular(5)),
                  color: CustomColors.white,
                  border: Border.all(color: CustomColors.lightGrey),
                ),
                child: Text(
                  addressLabel,
                  style: CustomTextStyles.bodyMintBold2,
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.map,
                color: CustomColors.mint,
              ),
              onPressed: onPressedMapIcon,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRow(Widget widget1, Widget widget2, Function()? onPressed,
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
          Container(width: 80, child: widget1),
          InkWell(
            child: widget2,
            onTap: onPressed,
          )
        ],
      ),
    );
  }
}
