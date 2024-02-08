import 'dart:async';
import 'dart:developer' as debug;
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:neptun2/notifications.dart';
import 'package:neptun2/Misc/emojirich_text.dart';
import 'package:neptun2/Misc/popup.dart';
import 'package:neptun2/PaymentsElements/payment_element_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../API/api_coms.dart' as api;
import '../storage.dart' as storage;
import '../TimetableElements/timetable_element_widget.dart' as t_table;
import '../MarkbookElements/markbook_element_widget.dart' as mbook;
import '../PeriodsElements/periods_element_widget.dart' as priods;
import '../Navigator/bottomnavigator.dart' as bottomnav;
import '../Navigator/topnavigator.dart' as topnav;

class HomePage extends StatefulWidget{
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin{

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

  void setBlurComplex(bool state){
    setState(() {
      _showBlur = state;

      if(state) {
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: Color.fromRGBO(0x0C, 0x0C, 0x0C, 1.0), // navigation bar color
            statusBarColor: Color.fromRGBO(0x1A, 0x1A, 0x1A, 1.0), // status bar color
        ));
        return;
      }
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color.fromRGBO(0x22, 0x22, 0x22, 1.0), // navigation bar color
        statusBarColor: Color.fromRGBO(0x22, 0x22, 0x22, 1.0), // status bar color
      ));
    });
  }

  late List<api.CalendarEntry> calendarEntries = <api.CalendarEntry>[].toList();
  late List<api.Subject> markbookEntries = <api.Subject>[].toList();
  late List<api.CashinEntry> paymentsEntries = <api.CashinEntry>[].toList();
  late List<api.PeriodEntry> periodEntries = <api.PeriodEntry>[].toList();

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

  late final LinkedScrollControllerGroup bottomnavScrollCntroller;
  late final ScrollController bottomnavController;

  bool canDoCalendarPaging = false;
  int weeksSinceStart = 1;
  int currentWeekOffset = 1;
  late TabController calendarTabController;
  int currentView = 0;
  String calendarGreetText = "";

  int totalCredits = 0;
  int totalMoney = 0;
  double totalAvg = 0;

  int currentSemester = -1;

  double bottomNavSwitchValue = 0.0;
  bool bottomNavCanNavigate = true;
  static const int maxBottomNavWidgets = 4;

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

    bottomnavScrollCntroller = LinkedScrollControllerGroup();
    bottomnavController = bottomnavScrollCntroller.addAndGet();

    AppNotifications.initialize();
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
    });


    weeksSinceStart = calcPassedWeeks();

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
  }

  void setupCalendarGreetText(){
    final currentTimeHour = DateTime.now().hour;
    if(currentTimeHour > 1 && currentTimeHour <= 6){
      setState(() {
        calendarGreetText = "Szép Hajnalt 🥛";
      });
    }
    else if(currentTimeHour > 6 && currentTimeHour <= 9){
      setState(() {
        calendarGreetText = "Jó Reggelt ☕";
      });
    }
    else if(currentTimeHour > 9 && currentTimeHour <= 13){
      setState(() {
        calendarGreetText = "Szép Napot 🍷";
      });
    }
    else if(currentTimeHour > 13 && currentTimeHour <= 17){
      setState(() {
        calendarGreetText = "Jó Délutánt 🥂";
      });
    }
    else if(currentTimeHour > 17 && currentTimeHour <= 21){
      setState(() {
        calendarGreetText = "Szép Estét 🍻";
      });
    }
    else if(currentTimeHour > 21 || currentTimeHour <= 1){
      setState(() {
        calendarGreetText = "Jó Éjszakát 🍹";
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
      if(daysTillExam <= 1){
        await AppNotifications.scheduleNotification('Vizsga Emlékeztető!', '"${item.title}" tárgyból vizsgád lesz MA!', DateTime(now.year, now.month, now.day + i, 06, 00), 0);
        continue;
      }
      await AppNotifications.scheduleNotification('Vizsga Emlékeztető!', '"${item.title}" tárgyból vizsgád lesz $i nap múlva!', DateTime(now.year, now.month, now.day + i, 09, 00), 0);
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
          await AppNotifications.scheduleNotification('Befizetés', '${item.ammount}Ft-al lógsz. Fizesd be! (Nincs Időhatár)', DateTime(now.year, now.month, now.day + i, 11, 00),2 );
        }
        continue;
      }
      final daysRemaining = (Duration(milliseconds: item.dueDateMs) - Duration(milliseconds: now.millisecondsSinceEpoch)).inDays;
      final time = DateTime.fromMillisecondsSinceEpoch(item.dueDateMs);
      for(int i = 0; i <= daysRemaining; i++){
        await AppNotifications.scheduleNotification('Befizetés', '${item.ammount}Ft-al lógsz. Fizesd be: ${daysRemaining > 61 ? "(${time.year})" : ""} ${api.Generic.monthToText(time.month)} ${time.day}-ig!', DateTime(now.year, now.month, now.day + i, 11, 00), 2);
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
      await AppNotifications.scheduleNotification('Időszak', '"${api.Generic.capitalizePeriodText(item.name)}" idószak lesz HOLNAP!', DateTime(time.year, time.month, time.day - 1, 11, 00), 3);
      await AppNotifications.scheduleNotification('Időszak', '"${api.Generic.capitalizePeriodText(item.name)}" idószak van MA!', DateTime(time.year, time.month, time.day, 06, 00), 3);
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
    calendarTabController.index = currWeekday - 1 > 6 ? 0 : currWeekday - 1;
    Future.delayed(Duration.zero,()async{
      await _setupClassesNotifications(_classesNotificationList);
    });
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
  }

  void _fillOneCalendarElement(BuildContext context, List<Widget> w, String name, bool isLoading){
    /*if(!isLoading && w.isEmpty){
      return;
    }*/
    calendarTabs.add(Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Tab(
        text: name,
      ),
    ));
    calendarTabViews.add(RefreshIndicator(
      onRefresh: onCalendarRefresh,
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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
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
    _fillOneCalendarElement(context, sundayCalendar, 'Varárnap', isLoading);
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
    if(markbookEntries.isEmpty){
      totalCredits = 0;
      totalAvg = 5;
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
    totalAvg /= currCredits;
  }

  void _markbookCalcGhostAvg(){
    if(markbookEntries.isEmpty){
      return;
    }
    var currCredits = 0;
    totalAvg = 0;
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
      paymentsList.add(PaymentElementWidget(ammount: item.ammount, dueDateMs: item.dueDateMs, name: item.comment));
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

    //Map<String, List<api.PeriodType>> values = Map<String, List<api.PeriodType>>.identity();
    for(var item in periodEntries){
      final starttime = DateTime.fromMillisecondsSinceEpoch(item.startEpoch);
      final endtime = DateTime.fromMillisecondsSinceEpoch(item.endEpoch);
      final now = DateTime.now().millisecondsSinceEpoch;
      if(now > endtime.millisecondsSinceEpoch){
        continue; // expired
      }
      if(prevSemester == -1){
        prevSemester = item.partofSemester;
      }
      else if(item.partofSemester != prevSemester){
        periodList.add(
            Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 30),
              color: Colors.white.withOpacity(0.3),
            )
        );
        prevSemester = item.partofSemester;
      }
      if(!item.isActive){ // exclude today
        _periodsNotificationList.add(item);
      }
      periodList.add(priods.PeriodsElementWidget(
        displayName: api.Generic.capitalizePeriodText(item.name),
        formattedStartTime: '${api.Generic.monthToText(starttime.month)} ${starttime.day}',
        formattedStartTimeYear: '${starttime.year}',
        formattedEndTime: '${api.Generic.monthToText(endtime.month)} ${endtime.day}',
        formattedEndTimeYear: '${endtime.year}',
        isActive: item.isActive,
        periodType: item.type,
        startTime: item.startEpoch,
        endTime: (DateTime.fromMillisecondsSinceEpoch(item.endEpoch).add(const Duration(days: 1)).millisecondsSinceEpoch), // utolsó nap is beleszámít
      ));
      if(currentSemester == -1) {
        currentSemester = item.partofSemester;
      }
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
            text: '🤩Szünet Van!🤩',
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

  Future<void> stepCalendarBack() async{
    currentWeekOffset--;
    HapticFeedback.lightImpact();
    await onCalendarRefresh();
  }
  Future<void> stepCalendarForward() async{
    currentWeekOffset++;
    HapticFeedback.lightImpact();
    await onCalendarRefresh();
  }

  Future<List<api.CalendarEntry>> fetchCalendarToList(int offset) async{
    final request = await api.CalendarRequest.makeCalendarRequest(api.CalendarRequest.getCalendarOneWeekJSON(storage.DataCache.getUsername()!, storage.DataCache.getPassword()!, currentWeekOffset + offset/* + isWeekend*/));
    final list = api.CalendarRequest.getCalendarEntriesFromJSON(request);
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
      storage.DataCache.setHasCachedFirstWeekEpoch(1); // dont fetch this, as there is still no network
      return;
    }
    //otherwise, just fetch again
    //final isWeekend = DateTime.now().weekday == DateTime.saturday || DateTime.now().weekday == DateTime.sunday ? 1 : 0;
    final request = await api.CalendarRequest.makeCalendarRequest(api.CalendarRequest.getCalendarOneWeekJSON(storage.DataCache.getUsername()!, storage.DataCache.getPassword()!, currentWeekOffset/* + isWeekend*/));
    calendarEntries = api.CalendarRequest.getCalendarEntriesFromJSON(request);
    if(currentWeekOffset == 1) {
      storage.saveInt('CachedCalendarLength', calendarEntries.length);
      //cache calendar
      for (int i = 0; i < calendarEntries.length; i++) {
        storage.saveString('CachedCalendar_$i', calendarEntries[i].toString());
      }

      storage.saveString('CalendarCacheTime', DateTime.now().toString());
    }
    storage.DataCache.setHasCachedCalendar(1);

    final firstWeekOfSemester = await api.InstitutesRequest.getFirstStudyweek();
    storage.DataCache.setHasCachedFirstWeekEpoch(1);
    await storage.DataCache.setFirstWeekEpoch(firstWeekOfSemester);
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
        paymentsEntries.add(api.CashinEntry(0, 0, 'NULL', 'NULL').fillWithExisting(calEntry!));
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
        periodEntries.add(api.PeriodEntry("ERROR", 0, 0, 0).fillWithExisting(calEntry!));
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

  Timer? _calendarTimer;

  bool _calendarDebounce = false;
  Future<void> onCalendarRefresh() async{
    if(!storage.DataCache.getHasNetwork() || _calendarDebounce){
      return;
    }
    if(_calendarTimer != null){
      _calendarTimer!.cancel();
    }
    clearCalendar();
    setupCalendarController(false, true);
    _calendarTimer = Timer(const Duration(milliseconds: 700), () async {
      _calendarDebounce = true;
      setState(() {
        canDoCalendarPaging = false;
      });
      await storage.DataCache.setHasCachedCalendar(0);
      await storage.DataCache.setHasCachedFirstWeekEpoch(0);
      await fetchCalendar();
      setupCalendar(false);
      _calendarDebounce = false;
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
    //final isWeekend = now.weekday == DateTime.saturday || now.weekday == DateTime.sunday ? 1 : 0;

    /*
    // Find the most recent Monday on or before the current date
    final mondayOffset = (now.weekday - 1) % 7;
    final monday = now.subtract(Duration(days: mondayOffset));

    final elapsedWeeks = (monday.difference(sepOne).inDays / 7).floor();

    return elapsedWeeks + currentWeekOffset - 1 + isWeekend;*/
    return weeksPassed.floor() + currentWeekOffset - 1;// + isWeekend;
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
  }

  static Container getSeparatorLine(BuildContext context){
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.2),
              Colors.white.withOpacity(0.4),
              Colors.white.withOpacity(0.4),
              Colors.white.withOpacity(0.2),
              Colors.white.withOpacity(0.1),
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
              child: MarkbookPageWidget(homePage: this, totalCredits: totalCredits, totalAvg: totalAvg,)
          ),
          Visibility(
              visible: currentView == 2,
              child: PaymentsPageWidget(homePage: this, totalMoney: totalMoney)
          ),
          Visibility(
            visible: currentView == 3,
            child: PeriodsPageWidget(homePage: this, currentSemester: currentSemester),
          ),
          GestureDetector(
            onLongPress: (){
              HapticFeedback.lightImpact();
              final val = currentView + 1 > HomePageState.maxBottomNavWidgets - 1 ? 0 : currentView + 1;
              switchView(val);
            },
          ),
          Visibility(
            visible: _showBlur,
            child: Positioned.fill(
              child: BackdropFilter(
                 filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                 child: Container(
                   color: Colors.black.withOpacity(0.4),
                 ),
               ),
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
              topnav.TopNavigatorWidget(homePage: homePage, displayString: "Órarend", smallHintText: greetText),
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
                    borderRadius: BorderRadius.circular(40),
                  ),
                  onTap: (index){
                    return;
                  },
                ),
              ),
              HomePageState.getSeparatorLine(context),
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  color: homePage.mondayCalendar.isNotEmpty ? Colors.white.withOpacity(0.03) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: t_table.WeekoffseterElementWidget(
                  week: homePage.weeksSinceStart,
                  from: homePage.calendarEntries.isEmpty ? null : DateTime.fromMillisecondsSinceEpoch(homePage.calendarEntries[0].startEpoch),
                  to: homePage.calendarEntries.isEmpty ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(homePage.calendarEntries[homePage.calendarEntries.length - 1].endEpoch),
                  onBackPressed: homePage.stepCalendarBack,
                  onForwardPressed: homePage.stepCalendarForward,
                  canDoPaging: homePage.canDoCalendarPaging,
                  homePage: homePage,
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
      floatingActionButton: Visibility(
        visible: homePage.currentWeekOffset != 1 && homePage.canDoCalendarPaging,
        child: FloatingActionButton(
          onPressed: homePage.canDoCalendarPaging ? (() async {
            homePage.currentWeekOffset = 1;
            await homePage.onCalendarRefresh();
          }
          ) : null,
          backgroundColor: const Color.fromRGBO(0x4F, 0x69, 0x6E, 1.0),
          child: const Icon(
            Icons.home_outlined,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: _FloatingButtonOffset.getInstance(1.04, 0.4),
    );
  }
}

class _FloatingButtonOffset extends FloatingActionButtonLocation{
  static _FloatingButtonOffset? Instance = _FloatingButtonOffset();
  static _FloatingButtonOffset getInstance(double offsetX, double offsetY){
    if(Instance == null){
      final fbo = _FloatingButtonOffset();
      fbo.offsetX = offsetX;
      fbo.offsetY = offsetY;
      return fbo;
    }
    Instance!.offsetX = offsetX;
    Instance!.offsetY = offsetY;
    return Instance!;
  }

  late double offsetY;
  late double offsetX;
  _FloatingButtonOffset();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double x = (scaffoldGeometry.scaffoldSize.width - scaffoldGeometry.floatingActionButtonSize.width) / offsetX;
    final double y = scaffoldGeometry.scaffoldSize.height - scaffoldGeometry.floatingActionButtonSize.height / offsetY;
    return Offset(x, y);
  }
}

class MarkbookPageWidget extends StatelessWidget{
  final HomePageState homePage;
  final int totalCredits;
  final double totalAvg;
  const MarkbookPageWidget({super.key, required this.homePage, required this.totalCredits, required this.totalAvg});

  Future<void> onRefresh() async{
    homePage.onMarkbookRefresh();
  }

  String reactionForAvg(double avg){
    if(avg >= 5.0){
      return "💀";
    }
    else if(avg >= 4.25){
      return "🤓";
    }
    else if(avg >= 3.75){
      return "😌";
    }
    else if(avg >= 2.75){
      return "😐";
    }
    else if(avg >= 2){
      return "😬";
    }
    else{
      return "😞";
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
              topnav.TopNavigatorWidget(homePage: homePage, displayString: "Tantárgyak", smallHintText: "Össz Kredited: $totalCredits🎖️\nÁtlagod: ${totalAvg.toStringAsFixed(2)} ${reactionForAvg(totalAvg)}"),
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
              topnav.TopNavigatorWidget(homePage: homePage, displayString: "Befizetendők", smallHintText: "${totalMoney}Ft-ot Költöttél Az Egyetemre 💸"),
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
    homePage.onPeriodsRefresh();
  }

  String aOrAzDeterminer(int semester){
    switch(semester){
      case 0:
        return '';
      case 1:
        return 'Az';
      case 5:
        return 'Az';
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
                topnav.TopNavigatorWidget(homePage: homePage, displayString: "Időszakok", smallHintText: "Jelenleg ${currentSemester != -1 ? "${aOrAzDeterminer(currentSemester)} $currentSemester." : "Egy"} Félév Van 🗓️"),
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