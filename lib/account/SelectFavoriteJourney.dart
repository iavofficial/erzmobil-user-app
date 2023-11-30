import 'package:erzmobil/Constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SelectFavoriteJourneyScreen extends StatefulWidget {
  const SelectFavoriteJourneyScreen({Key? key}) : super(key: key);

  @override
  State<SelectFavoriteJourneyScreen> createState() =>
      _SelectFavoriteJourneyScreenState();
}

class _SelectFavoriteJourneyScreenState
    extends State<SelectFavoriteJourneyScreen> {
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
      body: Container(),
    );
  }
}
