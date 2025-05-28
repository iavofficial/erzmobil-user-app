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
import 'package:erzmobil/debug/Console.dart';
import 'package:erzmobil/model/User.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class DebugScreen extends StatefulWidget {
  @override
  _DebugScreenState createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );

  late String logs;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<User>(
      builder: (context, user, child) => _buildWidgets(context),
    );
  }

  Widget _buildWidgets(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[CustomColors.mint, CustomColors.marine])),
          ),
          automaticallyImplyLeading: !User().isDebugProcessing,
          centerTitle: true,
          foregroundColor: CustomColors.white,
          title: Text('Debug'),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: CustomColors.backButtonIconColor,
            ),
          ),
          iconTheme:
              IconThemeData(color: CustomColors.mint, opacity: 1.0, size: 40.0),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            /*Container(
              margin: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 10.0),
              child: TextButton(
                style: CustomButtonStyles.flatButtonStyle,
                child: User().isDebugProcessing
                    ? new CircularProgressIndicator()
                    : Text(
                        'Send Logs',
                        style: CustomTextStyles.bodyWhite,
                      ),
                onPressed: User().isDebugProcessing
                    ? null
                    : () {
                        _submit();
                      },
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 10.0),
              child: TextButton(
                style: CustomButtonStyles.flatButtonStyle,
                child: User().isDebugProcessing
                    ? new CircularProgressIndicator()
                    : Text(
                        'Clear Logs',
                        style: CustomTextStyles.bodyWhite,
                      ),
                onPressed: User().isDebugProcessing
                    ? null
                    : () {
                        _deleteLogs();
                      },
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 10.0),
              child: TextButton(
                  style: CustomButtonStyles.flatButtonStyle,
                  child: User().isDebugProcessing
                      ? new CircularProgressIndicator()
                      : Text(
                          'Show Logs',
                          style: CustomTextStyles.bodyWhite,
                        ),
                  onPressed: null),
            ),*/
            Container(
              margin: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 10.0),
              alignment: Alignment.center,
              child: Text('Version: ${_packageInfo.version}'),
            )
          ],
        ));
  }

  void _submit() async {
    //TODO: show feedback?
    //await User().sendLogs();
  }

  void _deleteLogs() async {
    //TODO: show feedback?
    //await User().deleteLogs();
  }
}
