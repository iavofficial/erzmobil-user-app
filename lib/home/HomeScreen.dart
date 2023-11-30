import 'package:erzmobil/debug/Logger.dart';
import 'package:erzmobil/journeys/Booking.dart';
import 'package:erzmobil/journeys/JourneyHistory.dart';
import 'package:erzmobil/location/LocationManager.dart';
import 'package:erzmobil/model/RequestState.dart';
import 'package:erzmobil/push/PushNotificationService.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:erzmobil/Constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:erzmobil/account/AccountScreen.dart';
import 'package:erzmobil/information/InformationScreen.dart';
import 'package:erzmobil/journeys/MyJourneys.dart';
import 'package:erzmobil/model/User.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  int _contentIndex = 0;
  bool _isInitialLogin = true;

  late List<String> _pageTitles;
  late Widget _page1;
  late Widget _page2;
  late Widget _page3;
  late Widget _page4;
  late List<Widget> _pages = <Widget>[];
  AppLifecycleState lifecycleState = AppLifecycleState.resumed;

  @override
  void initState() {
    super.initState();
    _page1 = AccountScreen();
    _page2 = MyJourneysScreen();
    _page3 = BookingScreen(changePage: onItemTapped);
    _page4 = InformationScreen();
    _pages = [_page1, _page2, _page3, _page4];
    if (User().isLoggedIn() &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      Future.delayed(Duration.zero, () async {
        RequestState result = await User().registerToken();
        User().showFCMErrorIfnecessary(context, result);
      });
    }

    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    lifecycleState = state;
    if (state == AppLifecycleState.resumed) {
      if (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS) {
        RemoteMessage? initialMessage =
            await FirebaseMessaging.instance.getInitialMessage();

        if (initialMessage != null) {
          PushNotificationService().handleMessage(initialMessage, context);
        } else {
          Logger.info("No push message available");
        }
      }
    }
  }

  Future<void> setupInteractedMessage(BuildContext context) async {
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        PushNotificationService().handleMessage(initialMessage, context);
      }
    }
  }

  void _buildTitleList(BuildContext context) {
    _pageTitles = <String>[
      AppLocalizations.of(context)!.authentication,
      AppLocalizations.of(context)!.myJourneys,
      AppLocalizations.of(context)!.newJourney,
      AppLocalizations.of(context)!.infoTitle,
    ];
  }

  void _computeIndex() {
    if (User().isLoggedIn() && _isInitialLogin) {
      _selectedIndex = 1;
      _contentIndex = 1;
      _isInitialLogin = false;
    }
  }

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      bool isLoggedIn = User().isLoggedIn();
      if (index == 0) {
        _contentIndex = index;
      } else if (index == 1) {
        _contentIndex = isLoggedIn ? 1 : 3;
      } else if (index >= 2) {
        _contentIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    PushNotificationService()
        .initialisePushMessageHandling(context, onItemTapped);
    setupInteractedMessage(context);
    _buildTitleList(context);
    return Consumer<User>(builder: (context, user, child) {
      _computeIndex();
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[CustomColors.mint, CustomColors.marine])),
          ),
          title: Text(_pageTitles.elementAt(_contentIndex)),
          actions: !User().isProcessing && _contentIndex == 1
              ? <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.history,
                      color: User().isLoggedIn() &&
                              User().journeyList != null &&
                              User().journeyList!.getCompletedJourneys() != null
                          ? CustomColors.white
                          : CustomColors.lightGrey,
                    ),
                    onPressed: User().isLoggedIn() &&
                            User().journeyList != null &&
                            User().journeyList!.getCompletedJourneys() != null
                        ? () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    new JourneyHistory()));
                          }
                        : null,
                  )
                ]
              : null,
        ),
        extendBodyBehindAppBar: false,
        body: _pages.elementAt(_contentIndex),
        bottomNavigationBar: BottomNavigationBar(
          selectedLabelStyle: User().isProcessing
              ? CustomTextStyles.navigationWhite
              : CustomTextStyles.navigationMint,

          type: BottomNavigationBarType.fixed,
          backgroundColor: CustomColors.anthracite,

          /// takes only font size
          unselectedLabelStyle: CustomTextStyles.navigationGrey,

          /// takes only font size
          selectedIconTheme: CustomIconThemeData.navigationIconMint,
          unselectedIconTheme: CustomIconThemeData.navigationIconWhite,
          selectedItemColor: CustomColors.mint,
          unselectedItemColor: CustomColors.white,
          currentIndex: _selectedIndex,
          // this will be set when a new tab is tapped
          onTap: User().isProcessing ? (int index) {} : onItemTapped,
          items: _buildTabs(context),
        ),
      );
    });
  }

  List<BottomNavigationBarItem> _buildTabs(BuildContext context) {
    if (User().isLoggedIn()) {
      return <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: new Icon(Icons.account_circle),
          label: AppLocalizations.of(context)!.authentication,
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.departure_board),
            label: (AppLocalizations.of(context)!.myJourneys)),
        BottomNavigationBarItem(
            icon: Icon(Icons.add_location_alt),
            label: (AppLocalizations.of(context)!.newJourney)),
        BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: (AppLocalizations.of(context)!.infoTitle)),
      ];
    } else {
      return <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: new Icon(Icons.account_circle),
          label: (AppLocalizations.of(context)!.authentication),
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: (AppLocalizations.of(context)!.infoTitle))
      ];
    }
  }
}
