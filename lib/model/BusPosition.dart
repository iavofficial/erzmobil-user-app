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
import 'package:erzmobil/model/Location.dart';

class BusPosition {
  final int? id;
  final Location? position;
  final String? updatedAt;

  const BusPosition(this.id, this.position, this.updatedAt);

  factory BusPosition.fromJson(Map<String, dynamic> json) {
    return BusPosition(
        json['id'] as int,
        json['position'] != null
            ? new Location.fromJson(json['position'])
            : null,
        json['updatedAt']);
  }

  factory BusPosition.fromJsonDirectus(Map<String, dynamic> json) {
    return BusPosition(
        json['id'] as int,
        json['last_position'] != null
            ? new Location.fromJsonDirectus(json['last_position'])
            : null,
        json['last_position_updated_at']);
  }
}
