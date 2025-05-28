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
import 'package:erzmobil/model/BusStop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FavoriteStopView extends StatelessWidget {
  const FavoriteStopView({Key? key, required this.busStop}) : super(key: key);

  final BusStop busStop;

  @override
  Widget build(BuildContext context) {
    return _buildRow(
        context,
        Icon(
          Icons.place,
          color: CustomColors.black,
          size: 30,
        ),
        busStop.name!,
        null,
        () => null);
  }

  Widget _buildRow(BuildContext context, Widget iconPlaceholder, String title,
      String? information, Function()? onPressed,
      {TextStyle textStyle = CustomTextStyles.bodyBlackBold}) {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 5, 15, 0),
      child: (information != null)
          ? Row(
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 20, 0),
                  alignment: Alignment.topLeft,
                  width: 30,
                  child: iconPlaceholder,
                ),
                Flexible(
                  child: Container(
                    alignment: Alignment.topLeft,
                    child: Text(
                      title,
                      style: textStyle,
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Container(
                      alignment: Alignment.topRight,
                      child: Text(
                        information,
                        style: CustomTextStyles.bodyBlack,
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 20, 0),
                  alignment: Alignment.topLeft,
                  width: 20,
                  child: iconPlaceholder,
                ),
                Flexible(
                  child: Container(
                    alignment: Alignment.topLeft,
                    child: Text(
                      title,
                      style: textStyle,
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
