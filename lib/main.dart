import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_willbefore/core/routes/app_router.dart';
import 'package:flutter_web_willbefore/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
