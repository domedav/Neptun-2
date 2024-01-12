import 'dart:convert' as conv;
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../storage.dart' as storage;

class URLs{
  static const String INSTITUTIONS_URL = "https://mobilecloudservice.cloudapp.net/MobileServiceLib/MobileCloudService.svc/GetAllNeptunMobileUrls";
  static const String TRAININGS_URL = "/GetTrainings";
  static const String CALENDAR_URL = "/GetCalendarData";
  static const String PERIODTERMS_URL = "/GetPeriodTerms";
  static const String PERIODS_URL = "/GetPeriods";
  static const String GETCASHIN_URL = "/GetCashinData";
  static const String CURRICULUMS_URL = "/GetCurriculums";
  static const String MARKBOOK_URL = "/GetMarkbookData";
}

class _APIRequest{
  static Future<String> postRequest(Uri url, String requestBody) async{
    HttpOverrides.global = NeptunCerts.getInstance();

    final client = http.Client();
    final request = http.Request('POST', url);
    request.headers['Content-Type'] = 'application/json';
    request.body = requestBody;

    final response = await client.send(request).then((response) {
      // Read and return the response
      return response.stream.bytesToString();
    });

    // Close the client when done
    client.close();

    return response;
  }

  static String getGenericPostData(String username, String password){
    return
      '{'
        '"UserLogin":"$username",'
        '"Password":"$password"'
      '}';
  }

  static Future<List<Term>> _getTermIDs() async{
    final username = storage.DataCache.getUsername();
    final password = storage.DataCache.getPassword();
    final url = Uri.parse(storage.DataCache.getInstituteUrl()! + URLs.PERIODTERMS_URL);
    final request = await _APIRequest.postRequest(url, _APIRequest.getGenericPostData(username!, password!));

    List<dynamic> termList = conv.json.decode(request)['PeriodTermsList'];
    List<Term> terms = [];
    for (var term in termList){
      final map = term as Map<String, dynamic>;
      terms.add(Term(map['Id'], map['TermName']));
    }

    return terms;
  }
}

class InstitutesRequest{
  static Future<String> fetchInstitudesJSON(){
    return _APIRequest.postRequest(Uri.parse(URLs.INSTITUTIONS_URL), '{}');
  }

  static List<Institute> getDataFromInstitudesJSON(String json){
    var newList = <Institute>[].toList();
    List<dynamic> jsonMap = conv.json.decode(json);
    for (var item in jsonMap){
      var item2 = item as Map<String, dynamic>;
      String name = item2['Name'];
      String url = item2['Url'] ?? "NULL";
      if(url != "NULL" && name != "DEMO") { //remove obsolete or non existent entries
        newList.add(Institute(name, url));
      }
    }
    return newList;
  }
  static Future<bool> validateLoginCredentials(Institute institute, String username, String password) async{
    final request = await _APIRequest.postRequest(Uri.parse(institute.URL + URLs.TRAININGS_URL), _APIRequest.getGenericPostData(username, password));
    return conv.json.decode(request)["ErrorMessage"] == null;
  }
  static Future<int?> getFirstStudyweek() async{
    final periods = await PeriodsRequest.getPeriods();
    final now = DateTime.now().millisecondsSinceEpoch;
    if(periods == null){
      return null;
    }

    PeriodEntry? period;

    for (var item in periods){
      if(item.name.toLowerCase().contains('jegybeírási időszak')){
        if(item.startEpoch <= now){
          period = item;
        }
      }
    }
    if(period == null){
      return null;
    }

    //final startDate = DateTime.fromMillisecondsSinceEpoch(period!.startEpoch);
    return period.startEpoch;
  }
}

class CalendarRequest{
  static List<CalendarEntry> getCalendarEntriesFromJSON(String json){
    var list = <CalendarEntry>[].toList();
    Map<String, dynamic> map = conv.json.decode(json);
    if(map['calendarData'] == null) {
      list.add(CalendarEntry(DateTime(1970, 1, 6).millisecondsSinceEpoch.toString(), DateTime.now().millisecondsSinceEpoch.toString(), 'Please Refresh!', 'Error Loading Calendar Data!', false));
      return list;
    }
    List<dynamic> sublist = map['calendarData'];
    final numberRegex = RegExp(r'\d+');
    for(var item in sublist){
      map = item as Map<String, dynamic>;
      list.add(CalendarEntry(
          numberRegex.firstMatch(map['start'].toString())!.group(0)!,
          numberRegex.firstMatch(map['end'].toString())!.group(0)!,
          map['location'].toString(),
          map['title'].toString(),
          map['type'] == 1));
    }
    return list;
  }

  static Future<String> makeCalendarRequest(String calendarJson) async{
    final url = Uri.parse(storage.DataCache.getInstituteUrl()! + URLs.CALENDAR_URL);
    final request = await _APIRequest.postRequest(url, calendarJson);
    return request;
  }

  static String getCalendarOneWeekJSON(String username, String password, int weekOffset){
    final DateTime now = DateTime.now();
    DateTime previousMonday = now.subtract(Duration(days: now.weekday));
    if (previousMonday.weekday == 7) {
      previousMonday = previousMonday.subtract(const Duration(days: 7));
    }
    previousMonday = DateTime(previousMonday.year, previousMonday.month, previousMonday.day, 0, 0);

    DateTime nextFriday = previousMonday.add(const Duration(days: 5, hours: 23, minutes: 59));
    if (nextFriday.weekday == 7) {
      nextFriday = nextFriday.subtract(const Duration(days: 7));
    }

    DateTime startOfTargetWeek = previousMonday.add(Duration(days: weekOffset * 7));
    DateTime endOfTargetWeek = nextFriday.add(Duration(days: weekOffset * 7));

    final epochStart = startOfTargetWeek.millisecondsSinceEpoch;
    final epochEnd = endOfTargetWeek.millisecondsSinceEpoch;

    return
      '{'
        '"UserLogin":"$username",'
        '"Password":"$password",'
        '"Time":true,'
        '"Exam":true,'
        '"startDate":"/Date($epochStart)/",'
        '"endDate":"/Date($epochEnd)/"'
      '}';
  }
}

class MarkbookRequest{
  static Future<String> _getMarkbookJSon(int termID) async{
    final username = storage.DataCache.getUsername();
    final password = storage.DataCache.getPassword();
    final url = Uri.parse(storage.DataCache.getInstituteUrl()! + URLs.MARKBOOK_URL);
    final json =
        '{'
          '"UserLogin":"$username",'
          '"Password":"$password",'
          '"CurrentPage":1,'
          '"filter":[{"TermID": $termID}]'
        '}';
    final request = await _APIRequest.postRequest(url, json);
    return request;
  }

  static Future<List<Subject>?> getMarkbookSubjects() async{
    List<Term> terms = await _APIRequest._getTermIDs();
    if(terms.isEmpty){
      return null;
    }

    String responseJson = "";
    List<dynamic> markbooklistRaw = [];
    for(var term in terms){
      responseJson = await _getMarkbookJSon(term.id);
      markbooklistRaw = conv.json.decode(responseJson)['MarkBookList'];
      if(markbooklistRaw.isNotEmpty){
        break;                        // find first non null markbook term
      }
    }

    if(responseJson.isEmpty || markbooklistRaw.isEmpty){    // if we went thru all possible markbooks, but non was valid
      return null;
    }

    List<Subject> subjects = [];

    for (var markbook in markbooklistRaw){
      final markbookMap = markbook as Map<String, dynamic>;
      subjects.add(Subject(markbookMap['Completed'], markbookMap['Credit'], markbookMap['SubjectName'], markbookMap['ID'], parseTextToGrade(markbookMap['Values']), parseTextToFailstate(markbookMap['Signer'])));
    }

    return subjects;
  }

  static int parseTextToFailstate(String failState){
    RegExp regex = RegExp(r'^(.*?)<br/>');
    Match? match = regex.firstMatch(failState);
    if(match == null){
      return 0;
    }
    failState = (match.group(1) ?? '').trim().toLowerCase();
    if(failState.isEmpty){
      return 0;
    }

    switch (failState.toLowerCase()){
      case "megtagadva":
        return 1;
      default:
        return 0;
    }
  }

  static bool isMark(String txt){
    switch(txt){
      case 'jeles':
      case 'jó':
      case 'közepes':
      case 'elégséges':
      case 'elégtelen':
        return true;
      default:
        return false;
    }
  }

  static int parseTextToGrade(String gradeTxt){
    final lst = gradeTxt.split('<br/>');
    var lst2 = <String>[];
    for (var item in lst){
      final checkFor = item.trim().toLowerCase();
      if(isMark(checkFor)){
        lst2.add(checkFor);
      }
    }
    if(!lst2.isNotEmpty){
      return 0;
    }

    final latestGrade = lst2[lst2.length - 1];

    switch (latestGrade){
      case 'jeles':
        return 5;
      case 'jó':
        return 4;
      case 'közepes':
        return 3;
      case 'elégséges':
        return 2;
      case 'elégtelen':
        return 1;
      default:
        return 0;
    }
  }


}

class CashinRequest{
  static Future<List<CashinEntry>> getAllCashins() async{
    final username = storage.DataCache.getUsername();
    final password = storage.DataCache.getPassword();
    String requestBody = _APIRequest.getGenericPostData(username!, password!);

    final url = Uri.parse(storage.DataCache.getInstituteUrl()! + URLs.GETCASHIN_URL);

    List<CashinEntry> entries = CashinRequest._jsonToCashinEntry(await _APIRequest.postRequest(url, requestBody));
    return entries;
  }
  
  
  static List<CashinEntry> _jsonToCashinEntry(String json){
    List<CashinEntry> ls = List.empty(growable: true);
    final List<dynamic> cashins = conv.json.decode(json)['CashinDataRows'];
    for (var cashin in cashins){
      ls.add(CashinEntry(
          cashin['amount'],
          int.parse(cashin['deadline'].toString().replaceAll('/Date(', '').replaceAll(')/', '')),
          cashin['appellation'],
          cashin['status_name']
      ));
    }
    return ls;
  }
}

class PeriodsRequest{

  static Future<List<PeriodEntry>?> getPeriods() async{
    final terms = await _APIRequest._getTermIDs();
    if(terms.isEmpty){
      return null;
    }
    List<PeriodEntry> periods = <PeriodEntry>[];
    int cntperiod = terms.length;
    for(var term in terms){
      final jsonresult = await _getPeriodJSon(term.id);
      final result = conv.json.decode(jsonresult)['PeriodList'] as List<dynamic>;
      for(var period in result){
        final currPeriod = period as Map<String, dynamic>;
        periods.add(PeriodEntry(currPeriod['PeriodTypeName'], int.parse(currPeriod['FromDate'].toString().replaceAll('/Date(', '').replaceAll(')/', '')), int.parse(currPeriod['ToDate'].toString().replaceAll('/Date(', '').replaceAll(')/', '')), cntperiod));
      }
      cntperiod--;
    }
    return periods;
  }

  static Future<String> _getPeriodJSon(int termID) async{
    final username = storage.DataCache.getUsername();
    final password = storage.DataCache.getPassword();
    final url = Uri.parse(storage.DataCache.getInstituteUrl()! + URLs.PERIODS_URL);
    final json =
        '{'
        '"UserLogin":"$username",'
        '"Password":"$password",'
        '"PeriodTermID":$termID,'
        '}';
    final request = await _APIRequest.postRequest(url, json);
    return request;
  }
}

class Term{
  int id;
  String termName;

  Term(this.id, this.termName);
}

class Subject{
  bool completed;
  int credit;
  int id;
  String name;
  int grade = 0;
  int failState = 0;


  Subject(this.completed, this.credit, this.name, this.id, this.grade, this.failState);

  @override
  String toString() {
    return '$completed\n$credit\n$id\n$name\n$grade\n$failState';
  }

  Subject fillWithExisting(String existing){
    var data = existing.split('\n');
    if(data.length < 6){
      completed = false;
      credit = 0;
      id = 0;
      name = 'ERROR';
      grade = 0;
      failState = 1;
      return this;
    }
    completed = bool.parse(data[0]);
    credit = int.parse(data[1]);
    id = int.parse(data[2]);
    name = data[3];
    grade = int.parse(data[4]);
    failState = int.parse(data[5]);
    return this;
  }
}

class Institute{
  late final String Name;
  late final String URL;

  Institute(String name, String url){
    Name = name;
    URL = url;
  }

  getUrl() => Uri.parse(URL);
}

class CalendarEntry{
  late int startEpoch;
  late int endEpoch;
  late String location;
  late String title;
  late bool isExam;

  CalendarEntry(String start, String end, String loc, String rawTitle, this.isExam){
    startEpoch = int.parse(start);
    startEpoch = DateTime.fromMillisecondsSinceEpoch(startEpoch).subtract(const Duration(hours: 1)).millisecondsSinceEpoch; // need to offset

    endEpoch = int.parse(end);
    endEpoch = DateTime.fromMillisecondsSinceEpoch(endEpoch).subtract(const Duration(hours: 1)).millisecondsSinceEpoch;

    location = loc;

    final regex = RegExp(r'\]([^(]+)\(');
    final match = regex.firstMatch(rawTitle);

    if(match != null){
      title = match.group(1)!
          .replaceAll(']', '')
          .replaceAll('(', '')
          .replaceAll('\u0009', '')
          .trim();
    }
    else{
      // we couldnt find the real title
      title = rawTitle;
    }
  }

  @override
  String toString() {
    return '$startEpoch\n$endEpoch\n$location\n$title\n$isExam';
  }

  CalendarEntry fillWithExisting(String existing){
    var data = existing.split('\n');
    if(data.isEmpty || data.length < 5){
      return this;
    }
    startEpoch = int.parse(data[0]);
    endEpoch = int.parse(data[1]);
    location = data[2];
    title = data[3];
    isExam = bool.parse(data[4]);
    return this;
  }
}

class CashinEntry{
  late int ammount;
  late int dueDateMs;
  late String comment;
  late bool completed;

  CashinEntry(this.ammount, this.dueDateMs, this.comment, String completed){
    if(completed.toLowerCase() == 'teljesített'){
      this.completed = true;
    }
  }

  @override
  String toString() {
    return '$ammount\n$dueDateMs\n$comment\n$completed';
  }

  CashinEntry fillWithExisting(String existing){
    var data = existing.split('\n');
    if(data.isEmpty || data.length < 4){
      return this;
    }
    ammount = int.parse(data[0]);
    dueDateMs = int.parse(data[1]);
    comment = data[2];
    completed = bool.parse(data[3]);
    return this;
  }
}

enum PeriodType{
  timetableRegistration,
  gradingTime,
  loginTime,
  pregivenGradingAccepting,
  timetableFinalization,
  coursesRegistration,
  nerdTime,
  examTime,
  none
}

class PeriodEntry{
  late String name;
  late int startEpoch;
  late int endEpoch;
  late bool isActive;
  late int partofSemester;
  late PeriodType type;

  PeriodEntry(this.name, startEpoch, endEpoch, this.partofSemester){
    final startEp = DateTime.fromMillisecondsSinceEpoch(startEpoch);
    final correctedStartEpoch = DateTime(startEp.year, startEp.month, startEp.day);
    this.startEpoch = correctedStartEpoch.millisecondsSinceEpoch;

    final endEp = DateTime.fromMillisecondsSinceEpoch(endEpoch);
    final correctedEndEpoch = DateTime(endEp.year, endEp.month, endEp.day);
    this.endEpoch = correctedEndEpoch.millisecondsSinceEpoch;


    fillIsActiveStatus();
  }

  @override
  String toString() {
    return '$name\n$startEpoch\n$endEpoch\n$partofSemester';
  }

  String getValue(){
    return '$startEpoch-$endEpoch';
  }

  PeriodEntry fillWithExisting(String existing){
    var data = existing.split('\n');
    if(data.isEmpty || data.length < 4){
      return this;
    }
    name = data[0];
    startEpoch = int.parse(data[1]);
    endEpoch = int.parse(data[2]);
    partofSemester = int.parse(data[3]);
    fillIsActiveStatus();
    return this;
  }

  void fillIsActiveStatus() {
    final now = DateTime
        .now()
        .millisecondsSinceEpoch;
    isActive = (startEpoch < now && now < endEpoch);

    switch (name.toLowerCase().trim()){
      case 'előzetes tárgyjelentkezés':
        type = PeriodType.timetableRegistration;
        break;
      case 'jegybeírási időszak':
        type = PeriodType.gradingTime;
        break;
      case 'bejelentkezési időszak':
        type = PeriodType.loginTime;
        break;
      case 'megajánlott jegy beírási időszak':
        type = PeriodType.pregivenGradingAccepting;
        break;
      case 'végleges tárgyjelentkezés':
        type = PeriodType.timetableFinalization;
        break;
      case 'kurzusjelentkezési időszak':
        type = PeriodType.coursesRegistration;
        break;
      case 'szorgalmi időszak':
        type = PeriodType.nerdTime;
        break;
      case 'vizsgajelentkezési időszak':
        type = PeriodType.examTime;
        break;
      default:
        type = PeriodType.none;
        break;
    }
  }
}

class Generic{
  static String monthToText(int month){
    switch (month){
      case 1:
        return "Január";
      case 2:
        return "Február";
      case 3:
        return "Március";
      case 4:
        return "Április";
      case 5:
        return "Május";
      case 6:
        return "Június";
      case 7:
        return "Július";
      case 8:
        return "Augusztus";
      case 9:
        return "Szeptember";
      case 10:
        return "Október";
      case 11:
        return "November";
      case 12:
        return "December";
    }
    return "NULL";
  }
}

class NeptunCerts extends HttpOverrides {
  static final NeptunCerts _instance = NeptunCerts();
  static NeptunCerts getInstance(){return _instance;}

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // accept all certs, as neptun has none
        return true;
      };
  }
}