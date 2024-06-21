import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:neptun2/colors.dart';
import 'package:neptun2/storage.dart';
import 'package:provider/provider.dart';
import 'Pages/startup_page.dart';
import 'language.dart';

void main() {
  //DataCache.dataWipeNoKeep();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  DataCache.loadThemeOnly().whenComplete((){
    AppColors.initialize();
    AppStrings.initialize();
    final app = const NeptunApp();
    final themeNotifier = ThemeNotifier(ThemeNotifier._initialTheme(AppColors.getTheme().basedOnDark));
    runApp(
      ChangeNotifierProvider(
        create: (_) => themeNotifier,
        child: app,
      ),
    );
    WidgetsBinding.instance.addObserver(app);
  });
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
class NeptunApp extends StatelessWidget with WidgetsBindingObserver {
  const NeptunApp({super.key});

  @override
  void didChangePlatformBrightness(){
    //final systemTheme = MediaQuery.of(navigatorKey.currentContext!).platformBrightness == Brightness.dark;
    final isDark = MediaQuery.of(navigatorKey.currentContext!).platformBrightness == Brightness.dark;
    //log('$systemTheme $isDark');
    AppColors.setCurrentSystemTheme(!isDark);
    final preferedTheme = !isDark ? 'Dark' : 'Light';
    AppColors.setUserThemeByName(preferedTheme, navigatorKey.currentContext!);
    DataCache.setPreferredAppTheme(preferedTheme);
    //navigatorKey.currentContext!.read<ThemeNotifier>().createNewThemeData();
    super.didChangePlatformBrightness();
  }

  static bool _themeSetup = false;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.getTheme().basedOnDark;
    AppColors.setCurrentSystemTheme(isDark);
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    if(!_themeSetup){
      _themeSetup = true;
      WidgetsBinding.instance.addPostFrameCallback((_){
        final isDark = AppColors.getTheme().basedOnDark;
        AppColors.setCurrentSystemTheme(isDark);
        final userTheme = DataCache.getPreferredAppTheme();
        if(userTheme == null || userTheme == 'Dark' || userTheme == 'Light'){
          AppColors.setUserThemeByName(isDark ? 'Dark' : 'Light', navigatorKey.currentContext!);
        }
        AppColors.setUserThemeByName(userTheme!, navigatorKey.currentContext!);
        AppColors.refreshThemeIndexing();
      });
    }
    return MaterialApp(
      key: navigatorKey,
      title: 'Neptun 2',
      theme: themeNotifier._themeData,
      home: const Splitter(),
    );
  }
}

class ThemeNotifier extends ChangeNotifier {

  static ThemeNotifier? _instance;

  ThemeData _themeData;
  ThemeNotifier(this._themeData){
    _instance = this;
  }

  static ThemeNotifier? getInstance(){
    return _instance;
  }

  void createNewThemeData(){
    _themeData = _buildTheme(AppColors.isDarktheme());
    notifyListeners();
  }

  ThemeData _buildTheme(bool isDark) {
    return ThemeData(
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
    );
  }

  static ThemeData _initialTheme(bool isDark){
    return ThemeData(
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
    );
  }
}