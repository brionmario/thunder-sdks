import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:thunder_flutter/thunder_flutter.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(
    ThunderProvider(
      config: ThunderConfig(
        baseUrl: dotenv.env['THUNDER_BASE_URL']!,
        clientId: dotenv.env['THUNDER_CLIENT_ID'],
        applicationId: dotenv.env['THUNDER_APP_ID'],
        afterSignInUrl: dotenv.env['THUNDER_AFTER_SIGN_IN_URL'],
        afterSignOutUrl: dotenv.env['THUNDER_AFTER_SIGN_OUT_URL'],
        scopes: const ['openid', 'profile', 'email'],
      ),
      child: const FlutterB2CApp(),
    ),
  );
}
