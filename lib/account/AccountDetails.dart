import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:erzmobil/Constants.dart';
import 'package:erzmobil/model/User.dart';
import 'package:erzmobil/utils/Utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AccountDetailsScreen extends StatefulWidget {
  @override
  _AccountDetailsScreenState createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  List<CognitoUserAttribute>? attributes;

  final _firstNameFormKey = GlobalKey<FormState>();
  final _lastNameFormKey = GlobalKey<FormState>();
  final _phoneFormKey = GlobalKey<FormState>();
  final _addressFormKey = GlobalKey<FormState>();
  bool _firstNameEntered = false;
  bool _lastNameEntered = false;
  bool _addressEntered = false;
  bool _phoneNumberEntered = false;
  String? _tmpFirstName;
  String? _tmpLastName;
  String? _tmpPhone;
  String? _tmpAddress;

  bool _isPhoneEditable = false;
  bool _isAddressEditable = false;
  bool _isFirstNameEditable = false;
  bool _isLastNameEditable = false;

  double contentPadding = 0;

  late FocusNode firstNameFocus;

  final RegExp _regExpPhoneNumber = RegExp(r'(^([+][0-9]{10,14})$)');

  @override
  void initState() {
    super.initState();
    firstNameFocus = FocusNode();
  }

  String getValue(String attributeName) {
    if (attributes != null) {}

    return Utils.NO_DATA;
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
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[CustomColors.mint, CustomColors.marine])),
          ),
          automaticallyImplyLeading: !User().isProcessing,
          centerTitle: true,
          title: Text(AppLocalizations.of(context)!.accountDetails),
          iconTheme:
              IconThemeData(color: CustomColors.mint, opacity: 1.0, size: 40.0),
          actions: null,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: CustomColors.backButtonIconColor,
            ),
          ),
        ),
        body: SingleChildScrollView(
            child: Column(
          children: [
            _buildRow(
                context,
                AppLocalizations.of(context)!.placeholderGivenName,
                User().firstName, () {
              _showDialog(() {
                if (_firstNameFormKey.currentState!.validate()) {
                  _firstNameFormKey.currentState!.save();
                  if (User().firstName != _tmpFirstName!) {
                    User().saveUserData("given_name", _tmpFirstName!, context);
                  }
                  Navigator.of(context).pop();
                }
              },
                  AppLocalizations.of(context)!.editData(
                      AppLocalizations.of(context)!.placeholderGivenName),
                  User().firstName,
                  Form(
                    key: _firstNameFormKey,
                    onChanged: () => setState(
                      () => _firstNameEntered =
                          _firstNameFormKey.currentState!.validate(),
                    ),
                    child: TextFormField(
                      textAlign: TextAlign.start,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      obscureText: false,
                      autofocus: true,
                      style: CustomTextStyles.bodyGrey,
                      autocorrect: false,
                      initialValue: User().firstName,
                      enabled: !User().isProcessing,
                      decoration: new InputDecoration(
                          labelStyle: CustomTextStyles.bodyBlack,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: contentPadding),
                          errorMaxLines: 3),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return AppLocalizations.of(context)!
                              .firstNameValidation;
                        }
                        return null;
                      },
                      onSaved: (String? firstName) {
                        _tmpFirstName = firstName;
                      },
                    ),
                  ),
                  context);
            }),
            _buildRow(
                context,
                AppLocalizations.of(context)!.placeholderFamilyName,
                User().name, () {
              _showDialog(() {
                if (_lastNameFormKey.currentState!.validate()) {
                  _lastNameFormKey.currentState!.save();
                  if (User().name != _tmpLastName!) {
                    User().saveUserData("name", _tmpLastName!, context);
                  }
                  Navigator.of(context).pop();
                }
              },
                  AppLocalizations.of(context)!.editData(
                      AppLocalizations.of(context)!.placeholderFamilyName),
                  User().name,
                  Form(
                    key: _lastNameFormKey,
                    onChanged: () => setState(
                      () => _lastNameEntered =
                          _lastNameFormKey.currentState!.validate(),
                    ),
                    child: TextFormField(
                      textAlign: TextAlign.start,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      obscureText: false,
                      style: CustomTextStyles.bodyGrey,
                      autocorrect: false,
                      autofocus: true,
                      initialValue: User().name,
                      enabled: !User().isProcessing,
                      decoration: new InputDecoration(
                          labelStyle: CustomTextStyles.bodyBlack,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: contentPadding),
                          errorMaxLines: 3),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return AppLocalizations.of(context)!
                              .lastNameValidation;
                        }
                        return null;
                      },
                      onSaved: (String? lastName) {
                        _tmpLastName = lastName;
                      },
                    ),
                  ),
                  context);
            }),
            _buildRow(context, AppLocalizations.of(context)!.placeholderAddress,
                User().address, () {
              _showDialog(() {
                if (_addressFormKey.currentState!.validate()) {
                  _addressFormKey.currentState!.save();
                  if (User().address != _tmpAddress!) {
                    User().saveUserData("address", _tmpAddress!, context);
                  }
                  Navigator.of(context).pop();
                }
              },
                  AppLocalizations.of(context)!.editData(
                      AppLocalizations.of(context)!.placeholderAddress),
                  User().address,
                  Form(
                    key: _addressFormKey,
                    onChanged: () => setState(
                      () => _addressEntered =
                          _addressFormKey.currentState!.validate(),
                    ),
                    child: TextFormField(
                      textAlign: TextAlign.start,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      obscureText: false,
                      autofocus: true,
                      style: CustomTextStyles.bodyGrey,
                      autocorrect: false,
                      initialValue: User().address,
                      enabled: !User().isProcessing,
                      decoration: new InputDecoration(
                          labelStyle: CustomTextStyles.bodyBlack,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: contentPadding),
                          errorMaxLines: 3),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return AppLocalizations.of(context)!
                              .addressValidation;
                        }
                        return null;
                      },
                      onSaved: (String? address) {
                        _tmpAddress = address;
                      },
                    ),
                  ),
                  context);
            }),
            _buildRow(
                context,
                AppLocalizations.of(context)!.placeholderPhoneNumber,
                User().phoneNumber, () {
              _showDialog(() {
                if (_phoneFormKey.currentState!.validate()) {
                  _phoneFormKey.currentState!.save();
                  if (User().phoneNumber != _tmpPhone!) {
                    User().saveUserData("phone_number", _tmpPhone!, context);
                  }
                  Navigator.of(context).pop();
                }
              },
                  AppLocalizations.of(context)!.editData(
                      AppLocalizations.of(context)!.placeholderPhoneNumber),
                  User().phoneNumber,
                  Form(
                    key: _phoneFormKey,
                    onChanged: () => setState(
                      () => _phoneNumberEntered =
                          _phoneFormKey.currentState!.validate(),
                    ),
                    child: TextFormField(
                      textAlign: TextAlign.start,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      obscureText: false,
                      style: CustomTextStyles.bodyGrey,
                      autocorrect: false,
                      autofocus: true,
                      initialValue: User().phoneNumber,
                      enabled: !User().isProcessing,
                      decoration: new InputDecoration(
                          labelStyle: CustomTextStyles.bodyBlack,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: contentPadding),
                          errorMaxLines: 3),
                      validator: (value) {
                        if (value!.isEmpty || !validatePhoneNumber(value)) {
                          return AppLocalizations.of(context)!
                              .phoneNumberValidation;
                        }
                        return null;
                      },
                      onSaved: (String? phone) {
                        if (phone != "+49") {
                          _tmpPhone = phone;
                        }
                      },
                    ),
                  ),
                  context);
            }),
          ],
        )));
  }

  Future<void> _showDialog(Function() onSaveClicked, String title, String value,
      Form form, BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: CustomTextStyles.title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                form,
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text(
                AppLocalizations.of(context)!.save,
                style: CustomTextStyles.bodyWhite,
              ),
              onPressed: () {
                onSaveClicked.call();
              },
            ),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  AppLocalizations.of(context)!.cancel,
                  style: CustomTextStyles.bodyBlack,
                ))
          ],
        );
      },
    );
  }

  bool validatePhoneNumber(String value) {
    if (value.length == 0 || !_regExpPhoneNumber.hasMatch(value)) {
      return false;
    }
    return true;
  }

  Widget _buildRow(
      BuildContext context, String label, String value, Function() onEdit) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: CustomTextStyles.bodyBlackBold,
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(
                    Icons.edit,
                    size: 20,
                    color: CustomColors.mint,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(15, 0, 20, 5),
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: CustomTextStyles.bodyBlack,
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Divider(
            height: 10,
            thickness: 1,
          ),
        ],
      ),
    );
  }
}
