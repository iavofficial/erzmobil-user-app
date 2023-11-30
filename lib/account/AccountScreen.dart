import 'package:erzmobil/Constants.dart';
import 'package:erzmobil/account/AccountDetails.dart';
import 'package:erzmobil/account/Favorites.dart';
import 'package:erzmobil/account/LoginScreen.dart';
import 'package:erzmobil/account/RegisterScreen.dart';
import 'package:erzmobil/account/SelectFavorites.dart';
import 'package:erzmobil/debug/Logger.dart';
import 'package:erzmobil/model/RequestState.dart';
import 'package:erzmobil/model/User.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final GlobalKey<_AccountScreenState> _accountScreenStateKey =
      GlobalKey<_AccountScreenState>();
  @override
  Widget build(BuildContext context) {
    return Consumer<User>(
      key: _accountScreenStateKey,
      builder: (context, user, child) => _buildWidgets(context),
    );
  }

  Widget _buildWidgets(BuildContext context) {
    if (User().isLoggedIn()) {
      return ListView(
        children: <Widget>[
          _getAppIcon(),
          Padding(padding: EdgeInsets.only(top: 30)),
          Container(
            margin: EdgeInsets.only(left: 25, right: 25),
            child: Text(
              AppLocalizations.of(context)!.loggedInAsLabel,
              style: CustomTextStyles.bodyGrey,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(25, 0, 25, 5),
            child: Text(
              User().email!,
              style: CustomTextStyles.bodyGrey,
              softWrap: true,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Divider(
            height: 20,
            thickness: 1,
          ),
          InkWell(
            child: Container(
              margin: EdgeInsets.only(left: 15, right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    fit: FlexFit.loose,
                    child: Container(
                      margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
                      child: Text(
                        AppLocalizations.of(context)!.accountDetails,
                        style: CustomTextStyles.bodyMint,
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: CustomColors.mint,
                    size: 30,
                  )
                ],
              ),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) =>
                      ChangeNotifierProvider.value(
                    value: User(),
                    child: new AccountDetailsScreen(),
                  ),
                ),
              );
            },
          ),
          const Divider(
            height: 20,
            thickness: 1,
          ),
          Offstage(
            offstage: (defaultTargetPlatform != TargetPlatform.android &&
                defaultTargetPlatform != TargetPlatform.iOS),
            child: InkWell(
              child: Container(
                margin: EdgeInsets.only(left: 15, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      fit: FlexFit.loose,
                      child: Container(
                        margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
                        child: Text(
                          AppLocalizations.of(context)!.favoriteTitle,
                          style: CustomTextStyles.bodyMint,
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: CustomColors.mint,
                      size: 30,
                    )
                  ],
                ),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) =>
                        ChangeNotifierProvider.value(
                      value: User(),
                      child: new FavoritesOverview(),
                    ),
                  ),
                );
              },
            ),
          ),
          Offstage(
            offstage: (defaultTargetPlatform != TargetPlatform.android &&
                defaultTargetPlatform != TargetPlatform.iOS),
            child: const Divider(
              height: 20,
              thickness: 1,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 15.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 15.0),
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10.0)),
                  onPrimary: Colors.white,
                  primary: CustomColors.mint),
              child: User().isProgressLogout
                  ? new CircularProgressIndicator()
                  : Text(
                      AppLocalizations.of(context)!.signout,
                      style: CustomTextStyles.bodyWhite,
                    ),
              onPressed: User().isProcessing
                  ? null
                  : () {
                      _logout(context);
                    },
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 30.0),
            child: RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                style: CustomTextStyles.bodyGrey,
                children: <TextSpan>[
                  TextSpan(
                      text: AppLocalizations.of(context)!.deleteAccountText1),
                  TextSpan(
                      style: CustomTextStyles.bodyMintBold,
                      text: AppLocalizations.of(context)!.deleteAccountText2,
                      recognizer: TapGestureRecognizer()
                        ..onTap = User().isProcessing
                            ? null
                            : () {
                                _confirmDeleteDialog();
                              })
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _getAppIcon(),
          _buildButton(
            AppLocalizations.of(context)!.signup,
            ChangeNotifierProvider.value(
                value: User(), child: RegisterScreen()),
          ),
          _buildButton(
            AppLocalizations.of(context)!.signin,
            ChangeNotifierProvider.value(value: User(), child: LoginScreen()),
          ),
        ],
      );
    }
  }

  Widget _getAppIcon() {
    return Container(
      margin: EdgeInsets.fromLTRB(25.0, 30, 50.0, 10),
      alignment: Alignment.centerLeft,
      child: new Image.asset(
        Strings.assetPathLogo,
        fit: BoxFit.cover,
        repeat: ImageRepeat.noRepeat,
      ),
    );
  }

  void _logout(BuildContext context) async {
    RequestState state = await User().logout();
    if (state != RequestState.SUCCESS) {
      Logger.debug("Error occured during logout");
    }
  }

  void _delete(BuildContext context) async {
    RequestState state = await User().deleteUser();
    if (_accountScreenStateKey.currentContext != null) {
      if (state == RequestState.ERROR_FAILED_NO_INTERNET) {
        _showDialog(
            AppLocalizations.of(_accountScreenStateKey.currentContext!)!
                .dialogErrorTitle,
            AppLocalizations.of(_accountScreenStateKey.currentContext!)!
                .dialogMessageNoInternet);
      } else if (state != RequestState.SUCCESS) {
        _showDialog(
            AppLocalizations.of(_accountScreenStateKey.currentContext!)!
                .dialogErrorTitle,
            AppLocalizations.of(_accountScreenStateKey.currentContext!)!
                .dialogGenericErrorText);
      } else {
        _showDialog(
            AppLocalizations.of(_accountScreenStateKey.currentContext!)!
                .dialogInfoTitle,
            AppLocalizations.of(_accountScreenStateKey.currentContext!)!
                .dialogDeleteAccountText);
      }
    }
  }

  Future<void> _showDialog(String title, String message) async {
    showDialog<void>(
      context: _accountScreenStateKey.currentContext!,
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
                Navigator.of(_accountScreenStateKey.currentContext!).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDeleteDialog() async {
    if (_accountScreenStateKey.currentContext != null) {
      return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.dialogDeleteAccountTitle,
                style: CustomTextStyles.title),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                    AppLocalizations.of(context)!.dialogDeleteAccountMessage,
                    style: CustomTextStyles.bodyGrey,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  AppLocalizations.of(context)!.buttonConfirmDelete,
                  style: CustomTextStyles.bodyMint,
                ),
                onPressed: () {
                  _delete(context);
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text(
                  AppLocalizations.of(context)!.cancel,
                  style: CustomTextStyles.bodyMint,
                ),
                onPressed: () {
                  Navigator.of(_accountScreenStateKey.currentContext!).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildButton(String text, Widget screen) => Container(
        margin: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 15.0),
        child: TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 15.0),
            backgroundColor: CustomColors.mint,
            disabledBackgroundColor: CustomColors.lightGrey,
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(10.0),
            ),
          ),
          child: Text(
            text,
            style: CustomTextStyles.bodyWhite,
          ),
          // Routes must be rebuild after usage, reuse is not possible so we must use a closure and not one route object
          onPressed: User().isProcessing
              ? null
              : () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => screen));
                },
        ),
      );
}
