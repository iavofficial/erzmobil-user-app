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
