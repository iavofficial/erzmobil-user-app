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
import 'package:erzmobil/journeys/NewJourney.dart';
import 'package:erzmobil/model/BusStop.dart';
import 'package:erzmobil/model/User.dart';
import 'package:erzmobil/views/FavoriteJourneyItem.dart';
import 'package:erzmobil/views/FavoriteStopItemView.dart';
import 'package:flutter/material.dart';
import 'package:erzmobil/model/Journey.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class FavoritesListView extends StatelessWidget {
  const FavoritesListView(
      {Key? key, required this.journeys, required this.stops})
      : super(key: key);

  final List<Journey>? journeys;
  final List<BusStop>? stops;

  @override
  Widget build(BuildContext context) {
    if ((journeys == null || journeys!.length == 0) &&
        (stops == null || stops!.length == 0)) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.no_transfer,
              color: CustomColors.anthracite,
            ),
            Text(AppLocalizations.of(context)!.noFavorites),
          ],
        ),
      );
    } else
      return Container(
        child: ListView(
          children: [
            Padding(padding: EdgeInsets.only(top: 10)),
            Offstage(
              offstage: stops == null || stops!.length == 0,
              child: ListView.separated(
                  separatorBuilder: (context, index) {
                    return const Divider(
                      thickness: 1,
                    );
                  },
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  itemCount: stops != null ? stops!.length : 0,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                        onTap: () {},
                        child: FavoriteStopView(busStop: stops![index]));
                  }),
            ),
            Offstage(
              offstage: stops == null || stops!.length == 0,
              child: const Divider(
                thickness: 1,
              ),
            ),
            Offstage(
              offstage: journeys == null ||
                  (journeys != null && journeys!.length == 0),
              child: ListView.separated(
                  separatorBuilder: (context, index) {
                    return const Divider(
                      thickness: 1,
                    );
                  },
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  itemCount: journeys != null ? journeys!.length : 0,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      child: FavoriteJourneyItemView(journey: journeys![index]),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                ChangeNotifierProvider.value(
                              value: User(),
                              child: new NewJourneyScreen(
                                changePage: null,
                                prefilledJourneyData: journeys![index],
                                isFavoriteSelection: true,
                                isNewFavorite: false,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
            ),
            Offstage(
              offstage: journeys == null ||
                  (journeys != null && journeys!.length == 0),
              child: const Divider(
                thickness: 1,
              ),
            ),
          ],
        ),
      );
  }
}
