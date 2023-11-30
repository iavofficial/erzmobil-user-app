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
