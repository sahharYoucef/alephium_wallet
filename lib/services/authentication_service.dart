import 'dart:io';

import 'package:local_auth/local_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';

class AuthenticationService {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  final LocalAuthentication auth = LocalAuthentication();
  AndroidDeviceInfo? info;

  Future<bool> authenticate(String message) async {
    var options = AuthenticationOptions();
    if (Platform.isAndroid) {
      final sdkInt = await _getAndroidSdkVersion;
      if (sdkInt < 29) {
        options = AuthenticationOptions(biometricOnly: true);
      }
    }
    final didAuthenticate = await auth.authenticate(
      localizedReason: message,
      options: options,
    );
    return didAuthenticate;
  }

  Future<int> get _getAndroidSdkVersion async {
    info = info ?? await deviceInfo.androidInfo;
    final sdkInt = info!.version.sdkInt;
    return sdkInt;
  }

  Future<bool> get canAuthenticate async {
    if (Platform.isAndroid) {
      final sdkInt = await _getAndroidSdkVersion;
      if (sdkInt < 29) {
        return Future.value(true);
      }
    }
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool canAuthenticate =
        canAuthenticateWithBiometrics || await auth.isDeviceSupported();
    return canAuthenticate;
  }
}
