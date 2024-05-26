import 'dart:io';
class AppStrings{
  static late final String defaultLocale;
  static List<String> _supportedLanguages = ['hu', 'en'];
  static final Map<String, LanguagePack> _languages = {};

  static void initialize(){
    defaultLocale = Platform.localeName.split('_')[0].toLowerCase();
    _languages.addAll({_supportedLanguages[0]: LanguagePack(
      setupPage_selectLoginTypeHeader_RootPage: 'Válassz bejelentkezési módot',
      setupPage_institutesSelection_RootPage: 'Intézény választás',
      setupPage_institutesSelectionDescription_RootPage: 'Ez a legkényelmesebb opció. Egy szimpla lista, amiben meg tudod keresni az egyetemedet, viszont nem minden intézmény található meg a listában!',
      setupPage_urlLogin_RootPage: 'Neptun URL',
      setupPage_urlLoginDescription_RootPage: 'Ha nincs az iskolád a listában, akkor az egyetemed neptun URL-jét használva is be tudsz lépni. Nem minden egyetemmel működik!',
      setupPage_appProblemReporting_RootPage: 'Probléma van az appal?\nÍrd meg nekem! 👉',
    )});
    _languages.addAll({_supportedLanguages[1]: LanguagePack(
        setupPage_selectLoginTypeHeader_RootPage: 'Select login method',
      setupPage_institutesSelection_RootPage: 'Institute selection',
      setupPage_institutesSelectionDescription_RootPage: 'This is the simplest way. It is a list, where you can search for your university, however not all institutes can be found here!',
      setupPage_urlLogin_RootPage: 'Neptun URL',
      setupPage_urlLoginDescription_RootPage: 'If you cant find your university inside the list, you can enter the neptun URL of your school to log in. This might not work with all universities!',
      setupPage_appProblemReporting_RootPage: 'Is there a problem with the app?\nTell me! 👉',
    )});
  }

  static LanguagePack getLanguagePack(){
    return _getLangPack(_getCurrentLang());
  }

  static String _getCurrentLang(){
    return defaultLocale;
  }

  static LanguagePack _getLangPack(String id){
    if(!_languages.containsKey(id)){
      return _languages[_supportedLanguages[0]]!;
    }
    return _languages[id]!;
  }

  static String getStringWithParams(String base, List<dynamic> params){
    String result = "" + base;
    for(int i = 0; i < params.length; i++){
      result.replaceAll('%$i', '${params[i].toString()}');
    }
    return result;
  }

  static String getStringPrural(String one, String multiple, int determiner){
    return determiner <= 0 ? one : multiple;
  }

}

class LanguagePack{
  final String setupPage_selectLoginTypeHeader_RootPage;
  final String setupPage_institutesSelection_RootPage;
  final String setupPage_institutesSelectionDescription_RootPage;
  final String setupPage_urlLogin_RootPage;
  final String setupPage_urlLoginDescription_RootPage;
  final String setupPage_appProblemReporting_RootPage;
  LanguagePack({
    required this.setupPage_selectLoginTypeHeader_RootPage,
    required this.setupPage_institutesSelection_RootPage,
    required this.setupPage_institutesSelectionDescription_RootPage,
    required this.setupPage_urlLogin_RootPage,
    required this.setupPage_urlLoginDescription_RootPage,
    required this.setupPage_appProblemReporting_RootPage,
  });
}