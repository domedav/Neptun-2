import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

Future<void> saveString(String key, String value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

Future<void> saveInt(String key, int value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt(key, value);
}

Future<void> saveFloat(String key, double value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setDouble(key, value);
}

Future<void> saveStringList(String key, List<String> value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setStringList(key, value);
}

Future<String?> getString(String key) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

Future<int?> getInt(String key) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt(key);
}

Future<double?> getFloat(String key) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getDouble(key);
}

Future<List<String>?> getStringList(String key) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getStringList(key);
}

class DataCache{
  static Future<void> dataWipe() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.reload();
    _instance._localWipe();
  }

  void _localWipe(){
    _username = '';
    _password = '';
    _instituteUrl = '';
    _hasNetwork = false;
    _hasLogin = false;
    _hasCachedCalendar = false;
    _hasCachedMarkbook = false;
    _hasCachedPayments = false;
    _hasCachedFirstWeekEpoch = false;
    _hasCachedPeriods = false;
    _firstweekOfSemesterEpoch = 0;
    _isDemoAccount = false;
    setNeedFamilyFriendlyComments(_persistentSetting_familyFriendlyLoadingComments! ? 1 : 0);
    setNeedExamNotifications(_persistentSetting_showExamNotifications! ? 1 : 0);
    setNeedClassNotifications(_persistentSetting_showClassNotifications! ? 1 : 0);
    setNeedClassNotifications(_persistentSetting_showPaymentsNotifications! ? 1 : 0);
    setNeedClassNotifications(_persistentSetting_showPeriodsNotifications! ? 1 : 0);
    setAnalyticsFirstAppOpenTime(_persistentAnalytics_firstAppOpenTimeMs!);
    setAnalyticsNextRatePopupTime(_persistentAnalytics_nextRatePopupShowMs!);
    setAnalyticsRateNudgedAmount(_persistentAnalytics_userRateNudgedAmount!);
    setAnalyticsHasRatedApp(_persistentAnalytics_hasRatedApp! ? 1 : 0);
  }

  static final DataCache _instance = DataCache();

  late String? _username;
  late String? _password;
  late String? _instituteUrl;
  late bool _hasNetwork = false;
  late bool? _hasLogin = false;
  late bool? _hasCachedCalendar = false;
  late bool? _hasCachedMarkbook = false;
  late bool? _hasCachedPayments = false;
  late bool? _hasCachedPeriods = false;
  late bool? _hasCachedFirstWeekEpoch = false;
  late int? _firstweekOfSemesterEpoch = 0;
  late bool? _isDemoAccount = false;
  
  late bool? _persistentSetting_familyFriendlyLoadingComments = true;
  late bool? _persistentSetting_showExamNotifications = true;
  late bool? _persistentSetting_showClassNotifications = true;
  late bool? _persistentSetting_showPaymentsNotifications = true;
  late bool? _persistentSetting_showPeriodsNotifications = true;

  late int? _persistentAnalytics_firstAppOpenTimeMs = 0;
  late int? _persistentAnalytics_nextRatePopupShowMs = 0;
  late int? _persistentAnalytics_userRateNudgedAmount = 0;
  late bool? _persistentAnalytics_hasRatedApp = false;

  static Future<void> loadData() async{return _instance._loadData();}

  Future<void> _loadData() async{
    int? tmp;

    _username = await getString('Username');
    _password = await getString('Password');
    _instituteUrl = await getString('URL');

    tmp = await getInt('HasLogin');
    _hasLogin = tmp != null && tmp != 0;

    tmp = await getInt('HasCachedCalendar');
    _hasCachedCalendar = tmp != null && tmp != 0;

    tmp = await getInt('HasCachedMarkbook');
    _hasCachedMarkbook = tmp != null && tmp != 0;

    tmp = await getInt('HasCachedPayments');
    _hasCachedPayments = tmp != null && tmp != 0;

    tmp = await getInt('HasCachedPeriods');
    _hasCachedPeriods = tmp != null && tmp != 0;

    _hasNetwork = await Connectivity().checkConnectivity() != ConnectivityResult.none;
    Connectivity().onConnectivityChanged.listen((event) async {
      _hasNetwork = await Connectivity().checkConnectivity() != ConnectivityResult.none;
    });

    tmp = await getInt('HasCachedFirstWeekEpoch');
    _hasCachedFirstWeekEpoch = tmp != null && tmp != 0;

    tmp = await getInt('FirstWeekOfSemesterEpoch');
    _firstweekOfSemesterEpoch = tmp ?? 0;

    tmp = await getInt('IsDemoAccount');
    _isDemoAccount = tmp != null && tmp != 0;

    tmp = await getInt('SETTING_IsFamilyFriendlyLoading');
    _persistentSetting_familyFriendlyLoadingComments = tmp != null && tmp != 0;
    if(tmp == null){
      _persistentSetting_familyFriendlyLoadingComments = true;  // this is the default value, not false
    }

    tmp = await getInt('SETTING_IsNeedExamNotifications');
    _persistentSetting_showExamNotifications = tmp != null && tmp != 0;
    if(tmp == null){
      _persistentSetting_showExamNotifications = true;  // this is the default value, not false
    }

    tmp = await getInt('SETTING_IsNeedClassNotifications');
    _persistentSetting_showClassNotifications = tmp != null && tmp != 0;
    if(tmp == null){
      _persistentSetting_showClassNotifications = true;  // this is the default value, not false
    }

    tmp = await getInt('SETTING_IsNeedPaymentsNotifications');
    _persistentSetting_showPaymentsNotifications = tmp != null && tmp != 0;
    if(tmp == null){
      _persistentSetting_showPaymentsNotifications = true;  // this is the default value, not false
    }

    tmp = await getInt('SETTING_IsNeedPeriodsNotifications');
    _persistentSetting_showPeriodsNotifications = tmp != null && tmp != 0;
    if(tmp == null){
      _persistentSetting_showPeriodsNotifications = true;  // this is the default value, not false
    }

    tmp = await getInt('ANALYTICS_FirstAppOpenTime');
    _persistentAnalytics_firstAppOpenTimeMs = tmp ?? 0;

    tmp = await getInt('ANALYTICS_NextRatePopupTime');
    _persistentAnalytics_nextRatePopupShowMs = tmp ?? 0;

    tmp = await getInt('ANALYTICS_RateNudgeAmount');
    _persistentAnalytics_userRateNudgedAmount = tmp ?? 0;

    tmp = await getInt('ANALYTICS_HasRatedApp');
    _persistentAnalytics_hasRatedApp = tmp != null && tmp != 0;
  }

  static String? getUsername(){return _instance._username;}
  static Future<void> setUsername(String? value) async{
    _instance._username = value;
    await saveString('Username', value.toString());
  }

  static String? getPassword(){return _instance._password;}
  static Future<void> setPassword(String? value) async{
    _instance._password = value;
    await saveString('Password', value.toString());
  }

  static String? getInstituteUrl(){return _instance._instituteUrl;}
  static Future<void> setInstituteUrl(String? value) async{
    _instance._instituteUrl = value;
    await saveString('URL', value.toString());
  }

  static bool getHasNetwork(){return _instance._hasNetwork;}

  static bool? getHasLogin(){return _instance._hasLogin;}
  static Future<void> setHasLogin(int? value) async {
    _instance._hasLogin = value != null && value != 0;
    await saveInt('HasLogin', value ?? 0);
  }

  static bool? getHasCachedCalendar(){return _instance._hasCachedCalendar;}
  static Future<void> setHasCachedCalendar(int? value) async {
    _instance._hasCachedCalendar = value != null && value != 0;
    await saveInt('HasCachedCalendar', value ?? 0);
  }

  static bool? getHasCachedMarkbook(){return _instance._hasCachedMarkbook;}
  static Future<void> setHasCachedMarkbook(int? value) async {
    _instance._hasCachedMarkbook = value != null && value != 0;
    await saveInt('HasCachedMarkbook', value ?? 0);
  }

  static bool? getHasCachedPayments(){return _instance._hasCachedPayments;}
  static Future<void> setHasCachedPayments(int? value) async{
    _instance._hasCachedPayments = value != null && value != 0;
    await saveInt('HasCachedPayments', value ?? 0);
  }

  static bool? getHasCachedPeriods(){return _instance._hasCachedPeriods;}
  static Future<void> setHasCachedPeriods(int? value) async{
    _instance._hasCachedPeriods = value != null && value != 0;
    await saveInt('HasCachedPeriods', value ?? 0);
  }

  static bool? getHasCachedFirstWeekEpoch(){return _instance._hasCachedFirstWeekEpoch;}
  static Future<void> setHasCachedFirstWeekEpoch(int? value) async{
    _instance._hasCachedFirstWeekEpoch = value != null && value != 0;
    await saveInt('HasCachedFirstWeekEpoch', value ?? 0);
  }

  static int? getFirstWeekEpoch(){return _instance._firstweekOfSemesterEpoch;}
  static Future<void> setFirstWeekEpoch(int? value) async{
    _instance._firstweekOfSemesterEpoch = value ?? 0;
    await saveInt('FirstWeekOfSemesterEpoch', value ?? 0);
  }

  static bool? getIsDemoAccount(){return _instance._isDemoAccount;}
  static Future<void> setIsDemoAccount(int? value) async{
    _instance._isDemoAccount = value != null && value != 0;
    await saveInt('IsDemoAccount', value ?? 0);
  }

  static bool? getNeedFamilyFriendlyComments(){return _instance._persistentSetting_familyFriendlyLoadingComments;}
  static Future<void> setNeedFamilyFriendlyComments(int? value) async{
    _instance._persistentSetting_familyFriendlyLoadingComments = value != null && value != 0;
    await saveInt('SETTING_IsFamilyFriendlyLoading', value ?? 1);
  }

  static bool? getNeedExamNotifications(){return _instance._persistentSetting_showExamNotifications;}
  static Future<void> setNeedExamNotifications(int? value) async{
    _instance._persistentSetting_showExamNotifications = value != null && value != 0;
    await saveInt('SETTING_IsNeedExamNotifications', value ?? 1);
  }

  static bool? getNeedClassNotifications(){return _instance._persistentSetting_showClassNotifications;}
  static Future<void> setNeedClassNotifications(int? value) async{
    _instance._persistentSetting_showClassNotifications = value != null && value != 0;
    await saveInt('SETTING_IsNeedClassNotifications', value ?? 1);
  }

  static bool? getNeedPaymentsNotifications(){return _instance._persistentSetting_showPaymentsNotifications;}
  static Future<void> setNeedPaymentsNotifications(int? value) async{
    _instance._persistentSetting_showPaymentsNotifications = value != null && value != 0;
    await saveInt('SETTING_IsNeedPaymentsNotifications', value ?? 1);
  }

  static bool? getNeedPeriodsNotifications(){return _instance._persistentSetting_showPeriodsNotifications;}
  static Future<void> setNeedPeriodsNotifications(int? value) async{
    _instance._persistentSetting_showPeriodsNotifications = value != null && value != 0;
    await saveInt('SETTING_IsNeedPeriodsNotifications', value ?? 1);
  }

  static int? getAnalyticsFirstAppOpenTime(){return _instance._persistentAnalytics_firstAppOpenTimeMs;}
  static Future<void> setAnalyticsFirstAppOpenTime(int? value) async{
    _instance._persistentAnalytics_firstAppOpenTimeMs = value ?? 0;
    await saveInt('ANALYTICS_FirstAppOpenTime', value ?? 0);
  }

  static int? getAnalyticsNextRatePopupTime(){return _instance._persistentAnalytics_nextRatePopupShowMs;}
  static Future<void> setAnalyticsNextRatePopupTime(int? value) async{
    _instance._persistentAnalytics_nextRatePopupShowMs = value ?? 0;
    await saveInt('ANALYTICS_NextRatePopupTime', value ?? 0);
  }

  static int? getAnalyticsRateNudgedAmount(){return _instance._persistentAnalytics_userRateNudgedAmount;}
  static Future<void> setAnalyticsRateNudgedAmount(int? value) async{
    _instance._persistentAnalytics_userRateNudgedAmount = value ?? 0;
    await saveInt('ANALYTICS_RateNudgeAmount', value ?? 0);
  }

  static bool? getAnalyticsHasRatedApp(){return _instance._persistentAnalytics_hasRatedApp;}
  static Future<void> setAnalyticsHasRatedApp(int? value) async{
    _instance._persistentAnalytics_hasRatedApp = value != null && value != 0;
    await saveInt('ANALYTICS_HasRatedApp', value ?? 0);
  }
}