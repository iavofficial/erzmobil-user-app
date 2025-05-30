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
class CognitoData {
  final String? userClientId;
  final String? userPoolId;
  final String? driverClientId;

  const CognitoData(this.userClientId, this.driverClientId, this.userPoolId);

  factory CognitoData.fromJson(Map<String, dynamic> json) {
    return CognitoData(
        json['userClientId'], json['driverClientId'], json['userPoolId']);
  }

  bool isValid() {
    return userClientId != null && userPoolId != null;
  }
}
