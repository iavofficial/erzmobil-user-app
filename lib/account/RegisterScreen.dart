import 'package:erzmobil/Constants.dart';
import 'package:erzmobil/debug/Logger.dart';
import 'package:erzmobil/model/RequestState.dart';
import 'package:erzmobil/model/User.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameFormKey = GlobalKey<FormState>();
  final _lastNameFormKey = GlobalKey<FormState>();
  final _emailFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _passwordControlFormKey = GlobalKey<FormState>();
  final _phoneFormKey = GlobalKey<FormState>();
  final _addressFormKey = GlobalKey<FormState>();
  bool _firstNameEntered = false;
  bool _lastNameEntered = false;
  bool _addressEntered = false;
  bool _phoneNumberEntered = false;
  bool _emailEntered = false;
  bool _pwdEntered = false;
  bool _pwdControlEntered = false;

  String? _tmpEmail;
  String? _tmpPwd;
  String? _tmpFirstName;
  String? _tmpLastName;
  String? _tmpPhone;
  String? _tmpAddress;

  final RegExp _regExpUpperCase = RegExp(r'[A-Z]');
  final RegExp _regExpLowerCase = RegExp(r'[a-z]');
  final RegExp _regExpNumbers = RegExp(r'\d');
  final RegExp _regExpSpecial = RegExp(r'[\W_]');
  final RegExp _regExpPhoneNumber = RegExp(r'(^([+][0-9]{10,14})$)');

  TextEditingController controller = TextEditingController();

  String initialCountry = 'DE';
  PhoneNumber number = PhoneNumber(isoCode: 'DE');

  bool tosAccepted = false;
  bool showCheckboxError = false;
  bool obscurePwd = true;
  bool obscureControlPwd = true;
  bool isPhoneNumberValid = true;

  @override
  void initState() {
    super.initState();
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
        foregroundColor: CustomColors.white,
        title: Text(AppLocalizations.of(context)!.signupTitle),
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
            Form(
              key: _firstNameFormKey,
              onChanged: () => setState(
                () => _firstNameEntered =
                    _firstNameFormKey.currentState!.validate(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 5),
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      obscureText: false,
                      style: CustomTextStyles.bodyGrey,
                      autocorrect: false,
                      enabled: !User().isProcessing,
                      decoration: new InputDecoration(
                          labelText: AppLocalizations.of(context)!
                              .placeholderGivenName,
                          labelStyle: CustomTextStyles.bodyBlack,
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
                  Container(
                    margin: EdgeInsets.fromLTRB(20.0, 0, 20.0, 10),
                    child: Text(
                      AppLocalizations.of(context)!.usageHintFirstName,
                      style: CustomTextStyles.bodyGreySmall,
                    ),
                  )
                ],
              ),
            ),
            Form(
              key: _lastNameFormKey,
              onChanged: () => setState(
                () => _lastNameEntered =
                    _lastNameFormKey.currentState!.validate(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 5.0),
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      obscureText: false,
                      style: CustomTextStyles.bodyGrey,
                      autocorrect: false,
                      enabled: !User().isProcessing,
                      decoration: new InputDecoration(
                        labelText:
                            AppLocalizations.of(context)!.placeholderFamilyName,
                        labelStyle: CustomTextStyles.bodyBlack,
                        errorMaxLines: 3,
                      ),
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
                  Container(
                    margin: EdgeInsets.fromLTRB(20.0, 0, 20.0, 10),
                    child: Text(
                      AppLocalizations.of(context)!.usageHintLastName,
                      style: CustomTextStyles.bodyGreySmall,
                    ),
                  )
                ],
              ),
            ),
            Form(
              key: _phoneFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 5.0),
                    child: InternationalPhoneNumberInput(
                      onInputChanged: (PhoneNumber number) {
                        Logger.debug("onInputChanged" + number.phoneNumber!);
                      },
                      onInputValidated: (bool value) {
                        if (defaultTargetPlatform != TargetPlatform.android &&
                            defaultTargetPlatform != TargetPlatform.iOS) {
                          // validator does not work in WebApp!
                          value = true;
                        }
                        setState(() {
                          isPhoneNumberValid = value;
                          _phoneNumberEntered = isPhoneNumberValid;
                        });
                      },
                      errorMessage: null,
                      selectorConfig: SelectorConfig(
                        selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                      ),
                      ignoreBlank: false,
                      autoValidateMode: AutovalidateMode.onUserInteraction,
                      hintText:
                          AppLocalizations.of(context)!.placeholderPhoneNumber,
                      selectorTextStyle: TextStyle(color: Colors.black),
                      initialValue: number,
                      formatInput: false,
                      keyboardType: TextInputType.numberWithOptions(
                          signed: true, decimal: true),
                      inputBorder: OutlineInputBorder(),
                      onSaved: (PhoneNumber number) {
                        print('On Saved: $number.phoneNumber');
                        List<String> numbers =
                            number.phoneNumber!.split(number.dialCode!);
                        if (numbers.isNotEmpty) {
                          final RegExp regExpNum = RegExp(r'^0+(?!$)');
                          String phoneNumber =
                              numbers[1].replaceAll(regExpNum, "");
                          _tmpPhone = "${number.dialCode}" + "$phoneNumber";
                          print('Phone: $_tmpPhone');
                        }
                      },
                    ),
                  ),
                  Offstage(
                    offstage: isPhoneNumberValid,
                    child: Container(
                      margin: EdgeInsets.fromLTRB(20.0, 0, 20.0, 10),
                      child: Text(
                        AppLocalizations.of(context)!.phoneNumberValidation,
                        style: CustomTextStyles.bodyRedVerySmall,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(20.0, 0, 20.0, 10),
                    child: Text(
                      AppLocalizations.of(context)!.usageHintPhone,
                      style: CustomTextStyles.bodyGreySmall,
                    ),
                  )
                ],
              ),
            ),
            Form(
              key: _addressFormKey,
              onChanged: () => setState(
                () =>
                    _addressEntered = _addressFormKey.currentState!.validate(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 5.0),
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      obscureText: false,
                      style: CustomTextStyles.bodyGrey,
                      autocorrect: false,
                      enabled: !User().isProcessing,
                      decoration: new InputDecoration(
                          labelText:
                              AppLocalizations.of(context)!.placeholderAddress,
                          labelStyle: CustomTextStyles.bodyBlack,
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
                  Container(
                    margin: EdgeInsets.fromLTRB(20.0, 0, 20.0, 10),
                    child: Text(
                      AppLocalizations.of(context)!.usageHintAddress,
                      style: CustomTextStyles.bodyGreySmall,
                    ),
                  )
                ],
              ),
            ),
            Form(
              key: _emailFormKey,
              onChanged: () => setState(
                () => _emailEntered = _emailFormKey.currentState!.validate(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 5.0),
                    child: TextFormField(
                      style: CustomTextStyles.bodyGrey,
                      keyboardType: TextInputType.emailAddress,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      autocorrect: false,
                      enabled: !User().isProcessing,
                      decoration: new InputDecoration(
                          labelText:
                              AppLocalizations.of(context)!.placeholderEmail,
                          labelStyle: CustomTextStyles.bodyBlack,
                          errorMaxLines: 2),
                      validator: (value) {
                        if (value!.isEmpty ||
                            !Expressions.regExpName.hasMatch(value)) {
                          return AppLocalizations.of(context)!.eMailValidation;
                        }
                        return null;
                      },
                      onSaved: (String? email) {
                        _tmpEmail = email;
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(20.0, 0, 20.0, 10),
                    child: Text(
                      AppLocalizations.of(context)!.usageHintMail,
                      style: CustomTextStyles.bodyGreySmall,
                    ),
                  )
                ],
              ),
            ),
            Form(
              key: _passwordFormKey,
              onChanged: () => setState(() =>
                  _pwdEntered = _passwordFormKey.currentState!.validate()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      obscureText: obscurePwd,
                      style: CustomTextStyles.bodyGrey,
                      autocorrect: false,
                      enabled: !User().isProcessing,
                      controller: controller,
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
                          labelStyle: CustomTextStyles.bodyBlack,
                          errorMaxLines: 4),
                      validator: (value) {
                        if (value!.isEmpty ||
                            value.length < 8 ||
                            !_regExpLowerCase.hasMatch(value) ||
                            !_regExpUpperCase.hasMatch(value) ||
                            !_regExpNumbers.hasMatch(value) ||
                            !_regExpSpecial.hasMatch(value)) {
                          return AppLocalizations.of(context)!.passwordHint;
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
            Form(
              key: _passwordControlFormKey,
              onChanged: () => setState(() => _pwdControlEntered =
                  _passwordControlFormKey.currentState!.validate()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      obscureText: obscureControlPwd,
                      style: CustomTextStyles.bodyGrey,
                      autocorrect: false,
                      enabled: !User().isProcessing,
                      decoration: new InputDecoration(
                          suffixIcon: IconButton(
                              icon: Icon(
                                obscureControlPwd
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: CustomColors.black,
                                size: 18,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscureControlPwd = !obscureControlPwd;
                                });
                              }),
                          labelText: AppLocalizations.of(context)!
                              .placeholderPasswordRepetition,
                          labelStyle: CustomTextStyles.bodyBlack,
                          errorMaxLines: 4),
                      validator: (value) {
                        if (value != controller.text) {
                          return AppLocalizations.of(context)!
                              .passwordControlHint;
                        } else if (value!.isEmpty ||
                            value.length < 8 ||
                            !_regExpLowerCase.hasMatch(value) ||
                            !_regExpUpperCase.hasMatch(value) ||
                            !_regExpNumbers.hasMatch(value) ||
                            !_regExpSpecial.hasMatch(value)) {
                          return AppLocalizations.of(context)!.passwordHint;
                        }
                        return null;
                      },
                    ),
                  )
                ],
              ),
            ),
            getToSContainer(),
            Container(
              margin: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              child: TextButton(
                style: CustomButtonStyles.flatButtonStyle,
                child: User().isProgressRegister
                    ? new CircularProgressIndicator()
                    : Text(
                        AppLocalizations.of(context)!.signup,
                        style: CustomTextStyles.bodyWhite,
                      ),
                onPressed: _emailEntered &&
                        _pwdEntered &&
                        _pwdControlEntered &&
                        _firstNameEntered &&
                        _lastNameEntered &&
                        _addressEntered &&
                        _phoneNumberEntered &&
                        tosAccepted &&
                        !User().isProcessing
                    ? () {
                        _emailFormKey.currentState!.save();
                        _passwordFormKey.currentState!.save();
                        _firstNameFormKey.currentState!.save();
                        _lastNameFormKey.currentState!.save();
                        _phoneFormKey.currentState!.save();
                        _addressFormKey.currentState!.save();

                        _register(context);
                      }
                    : _validateAllFields,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _validateAllFields() {
    Logger.debug("validating user input");

    _emailFormKey.currentState!.save();
    _passwordFormKey.currentState!.validate();
    _passwordControlFormKey.currentState!.validate();
    _firstNameFormKey.currentState!.validate();
    _lastNameFormKey.currentState!.validate();
    _phoneFormKey.currentState!.validate();
    _addressFormKey.currentState!.validate();
    _emailFormKey.currentState!.validate();
    if (!tosAccepted) {
      setState(() {
        showCheckboxError = true;
      });
    }
  }

  Widget getToSContainer() {
    return Flexible(
      child: Row(
        children: [
          Theme(
            child: Checkbox(
              value: tosAccepted,
              onChanged: (bool? value) {
                setState(() {
                  tosAccepted = value!;
                  if (!tosAccepted) {
                    showCheckboxError = true;
                  } else {}
                });
              },
            ),
            data: ThemeData(
              primarySwatch: CustomColors.mint,
              unselectedWidgetColor:
                  showCheckboxError ? Colors.red : CustomColors.mint,
            ),
          ),
          Flexible(
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.fromLTRB(5.0, 15.0, 25.0, 30.0),
              child: RichText(
                maxLines: 10,
                textAlign: TextAlign.start,
                text: TextSpan(
                  style: CustomTextStyles.bodyBlack,
                  children: <TextSpan>[
                    TextSpan(text: AppLocalizations.of(context)!.acceptTOS),
                    TextSpan(
                      style: CustomTextStyles.bodyMintBold,
                      text: AppLocalizations.of(context)!.termsOfTransportation,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          _openTermsOfTransportation();
                        },
                    ),
                    TextSpan(text: AppLocalizations.of(context)!.acceptTOS2),
                    TextSpan(
                      style: CustomTextStyles.bodyMintBold,
                      text: AppLocalizations.of(context)!.specialStipulations,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          _openLocalTermsAndConditions();
                        },
                    ),
                    TextSpan(text: AppLocalizations.of(context)!.acceptTOS3),
                    TextSpan(
                      style: CustomTextStyles.bodyMintBold,
                      text: AppLocalizations.of(context)!.dataPrivacy,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          _openPrivacyPolicy();
                        },
                    ),
                    TextSpan(text: AppLocalizations.of(context)!.acceptTOS4),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openPrivacyPolicy() async {
    if (await canLaunch(Strings.DATAPRIVACY_URL)) {
      await launch(Strings.DATAPRIVACY_URL);
    } else {
      Logger.info('Could not launch $Strings.DATAPRIVACY_URL');
    }
  }

  Future<void> _openLocalTermsAndConditions() async {
    if (await canLaunch(Strings.ABOUT_ERZMOBIL_URL)) {
      await launch(Strings.ABOUT_ERZMOBIL_URL);
    } else {
      Logger.info(
          'Could not launch local terms and conditions $Strings.ABOUT_ERZMOBIL_URL');
    }
  }

  Future<void> _openTermsOfTransportation() async {
    if (await canLaunch(Strings.TERMS_OF_TRANSPORTATION)) {
      await launch(Strings.TERMS_OF_TRANSPORTATION);
    } else {
      Logger.info('Could not launch $Strings.TERMS_OF_TRANSPORTATION');
    }
  }

  void _register(BuildContext context) async {
    RequestState state = await User().register(_tmpEmail, _tmpPwd,
        _tmpFirstName, _tmpLastName, _tmpAddress, _tmpPhone, context);
    if (state == RequestState.SUCCESS) {
      _showDialog(
          AppLocalizations.of(context)!.dialogInfoTitle,
          AppLocalizations.of(context)!.dialogRegisterAccountText,
          context,
          true);
    } else if (state == RequestState.ERROR_USER_EXISTS) {
      _showDialog(
          AppLocalizations.of(context)!.dialogErrorTitle,
          AppLocalizations.of(context)!.dialogUserExistsErrorText,
          context,
          false);
    } else {
      _showDialog(AppLocalizations.of(context)!.dialogErrorTitle,
          AppLocalizations.of(context)!.dialogGenericErrorText, context, false);
    }
  }

  Future<void> _showDialog(String title, String message, BuildContext context,
      bool popToFirst) async {
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
              onPressed: () {
                popToFirst
                    ? Navigator.of(context).popUntil((route) => route.isFirst)
                    : Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: CustomTextStyles.bodyMint,
              ),
            ),
          ],
        );
      },
    );
  }
}
