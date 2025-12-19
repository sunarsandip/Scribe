import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env", isOptional: true);
    if (!dotenv.isInitialized) {
      debugPrint('dotenv not loaded (file missing or empty).');
    }
  } catch (e) {
    debugPrint("Failed to load dotenv: $e");
  }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AppRouteConfig appRouting = AppRouteConfig();
    return MaterialApp.router(
      title: 'Scribe - AI Meeting Recorder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: AppColors.backgroundColor,
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.backgroundColor,
          actionsIconTheme: IconThemeData(color: AppColors.iconButtonColor),
          iconTheme: IconThemeData(color: AppColors.iconButtonColor),
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryTextColor,
          ),
        ),
      ),
      routeInformationParser: appRouting.appRoutes.routeInformationParser,
      routeInformationProvider: appRouting.appRoutes.routeInformationProvider,
      routerDelegate: appRouting.appRoutes.routerDelegate,
      debugShowCheckedModeBanner: false,
    );
  }
}