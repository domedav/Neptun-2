import 'dart:io';
class AppStrings{
  static late final String _defaultLocale;
  static List<String> _supportedLanguages = ['hu', 'en'];
  static final Map<String, LanguagePack> _languages = {};

  static void initialize(){
    _defaultLocale = Platform.localeName.split('_')[0].toLowerCase();
    _languages.addAll({_supportedLanguages[0]: LanguagePack(
      setupPage_selectLoginTypeHeader_RootPage: 'Válassz bejelentkezési módot',
      setupPage_institutesSelection_RootPage: 'Intézény választás',
      setupPage_institutesSelectionDescription_RootPage: 'Ez a legkényelmesebb opció. Egy szimpla lista, amiben meg tudod keresni az egyetemedet, viszont nem minden intézmény található meg a listában!',
      setupPage_urlLogin_RootPage: 'Neptun URL',
      setupPage_urlLoginDescription_RootPage: 'Ha nincs az iskolád a listában, akkor az egyetemed neptun URL-jét használva is be tudsz lépni. Nem minden egyetemmel működik!',
      setupPage_appProblemReporting_RootPage: 'Probléma van az appal?\nÍrd meg nekem! 👉',
      setupPage_loadingText_InstituteSelection: 'Betöltés...',
      setupPage_noNetwork_InstituteSelection: 'Nincs internet...',
      setupPage_selectValidInstitute_InstituteSelection: 'Válassz ki egy érvényes egyetemet! 😡',
      setupPage_selectInstitute_InstituteSelection: 'Válassz intézményt',
      setupPage_search_InstituteSelection: 'Keresés',
      setupPage_searchNotFound_InstituteSelection: 'Nincs találat...',
      setupPage_instituteCantFindHelpText_InstituteSelection: 'Nem találod az iskolád a listában?',
      setupPage_instituteCantFindHelpTextDescription_InstituteSelection: 'A fenti listában szereplő elemek manuálisan lettek felvéve! 😅 Így előfordulhat, hogy egyes iskolák nincsenek benne a listában.\nJelentkezz be URL használatával, ha nem találod a sulid. 😉',
      setupPage_goBack_Universal: 'Vissza',
      setupPage_proceedLogin_Universal: 'Tovább',
      setupPage_invalidUrl_UrlLogin: 'Írj be egy érvényes neptun URL-t! 😡',
      setupPage_loginViaURlHeader_UrlLogin: 'Belépés URL-el',
      setupPage_instituteNeptunUrl_UrlLogin: 'Egyetem neptun URL-je',
      setupPage_instituteNeptunUrlInvalid_UrlLogin: 'Ez nem egy jó neptun URL! 😡\n\nValami ilyesmit másolj ide:\nhttps://neptun-ws01.uni-pannon.hu/hallgato/login.aspx 🤫',
      setupPage_whereIsURLHelper_UrlLogin: 'Hol találom meg az URL-t?',
      setupPage_whereIsURLHelperDescription_UrlLogin: 'Keresd meg weben az egyetemed neptun weboldalát és másold be ide a fenti linket. 🔗\n\nPld: https://neptun-ws01.uni-pannon.hu/hallgato/login.aspx',
      setupPage_invalidCredentials_LoginPage: 'Érvényes adatokat adj meg! 😡',
      setupPage_loginHeaderText_LoginPage: 'Jelentkezz be',
      setupPage_activityCacheInvalidHelper_LoginPage: 'HIBA! Lépj egyet vissza!',
      setupPage_neptunCode_LoginPage: 'Neptun kód',
      setupPage_password_LoginPage: 'Jelszó',
      setupPage_invalidCredentialsEntered_LoginPage: 'Hibás felhasználónév vagy jelszó!',
      setupPage_2faWarning_LoginPage: 'Ha két lépcsős azonosítás van a fiókodon, nem fogsz tudni bejelenzkezni!',
      setupPage_2faWarningDescription_LoginPage: '❌ A Neptun2 a régi Neptun mobilapp API-jait használja, amiben nem volt 2 lépcsős azonosítás. Így, ha a fiókod 2 lépcsős azonosítással van védve, a Neptun2 nem fog tudni bejelentkeztetni.\n\n🤓 Viszont, ha kikapcsolod, hiba nélkül tudod használni a Neptun2-t.\nKikapcsolni a webes neptunban, a "Saját Adatok/Beállítások"-ban tudod.',
      setupPage_logInButton_LoginPage: 'Belépés',
      setupPage_loginInProgress_LoginPage: 'Bejelentkezés...',
      setupPage_loginInProgressSlow_LoginPage: 'Neptun szervereivel lehet problémák vannak...',
      api_monthJan_Universal: 'január',
      api_monthFeb_Universal: 'február',
      api_monthMar_Universal: 'március',
      api_monthApr_Universal: 'április',
      api_monthMay_Universal: 'május',
      api_monthJun_Universal: 'június',
      api_monthJul_Universal: 'július',
      api_monthAug_Universal: 'augusztus',
      api_monthSep_Universal: 'szeptember',
      api_monthOkt_Universal: 'október',
      api_monthNov_Universal: 'november',
      api_monthDec_Universal: 'december',
      api_dayMon_Universal: 'Hétfő',
      api_dayTue_Universal: 'Kedd',
      api_dayWed_Universal: 'Szerda',
      api_dayThu_Universal: 'Csütörtök',
      api_dayFri_Universal: 'Péntek',
      api_daySat_Universal: 'Szombat',
      api_daySun_Universal: 'Vasárnap'
    )});
    _languages.addAll({_supportedLanguages[1]: LanguagePack(
        setupPage_selectLoginTypeHeader_RootPage: 'Select login method',
      setupPage_institutesSelection_RootPage: 'Institute selection',
      setupPage_institutesSelectionDescription_RootPage: 'This is the simplest way. It is a list, where you can search for your university, however not all institutes can be found here!',
      setupPage_urlLogin_RootPage: 'Neptun URL',
      setupPage_urlLoginDescription_RootPage: 'If you cant find your university inside the list, you can enter the neptun URL of your school to log in. This might not work with all universities!',
      setupPage_appProblemReporting_RootPage: 'Is there a problem with the app?\nTell me! 👉',
      setupPage_loadingText_InstituteSelection: 'Loading...',
      setupPage_noNetwork_InstituteSelection: 'No network...',
      setupPage_selectValidInstitute_InstituteSelection: 'Select a valid institute! 😡',
      setupPage_selectInstitute_InstituteSelection: 'Select institute',
      setupPage_search_InstituteSelection: 'Search',
      setupPage_searchNotFound_InstituteSelection: 'Nothing found...',
      setupPage_instituteCantFindHelpText_InstituteSelection: 'Cant find your school in the list?',
      setupPage_instituteCantFindHelpTextDescription_InstituteSelection: 'Items in the list above were added manually! 😅 It is possible, that some institutes are missing from it.\nYou can login via URL if you cant find your school. 😉',
      setupPage_goBack_Universal: 'Back',
      setupPage_proceedLogin_Universal: 'Proceed',
      setupPage_invalidUrl_UrlLogin: 'Enter a valid neptun URL! 😡',
      setupPage_loginViaURlHeader_UrlLogin: 'Login via URL',
      setupPage_instituteNeptunUrl_UrlLogin: 'Institute neptun URL',
      setupPage_instituteNeptunUrlInvalid_UrlLogin: 'This is not a valid neptun URL! 😡\n\nPaste something similar here:\nhttps://neptun-ws01.uni-pannon.hu/hallgato/login.aspx 🤫',
      setupPage_whereIsURLHelper_UrlLogin: 'Where do I find the URL?',
      setupPage_whereIsURLHelperDescription_UrlLogin: 'Go to your schools neptun website, and paste the link from up top. 🔗\n\nEx: https://neptun-ws01.uni-pannon.hu/hallgato/login.aspx',
      setupPage_invalidCredentials_LoginPage: 'Provide valid credentials! 😡',
      setupPage_loginHeaderText_LoginPage: 'Log in',
      setupPage_activityCacheInvalidHelper_LoginPage: 'ERROR! Please go back!',
      setupPage_neptunCode_LoginPage: 'Neptun code',
      setupPage_password_LoginPage: 'Password',
      setupPage_invalidCredentialsEntered_LoginPage: 'Invalid username or password!',
      setupPage_2faWarning_LoginPage: 'If you have multi factor authentication enabled on your account, you wont be able to login!',
      setupPage_2faWarningDescription_LoginPage: '❌ Neptun2 uses the old Neptun mobileapp API, which didnt contain multi factor authentication. If your account if protected by it, you wont be able to login via Neptun2.\n\n🤓 But you can turn it off, and you will be able to use Neptun2 without a problem.\nTo turn it off, go to "My Data/Settings" in neptun web.',
      setupPage_logInButton_LoginPage: 'Login',
      setupPage_loginInProgress_LoginPage: 'Logging in...',
      setupPage_loginInProgressSlow_LoginPage: 'Neptun servers are having a hard time...',
      api_monthJan_Universal: 'january',
      api_monthFeb_Universal: 'february',
      api_monthMar_Universal: 'march',
      api_monthApr_Universal: 'april',
      api_monthMay_Universal: 'may',
      api_monthJun_Universal: 'june',
      api_monthJul_Universal: 'juli',
      api_monthAug_Universal: 'august',
      api_monthSep_Universal: 'september',
      api_monthOkt_Universal: 'october',
      api_monthNov_Universal: 'november',
      api_monthDec_Universal: 'december',
      api_dayMon_Universal: 'Monday',
      api_dayTue_Universal: 'Tuesday',
      api_dayWed_Universal: 'Wednesday',
      api_dayThu_Universal: 'Thursday',
      api_dayFri_Universal: 'Friday',
      api_daySat_Universal: 'Saturday',
      api_daySun_Universal: 'Sunday'
    )});
  }

  static LanguagePack getLanguagePack(){
    return _getLangPack(_getCurrentLang());
  }

  static String _getCurrentLang(){
    return _defaultLocale;
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
  final String setupPage_loadingText_InstituteSelection;
  final String setupPage_noNetwork_InstituteSelection;
  final String setupPage_selectValidInstitute_InstituteSelection;
  final String setupPage_selectInstitute_InstituteSelection;
  final String setupPage_search_InstituteSelection;
  final String setupPage_searchNotFound_InstituteSelection;
  final String setupPage_instituteCantFindHelpText_InstituteSelection;
  final String setupPage_instituteCantFindHelpTextDescription_InstituteSelection;
  final String setupPage_goBack_Universal;
  final String setupPage_proceedLogin_Universal;
  final String setupPage_invalidUrl_UrlLogin;
  final String setupPage_loginViaURlHeader_UrlLogin;
  final String setupPage_instituteNeptunUrl_UrlLogin;
  final String setupPage_instituteNeptunUrlInvalid_UrlLogin;
  final String setupPage_whereIsURLHelper_UrlLogin;
  final String setupPage_whereIsURLHelperDescription_UrlLogin;
  final String setupPage_invalidCredentials_LoginPage;
  final String setupPage_loginHeaderText_LoginPage;
  final String setupPage_activityCacheInvalidHelper_LoginPage;
  final String setupPage_neptunCode_LoginPage;
  final String setupPage_password_LoginPage;
  final String setupPage_invalidCredentialsEntered_LoginPage;
  final String setupPage_2faWarning_LoginPage;
  final String setupPage_2faWarningDescription_LoginPage;
  final String setupPage_logInButton_LoginPage;
  final String setupPage_loginInProgress_LoginPage;
  final String setupPage_loginInProgressSlow_LoginPage;
  final String api_monthJan_Universal;
  final String api_monthFeb_Universal;
  final String api_monthMar_Universal;
  final String api_monthApr_Universal;
  final String api_monthMay_Universal;
  final String api_monthJun_Universal;
  final String api_monthJul_Universal;
  final String api_monthAug_Universal;
  final String api_monthSep_Universal;
  final String api_monthOkt_Universal;
  final String api_monthNov_Universal;
  final String api_monthDec_Universal;
  final String api_dayMon_Universal;
  final String api_dayTue_Universal;
  final String api_dayWed_Universal;
  final String api_dayThu_Universal;
  final String api_dayFri_Universal;
  final String api_daySat_Universal;
  final String api_daySun_Universal;
  LanguagePack({
    required this.setupPage_selectLoginTypeHeader_RootPage,
    required this.setupPage_institutesSelection_RootPage,
    required this.setupPage_institutesSelectionDescription_RootPage,
    required this.setupPage_urlLogin_RootPage,
    required this.setupPage_urlLoginDescription_RootPage,
    required this.setupPage_appProblemReporting_RootPage,
    required this.setupPage_loadingText_InstituteSelection,
    required this.setupPage_noNetwork_InstituteSelection,
    required this.setupPage_selectValidInstitute_InstituteSelection,
    required this.setupPage_selectInstitute_InstituteSelection,
    required this.setupPage_search_InstituteSelection,
    required this.setupPage_searchNotFound_InstituteSelection,
    required this.setupPage_instituteCantFindHelpText_InstituteSelection,
    required this.setupPage_instituteCantFindHelpTextDescription_InstituteSelection,
    required this.setupPage_goBack_Universal,
    required this.setupPage_proceedLogin_Universal,
    required this.setupPage_invalidUrl_UrlLogin,
    required this.setupPage_loginViaURlHeader_UrlLogin,
    required this.setupPage_instituteNeptunUrl_UrlLogin,
    required this.setupPage_instituteNeptunUrlInvalid_UrlLogin,
    required this.setupPage_whereIsURLHelper_UrlLogin,
    required this.setupPage_whereIsURLHelperDescription_UrlLogin,
    required this.setupPage_invalidCredentials_LoginPage,
    required this.setupPage_loginHeaderText_LoginPage,
    required this.setupPage_activityCacheInvalidHelper_LoginPage,
    required this.setupPage_neptunCode_LoginPage,
    required this.setupPage_password_LoginPage,
    required this.setupPage_invalidCredentialsEntered_LoginPage,
    required this.setupPage_2faWarning_LoginPage,
    required this.setupPage_2faWarningDescription_LoginPage,
    required this.setupPage_logInButton_LoginPage,
    required this.setupPage_loginInProgress_LoginPage,
    required this.setupPage_loginInProgressSlow_LoginPage,
    required this.api_monthJan_Universal,
    required this.api_monthFeb_Universal,
    required this.api_monthMar_Universal,
    required this.api_monthApr_Universal,
    required this.api_monthJun_Universal,
    required this.api_monthMay_Universal,
    required this.api_monthJul_Universal,
    required this.api_monthAug_Universal,
    required this.api_monthSep_Universal,
    required this.api_monthOkt_Universal,
    required this.api_monthNov_Universal,
    required this.api_monthDec_Universal,
    required this.api_dayMon_Universal,
    required this.api_dayTue_Universal,
    required this.api_dayWed_Universal,
    required this.api_dayThu_Universal,
    required this.api_dayFri_Universal,
    required this.api_daySat_Universal,
    required this.api_daySun_Universal,
  });
}