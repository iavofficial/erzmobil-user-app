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
import 'package:erzmobil/model/BusStop.dart';
import 'package:erzmobil/model/User.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../Constants.dart';

class SelectFavorites extends StatefulWidget {
  @override
  _SelectFavoritesState createState() => _SelectFavoritesState();
}

class _SelectFavoritesState extends State<SelectFavorites> {
  List<BusStop>? stops;
  Map<int, bool> favoritesMapping = {};

  @override
  void initState() {
    stops = User().stopList!.data.cast<BusStop>();
    List<int>? favorites = User().favoriteStops;
    //fill map with existing stops
    if (stops != null) {
      stops?.forEach((element) {
        favoritesMapping[element.id] = false;
      });
    }
    //map stored favorites to existing stops
    if (favorites != null) {
      favorites.forEach((element) {
        favoritesMapping.update(element, (value) => !value);
      });
    }

    super.initState();
  }

  @override
  void deactivate() {
    User().saveFavorites(favoritesMapping);
    super.deactivate();
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
        title: Text(AppLocalizations.of(context)!.favoriteTitle),
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
      body: _showList(context),
    );
  }

  Widget _showList(BuildContext context) {
    if (stops == null) {
      return Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.no_transfer,
              color: CustomColors.anthracite,
            ),
            Text(
              AppLocalizations.of(context)!.noData,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } else
      return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        child: ListView.separated(
          separatorBuilder: (context, index) {
            return Divider(
              thickness: 1,
            );
          },
          itemCount: stops == null ? 0 : stops!.length,
          addAutomaticKeepAlives: false,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                stops![index].name!,
              ),
              trailing: favoritesMapping[stops![index].id] == true
                  ? Icon(Icons.star)
                  : null,
              onTap: () {
                setState(() {
                  bool? isFavorite = favoritesMapping[stops![index].id];
                  favoritesMapping[stops![index].id] = !isFavorite!;
                });
              },
            );
          },
        ),
      );
  }
}
