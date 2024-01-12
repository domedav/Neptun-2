import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:neptun2/Misc/popup.dart';
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

  late final List<Widget> markbookList = <Widget>[].toList();

  late final List<Widget> paymentsList = <Widget>[].toList();
  late final List<Widget> periodList = <Widget>[].toList();

  bool canDoCalendarPaging = true;
  int weeksSinceStart = 1;
  int currentWeekOffset = 1;
  late TabController calendarTabController;
  int currentView = 0;
  String calendarGreetText = "";

  int totalCredits = 0;
  int totalMoney = 0;
  double totalAvg = 0;

  int currentSemester = -1;

  @override
  void initState() {
    super.initState();

    FlutterNativeSplash.remove();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color.fromRGBO(0x22, 0x22, 0x22, 1.0), // navigation bar color
      statusBarColor: Color.fromRGBO(0x22, 0x22, 0x22, 1.0), // status bar color
    ));

    calendarTabController = TabController(length: 5, vsync: this);
    weeksSinceStart = calcPassedWeeks();

    Future.delayed(Duration.zero, () async {
      await fetchCalendar();
    }).then((value) {
      setupCalendar();
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

    setupCalendarGreetText();

    PopupWidgetHandler(homePage: this);

    //api.InstitutesRequest.getFirstStudyweek();

    /*api.PeriodsRequest.getPeriods().then((value) {
      for (var item in value!){
        final startTime = DateTime.fromMillisecondsSinceEpoch(item.startEpoch);
        final endTime = DateTime.fromMillisecondsSinceEpoch(item.endEpoch);
        log("${item.name} - $startTime -- $endTime --- ${item.isActive}");
      }
    });*/
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
      canDoCalendarPaging = false;
      calendarEntries.clear();
      mondayCalendar.clear();
      tuesdayCalendar.clear();
      wednessdayCalendar.clear();
      thursdayCalendar.clear();
      fridayCalendar.clear();
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

  void setupCalendar(){
    setState(() {
      _setupCalendar();
      canDoCalendarPaging = true;
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

  void _setupCalendar(){
    int i = 1;
    int prev = 0;
    final currWeekday = DateTime.now().weekday;
    for(var item in calendarEntries){
      final wkday = DateTime.fromMillisecondsSinceEpoch(item.startEpoch).weekday;
      if(prev != wkday){
        i = 1;
        prev = wkday;
      }
      switch(wkday){
        case 1:
          mondayCalendar.add(t_table.TimetableElementWidget(
            entry: item,
            position: i,
          ));
          break;
        case 2:
          tuesdayCalendar.add(t_table.TimetableElementWidget(
            entry: item,
            position: i,
          ));
          break;
        case 3:
          wednessdayCalendar.add(t_table.TimetableElementWidget(
            entry: item,
            position: i,
          ));
          break;
        case 4:
          thursdayCalendar.add(t_table.TimetableElementWidget(
            entry: item,
            position: i,
          ));
          break;
        case 5:
          fridayCalendar.add(t_table.TimetableElementWidget(
            entry: item,
            position: i,
          ));
          break;
      }
      i++;
    }
    if(mondayCalendar.isEmpty){
      mondayCalendar.add(const t_table.FreedayElementWidget());
    }
    if(tuesdayCalendar.isEmpty){
      tuesdayCalendar.add(const t_table.FreedayElementWidget());
    }
    if(wednessdayCalendar.isEmpty){
      wednessdayCalendar.add(const t_table.FreedayElementWidget());
    }
    if(thursdayCalendar.isEmpty){
      thursdayCalendar.add(const t_table.FreedayElementWidget());
    }
    if(fridayCalendar.isEmpty){
      fridayCalendar.add(const t_table.FreedayElementWidget());
    }
    calendarTabController.index = currWeekday - 1 > 4 ? 0 : currWeekday - 1;
  }
  void _setupMarkbook(){
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
    var currCredits = 0;
    var hasCompleted = false;
    var hasIncomplete = false;
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
      ));
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
        ));
        if (item.grade >= 2) {
          currCredits += item.credit;
          totalAvg += item.grade * item.credit;
        }
      }
      totalAvg /= currCredits;
    }
  }

  void _setupPayments(){

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
      periodList.add(priods.PeriodsElementWidget(
        displayName: item.name,
        formattedStartTime: '${api.Generic.monthToText(starttime.month)} ${starttime.day}',
        formattedStartTimeYear: '${starttime.year}',
        formattedEndTime: '${api.Generic.monthToText(endtime.month)} ${endtime.day}',
        formattedEndTimeYear: '${endtime.year}',
        isActive: item.isActive,
        periodType: item.type,
        startTime: item.startEpoch,
        endTime: item.endEpoch,
      ));
      if(currentSemester == -1) {
        currentSemester = item.partofSemester;
      }
    }
  }

  Future<void> stepCalendar_Back() async{
    currentWeekOffset--;
    await onCalendarRefresh();
  }
  Future<void> stepCalendar_Forward() async{
    currentWeekOffset++;
    await onCalendarRefresh();
  }

  Future<void> fetchCalendar() async{
    bool hasCachedCalendar = storage.DataCache.getHasCachedCalendar() ?? false;
    final cacheTime = await storage.getString('CalendarCacheTime');

    if(!hasCachedCalendar && !storage.DataCache.getHasNetwork()){
      return;
    }

    // if we had a save, and the cached value is not older than a day, we can load that up
    if(hasCachedCalendar && cacheTime != null && (DateTime.now().millisecondsSinceEpoch - DateTime.parse(cacheTime).millisecondsSinceEpoch) < const Duration(hours: 24).inMilliseconds) {
      final len = await storage.getInt('CachedCalendarLength');
      for(int i = 0; i < len!; i++){
        final calEntry = await storage.getString('CachedCalendar_$i');
        calendarEntries.add(api.CalendarEntry('0', '0', 'NULL', 'NULL', false).fillWithExisting(calEntry!));
      }
      storage.DataCache.setHasCachedFirstWeekEpoch(1); // dont fetch this, as there is still no network
      return;
    }
    //otherwise, just fetch again
    final isWeekend = DateTime.now().weekday == DateTime.saturday || DateTime.now().weekday == DateTime.sunday ? 1 : 0;
    final request = await api.CalendarRequest.makeCalendarRequest(api.CalendarRequest.getCalendarOneWeekJSON(storage.DataCache.getUsername()!, storage.DataCache.getPassword()!, currentWeekOffset + isWeekend));
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

  Future<void> onCalendarRefresh() async{
    clearCalendar();
    await storage.DataCache.setHasCachedCalendar(0);
    await storage.DataCache.setHasCachedFirstWeekEpoch(0);
    await fetchCalendar();
    setupCalendar();
  }
  Future<void> onMarkbookRefresh() async{
    clearMarkbook();
    await storage.DataCache.setHasCachedMarkbook(0);
    await fetchMarkbook();
    setupMarkbook();
  }
  Future<void> onPaymentsRefresh() async{
    clearPayments();
    await storage.DataCache.setHasCachedPayments(0);
    await fetchPayments();
    setupPayments();
  }
  Future<void> onPeriodsRefresh()async{
    clearPeriods();
    await storage.DataCache.setHasCachedPeriods(0);
    await fetchPeriods();
    setupPeriods();
  }

  int calcPassedWeeks() {
    final epochsemester = storage.DataCache.getFirstWeekEpoch()!;
    final determiner = epochsemester > 0 ? DateTime.fromMillisecondsSinceEpoch(epochsemester) : null;
    final now = DateTime.now();
    final yearlessNow = DateTime(1, now.month, now.day);
    final sepOne = DateTime(yearlessNow.year - 1, epochsemester > 0 ? determiner!.month : 9, epochsemester > 0 ? determiner!.day : 1); // first week

    final timepassSinceSepOne = Duration(milliseconds: (yearlessNow.millisecondsSinceEpoch - sepOne.millisecondsSinceEpoch));
    final weeksPassed = timepassSinceSepOne.inDays / 7;
    /*
    // Find the most recent Monday on or before the current date
    final mondayOffset = (now.weekday - 1) % 7;
    final monday = now.subtract(Duration(days: mondayOffset));

    final elapsedWeeks = (monday.difference(sepOne).inDays / 7).floor();
    final isWeekend = now.weekday == DateTime.saturday || now.weekday == DateTime.sunday ? 1 : 0;

    return elapsedWeeks + currentWeekOffset - 1 + isWeekend;*/
    return weeksPassed.floor() + currentWeekOffset - 1;
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
              child: CalendarPageWidget(homePage: this, greetText: calendarGreetText)
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
  const CalendarPageWidget({super.key, required this.homePage, required this.greetText});

  Future<void> onRefresh() async{
    homePage.onCalendarRefresh();
  }

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
                  tabs: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: const Tab(
                        text: "Hétfő",
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: const Tab(
                        text: "Kedd",
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: const Tab(
                        text: "Szerda",
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: const Tab(
                        text: "Csütörtök",
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: const Tab(
                        text: "Péntek",
                      ),
                    ),
                  ],
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
                  onBackPressed: homePage.stepCalendar_Back,
                  onForwardPressed: homePage.stepCalendar_Forward,
                  canDoPaging: homePage.canDoCalendarPaging,
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: homePage.calendarTabController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: <Widget>[
                    RefreshIndicator(
                      onRefresh: onRefresh,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(
                            decelerationRate: ScrollDecelerationRate.fast
                        ),
                        scrollDirection: Axis.vertical,
                        child: Container(
                          margin: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: homePage.mondayCalendar.isNotEmpty ? Colors.white.withOpacity(0.03) : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.max,
                            children: homePage.mondayCalendar.isNotEmpty ? homePage.mondayCalendar : <Widget>[
                              Center(
                                child: SizedBox(
                                  height: MediaQuery.of(context).size.width < MediaQuery.of(context).size.height ? MediaQuery.of(context).size.width * 0.10 : MediaQuery.of(context).size.height * 0.10,
                                  width: MediaQuery.of(context).size.width < MediaQuery.of(context).size.height ? MediaQuery.of(context).size.width * 0.10 : MediaQuery.of(context).size.height * 0.10,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    RefreshIndicator(
                      onRefresh: onRefresh,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        child: Container(
                          margin: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: homePage.tuesdayCalendar.isNotEmpty ? Colors.white.withOpacity(0.03) : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.max,
                            children: homePage.tuesdayCalendar.isNotEmpty ? homePage.tuesdayCalendar : <Widget>[
                              Center(
                                child: SizedBox(
                                  height: MediaQuery.of(context).size.width < MediaQuery.of(context).size.height ? MediaQuery.of(context).size.width * 0.10 : MediaQuery.of(context).size.height * 0.10,
                                  width: MediaQuery.of(context).size.width < MediaQuery.of(context).size.height ? MediaQuery.of(context).size.width * 0.10 : MediaQuery.of(context).size.height * 0.10,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    RefreshIndicator(
                      onRefresh: onRefresh,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        child: Container(
                          margin: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: homePage.wednessdayCalendar.isNotEmpty ? Colors.white.withOpacity(0.03) : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.max,
                            children: homePage.wednessdayCalendar.isNotEmpty ? homePage.wednessdayCalendar : <Widget>[
                              Center(
                                child: SizedBox(
                                  height: MediaQuery.of(context).size.width < MediaQuery.of(context).size.height ? MediaQuery.of(context).size.width * 0.10 : MediaQuery.of(context).size.height * 0.10,
                                  width: MediaQuery.of(context).size.width < MediaQuery.of(context).size.height ? MediaQuery.of(context).size.width * 0.10 : MediaQuery.of(context).size.height * 0.10,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    RefreshIndicator(
                      onRefresh: onRefresh,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        child: Container(
                          margin: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: homePage.thursdayCalendar.isNotEmpty ? Colors.white.withOpacity(0.03) : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.max,
                            children: homePage.thursdayCalendar.isNotEmpty ? homePage.thursdayCalendar : <Widget>[
                              Center(
                                child: SizedBox(
                                  height: MediaQuery.of(context).size.width < MediaQuery.of(context).size.height ? MediaQuery.of(context).size.width * 0.10 : MediaQuery.of(context).size.height * 0.10,
                                  width: MediaQuery.of(context).size.width < MediaQuery.of(context).size.height ? MediaQuery.of(context).size.width * 0.10 : MediaQuery.of(context).size.height * 0.10,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    RefreshIndicator(
                      onRefresh: onRefresh,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        child: Container(
                          margin: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: homePage.fridayCalendar.isNotEmpty ? Colors.white.withOpacity(0.03) : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.max,
                            children: homePage.fridayCalendar.isNotEmpty ? homePage.fridayCalendar : <Widget>[
                              Center(
                                child: SizedBox(
                                  height: MediaQuery.of(context).size.width < MediaQuery.of(context).size.height ? MediaQuery.of(context).size.width * 0.10 : MediaQuery.of(context).size.height * 0.10,
                                  width: MediaQuery.of(context).size.width < MediaQuery.of(context).size.height ? MediaQuery.of(context).size.width * 0.10 : MediaQuery.of(context).size.height * 0.10,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
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
          onPressed: homePage.canDoCalendarPaging ? (() {
            homePage.currentWeekOffset = 1;
            homePage.onCalendarRefresh();
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
                        physics: const BouncingScrollPhysics(
                            decelerationRate: ScrollDecelerationRate.fast
                        ),
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
              topnav.TopNavigatorWidget(homePage: homePage, displayString: "Befizetendők", smallHintText: "$totalMoney Ft Van A Neptun Számládon 💸"),
              HomePageState.getSeparatorLine(context),
              Expanded(
                  child: RefreshIndicator(
                      onRefresh: onRefresh,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(
                            decelerationRate: ScrollDecelerationRate.fast
                        ),
                        scrollDirection: Axis.vertical,
                        child: Container(

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

  @override
  Widget build(BuildContext context){
    return Scaffold(
        body: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                topnav.TopNavigatorWidget(homePage: homePage, displayString: "Időszakok", smallHintText: "Jelenleg ${currentSemester != -1 ? "az $currentSemester." : "egy"} félév van 🗓️"),
                HomePageState.getSeparatorLine(context),
                Expanded(
                    child: RefreshIndicator(
                        onRefresh: onRefresh,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(
                              decelerationRate: ScrollDecelerationRate.fast
                          ),
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