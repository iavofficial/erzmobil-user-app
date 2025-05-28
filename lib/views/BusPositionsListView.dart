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
import 'package:flutter/material.dart';
import 'package:erzmobil/model/BusPosition.dart';

class BusPositionsListView extends StatelessWidget {
  const BusPositionsListView({Key? key, @required this.busPositions})
      : super(key: key);

  final List<BusPosition>? busPositions;

  @override
  Widget build(BuildContext context) {
    return busPositions != null
        ? ListView.builder(
            padding: const EdgeInsets.all(10),
            itemExtent: 120,
            itemCount: busPositions!.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                child: Text(busPositions![index].id.toString()),
              );
            })
        : Center(
            child: Text(
                'Die Bus-Positionen konnten leider nicht abgerufen werden'),
          );
  }
}
