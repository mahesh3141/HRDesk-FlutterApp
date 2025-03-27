import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';

import '../Screen/Splash_Screen.dart';
import 'Screen/companyCodeScreen.dart';
import 'Screen/login_screen.dart';
import 'Screen/otp_verification.dart';
import 'Screen/sign_up.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  //bool? is_visible= prefs.getBool("first_time");
  // print("======= ${is_visible}");

  // bool isFirstRun = prefs.getBool('isFirstRun') ?? true;
  await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
  );
  await Permission.storage.request();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

//  MyApp(bool? is_visible);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HrDesk',
      initialRoute: SplashScreen.id,
      routes: {
        SplashScreen.id: (context) => const SplashScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        CompanyCodeScreen.id: (context) => const CompanyCodeScreen(),
       // '/register': (context) => const SignupScreen(),
       // '/otp': (context) => const OtpScreen(),
        //'/home': (context) => WebViewScreen(),
      },
    );
  }
}
