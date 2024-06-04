import 'dart:developer';
import 'dart:io';
class AppStrings{
  static bool _hasInit = false;
  static late final String _defaultLocale;
  static List<String> _supportedLanguages = ['hu', 'en'];
  static final Map<String, LanguagePack> _languages = {};

  static void initialize(){
    if(_hasInit){
      return;
    }
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
      api_daySun_Universal: 'Vasárnap',
      api_loadingScreenHintFriendly1_Universal: 'Elfüstölne a telefonod, ha gyorsabb lenne...',
      api_loadingScreenHintFriendly2_Universal: 'Még mindíg, jobb mint a nem létező Neptun mobilapp...',
      api_loadingScreenHintFriendly3_Universal: 'Már bármelyik milleniumban betölthet...',
      api_loadingScreenHintFriendly4_Universal: 'Áramszünet van az SDA Informatikánál...',
      api_loadingScreenHintFriendly5_Universal: 'Az SDA Informatika egy nagyon jó cég...',
      api_loadingScreenHintFriendly6_Universal: 'Tudtad? A "Neptun 2" alapja csupán 1 hét alatt készült...',
      api_loadingScreenHintFriendly7_Universal: 'Túl lassú? Panaszkodj az SDA Informatikának...',
      api_loadingScreenHint1_Universal: 'Úgy dolgoznak a Neptun szerverek, mint egy átlagos államilag finanszírozott útépítés...',
      api_loadingScreenHint2_Universal: 'Megvárjuk, amíg az SDA Informatika főnöke kávéba fullad...',
      api_loadingScreenHint3_Universal: 'Légy türelmes, egy patkány miatt zárlatos lett az egyik szerver...',
      api_loadingScreenHint4_Universal: 'Előbb hiszem el, hogy az Északi-sarkon is vannak pingvinek, minthogy a Neptun szervereire pénzt költöttek...',
      api_loadingScreenHint5_Universal: 'Neptun szerverei olyan megbízhatóak, bankolni is lehet rajtuk...',
      api_loadingScreenHint6_Universal: 'SDA jelentése: Sok Dagadt Analfabéta. Egy normális mobilappot nem sikerült összehoziuk...',
      api_loadingScreenHint7_Universal: 'Fogadni merek, mire ezt elolvasod, még mindíg a Neptun szervereire vársz...',
      api_loadingScreenHintFriendlyMini1_Universal: 'Egy pillanat...',
      api_loadingScreenHintFriendlyMini2_Universal: 'Alakul a molekula...',
      api_loadingScreenHintFriendlyMini3_Universal: 'Csak szépen lassan...',
      api_loadingScreenHintFriendlyMini4_Universal: 'Tölt valamit nagyon...',
      api_loadingScreenHintMini1_Universal: 'Na, megvan?...',
      api_loadingScreenHintMini2_Universal: 'Várjál! Nem megy ez ilyen gyorsan...',
      api_loadingScreenHintMini3_Universal: 'Nem emlékszel mit olvastál? Szedj B6 vitamint!...',
      api_generic_NoData: 'Nincs Adat',
      view_header_Calendar: 'Órarend',
      view_header_Messages: 'Üzenetek',
      view_header_Payments: 'Befizetendők',
      view_header_Periods: 'Időszakok',
      view_header_Subjects: 'Tárgyak',
      topheader_calendar_greetMessage_1to6: 'Boldog hajnalt! 🍼',
      topheader_calendar_greetMessage_6to9: 'Jó reggelt! ☕',
      topheader_calendar_greetMessage_9to13: 'Szép napot! 🍷',
      topheader_calendar_greetMessage_13to17: 'Kellemes délutánt! 🥂',
      topheader_calendar_greetMessage_17to21: 'Szép estét! 🍻',
      topheader_calendar_greetMessage_21to1: 'Jó éjszakát! 🍹',
      topheader_subjects_CreditsInSemester: 'Kredited ebben a félévben: %0🎖️',
      topheader_payments_TotalMoneySpent: '%0Ft-ot költöttél az egyetemre 💸',
      topheader_periods_ActiveText: 'Aktuális',
      topheader_periods_ExpiredText: 'Lejárt',
      topheader_periods_FutureText: 'Jövőbeli',
      topheader_periods_MainHeader: '%0 %1, %2 %3, %4 %5 🗓️',
      topheader_messages_UnreadMessages: '%0 olvasatlan üzeneted van 💌',
      topmenu_Greet: 'Szia %0! 👋',
      topmenu_LoginPlace: 'Ide vagy bejelentkezve: 🔗\n%0',
      topmenu_buttons_Settings: '⚙ Beállítások',
      topmenu_buttons_SupportDev: '🎁 Fejlesztés támogatása',
      topmenu_buttons_Bugreport: '🐞 Hibabejelentés',
      topmenu_buttons_Logout: '🚪 Kijelentkezés',
      topmenu_buttons_LogoutSuccessToast: 'Sikeresen kijelentkeztél! 🚪',
      calendarPage_FreeDay: '🥳Szabadnap!🥳',
      calendarPage_weekNav_ClassesThisWeekFull: 'Óráid ezen a héten: %0 %1. - %2 %3.',
      calendarPage_weekNav_ClassesThisWeekOneDay: 'Órád ezen a héten: %0 %1. (%2)',
      calendarPage_weekNav_ClassesThisWeekEmpty: 'Üres ez a heted! 🥳',
      calendarPage_weekNav_ClassesThisWeekLoading: 'Gondolkodunk... 🤔',
      calendarPage_weekNav_StudyWeek: '%0. oktatási hét',
      markbookPage_AverageDisplay: 'Átlagod: %0',
      markbookPage_AverageScholarshipDisplay: 'Ösztöndíj indexed: %0',
      markbookPage_NoGrades: 'nincs jegyed',
      markbookPage_Empty: '🤪Nincs Tantárgyad🤪',
      markbookPage_CompletedLine: 'Elvégezve',
      paymentPage_Empty: '😇Nem Tartozol😇',
      paymentPage_MoneyDisplay: '%0Ft',
      paymentPage_PaymentDeadlineTime: '(%0 nap van hátra)',
      paymentPage_PaymentMissedTime: '(%0 nappal lekésve)',
      periodPage_Empty: '🤩Szünet Van🤩',
      periodPage_Expired: 'Lejárt: ',
      periodPage_Starts: 'Kezdődik: ',
      periodPage_ActiveDays: '(%0 nap van hátra)',
      periodPage_StartDays: '(%0 nap múlva)',
      periodPage_ExpiredDays: '(%0 napja)',
      messagePage_SentBy: 'Küldte: %0',
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
      api_monthJul_Universal: 'july',
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
      api_daySun_Universal: 'Sunday',
      api_loadingScreenHintFriendly1_Universal: 'Your phone would go up in flames, if this was faster...',
      api_loadingScreenHintFriendly2_Universal: 'Still better, than the non existent Neptun mobile app...',
      api_loadingScreenHintFriendly3_Universal: 'Loading in any millennium now...',
      api_loadingScreenHintFriendly4_Universal: 'Theres a power outage at SDA informatics...',
      api_loadingScreenHintFriendly5_Universal: 'SDA informatics is an amazing company...',
      api_loadingScreenHintFriendly6_Universal: 'Did you know? "Neptun 2" was created in about 1 week...',
      api_loadingScreenHintFriendly7_Universal: 'Too slow? Send a complaint to SDA informatics...',
      api_loadingScreenHint1_Universal: 'The Neptun servers are working as hard az an average hungarian construction worker...',
      api_loadingScreenHint2_Universal: 'We are waiting until the CEO of SDA informatics drown in coffee...',
      api_loadingScreenHint3_Universal: 'Be patient, the servers are down, because a rat went into them...',
      api_loadingScreenHint4_Universal: 'Im more likely to believe, that there are penguins at the North pole, than SDA informatics has spent money on Neptun servers...',
      api_loadingScreenHint5_Universal: 'Neptun servers are so reliable, I would do my banking on them...',
      api_loadingScreenHint6_Universal: 'SDA meaning: Sok Dagadt Analfabéta, aka: Many Fat Analfabetics. They couldnt create a usable mobile app...',
      api_loadingScreenHint7_Universal: 'I would bet my house on that, you are still reading this, because it is still loading...',
      api_loadingScreenHintFriendlyMini1_Universal: 'Just a second...',
      api_loadingScreenHintFriendlyMini2_Universal: 'We are getting there...',
      api_loadingScreenHintFriendlyMini3_Universal: 'Easy does it...',
      api_loadingScreenHintFriendlyMini4_Universal: 'Its really loading something...',
      api_loadingScreenHintMini1_Universal: 'So, found it?...',
      api_loadingScreenHintMini2_Universal: 'Hold up! It cant do it that fast...',
      api_loadingScreenHintMini3_Universal: 'Forgot what you just read? Try taking B6 vitamins!...',
      api_generic_NoData: 'No Data',
      view_header_Calendar: 'Calendar',
      view_header_Messages: 'Messages',
      view_header_Payments: 'Payments',
      view_header_Periods: 'Periods',
      view_header_Subjects: 'Subjects',
      topheader_calendar_greetMessage_1to6: 'Merry midnight! 🍼',
      topheader_calendar_greetMessage_6to9: 'Good morning! ☕',
      topheader_calendar_greetMessage_9to13: 'Good day! 🍷',
      topheader_calendar_greetMessage_13to17: 'Good afternoon! 🥂',
      topheader_calendar_greetMessage_17to21: 'Good evening! 🍻',
      topheader_calendar_greetMessage_21to1: 'Good night! 🍹',
      topheader_subjects_CreditsInSemester: 'Your credits in this semester: %0🎖️',
      topheader_payments_TotalMoneySpent: 'You have spent %0Huf on university 💸',
      topheader_periods_ActiveText: 'Actual',
      topheader_periods_ExpiredText: 'Expired',
      topheader_periods_FutureText: 'Future',
      topheader_periods_MainHeader: '%0 %1, %2 %3, %4 %5 🗓️',
      topheader_messages_UnreadMessages: 'You have %0 unread messages 💌',
      topmenu_Greet: 'Hello %0! 👋',
      topmenu_LoginPlace: 'You are logged into here: 🔗\n%0',
      topmenu_buttons_Settings: '⚙ Settings',
      topmenu_buttons_SupportDev: '🎁 Support developer',
      topmenu_buttons_Bugreport: '🐞 Bugreport',
      topmenu_buttons_Logout: '🚪 Log out',
      topmenu_buttons_LogoutSuccessToast: 'You have logged out successfully! 🚪',
      calendarPage_FreeDay: '🥳Free Day!🥳',
      calendarPage_weekNav_ClassesThisWeekFull: 'Classes this week: %0 %1. - %2 %3.',
      calendarPage_weekNav_ClassesThisWeekOneDay: 'Class this week: %0 %1. (%2)',
      calendarPage_weekNav_ClassesThisWeekEmpty: 'This week is empty! 🥳',
      calendarPage_weekNav_ClassesThisWeekLoading: 'Thinking... 🤔',
      calendarPage_weekNav_StudyWeek: '%0. education week',
      markbookPage_AverageDisplay: 'Average: %0 %1',
      markbookPage_AverageScholarshipDisplay: 'Scholarship index: %0 %1',
      markbookPage_NoGrades: 'you have no grades',
      markbookPage_Empty: '🤪You dont have any subjects🤪',
      markbookPage_CompletedLine: 'Completed',
      paymentPage_Empty: '😇All payed😇',
      paymentPage_MoneyDisplay: '%0Huf',
      paymentPage_PaymentDeadlineTime: '(%0 days remaining)',
      paymentPage_PaymentMissedTime: '(%0 days since deadline)',
      periodPage_Empty: '🤩Break time🤩',
      periodPage_Expired: 'Expired: ',
      periodPage_Starts: 'Starts: ',
      periodPage_ActiveDays: '(%0 days remaining)',
      periodPage_StartDays: '(in %0 days)',
      periodPage_ExpiredDays: '(%0 days ago)',
      messagePage_SentBy: 'Sent by: %0',
    )});
    _hasInit = true;
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
      result = result.replaceAll('%$i', '${params[i].toString()}');
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

  final String api_loadingScreenHintFriendly1_Universal;
  final String api_loadingScreenHintFriendly2_Universal;
  final String api_loadingScreenHintFriendly3_Universal;
  final String api_loadingScreenHintFriendly4_Universal;
  final String api_loadingScreenHintFriendly5_Universal;
  final String api_loadingScreenHintFriendly6_Universal;
  final String api_loadingScreenHintFriendly7_Universal;

  final String api_loadingScreenHint1_Universal;
  final String api_loadingScreenHint2_Universal;
  final String api_loadingScreenHint3_Universal;
  final String api_loadingScreenHint4_Universal;
  final String api_loadingScreenHint5_Universal;
  final String api_loadingScreenHint6_Universal;
  final String api_loadingScreenHint7_Universal;

  final String api_loadingScreenHintFriendlyMini1_Universal;
  final String api_loadingScreenHintFriendlyMini2_Universal;
  final String api_loadingScreenHintFriendlyMini3_Universal;
  final String api_loadingScreenHintFriendlyMini4_Universal;

  final String api_loadingScreenHintMini1_Universal;
  final String api_loadingScreenHintMini2_Universal;
  final String api_loadingScreenHintMini3_Universal;

  final String api_generic_NoData;

  final String view_header_Calendar;
  final String view_header_Subjects;
  final String view_header_Payments;
  final String view_header_Periods;
  final String view_header_Messages;

  final String topheader_calendar_greetMessage_1to6;
  final String topheader_calendar_greetMessage_6to9;
  final String topheader_calendar_greetMessage_9to13;
  final String topheader_calendar_greetMessage_13to17;
  final String topheader_calendar_greetMessage_17to21;
  final String topheader_calendar_greetMessage_21to1;

  final String topheader_subjects_CreditsInSemester;

  final String topheader_payments_TotalMoneySpent;

  final String topheader_periods_ActiveText;
  final String topheader_periods_ExpiredText;
  final String topheader_periods_FutureText;
  final String topheader_periods_MainHeader;

  final String topheader_messages_UnreadMessages;

  final String topmenu_Greet;
  final String topmenu_LoginPlace;
  final String topmenu_buttons_Settings;
  final String topmenu_buttons_SupportDev;
  final String topmenu_buttons_Bugreport;
  final String topmenu_buttons_Logout;
  final String topmenu_buttons_LogoutSuccessToast;

  final String calendarPage_weekNav_StudyWeek;
  final String calendarPage_weekNav_ClassesThisWeekFull;
  final String calendarPage_weekNav_ClassesThisWeekOneDay;
  final String calendarPage_weekNav_ClassesThisWeekLoading;
  final String calendarPage_weekNav_ClassesThisWeekEmpty;
  final String calendarPage_FreeDay;

  final String markbookPage_AverageDisplay;
  final String markbookPage_AverageScholarshipDisplay;
  final String markbookPage_NoGrades;
  final String markbookPage_Empty;
  final String markbookPage_CompletedLine;

  final String paymentPage_Empty;
  final String paymentPage_MoneyDisplay;
  final String paymentPage_PaymentMissedTime;
  final String paymentPage_PaymentDeadlineTime;

  final String periodPage_Empty;
  final String periodPage_Expired;
  final String periodPage_Starts;
  final String periodPage_ExpiredDays;
  final String periodPage_StartDays;
  final String periodPage_ActiveDays;

  final String messagePage_SentBy;

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
    required this.api_loadingScreenHintFriendly1_Universal,
    required this.api_loadingScreenHintFriendly2_Universal,
    required this.api_loadingScreenHintFriendly3_Universal,
    required this.api_loadingScreenHintFriendly4_Universal,
    required this.api_loadingScreenHintFriendly5_Universal,
    required this.api_loadingScreenHintFriendly6_Universal,
    required this.api_loadingScreenHintFriendly7_Universal,
    required this.api_loadingScreenHint1_Universal,
    required this.api_loadingScreenHint2_Universal,
    required this.api_loadingScreenHint3_Universal,
    required this.api_loadingScreenHint4_Universal,
    required this.api_loadingScreenHint5_Universal,
    required this.api_loadingScreenHint6_Universal,
    required this.api_loadingScreenHint7_Universal,
    required this.api_loadingScreenHintFriendlyMini1_Universal,
    required this.api_loadingScreenHintFriendlyMini2_Universal,
    required this.api_loadingScreenHintFriendlyMini3_Universal,
    required this.api_loadingScreenHintFriendlyMini4_Universal,
    required this.api_loadingScreenHintMini1_Universal,
    required this.api_loadingScreenHintMini2_Universal,
    required this.api_loadingScreenHintMini3_Universal,
    required this.api_generic_NoData,
    required this.view_header_Calendar,
    required this.view_header_Messages,
    required this.view_header_Payments,
    required this.view_header_Periods,
    required this.view_header_Subjects,
    required this.topheader_calendar_greetMessage_1to6,
    required this.topheader_calendar_greetMessage_6to9,
    required this.topheader_calendar_greetMessage_9to13,
    required this.topheader_calendar_greetMessage_13to17,
    required this.topheader_calendar_greetMessage_17to21,
    required this.topheader_calendar_greetMessage_21to1,
    required this.topheader_subjects_CreditsInSemester,
    required this.topheader_payments_TotalMoneySpent,
    required this.topheader_periods_ActiveText,
    required this.topheader_periods_ExpiredText,
    required this.topheader_periods_FutureText,
    required this.topheader_periods_MainHeader,
    required this.topheader_messages_UnreadMessages,
    required this.topmenu_buttons_Bugreport,
    required this.topmenu_buttons_Logout,
    required this.topmenu_buttons_Settings,
    required this.topmenu_buttons_SupportDev,
    required this.topmenu_Greet,
    required this.topmenu_LoginPlace,
    required this.topmenu_buttons_LogoutSuccessToast,
    required this.calendarPage_FreeDay,
    required this.calendarPage_weekNav_ClassesThisWeekFull,
    required this.calendarPage_weekNav_ClassesThisWeekOneDay,
    required this.calendarPage_weekNav_StudyWeek,
    required this.calendarPage_weekNav_ClassesThisWeekEmpty,
    required this.calendarPage_weekNav_ClassesThisWeekLoading,
    required this.markbookPage_AverageDisplay,
    required this.markbookPage_AverageScholarshipDisplay,
    required this.markbookPage_NoGrades,
    required this.markbookPage_Empty,
    required this.markbookPage_CompletedLine,
    required this.paymentPage_Empty,
    required this.paymentPage_MoneyDisplay,
    required this.paymentPage_PaymentDeadlineTime,
    required this.paymentPage_PaymentMissedTime,
    required this.periodPage_ActiveDays,
    required this.periodPage_Empty,
    required this.periodPage_Expired,
    required this.periodPage_ExpiredDays,
    required this.periodPage_StartDays,
    required this.periodPage_Starts,
    required this.messagePage_SentBy
  });
}