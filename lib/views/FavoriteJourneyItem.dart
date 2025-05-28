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
import 'package:erzmobil/model/Journey.dart';
import 'package:flutter/material.dart';

class FavoriteJourneyItemView extends StatelessWidget {
  const FavoriteJourneyItemView({Key? key, required this.journey})
      : super(key: key);

  final Journey journey;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 5, 15, 10),
      child: Row(
        children: [
          Image.asset(
            Strings.assetPathRoute,
            scale: 1.2,
          ),
          Flexible(
            child: (journey.favoriteName != null &&
                    journey.favoriteName!.isNotEmpty)
                ? Container(
                    margin: EdgeInsets.fromLTRB(10, 0, 5, 0),
                    alignment: Alignment.topLeft,
                    child: Text(
                      journey.favoriteName!,
                      style: CustomTextStyles.bodyBlackBold,
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                : Column(children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(10, 0, 5, 5),
                      alignment: Alignment.topLeft,
                      child: Text(
                        journey.startAddress!.label!,
                        style: CustomTextStyles.bodyBlackBold,
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(10, 0, 5, 0),
                      alignment: Alignment.topLeft,
                      child: Text(
                        journey.destinationAddress!.label!,
                        style: CustomTextStyles.bodyBlackBold,
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ]),
          ),
          Icon(Icons.chevron_right, color: CustomColors.black)
        ],
      ),
    );
  }
}
