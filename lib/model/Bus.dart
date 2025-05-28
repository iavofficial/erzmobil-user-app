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
import 'package:erzmobil/model/VehicleType.dart';

class Bus {
  final int busId;
  final String? licenseplate;
  final VehicleType vehicletype;

  Bus(this.busId, this.licenseplate, this.vehicletype);

  factory Bus.fromJsonDirectus(Map<String, dynamic> json) {
    return Bus(json['id'] as int, json['licensePlate'] as String,
        json['vehicletype'] as VehicleType);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.busId;
    data['licensePlate'] = this.licenseplate;
    data['vehicletype'] = this.vehicletype;

    return data;
  }
}
