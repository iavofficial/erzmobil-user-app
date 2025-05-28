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
import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:erzmobil/Amazon.dart';
import 'package:erzmobil/Constants.dart';
import 'package:erzmobil/debug/Logger.dart';
import 'package:erzmobil/model/BusPosition.dart';
import 'package:erzmobil/model/BusStop.dart';
import 'package:erzmobil/model/BusStopList.dart';
import 'package:erzmobil/model/CognitoData.dart';
import 'package:erzmobil/model/DirectusToken.dart';
import 'package:erzmobil/model/Journey.dart';
import 'package:erzmobil/model/JourneyList.dart';
import 'package:erzmobil/model/PreferenceHolder.dart';
import 'package:erzmobil/model/ProgressState.dart';
import 'package:erzmobil/model/RequestState.dart';
import 'package:erzmobil/model/RouteRequestResult.dart';
import 'package:erzmobil/model/TicketType.dart';
import 'package:erzmobil/model/database/DatabaseProvider.dart';
import 'package:erzmobil/push/PushNotificationService.dart';
import 'package:erzmobil/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

///
/// This is the main class for the backend communication.
///
class User extends ChangeNotifier {
  static final User _instance = new User._internal();

  static const int TIMEOUT_DURATION = 60;
  static const int TIMEOUT_DURATION_SHORT = 30;

  bool isProcessing = false;
  bool isDebugProcessing = false;
  ProgressState _currentProgressState = ProgressState.NONE;

  bool _isCognitoInitialized = false;
  CognitoData? _cognitoData;

  int? id;
  String? _name;
  String? email;
  String? _address;
  String? _phoneNumber;
  String? _firstName;
  String? tmpAcceptedRegisterVersions;
  bool _isActive = true;
  List<int>? favoriteStops;
  List<Journey>? favoriteJourneys;
  String? userId;

  bool canBook = true;

  JourneyList? journeyList;
  BusStopList? stopList;
  Map<int, bool>? favoritesMapping;
  Journey? lastBookedJourney;

  List<TicketType>? ticketTypes;

  bool useDirectus = false;
  DirectusToken? directusToken;
  DateTime? directusTokenExpirationDate;

  String get firstName => _firstName != null ? _firstName! : Utils.NO_DATA;
  String get phoneNumber =>
      _phoneNumber != null ? _phoneNumber! : Utils.NO_DATA;
  String get name => _name != null ? _name! : Utils.NO_DATA;
  String get address => _address != null ? _address! : Utils.NO_DATA;

  SharedPreferences? _sharedPreferences = PreferenceHolder().getPreferences();
  DatabaseProvider _databaseProvider = DatabaseProvider();
  CognitoUser? _cognitoUser;
  CognitoUserSession? _cognitoUserSession;

  /// This is LetsEncrypt's self-signed trusted root certificate authority
  /// certificate, issued under common name: ISRG Root X1 (Internet Security
  /// Research Group).  Used in handshakes to negotiate a Transport Layer Security
  /// connection between endpoints.  This certificate is missing from older devices
  /// that don't get OS updates such as Android 7 and older.  But, we can supply
  /// this certificate manually to our HttpClient via SecurityContext so it can be
  /// used when connecting to URLs protected by LetsEncrypt SSL certificates.
  /// PEM format LE self-signed cert from here: https://letsencrypt.org/certificates/
  static const String ISRG_X1 = """-----BEGIN CERTIFICATE-----
MIIFazCCA1OgAwIBAgIRAIIQz7DSQONZRGPgu2OCiwAwDQYJKoZIhvcNAQELBQAw
TzELMAkGA1UEBhMCVVMxKTAnBgNVBAoTIEludGVybmV0IFNlY3VyaXR5IFJlc2Vh
cmNoIEdyb3VwMRUwEwYDVQQDEwxJU1JHIFJvb3QgWDEwHhcNMTUwNjA0MTEwNDM4
WhcNMzUwNjA0MTEwNDM4WjBPMQswCQYDVQQGEwJVUzEpMCcGA1UEChMgSW50ZXJu
ZXQgU2VjdXJpdHkgUmVzZWFyY2ggR3JvdXAxFTATBgNVBAMTDElTUkcgUm9vdCBY
MTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAK3oJHP0FDfzm54rVygc
h77ct984kIxuPOZXoHj3dcKi/vVqbvYATyjb3miGbESTtrFj/RQSa78f0uoxmyF+
0TM8ukj13Xnfs7j/EvEhmkvBioZxaUpmZmyPfjxwv60pIgbz5MDmgK7iS4+3mX6U
A5/TR5d8mUgjU+g4rk8Kb4Mu0UlXjIB0ttov0DiNewNwIRt18jA8+o+u3dpjq+sW
T8KOEUt+zwvo/7V3LvSye0rgTBIlDHCNAymg4VMk7BPZ7hm/ELNKjD+Jo2FR3qyH
B5T0Y3HsLuJvW5iB4YlcNHlsdu87kGJ55tukmi8mxdAQ4Q7e2RCOFvu396j3x+UC
B5iPNgiV5+I3lg02dZ77DnKxHZu8A/lJBdiB3QW0KtZB6awBdpUKD9jf1b0SHzUv
KBds0pjBqAlkd25HN7rOrFleaJ1/ctaJxQZBKT5ZPt0m9STJEadao0xAH0ahmbWn
OlFuhjuefXKnEgV4We0+UXgVCwOPjdAvBbI+e0ocS3MFEvzG6uBQE3xDk3SzynTn
jh8BCNAw1FtxNrQHusEwMFxIt4I7mKZ9YIqioymCzLq9gwQbooMDQaHWBfEbwrbw
qHyGO0aoSCqI3Haadr8faqU9GY/rOPNk3sgrDQoo//fb4hVC1CLQJ13hef4Y53CI
rU7m2Ys6xt0nUW7/vGT1M0NPAgMBAAGjQjBAMA4GA1UdDwEB/wQEAwIBBjAPBgNV
HRMBAf8EBTADAQH/MB0GA1UdDgQWBBR5tFnme7bl5AFzgAiIyBpY9umbbjANBgkq
hkiG9w0BAQsFAAOCAgEAVR9YqbyyqFDQDLHYGmkgJykIrGF1XIpu+ILlaS/V9lZL
ubhzEFnTIZd+50xx+7LSYK05qAvqFyFWhfFQDlnrzuBZ6brJFe+GnY+EgPbk6ZGQ
3BebYhtF8GaV0nxvwuo77x/Py9auJ/GpsMiu/X1+mvoiBOv/2X/qkSsisRcOj/KK
NFtY2PwByVS5uCbMiogziUwthDyC3+6WVwW6LLv3xLfHTjuCvjHIInNzktHCgKQ5
ORAzI4JMPJ+GslWYHb4phowim57iaztXOoJwTdwJx4nLCgdNbOhdjsnvzqvHu7Ur
TkXWStAmzOVyyghqpZXjFaH3pO3JLF+l+/+sKAIuvtd7u+Nxe5AW0wdeRlN8NwdC
jNPElpzVmbUq4JUagEiuTDkHzsxHpFKVK7q4+63SM1N95R1NbdWhscdCb+ZAJzVc
oyi3B43njTOQ5yOf+1CceWxG1bQVs5ZufpsMljq4Ui0/1lvh+wjChP4kqKOJ2qxq
4RgqsahDYVvTH9w7jXbyLeiNdd8XM2w9U/t7y0Ff/9yi0GE44Za4rF2LN9d11TPA
mRGunUHBcnWEvgJBQl9nJEiU0Zsnvgc/ubhPgXRR4Xq37Z0j4r7g1SgEEzwxA57d
emyPxgcYxn/eR44/KJ4EBs+lVDR3veyJm+kXQ99b21/+jh5Xos1AnX5iItreGCc=
-----END CERTIFICATE-----""";

  factory User() {
    return _instance;
  }

  User._internal();

  /*Future<void> deleteLogs() async {
    _setDebugProcessing(true);
    await FLog.clearLogs();
    _setDebugProcessing(false);
  }

  Future<void> sendLogs() async {
    _setDebugProcessing(true);

    File? logFile;
    try {
      logFile = await FLog.exportLogs();
    } catch (e) {
      print(e);
    }

    if (logFile != null && logFile.existsSync()) {
      //zip file
      Directory? externalDirectory;
      File? zipFile;
      try {
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          externalDirectory = await getApplicationDocumentsDirectory();
        } else {
          externalDirectory = await getExternalStorageDirectory();
        }

        if (externalDirectory != null) {
          zipFile = File("${externalDirectory.path}/logs.zip");
          await ZipFile.createFromFiles(
              sourceDir: logFile.parent, files: [logFile], zipFile: zipFile);
        }
      } catch (e) {
        print(e);
      }

      if (zipFile != null && zipFile.existsSync()) {
        //obtain device data
        StringBuffer buffer = StringBuffer();
        buffer.write(
            'Bitte teilen Sie uns mit, warum Sie uns dieses Log schicken.\nPlease tell us why you are sending the log file.\n\n');
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
          buffer.write('systemVersion: ${iosInfo.systemVersion} \n');
          buffer.write('model: ${iosInfo.model} \n');
          buffer.write('name: ${iosInfo.name} \n');
        } else {
          AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
          buffer.write('version.baseOS: ${androidInfo.version.baseOS} \n');
          buffer.write('manufacturer: ${androidInfo.manufacturer} \n');
          buffer.write('model: ${androidInfo.model} \n');
        }

        //sendZip
        final Email email = Email(
          body: buffer.toString(),
          subject: 'Erzmobil User App Logs',
          recipients: ['erzmobil@smartcity-zwoenitz.de'],
          attachmentPaths: [zipFile.path],
          isHTML: false,
        );

        try {
          await FlutterEmailSender.send(email);
        } catch (e) {
          print(e);
        }
        //TODO: handle no Email client found?
        zipFile.deleteSync();
      }
      logFile.deleteSync();
    }

    _setDebugProcessing(false);
  }*/

  static const sslUrl = 'https://valid-isrgrootx1.letsencrypt.org/';

  /// From dart:io, create a HttpClient with a trusted certificate [cert]
  /// added to SecurityContext.
  /// Wrapped in try catch in case the certificate is already trusted by
  /// device/os, which will cause an exception to be thrown.
  HttpClient customHttpClient({required String cert}) {
    SecurityContext context = SecurityContext.defaultContext;
    try {
      // ignore: unnecessary_null_comparison
      if (cert != null) {
        List<int> bytes = utf8.encode(cert);
        context.setTrustedCertificatesBytes(bytes);
      }
      print('createHttpClient() - cert added!');
    } on TlsException catch (e) {
      if (e.osError?.message != null &&
          e.osError!.message.contains('CERT_ALREADY_IN_HASH_TABLE')) {
        print('createHttpClient() - cert already trusted! Skipping.');
      } else {
        print('createHttpClient().setTrustedCertificateBytes EXCEPTION: $e');
        rethrow;
      }
    } finally {}
    HttpClient httpClient = new HttpClient(context: context);
    return httpClient;
  }

  /// Use package:http Client with our custom dart:io HttpClient with added
  /// LetsEncrypt trusted certificate
  http.Client createLEClient() {
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      IOClient ioClient;
      ioClient = IOClient(customHttpClient(cert: ISRG_X1));
      return ioClient;
    } else {
      return http.Client();
    }
  }

  Future<void> loadCognitoData() async {
    _setProcessing(true, ProgressState.REQUEST_COGNITO_DATA);

    if (useDirectus) {
      Logger.info("load Cognito data from backend");
      http.Response response;
      try {
        response = await http
            .get(Uri.parse(Amazon.baseUrl + Strings.COGNITO_DATA_URL_DIRECTUS),
                headers: new Map<String, String>.from(
                    {'Content-Type': 'application/json'}))
            .timeout(Duration(seconds: User.TIMEOUT_DURATION));

        Logger.info(response.request.toString());
        Logger.info("RESPONSE: " + response.statusCode.toString());
        if (response.statusCode == 200) {
          final parsed = jsonDecode(response.body);
          _cognitoData = CognitoData.fromJson(parsed);
          if (_cognitoData != null && _cognitoData!.isValid()) {
            Logger.info("Cognito data was loaded successfully");

            Amazon.initUserPool(
                _cognitoData!.userPoolId!, _cognitoData!.userClientId!);
            _isCognitoInitialized = true;
          }
        }
      } on SocketException {
        Logger.info("ERROR_FAILED_NO_INTERNET");
      } catch (e) {
        Logger.error(e, StackTrace.current);
        Logger.info("Couldn't get load cognito data");
      }
    } else {
      Logger.info("Using default cognito data");
      Amazon.initUserPool(Amazon.userPoolId, Amazon.clientId);
      _isCognitoInitialized = true;
    }

    _setProcessing(false, ProgressState.NONE);
  }

  Future<RequestState> login(String? pwd, BuildContext context) async {
    RequestState retVal = RequestState.ERROR_FAILED;
    if (_isCognitoInitialized && email != null && pwd != null) {
      _setProcessing(true, ProgressState.LOGIN);
      _cognitoUser = new CognitoUser(email, Amazon.userPool,
          storage: Amazon.userPool.storage);
      try {
        _cognitoUserSession = await _cognitoUser!.authenticateUser(
            AuthenticationDetails(username: email, password: pwd));
        await _cognitoUser!.cacheTokens();
        _setPwdVerificationMode(false);
        _isActive = true;
        if (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS) {
          User? user = await _databaseProvider.getUser(email!);
          if (user == null) {
            id = await _databaseProvider.insert(this);
          }
        } else {
          id = 0;
        }

        await loadUserData();

        Logger.info("stored user with $id");
        retVal = RequestState.SUCCESS;
      } on CognitoUserNewPasswordRequiredException catch (e) {
        Logger.error(e, StackTrace.current);
        // handle New Password challenge
      } on CognitoUserMfaRequiredException catch (e) {
        Logger.error(e, StackTrace.current);
        // handle SMS_MFA challenge
      } on CognitoUserSelectMfaTypeException catch (e) {
        Logger.error(e, StackTrace.current);
        // handle SELECT_MFA_TYPE challenge
      } on CognitoUserMfaSetupException catch (e) {
        Logger.error(e, StackTrace.current);
        // handle MFA_SETUP challenge
      } on CognitoUserTotpRequiredException catch (e) {
        Logger.error(e, StackTrace.current);
        // handle SOFTWARE_TOKEN_MFA challenge
      } on CognitoUserCustomChallengeException catch (e) {
        Logger.error(e, StackTrace.current);
        // handle CUSTOM_CHALLENGE challenge
      } on CognitoUserConfirmationNecessaryException catch (e) {
        Logger.error(e, StackTrace.current);
        retVal = RequestState.ERROR_CONFIRMATION_NECESSARY;
      } on CognitoClientException catch (e) {
        Logger.error(e, StackTrace.current);
        bool isWebPlatform = defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS;
        final bool isConnected = isWebPlatform
            ? true
            : await InternetConnectionChecker().hasConnection;
        if (!isConnected) {
          Logger.info("ERROR_FAILED_NO_INTERNET");
          retVal = RequestState.ERROR_FAILED_NO_INTERNET;
        }
        if (e.code == 'NotAuthorizedException') {
          retVal = RequestState.ERROR_WRONG_CREDENTIALS;
        }
        if (e.code == 'UserNotConfirmedException') {
          retVal = RequestState.ERROR_CONFIRMATION_NECESSARY;
        }
        if (e.code == 'UserNotFoundException') {
          Logger.error(e, StackTrace.current);
          retVal = RequestState.ERROR_USER_UNKNOWN;
        }
      } catch (e) {
        Logger.error(e, StackTrace.current);
      }
      await loadPublicDataFromBE();
      _setProcessing(false, ProgressState.NONE);
    }

    return retVal;
  }

  bool hasActiveJourney() {
    return journeyList != null && journeyList!.hasActiveJourneys;
  }

  Future<RequestState> loadUserData() async {
    RequestState retVal = RequestState.ERROR_FAILED;
    _setProcessing(true, ProgressState.UPDATE_DATA);

    List<CognitoUserAttribute>? attributes;
    try {
      attributes = await _cognitoUser!.getUserAttributes();
      attributes!.forEach((attribute) {
        switch (attribute.getName()) {
          case "given_name":
            _firstName = attribute.getValue();
            break;
          case "name":
            _name = attribute.getValue();
            break;
          case "address":
            _address = attribute.getValue();
            break;
          case "phone_number":
            _phoneNumber = attribute.getValue();
            break;
        }
      });
      if (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS) {
        await _databaseProvider.update(this);
      }
    } catch (e) {
      Logger.error(e, StackTrace.current);
      _setProcessing(false, ProgressState.NONE);
      Logger.info("Error loading user data");
    }

    _setProcessing(false, ProgressState.NONE);

    return retVal;
  }

  Future<RequestState> saveUserData(
      String attribute, String value, BuildContext context) async {
    RequestState retVal = RequestState.ERROR_FAILED;
    _setProcessing(true, ProgressState.UPDATE_DATA);

    await _refreshSessionIfNeeded();
    final List<CognitoUserAttribute> attributes = [];
    attributes.add(CognitoUserAttribute(name: attribute, value: value));

    final bool isConnected = await checkInternetConnection(context);
    if (isConnected) {
      try {
        Logger.info("Update user attributes");
        await _cognitoUser!.updateAttributes(attributes);
        await loadUserData();
        retVal = RequestState.SUCCESS;
      } on CognitoClientException catch (e) {
        _setProcessing(false, ProgressState.NONE);
        await _showDialog(AppLocalizations.of(context)!.dialogErrorTitle,
            AppLocalizations.of(context)!.dialogMessageNoInternet, context);
        _setProcessing(false, ProgressState.NONE);
      } catch (e) {
        _setProcessing(false, ProgressState.NONE);
        Logger.info("Error saving user data");

        final bool isConnected = await checkInternetConnection(context);
        if (isConnected) {
          Logger.info(e.toString());

          await _showDialog(AppLocalizations.of(context)!.dialogErrorTitle,
              AppLocalizations.of(context)!.dialogGenericErrorText, context);
        }
      }
    }

    _setProcessing(false, ProgressState.NONE);

    return retVal;
  }

  Future<bool> checkInternetConnection(BuildContext context) async {
    bool isWebPlatform = defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS;
    final bool isConnected =
        isWebPlatform ? true : await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      await _showDialog(AppLocalizations.of(context)!.dialogErrorTitle,
          AppLocalizations.of(context)!.dialogMessageNoInternet, context);
    }

    return isConnected;
  }

  Future<void>? showFCMErrorIfnecessary(
      BuildContext context, RequestState resultState) {
    if (resultState != RequestState.SUCCESS) {
      if (resultState == RequestState.ERROR_FAILED_NO_INTERNET) {
        Logger.info("ERROR_FAILED_NO_INTERNET");
        _showDialog(
            AppLocalizations.of(context)!.dialogErrorTitle,
            AppLocalizations.of(context)!.dialogPushNoInternetErrorText,
            context);
      } else if (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS) {
        return _showDialog(AppLocalizations.of(context)!.dialogErrorTitle,
            AppLocalizations.of(context)!.dialogPushBackendErrorText, context);
      }
    }
    return null;
  }

  Future<void> _showDialog(String title, String message, BuildContext context) {
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

  List<TicketType> getTicketTypes() {
    if (ticketTypes == null || ticketTypes!.isEmpty) {
      Logger.info("Using default ticket type");

      ticketTypes = [];
      if (useDirectus) {
        ticketTypes!.add(TicketType(Strings.DEFAULT_TICKET_TYPE));
      } else {
        List<String> oldJourneyTypes = [
          'keines',
          'Einzelfahrt',
          '4-Fahrten-Karte',
          'Tageskarte (1-5 Personen)',
          '10er-Tageskarte (ab 01.08.2022)',
          'Wochenkarte (bis 31.07.2022)',
          'Monatskarte',
          'Abo-Monatskarte',
          '9-Uhr-Abo-Monatskarte',
          'JungeLeuteTicket',
          'SeniorenTicket',
          'BildungsTicket',
          'SchülerVerbundKarte (bis 31.07.2022)',
          'AzubiTicket Sachsen',
          'JobTicket',
          'SemesterTicket',
          'Sachsen-Ticket',
          'Schwerbehindertenausweis',
          'Sonstiges'
        ];

        oldJourneyTypes.forEach((type) {
          ticketTypes!.add(TicketType(type));
        });
      }
    }

    return ticketTypes!;
  }

  Future<RequestState> loadTicketTypes() async {
    _setProcessing(true, ProgressState.UPDATE_TICKETTYPES);
    RequestState retVal = RequestState.ERROR_FAILED;

    http.Client _client = createLEClient();
    http.Response response;

    try {
      response = await _client
          .get(Uri.parse(Amazon.baseUrl + Strings.TICKET_TYPES_URL),
              headers: new Map<String, String>.from({
                'Accept': 'application/json',
                'Access-Control-Allow-Origin': '*'
              }))
          .timeout(Duration(seconds: User.TIMEOUT_DURATION));
      Logger.info("RESPONSE: " + response.statusCode.toString());

      if (response.statusCode == 200) {
        final parsed =
            jsonDecode(response.body)["data"].cast<Map<String, dynamic>>();

        ticketTypes = parsed
            .map<TicketType>((json) => TicketType.fromJson(json))
            .toList();
      }
    } on SocketException {
      retVal = RequestState.ERROR_FAILED_NO_INTERNET;
      Logger.info("ERROR_FAILED_NO_INTERNET");
    } catch (e) {
      Logger.error(e, StackTrace.current);
    }

    _setProcessing(false, ProgressState.NONE);
    return retVal;
  }

  Future<RequestState> loadUserBookingStatus() async {
    _setProcessing(true, ProgressState.UPDATE_STOPS);
    RequestState retVal = RequestState.ERROR_FAILED;

    if (!isLoggedIn()) {
      return retVal;
    }

    http.Client _client = createLEClient();
    http.Response response;
    String? authorizationToken = useDirectus
        ? directusToken!.accessToken
        : _cognitoUserSession!.getAccessToken().getJwtToken();

    try {
      response = await _client
          .get(Uri.parse(Amazon.baseUrl + Strings.USER_CAN_BOOK_URL_DIRECTUS),
              headers: new Map<String, String>.from({
                'Accept': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Authorization': 'Bearer $authorizationToken'
              }))
          .timeout(Duration(seconds: User.TIMEOUT_DURATION));
      Logger.info("RESPONSE: " + response.statusCode.toString());

      if (response.statusCode == 200) {
        canBook = parseBool(response.body);
        Logger.info("User can book: $canBook");
      }
    } on SocketException {
      retVal = RequestState.ERROR_FAILED_NO_INTERNET;
      Logger.info("ERROR_FAILED_NO_INTERNET");
    } catch (e) {
      Logger.error(e, StackTrace.current);
    }

    _setProcessing(false, ProgressState.NONE);
    return retVal;
  }

  bool parseBool(String value) {
    if (value.toLowerCase() == 'true') {
      return true;
    } else if (value.toLowerCase() == 'false') {
      return false;
    }

    Logger.info("$value can not be parsed to boolean.");
    return false;
  }

  Future<bool> saveFavoriteJourney(Journey newFavJourney) async {
    bool success = true;
    if (favoriteJourneys == null) {
      favoriteJourneys = [];
    }
    favoriteJourneys!.add(newFavJourney);
    try {
      if (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS) {
        await _databaseProvider.update(this);
        notifyListeners();
        Logger.info("saved favorite journeys");
      }
    } catch (e) {
      success = false;
      Logger.error(e, StackTrace.current);
    }

    return success;
  }

  Future<bool> deleteFavoriteJourney(Journey favToDelete) async {
    bool success = true;
    if (favoriteJourneys == null) {
      favoriteJourneys = [];
    }
    if (favoriteJourneys!.contains(favToDelete)) {
      favoriteJourneys!.remove(favToDelete);

      try {
        await _databaseProvider.update(this);
        notifyListeners();
        Logger.info("succesfully removed favorite journey");
      } catch (e) {
        Logger.error(e, StackTrace.current);
      }
    }
    return success;
  }

  Future<void> saveFavorites(Map<int, bool> favoritesMapping) async {
    favoriteStops = [];
    this.favoritesMapping = favoritesMapping;
    favoritesMapping.entries.forEach((element) {
      if (element.value) {
        favoriteStops!.add(element.key);
      }
    });
    try {
      await _databaseProvider.update(this);
      Logger.info("saved favorites");
      notifyListeners();
    } catch (e) {
      Logger.error(e, StackTrace.current);
    }
  }

  List<BusStop> getFavoriteStops() {
    List<BusStop> busStops = [];
    if (favoriteStops != null && favoriteStops!.isNotEmpty) {
      favoriteStops!.forEach((stopId) {
        BusStop? stop = getStopFromId(stopId);
        if (stop != null) {
          busStops.add(stop);
        }
      });
    }

    return busStops;
  }

  BusStop? getStopFromId(int id) {
    if (stopList != null && stopList!.data.isNotEmpty) {
      for (int i = 0; i < stopList!.data.length; i++) {
        BusStop stop = stopList!.data.cast<BusStop>()[i];
        if (stop.id == id) {
          return stop;
        }
      }
    }
    return null;
  }

  Future<RequestState> deleteUser() async {
    RequestState retVal = RequestState.ERROR_FAILED;
    _setProcessing(true, ProgressState.DELETE);
    bool userDeleted = false;
    await _refreshSessionIfNeeded();
    try {
      userDeleted = await _cognitoUser!.deleteUser();
      if (userDeleted) {
        await deleteFirebaseToken(
            await PushNotificationService().getFCMToken());
        await _cognitoUser!.clearCachedTokens();
        if (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS) {
          await _databaseProvider.delete(this);
        }
        _reset();
        retVal = RequestState.SUCCESS;
      }
    } on SocketException catch (e) {
      retVal = RequestState.ERROR_FAILED_NO_INTERNET;
      Logger.info("ERROR_FAILED_NO_INTERNET");
      Logger.error(e, StackTrace.current);
    } catch (e) {
      bool isWebPlatform = defaultTargetPlatform != TargetPlatform.android &&
          defaultTargetPlatform != TargetPlatform.iOS;
      final bool isConnected = isWebPlatform
          ? true
          : await InternetConnectionChecker().hasConnection;
      if (!isConnected) {
        retVal = RequestState.ERROR_FAILED_NO_INTERNET;
        Logger.info("ERROR_FAILED_NO_INTERNET");
      }
    }
    _setProcessing(false, ProgressState.NONE);
    return retVal;
  }

  Future<RequestState> startForgotPwd(String? email) async {
    RequestState retVal = RequestState.ERROR_FAILED;
    if (_isCognitoInitialized) {
      _setProcessing(true, ProgressState.RESET);
      CognitoUser user = CognitoUser(email, Amazon.userPool);
      try {
        await user.forgotPassword();
        _setPwdVerificationMode(true);
        retVal = RequestState.SUCCESS;
      } on CognitoClientException catch (e) {
        Logger.error(e, StackTrace.current);
        bool isWebPlatform = defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS;
        final bool isConnected = isWebPlatform
            ? true
            : await InternetConnectionChecker().hasConnection;
        if (!isConnected) {
          retVal = RequestState.ERROR_FAILED_NO_INTERNET;
          Logger.info("ERROR_FAILED_NO_INTERNET");
        } else if (e.code == 'ResourceNotFoundException') {
          retVal = RequestState.ERROR_USER_UNKNOWN;
        }
      } catch (e) {
        Logger.error(e, StackTrace.current);
      }
      _setProcessing(false, ProgressState.NONE);
    }
    return retVal;
  }

  Future<RequestState> completeForgotPwd(
      String? email, String? code, String? pwd) async {
    RequestState retVal = RequestState.ERROR_FAILED;
    if (_isCognitoInitialized) {
      _setProcessing(true, ProgressState.RESET);
      CognitoUser user = CognitoUser(email, Amazon.userPool);
      try {
        if (await user.confirmPassword(code!, pwd!)) {
          _setPwdVerificationMode(false);
          retVal = RequestState.SUCCESS;
        }
      } on CognitoClientException catch (e) {
        Logger.error(e, StackTrace.current);
        //this exception will be thrown if user is unknown or code is expired
        if (e.code == 'ExpiredCodeException') {
          retVal = RequestState.ERROR_EXPIRED_CODE;
        }
        if (e.code == 'CodeMismatchException') {
          retVal = RequestState.ERROR_WRONG_CODE;
        }
      } catch (e) {
        Logger.error(e, StackTrace.current);
      }
      _setProcessing(false, ProgressState.NONE);
    }
    return retVal;
  }

  Future<RequestState> resendConfirmationCode(String? email) async {
    RequestState retVal = RequestState.ERROR_FAILED;
    _setProcessing(true, ProgressState.CONFIRM);
    if (_isCognitoInitialized) {
      CognitoUser user = CognitoUser(email, Amazon.userPool);
      try {
        await user.resendConfirmationCode();
        retVal = RequestState.SUCCESS;
      } on CognitoClientException catch (e) {
        Logger.error(e, StackTrace.current);
      } catch (e) {
        Logger.error(e, StackTrace.current);
      }
      _setProcessing(false, ProgressState.NONE);
    }
    return retVal;
  }

  Future<RequestState> register(
      String? mailAddress,
      String? pwd,
      String? firstName,
      String? lastName,
      String? address,
      String? phoneNumber,
      BuildContext context) async {
    RequestState retVal = RequestState.ERROR_FAILED;
    _setProcessing(true, ProgressState.REGISTER);

    final List<AttributeArg> userAttributes = [
      new AttributeArg(name: 'given_name', value: firstName),
      new AttributeArg(name: 'name', value: lastName),
      new AttributeArg(name: 'address', value: address),
      new AttributeArg(name: 'email', value: mailAddress),
      new AttributeArg(name: 'phone_number', value: phoneNumber)
    ];
    if (_isCognitoInitialized) {
      try {
        CognitoUserPoolData data = await Amazon.userPool
            .signUp(mailAddress!, pwd!, userAttributes: userAttributes);
        if (data != null) {
          _cognitoUser = data.user;
          /*try {
          //cleanup already registered user which are not logged in
          await _databaseProvider.delete(this);
        } catch (e) {}*/
          this._name = lastName;
          this._firstName = firstName;
          this._phoneNumber = phoneNumber;
          this.email = mailAddress;
          this._address = address;

          if (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS) {
            id = await _databaseProvider.insert(this);
          } else {
            id = 0;
          }

          retVal = RequestState.SUCCESS;
        }
      } on CognitoClientException catch (e) {
        if (e.code == 'UsernameExistsException') {
          retVal = RequestState.ERROR_USER_EXISTS;
        }
        Logger.error(e, StackTrace.current);
      } catch (e) {
        Logger.error(e, StackTrace.current);
      }
      _setProcessing(false, ProgressState.NONE);
    }
    return retVal;
  }

  Future<RequestState> logout() async {
    RequestState retVal = RequestState.ERROR_FAILED;
    _setProcessing(true, ProgressState.LOGOUT);
    await _refreshSessionIfNeeded();
    try {
      await deleteFirebaseToken(await PushNotificationService().getFCMToken());

      await _cognitoUser!.globalSignOut();
      await _cognitoUser!.clearCachedTokens();
      retVal = RequestState.SUCCESS;
    } catch (e) {
      Logger.error(e, StackTrace.current);
    }
    _isActive = false;
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      await _databaseProvider.update(this);
    }
    _reset();

    _setProcessing(false, ProgressState.NONE);
    return retVal;
  }

  /// Handles session refresh. Used due to problematic secure storage handling. Otherwise user.getSession() would be enough.
  Future<void> _refreshSessionIfNeeded() async {
    if (useDirectus &&
        directusToken != null &&
        directusToken!.expires != null &&
        directusTokenExpirationDate != null) {
      DateTime now = DateTime.now();

      if (now.isAfter(directusTokenExpirationDate!.toLocal())) {
        Logger.info("Directus token expired, refresh session");
        await loadDirectusToken();
      }
    }
    if (!_cognitoUserSession!.isValid()) {
      try {
        Logger.info("Cognito session expired, refresh session");
        _cognitoUserSession = await _cognitoUser!.refreshSession(
            CognitoRefreshToken(
                _cognitoUserSession!.getRefreshToken()!.getToken()));
      } catch (e) {
        Logger.error(e, StackTrace.current);
      }
    }
  }

  bool isLoggedIn() {
    return id != null && _cognitoUser != null && _cognitoUserSession != null;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      DatabaseProvider.columnMail: email,
    };

    if (_name != null) {
      map[DatabaseProvider.columnName] = _name;
    }

    if (firstName != null) {
      map[DatabaseProvider.columnFirstName] = firstName;
    }

    if (_address != null) {
      map[DatabaseProvider.columnAddress] = _address;
    }

    if (_phoneNumber != null) {
      map[DatabaseProvider.columnPhone] = _phoneNumber;
    }

    if (id != null) {
      map[DatabaseProvider.columnId] = id;
    }

    if (tmpAcceptedRegisterVersions != null) {
      map[DatabaseProvider.columnRegisteredVersions] =
          tmpAcceptedRegisterVersions;
    }

    if (favoriteStops != null) {
      String encodedFavorites = json.encode({"favorites": favoriteStops});
      Logger.info("store favorites $encodedFavorites");
      map[DatabaseProvider.columnFavorites] = encodedFavorites;
    }

    if (favoriteJourneys != null) {
      String jsonJourneys =
          jsonEncode(favoriteJourneys!.map((i) => i.toJson()).toList())
              .toString();
      String encodedFavoriteJourneys =
          json.encode({"favoriteJourneys": jsonJourneys});
      Logger.info("store favorite journeys $encodedFavoriteJourneys");
      map[DatabaseProvider.columnFavoriteJourneys] = encodedFavoriteJourneys;
    }

    if (lastBookedJourney != null) {
      String encodedLastBookedJourney =
          json.encode({"lastBookedJourney": lastBookedJourney});
      Logger.info("store encodedLastBookedJourney: $encodedLastBookedJourney");
      map[DatabaseProvider.columnLastBooked] = encodedLastBookedJourney;
    }

    map[DatabaseProvider.columnIsActive] = _isActive ? 1 : 0;

    return map;
  }

  User.fromMap(map) {
    User().id = map[DatabaseProvider.columnId];
    User()._name = map[DatabaseProvider.columnName];
    User()._firstName = map[DatabaseProvider.columnFirstName];
    User().email = map[DatabaseProvider.columnMail];
    User()._address = map[DatabaseProvider.columnAddress];
    User()._phoneNumber = map[DatabaseProvider.columnPhone];
    User().tmpAcceptedRegisterVersions =
        map[DatabaseProvider.columnRegisteredVersions];
    String? rawFavorites = map[DatabaseProvider.columnFavorites];
    Logger.info("loaded user with favorites $rawFavorites");
    if (rawFavorites != null) {
      Map<String, dynamic> data = json.decode(rawFavorites);
      var items = data["favorites"] as List;
      User().favoriteStops = items.cast<int>();
    }

    String? rawFavoriteJourneys = map[DatabaseProvider.columnFavoriteJourneys];
    Logger.info("loaded user with favorite journeys $rawFavoriteJourneys");
    if (rawFavoriteJourneys != null) {
      Map<String, dynamic> data = json.decode(rawFavoriteJourneys);
      var items = data["favoriteJourneys"];
      final parsed = useDirectus
          ? jsonDecode(items).cast<Map<String, dynamic>>()
          : jsonDecode(items).cast<Map<String, dynamic>>();

      User().favoriteJourneys = parsed
          .map<Journey>((json) => useDirectus
              ? Journey.fromJsonDirectus(json)
              : Journey.fromJson(json))
          .toList();
    }

    String? rawLastBooked = map[DatabaseProvider.columnLastBooked];
    if (rawLastBooked != null) {
      Map<String, dynamic> data =
          json.decode(rawLastBooked)["lastBookedJourney"];

      Journey result =
          useDirectus ? Journey.fromJsonDirectus(data) : Journey.fromJson(data);
      User().lastBookedJourney = result;
      Logger.info("loaded last booked journey: ");
      if (User().lastBookedJourney != null) User().lastBookedJourney!.logJson();
    }
  }

  /// Restores cached session from store (refresh if session is not valid any more).
  Future<void> restoreSessionFromStore() async {
    Logger.info("restoreSession");
    //we have a user in our database
    if (_isCognitoInitialized && email != null) {
      _cognitoUser = await Amazon.userPool.getCurrentUser();
      if (_cognitoUser != null) {
        try {
          _cognitoUserSession = await _cognitoUser!.getSession();
          await loadUserData();
        } catch (e) {
          //we have no valid session and refresh is not possible
          _cognitoUser = null;
          Logger.error(e, StackTrace.current);
        }
      } else if (tmpAcceptedRegisterVersions == null) {
        //clear user data if we have not registered otherwise keep data without session --> login possible
        try {
          await _databaseProvider.delete(this);
        } catch (e) {}
        _reset();
      }
    }
  }

  //no return type needed
  Future<void> loadPublicDataFromBE() async {
    await loadStopList();
    if (!isLoggedIn()) {
      return null;
    }
    if (useDirectus) {
      await loadDirectusToken();
      await loadUserBookingStatus();
      await loadTicketTypes();
      await loadUserId();
    }
    await loadCurrentBusPositions();
    await loadJourneys();
    _setProcessing(false, ProgressState.NONE);
  }

  Future<void> checkBackendConnection() async {
    _setProcessing(true, ProgressState.CHECK_DIRECTUS_CONNECTION);
    http.Client _client = createLEClient();
    http.Response response;

    try {
      response = await _client
          .get(Uri.parse(Amazon.baseUrl + Strings.NEW_BACKEND_AVAILABILITY),
              headers: new Map<String, String>.from({
                'Accept': 'application/json',
                'Access-Control-Allow-Origin': '*'
              }))
          .timeout(Duration(seconds: User.TIMEOUT_DURATION));
      Logger.info("RESPONSE: " + response.statusCode.toString());
      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body)["data"];
        if (parsed['isActive'] != null) {
          final bool isDirectusAvailable = parsed['isActive'] as bool;
          useDirectus = isDirectusAvailable;
        }
      }
    } on SocketException {
      Logger.info("ERROR_FAILED_NO_INTERNET");
    } on TimeoutException catch (e) {
      Logger.info("Timeout for NewBackendAvailability");
      _setProcessing(false, ProgressState.NONE);
    } catch (e) {
      Logger.error(e, StackTrace.current);
    }

    if (useDirectus) {
      Logger.info("App is using the new directus backend.");
    } else {
      Logger.info("App is using old backend connection.");
    }

    _setProcessing(false, ProgressState.NONE);
  }

  Future<void> loadUserId() async {
    if (!useDirectus) {
      return;
    }
    _setProcessing(true, ProgressState.LOAD_USER_ID);
    http.Client _client = createLEClient();
    http.Response response;

    String? authorizationToken = directusToken!.accessToken;

    try {
      response = await _client
          .get(Uri.parse(Amazon.baseUrl + Strings.USERID_URL_DIRECTUS),
              headers: new Map<String, String>.from({
                'Accept': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Authorization': 'Bearer $authorizationToken'
              }))
          .timeout(Duration(seconds: User.TIMEOUT_DURATION));
      Logger.info("RESPONSE: " + response.statusCode.toString());
      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body)["data"];
        if (parsed['id'] != null) {
          userId = parsed['id'];
        }
      }
    } on SocketException {
      Logger.info("ERROR_FAILED_NO_INTERNET");
    } on TimeoutException catch (e) {
      Logger.info("Timeout for loading user id");
      _setProcessing(false, ProgressState.NONE);
    } catch (e) {
      Logger.error(e, StackTrace.current);
    }

    _setProcessing(false, ProgressState.NONE);
  }

  Future<void> loadDirectusToken() async {
    _setProcessing(true, ProgressState.REQUEST_DIRECTUS_TOKEN);
    http.Response response;
    http.Client _client = createLEClient();

    String? idToken = _cognitoUserSession!.getIdToken().getJwtToken();
    String? refreshToken = _cognitoUserSession!.getRefreshToken()!.getToken();

    Logger.info('Cognito IdToken: $idToken');
    Logger.info('Cognito RefreshToken: $refreshToken');

    try {
      response = await _client
          .post(Uri.parse(Amazon.baseUrl + '/awsmw/auth'),
              headers: new Map<String, String>.from(
                  {'Content-Type': 'application/json'}),
              body: json.encode(
                  {"IdToken": '$idToken', "RefreshToken": '$refreshToken'}))
          .timeout(Duration(seconds: User.TIMEOUT_DURATION));

      Logger.info(response.request.toString());
      Logger.info("RESPONSE: " + response.statusCode.toString());
      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        directusToken = DirectusToken.fromJson(parsed);
        if (directusToken != null && directusToken!.expires != null) {
          directusTokenExpirationDate = directusToken!.expires!;
          Logger.info("Directus token: ${directusToken!.accessToken}");
          Logger.info("Token expires " +
              directusTokenExpirationDate!.toLocal().toIso8601String());
        } else {
          Logger.info("Couldn't get directus token");
        }
      }
    } on SocketException {
      Logger.info("ERROR_FAILED_NO_INTERNET");
    } catch (e) {
      Logger.error(e, StackTrace.current);
      Logger.info("Couldn't get directus token");
    }

    _setProcessing(false, ProgressState.NONE);
  }

  Future<RequestState> loadStopList() async {
    _setProcessing(true, ProgressState.UPDATE_STOPS);
    RequestState retVal = RequestState.ERROR_FAILED;

    http.Client _client = createLEClient();
    http.Response response;

    try {
      response = await _client
          .get(
              Uri.parse(Amazon.baseUrl +
                  (useDirectus
                      ? Strings.STOPS_URL_DIRECTUS
                      : Strings.STOPS_URL_BACKEND)),
              headers: new Map<String, String>.from({
                'Accept': 'application/json',
                'Access-Control-Allow-Origin': '*'
              }))
          .timeout(Duration(seconds: User.TIMEOUT_DURATION));

      BusStopList newStopList = stopList = BusStopList(response);
      if (newStopList.isSuccessful()) {
        retVal = RequestState.SUCCESS;
        stopList = newStopList;
      }
    } on SocketException {
      retVal = RequestState.ERROR_FAILED_NO_INTERNET;
      Logger.info("ERROR_FAILED_NO_INTERNET");
      if (stopList == null) {
        stopList = BusStopList(null);
        stopList!.markNotLoaded();
      }
    } catch (e) {
      Logger.error(e, StackTrace.current);
      if (stopList == null) {
        stopList = BusStopList(null);
        stopList!.markNotLoaded();
      }
    }

    if (stopList!.isSuccessful()) {
      try {
        stopList!.data.sort((a, b) =>
            a.name!.toLowerCase().compareTo(b.name!.toLowerCase().toString()));
      } catch (e) {
        Logger.e("Cannot sort bus stops");
      }
    }

    _setProcessing(false, ProgressState.NONE);
    return retVal;
  }

  Future<RequestState> loadJourneys() async {
    if (!isLoggedIn()) {
      return RequestState.ERROR_NOT_LOGGED_IN;
    }
    RequestState retVal = RequestState.ERROR_FAILED;

    _setProcessing(true, ProgressState.UPDATE_JOURNEYS);
    await _refreshSessionIfNeeded();
    if (useDirectus && directusToken == null) {
      if (journeyList == null) {
        journeyList = JourneyList(null);
      }
      journeyList!.markInvalid();
      _setProcessing(false, ProgressState.NONE);
      return retVal;
    }

    http.Client _client = createLEClient();
    http.Response response;
    String? authorizationToken = useDirectus
        ? directusToken!.accessToken
        : _cognitoUserSession!.getAccessToken().getJwtToken();

    try {
      response = await _client
          .get(
              Uri.parse(Amazon.baseUrl +
                  (useDirectus
                      ? Strings.ORDERS_URL_DIRECTUS
                      : Strings.ORDERS_URL_BACKEND)),
              headers: new Map<String, String>.from({
                'Accept': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Authorization': 'Bearer $authorizationToken'
              }))
          .timeout(Duration(seconds: TIMEOUT_DURATION));
      Logger.info("Bearer $authorizationToken");

      JourneyList newJourneyList = JourneyList(response);
      if (newJourneyList.isSuccessful()) {
        retVal = RequestState.SUCCESS;
        journeyList = newJourneyList;
      }
    } on SocketException catch (e) {
      if (journeyList == null) {
        journeyList = JourneyList(null);
      }
      journeyList!.markNotLoaded();
      Logger.error(e, StackTrace.current);
      retVal = RequestState.ERROR_FAILED_NO_INTERNET;
      Logger.info("ERROR_FAILED_NO_INTERNET");
    } catch (e) {
      if (journeyList == null) {
        journeyList = JourneyList(null);
      }
      journeyList!.markInvalid();
      Logger.error(e, StackTrace.current);
    }
    _setProcessing(false, ProgressState.NONE);
    return retVal;
  }

  Journey? getJourney(int orderId) {
    if (journeyList != null && journeyList!.bookedJourneys != null) {
      for (Journey journey in journeyList!.bookedJourneys!) {
        if (journey.id == orderId) {
          return journey;
        }
      }
    }
    return null;
  }

  List<Journey>? getBookedJourneys() {
    if (journeyList != null && journeyList!.bookedJourneys != null) {
      return journeyList!.bookedJourneys;
    }
    return List.empty();
  }

  Future<RequestState> deleteOrder(int id) async {
    RequestState retVal = RequestState.ERROR_FAILED;
    _setProcessing(true, ProgressState.DELETE_JOURNEY);
    http.Client _client = createLEClient();
    http.Response response;

    await _refreshSessionIfNeeded();
    if (useDirectus && directusToken == null) {
      _setProcessing(false, ProgressState.NONE);
      return retVal;
    }

    String? authorizationToken = useDirectus
        ? directusToken!.accessToken
        : _cognitoUserSession!.getAccessToken().getJwtToken();

    try {
      if (useDirectus) {
        DateTime now = DateTime.now();
        String isoTimeNow = Utils().getFormatISOTime(now);
        response = await _client
            .patch(
                Uri.parse(Amazon.baseUrl +
                    Strings.ORDERS_DELETE_URL_DIRECTUS +
                    '/$id'),
                headers: new Map<String, String>.from({
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $authorizationToken'
                }),
                body: json.encode({
                  "cancelled_on": '$isoTimeNow',
                  "cancellation_reason": 'cancelled by User',
                  "status": 'Cancelled'
                }))
            .timeout(Duration(seconds: TIMEOUT_DURATION));
        Logger.info(response.request.toString());
        Logger.info("RESPONSE: " + response.statusCode.toString());
      } else {
        response = await _client
            .delete(
                Uri.parse(Amazon.baseUrl +
                    (useDirectus
                        ? Strings.ORDERS_DELETE_URL_DIRECTUS
                        : Strings.ORDERS_URL_BACKEND) +
                    '/$id'),
                headers: new Map<String, String>.from({
                  'Accept': 'application/json',
                  'Access-Control-Allow-Origin': '*',
                  'Authorization': 'Bearer $authorizationToken'
                }))
            .timeout(Duration(seconds: TIMEOUT_DURATION));
        Logger.info(response.request.toString());
        Logger.info("RESPONSE: " + response.statusCode.toString());
      }
      if (response.statusCode == 204 || response.statusCode == 200) {
        retVal = RequestState.SUCCESS;
        loadJourneys();
      }
    } on SocketException catch (e) {
      Logger.error(e, StackTrace.current);
      retVal = RequestState.ERROR_FAILED_NO_INTERNET;
      Logger.info("ERROR_FAILED_NO_INTERNET");
    } on TimeoutException catch (e) {
      retVal = RequestState.ERROR_TIMEOUT;
      Logger.error(e, StackTrace.current);
      _setProcessing(false, ProgressState.NONE);
    } catch (e) {
      Logger.error(e, StackTrace.current);
      _setProcessing(false, ProgressState.NONE);
    }

    _setProcessing(false, ProgressState.NONE);

    return retVal;
  }

  Future<List<BusPosition>?> loadCurrentBusPositions() async {
    if (!isLoggedIn()) {
      return null;
    }

    await _refreshSessionIfNeeded();
    if (useDirectus && directusToken == null) {
      _setProcessing(false, ProgressState.NONE);
      return null;
    }

    String? authorizationToken = useDirectus
        ? directusToken!.accessToken
        : _cognitoUserSession!.getAccessToken().getJwtToken();

    List<BusPosition>? busPositions;

    try {
      http.Client _client = createLEClient();
      http.Response response = await _client
          .get(
              Uri.parse(Amazon.baseUrl +
                  (useDirectus
                      ? Strings.BUS_POSITIONS_URL_DIRECTUS
                      : Strings.BUS_POSITIONS_URL_BACKEND)),
              headers: new Map<String, String>.from({
                'Accept': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Authorization': 'Bearer $authorizationToken'
              }))
          .timeout(Duration(seconds: TIMEOUT_DURATION));
      Logger.info(response.request.toString());
      Logger.info("RESPONSE: " + response.body.toString());
      if (response.statusCode == 200) {
        final parsed = useDirectus
            ? jsonDecode(response.body)["data"].cast<Map<String, dynamic>>()
            : jsonDecode(response.body).cast<Map<String, dynamic>>();

        busPositions = parsed
            .map<BusPosition>((json) => useDirectus
                ? BusPosition.fromJsonDirectus(json)
                : BusPosition.fromJson(json))
            .toList();
        return busPositions;
      }
    } catch (e) {
      Logger.error(e, StackTrace.current);
    }
    return null;
  }

  List<BusStop>? getSortedBusStops() {
    List<BusStop>? sorted = [];
    List<BusStop>? fav = [];
    List<BusStop>? other = [];
    favoritesMapping = {};

    if (stopList!.isSuccessful() && stopList!.data != null) {
      stopList!.data.forEach((element) {
        favoritesMapping![element.id] = false;
      });
    }

    //map stored favorites to existing stops
    if (favoriteStops != null) {
      favoriteStops!.forEach((element) {
        try {
          favoritesMapping!.update(element, (value) => !value);
        } catch (e) {}
      });
    }

    if (stopList!.data != null) {
      stopList!.data.forEach((element) {
        if (favoritesMapping![element.id] == true) {
          fav.add(element);
        } else {
          other.add(element);
        }
      });
    }

    try {
      fav.sort((a, b) =>
          a.name!.toLowerCase().compareTo(b.name!.toLowerCase().toString()));
      other.sort((a, b) =>
          a.name!.toLowerCase().compareTo(b.name!.toLowerCase().toString()));
    } catch (e) {
      Logger.e("Cannot sort stops / favorite stops");
    }

    sorted.addAll(fav);
    sorted.addAll(other);

    return sorted;
  }

  BusStop? getBusStopFromId(int id) {
    if (stopList!.data != null) {
      for (BusStop stop in stopList!.data) {
        if (stop.id == id) {
          return stop;
        }
      }
    }
    return null;
  }

  BusStop? getBusStopFromAddress(Address? address) {
    if (stopList!.data != null && address != null) {
      for (BusStop stop in stopList!.data) {
        if (stop.position!.latitude == address.location!.lat &&
            stop.position!.longitude == address.location!.lng) {
          return stop;
        }
      }
    }
    return null;
  }

  Map<int, bool> getFavoritesMapping() {
    return (this.favoritesMapping == null) ? {} : favoritesMapping!;
  }

  Future<RequestState> registerToken() async {
    RequestState retVal = RequestState.ERROR_FAILED;

    _setProcessing(true, ProgressState.REGISTER_TOKEN);
    String? token = await PushNotificationService().getFCMToken();
    await _refreshSessionIfNeeded();
    if (useDirectus && directusToken == null) {
      _setProcessing(false, ProgressState.NONE);
      return retVal;
    }
    String? authorizationToken = useDirectus
        ? directusToken!.accessToken
        : _cognitoUserSession!.getAccessToken().getJwtToken();

    if (token != null) {
      try {
        http.Client _client = createLEClient();
        http.Response response = await _client
            .post(
                Uri.parse(Amazon.baseUrl +
                    (useDirectus
                        ? Strings.TOKENS_URL_DIRECTUS
                        : Strings.TOKENS_URL_BACKEND)),
                headers: new Map<String, String>.from({
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $authorizationToken'
                }),
                body: json.encode({"fcmToken": token}))
            .timeout(Duration(seconds: TIMEOUT_DURATION));
        Logger.info("Body:" + json.encode({"fcmToken": token}));
        Logger.info(response.request.toString());
        Logger.info("RESPONSE: " + response.statusCode.toString());
        if (response.statusCode == 201 ||
            response.statusCode == 204 ||
            response.statusCode == 200) {
          Logger.info("Firebase token successfully registered");
          retVal = RequestState.SUCCESS;
        }
      } on SocketException catch (e) {
        Logger.error(e, StackTrace.current);
        retVal = RequestState.ERROR_FAILED_NO_INTERNET;
        Logger.info("ERROR_FAILED_NO_INTERNET");
      } on TimeoutException catch (e) {
        Logger.error(e, StackTrace.current);
        retVal = RequestState.ERROR_TIMEOUT;
      } catch (e) {
        Logger.error(e, StackTrace.current);
      }
    }

    _setProcessing(false, ProgressState.NONE);

    return retVal;
  }

  Future<RequestState> deleteFirebaseToken(String? token) async {
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      RequestState retVal = RequestState.ERROR_FAILED;
      _setProcessing(true, ProgressState.DELETE_TOKEN);
      http.Client _client = createLEClient();
      http.Response response;

      await _refreshSessionIfNeeded();
      if (useDirectus && directusToken == null) {
        _setProcessing(false, ProgressState.NONE);
        return retVal;
      }

      String? authorizationToken = useDirectus
          ? directusToken!.accessToken
          : _cognitoUserSession!.getAccessToken().getJwtToken();

      try {
        response = await _client
            .delete(
                Uri.parse(Amazon.baseUrl +
                    (useDirectus
                        ? Strings.TOKENS_URL_DIRECTUS
                        : Strings.TOKENS_URL_BACKEND) +
                    '/$token'),
                headers: new Map<String, String>.from({
                  'Accept': 'application/json',
                  'Access-Control-Allow-Origin': '*',
                  'Authorization': 'Bearer $authorizationToken'
                }))
            .timeout(Duration(seconds: TIMEOUT_DURATION));
        Logger.info(response.request.toString());
        Logger.info("RESPONSE: " + response.statusCode.toString());
        if (response.statusCode == 204) {
          retVal = RequestState.SUCCESS;
          Logger.info("Firebase token successfully deleted");
        }
      } on TimeoutException catch (e) {
        retVal = RequestState.ERROR_TIMEOUT;
        Logger.error(e, StackTrace.current);
        _setProcessing(false, ProgressState.NONE);
      } catch (e) {
        Logger.error(e, StackTrace.current);
        _setProcessing(false, ProgressState.NONE);
      }

      _setProcessing(false, ProgressState.NONE);

      return retVal;
    } else
      return RequestState.SUCCESS;
  }

  Future<Tuple2<RequestState, Journey>> requestOrder(Journey journey) async {
    RequestState retVal = RequestState.ERROR_FAILED;

    String? authorizationToken = useDirectus
        ? directusToken!.accessToken
        : _cognitoUserSession!.getAccessToken().getJwtToken();

    try {
      http.Client _client = createLEClient();
      http.Response response = await _client
          .post(
              Uri.parse(Amazon.baseUrl +
                  (useDirectus
                      ? Strings.ORDERS_URL_DIRECTUS
                      : Strings.ORDERS_URL_BACKEND)),
              headers: new Map<String, String>.from({
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $authorizationToken'
              }),
              body: json.encode(
                  useDirectus ? journey.toJsonDirectus() : journey.toJson()))
          .timeout(Duration(seconds: TIMEOUT_DURATION));
      Logger.info("Body:" + json.encode(journey.toJson()));
      Logger.info(response.request.toString());
      Logger.info("RESPONSE: " + response.body.toString());
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        final parsed = useDirectus
            ? jsonDecode(response.body)["data"]
            : jsonDecode(response.body);
        Journey resultJourney = useDirectus
            ? Journey.fromJsonDirectus(parsed)
            : Journey.fromJson(parsed);
        journey = resultJourney;
        Logger.info("Journey booked: ");
        journey.logJson();

        await loadJourneys();
        retVal = RequestState.SUCCESS;
      }
    } on SocketException catch (e) {
      Logger.error(e, StackTrace.current);
      retVal = RequestState.ERROR_FAILED_NO_INTERNET;
      Logger.info("ERROR_FAILED_NO_INTERNET");
    } on TimeoutException catch (e) {
      Logger.error(e, StackTrace.current);
      retVal = RequestState.ERROR_TIMEOUT;
    } catch (e) {
      Logger.error(e, StackTrace.current);
    }

    return Tuple2<RequestState, Journey>(retVal, journey);
  }

  Future<Tuple3<int, Journey, List<DateTime>?>> requestRoute(
      int flexibleOption, Journey journey, BuildContext context) async {
    if (!isLoggedIn()) {
      return Tuple3<int, Journey, List<DateTime>?>(-1, journey, null);
    }
    int resultCode = -1;
    List<DateTime>? times = [];
    _setProcessing(true, ProgressState.BOOK_ROUTE);

    await _refreshSessionIfNeeded();

    try {
      http.Client _client = createLEClient();
      http.Response response = await _client
          .get(Uri.parse(getRequestRouteUrl(journey, flexibleOption)),
              headers: new Map<String, String>.from({
                'Accept': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Authorization':
                    'Bearer ${_cognitoUserSession!.getAccessToken().getJwtToken()}'
              }))
          .timeout(Duration(seconds: TIMEOUT_DURATION));
      Logger.info(
          'Authorization: Bearer ${_cognitoUserSession!.getAccessToken().getJwtToken()}');
      Logger.info(response.request.toString());
      Logger.info("RESPONSE: " + response.body.toString());
      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        RouteRequestResult requestResult = RouteRequestResult.fromJson(parsed);

        /*List<DateTime> resultingTimes = [
          DateTime.parse("2022-07-22T10:50:52.725Z"),
          DateTime.parse("2022-07-22T12:18:52.725Z")
        ];
        RouteRequestResult requestResult = RouteRequestResult(
            true, 10, "No routes found", resultingTimes, null);*/

        if (requestResult.result) {
          if (requestResult.reasonCode == 0) {
            // requested time is available and journey can be booked
            Tuple2<RequestState, Journey> result = await requestOrder(journey)
                .timeout(Duration(seconds: TIMEOUT_DURATION));

            RequestState requestState = result.item1;
            if (requestState == RequestState.ERROR_FAILED) {
              resultCode = -1;
            } else if (requestState == RequestState.ERROR_TIMEOUT) {
              resultCode = 504;
            } else if (requestState == RequestState.ERROR_FAILED_NO_INTERNET) {
              resultCode = 999;
            } else {
              resultCode = 0;
              lastBookedJourney = journey;
              try {
                await _databaseProvider.update(this);
                Logger.info("save last booked");
                notifyListeners();
              } catch (e) {
                Logger.error(e, StackTrace.current);
              }

              journey = result.item2;
            }
          } else if (requestResult.reasonCode == 10) {
            // requested time slot is not available but there are alternative suggestions
            resultCode = requestResult.reasonCode;
            if (requestResult.alternativeTimes != null) {
              times = requestResult.alternativeTimes!;
            }
          }
        } else if (requestResult.reasonCode == 11) {
          // requested time slot is not available and there are no alternatives
          resultCode = requestResult.reasonCode;
          if (requestResult.timeSlot != null) {
            times = requestResult.timeSlot!;
          }
        } else
          resultCode = requestResult.reasonCode;
      }
    } on TimeoutException catch (e) {
      resultCode = 504;
      _setProcessing(false, ProgressState.NONE);
      Logger.error(e, StackTrace.current);
    } on SocketException catch (e) {
      Logger.error(e, StackTrace.current);
      resultCode = 999;
    } catch (e) {
      _setProcessing(false, ProgressState.NONE);
      Logger.error(e, StackTrace.current);
    }
    _setProcessing(false, ProgressState.NONE);
    return Tuple3(resultCode, journey, times);
  }

  String getRequestRouteUrl(Journey journey, int flexibleOption) {
    String url = Amazon.baseUrl + '/routes/';
    url = '$url?startLatitude=${journey.startAddress!.location!.lat}';
    url = '$url&startLongitude=${journey.startAddress!.location!.lng}';
    url = '$url&stopLatitude=${journey.destinationAddress!.location!.lat}';
    url = '$url&stopLongitude=${journey.destinationAddress!.location!.lng}';
    url = '$url&time=${journey.getEncodedDepartureTime()}';
    url = '$url&isDeparture=${journey.isDeparture}';
    url = '$url&seatNumber=${journey.seats}';
    url = '$url&seatNumberWheelchair=${journey.seatsWheelchair}';
    url = '$url&routeId=${journey.routeId}';
    if (flexibleOption == -1) {
      url = '$url&suggestAlternatives=' + Strings.FLEXIBLE_OPTION_EARLIER;
    } else if (flexibleOption == 1) {
      url = '$url&suggestAlternatives=' + Strings.FLEXIBLE_OPTION_LATER;
    }
    return url;
  }

  void _setPwdVerificationMode(bool enabled) {
    _sharedPreferences!.setBool(Strings.prefKeyCode, enabled);
  }

  bool isPwdVerificationMode() {
    return _sharedPreferences!.getBool(Strings.prefKeyCode) ?? false;
  }

  /// Load user data from local database.
  Future<void> loadUser() async {
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      Logger.info("loadUser from database");
      await _databaseProvider.getActiveUser();
    }
  }

  void _setProcessing(bool isProcessing, ProgressState state) {
    Logger.info('setProcessing: ' +
        isProcessing.toString() +
        ", state: " +
        state.toString());
    this.isProcessing = isProcessing;
    this._currentProgressState = state;
    notifyListeners();
  }

  void _setDebugProcessing(bool isProcessing) {
    this.isDebugProcessing = isProcessing;
    notifyListeners();
  }

  bool get isProgressUpdateJourneys {
    return _currentProgressState == ProgressState.UPDATE_JOURNEYS;
  }

  bool get isProgressLogin {
    return _currentProgressState == ProgressState.LOGIN;
  }

  bool get isProgressLogout {
    return _currentProgressState == ProgressState.LOGOUT;
  }

  bool get isProgressRegister {
    return _currentProgressState == ProgressState.REGISTER;
  }

  bool get isProgressReset {
    return _currentProgressState == ProgressState.RESET;
  }

  bool get isProgressDelete {
    return _currentProgressState == ProgressState.DELETE;
  }

  bool get isProgressAccept {
    return _currentProgressState == ProgressState.ACCEPT;
  }

  bool get isProgressConfirm {
    return _currentProgressState == ProgressState.CONFIRM;
  }

  void _reset() {
    _cognitoUser = null;
    _cognitoUserSession = null;

    id = null;
    _name = null;
    email = null;
    _firstName = null;
    _phoneNumber = null;
    _address = null;
    tmpAcceptedRegisterVersions = null;
    favoriteStops = null;
    favoriteJourneys = null;
  }

  /*Future<String> getLogs() async {
    String logString = "";
    try {
      List<Log> logs = await FLog.getAllLogs();

      logs.forEach((log) {
        if (log.text != null) {
          logString += "\n";
          logString += log.timestamp! + ": " + log.text!;
          logString += "\n";
        }
      });
    } catch (e) {
      print(e);
    }

    return logString;
  }*/
}
