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
                            child: new JourneyDetailsScreen(
                                currentJourneyId: journeys[index].id,
                                showButtonToMyJourneys: false),
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
