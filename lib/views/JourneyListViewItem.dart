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
import 'package:erzmobil/Constants.dart';
import 'package:erzmobil/model/Journey.dart';
import 'package:erzmobil/views/JourneyStartAndDestinationView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class JourneyListViewItem extends StatelessWidget {
  const JourneyListViewItem(
      {Key? key, required this.journey, required this.showArrow})
      : super(key: key);

  final Journey journey;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return Container(
      //constraints: BoxConstraints(
      //    minHeight: 100, minWidth: double.infinity, maxHeight: 125),
      margin: EdgeInsets.fromLTRB(10, 10, 5, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          JourneyStartAndDestinationView(
              journey: journey, showArrow: showArrow),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: EdgeInsets.only(top: 10),
                alignment: Alignment.bottomLeft,
                child: showStatus()
                    ? Text(
                        journey.getRequestStateString(context),
                        style: TextStyle(color: getRequestColor()),
                      )
                    : Text(''),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(0, 10, 5, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(getTimeAsTimeString(),
                        style: CustomTextStyles.bodyWhite),
                    Text(getTimeAsDayString(),
                        style: CustomTextStyles.bodyWhite),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  String getTimeAsTimeString() {
    return getTimeAsString('kk:mm');
  }

  String getTimeAsDayString() {
    return getTimeAsString('dd.MM.yyyy');
  }

  String getTimeAsString(String pattern) {
    if (journey.departureTime != null) {
      return DateFormat(pattern).format(journey.departureTime!.toLocal());
    } else if (journey.cancelledOn != null) {
      return DateFormat(pattern).format(journey.cancelledOn!.toLocal());
    } else
      return '';
  }

  bool showStatus() {
    return journey.status != 'UNKOWN';
    //return journey.status != 'Started' && journey.status != 'Reserved';
  }

  Color getRequestColor() {
    switch (journey.status) {
      case 'Started':
        return Colors.orange;
      case 'Reserved':
      case 'RideStarted':
        return CustomColors.green;
      case 'Cancelled':
        return Colors.red;
      case 'RideFinished':
      default:
        return Colors.white;
    }
  }
}
