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
import 'dart:convert';
import 'dart:core';

import 'package:erzmobil/debug/Logger.dart';
import 'package:erzmobil/model/BackendResponse.dart';
import 'package:http/http.dart' as http;

import 'Journey.dart';
import 'User.dart';

class JourneyList extends BackendResponse {
  List<Journey>? completedJourneys;
  List<Journey>? bookedJourneys;
  List<Journey>? requestedJourneys;
  bool hasActiveJourneys = false;

  @override
  JourneyList(http.Response? responseOptional) : super(responseOptional) {
    if (responseOptional != null) {
      super.logStatus();
      try {
        if (data != null) {
          data.clear();
        }
        if (completedJourneys != null) {
          completedJourneys!.clear();
        }
        if (requestedJourneys != null) {
          requestedJourneys!.clear();
        }
        if (bookedJourneys != null) {
          bookedJourneys!.clear();
        }

        bool useDirectus = User().useDirectus;

        final parsed = useDirectus
            ? jsonDecode(responseOptional.body)["data"]
                .cast<Map<String, dynamic>>()
            : jsonDecode(responseOptional.body).cast<Map<String, dynamic>>();

        data = parsed
            .map<Journey>((json) => useDirectus
                ? Journey.fromJsonDirectus(json)
                : Journey.fromJson(json))
            .toList();

        if (data != null) {
          for (Journey journey in data) {
            journey.logJson();
          }
        }
        filterJourneys(data);
      } catch (e) {
        super.markInvalid();
      }
    }
  }

  List<Journey> getCompletedJourneys() {
    if (completedJourneys == null) {
      return <Journey>[];
    } else {
      List<Journey> sortedCompletedJourneys = completedJourneys!;
      sortedCompletedJourneys.sort((a, b) {
        if (a.departureTime == null && b.departureTime == null) return 0;
        if (a.departureTime == null) return -1;
        if (b.departureTime == null) return 1;
        return a.departureTime!.compareTo(b.departureTime!);
      });
      return sortedCompletedJourneys.reversed.toList();
    }
  }

  void filterJourneys(journeys) {
    if (completedJourneys == null) {
      completedJourneys = [];
    }
    if (requestedJourneys == null) {
      requestedJourneys = [];
    }
    if (bookedJourneys == null) {
      bookedJourneys = [];
    }
    hasActiveJourneys = false;

    for (Journey journey in journeys) {
      if (journey.status == 'Cancelled' || journey.status == 'RideFinished') {
        completedJourneys!.add(journey);
      } else if (journey.status == 'Started') {
        requestedJourneys!.add(journey);
      } else if (journey.status == 'RideStarted') {
        hasActiveJourneys = true;
        bookedJourneys!.add(journey);
      } else if (journey.status == 'Reserved') {
        bookedJourneys!.add(journey);
      }
    }

    try {
      bookedJourneys!
          .sort((a, b) => a.departureTime!.compareTo(b.departureTime!));
      bookedJourneys!.addAll(requestedJourneys!);
    } catch (e) {
      Logger.error(e, StackTrace.current);
    }
  }

  List<Journey>? getBusData() {
    if (data == null) {
      data = <Journey>[];
    }
    return data as List<Journey>;
  }

  @override
  Error createErrorObject(String responseBody) {
    throw UnimplementedError();
  }
}
