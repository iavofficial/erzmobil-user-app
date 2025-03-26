# ERZmobil

This project contains the code for the Erzmobil Passenger App.

## Getting Started
These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

What you need to install the app and how to install the app

-   [Visual Studio Code](https://code.visualstudio.com/) (recommended)
-   [Android Studio](https://developer.android.com/studio/) (optional)
-   [XCode](https://developer.apple.com/xcode/) (required for iOS)
-   [Flutter](https://docs.flutter.dev/get-started/install) (Version 2.2.3, Dart 2.13.4 )

### Run the project

In Visual Studio Code, open the project, go to the Terminal and type `flutter run`

## Configuration

### Cognito

The cognito configuration (user pool, region, etc) can be edited in the `lib/Amazon` file.

### Backend URLs, Text Styles, Constants

The base url for the backend communication is defined at `lib/Amazon.baseUrl`, the custom endpoints for the communication are defined in the `lib/Constants` class. This class also contains various constants like urls, phone numbers, text styles and custom colors.

### Localization

The texts files can be found here: `lib/l10n`

## How to build a release

## Android
1. Make sure you have an existing keystore and the key.properties file set up. If not follow the steps described [here](https://docs.flutter.dev/deployment/android#create-an-upload-keystore)
2. Afterwards you can run `flutter build apk` or `flutter build appbundle`.
3. Grab the artifacts from `build\app\outputs\flutter-apk\app-release.apk/` or `build\app\outputs\bundle\release\app-release.aab`

## iOS
1. You must install the needed signing certificates and provisining profiles.
2. Afterwards you can run `flutter build ipa` to produce an Xcode build archive (.xcarchive file) in the project's `build/ios/archive/` directory and an App Store app bundle (.ipa file) in `build/ios/ipa`.

Further insights regarding Push: 
It happened not only once, that Push Notification on a submitted app store version just didn't work. After successful submit to Appstoreconnect, an email from the Apple informed about the following:
`...Missing Push Notification Entitlement - Your app appears to register with the Apple Push Notification service, but the app signature's entitlements do not include the 'aps-environment' entitlement....`

It turned out that a setting in the Xcode project file `(CODE_SIGNING_ALLOWED = NO)` caused this to happen. Therefore, make sure `CODE_SIGNING_ALLOWED = YES`.
For some reason, the CI config (Fastfile) had it set to NO and thus produced a xcarchive that would not support push. Signing a resulting xcarchive from CI was missing the entitlements completely.
This lead to the mentioned email above.

So if you ever come accross such a problem again, make sure you have set CODE_SIGNING_ALLOWED to YES. 

Gitlab CI can be used to build a Release version. Take the resulting xcarchive and use Xcode to submit it to the App Store.

## WebApp
1. Run `flutter build web` in the Terminal.
2. Afterwards you can run 
3. Grab the artifacts from `build\web\`

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.