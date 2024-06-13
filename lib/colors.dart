import 'dart:async';
import 'dart:convert' as conv;
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:neptun2/storage.dart';

import 'Pages/startup_page.dart';

class AppColors{
  static bool _hasInit = false;
  static List<AppPalette> _appColors = [];
  static List<AppPalette> _downloadedAppColors = [];
  static int _themeBatchSelectedIdx = -1;
  static bool _isDark = false;

  static bool isDarktheme(){
    return _isDark;
  }

  static void initialize() {
    if (_hasInit) {
      return;
    }
    _appColors.add(AppPalette('Light',
      primary: Color.fromRGBO(0x6C, 0x8F, 0x96, 1.0),
      onPrimary: Color.fromRGBO(0x00, 0x00, 0x00, 1.0),
      onPrimaryContainer: Color.fromRGBO(0x45, 0x6C, 0x76, 1.0),
      secondary: Color.fromRGBO(0xA7, 0xC4, 0xC8, 1.0),
      onSecondary: Color.fromRGBO(0x1B, 0x1B, 0x1B, 1.0),
      onSecondaryContainer: Color.fromRGBO(0x6C, 0x8F, 0x96, 1.0),
      grade1: Color.fromRGBO(0xBD, 0x2E, 0x2E, 1.0),
      grade2: Color.fromRGBO(0x95, 0x51, 0x51, 1.0),
      grade3: Color.fromRGBO(0x9E, 0x97, 0x54, 1.0),
      grade4: Color.fromRGBO(0x72, 0x88, 0x5A, 1.0),
      grade5: Color.fromRGBO(0x56, 0x7B, 0x58, 1.0),
      navbarStatusBarColor: Color.fromRGBO(0xF0, 0xF0, 0xF0, 1.0),
      navbarNavibarColor: Color.fromRGBO(0xE0, 0xE0, 0xE0, 1.0),
      rootBackground: Color.fromRGBO(0xE2, 0xE2, 0xE2, 1.0),
      textColor: Color.fromRGBO(0x00, 0x00, 0x00, 1.0),
      buttonEnabled: Color.fromRGBO(0xA7, 0xC4, 0xC8, 1.0),
      buttonDisabled: Color.fromRGBO(0xD3, 0xDD, 0xDD, 1.0),
      errorRed: Color.fromRGBO(0xFF, 0x52, 0x52, 1.0),
      currentClassGreen: Color.fromRGBO(0x46, 0x97, 0x32, 1.0),
    ));
    _appColors.add(AppPalette('Dark',
      primary: Color.fromRGBO(0x6C, 0x8F, 0x96, 1.0),
      onPrimary: Color.fromRGBO(0xFF, 0xFF, 0xFF, 1.0),
      onPrimaryContainer: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
      secondary: Color.fromRGBO(0x4F, 0x69, 0x6E, 1.0),
      onSecondary: Color.fromRGBO(0xB6, 0xB6, 0xB6, 1.0),
      onSecondaryContainer: Color.fromRGBO(0x6C, 0x8F, 0x96, 1.0),
      grade1: Color.fromRGBO(0xFF, 0x52, 0x52, 1.0),
      grade2: Color.fromRGBO(0xEF, 0x9A, 0x9A, 1.0),
      grade3: Color.fromRGBO(0xFF, 0xF5, 0x9D, 1.0),
      grade4: Color.fromRGBO(0xC5, 0xE1, 0xA5, 1.0),
      grade5: Color.fromRGBO(0xA5, 0xD6, 0xA7, 1.0),
      navbarStatusBarColor: Color.fromRGBO(0x0C, 0x0C, 0x0C, 1.0),
      navbarNavibarColor: Color.fromRGBO(0x1A, 0x1A, 0x1A, 1.0),
      rootBackground: Color.fromRGBO(0x22, 0x22, 0x22, 1.0),
      textColor: Color.fromRGBO(0xFF, 0xFF, 0xFF, 1.0),
      buttonEnabled: Color.fromRGBO(0x31, 0x42, 0x42, 1.0),
      buttonDisabled: Color.fromRGBO(0x22, 0x2B, 0x2B, 1.0),
      errorRed: Color.fromRGBO(0xFF, 0xB0, 0xB0, 1.0),
      currentClassGreen: Color.fromRGBO(0x8B, 0xD4, 0x81, 1.0),
    ));

    _hasInit = true;
  }

  static AppPalette getTheme(){
    if(_themeBatchSelectedIdx == -1){
      if(_isDark){
        return _appColors[1];
      }
      else{
        return _appColors[0];
      }
    }
    if(_isDark){
      return _appColors[1];
    }
    else{
      return _appColors[0];
    }
  }

  static void setCurrentSystemTheme(bool isDark) {
    _isDark = isDark;
  }

  static void refreshThemeIndexing(){
    final List<AppPalette> batch = _appColors + _downloadedAppColors;
    final userPreference = DataCache.getPreferredAppTheme();
    var idx = -1;
    for(var item in batch){
      if(item.paletteName == userPreference){
        idx = batch.indexOf(item);
        break;
      }
    }
    _themeBatchSelectedIdx = idx;
  }

  static void changedSystemTheme(){
    _isDark = !_isDark;
  }

  static void saveDownloadedPaletteData(){
    List<String> saveList = [];
    final List<AppPalette> batch = _appColors + _downloadedAppColors;
    for(var item in batch){
      saveList.add(AppPalette.toJson(item));
    }
    DataCache.setAllDownloadedAppThemes(saveList);
  }

  static Timer _loadDownloadColorTimer = Timer(Duration.zero, () {});

  static Future<void> loadDownloadedPaletteData(BuildContext context)async{
    final downloadedPalattesJson = DataCache.getAllDownloadedAppThemes();
    for(var item in downloadedPalattesJson){
      await Future.delayed(Duration.zero, (){
        AppPalette.fromJson(item, ()async{
          if(!DataCache.getHasNetwork()){
            return;
          }
          //await Language.getLanguagePackById(await Language.getAllLanguages(), downloadedSupportedLanguages[i]); // redownload language
          _loadDownloadColorTimer.cancel();
          _loadDownloadColorTimer = Timer(const Duration(seconds: 3), (){
            saveDownloadedPaletteData(); // save after all langs have been fetched
          });
          Navigator.popUntil(context, (route) => route.willHandlePopInternally);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Splitter()),
          );
        });
      });
    }
    refreshThemeIndexing();
  }
}

class AppPalette{
  final String paletteName;

  final Color primary;
  final Color onPrimary;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color onSecondaryContainer;
  final Color grade1;
  final Color grade2;
  final Color grade3;
  final Color grade4;
  final Color grade5;

  final Color navbarNavibarColor;
  final Color navbarStatusBarColor;

  final Color rootBackground;
  final Color textColor;

  final Color buttonEnabled;
  final Color buttonDisabled;

  final Color errorRed;

  final Color currentClassGreen;

  const AppPalette(this.paletteName, {required this.currentClassGreen, required this.errorRed, required this.buttonDisabled, required this.buttonEnabled, required this.textColor, required this.rootBackground, required this.navbarNavibarColor, required this.navbarStatusBarColor, required this.primary, required this.onPrimary, required this.onPrimaryContainer, required this.secondary, required this.onSecondary, required this.onSecondaryContainer, required this.grade1, required this.grade2, required this.grade3, required this.grade4, required this.grade5});

  static AppPalette fromJson(String json, VoidCallback onColorOutdated){
    AppPalette decodedColorPack;
    try{
      final color = conv.json.decode(json);
      decodedColorPack = AppPalette(
        color['paletteName'],
        primary: color['primary'],
        onPrimary: color['onPrimary'],
        onPrimaryContainer: color['onPrimaryContainer'],
        secondary: color['secondary'],
        onSecondary: color['secondary'],
        onSecondaryContainer: color['onSecondaryContainer'],
        grade1: color['grade1'],
        grade2: color['grade2'],
        grade3: color['grade3'],
        grade4: color['grade4'],
        grade5: color['grade5'],
        navbarNavibarColor: color['navbarNavibarColor'],
        navbarStatusBarColor: color['navbarStatusBarColor'],
        rootBackground: color['rootBackground'],
        textColor:color['textColor'],
        buttonDisabled: color['buttonDisabled'],
        buttonEnabled: color['buttonEnabled'],
        errorRed: color['errorRed'],
        currentClassGreen: color['currentClassGreen']
      );
      for(var item in AppColors._downloadedAppColors){
        if(item.paletteName == decodedColorPack.paletteName){
          AppColors._downloadedAppColors.removeAt(AppColors._downloadedAppColors.indexOf(item)); // remove duplicate
          break;
        }
      }
    }
    catch(error){
      Future.delayed(Duration.zero,(){
        onColorOutdated();
      });
      return AppColors.getTheme();
    }
    AppColors._downloadedAppColors.add(decodedColorPack);
    return decodedColorPack;
  }

  static String toJson(AppPalette palette){
    final json = conv.json.encode({
      'paletteName':palette.paletteName,
      'primary':palette.primary,
      'onPrimary':palette.onPrimary,
      'onPrimaryContainer':palette.onPrimaryContainer,
      'secondary':palette.secondary,
      'onSecondary':palette.onSecondary,
      'onSecondaryContainer':palette.onSecondaryContainer,
      'grade1':palette.grade1,
      'grade2':palette.grade2,
      'grade3':palette.grade3,
      'grade4':palette.grade4,
      'grade5':palette.grade5,
      'navbarNavibarColor':palette.navbarNavibarColor,
      'navbarStatusBarColor':palette.navbarStatusBarColor,
      'rootBackground':palette.rootBackground,
      'textColor':palette.textColor,
      'buttonEnabled':palette.buttonEnabled,
      'buttonDisabled':palette.buttonDisabled,
      'errorRed':palette.errorRed,
      'currentClassGreen':palette.currentClassGreen
    });
    return json;
  }
}