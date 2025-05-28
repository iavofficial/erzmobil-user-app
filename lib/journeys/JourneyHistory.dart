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
        foregroundColor: CustomColors.white,
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
