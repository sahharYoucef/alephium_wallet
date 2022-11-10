import 'package:local_auth/local_auth.dart';

class AuthenticationService {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> authenticate(String message) async {
    final didAuthenticate = await auth.authenticate(
      localizedReason: message,
    );
    return didAuthenticate;
  }

  Future<bool> get canAuthenticate async {
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool canAuthenticate =
        canAuthenticateWithBiometrics || await auth.isDeviceSupported();
    return canAuthenticate;
  }
}
