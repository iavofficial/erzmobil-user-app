import 'package:erzmobil/Constants.dart';
import 'package:flutter/material.dart';
import 'package:erzmobil/model/User.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class AlternateJourneyTimesScreen extends StatefulWidget {
  const AlternateJourneyTimesScreen(
      {Key? key, required this.alternateTimes, required this.originalTime})
      : super(key: key);

  final List<DateTime> alternateTimes;
  final DateTime originalTime;

  @override
  _AlternateJourneyTimesState createState() => _AlternateJourneyTimesState();
}

class _AlternateJourneyTimesState extends State<AlternateJourneyTimesScreen> {
  int selectedIndex = -1;

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
      body: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(10, 10, 10, 15),
              child: Text(
                  AppLocalizations.of(context)!.alternateJourneys(
                      getTimeAsTimeString(widget.originalTime)),
                  style: CustomTextStyles.bodyBlack),
            ),
            Padding(padding: EdgeInsets.all(10)),
            Divider(
              thickness: 1,
              height: 0,
            ),
            Flexible(
              child: Container(
                child: ListView.builder(
                  itemCount: widget.alternateTimes.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      color: (index == selectedIndex)
                          ? CustomColors.anthracite
                          : CustomColors.white,
                      child: InkWell(
                        onTap: () {
                          onTimeSelected(index);
                        },
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          Container(
                            margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                            child: Text(
                              getTimeAsTimeString(widget.alternateTimes[index]),
                              style: (index == selectedIndex)
                                  ? CustomTextStyles.bodyWhite
                                  : CustomTextStyles.bodyBlack,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const Divider(
                            height: 0,
                            thickness: 1,
                          ),
                        ]),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(padding: EdgeInsets.all(10)),
            getButton(context)
          ],
        ),
      ),
    );
  }

  Widget getButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: ElevatedButton(
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all<Color>(CustomColors.mint),
            foregroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed))
                  return Theme.of(context).colorScheme.primary.withOpacity(0.5);
                else if (states.contains(MaterialState.disabled))
                  return CustomColors.white;
                return CustomColors.black;
              },
            )),
        onPressed: bookSelectedTime,
        child: Text(AppLocalizations.of(context)!.orderAlternateTime),
      ),
    );
  }

  void bookSelectedTime() {
    if (selectedIndex != -1) {
      DateTime selectedTime = widget.alternateTimes[selectedIndex];
      Navigator.pop(context, selectedTime);
    }
  }

  void onTimeSelected(int index) {
    setState(() {
      if (selectedIndex == -1) {
        selectedIndex = index;
      } else if (selectedIndex == index) {
        selectedIndex = -1;
      } else {
        selectedIndex = index;
      }
    });
  }

  String getTimeAsTimeString(DateTime alternateTime) {
    return DateFormat('kk:mm').format(alternateTime.toLocal());
  }
}
