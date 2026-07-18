import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_web_willbefore/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_strategy/url_strategy.dart';

import 'core/routes/route_endpoint.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';

final FirebaseFunctions functions = FirebaseFunctions.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // final config = await rootBundle.loadString(
  //   'assets/config/stripe_config.json',
  // );

  // Stripe.publishableKey = config;

  await Firebase.initializeApp(options: DefaultFirebaseOptions.web);

  await NotificationService().initialize();

  // functions.useFunctionsEmulator('localhost', 5001);

  setPathUrlStrategy();

  runApp(const ProviderScope(child: MyApp()));
}

/// Waits for Firebase Auth to restore the persisted session before showing
/// the router. This prevents Firestore providers from being created while
/// unauthenticated, which would cause them to hang on permission errors.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInitialized = ref.watch(
      authProvider.select((s) => s.isInitialized),
    );

    if (!isInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
    );
  }
}
