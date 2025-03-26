import 'package:erzmobil/map/SelectionMap.dart';
import 'package:erzmobil/model/BusStop.dart';
import 'package:erzmobil/model/RequestState.dart';
import 'package:erzmobil/model/User.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../Constants.dart';

class SelectStartOrDestination extends StatelessWidget {
  const SelectStartOrDestination(
      {Key? key,
      required this.stops,
      required this.screenTitle,
      required this.favoritesMapping})
      : super(key: key);

  final List<BusStop>? stops;
  final String screenTitle;
  final Map<int, bool> favoritesMapping;

  @override
  Widget build(BuildContext context) {
    if (User().stopList != null && stops!.isEmpty && User().stopList != null) {
      stops!.clear();
      stops!.addAll(User().stopList!.data.cast<BusStop>().toList());
    }
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
          title: Text(screenTitle),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: CustomColors.backButtonIconColor,
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.map),
              onPressed: () {
                _navigateToMap(context);
              },
            )
          ]),
      body: RefreshIndicator(
        onRefresh: () async {
          RequestState result = await User().loadStopList();
          if (result == RequestState.ERROR_FAILED_NO_INTERNET) {
            _showDialog(
                AppLocalizations.of(context)!.dialogErrorTitle,
                AppLocalizations.of(context)!.dialogMessageNoInternet,
                context,
                null);
          }
        },
        child: _showList(context),
      ),
    );
  }

  Future<void> _showDialog(String title, String message, BuildContext context,
      Function()? onPressed) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: CustomTextStyles.title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  message,
                  style: CustomTextStyles.bodyGrey,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                child: Text(
                  'OK',
                  style: CustomTextStyles.bodyMint,
                ),
                onPressed: onPressed == null
                    ? () {
                        Navigator.of(context).pop();
                      }
                    : onPressed),
          ],
        );
      },
    );
  }

  void _navigateToMap(BuildContext context) async {
    final BusStop? selected = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectionMap(screenTitle: screenTitle),
      ),
    );
    Navigator.pop(context, selected);
  }

  Widget _showList(BuildContext context) {
    if (stops == null || stops!.isEmpty) {
      return SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.fromLTRB(15, 30, 15, 30),
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
              Padding(padding: EdgeInsets.symmetric(vertical: 10)),
              Text(
                User().stopList!.getErrorMessage(context),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    } else
      return Container(
        child: Column(
          children: <Widget>[
            _buildList(stops),
            const Divider(
              thickness: 1,
              height: 0,
            ),
          ],
        ),
      );
  }

  Widget _buildList(List<BusStop>? stopList) {
    return Expanded(
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        shrinkWrap: true,
        separatorBuilder: (context, index) {
          return Divider(
            height: 0,
            thickness: 1,
          );
        },
        itemCount: stopList == null ? 0 : stopList.length,
        addAutomaticKeepAlives: false,
        itemBuilder: (context, index) {
          return ListTile(
            title: _buildStopItem(
                context, stopList![index], index == stopList.length - 1),
            trailing: favoritesMapping[stops![index].id] == true
                ? Icon(Icons.star)
                : null,
          );
        },
      ),
    );
  }

  Widget _buildStopItem(BuildContext context, BusStop stop, bool isLastItem) {
    return InkWell(
      onTap: () {
        Navigator.pop(context, stop);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 25),
        padding: EdgeInsets.symmetric(vertical: 5),
        alignment: Alignment.centerLeft,
        child: Text(
          stop.name!,
        ),
      ),
    );
  }
}
