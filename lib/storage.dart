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
  static final DataCache _instance = DataCache();

  late String? _username;
  late String? _password;
  late String? _instituteUrl;
  late bool _hasNetwork = false;
  late bool? _hasLogin = false;
  late bool? _hasCachedCalendar = false;
  late bool? _hasCachedMarkbook = false;


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

    _hasNetwork = await Connectivity().checkConnectivity() != ConnectivityResult.none;
    Connectivity().onConnectivityChanged.listen((event) async {
      _hasNetwork = await Connectivity().checkConnectivity() != ConnectivityResult.none;
    });
  }

  static String? getUsername(){return _instance._username;}
  static Future<void> setUsername(String? value) async{
    _instance._username = value;
    saveString('Username', value.toString());
  }

  static String? getPassword(){return _instance._password;}
  static Future<void> setPassword(String? value) async{
    _instance._password = value;
    saveString('Password', value.toString());
  }

  static String? getInstituteUrl(){return _instance._instituteUrl;}
  static Future<void> setInstituteUrl(String? value) async{
    _instance._instituteUrl = value;
    saveString('URL', value.toString());
  }

  static bool getHasNetwork(){return _instance._hasNetwork;}

  static bool? getHasLogin(){return _instance._hasLogin;}
  static Future<void> setHasLogin(int? value) async {
    _instance._hasLogin = value != null && value != 0;
    saveInt('HasLogin', value ?? 0);
  }

  static bool? getHasCachedCalendar(){return _instance._hasCachedCalendar;}
  static Future<void> setHasCachedCalendar(int? value) async {
    _instance._hasCachedCalendar = value != null && value != 0;
    saveInt('HasCachedCalendar', value ?? 0);
  }

  static bool? getHasCachedMarkbook(){return _instance._hasCachedMarkbook;}
  static Future<void> setHasCachedMarkbook(int? value) async {
    _instance._hasCachedMarkbook = value != null && value != 0;
    saveInt('HasCachedMarkbook', value ?? 0);
  }
}