import 'package:flutter/material.dart';
import 'package:erzmobil/Constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:erzmobil/model/RequestState.dart';
import 'package:erzmobil/model/User.dart';
import 'package:provider/provider.dart';

import 'VerifyScreen.dart';

class ResetScreen extends StatefulWidget {
  @override
  _ResetScreenState createState() => _ResetScreenState();
}

class _ResetScreenState extends State<ResetScreen> {
  final _nameFormKey = GlobalKey<FormState>();

  String? _tmpName;

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
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[CustomColors.mint, CustomColors.marine])),
        ),
        automaticallyImplyLeading: !User().isProcessing,
        centerTitle: true,
        foregroundColor: CustomColors.white,
        title: Text(AppLocalizations.of(context)!.forgotPasswordTitle),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(50.0, 30.0, 50.0, 10.0),
              alignment: Alignment.topCenter,
              child: new Image.asset(
                Strings.assetPathLogo,
                fit: BoxFit.cover,
                repeat: ImageRepeat.noRepeat,
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 30.0),
              child: Text(AppLocalizations.of(context)!.resetInfoLabel,
                  style: CustomTextStyles.bodyGrey),
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
                          return AppLocalizations.of(context)!.passwordHint;
                        }
                        if (!Expressions.regExpName.hasMatch(value)) {
                          return AppLocalizations.of(context)!.eMailValidation;
                        }
                        return null;
                      },
                      onSaved: (String? name) {
                        _tmpName = name;
                      },
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 10.0),
              child: TextButton(
                style: CustomButtonStyles.flatButtonStyle,
                child: User().isProgressReset
                    ? new CircularProgressIndicator()
                    : Text(
                        AppLocalizations.of(context)!.buttonResetPwd,
                        style: CustomTextStyles.bodyWhite,
                      ),
                onPressed: User().isProcessing
                    ? null
                    : () {
                        if (_nameFormKey.currentState!.validate()) {
                          _nameFormKey.currentState!.save();
                          _reset(context);
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _reset(BuildContext context) async {
    RequestState state = await User().startForgotPwd(_tmpName);
    if (state == RequestState.SUCCESS) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) =>
            ChangeNotifierProvider.value(value: User(), child: VerifyScreen()),
      ));

      _showDialog(AppLocalizations.of(context)!.dialogSendMailText,
          AppLocalizations.of(context)!.verifyCodeInfoLabel, context);

      return;
    }

    if (state == RequestState.ERROR_FAILED_NO_INTERNET) {
      _showDialog(AppLocalizations.of(context)!.dialogErrorTitle,
          AppLocalizations.of(context)!.dialogNoInternetErrorText, context);
    } else if (state == RequestState.ERROR_USER_UNKNOWN) {
      _showDialog(AppLocalizations.of(context)!.dialogErrorTitle,
          AppLocalizations.of(context)!.dialogUserUnknownErrorText, context);
    }
  }

  Future<void> _showDialog(
      String title, String message, BuildContext context) async {
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
                'OK',
                style: CustomTextStyles.bodyMint,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
