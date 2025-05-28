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
class RouteRequestResult {
  final bool result;
  final int reasonCode;
  final String reasonText;
  final List<DateTime>? alternativeTimes;
  final List<DateTime>? timeSlot;

  RouteRequestResult(this.result, this.reasonCode, this.reasonText,
      this.alternativeTimes, this.timeSlot);

  factory RouteRequestResult.fromJson(Map<String, dynamic> json) {
    return RouteRequestResult(
        json['result'] as bool,
        json['reasonCode'] as int,
        json['reasonText'],
        json['alternativeTimes'] != null
            ? getTimes(json['alternativeTimes'].cast<String>())
            : getTimes(null),
        json['timeSlot'] != null
            ? getTimes(json['timeSlot'].cast<String>())
            : getTimes(null));
  }

  static List<DateTime>? getTimes(List<String>? times) {
    List<DateTime> dateTimes = [];
    if (times != null && times.isNotEmpty) {
      times.forEach((element) {
        dateTimes.add(DateTime.parse(element));
      });
    }
    return dateTimes;
  }
}
