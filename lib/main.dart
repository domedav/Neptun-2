import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:neptun2/colors.dart';
import 'Pages/startup_page.dart';
import 'language.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  AppStrings.initialize();
  AppColors.initialize();
  final app = const NeptunApp();
  runApp(app);
  WidgetsBinding.instance.addObserver(app);
}

class NeptunApp extends StatelessWidget with WidgetsBindingObserver {
  const NeptunApp({super.key});

  @override
  void didChangePlatformBrightness() {
    AppColors.changedSystemTheme();
    super.didChangePlatformBrightness();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    AppColors.setCurrentSystemTheme(isDark);
    return MaterialApp(
      title: 'Neptun 2',
      theme: ThemeData(
        colorScheme: isDark ? ColorScheme.dark(
          primary: AppColors.getTheme().primary,
          onPrimary: AppColors.getTheme().onPrimary,
          onPrimaryContainer: AppColors.getTheme().onSecondaryContainer,
          secondary: AppColors.getTheme().secondary,
          onSecondary: AppColors.getTheme().onSecondary,
          onSecondaryContainer: AppColors.getTheme().onSecondaryContainer,
        ) : ColorScheme.light(
          primary: AppColors.getTheme().primary,
          onPrimary: AppColors.getTheme().onPrimary,
          onPrimaryContainer: AppColors.getTheme().onSecondaryContainer,
          secondary: AppColors.getTheme().secondary,
          onSecondary: AppColors.getTheme().onSecondary,
          onSecondaryContainer: AppColors.getTheme().onSecondaryContainer,
        ),
        useMaterial3: true,
      ),
      home:const Splitter(),
      );
  }
}