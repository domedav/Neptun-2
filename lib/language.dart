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
      rootpage_setupPage_SelectLoginTypeHeader: 'Válassz bejelentkezési módot',
      rootpage_setupPage_InstitutesSelection: 'Intézmény választás',
      rootpage_setupPage_InstitutesSelectionDescription: 'Ez a legkényelmesebb opció. Egy szimpla lista, amiben meg tudod keresni az egyetemedet, viszont nem minden intézmény található meg a listában!',
      rootpage_setupPage_UrlLogin: 'Neptun URL',
      rootpage_setupPage_UrlLoginDescription: 'Ha nincs az iskolád a listában, akkor az egyetemed neptun URL-jét használva is be tudsz lépni. Nem minden egyetemmel működik!',
      rootpage_setupPage_AppProblemReporting: 'Probléma van az appal?\nÍrd meg nekem! 👉',
      instituteSelection_setupPage_LoadingText: 'Betöltés...',
      instituteSelection_setupPage_NoNetwork: 'Nincs internet...',
      instituteSelection_setupPage_SelectValidInstitute: 'Válassz ki egy érvényes egyetemet! 😡',
      instituteSelection_setupPage_SelectInstitute: 'Válassz intézményt',
      instituteSelection_setupPage_Search: 'Keresés',
      instituteSelection_setupPage_SearchNotFound: 'Nincs találat...',
      instituteSelection_setupPage_InstituteCantFindHelpText: 'Nem találod az iskolád a listában?',
      instituteSelection_setupPage_InstituteCantFindHelpTextDescription: 'A fenti listában szereplő elemek manuálisan lettek felvéve! 😅 Így előfordulhat, hogy egyes iskolák nincsenek benne a listában.\nJelentkezz be URL használatával, ha nem találod a sulid. 😉',
      any_setupPage_GoBack: 'Vissza',
      any_setupPage_ProceedLogin: 'Tovább',
      urlLogin_setupPage_InvalidUrl: 'Írj be egy érvényes neptun URL-t! 😡',
      urlLogin_setupPage_LoginViaURlHeader: 'Belépés URL-el',
      urlLogin_setupPage_InstituteNeptunUrl: 'Egyetem neptun URL-je',
      urlLogin_setupPage_InstituteNeptunUrlInvalid: 'Ez nem egy jó neptun URL! 😡\n\nValami ilyesmit másolj ide:\nhttps://neptun-ws01.uni-pannon.hu/hallgato/login.aspx 🤫',
      urlLogin_setupPage_WhereIsURLHelper: 'Hol találom meg az URL-t?',
      urlLogin_setupPage_WhereIsURLHelperDescription: 'Keresd meg weben az egyetemed neptun weboldalát és másold be ide a fenti linket. 🔗\n\nPld: https://neptun-ws01.uni-pannon.hu/hallgato/login.aspx',
      loginPage_setupPage_InvalidCredentials: 'Érvényes adatokat adj meg! 😡',
      loginPage_setupPage_LoginHeaderText: 'Jelentkezz be',
      loginPage_setupPage_ActivityCacheInvalidHelper: 'HIBA! Lépj egyet vissza!',
      loginPage_setupPage_NeptunCode: 'Neptun kód',
      loginPage_setupPage_Password: 'Jelszó',
      loginPage_setupPage_InvalidCredentialsEntered: 'Hibás felhasználónév vagy jelszó!',
      loginPage_setupPage_2faWarning: 'Ha két lépcsős azonosítás van a fiókodon, nem fogsz tudni bejelenzkezni!',
      loginPage_setupPage_2faWarningDescription: '❌ A Neptun2 a régi Neptun mobilapp API-jait használja, amiben nem volt 2 lépcsős azonosítás. Így, ha a fiókod 2 lépcsős azonosítással van védve, a Neptun2 nem fog tudni bejelentkeztetni.\n\n🤓 Viszont, ha kikapcsolod, hiba nélkül tudod használni a Neptun2-t.\nKikapcsolni a webes neptunban, a "Saját Adatok/Beállítások"-ban tudod.',
      loginPage_setupPage_LogInButton: 'Belépés',
      loginPage_setupPage_LoginInProgress: 'Bejelentkezés...',
      loginPage_setupPage_LoginInProgressSlow: 'Neptun szervereivel lehet problémák vannak...',
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
      api_noData_Universal: 'Nincs Adat',
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
      messagePage_Empty: '😥Nincs Üzeneted😥',
      popup_case0_GhostGradeHeader: '👻 Szellemjegy 👻',
      popup_case0_SelectGrade: 'Válassz jegyet...',
      popup_caseAll_OkButton: 'Ok',
      popup_case1_SettingsHeader: '⚙ Beállítások ⚙',
      popup_case1_settingOption1_FamilyFriendlyLoadingText: 'Szókimondó betöltőszövegek',
      popup_case1_settingOption1_FamilyFriendlyLoadingTextDescription: 'Ha bekapcsolod, lecseréli a betöltő szövegeket szókimondóra.',
      popup_case1_settingOption2_ExamNotifications: 'Vizsga értesítők',
      popup_case1_settingOption2_ExamNotificationsDescription: 'Vizsgaértesítő értesítéseket küld neked a vizsga előtti 2 hétben. Hasznos, ha szereted halogatni a tanulást, vagy szimplán feledékeny vagy.',
      popup_case1_settingOption3_ClassNotifications: 'Órák előtti értesítések',
      popup_case1_settingOption3_ClassNotificationsDescription: 'Órák kezdete előtt 10 percel; 5 percel; és a kezdetük időpontjában, küld neked értesítést, hogy ne késd le őket. Hasznos, ha tudni akarod milyen órád lesz, anélkül, hogy a telódon lecsekkolnád. (pl: Okosórád van, és értesítésként látod a kövi órádat.)',
      popup_case1_settingOption4_PaymentNotifications: 'Befizetés értesítők',
      popup_case1_settingOption4_PaymentNotificationsDescription: 'Ha van befizetnivalód, értesíteni fog az app, minden nap, amíg nem fizeted be. Hasznos, ha feledékeny vagy, vagy nem szeretnéd lekésni a határidőt.',
      popup_case1_settingOption5_PeriodsNotifications: 'Időszak értesítők',
      popup_case1_settingOption5_PeriodsNotificationsDescription: 'Ha valamilyen új időszak lesz, értesíteni fog az app, az adott időszak előtt 1 nappal, és aznap fogsz értesítést kapni. Hasznos, ha nem akarsz lemaradni az adott időszakokról. (pl: tárgyfelvételi időszak)',
      popup_case1_settingOption6_AppHaptics: 'App haptika',
      popup_case1_settingOption6_AppHapticsDescription: 'Beállíthatod, hogy kapj haptikai visszajelzést az appban történő dolgokról. (Rezgés)',
      popup_case1_settingOption7_WeekOffset: 'Tanulmányi hét eltolás',
      popup_case1_settingOption7_WeekOffsetDescription: 'Ha nem jól írja ki az app az aktuális heted, itt át tudod állítani!',
      popup_case1_settingOption7_WeekOffsetAuto: 'Auto',
      popup_case1_settingBottomText_InstallOrigin: '%0 - Telepítve innen: ',
      popup_case1_settingBottomText_InstallOrigin3rdParty: 'Csomagtelepítő',
      popup_case1_settingBottomText_InstallOriginGPlay: 'Play Áruház',
      popup_case2_RateAppPopup: '⭐ Értékeld Az Appot! ⭐',
      popup_case2_RateAppPopupDescription: 'Tetszik az app? Esetleg nem? Értékeld a Play Áruházban!\n10 másodpercet vesz igénybe, és ezzel információt nyújthatsz nekem, és másoknak.',
      popup_case2_RateButton: 'Értékelem',
      popup_case3_MessagesHeader: '💌 Üzenet 💌',
      clickableText_OnCopy: 'Másolva! 📋',
      popup_case4_SubjectInfo: '📢 Óra Infó 📢',
      popup_case4_TeachedBy: 'Tanítja:',
      popup_case4_5_SubjectCode: 'Tárgykód:',
      popup_case4_5_SubjectLocation: 'Helyszín:',
      popup_case4_SubjectStartTime: 'Órakezdés:',
      popup_case5_ExamInfo: '⚠️ Vizsga Infó ⚠️',
      popup_case5_ExamStartTime: 'Vizsgaidőpont:',
      popup_case6_AccountError: '🤷 Probléma van a fiókoddal 🤷',
      popup_case6_AccountErrorDescription: 'Úgy tűnik nem tudjuk lekérni az adatokat a neptunodból.\nKérlek jelentkezz ki, majd vissza.',
      popup_case6_AccountErrorLogoutButton: 'Kijelentkezés',
    )});
    //---
    _languages.addAll({_supportedLanguages[1]: LanguagePack(
        rootpage_setupPage_SelectLoginTypeHeader: 'Select login method',
      rootpage_setupPage_InstitutesSelection: 'Institute selection',
      rootpage_setupPage_InstitutesSelectionDescription: 'This is the simplest way. It is a list, where you can search for your university, however not all institutes can be found here!',
      rootpage_setupPage_UrlLogin: 'Neptun URL',
      rootpage_setupPage_UrlLoginDescription: 'If you cant find your university inside the list, you can enter the neptun URL of your school to log in. This might not work with all universities!',
      rootpage_setupPage_AppProblemReporting: 'Is there a problem with the app?\nTell me! 👉',
      instituteSelection_setupPage_LoadingText: 'Loading...',
      instituteSelection_setupPage_NoNetwork: 'No network...',
      instituteSelection_setupPage_SelectValidInstitute: 'Select a valid institute! 😡',
      instituteSelection_setupPage_SelectInstitute: 'Select institute',
      instituteSelection_setupPage_Search: 'Search',
      instituteSelection_setupPage_SearchNotFound: 'Nothing found...',
      instituteSelection_setupPage_InstituteCantFindHelpText: 'Cant find your school in the list?',
      instituteSelection_setupPage_InstituteCantFindHelpTextDescription: 'Items in the list above were added manually! 😅 It is possible, that some institutes are missing from it.\nYou can login via URL if you cant find your school. 😉',
      any_setupPage_GoBack: 'Back',
      any_setupPage_ProceedLogin: 'Proceed',
      urlLogin_setupPage_InvalidUrl: 'Enter a valid neptun URL! 😡',
      urlLogin_setupPage_LoginViaURlHeader: 'Login via URL',
      urlLogin_setupPage_InstituteNeptunUrl: 'Institute neptun URL',
      urlLogin_setupPage_InstituteNeptunUrlInvalid: 'This is not a valid neptun URL! 😡\n\nPaste something similar here:\nhttps://neptun-ws01.uni-pannon.hu/hallgato/login.aspx 🤫',
      urlLogin_setupPage_WhereIsURLHelper: 'Where do I find the URL?',
      urlLogin_setupPage_WhereIsURLHelperDescription: 'Go to your schools neptun website, and paste the link from up top. 🔗\n\nEx: https://neptun-ws01.uni-pannon.hu/hallgato/login.aspx',
      loginPage_setupPage_InvalidCredentials: 'Provide valid credentials! 😡',
      loginPage_setupPage_LoginHeaderText: 'Log in',
      loginPage_setupPage_ActivityCacheInvalidHelper: 'ERROR! Please go back!',
      loginPage_setupPage_NeptunCode: 'Neptun code',
      loginPage_setupPage_Password: 'Password',
      loginPage_setupPage_InvalidCredentialsEntered: 'Invalid username or password!',
      loginPage_setupPage_2faWarning: 'If you have multi factor authentication enabled on your account, you wont be able to login!',
      loginPage_setupPage_2faWarningDescription: '❌ Neptun2 uses the old Neptun mobileapp API, which didnt contain multi factor authentication. If your account if protected by it, you wont be able to login via Neptun2.\n\n🤓 But you can turn it off, and you will be able to use Neptun2 without a problem.\nTo turn it off, go to "My Data/Settings" in neptun web.',
      loginPage_setupPage_LogInButton: 'Login',
      loginPage_setupPage_LoginInProgress: 'Logging in...',
      loginPage_setupPage_LoginInProgressSlow: 'Neptun servers are having a hard time...',
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
      api_noData_Universal: 'No Data',
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
      topheader_periods_ActiveText: 'Active',
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
      messagePage_Empty: '😥You dont have any messages😥',
      popup_case0_GhostGradeHeader: '👻 Ghost grade 👻',
      popup_case0_SelectGrade: 'Select grade...',
      popup_caseAll_OkButton: 'Ok',
      popup_case1_SettingsHeader: '⚙ Settings ⚙',
      popup_case1_settingOption1_FamilyFriendlyLoadingText: 'Outspoken loading texts',
      popup_case1_settingOption1_FamilyFriendlyLoadingTextDescription: 'If you turn this on, loading texts will become outspoken ones.',
      popup_case1_settingOption2_ExamNotifications: 'Exam notifications',
      popup_case1_settingOption2_ExamNotificationsDescription: 'Exam notifications will send you notifications in the span of 2 weeks beforehand. It is useful, if you like procrastinating studying, or you tend to forget.',
      popup_case1_settingOption3_ClassNotifications: 'Notifications before classes',
      popup_case1_settingOption3_ClassNotificationsDescription: 'It will send you notifications 10 minutes; 5 minutes; and at the start of the class, so you wont miss them. Useful if you want to know what class are you going to have beforehand, without the need to check on your phone (ex: You have a smartwatch)',
      popup_case1_settingOption4_PaymentNotifications: 'Payment notifications',
      popup_case1_settingOption4_PaymentNotificationsDescription: 'If you have payments due, the app will be notifying you every day, until they are paid. Useful if you tend to forget, or just dont want to miss a due date.',
      popup_case1_settingOption5_PeriodsNotifications: 'Period notifications',
      popup_case1_settingOption5_PeriodsNotificationsDescription: 'If a new period is about to become active, the app will notify you, 1 day before the given period, and the they when they are active. Useful if you dont want to miss something important tied to periods. (ex: class registration period)',
      popup_case1_settingOption6_AppHaptics: 'App haptics',
      popup_case1_settingOption6_AppHapticsDescription: 'You can set, if you want the app to give you haptic feedback. (Vibrate)',
      popup_case1_settingOption7_WeekOffset: 'Study week offset',
      popup_case1_settingOption7_WeekOffsetDescription: 'If you have issues with the current study week, you can offset it to the correct week!',
      popup_case1_settingOption7_WeekOffsetAuto: 'Auto',
      popup_case1_settingBottomText_InstallOrigin: '%0 - Installed from: ',
      popup_case1_settingBottomText_InstallOrigin3rdParty: 'Package Installer',
      popup_case1_settingBottomText_InstallOriginGPlay: 'Google Play',
      popup_case2_RateAppPopup: '⭐ Rate The App! ⭐',
      popup_case2_RateAppPopupDescription: 'Do you like the app? Do you hate it? Rate it on Google Play!\nIt takes about 10 seconds, and it gives me, and other users feedback.',
      popup_case2_RateButton: 'Rate it',
      popup_case3_MessagesHeader: '💌 Message 💌',
      clickableText_OnCopy: 'Copied! 📋',
      popup_case4_SubjectInfo: '📢 Subject Info 📢',
      popup_case4_TeachedBy: 'Taught by:',
      popup_case4_5_SubjectCode: 'Subject code:',
      popup_case4_5_SubjectLocation: 'Location:',
      popup_case4_SubjectStartTime: 'Subject start time:',
      popup_case5_ExamInfo: '⚠️ Exam Info ⚠️',
      popup_case5_ExamStartTime: 'Exam start time:',
      popup_case6_AccountError: '🤷 There is an issue with your account 🤷',
      popup_case6_AccountErrorDescription: 'It seems like we cant fetch data from your neptun.\nPlease log out, and log right back in.',
      popup_case6_AccountErrorLogoutButton: 'Logout',
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
      return _languages[_supportedLanguages[1]]!; // default to english, if user device lang is not supported
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
  final String rootpage_setupPage_SelectLoginTypeHeader;
  final String rootpage_setupPage_InstitutesSelection;
  final String rootpage_setupPage_InstitutesSelectionDescription;
  final String rootpage_setupPage_UrlLogin;
  final String rootpage_setupPage_UrlLoginDescription;
  final String rootpage_setupPage_AppProblemReporting;

  final String instituteSelection_setupPage_LoadingText;
  final String instituteSelection_setupPage_NoNetwork;
  final String instituteSelection_setupPage_SelectValidInstitute;
  final String instituteSelection_setupPage_SelectInstitute;
  final String instituteSelection_setupPage_Search;
  final String instituteSelection_setupPage_SearchNotFound;
  final String instituteSelection_setupPage_InstituteCantFindHelpText;
  final String instituteSelection_setupPage_InstituteCantFindHelpTextDescription;

  final String any_setupPage_GoBack;
  final String any_setupPage_ProceedLogin;

  final String urlLogin_setupPage_InvalidUrl;
  final String urlLogin_setupPage_LoginViaURlHeader;
  final String urlLogin_setupPage_InstituteNeptunUrl;
  final String urlLogin_setupPage_InstituteNeptunUrlInvalid;
  final String urlLogin_setupPage_WhereIsURLHelper;
  final String urlLogin_setupPage_WhereIsURLHelperDescription;

  final String loginPage_setupPage_InvalidCredentials;
  final String loginPage_setupPage_LoginHeaderText;
  final String loginPage_setupPage_ActivityCacheInvalidHelper;
  final String loginPage_setupPage_NeptunCode;
  final String loginPage_setupPage_Password;
  final String loginPage_setupPage_InvalidCredentialsEntered;
  final String loginPage_setupPage_2faWarning;
  final String loginPage_setupPage_2faWarningDescription;
  final String loginPage_setupPage_LogInButton;
  final String loginPage_setupPage_LoginInProgress;
  final String loginPage_setupPage_LoginInProgressSlow;

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

  final String api_noData_Universal;

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
  final String messagePage_Empty;

  final String popup_case0_GhostGradeHeader;
  final String popup_caseAll_OkButton;
  final String popup_case0_SelectGrade;

  final String popup_case1_SettingsHeader;
  final String popup_case1_settingOption1_FamilyFriendlyLoadingText;
  final String popup_case1_settingOption1_FamilyFriendlyLoadingTextDescription;
  final String popup_case1_settingOption2_ExamNotifications;
  final String popup_case1_settingOption2_ExamNotificationsDescription;
  final String popup_case1_settingOption3_ClassNotifications;
  final String popup_case1_settingOption3_ClassNotificationsDescription;
  final String popup_case1_settingOption4_PaymentNotifications;
  final String popup_case1_settingOption4_PaymentNotificationsDescription;
  final String popup_case1_settingOption5_PeriodsNotifications;
  final String popup_case1_settingOption5_PeriodsNotificationsDescription;
  final String popup_case1_settingOption6_AppHaptics;
  final String popup_case1_settingOption6_AppHapticsDescription;
  final String popup_case1_settingOption7_WeekOffset;
  final String popup_case1_settingOption7_WeekOffsetDescription;
  final String popup_case1_settingOption7_WeekOffsetAuto;
  final String popup_case1_settingBottomText_InstallOrigin;
  final String popup_case1_settingBottomText_InstallOriginGPlay;
  final String popup_case1_settingBottomText_InstallOrigin3rdParty;

  final String popup_case2_RateAppPopup;
  final String popup_case2_RateAppPopupDescription;
  final String popup_case2_RateButton;

  final String popup_case3_MessagesHeader;
  final String clickableText_OnCopy;

  final String popup_case4_SubjectInfo;
  final String popup_case4_TeachedBy;
  final String popup_case4_5_SubjectCode;
  final String popup_case4_5_SubjectLocation;
  final String popup_case4_SubjectStartTime;

  final String popup_case5_ExamInfo;
  final String popup_case5_ExamStartTime;

  final String popup_case6_AccountError;
  final String popup_case6_AccountErrorDescription;
  final String popup_case6_AccountErrorLogoutButton;

  LanguagePack({
    required this.rootpage_setupPage_SelectLoginTypeHeader,
    required this.rootpage_setupPage_InstitutesSelection,
    required this.rootpage_setupPage_InstitutesSelectionDescription,
    required this.rootpage_setupPage_UrlLogin,
    required this.rootpage_setupPage_UrlLoginDescription,
    required this.rootpage_setupPage_AppProblemReporting,
    required this.instituteSelection_setupPage_LoadingText,
    required this.instituteSelection_setupPage_NoNetwork,
    required this.instituteSelection_setupPage_SelectValidInstitute,
    required this.instituteSelection_setupPage_SelectInstitute,
    required this.instituteSelection_setupPage_Search,
    required this.instituteSelection_setupPage_SearchNotFound,
    required this.instituteSelection_setupPage_InstituteCantFindHelpText,
    required this.instituteSelection_setupPage_InstituteCantFindHelpTextDescription,
    required this.any_setupPage_GoBack,
    required this.any_setupPage_ProceedLogin,
    required this.urlLogin_setupPage_InvalidUrl,
    required this.urlLogin_setupPage_LoginViaURlHeader,
    required this.urlLogin_setupPage_InstituteNeptunUrl,
    required this.urlLogin_setupPage_InstituteNeptunUrlInvalid,
    required this.urlLogin_setupPage_WhereIsURLHelper,
    required this.urlLogin_setupPage_WhereIsURLHelperDescription,
    required this.loginPage_setupPage_InvalidCredentials,
    required this.loginPage_setupPage_LoginHeaderText,
    required this.loginPage_setupPage_ActivityCacheInvalidHelper,
    required this.loginPage_setupPage_NeptunCode,
    required this.loginPage_setupPage_Password,
    required this.loginPage_setupPage_InvalidCredentialsEntered,
    required this.loginPage_setupPage_2faWarning,
    required this.loginPage_setupPage_2faWarningDescription,
    required this.loginPage_setupPage_LogInButton,
    required this.loginPage_setupPage_LoginInProgress,
    required this.loginPage_setupPage_LoginInProgressSlow,
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
    required this.api_noData_Universal,
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
    required this.messagePage_SentBy,
    required this.messagePage_Empty,
    required this.popup_case0_GhostGradeHeader,
    required this.popup_case0_SelectGrade,
    required this.popup_caseAll_OkButton,
    required this.popup_case1_settingBottomText_InstallOrigin,
    required this.popup_case1_settingBottomText_InstallOrigin3rdParty,
    required this.popup_case1_settingBottomText_InstallOriginGPlay,
    required this.popup_case1_settingOption1_FamilyFriendlyLoadingText,
    required this.popup_case1_settingOption1_FamilyFriendlyLoadingTextDescription,
    required this.popup_case1_settingOption2_ExamNotifications,
    required this.popup_case1_settingOption2_ExamNotificationsDescription,
    required this.popup_case1_settingOption3_ClassNotifications,
    required this.popup_case1_settingOption3_ClassNotificationsDescription,
    required this.popup_case1_settingOption4_PaymentNotifications,
    required this.popup_case1_settingOption4_PaymentNotificationsDescription,
    required this.popup_case1_settingOption5_PeriodsNotifications,
    required this.popup_case1_settingOption5_PeriodsNotificationsDescription,
    required this.popup_case1_settingOption6_AppHaptics,
    required this.popup_case1_settingOption6_AppHapticsDescription,
    required this.popup_case1_settingOption7_WeekOffset,
    required this.popup_case1_settingOption7_WeekOffsetDescription,
    required this.popup_case1_settingOption7_WeekOffsetAuto,
    required this.popup_case1_SettingsHeader,
    required this.popup_case2_RateAppPopup,
    required this.popup_case2_RateAppPopupDescription,
    required this.popup_case2_RateButton,
    required this.popup_case3_MessagesHeader,
    required this.clickableText_OnCopy,
    required this.popup_case4_5_SubjectCode,
    required this.popup_case4_5_SubjectLocation,
    required this.popup_case4_SubjectStartTime,
    required this.popup_case4_SubjectInfo,
    required this.popup_case4_TeachedBy,
    required this.popup_case5_ExamInfo,
    required this.popup_case5_ExamStartTime,
    required this.popup_case6_AccountError,
    required this.popup_case6_AccountErrorDescription,
    required this.popup_case6_AccountErrorLogoutButton
  });
}