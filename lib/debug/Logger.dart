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
import 'package:f_logs/f_logs.dart';
import 'package:flutter/foundation.dart';
import 'package:info_plist/info_plist.dart';
import 'package:stack_trace/stack_trace.dart';

class Logger {
  static bool debugMode = false;

  static Future<void> _initDebug() async {
    debugMode = await InfoPlist.debugVersion;
  }

  static init() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      _initDebug();
    }
  }

  static void debug(String text) {
    if ((defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS) &&
        (!kReleaseMode || debugMode)) {
      FLog.debug(
          className: Trace.current().frames[1].member!.split(".")[0],
          methodName: Trace.current().frames[1].member!.split(".")[1],
          text: text);
    }
  }

  static void info(String text) {
    if ((defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS) &&
        (!kReleaseMode || debugMode)) {
      FLog.info(
          className: Trace.current().frames[1].member!.split(".")[0],
          methodName: Trace.current().frames[1].member!.split(".")[1],
          text: text);
    }
  }

  static void e(String text) {
    if ((defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS) &&
        (!kReleaseMode || debugMode)) {
      FLog.error(
          className: Trace.current().frames[1].member!.split(".")[0],
          methodName: Trace.current().frames[1].member!.split(".")[1],
          text: text);
    }
  }

  static void error(Object object, StackTrace stackTrace) {
    if ((defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS) &&
        (!kReleaseMode || debugMode)) {
      String exception = object.toString();
      FLog.logThis(
          className: Trace.current().frames[1].member!.split(".")[0],
          methodName: Trace.current().frames[1].member!.split(".")[1],
          text: exception,
          type: LogLevel.SEVERE,
          stacktrace: stackTrace);
    }
  }
}
