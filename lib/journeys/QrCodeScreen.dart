import 'package:erzmobil/debug/Logger.dart';
import 'package:erzmobil/model/Journey.dart';
import 'package:erzmobil/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Constants.dart';

class QrCodeScreen extends StatelessWidget {
  const QrCodeScreen({Key? key, required this.currentJourney})
      : super(key: key);
  final Journey? currentJourney;

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
        title: Text('QR-Code'),
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
      body: Padding(
        padding: EdgeInsets.only(top: 20, right: 20, left: 20),
        child: ListView(children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                alignment: Alignment.topLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAddressRow(
                        AppLocalizations.of(context)!.selectRouteFromLabel,
                        currentJourney == null
                            ? Utils.NO_DATA
                            : currentJourney!.startAddress!.label!),
                    _buildAddressRow(
                        AppLocalizations.of(context)!.selectRouteToLabel,
                        currentJourney == null
                            ? Utils.NO_DATA
                            : currentJourney!.destinationAddress!.label!),
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 15)),
              _buildRow(
                  Text(AppLocalizations.of(context)!.bookedOn + ":"),
                  currentJourney == null
                      ? Text(Utils.NO_DATA)
                      : Text(
                          Utils()
                              .getDateAsString(currentJourney!.departureTime),
                          style: CustomTextStyles.bodyGreyBold2,
                        ),
                  mainAxisAlignment: MainAxisAlignment.spaceBetween),
              _buildRow(
                  Text(AppLocalizations.of(context)!.estimatedArrival + ":"),
                  currentJourney == null
                      ? Text(Utils.NO_DATA)
                      : Text(
                          Utils().getDateAsString(
                              currentJourney!.estimatedArrivalTime),
                          style: CustomTextStyles.bodyGreyBold2,
                        ),
                  mainAxisAlignment: MainAxisAlignment.spaceBetween),
            ],
          ),
          Padding(padding: EdgeInsets.only(top: 25)),
          Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                QrImageView(
                  data: currentJourney!.id.toString(),
                  version: QrVersions.auto,
                  size: 300.0,
                ),
                Padding(padding: EdgeInsets.only(top: 25)),
                InkWell(
                  child: Text(
                    AppLocalizations.of(context)!.qrCodeNeedHelp,
                    style: CustomTextStyles.bodyMintBold,
                  ),
                  onTap: () {
                    _launchAboutErzmobil();
                  },
                )
              ],
            ),
          ),
        ]),
      ),
    );
  }

  void _launchAboutErzmobil() async {
    if (await canLaunch(Strings.ABOUT_ERZMOBIL_URL)) {
      await launch(Strings.ABOUT_ERZMOBIL_URL);
    } else {
      Logger.info('Could not launch $Strings.ABOUT_ERZMOBIL_URL');
    }
  }

  Widget _buildRow(Widget widget1, Widget widget2,
      {MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start}) {
    return Row(children: [Container(width: 80, child: widget1), widget2]);
  }

  Widget _buildAddressRow(String label, String addressLabel) {
    return Row(
      children: [
        Container(
          alignment: Alignment.topLeft,
          width: 80,
          child: Text(
            label,
            style: CustomTextStyles.bodyGrey,
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          alignment: Alignment.topLeft,
          child: Text(
            addressLabel,
            style: CustomTextStyles.bodyGreyBold2,
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
        )
      ],
    );
  }
}
