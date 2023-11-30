import 'package:erzmobil/Constants.dart';
import 'package:erzmobil/debug/Logger.dart';
import 'package:erzmobil/journeys/NewJourney.dart';
import 'package:erzmobil/model/User.dart';
import 'package:erzmobil/views/JourneyFavoriteView.dart';
import 'package:erzmobil/views/JourneyStartAndDestinationView.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({Key? key, required this.changePage}) : super(key: key);

  final void Function(int) changePage;

  @override
  Widget build(BuildContext context) {
    if (User().canBook) {
      return SingleChildScrollView(child: _buildWidgets(context));
    } else {
      return Container(
        padding: EdgeInsets.all(10),
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: CustomTextStyles.bodyGrey,
              children: <TextSpan>[
                TextSpan(
                    text: AppLocalizations.of(context)!.userBlockedDescription),
                TextSpan(
                  style: CustomTextStyles.bodyMintBold,
                  text: AppLocalizations.of(context)!.website,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      _launchErzmobilWebsite();
                    },
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  void _launchErzmobilWebsite() async {
    String userId = User().userId != null ? User().userId! : "";
    String firstName = User().firstName;
    String name = User().name;
    String url = Strings.BLOCKED_USER_ERZMOBIL_URL +
        "?UserID=$userId&Name=$name&Vorname=$firstName";
    Logger.info("Trying to launch url $url");
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Logger.info('Could not launch $url');
    }
  }

  Widget _buildWidgets(BuildContext context) {
    bool isWebApp = (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS);
    return Column(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(20, 10, 20, 20),
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) =>
                      ChangeNotifierProvider.value(
                    value: User(),
                    child: new NewJourneyScreen(changePage: this.changePage),
                  ),
                ),
              );
            },
            child: User().isProcessing
                ? CircularProgressIndicator()
                : Text(
                    AppLocalizations.of(context)!.bookNewJourney,
                  ),
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
          alignment: Alignment.centerLeft,
          child: Text(AppLocalizations.of(context)!.bookLastBookedJourney,
              style: CustomTextStyles.bodyBlackHeadlineBold,
              textAlign: TextAlign.left),
        ),
        Consumer<User>(
            builder: (context, user, child) => _getLastBookedOrEmpty(context)),
        Offstage(
          offstage: isWebApp,
          child: Container(
            margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
            alignment: Alignment.centerLeft,
            child: Text(AppLocalizations.of(context)!.bookFromFavoriteJourney,
                style: CustomTextStyles.bodyBlackHeadlineBold,
                textAlign: TextAlign.left),
          ),
        ),
        Offstage(
          offstage: isWebApp &&
              (User().favoriteJourneys == null ||
                  User().favoriteJourneys!.isEmpty),
          child: const Divider(
            height: 20,
            thickness: 1,
            indent: 15,
            endIndent: 15,
          ),
        ),
        Offstage(
            offstage: isWebApp, child: _getFavoriteJourneysOrEmpty(context)),
        Offstage(
          offstage: User().favoriteJourneys == null ||
              User().favoriteJourneys!.isEmpty,
          child: const Divider(
            height: 0,
            thickness: 1,
            indent: 15,
            endIndent: 15,
          ),
        ),
      ],
    );
  }

  Widget _getLastBookedOrEmpty(BuildContext context) {
    if (User().lastBookedJourney != null) {
      return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      ChangeNotifierProvider.value(
                        value: User(),
                        child: new NewJourneyScreen(
                          changePage: this.changePage,
                          prefilledJourneyData: User().lastBookedJourney,
                        ),
                      )),
            );
          },
          child: Container(
            margin: EdgeInsets.fromLTRB(15, 0, 10, 10),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Divider(
                height: 20,
                thickness: 1,
              ),
              JourneyStartAndDestinationView(
                journey: User().lastBookedJourney!,
                useWhiteTextStyle: false,
                showArrow: true,
              ),
              const Divider(
                height: 20,
                thickness: 1,
              ),
            ]),
          ));
    } else {
      return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Text(AppLocalizations.of(context)!.noJourney,
            style: CustomTextStyles.bodyBlack),
      );
    }
  }

  Widget _getFavoriteJourneysOrEmpty(BuildContext context) {
    if (User().favoriteJourneys != null &&
        User().favoriteJourneys!.isNotEmpty) {
      return Container(
        margin: EdgeInsets.fromLTRB(15, 0, 10, 10),
        child: ListView.separated(
            separatorBuilder: (context, index) {
              return const Divider(
                thickness: 1,
              );
            },
            shrinkWrap: true,
            physics: ScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
            itemCount: User().favoriteJourneys!.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            ChangeNotifierProvider.value(
                              value: User(),
                              child: new NewJourneyScreen(
                                changePage: this.changePage,
                                prefilledJourneyData:
                                    User().favoriteJourneys![index],
                              ),
                            )),
                  );
                },
                child: (User().favoriteJourneys![index].favoriteName != null &&
                        User()
                            .favoriteJourneys![index]
                            .favoriteName!
                            .isNotEmpty)
                    ? JourneyFavoriteView(
                        journey: User().favoriteJourneys![index],
                        showArrow: true,
                      )
                    : JourneyStartAndDestinationView(
                        journey: User().favoriteJourneys![index],
                        useWhiteTextStyle: false,
                        showArrow: true,
                      ),
              );
            }),
      );
    } else {
      return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Text(AppLocalizations.of(context)!.noJourney,
            style: CustomTextStyles.bodyBlack),
      );
    }
  }
}
