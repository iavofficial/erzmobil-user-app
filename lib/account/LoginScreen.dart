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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:erzmobil/Constants.dart';
import 'package:erzmobil/account/VerifyScreen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:erzmobil/model/RequestState.dart';
import 'package:erzmobil/model/User.dart';
import 'package:provider/provider.dart';

import 'ResetScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  String? _tmpPwd;
  bool obscurePwd = true;

  void _submit(BuildContext context) async {
    //check system state

    RequestState state = await User().login(_tmpPwd, context);
    if (state != RequestState.SUCCESS) {
      if (state == RequestState.ERROR_FAILED_NO_INTERNET) {
        _showDialog(
            AppLocalizations.of(context)!.dialogErrorTitle,
            AppLocalizations.of(context)!.dialogNoInternetErrorText,
            context,
            false);
      } else if (state == RequestState.ERROR_WRONG_CREDENTIALS) {
        _showDialog(
            AppLocalizations.of(context)!.dialogErrorTitle,
            AppLocalizations.of(context)!.dialogWrongCredentialsErrorText,
            context,
            false);
      } else if (state == RequestState.ERROR_CONFIRMATION_NECESSARY) {
        _showDialog(
            AppLocalizations.of(context)!.dialogInfoTitle,
            AppLocalizations.of(context)!.dialogConfirmNecessaryText,
            context,
            true);
      } else if (state == RequestState.ERROR_USER_UNKNOWN) {
        _showDialog(AppLocalizations.of(context)!.dialogErrorTitle,
            AppLocalizations.of(context)!.userNotAvailable, context, false);
      } else {
        _showDialog(
            AppLocalizations.of(context)!.dialogErrorTitle,
            AppLocalizations.of(context)!.dialogGenericErrorText,
            context,
            false);
      }
      return;
    }
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      RequestState result = await User().registerToken();
      await User().showFCMErrorIfnecessary(context, result);
    }

    Navigator.of(context).pop();
  }

  void _sendMail() async {
    RequestState state = await User().resendConfirmationCode(User().email);
    if (state == RequestState.SUCCESS) {
      _showDialog(AppLocalizations.of(context)!.dialogInfoTitle,
          AppLocalizations.of(context)!.dialogSendMailText, context, false);
    } else {
      _showDialog(AppLocalizations.of(context)!.dialogErrorTitle,
          AppLocalizations.of(context)!.dialogGenericErrorText, context, false);
    }
  }

  Future<void> _showDialog(String title, String message, BuildContext context,
      bool isConfirmNecessary) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: CustomTextStyles.title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  message,
                  style: CustomTextStyles.bodyGrey,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                isConfirmNecessary
                    ? AppLocalizations.of(context)!.buttonSend
                    : 'OK',
                style: CustomTextStyles.bodyMint,
              ),
              onPressed: () {
                if (isConfirmNecessary) {
                  _sendMail();
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Consumer<User>(
            builder: (context, user, child) => _buildWidgets(context)),
        onWillPop: () async {
          return !User().isProcessing;
        });
  }

  Widget _buildWidgets(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !User().isProcessing,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[CustomColors.mint, CustomColors.marine])),
        ),
        centerTitle: true,
        foregroundColor: CustomColors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: CustomColors.backButtonIconColor,
          ),
        ),
        title: Text(AppLocalizations.of(context)!.signin),
        iconTheme:
            IconThemeData(color: CustomColors.mint, opacity: 1.0, size: 40.0),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(50.0, 30.0, 50.0, 10.0),
              alignment: Alignment.topCenter,
              child: Icon(
                Icons.account_circle,
                color: CustomColors.mint,
                size: 100,
              ),
            ),
            Form(
              key: _nameFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 10.0),
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      style: CustomTextStyles.bodyGrey,
                      autocorrect: false,
                      enabled: !User().isProcessing,
                      decoration: new InputDecoration(
                          labelText:
                              AppLocalizations.of(context)!.placeholderEmail,
                          labelStyle: CustomTextStyles.bodyLightGrey,
                          errorMaxLines: 2),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return AppLocalizations.of(context)!.placeholderEmail;
                        }
                        if (!Expressions.regExpName.hasMatch(value.trim())) {
                          return AppLocalizations.of(context)!.eMailValidation;
                        }
                        return null;
                      },
                      onSaved: (String? email) {
                        User().email = email!.trim();
                      },
                    ),
                  )
                ],
              ),
            ),
            Form(
              key: _passwordFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 20.0),
                    child: TextFormField(
                      obscureText: obscurePwd,
                      style: CustomTextStyles.bodyGrey,
                      autocorrect: false,
                      enabled: !User().isProcessing,
                      decoration: new InputDecoration(
                          suffixIcon: IconButton(
                              icon: Icon(
                                obscurePwd
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: CustomColors.black,
                                size: 18,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscurePwd = !obscurePwd;
                                });
                              }),
                          labelText:
                              AppLocalizations.of(context)!.placeholderPassword,
                          labelStyle: CustomTextStyles.bodyLightGrey,
                          errorMaxLines: 3),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return AppLocalizations.of(context)!
                              .placeholderPassword;
                        }
                        return null;
                      },
                      onSaved: (String? pwd) {
                        _tmpPwd = pwd;
                      },
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 10.0),
              child: TextButton(
                style: TextButton.styleFrom(
                    padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 15.0),
                    backgroundColor: CustomColors.mint,
                    disabledBackgroundColor: CustomColors.lightGrey,
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                    )),
                child: User().isProgressLogin || User().isProgressConfirm
                    ? new CircularProgressIndicator()
                    : Text(
                        AppLocalizations.of(context)!.signin,
                        style: CustomTextStyles.bodyWhite,
                      ),
                onPressed: User().isProcessing
                    ? null
                    : () {
                        if (_nameFormKey.currentState!.validate() &&
                            _passwordFormKey.currentState!.validate()) {
                          _nameFormKey.currentState!.save();
                          _passwordFormKey.currentState!.save();
                          _submit(context);
                        }
                      },
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 15.0),
              child: TextButton(
                style: CustomButtonStyles.flatButtonStyle,
                child: Text(
                  AppLocalizations.of(context)!.forgotPassword,
                  style: CustomTextStyles.bodyWhite,
                ),
                onPressed: User().isProcessing
                    ? null
                    : () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) =>
                              ChangeNotifierProvider.value(
                                  value: User(), child: ResetScreen()),
                        ));
                      },
              ),
            ),
            _buildVerifyContainer(context),
          ],
        ),
      ),
    );
  }

  Widget _buildVerifyContainer(BuildContext context) {
    if (User().isPwdVerificationMode()) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0),
            child: Text(AppLocalizations.of(context)!.verifyCodeInfoLabel,
                style: CustomTextStyles.bodyGrey),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0),
            child: TextButton(
              style: CustomButtonStyles.flatButtonStyle,
              child: Text(
                AppLocalizations.of(context)!.enterRegistrationCode,
                style: CustomTextStyles.bodyWhite,
              ),
              onPressed: User().isProcessing
                  ? null
                  : () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) =>
                            ChangeNotifierProvider.value(
                                value: User(), child: VerifyScreen()),
                      ));
                    },
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }
}
