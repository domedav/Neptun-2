import 'dart:async';
import 'dart:developer' as debug;
import 'dart:io';
import 'dart:ui';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:neptun2/MailElements/mail_element_widget.dart';
import 'package:neptun2/notifications.dart';
import 'package:neptun2/Misc/emojirich_text.dart';
import 'package:neptun2/Misc/popup.dart';
import 'package:neptun2/PaymentsElements/payment_element_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../API/api_coms.dart' as api;
import '../haptics.dart';
import '../storage.dart' as storage;
import '../TimetableElements/timetable_element_widget.dart' as t_table;
import '../MarkbookElements/markbook_element_widget.dart' as mbook;
import '../PeriodsElements/periods_element_widget.dart' as priods;
import '../Navigator/bottomnavigator.dart' as bottomnav;
import '../Navigator/topnavigator.dart' as topnav;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../Pages/startup_page.dart' as root_page;

class HomePage extends StatefulWidget{
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin{

  double _fbPosX = 0;
  double _fbPosY = 0;
  bool _fbNeedAnimate = false;

  static late HomePageState _instance;
  HomePageState(){
    _instance = this;
  }

  static void showBlurPopup(bool b){
    _instance.setBlurComplex(b);
  }

  bool _showBlur = false;
  void setBlur(bool state){
    setState(() {
      _showBlur = state;
    });
  }

  late AnimationController blurController;
  late Animation<double> blurAnimation;

  void setBlurComplex(bool state){
    setState(() {
      if(state) {
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: Color.fromRGBO(0x0C, 0x0C, 0x0C, 1.0), // navigation bar color
            statusBarColor: Color.fromRGBO(0x1A, 0x1A, 0x1A, 1.0), // status bar color
        ));
        blurController.forward();
        _showBlur = true;
        return;
      }
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color.fromRGBO(0x22, 0x22, 0x22, 1.0), // navigation bar color
        statusBarColor: Color.fromRGBO(0x22, 0x22, 0x22, 1.0), // status bar color
      ));
      blurController.reverse().whenComplete((){
        setState(() {
          _showBlur = false;
        });
      });
    });
  }

  late List<api.CalendarEntry> calendarEntries = <api.CalendarEntry>[].toList();
  late List<api.Subject> markbookEntries = <api.Subject>[].toList();
  late List<api.CashinEntry> paymentsEntries = <api.CashinEntry>[].toList();
  late List<api.PeriodEntry> periodEntries = <api.PeriodEntry>[].toList();
  late List<api.MailEntry> mailEntries = <api.MailEntry>[].toList();

  late final List<Widget> mondayCalendar = <Widget>[].toList();
  late final List<Widget> tuesdayCalendar = <Widget>[].toList();
  late final List<Widget> wednessdayCalendar = <Widget>[].toList();
  late final List<Widget> thursdayCalendar = <Widget>[].toList();
  late final List<Widget> fridayCalendar = <Widget>[].toList();
  late final List<Widget> saturdayCalendar = <Widget>[].toList();
  late final List<Widget> sundayCalendar = <Widget>[].toList();

  late final List<Widget> markbookList = <Widget>[].toList();

  late final List<Widget> paymentsList = <Widget>[].toList();
  late final List<Widget> periodList = <Widget>[].toList();
  late final List<Widget> mailList = <Widget>[].toList();

  late final LinkedScrollControllerGroup bottomnavScrollCntroller;
  late final ScrollController bottomnavController;

  late final TextEditingController settingsUserWeekOffset;
  late int settingsUserWeekOffsetPrev;
  String prevSettingsUserWeekOffset = '';
  static TextEditingController getUserWeekOffsetTextController(){
    return _instance.settingsUserWeekOffset;
  }
  static Timer? settingsUserWeekOffsetPeriodicLooper = null;

  bool canDoCalendarPaging = false;
  int weeksSinceStart = 1;
  int currentWeekOffset = 1;
  late TabController calendarTabController;
  int currentView = 0;
  String calendarGreetText = "";

  int totalCredits = 0;
  int totalMoney = 0;
  double totalAvg = 0;
  double totalAvg30 = 0;

  int currentSemester = -1;
  int countActivePeriods = 0;
  int countFuturePeriods = 0;
  int countExpiredPeriods = 0;

  int unreadMailCount = 0;
  int totalMailCount = 0;
  int allLoadedMailCount = 0;

  double bottomNavSwitchValue = 0.0;
  bool bottomNavCanNavigate = true;
  static const int maxBottomNavWidgets = 5;

  double calendarWeekSwitchValue = 0.0;
  bool calendarWeekCanNavigate = true;

  @override
  void initState() {
    super.initState();

    FlutterNativeSplash.remove();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color.fromRGBO(0x22, 0x22, 0x22, 1.0), // navigation bar color
      statusBarColor: Color.fromRGBO(0x22, 0x22, 0x22, 1.0), // status bar color
    ));

    api.Generic.setupDaylightSavingsTime();

    if(Platform.isAndroid){
      Future.delayed(Duration.zero, ()async{
        tz.initializeTimeZones();
        final String timeZone = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(timeZone));
      });
    }

    if(Platform.isAndroid && storage.DataCache.getIsInstalledFromGPlay() != 0){
      Future.delayed(const Duration(seconds: 3), ()async{
        final cacheTime = await storage.getInt('UpdateCacheTime') ?? -1;
        if(cacheTime <= 0){ // fresh app version
          storage.saveInt('UpdateCacheTime', DateTime.now().microsecondsSinceEpoch);
          return;
        }

        if((DateTime.now().millisecondsSinceEpoch - cacheTime) > const Duration(hours: 24).inMilliseconds || // once a day update check
        await Connectivity().checkConnectivity() == ConnectivityResult.none) // only check for updates, if there is internet
        {return;}

        final appupdateInfo = await InAppUpdate.checkForUpdate();
        storage.saveInt('UpdateCacheTime', DateTime.now().microsecondsSinceEpoch); // save last checked update time
        if(appupdateInfo.updateAvailability == UpdateAvailability.updateAvailable){ // has new version
          AppHaptics.attentionImpact();
          await InAppUpdate.startFlexibleUpdate().then((value) async { // install update
            await InAppUpdate.completeFlexibleUpdate();
          });
        }
      });
    }

    bottomnavScrollCntroller = LinkedScrollControllerGroup();
    bottomnavController = bottomnavScrollCntroller.addAndGet();

    final userWeekOffserValue = storage.DataCache.getUserWeekOffset()!;
    settingsUserWeekOffset = TextEditingController(text: (userWeekOffserValue == 0 ? '' : userWeekOffserValue.toString()));
    prevSettingsUserWeekOffset = settingsUserWeekOffset.text;
    settingsUserWeekOffsetPrev = storage.DataCache.getUserWeekOffset()!;
    settingsUserWeekOffset.addListener(() {
      if(settingsUserWeekOffset.text != prevSettingsUserWeekOffset){
        changedSettingsUserWeekOffset = true;
        settingsUserWeekOffsetSetup();
      }
    });

    _fbController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fbTween = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fbController, curve: Curves.decelerate),
    );

    blurController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 350),
    );
    blurAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: blurController, curve: Curves.linear),
    );

    currentMailPageController = ScrollController();
    currentMailPageController.addListener(() {
      //debug.log(currentMailPageController.position.atEdge.toString() + " " + currentMailPageController.position.userScrollDirection.toString());
      if(currentMailPageController.position.atEdge && currentMailPageController.position.userScrollDirection == ScrollDirection.reverse && allLoadedMailCount < totalMailCount){
        if(currentMailLoadingDebounce){
          return;
        }
        currentMailLoadingDebounce = true;
        Future.delayed(Duration.zero, ()async{
          setState((){
            currentMailPage++;
            mailList.add(Column(
              children: [
                const CircularProgressIndicator(
                  color: Colors.white,
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
                Text(
                 api.Generic.randomLoadingCommentMini(storage.DataCache.getNeedFamilyFriendlyComments()!),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.4),
                    fontSize: 11,
                    fontWeight: FontWeight.w300
                  ),
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 8)),
              ],
            ),);
          });
          await fetchMails(force: true);
          /*mailList.add(Container(
            height: 1,
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(horizontal: 30),
            color: Colors.white.withOpacity(.3),
          ));*/
          setupMails(clear: true);
        }).whenComplete((){
          currentMailLoadingDebounce = false;
        });
      }
    });

    AppNotifications.initialize();
    Future.delayed(Duration.zero, ()async{
      if(storage.DataCache.getHasCachedFirstWeekEpoch()!){
        return;
      }
      final firstWeekOfSemester = await api.InstitutesRequest.getFirstStudyweek();
      storage.DataCache.setHasCachedFirstWeekEpoch(1);
      await storage.DataCache.setFirstWeekEpoch(firstWeekOfSemester);
    }).whenComplete((){
      Future.delayed(const Duration(seconds: 1), (){
        setState(() {weeksSinceStart = calcPassedWeeks();});
      });
    });

    Future.delayed(Duration.zero,() async{
      await AppNotifications.cancelScheduledNotifs();
    }).whenComplete((){
      Future.delayed(Duration.zero, () async{
        await fetchCalendar();
      }).then((value) async {
        if(storage.DataCache.getNeedExamNotifications()!){
          Future.delayed(Duration.zero,() async{
            if(!storage.DataCache.getHasNetwork()){
              return;
            }
            await _skimForExams();
          });
        }
        setupCalendar(true);
      });

      Future.delayed(Duration.zero, () async{
        await fetchMarkbook();
      }).then((value) {
        setupMarkbook();
      });

      Future.delayed(Duration.zero, () async{
        await fetchPayments();
      }).then((value) {
        setupPayments();
      });

      Future.delayed(Duration.zero, () async{
        await fetchPeriods();
      }).then((value) {
        setupPeriods();
      });

      Future.delayed(Duration.zero, () async{
        await fetchMails();
      }).then((value) {
        setupMails();
      });
    });

    setupCalendarGreetText();
    setupCalendarController(true, true);

    if(storage.DataCache.getAnalyticsFirstAppOpenTime()! == 0){
      storage.DataCache.setAnalyticsFirstAppOpenTime(DateTime.now().millisecondsSinceEpoch);
    }

    Future.delayed(const Duration(seconds: 2), ()async{
      final pinfo = await PackageInfo.fromPlatform();
      if(pinfo.installerStore != 'com.android.vending'){ // cant rate
        return;
      }

      /*await storage.DataCache.setAnalyticsRateNudgedAmount(0);
      await storage.DataCache.setAnalyticsHasRatedApp(0);
      await storage.DataCache.setAnalyticsNextRatePopupTime(0);*/

      if(storage.DataCache.getAnalyticsNextRatePopupTime()! == 0){
        final appUsedDays = Duration(milliseconds: DateTime.now().millisecondsSinceEpoch - storage.DataCache.getAnalyticsFirstAppOpenTime()!).inDays;
        await storage.DataCache.setAnalyticsNextRatePopupTime(DateTime.now().add(Duration(days: 2 + (appUsedDays > 30 ? 10 : appUsedDays / 3).round())).millisecondsSinceEpoch);
      }

      if(storage.DataCache.getAnalyticsHasRatedApp()! || DateTime.now().millisecondsSinceEpoch < storage.DataCache.getAnalyticsNextRatePopupTime()! || storage.DataCache.getAnalyticsRateNudgedAmount()! >= 5){
        return;
      }

      final appUsedDays = Duration(milliseconds: DateTime.now().millisecondsSinceEpoch - storage.DataCache.getAnalyticsFirstAppOpenTime()!).inDays;
      await storage.DataCache.setAnalyticsNextRatePopupTime(DateTime.now().add(Duration(days: 2 + (appUsedDays > 30 ? 10 : appUsedDays / 3).round())).millisecondsSinceEpoch);

      final nudge = storage.DataCache.getAnalyticsRateNudgedAmount()!;
      await storage.DataCache.setAnalyticsRateNudgedAmount(nudge + 1);

      PopupWidgetHandler(mode: 2, callback: (_)async{
        //only called, when the button is pressed
        if(!Platform.isAndroid){
          return;
        }
        launchUrl(Uri.parse('market://details?id=com.domedav.neptun2'), mode: LaunchMode.externalNonBrowserApplication);
        await storage.DataCache.setAnalyticsHasRatedApp(1);
      });
      PopupWidgetHandler.doPopup(context);
    });

    Future.delayed(const Duration(seconds: 1), (){
      final size = MediaQuery.of(context).size;

      setState(() {
        _fbPosX = size.width - 90;
        _fbPosY = size.height - 140;
      });
    });

    Future.delayed(Duration(seconds: 5), ()async{
      final hasConnection = storage.DataCache.getHasNetwork();
      final isLoggedIn = storage.DataCache.getHasLogin()!;

      if(!hasConnection || !isLoggedIn){
        return;
      }

      final username = storage.DataCache.getUsername()!;
      final password = storage.DataCache.getPassword()!;
      final url = storage.DataCache.getInstituteUrl()!;

      final result = await api.InstitutesRequest.validateLoginCredentialsUrl(url, username, password);
      if(result){
        return;
      }

      PopupWidgetHandler(mode: 6, callback: (_){
        userUnavailableAccountLogout();
      }, onCloseCallback: (){
        userUnavailableAccountLogout();
      });
      PopupWidgetHandler.doPopup(context);
    });
  }

  void userUnavailableAccountLogout(){
    Future.delayed(Duration.zero, ()async{
      await storage.DataCache.dataWipe();
      await AppNotifications.cancelScheduledNotifs();
    }).whenComplete((){
      Navigator.popUntil(context, (route) => route.willHandlePopInternally);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const root_page.Splitter()),
      );
    });
  }

  bool changedSettingsUserWeekOffset = false;

  void settingsUserWeekOffsetSetup(){
    if(settingsUserWeekOffset.text == '-'){
      return;
    }
    var newVal = int.tryParse(settingsUserWeekOffset.text);
    var correctedVal = 0;
    if(newVal == null || newVal == 0){
      settingsUserWeekOffset.text = '';
      prevSettingsUserWeekOffset = settingsUserWeekOffset.text;
      Future.delayed(Duration.zero, ()async{
        await storage.DataCache.setUserWeekOffset(correctedVal);
      });
      return;
    }
    correctedVal = clampDouble(newVal.toDouble(), -calcPassedWeekOffsetless().toDouble(), 51 - calcPassedWeekOffsetless().toDouble()).toInt();
    settingsUserWeekOffset.text = correctedVal.toString();
    settingsUserWeekOffset.text = correctedVal.toString();
    prevSettingsUserWeekOffset = settingsUserWeekOffset.text;
    Future.delayed(Duration.zero, ()async{
      await storage.DataCache.setUserWeekOffset(correctedVal);
    });
  }

  static void settingsUserWeekOffsetAdd(int val){
    _instance.changedSettingsUserWeekOffset = true;
    final oldVal = storage.DataCache.getUserWeekOffset()!;
    var correctedVal = oldVal + val;
    correctedVal = clampDouble(correctedVal.toDouble(), -_instance.calcPassedWeekOffsetless().toDouble(), 51 - _instance.calcPassedWeekOffsetless().toDouble()).toInt();
    _instance.settingsUserWeekOffset.text = correctedVal.toString();
    _instance.prevSettingsUserWeekOffset = _instance.settingsUserWeekOffset.text;
    Future.delayed(Duration.zero, ()async{
      await storage.DataCache.setUserWeekOffset(correctedVal);
    });
  }

  static void settingsUserWeekOffsetChangeDetect(){
    _instance._settingsUserWeekOffsetChangeDetect();
  }
  void _settingsUserWeekOffsetChangeDetect(){
    final currentOffset = storage.DataCache.getUserWeekOffset()!;
    if(settingsUserWeekOffsetPrev != currentOffset){
      settingsUserWeekOffsetPrev = currentOffset;
      Future.delayed(Duration.zero,() async{
        await storage.DataCache.setHasCachedCalendar(0);
        await AppNotifications.cancelScheduledNotifs();
      }).whenComplete(()async{
        await onCalendarRefresh(false);
      });
    }
  }

  void setupCalendarGreetText(){
    final currentTimeHour = DateTime.now().hour;
    if(currentTimeHour > 1 && currentTimeHour <= 6){
      setState(() {
        calendarGreetText = "Boldog hajnalt! 🍼";
      });
    }
    else if(currentTimeHour > 6 && currentTimeHour <= 9){
      setState(() {
        calendarGreetText = "Jó reggelt! ☕";
      });
    }
    else if(currentTimeHour > 9 && currentTimeHour <= 13){
      setState(() {
        calendarGreetText = "Szép napot! 🍷";
      });
    }
    else if(currentTimeHour > 13 && currentTimeHour <= 17){
      setState(() {
        calendarGreetText = "Kellemes délutánt! 🥂";
      });
    }
    else if(currentTimeHour > 17 && currentTimeHour <= 21){
      setState(() {
        calendarGreetText = "Szép estét! 🍻";
      });
    }
    else if(currentTimeHour > 21 || currentTimeHour <= 1){
      setState(() {
        calendarGreetText = "Jó éjszakát! 🍹";
      });
    }
  }

  void clearCalendar(){
    setState(() {
      weeksSinceStart = calcPassedWeeks();
      calendarEntries.clear();
      mondayCalendar.clear();
      tuesdayCalendar.clear();
      wednessdayCalendar.clear();
      thursdayCalendar.clear();
      fridayCalendar.clear();
      saturdayCalendar.clear();
      sundayCalendar.clear();
    });
  }

  void clearMarkbook(){
    setState(() {
      markbookEntries.clear();
      markbookList.clear();
    });
  }

  void clearPayments(){
    setState(() {
      paymentsEntries.clear();
      paymentsList.clear();
    });
  }
  void clearPeriods(){
    setState(() {
      periodEntries.clear();
      periodList.clear();
      currentSemester = -1;
      countActivePeriods = 0;
      countExpiredPeriods = 0;
      countFuturePeriods = 0;
    });
  }

  void clearMails(){
    setState(() {
      mailEntries.clear();
      mailList.clear();
      currentMailPage = 1;
      currentMailLoadingDebounce = false;
      unreadMailCount = 0;
      totalMailCount = 0;
      allLoadedMailCount = 0;
    });
  }

  void setupCalendar(bool thisweekCalendar){
    setState(() {
      _setupCalendar(thisweekCalendar);
      canDoCalendarPaging = true;
      setupCalendarController(false, false);
    });
  }
  void setupMarkbook(){
    setState(() {
      _setupMarkbook();
    });
  }

  void setupPayments(){
    setState(() {
      _setupPayments();
    });
  }

  void setupPeriods(){
    setState(() {
      _setupPeriods();
    });
  }

  void setupMails({bool clear = false}){
    setState(() {
      _setupMails(clearLoader: clear);
    });
  }

  static void setupExamNotifications(){
    Future.delayed(Duration.zero, ()async{
      await _instance._setupExamNotifications(_instance._examNotificationList);
    });
  }

  static void cancelExamNotifications(){
    Future.delayed(Duration.zero, ()async{
      await _instance._cancelExamNotifications();
    });
  }

  final _examNotificationList = <api.CalendarEntry>[];
  
  Future<void> _skimForExams()async{
    for(int i = 0; i < 3; i++){
      final result = await fetchCalendarToList(i);
      _examNotificationList.addAll(result);
    }

    _setupExamNotifications(_examNotificationList);
  }
  
  Future<void> _setupExamNotifications(List<api.CalendarEntry> items)async{
    if(_examNotificationList.isEmpty){
      return;
    }
    final now = DateTime.now();
    for(var item in items){ // add notifiers for exams
      if(!item.isExam || now.millisecondsSinceEpoch > item.startEpoch){
        continue;
      }
      await _setupNotificationsForSkimmedExams(item, now);
    }
  }

  Future<void> _setupNotificationsForSkimmedExams(api.CalendarEntry item, DateTime now)async{
    final daysTillExam = (Duration(milliseconds: item.startEpoch) - Duration(milliseconds: now.millisecondsSinceEpoch)).inDays;
    for(int i = 1; i <= daysTillExam + 1; i++){
      if(i == 1){
        await AppNotifications.scheduleNotification('Vizsga emlékeztető!', '"${item.title}" tárgyból vizsgád lesz MA!', DateTime(now.year, now.month, now.day + daysTillExam - i + 2, 06, 00), 0);
        continue;
      }
      else if(i == 2){
        await AppNotifications.scheduleNotification('Vizsga emlékeztető!', '"${item.title}" tárgyból vizsgád lesz HOLNAP!', DateTime(now.year, now.month, now.day + daysTillExam - i + 2, 09, 00), 0);
        continue;
      }
      await AppNotifications.scheduleNotification('Vizsga emlékeztető!', '"${item.title}" tárgyból vizsgád lesz $i nap múlva!', DateTime(now.year, now.month, now.day + daysTillExam - i + 2, 09, 00), 0);
    }
  }

  Future<void> _cancelExamNotifications()async{
    await AppNotifications.cancelScheduledNotifsId(0);
  }

  static void setupClassesNotifications(){
    Future.delayed(Duration.zero, ()async{
      await _instance._setupClassesNotifications(_instance._classesNotificationList);
    });
  }

  static void cancelClassesNotifications(){
    Future.delayed(Duration.zero, ()async{
      await _instance._cancelClassesNotifications();
    });
  }

  final List<api.CalendarEntry> _classesNotificationList = <api.CalendarEntry>[].toList();

  Future<void> _setupClassesNotifications(List<api.CalendarEntry> items)async{
    if(!storage.DataCache.getNeedExamNotifications()!){
      return;
    }
    for(var item in items){
      // set up notifications for today
      final now = DateTime.now();
      if(now.millisecondsSinceEpoch < item.startEpoch && !item.isExam){ // did not pass them in time
        await AppNotifications.scheduleNotification('Óra', '"${item.title}" órád lesz itt: "${item.location}" 10 perc múlva!', DateTime.fromMillisecondsSinceEpoch((Duration(milliseconds: item.startEpoch) - const Duration(minutes: 10)).inMilliseconds), 1);
        await AppNotifications.scheduleNotification('Óra', '"${item.title}" órád lesz itt: "${item.location}" 5 perc múlva!', DateTime.fromMillisecondsSinceEpoch((Duration(milliseconds: item.startEpoch) - const Duration(minutes: 5)).inMilliseconds), 1);
        await AppNotifications.scheduleNotification('Óra', '"${item.title}" órád van itt: "${item.location}"!', DateTime.fromMillisecondsSinceEpoch(item.startEpoch), 1);
      }
    }
  }
  
  Future<void> _cancelClassesNotifications()async{
    await AppNotifications.cancelScheduledNotifsId(1);
  }

  static void setupPaymentsNotifications(){
    Future.delayed(Duration.zero, ()async{
      await _instance._setupPaymentsNotification(_instance._paymentsNotificationList);
    });
  }

  static void cancelPaymentsNotifications(){
    Future.delayed(Duration.zero, ()async{
      await _instance._cancelPaymentsNotifications();
    });
  }

  final List<api.CashinEntry> _paymentsNotificationList = <api.CashinEntry>[].toList();

  Future<void> _setupPaymentsNotification(List<api.CashinEntry> items)async{
    if(!storage.DataCache.getNeedPaymentsNotifications()! || _paymentsNotificationList.isEmpty){
      return;
    }
    final now = DateTime.now();
    for(var item in items){
      if(item.dueDateMs == 0){
        for(int i = 0; i <= 31; i++){
          await AppNotifications.scheduleNotification('Befizetés', '${item.ammount}Ft-al lógsz. Fizesd be! (Nincs határidő)', DateTime(now.year, now.month, now.day + i, 11, 00),2 );
        }
        continue;
      }
      final daysRemaining = (Duration(milliseconds: item.dueDateMs) - Duration(milliseconds: now.millisecondsSinceEpoch)).inDays;
      final time = DateTime.fromMillisecondsSinceEpoch(item.dueDateMs);
      for(int i = 0; i <= daysRemaining; i++){
        await AppNotifications.scheduleNotification('Befizetés', '${item.ammount}Ft-al lógsz. Fizesd be: ${daysRemaining > 61 ? "(${time.year})" : ""} ${api.Generic.monthToText(time.month)}. ${time.day}.-ig!', DateTime(now.year, now.month, now.day + i, 11, 00), 2);
      }
    }
  }

  Future<void> _cancelPaymentsNotifications()async{
    await AppNotifications.cancelScheduledNotifsId(2);
  }
  
  static void setupPeriodsNotifications(){
    Future.delayed(Duration.zero, ()async{
      await _instance._setupPeriodsNotification(_instance._periodsNotificationList);
    });
  }

  static void cancelPeriodsNotifications(){
    Future.delayed(Duration.zero, ()async{
      await _instance._cancelPeriodsNotifications();
    });
  }

  final List<api.PeriodEntry> _periodsNotificationList = <api.PeriodEntry>[].toList();
  
  Future<void> _setupPeriodsNotification(List<api.PeriodEntry> items)async{
    if(!storage.DataCache.getNeedPeriodsNotifications()! || _periodsNotificationList.isEmpty){
      return;
    }

    for(var item in items){
      final time = DateTime.fromMillisecondsSinceEpoch(item.startEpoch);
      await AppNotifications.scheduleNotification('Időszak', '"${api.Generic.capitalizePeriodText(item.name)}" időszak lesz HOLNAP!', DateTime(time.year, time.month, time.day - 1, 11, 00), 3);
      await AppNotifications.scheduleNotification('Időszak', '"${api.Generic.capitalizePeriodText(item.name)}" időszak van MA!', DateTime(time.year, time.month, time.day, 06, 00), 3);
    }
  }

  Future<void> _cancelPeriodsNotifications()async{
    await AppNotifications.cancelScheduledNotifsId(3);
  }

  void _setupCalendar(bool thisweekCalendar){
    int idx = 1;
    int prev = 0;
    api.CalendarEntry? prevEntry;
    final currWeekday = DateTime.now().weekday;
    for(var item in calendarEntries){
      if(!item.isExam){
        continue;
      }
      final wkday = DateTime.fromMillisecondsSinceEpoch(item.startEpoch).weekday;
      if(prev != wkday){
        idx = 1;
        prev = wkday;
      }
      switch(wkday){
        case 1:
          mondayCalendar.add(t_table.TimetableElementWidget(
            entry: item,
            position: idx,
          ));
          break;
        case 2:
          tuesdayCalendar.add(t_table.TimetableElementWidget(
            entry: item,
            position: idx,
          ));
          break;
        case 3:
          wednessdayCalendar.add(t_table.TimetableElementWidget(
            entry: item,
            position: idx,
          ));
          break;
        case 4:
          thursdayCalendar.add(t_table.TimetableElementWidget(
            entry: item,
            position: idx,
          ));
          break;
        case 5:
          fridayCalendar.add(t_table.TimetableElementWidget(
            entry: item,
            position: idx,
          ));
          break;
        case 6:
          saturdayCalendar.add(t_table.TimetableElementWidget(
            entry: item,
            position: idx,
          ));
          break;
        case 7:
          sundayCalendar.add(t_table.TimetableElementWidget(
            entry: item,
            position: idx,
          ));
          break;
      }
      idx++;
    }

    for(var item in calendarEntries){
      if(item.isExam){
        continue;
      }
      final wkday = DateTime.fromMillisecondsSinceEpoch(item.startEpoch).weekday;
      if(prev != wkday){
        idx = 1;
        prev = wkday;
        prevEntry = item;
      }
      if(thisweekCalendar && currWeekday == wkday){
        _classesNotificationList.add(item);
      }
      if(idx == 2 && item.startEpoch == prevEntry!.startEpoch){
        idx--;
      }
      switch(wkday){
        case 1:
          mondayCalendar.add(t_table.TimetableElementWidget(
            entry: item,
            position: idx,
          ));
          break;
        case 2:
          tuesdayCalendar.add(t_table.TimetableElementWidget(
            entry: item,
            position: idx,
          ));
          break;
        case 3:
          wednessdayCalendar.add(t_table.TimetableElementWidget(
            entry: item,
            position: idx,
          ));
          break;
        case 4:
          thursdayCalendar.add(t_table.TimetableElementWidget(
            entry: item,
            position: idx,
          ));
          break;
        case 5:
          fridayCalendar.add(t_table.TimetableElementWidget(
            entry: item,
            position: idx,
          ));
          break;
        case 6:
          saturdayCalendar.add(t_table.TimetableElementWidget(
            entry: item,
            position: idx,
          ));
          break;
        case 7:
          sundayCalendar.add(t_table.TimetableElementWidget(
            entry: item,
            position: idx,
          ));
          break;
      }
      if(idx == 1 || item.startEpoch != prevEntry!.startEpoch){
        prevEntry = item;
        idx++;
      }
    }
    calendarTabController.index = currentWeekOffset == 1 ? currWeekday - 1 > 6 ? 0 : currWeekday - 1 : calendarTabController.index;
  }

  List<Widget> calendarTabs = <Widget>[].toList();
  List<Widget> calendarTabViews = <Widget>[].toList();

  void setupCalendarController(bool replaceController, bool isLoading){
    calendarTabs = <Widget>[].toList();
    calendarTabViews = <Widget>[].toList();
    getCalendarTabViews(context, isLoading);
    if(replaceController) {
      calendarTabController = TabController(length: calendarTabs.length, vsync: this);
    }
    setState(() {
      isLoadingCalendar = isLoading;
    });
  }

  void _fillOneCalendarElement(BuildContext context, List<Widget> w, String name, bool isLoading){
    /*if(!isLoading && w.isEmpty){
      return;
    }*/
    calendarTabs.add(Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Tab(
        child: Text(
          name,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12
          ),
        ),
      ),
    ));
    calendarTabViews.add(RefreshIndicator(
      onRefresh: ()async{AppHaptics.lightImpact(); onCalendarRefresh(false);},
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: Container(
          margin: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: w.isNotEmpty ? Colors.white.withOpacity(0.03) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: w.isNotEmpty ? w : isLoading ? <Widget>[
              const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                api.Generic.randomLoadingComment(storage.DataCache.getNeedFamilyFriendlyComments()!),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(.2),
                  fontWeight: FontWeight.w300,
                  fontSize: 10
                ),
              )
            ] : <Widget>[const t_table.FreedayElementWidget()],
          ),
        ),
      ),
    ));
  }

  void getCalendarTabViews(BuildContext context, bool isLoading){
    _fillOneCalendarElement(context, mondayCalendar, 'Hétfő', isLoading);
    _fillOneCalendarElement(context, tuesdayCalendar, 'Kedd', isLoading);
    _fillOneCalendarElement(context, wednessdayCalendar, 'Szerda', isLoading);
    _fillOneCalendarElement(context, thursdayCalendar, 'Csütörtök', isLoading);
    _fillOneCalendarElement(context, fridayCalendar, 'Péntek', isLoading);
    _fillOneCalendarElement(context, saturdayCalendar, 'Szombat', isLoading);
    _fillOneCalendarElement(context, sundayCalendar, 'Vasárnap', isLoading);
  }

  void _mbookPopupResult(int result, int idx){
    if(result == -1){
      setState(() {
        final e = markbookList[idx] as mbook.MarkbookElementWidget;
        setState(() {
          markbookList[idx] = mbook.MarkbookElementWidget(
            name: e.name,
            credit: e.credit,
            completed: e.completed,
            grade: e.grade,
            isFailed: e.isFailed,
            onPopupResult: e.onPopupResult,
            listIndex: e.listIndex,
            ghostGrade: -1,
          );
          _markbookCalcGhostAvg();
        });
      });
      return;
    }

    final grade = result + 1;
    final e = markbookList[idx] as mbook.MarkbookElementWidget;
    setState(() {
      markbookList[idx] = mbook.MarkbookElementWidget(
        name: e.name,
        credit: e.credit,
        completed: e.completed,
        grade: e.grade,
        isFailed: e.isFailed,
        onPopupResult: e.onPopupResult,
        listIndex: e.listIndex,
        ghostGrade: grade,
      );
      _markbookCalcGhostAvg();
    });
  }
  
  void _setupMarkbook(){
    totalAvg = 5;
    totalAvg30 = 5;
    if(markbookEntries.isEmpty){
      totalCredits = 0;
      markbookList.add(Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: const Center(
          child: EmojiRichText(
            text: '🤪Nincs Tantárgyad🤪',
            defaultStyle: TextStyle(
              color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
              fontWeight: FontWeight.w900,
              fontSize: 26.0,
            ),
            emojiStyle: TextStyle(
                color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
                fontSize: 26.0,
                fontFamily: "Noto Color Emoji"
            ),
          ),
        ),
      ));
    }

    //order them
    for (int i = 0; i < markbookEntries.length; i++){
      for (int j = i; j < markbookEntries.length; j++){
        if(markbookEntries[j].credit > markbookEntries[i].credit){
          final tmp = markbookEntries[i];
          markbookEntries[i] = markbookEntries[j];
          markbookEntries[j] = tmp;
        }
      }
    }

    // set them up
    totalCredits = 0;
    totalAvg = 0;
    totalAvg30 = 0;
    var hasCompleted = false;
    var hasIncomplete = false;
    int idx = 0;
    for (var item in markbookEntries){
      totalCredits += item.credit;
      if(item.completed){
        hasCompleted = true;
        continue;
      }
      hasIncomplete = true;
      markbookList.add(mbook.MarkbookElementWidget(
        name: item.name,
        credit: item.credit,
        completed: item.completed,
        grade: item.grade,
        isFailed: item.failState == 1,
        onPopupResult: _mbookPopupResult,
        listIndex: idx,
        ghostGrade: -1,
      ));
      idx++;
    }
    if(hasCompleted) {
      if(hasIncomplete){
        markbookList.add(
            Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 30),
              color: Colors.white.withOpacity(0.3),
            )
        );
        idx++;
      }

      for (var item in markbookEntries) {
        if (!item.completed) {
          continue;
        }
        markbookList.add(mbook.MarkbookElementWidget(
          name: item.name,
          credit: item.credit,
          completed: item.completed,
          grade: item.grade,
          isFailed: item.failState == 1,
          onPopupResult: _mbookPopupResult,
          listIndex: idx,
          ghostGrade: -1,
        ));
        idx++;
      }
    }
    _markbookCalcAvg();
  }

  void _markbookCalcAvg(){
    if(markbookEntries.isEmpty){
      return;
    }
    var currCredits = 0;
    for(var item in markbookEntries){
      if (!item.completed) {
        continue;
      }
      if (item.grade >= 2) {
        currCredits += item.credit;
        totalAvg += item.grade * item.credit;
      }
    }
    totalAvg30 = totalAvg / 30;
    totalAvg /= currCredits;
  }

  void _markbookCalcGhostAvg(){
    if(markbookEntries.isEmpty){
      return;
    }
    var currCredits = 0;
    totalAvg = 0;
    totalAvg30 = 0;
    for(var item in markbookList){
      try{
        final itm = item as mbook.MarkbookElementWidget;
        if(!itm.completed && itm.ghostGrade == -1){
          continue;
        }
        if (item.grade >= 2) {
          currCredits += item.credit;
          totalAvg += item.grade * item.credit;
        }
        else if(item.ghostGrade != -1){
          currCredits += item.credit;
          totalAvg += item.ghostGrade * item.credit;
        }
      }
      catch(_){}
    }
    totalAvg30 = totalAvg / 30;
    totalAvg /= currCredits;
  }

  void _setupPayments(){
    totalMoney = 0;
    //order them
    for (int i = 0; i < paymentsEntries.length; i++){
      for (int j = i; j < paymentsEntries.length; j++){
        if(paymentsEntries[j].dueDateMs < paymentsEntries[i].dueDateMs){
          final tmp = paymentsEntries[i];
          paymentsEntries[i] = paymentsEntries[j];
          paymentsEntries[j] = tmp;
        }
      }
    }

    bool isEmpty = true;
    for(var item in paymentsEntries){
      if(item.completed){
        totalMoney += item.ammount;
        continue;
      }
      isEmpty = false;
      paymentsList.add(PaymentElementWidget(ammount: item.ammount, dueDateMs: item.dueDateMs, ID: item.ID, name: item.comment));
      if(item.dueDateMs > DateTime.now().millisecondsSinceEpoch || item.dueDateMs == 0){
        _paymentsNotificationList.add(item);
      }
    }

    if(_paymentsNotificationList.isNotEmpty){
      Future.delayed(Duration.zero,()async{
        await _setupPaymentsNotification(_paymentsNotificationList);
      });
    }

    if(isEmpty){
      paymentsList.add(Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: const Center(
          child: EmojiRichText(
            text: '😇Nem Tartozol😇',
            defaultStyle: TextStyle(
              color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
              fontWeight: FontWeight.w900,
              fontSize: 26.0,
            ),
            emojiStyle: TextStyle(
                color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
                fontSize: 26.0,
                fontFamily: "Noto Color Emoji"
            ),
          ),
        ),
      ));
    }
  }

  Widget _getSeparatorLine(String text, {bool expired = false}){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 30),
            color: expired ? Colors.red.withOpacity(.3) : Colors.white.withOpacity(.3),
          ),
        ),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: expired ? Colors.red.withOpacity(.6) : Colors.white.withOpacity(.6),
              fontWeight: FontWeight.w600,
              fontSize: 14
          ),
        ),
        Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 30),
            color: expired ? Colors.red.withOpacity(.3) : Colors.white.withOpacity(.3),
          ),
        ),
      ],
    );
  }

  void _setupPeriods(){
    //order them
    for (int i = 0; i < periodEntries.length; i++){
      for (int j = i; j < periodEntries.length; j++){
        if(periodEntries[j].startEpoch < periodEntries[i].startEpoch){
          final tmp = periodEntries[i];
          periodEntries[i] = periodEntries[j];
          periodEntries[j] = tmp;
        }
      }
    }

    int prevSemester = -1;

    List<api.PeriodEntry> expiredPeriods = [];
    bool hasFuturePeriodLine = false;
    //Map<String, List<api.PeriodType>> values = Map<String, List<api.PeriodType>>.identity();
    for(var item in periodEntries){
      if(item.isActive){
        countActivePeriods++;
      }
      else if(item.endEpoch > DateTime.now().millisecondsSinceEpoch){
        if(!hasFuturePeriodLine){
          hasFuturePeriodLine = true;
          periodList.add(
              const Padding(padding: EdgeInsets.only(top: 10))
          );
          periodList.add(
              _getSeparatorLine('Jövőbeli')
          );
        }
        countFuturePeriods++;
      }
      else{
        countExpiredPeriods++;
      }

      final starttime = DateTime.fromMillisecondsSinceEpoch(item.startEpoch);
      final endtime = DateTime.fromMillisecondsSinceEpoch(item.endEpoch);
      final now = DateTime.now().millisecondsSinceEpoch;
      if(now > endtime.millisecondsSinceEpoch){
        expiredPeriods.add(item);
        continue; // expired
      }
      if(prevSemester == -1){
        prevSemester = item.partofSemester;
        periodList.add(
            const Padding(padding: EdgeInsets.only(top: 10))
        );
        periodList.add(
            _getSeparatorLine('Aktuális')
        );
      }
      else if(item.partofSemester != prevSemester){
        /*periodList.add(
          _getSeparatorLine('${prevSemester + 1}. félév')
        );*/
        prevSemester = item.partofSemester;
      }
      if(!item.isActive){ // exclude today
        _periodsNotificationList.add(item);
      }
      periodList.add(priods.PeriodsElementWidget(
        displayName: api.Generic.capitalizePeriodText(item.name),
        formattedStartTime: '${api.Generic.monthToText(starttime.month)}. ${starttime.day}.',
        formattedStartTimeYear: '${starttime.year}',
        formattedEndTime: '${api.Generic.monthToText(endtime.month)}. ${endtime.day}.',
        formattedEndTimeYear: '${endtime.year}',
        isActive: item.isActive,
        periodType: item.type,
        startTime: item.startEpoch,
        endTime: (DateTime.fromMillisecondsSinceEpoch(item.endEpoch).millisecondsSinceEpoch),
        expired: false,
      ));
      if(currentSemester == -1) {
        currentSemester = item.partofSemester;
      }
    }

    periodList.add(
        const Padding(padding: EdgeInsets.only(top: 10))
    );

    periodList.add(
        _getSeparatorLine('Lejárt', expired: true)
    );
    
    for(var item in expiredPeriods){
      final starttime = DateTime.fromMillisecondsSinceEpoch(item.startEpoch);
      final endtime = DateTime.fromMillisecondsSinceEpoch(item.endEpoch);
      periodList.add(priods.PeriodsElementWidget(
        displayName: api.Generic.capitalizePeriodText(item.name),
        formattedStartTime: '${api.Generic.monthToText(starttime.month)}. ${starttime.day}.',
        formattedStartTimeYear: '${starttime.year}',
        formattedEndTime: '${api.Generic.monthToText(endtime.month)}. ${endtime.day}.',
        formattedEndTimeYear: '${endtime.year}',
        isActive: item.isActive,
        periodType: item.type,
        startTime: item.startEpoch,
        endTime: (DateTime.fromMillisecondsSinceEpoch(item.endEpoch).millisecondsSinceEpoch),
        expired: true,
      ));
    }

    if(_periodsNotificationList.isNotEmpty){
      Future.delayed(Duration.zero,()async{
        await _setupPeriodsNotification(_periodsNotificationList);
      });
    }

    if(periodEntries.isEmpty){
      periodList.add(Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: const Center(
          child: EmojiRichText(
            text: '🤩Szünet Van🤩',
            defaultStyle: TextStyle(
              color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
              fontWeight: FontWeight.w900,
              fontSize: 26.0,
            ),
            emojiStyle: TextStyle(
                color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
                fontSize: 26.0,
                fontFamily: "Noto Color Emoji"
            ),
          ),
        ),
      ));
    }
  }

  void _setupMails({bool clearLoader = false}){
    if(mailEntries.isEmpty){
      mailList.add(Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: const Center(
          child: EmojiRichText(
            text: '😥Nincs Üzeneted😥',
            defaultStyle: TextStyle(
              color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
              fontWeight: FontWeight.w900,
              fontSize: 26.0,
            ),
            emojiStyle: TextStyle(
                color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
                fontSize: 26.0,
                fontFamily: "Noto Color Emoji"
            ),
          ),
        ),
      ));
    }

    if(clearLoader && mailList.isNotEmpty){
      mailList.removeAt(mailList.length-1);
    }

    int idx = 0;
    var prevDate = DateTime.now();
    mailList.add(
        const Padding(padding: EdgeInsets.only(top: 10))
    );
    for(var item in mailEntries){
      allLoadedMailCount++;
      final date = DateTime.fromMillisecondsSinceEpoch(item.sendDateMs);
      final currDate = DateTime(date.year, date.month, date.day);
      if(mailEntries.length != ++idx && prevDate != currDate){
        prevDate = currDate;
        mailList.add(_getSeparatorLine('${currDate.year}. ${api.Generic.monthToText(date.month)}. ${date.day}.'));
      }
      mailList.add(MailElementWidget(subject: item.subject, details: item.detail, sender: item.senderName, sendTime: item.sendDateMs, isRead: item.isRead, mailID: item.ID, callback: (element){
        setState(() {
          if(element.isRead){
            return;
          }
          final indx = mailList.indexOf(element);
          mailList.insert(indx, MailElementWidget(subject: element.subject, details: element.details, sender: element.sender, sendTime: element.sendTime, isRead: true, mailID: element.mailID, callback: (_){}));
          mailList.remove(element);
          unreadMailCount--;
          storage.saveInt('CachedMailsUnread', unreadMailCount);
          Future.delayed(Duration.zero, ()async{
            await api.MailRequest.setMailRead(MailPopupDisplayTexts.mailID);
            if(currentMailPage == 1){
              storage.DataCache.setHasCachedMail(0);
            }
          });
        });
      },));
      /*if(!item.isRead){
        unreadMailCount++;
      }*/
    }
  }

  Future<void> stepCalendarBack() async{
    currentWeekOffset--;
    AppHaptics.lightImpact();
    await onCalendarRefresh(true);
  }
  Future<void> stepCalendarForward() async{
    currentWeekOffset++;
    AppHaptics.lightImpact();
    await onCalendarRefresh(true);
  }

  Future<List<api.CalendarEntry>> fetchCalendarToList(int offset) async{
    //final userOffset = storage.DataCache.getUserWeekOffset()!;
    final request = await api.CalendarRequest.makeCalendarRequest(api.CalendarRequest.getCalendarOneWeekJSON(storage.DataCache.getUsername()!, storage.DataCache.getPassword()!, currentWeekOffset + offset/* + isWeekend + userOffset*/));
    final list = api.CalendarRequest.getCalendarEntriesFromJSON(request);
    /*final List<api.CalendarEntry> list2 = [];
    for(var item in list){
      bool duplicate = false;
      for(var item2 in list2){
        if(item.isIdentical(item2)){
          duplicate = true;
          break;
        }
      }
      if(!duplicate){
        list2.add(item);
      }
    }*/
    //return list2;
    return list;
  }

  Future<void> fetchCalendar() async{
    bool hasCachedCalendar = storage.DataCache.getHasCachedCalendar() ?? false;
    final cacheTime = await storage.getString('CalendarCacheTime');

    if(!hasCachedCalendar && !storage.DataCache.getHasNetwork()){
      return;
    }
    // if we had a save, and the cached value is not older than a day, we can load that up
    if(hasCachedCalendar && cacheTime != null && (DateTime.now().millisecondsSinceEpoch - DateTime.parse(cacheTime).millisecondsSinceEpoch) < const Duration(hours: 24).inMilliseconds && !storage.DataCache.getIsDemoAccount()!) {
      final len = await storage.getInt('CachedCalendarLength');
      for(int i = 0; i < len!; i++){
        final calEntry = await storage.getString('CachedCalendar_$i');
        calendarEntries.add(api.CalendarEntry('0', '0', 'NULL', 'NULL', false).fillWithExisting(calEntry!));
      }
      storage.DataCache.setHasCachedFirstWeekEpoch(1);
      Future.delayed(Duration.zero,()async{
        await _setupClassesNotifications(_classesNotificationList);
      });
      return;
    }
    //otherwise, just fetch again
    //final isWeekend = DateTime.now().weekday == DateTime.saturday || DateTime.now().weekday == DateTime.sunday ? 1 : 0;
    //final userOffset = storage.DataCache.getUserWeekOffset()!;
    final request = await api.CalendarRequest.makeCalendarRequest(api.CalendarRequest.getCalendarOneWeekJSON(storage.DataCache.getUsername()!, storage.DataCache.getPassword()!, currentWeekOffset/* + isWeekend + userOffset*/));
    calendarEntries.clear();
    final list = api.CalendarRequest.getCalendarEntriesFromJSON(request);
    /*final List<api.CalendarEntry> list2 = [];
    for(var item in list){
      bool duplicate = false;
      for(var item2 in list2){
        if(item.isIdentical(item2)){
          //duplicate = true;
          //break;
        }
      }
      if(!duplicate){
        list2.add(item);
      }
    }*/
    //calendarEntries = list2;
    calendarEntries = list;
    if(currentWeekOffset == 1) {
      storage.saveInt('CachedCalendarLength', calendarEntries.length);
      //cache calendar
      for (int i = 0; i < calendarEntries.length; i++) {
        storage.saveString('CachedCalendar_$i', calendarEntries[i].toString());
      }
      final now = DateTime.now();
      storage.saveString('CalendarCacheTime', DateTime(now.year, now.month, now.day, 0, 0, 0).toString());
      Future.delayed(Duration.zero,()async{
        await _setupClassesNotifications(_classesNotificationList);
      });
    }
    storage.DataCache.setHasCachedCalendar(1);
  }
  Future<void> fetchMarkbook() async{
    bool hasCachedMarkbook= storage.DataCache.getHasCachedMarkbook() ?? false;
    final cacheTime = await storage.getString('MarkbookCacheTime');

    if(!hasCachedMarkbook && !storage.DataCache.getHasNetwork()){
      return;
    }

    // if we had a save, and the cached value is not older than a day, we can load that up
    if(hasCachedMarkbook && cacheTime != null && (DateTime.now().millisecondsSinceEpoch - DateTime.parse(cacheTime).millisecondsSinceEpoch) < const Duration(hours: 24).inMilliseconds) {
      final len = await storage.getInt('CachedMarkbookLength');
      for(int i = 0; i < len!; i++){
        final calEntry = await storage.getString('CachedMarkbook_$i');
        markbookEntries.add(api.Subject(false, 0, 'NULL', 0, 0, 0).fillWithExisting(calEntry!));
      }
      return;
    }

    //otherwise, just fetch again
    final request = await api.MarkbookRequest.getMarkbookSubjects();
    if(request != null && request.isEmpty){
      markbookEntries = [];
      return;
    }
    markbookEntries = request!;

    storage.saveInt('CachedMarkbookLength', markbookEntries.length);
    //cache calendar
    for (int i = 0; i < markbookEntries.length; i++) {
      storage.saveString('CachedMarkbook_$i', markbookEntries[i].toString());
    }
    storage.saveString('MarkbookCacheTime', DateTime.now().toString());

    storage.DataCache.setHasCachedMarkbook(1);
  }

  Future<void> fetchPayments() async{
    bool hasCachedPayments = storage.DataCache.getHasCachedPayments() ?? false;

    final cacheTime = await storage.getString('PaymentsCacheTime');

    if(!hasCachedPayments && !storage.DataCache.getHasNetwork()){
      return;
    }

    // if we had a save, and the cached value is not older than a day, we can load that up
    if(hasCachedPayments && cacheTime != null && (DateTime.now().millisecondsSinceEpoch - DateTime.parse(cacheTime).millisecondsSinceEpoch) < const Duration(hours: 24).inMilliseconds) {
      final len = await storage.getInt('CachedPaymentsLength');
      for(int i = 0; i < len!; i++){
        final calEntry = await storage.getString('CachedPayments_$i');
        paymentsEntries.add(api.CashinEntry(0, 0, 'NULL', 0, 'NULL').fillWithExisting(calEntry!));
      }
      return;
    }

    //otherwise, just fetch again
    final request = await api.CashinRequest.getAllCashins();
    if(request.isEmpty){
      return;
    }
    paymentsEntries = request;

    storage.saveInt('CachedPaymentsLength', paymentsEntries.length);
    //cache calendar
    for (int i = 0; i < paymentsEntries.length; i++) {
      storage.saveString('CachedPayments_$i', paymentsEntries[i].toString());
    }
    storage.saveString('PaymentsCacheTime', DateTime.now().toString());

    storage.DataCache.setHasCachedPayments(1);
  }

  Future<void> fetchPeriods() async{
    bool hasCachedPeriods = storage.DataCache.getHasCachedPeriods() ?? false;

    final cacheTime = await storage.getString('PeriodsCacheTime');

    if(!hasCachedPeriods && !storage.DataCache.getHasNetwork()){
      return;
    }

    // if we had a save, and the cached value is not older than a day, we can load that up
    if(hasCachedPeriods && cacheTime != null && (DateTime.now().millisecondsSinceEpoch - DateTime.parse(cacheTime).millisecondsSinceEpoch) < const Duration(hours: 24).inMilliseconds) {
      final len = await storage.getInt('CachedPeriodsLength');
      for(int i = 0; i < len!; i++){
        final calEntry = await storage.getString('CachedPeriods_$i');
        final entry = api.PeriodEntry("ERROR", 0, 0, 0).fillWithExisting(calEntry!);
        periodEntries.add(entry);
      }
      return;
    }

    //otherwise, just fetch again
    final request = await api.PeriodsRequest.getPeriods();
    if(request != null && request.isEmpty){
      return;
    }
    periodEntries = request!;

    storage.saveInt('CachedPeriodsLength', periodEntries.length);
    //cache calendar
    for (int i = 0; i < periodEntries.length; i++) {
      storage.saveString('CachedPeriods_$i', periodEntries[i].toString());
    }
    storage.saveString('PeriodsCacheTime', DateTime.now().toString());

    storage.DataCache.setHasCachedPeriods(1);
  }

  int currentMailPage = 1;
  bool currentMailLoadingDebounce = false;
  late ScrollController currentMailPageController;
  Future<void> fetchMails({bool force = false})async{
    bool hasCachedMails = storage.DataCache.getHasCachedMail() ?? false;

    final cacheTime = await storage.getString('MailCacheTime');

    if(!hasCachedMails && !storage.DataCache.getHasNetwork() && !force){
      return;
    }

    if(!force && hasCachedMails && cacheTime != null && (DateTime.now().millisecondsSinceEpoch - DateTime.parse(cacheTime).millisecondsSinceEpoch) < const Duration(hours: 24).inMilliseconds) {
      final len = await storage.getInt('CachedMailsLength');
      unreadMailCount = (await storage.getInt('CachedMailsUnread')) ?? 0;
      totalMailCount = (await storage.getInt('CachedMailsTotal')) ?? 0;
      for(int i = 0; i < len!; i++){
        final calEntry = await storage.getString('CachedMails_$i');
        mailEntries.add(api.MailEntry("ERROR", "ERROR", "ERROR", 0, false, 0).fillWithExisting(calEntry!));
      }
      return;
    }

    final request = await api.MailRequest.getMails(currentMailPage);
    if(request != null && request.isEmpty){
      return;
    }
    mailEntries = request!;
    //debug.log(request!.toString());

    if(force){
      return;
    }
    
    final nums = await api.MailRequest.getUnreadMessagesAndAllMessages();
    unreadMailCount = nums[0];
    totalMailCount = nums[1];

    storage.saveInt('CachedMailsLength', mailEntries.length);
    storage.saveInt('CachedMailsUnread', nums[0]);
    storage.saveInt('CachedMailsTotal', nums[1]);
    //cache calendar
    for (int i = 0; i < mailEntries.length; i++) {
      storage.saveString('CachedMails_$i', mailEntries[i].toString());
    }
    storage.saveString('MailCacheTime', DateTime.now().toString());

    storage.DataCache.setHasCachedMail(1);
  }

  Timer? _calendarTimer;

  bool _calendarDebounce = false;
  bool isLoadingCalendar = true;

  bool keepHomeButtonHidden = true;

  Future<void> onCalendarRefresh(bool isPaging) async{
    if(!storage.DataCache.getHasNetwork() || _calendarDebounce){
      return;
    }
    keepHomeButtonHidden = true;
    if(_calendarTimer != null){
      _calendarTimer!.cancel();
    }
    clearCalendar();
    setupCalendarController(false, true);
    _calendarTimer = Timer(Duration(milliseconds: isPaging ? 500 : 0), () async {
      _calendarDebounce = true;
      setState(() {
        canDoCalendarPaging = false;
        isLoadingCalendar = true;
        keepHomeButtonHidden = false;
      });
      await storage.DataCache.setHasCachedCalendar(0);
      //await storage.DataCache.setHasCachedFirstWeekEpoch(0);
      await fetchCalendar();
      setupCalendar(false);
      _calendarDebounce = false;
      setState(() {
        isLoadingCalendar = false;
      });
    });
  }

  bool _markbookDebounce = false;
  Future<void> onMarkbookRefresh() async{
    if(!storage.DataCache.getHasNetwork() || _markbookDebounce){
      return;
    }
    _markbookDebounce = true;
    clearMarkbook();
    await storage.DataCache.setHasCachedMarkbook(0);
    await fetchMarkbook();
    setupMarkbook();
    _markbookDebounce = false;
  }

  bool _paymentsDebounce = false;
  Future<void> onPaymentsRefresh() async{
    if(!storage.DataCache.getHasNetwork() || _paymentsDebounce){
      return;
    }
    _paymentsDebounce = true;
    clearPayments();
    await storage.DataCache.setHasCachedPayments(0);
    await fetchPayments();
    setupPayments();
    _paymentsDebounce = false;
  }

  bool _periodsDebounce = false;
  Future<void> onPeriodsRefresh()async{
    if(!storage.DataCache.getHasNetwork() || _periodsDebounce){
      return;
    }
    _periodsDebounce = true;
    clearPeriods();
    await storage.DataCache.setHasCachedPeriods(0);
    await fetchPeriods();
    setupPeriods();
    _periodsDebounce = false;
  }

  bool _mailsDebounce = false;
  Future<void> onMailRefresh()async{
    if(!storage.DataCache.getHasNetwork() || _mailsDebounce){
      return;
    }
    _mailsDebounce = true;
    clearMails();
    await storage.DataCache.setHasCachedMail(0);
    await fetchMails();
    setupMails();
    _mailsDebounce = false;
  }

  DateTime getClosestMondayTo(DateTime time){
    if(time.weekday == DateTime.monday){
      return time;
    }
    final result = time.add(Duration(days: 8 - time.weekday));
    return result;
  }

  int calcPassedWeeks() {
    final epochsemester = storage.DataCache.getFirstWeekEpoch()!;
    final now = DateTime.now();
    final determiner = epochsemester > 0 ? DateTime.fromMillisecondsSinceEpoch(epochsemester) : getClosestMondayTo(DateTime(now.year - (now.millisecondsSinceEpoch > DateTime(now.year, 9, 1).millisecondsSinceEpoch ? 0 : 1), 9, 1));
    final yearlessNow = DateTime(1, now.month, now.day);
    final sepOne = DateTime(yearlessNow.year - 1, determiner.month, determiner.day); // first week

    final timepassSinceSepOne = Duration(milliseconds: (yearlessNow.millisecondsSinceEpoch - sepOne.millisecondsSinceEpoch));
    final weeksPassed = timepassSinceSepOne.inDays / 7;
    //final isWeekend = /*now.weekday == DateTime.saturday || */now.weekday == DateTime.sunday ? 1 : 0;

    /*
    // Find the most recent Monday on or before the current date
    final mondayOffset = (now.weekday - 1) % 7;
    final monday = now.subtract(Duration(days: mondayOffset));

    final elapsedWeeks = (monday.difference(sepOne).inDays / 7).floor();

    return elapsedWeeks + currentWeekOffset - 1 + isWeekend;*/

    final userOffset = storage.DataCache.getUserWeekOffset()!;
    return ((weeksPassed.floor() % 52) + (currentWeekOffset + userOffset));// - isWeekend;// + isWeekend;
  }
  
  int calcPassedWeekOffsetless(){
    final epochsemester = storage.DataCache.getFirstWeekEpoch()!;
    final now = DateTime.now();
    final determiner = epochsemester > 0 ? DateTime.fromMillisecondsSinceEpoch(epochsemester) : getClosestMondayTo(DateTime(now.year - (now.millisecondsSinceEpoch > DateTime(now.year, 9, 1).millisecondsSinceEpoch ? 0 : 1), 9, 1));
    final yearlessNow = DateTime(1, now.month, now.day);
    final sepOne = DateTime(yearlessNow.year - 1, determiner.month, determiner.day); // first week

    final timepassSinceSepOne = Duration(milliseconds: (yearlessNow.millisecondsSinceEpoch - sepOne.millisecondsSinceEpoch));
    final weeksPassed = timepassSinceSepOne.inDays / 7;

    return ((weeksPassed.floor() % 52));
  }

  @override
  void dispose() {
    super.dispose();
    calendarEntries.clear();
    mondayCalendar.clear();
    tuesdayCalendar.clear();
    wednessdayCalendar.clear();
    thursdayCalendar.clear();
    fridayCalendar.clear();
    saturdayCalendar.clear();
    sundayCalendar.clear();
    markbookEntries.clear();
    markbookList.clear();
    calendarTabController.dispose();
    paymentsEntries.clear();
    paymentsList.clear();
    periodList.clear();
    periodEntries.clear();
    mailList.clear();
    mailEntries.clear();
    _fbController.dispose();
    currentMailPageController.dispose();
    blurController.dispose();
  }

  static Container getSeparatorLine(BuildContext context){
    return Container(
      width: MediaQuery.of(context).size.width / 1.2,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0),
              Colors.white.withOpacity(0.2),
              Colors.white.withOpacity(0.4),
              Colors.white.withOpacity(0.4),
              Colors.white.withOpacity(0.2),
              Colors.white.withOpacity(0),
            ]
        ),
      ),
    );
  }

  void switchView(int to){
    if(currentView == to){
      return;
    }
    setState(() {
      currentView = to;
    });
  }

  late AnimationController _fbController;
  late Animation<double> _fbTween;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Visibility(
              visible: currentView == 0,
              child: CalendarPageWidget(homePage: this, greetText: calendarGreetText, calendarTabs: calendarTabs, calendarTabViews: calendarTabViews)
          ),
          Visibility(
              visible: currentView == 1,
              child: MarkbookPageWidget(homePage: this, totalCredits: totalCredits, totalAvg: totalAvg, totalAvg30: totalAvg30,)
          ),
          Visibility(
              visible: currentView == 2,
              child: PaymentsPageWidget(homePage: this, totalMoney: totalMoney)
          ),
          Visibility(
            visible: currentView == 3,
            child: PeriodsPageWidget(homePage: this, currentSemester: currentSemester),
          ),
          Visibility(
            visible: currentView == 4,
            child: MailsPageWidget(homePage: this),
          ),
          /*GestureDetector(
            onLongPress: (){
              AppHaptics.lightImpact();
              final val = currentView + 1 > HomePageState.maxBottomNavWidgets - 1 ? 0 : currentView + 1;
              switchView(val);
            },
          ),*/
          Visibility(
            visible: currentView == 0 && currentWeekOffset != 1 && canDoCalendarPaging && !keepHomeButtonHidden,
            child: GestureDetector(
              onPanEnd: (_){
                setState(() {
                  _fbNeedAnimate = true;
                });
                _fbController.forward(from: 0).whenComplete(() {
                  final size = MediaQuery.of(context).size;

                  setState(() {
                    _fbPosX = size.width - 90;
                    _fbPosY = size.height - 140;
                  });
                });
              },
              onPanStart: (_){
                setState(() {
                  _fbNeedAnimate = false;
                });
              },
              onPanUpdate: (details){
                final size = MediaQuery.of(context).size;

                setState(() {
                  _fbPosX += details.delta.dx;
                  _fbPosY += details.delta.dy;

                  _fbPosX = _fbPosX < 20 ? 20 : (_fbPosX > size.width - 80 ? size.width - 80 : _fbPosX);
                  _fbPosY = _fbPosY < 120 ? 120 : (_fbPosY > size.height - 140 ? size.height - 140 : _fbPosY);
                });
              },
              child: AnimatedBuilder(
                animation: _fbController,
                builder: (context, child) {
                  return Padding(
                    padding: EdgeInsets.only(left: _fbNeedAnimate ? (lerpDouble(_fbPosX, MediaQuery.of(context).size.width - 90, _fbTween.value))! : _fbPosX, top: _fbNeedAnimate ? ((lerpDouble(_fbPosY, MediaQuery.of(context).size.height - 140, _fbTween.value))!) : _fbPosY),
                    child: IconButton(
                      onPressed: (() async {
                        AppHaptics.lightImpact();
                        keepHomeButtonHidden = true;
                        currentWeekOffset = 1;
                        await onCalendarRefresh(false);
                      }),
                      icon: const Icon(
                        Icons.home_outlined,
                        color: Colors.white,
                      ),
                      style: ButtonStyle(
                        padding: WidgetStateProperty.all(const EdgeInsets.all(15)),
                        backgroundColor: WidgetStateProperty.all(const Color.fromRGBO(0x4F, 0x69, 0x6E, 1.0))
                      ),
                    ),
                  );
                }
              ),
            ),
          ),
          Visibility(
            visible: _showBlur,
            child: AnimatedBuilder(
              animation: blurController,
              builder: (context, widget) {
                return Positioned.fill(
                  child: BackdropFilter(
                     filter: ImageFilter.blur(sigmaX: blurAnimation.value * 15, sigmaY: blurAnimation.value * 15),
                     child: Container(
                       color: Colors.black.withOpacity(blurAnimation.value * 0.4),
                     ),
                   ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CalendarPageWidget extends StatelessWidget{
  final HomePageState homePage;
  final String greetText;
  final List<Widget> calendarTabs;
  final List<Widget> calendarTabViews;
  const CalendarPageWidget({super.key, required this.homePage, required this.greetText, required this.calendarTabs, required this.calendarTabViews});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              topnav.TopNavigatorWidget(homePage: homePage, displayString: "Órarend", smallHintText: greetText, loggedInUsername: storage.DataCache.getUsername()!, loggedInURL: storage.DataCache.getInstituteUrl()!.replaceAll(RegExp(r'/hallgato/MobileService\.svc'), '').replaceAll("https://", '')),
              Container(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 6),
                color: const Color.fromRGBO(0x22, 0x22, 0x22, 1.0),
                width: MediaQuery.of(context).size.width,
                child: TabBar(
                  tabs: calendarTabs,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  dividerColor: Colors.transparent,
                  automaticIndicatorColorAdjustment: true,
                  controller: homePage.calendarTabController,
                  enableFeedback: true,
                  physics: const BouncingScrollPhysics(
                    decelerationRate: ScrollDecelerationRate.fast,
                  ),
                  indicator: BoxDecoration(
                    color: const Color.fromRGBO(0xFF, 0xFF, 0xFF, 0.05),
                    borderRadius: const BorderRadius.all(Radius.circular(26))
                  ),
                  onTap: (index){
                    return;
                  },
                ),
              ),
              HomePageState.getSeparatorLine(context),
              Container(
                width: MediaQuery.of(context).size.width,
                child: t_table.WeekoffseterElementWidget(
                  week: homePage.weeksSinceStart,
                  from: homePage.calendarEntries.isEmpty ? null : DateTime.fromMillisecondsSinceEpoch(homePage.calendarEntries[0].startEpoch),
                  to: homePage.calendarEntries.isEmpty ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(homePage.calendarEntries[homePage.calendarEntries.length - 1].endEpoch),
                  onBackPressed: homePage.stepCalendarBack,
                  onForwardPressed: homePage.stepCalendarForward,
                  canDoPaging: homePage.canDoCalendarPaging,
                  homePage: homePage,
                  isLoading: homePage.isLoadingCalendar,
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: homePage.calendarTabController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: calendarTabViews,
                ),
              ),
              HomePageState.getSeparatorLine(context),
              bottomnav.BottomNavigatorWidget(homePage: homePage),
            ],
          ),
        ],
      ),
    );
  }
}

/*class _FloatingButtonOffset extends FloatingActionButtonLocation{
  final double offsetY;
  final double offsetX;
  _FloatingButtonOffset({required this.offsetX, required this.offsetY});

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double x = (scaffoldGeometry.scaffoldSize.width - scaffoldGeometry.floatingActionButtonSize.width) / offsetX;
    final double y = scaffoldGeometry.scaffoldSize.height - scaffoldGeometry.floatingActionButtonSize.height / offsetY;
    return Offset(x, y);
  }
}*/

class MarkbookPageWidget extends StatelessWidget{
  final HomePageState homePage;
  final int totalCredits;
  final double totalAvg;
  final double totalAvg30;
  const MarkbookPageWidget({super.key, required this.homePage, required this.totalCredits, required this.totalAvg, required this.totalAvg30});

  Future<void> onRefresh() async{
    AppHaptics.lightImpact();
    homePage.onMarkbookRefresh();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              topnav.TopNavigatorWidget(homePage: homePage, displayString: "Tantárgyak", smallHintText: "Kredited ebben a félévben: $totalCredits🎖️", loggedInUsername: storage.DataCache.getUsername()!, loggedInURL: storage.DataCache.getInstituteUrl()!.replaceAll(RegExp(r'/hallgato/MobileService\.svc'), '').replaceAll("https://", '')),
              HomePageState.getSeparatorLine(context),
              Expanded(
                  child: RefreshIndicator(
                    onRefresh: onRefresh,
                    child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Visibility(
                              visible: homePage.markbookList.isNotEmpty,
                              child: Container(
                                margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 12),
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.03),
                                  borderRadius: BorderRadius.circular(20),
                                  //border: Border.all(color: Colors.white.withOpacity(.2), width: 1)
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    EmojiRichText(
                                      text: 'Átlagod: ${totalAvg.isNaN ? "nincs jegyed" : totalAvg.toStringAsFixed(2)} ${api.Generic.reactionForAvg(totalAvg)}',
                                      defaultStyle: const TextStyle(
                                        color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13.0,
                                      ),
                                      emojiStyle: const TextStyle(
                                          color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
                                          fontSize: 14.0,
                                          fontFamily: "Noto Color Emoji"
                                      ),
                                    ),
                                    EmojiRichText(
                                      text: 'Ösztöndíj indexed: ${totalAvg30.isNaN || totalAvg30 <= 0 ? "nincs jegyed" : totalAvg30.toStringAsFixed(2)} ${api.Generic.reactionForAvg(totalAvg30)}',
                                      defaultStyle: const TextStyle(
                                        color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13.0,
                                      ),
                                      emojiStyle: const TextStyle(
                                          color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
                                          fontSize: 14.0,
                                          fontFamily: "Noto Color Emoji"
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: homePage.markbookList.isNotEmpty ? Colors.white.withOpacity(0.03) : Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                mainAxisSize: MainAxisSize.max,
                                children: homePage.markbookList.isNotEmpty ? homePage.markbookList : <Widget>[
                                  Center(
                                    child: SizedBox(
                                      height: MediaQuery.of(context).size.width < MediaQuery.of(context).size.height ? MediaQuery.of(context).size.width * 0.10 : MediaQuery.of(context).size.height * 0.10,
                                      width: MediaQuery.of(context).size.width < MediaQuery.of(context).size.height ? MediaQuery.of(context).size.width * 0.10 : MediaQuery.of(context).size.height * 0.10,
                                      child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    api.Generic.randomLoadingComment(storage.DataCache.getNeedFamilyFriendlyComments()!),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(.2),
                                        fontWeight: FontWeight.w300,
                                        fontSize: 10
                                    ),
                                  )
                                ]
                              ),
                            ),
                          ],
                        ),
                    )
                  )
              ),
              HomePageState.getSeparatorLine(context),
              bottomnav.BottomNavigatorWidget(homePage: homePage),
            ],
          ),
        ],
      ),
      floatingActionButton: null
    );
  }
}

class PaymentsPageWidget extends StatelessWidget{
  final HomePageState homePage;
  final int totalMoney;
  const PaymentsPageWidget({super.key, required this.homePage, required this.totalMoney});

  Future<void> onRefresh() async{
    AppHaptics.lightImpact();
    homePage.onPaymentsRefresh();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              //topnav.TopNavigatorWidget(homePage: homePage, displayString: "Befizetendők", smallHintText: "$totalMoney Ft Van A Számládon 💸"),
              topnav.TopNavigatorWidget(homePage: homePage, displayString: "Befizetendők", smallHintText: "${totalMoney}Ft-ot költöttél az egyetemre 💸", loggedInUsername: storage.DataCache.getUsername()!, loggedInURL: storage.DataCache.getInstituteUrl()!.replaceAll(RegExp(r'/hallgato/MobileService\.svc'), '').replaceAll("https://", '')),
              HomePageState.getSeparatorLine(context),
              Expanded(
                  child: RefreshIndicator(
                      onRefresh: onRefresh,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        child: Container(
                          margin: const EdgeInsets.all(15),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: homePage.paymentsList.isNotEmpty ? Colors.white.withOpacity(0.03) : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              mainAxisSize: MainAxisSize.max,
                              children: homePage.paymentsList.isNotEmpty ? homePage.paymentsList : <Widget>[
                                Center(
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.width < MediaQuery.of(context).size.height ? MediaQuery.of(context).size.width * 0.10 : MediaQuery.of(context).size.height * 0.10,
                                    width: MediaQuery.of(context).size.width < MediaQuery.of(context).size.height ? MediaQuery.of(context).size.width * 0.10 : MediaQuery.of(context).size.height * 0.10,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  api.Generic.randomLoadingComment(storage.DataCache.getNeedFamilyFriendlyComments()!),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(.2),
                                      fontWeight: FontWeight.w300,
                                      fontSize: 10
                                  ),
                                )
                              ]
                          ),
                        ),
                      )
                  )
              ),
              HomePageState.getSeparatorLine(context),
              bottomnav.BottomNavigatorWidget(homePage: homePage),
            ],
          ),
        ],
      ),
      floatingActionButton: null
    );
  }
}

class PeriodsPageWidget extends StatelessWidget{
  final HomePageState homePage;
  final int currentSemester;
  const PeriodsPageWidget({super.key, required this.homePage, required this.currentSemester});

  Future<void> onRefresh() async{
    AppHaptics.lightImpact();
    homePage.onPeriodsRefresh();
  }

  String aOrAzDeterminer(int semester){
    switch(semester){
      case 0:
        return '';
      case 1:
        return 'az';
      case 5:
        return 'az';
      default:
        return 'A';
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
        body: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                //topnav.TopNavigatorWidget(homePage: homePage, displayString: "Időszakok", smallHintText: "Jelenleg ${currentSemester != -1 ? "${aOrAzDeterminer(currentSemester)} $currentSemester." : "gondolkodunk mi is van..."} ${currentSemester != -1 ? 'félév van' : ''} 🗓️", loggedInUsername: storage.DataCache.getUsername()!, loggedInURL: storage.DataCache.getInstituteUrl()!.replaceAll(RegExp(r'/hallgato/MobileService\.svc'), '').replaceAll("https://", '')),
                topnav.TopNavigatorWidget(homePage: homePage, displayString: "Időszakok", smallHintText: "${homePage.countActivePeriods} aktív, ${homePage.countFuturePeriods} jövőbeli, ${homePage.countExpiredPeriods} lejárt 🗓️", loggedInUsername: storage.DataCache.getUsername()!, loggedInURL: storage.DataCache.getInstituteUrl()!.replaceAll(RegExp(r'/hallgato/MobileService\.svc'), '').replaceAll("https://", '')),
                HomePageState.getSeparatorLine(context),
                Expanded(
                    child: RefreshIndicator(
                        onRefresh: onRefresh,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          child: Container(
                            margin: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: homePage.periodList.isNotEmpty ? Colors.white.withOpacity(0.03) : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                mainAxisSize: MainAxisSize.max,
                                children: homePage.periodList.isNotEmpty ? homePage.periodList : <Widget>[
                                  Center(
                                    child: SizedBox(
                                      height: MediaQuery.of(context).size.width < MediaQuery.of(context).size.height ? MediaQuery.of(context).size.width * 0.10 : MediaQuery.of(context).size.height * 0.10,
                                      width: MediaQuery.of(context).size.width < MediaQuery.of(context).size.height ? MediaQuery.of(context).size.width * 0.10 : MediaQuery.of(context).size.height * 0.10,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    api.Generic.randomLoadingComment(storage.DataCache.getNeedFamilyFriendlyComments()!),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(.2),
                                        fontWeight: FontWeight.w300,
                                        fontSize: 10
                                    ),
                                  )
                                ]
                            ),
                          ),
                        )
                    )
                ),
                HomePageState.getSeparatorLine(context),
                bottomnav.BottomNavigatorWidget(homePage: homePage),
              ],
            ),
          ],
        ),
        floatingActionButton: null
    );
  }
}

class MailsPageWidget extends StatelessWidget{
  final HomePageState homePage;
  const MailsPageWidget({super.key, required this.homePage});

  Future<void> onRefresh() async{
    AppHaptics.lightImpact();
    homePage.onMailRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                topnav.TopNavigatorWidget(homePage: homePage, displayString: "Üzenetek", smallHintText: "${homePage.unreadMailCount} olvasatlan üzeneted van 💌", loggedInUsername: storage.DataCache.getUsername()!, loggedInURL: storage.DataCache.getInstituteUrl()!.replaceAll(RegExp(r'/hallgato/MobileService\.svc'), '').replaceAll("https://", '')),
                HomePageState.getSeparatorLine(context),
                Expanded(
                    child: RefreshIndicator(
                        onRefresh: onRefresh,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          controller: homePage.currentMailPageController,
                          child: Container(
                            margin: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: homePage.mailList.isNotEmpty ? Colors.white.withOpacity(0.03) : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                mainAxisSize: MainAxisSize.max,
                                children: homePage.mailList.isNotEmpty ? homePage.mailList : <Widget>[
                                  Center(
                                    child: SizedBox(
                                      height: MediaQuery.of(context).size.width < MediaQuery.of(context).size.height ? MediaQuery.of(context).size.width * 0.10 : MediaQuery.of(context).size.height * 0.10,
                                      width: MediaQuery.of(context).size.width < MediaQuery.of(context).size.height ? MediaQuery.of(context).size.width * 0.10 : MediaQuery.of(context).size.height * 0.10,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    api.Generic.randomLoadingComment(storage.DataCache.getNeedFamilyFriendlyComments()!),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(.2),
                                        fontWeight: FontWeight.w300,
                                        fontSize: 10
                                    ),
                                  )
                                ]
                            ),
                          ),
                        )
                    )
                ),
                HomePageState.getSeparatorLine(context),
                bottomnav.BottomNavigatorWidget(homePage: homePage),
              ],
            ),
          ],
        ),
        floatingActionButton: null
    );
  }
}