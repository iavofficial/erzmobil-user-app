import 'package:erzmobil/Constants.dart';
import 'package:erzmobil/account/SelectFavorites.dart';
import 'package:erzmobil/journeys/NewJourney.dart';
import 'package:erzmobil/model/User.dart';
import 'package:erzmobil/views/FavoritesListView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class FavoritesOverview extends StatelessWidget {
  const FavoritesOverview({Key? key}) : super(key: key);

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
      body: _buildWidgets(context),
    );
  }

  Widget _buildWidgets(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(20, 10, 20, 5),
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => new SelectFavorites(),
              ));
            },
            child: Text(
              AppLocalizations.of(context)!.addNewFavoriteStop,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        ChangeNotifierProvider.value(
                          value: User(),
                          child: new NewJourneyScreen(
                            changePage: null,
                            isFavoriteSelection: true,
                          ),
                        )),
              );
            },
            child: Text(
              AppLocalizations.of(context)!.addNewFavoriteJourney,
            ),
          ),
        ),
        _buildFavoriteList(context)
      ],
    );
  }

  Widget _buildFavoriteList(BuildContext context) {
    return Flexible(
        child: Consumer<User>(
      builder: (context, user, child) =>
          User().isLoggedIn() && User().isProcessing ||
                  User().isProgressUpdateJourneys
              ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      new CircularProgressIndicator(),
                    ],
                  ),
                )
              : FavoritesListView(
                  journeys: User().favoriteJourneys,
                  stops: User().getFavoriteStops()),
    ));
  }
}
