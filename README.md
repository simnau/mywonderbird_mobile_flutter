# mywonderbird_mobile_flutter

The MyWonderbird flutter app

## Pre-requisites
- Android SDK - the easiest way is to install Android Studio and then install the SDK using it - https://www.mathworks.com/help/supportpkg/android/ug/install-android-sdk-platform-packages-and-sdk-tools.html
- Android emulator - same as with Android SDK, the easiest way is to create it from Android Studio - https://developers.foxitsoftware.com/kb/article/create-an-emulator-for-testing-in-android-studio/
- Flutter SDK - https://flutter.dev/docs/get-started/install

Depending on what IDE you use, you should install the appropriate flutter extension:
- VS Code - https://flutter.dev/docs/get-started/editor?tab=vscode, https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter
- Android Studio - https://flutter.dev/docs/get-started/editor?tab=androidstudio

## Running the application
- Command line - `flutter run`
- VS Code - open a `.dart` file and press F5, if no emulator is running, it will prompt you to start an emulator and will then launch the app on the emulator
- Android Studio - ?

## Building for prod
To build for prod, run
- App Bundle - `flutter build appbundle -t lib/main-prod.dart`
- APK - `flutter build apk -t lib/main-prod.dart`

In order to be able to upload the app to play store, you need play store signing keys.
