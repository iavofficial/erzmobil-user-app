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
import 'package:erzmobil/model/RequestState.dart';
import 'package:erzmobil/model/User.dart';
import 'package:flutter/material.dart';
import 'package:erzmobil/model/Journey.dart';
import 'package:provider/provider.dart';
import '../journeys/JourneyDetails.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

//import '../model/Location.dart';
import 'JourneyListViewItem.dart';

class JourneyListView extends StatelessWidget {
  const JourneyListView(
      {Key? key, required this.journeys, required this.showArrow})
      : super(key: key);

  final List<Journey> journeys;
  final bool showArrow;

  Widget _journeyDetailsScreen(int index, int numberJourneys) {
    if (numberJourneys > 1) {
      return new JourneyDetailsScreen.multipleJourneys(
          currentJourneyId: journeys[index].id,
          selectedIndex: index,
          numberTotalJourneys: journeys.length,
          showButtonToMyJourneys: false);
    }

    return new JourneyDetailsScreen.singleJourney(
        currentJourneyId: journeys[index].id, showButtonToMyJourneys: false);
  }

  /*
  void _setDebugData(){
    journeys.clear();
    Address start = Address(1, "startloooooooooooooooooooooooooooooooooooooooooooooooooooooong", new Location(54.11, 54.11));
    Address destination = Address(1, "destinationlooooooooooooooooooooooooooooooooooooooooooooog", new Location(57.11, 57.11));
    Journey journey = Journey(1, start, destination, "19:00", DateTime.now(), false, 1, 1, "open", "", null);
    journeys.add(journey);
  }
  */
  @override
  Widget build(BuildContext context) {
    //_setDebugData();
    return Container(
      child: journeys.length > 0
          ? ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(10),
              itemCount: journeys.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () {
                    if (showArrow) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              ChangeNotifierProvider.value(
                            value: User(),
                            child:
                                _journeyDetailsScreen(index, journeys.length),
                          ),
                        ),
                      );
                    }
                  },
                  child: Card(
                      elevation: 5,
                      child: JourneyListViewItem(
                        journey: journeys[index],
                        showArrow: showArrow,
                      )),
                );
              })
          : Stack(
              children: [
                ListView(),
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.no_transfer,
                        color: CustomColors.anthracite,
                      ),
                      Text(AppLocalizations.of(context)!.noJourneys),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
