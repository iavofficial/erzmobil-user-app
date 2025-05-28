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
import 'package:erzmobil/Constants.dart';
import 'package:erzmobil/debug/DebugWidget.dart';
import 'package:erzmobil/debug/Logger.dart';
import 'package:erzmobil/map/UserMap.dart';
import 'package:erzmobil/model/User.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class InformationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 25),
              ),
              /*Container(
                  margin: EdgeInsets.only(top: 25),
                  child: _buildRow(AppLocalizations.of(context)!.erzmobilStoryTitle,
                      _buildIcon(Icons.info), () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => new HeatStory()));
                      }),
                ),*/
              _buildRow(AppLocalizations.of(context)!.aboutErzmobil,
                  _buildIcon(Icons.info), () {
                _launchAboutErzmobil();
              }),
              _buildRow(
                  AppLocalizations.of(context)!.map, _buildIcon(Icons.map), () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => new UserMap(showBusStopMarkers: true, showStartEndStation: false,),
                ));
              }),
              _buildRow(AppLocalizations.of(context)!.licenses,
                  _buildIcon(Icons.library_books), () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => new LicensePage(),
                  ),
                );
              }),
              _buildRow(AppLocalizations.of(context)!.imprintLabel,
                  _buildIcon(Icons.privacy_tip), () {
                _launchImprint();
              }),
              _buildRow(AppLocalizations.of(context)!.dataprivacyLabel,
                  _buildIcon(Icons.policy), () {
                _launchDataprivacy();
              }),
              _buildDebug(context),
            ],
          ),
        ),
        Container(
          alignment: Alignment.bottomCenter,
          margin: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 30.0),
          child: (defaultTargetPlatform == TargetPlatform.android ||
                  defaultTargetPlatform == TargetPlatform.iOS)
              ? RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: CustomTextStyles.bodyGrey,
                    children: <TextSpan>[
                      TextSpan(
                          text:
                              AppLocalizations.of(context)!.sendFeedbackText1),
                      TextSpan(
                        style: CustomTextStyles.bodyMintBold,
                        text: AppLocalizations.of(context)!.mail,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            _sendFeedback();
                          },
                      ),
                      TextSpan(
                          text:
                              AppLocalizations.of(context)!.sendFeedbackText2),
                      TextSpan(
                        style: CustomTextStyles.bodyMintBold,
                        text: AppLocalizations.of(context)!.phone,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            _callSupport();
                          },
                      ),
                    ],
                  ),
                )
              : RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: CustomTextStyles.bodyGrey,
                    children: <TextSpan>[
                      TextSpan(
                          text:
                              AppLocalizations.of(context)!.sendFeedbackText3),
                      TextSpan(
                        style: CustomTextStyles.bodyMintBold,
                        text: AppLocalizations.of(context)!.email,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            _launchEmail();
                          },
                      ),
                      TextSpan(
                          text:
                              AppLocalizations.of(context)!.sendFeedbackText4),
                    ],
                  ),
                ),
        )
      ],
    );
  }

  Future<void> _sendFeedback() async {
    final Email email = Email(
      recipients: [''],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
    } catch (e) {
      Logger.e("Sending feedback failed! Missing client.");
      print(e);
    }
  }

  void _launchEmail() async {
    if (await canLaunch(Strings.MAILTO_URL)) {
      await launch(Strings.MAILTO_URL);
    } else {
      Logger.info('Could not launch $Strings.MAILTO_URL');
    }
  }

  void _launchImprint() async {
    if (await canLaunch(Strings.IMPRINT_URL)) {
      await launch(Strings.IMPRINT_URL);
    } else {
      Logger.info('Could not launch $Strings.IMPRINT_URL');
    }
  }

  void _launchAboutErzmobil() async {
    if (await canLaunch(Strings.ABOUT_ERZMOBIL_URL)) {
      await launch(Strings.ABOUT_ERZMOBIL_URL);
    } else {
      Logger.info('Could not launch $Strings.ABOUT_ERZMOBIL_URL');
    }
  }

  void _callSupport() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: Strings.SUPPORT_PHONE_NUMBER,
    );
    if (await canLaunch(launchUri.toString())) {
      await launch(launchUri.toString());
    } else {
      Logger.info('Could not launch $Strings.SUPPORT_PHONE_NUMBER');
    }
  }

  void _launchDataprivacy() async {
    if (await canLaunch(Strings.DATAPRIVACY_URL)) {
      await launch(Strings.DATAPRIVACY_URL);
    } else {
      Logger.info('Could not launch $Strings.DATAPRIVACY_URL');
    }
  }

  Widget _buildDebug(BuildContext context) {
    return !kReleaseMode || Logger.debugMode
        ? _buildRow('Debug', _buildIcon(Icons.library_books), () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => ChangeNotifierProvider.value(
                  value: User(), child: DebugScreen()),
            ));
          })
        : Container();
  }

  Widget _buildIcon(IconData data) {
    return Icon(
      data,
      color: CustomColors.mint,
      size: 30,
    );
  }

  Widget _buildImage(String asset) {
    return Container(
      width: 50,
      height: 50,
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        repeat: ImageRepeat.noRepeat,
      ),
    );
  }

  Widget _buildRow(String text, Widget icon, Function()? onPressed) {
    return InkWell(
      child: Container(
        margin: EdgeInsets.only(left: 15, right: 15),
        child: Row(
          children: <Widget>[
            icon,
            Flexible(
              fit: FlexFit.loose,
              child: Container(
                margin: EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: Text(
                  text,
                  style: CustomTextStyles.bodyMint,
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
          ],
        ),
      ),
      onTap: onPressed,
    );
  }
}
