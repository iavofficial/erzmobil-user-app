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
import 'package:erzmobil/debug/Logger.dart';
import 'package:erzmobil/model/RequestState.dart';

import '../Constants.dart';
import '../views/JourneyListView.dart';
import 'package:flutter/material.dart';
import 'package:erzmobil/model/User.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyJourneysScreen extends StatelessWidget {
  const MyJourneysScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Logger.info('MyJourneys build');
    return Container(
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
                : _buildList(context),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () async {
          RequestState result = await User().loadJourneys();
          if (result == RequestState.ERROR_FAILED_NO_INTERNET) {
            _showDialog(
                AppLocalizations.of(context)!.dialogErrorTitle,
                AppLocalizations.of(context)!.dialogMessageNoInternet,
                context,
                null);
          }
        },
        child: User().isLoggedIn() &&
                User().journeyList != null &&
                User().journeyList!.bookedJourneys != null &&
                User().journeyList!.isSuccessful()
            ? JourneyListView(
                journeys: User().journeyList!.bookedJourneys!,
                showArrow: true,
              )
            : getErrorWidget(context));
  }

  Widget getErrorWidget(BuildContext context) {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Container(
        margin: EdgeInsets.fromLTRB(15, 30, 15, 30),
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Offstage(
              offstage: User().journeyList == null,
              child: User().journeyList != null
                  ? Text(User().journeyList!.getErrorMessage(context),
                      textAlign: TextAlign.center)
                  : Text(""),
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 10)),
            Text(AppLocalizations.of(context)!.journeyError,
                textAlign: TextAlign.center),
          ],
        ),
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
}
