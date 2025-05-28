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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class JourneyStartAndDestinationView extends StatelessWidget {
  const JourneyStartAndDestinationView(
      {Key? key,
      required this.journey,
      required this.showArrow,
      this.useWhiteTextStyle = true})
      : super(key: key);

  final Journey journey;
  final bool showArrow;
  final bool useWhiteTextStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            alignment: Alignment.topLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                    child: Row(
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          width: 40,
                          child: Text(
                            AppLocalizations.of(context)!.selectRouteFromLabel,
                            style: useWhiteTextStyle
                                ? CustomTextStyles.bodyWhite
                                : CustomTextStyles.bodyBlack,
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Flexible(
                            child: Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            journey.startAddress!.label!,
                            style: useWhiteTextStyle
                                ? CustomTextStyles.bodyWhiteBold
                                : CustomTextStyles.bodyBlackBold,
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
                    child: Row(
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          width: 40,
                          child: Text(
                            AppLocalizations.of(context)!.selectRouteToLabel,
                            style: useWhiteTextStyle
                                ? CustomTextStyles.bodyWhite
                                : CustomTextStyles.bodyBlack,
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Flexible(
                            child: Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            journey.destinationAddress!.label!,
                            style: useWhiteTextStyle
                                ? CustomTextStyles.bodyWhiteBold
                                : CustomTextStyles.bodyBlackBold,
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              showArrow
                  ? Icon(
                      Icons.chevron_right,
                      color: useWhiteTextStyle
                          ? CustomColors.white
                          : CustomColors.black,
                    )
                  : Text(''),
            ],
          ),
        ),
      ],
    );
  }
}
