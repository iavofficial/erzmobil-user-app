import 'package:erzmobil/Constants.dart';
import 'package:erzmobil/views/JourneyListView.dart';
import 'package:flutter/material.dart';
import 'package:erzmobil/model/User.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class JourneyHistory extends StatelessWidget {
  const JourneyHistory({Key? key}) : super(key: key);

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
        title: Text(AppLocalizations.of(context)!.myJourneys),
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
      body: User().isLoggedIn() && User().journeyList!.isSuccessful()
          ? JourneyListView(
              journeys: User().journeyList!.getCompletedJourneys(),
              showArrow: false,
            )
          : SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Container(
                margin: EdgeInsets.fromLTRB(15, 30, 15, 30),
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    Text(User().journeyList!.getErrorMessage(context),
                        textAlign: TextAlign.center),
                    Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                    Text(AppLocalizations.of(context)!.journeyError,
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
    );
  }
}
