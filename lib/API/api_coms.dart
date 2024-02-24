  import 'dart:async';
  import 'dart:convert' as conv;
  import 'dart:developer' as debug;
  import 'dart:io';
  import 'dart:math';
  import 'dart:typed_data';
  import 'package:flutter/material.dart';
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
      HttpOverrides.global = NeptunCerts.getCerts();
  
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
      if(storage.DataCache.getIsDemoAccount()!){
        return <Term>[Term(70876, 'DEMO Félév')];
      }
      return getTerms();
    }

    static Future<List<Term>> getTerms() async{
      if(storage.DataCache.getIsDemoAccount()!){
        return <Term>[Term(70876, 'DEMO Félév')];
      }
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
    static Future<List<dynamic>?> fetchInstitudesJSON() async{
      //return _APIRequest.postRequest(Uri.parse(URLs.INSTITUTIONS_URL), '{}');
      return await getRawJsonWithNameUrlPairs();
    }

    static Future<List<dynamic>?> getRawJsonWithNameUrlPairs() async{
      final url = Uri.parse('https://raw.githubusercontent.com/domedav/Neptun-2/main/universityNameUrlPairs.json');
      final response = await http.get(url);

      if (response.statusCode != 200) {
        return null;
      }

      Map<String, dynamic> jsonMap = conv.json.decode(response.body);
      return jsonMap["Institutes"];
    }
  
    static List<Institute> getDataFromInstitudesJSON(List<dynamic> jsonMap){
      var newList = <Institute>[].toList();
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
      if(username == 'DEMO' && password == 'DEMO'){
        await storage.DataCache.setIsDemoAccount(1);
        return true;
      }
      final request = await _APIRequest.postRequest(Uri.parse(institute.URL + URLs.TRAININGS_URL), _APIRequest.getGenericPostData(username, password));
      return conv.json.decode(request)["ErrorMessage"] == null;
    }
    static Future<int?> getFirstStudyweek() async{
      final periods = await PeriodsRequest.getPeriods();
      if(storage.DataCache.getIsDemoAccount()!){
        return DateTime(2023, 9, 1).millisecondsSinceEpoch;
      }
      final now = DateTime.now().millisecondsSinceEpoch;
      if(periods == null){
        return null;
      }
  
      PeriodEntry? period;
  
      for (var item in periods){
        if(item.name.toLowerCase().contains('végleges tárgyjelentkezés')){
          if(item.startEpoch <= now){
            period = item;
            break;
          }
        }
      }
      if(period == null){
        return null;
      }
  
      //final startDate = DateTime.fromMillisecondsSinceEpoch(period.startEpoch);
      final date = DateTime.fromMillisecondsSinceEpoch(period.endEpoch);
      int difference = date.weekday - DateTime.monday;

      final roundedDate = date.subtract(Duration(days: difference));

      return roundedDate.millisecondsSinceEpoch;
    }
  }
  
  class CalendarRequest{
    static List<CalendarEntry> getCalendarEntriesFromJSON(String json){
      if(storage.DataCache.getIsDemoAccount()!){
        final now = DateTime.now();
        return <CalendarEntry>[
          //CalendarEntry(DateTime(now.year, now.month, 1, 0, 0, 0).millisecondsSinceEpoch.toString(), DateTime(now.year, now.month, 1, 23, 23, 23).millisecondsSinceEpoch.toString(), 'DEMO helyszín 1', 'DEMO név', false),
          CalendarEntry(DateTime(now.year, now.month, 2, 1, 1, 1).millisecondsSinceEpoch.toString(), DateTime(now.year, now.month, 2, 22, 22, 22).millisecondsSinceEpoch.toString(), 'DEMO helyszín 2', 'DEMO név', false),
          //CalendarEntry(DateTime(now.year, now.month, 3, 2, 2, 2).millisecondsSinceEpoch.toString(), DateTime(now.year, now.month, 3, 11, 11, 11).millisecondsSinceEpoch.toString(), 'DEMO helyszín 3', 'DEMO név', false),
          CalendarEntry(DateTime(now.year, now.month, 3, 3, 3, 3).millisecondsSinceEpoch.toString(), DateTime(now.year, now.month, 4, 10, 10, 10).millisecondsSinceEpoch.toString(), 'DEMO helyszín 4', 'DEMO név', false),
          CalendarEntry(DateTime(now.year, now.month, 3, 3, 3, 3).millisecondsSinceEpoch.toString(), DateTime(now.year, now.month, 4, 10, 10, 10).millisecondsSinceEpoch.toString(), 'DEMO helyszín 4', 'DEMO vizsga', true),
          CalendarEntry(DateTime(now.year, now.month, 4, 3, 3, 3).millisecondsSinceEpoch.toString(), DateTime(now.year, now.month, 4, 10, 10, 10).millisecondsSinceEpoch.toString(), 'DEMO helyszín 4', 'DEMO név', false),
          CalendarEntry(DateTime(now.year, now.month, 4, 3, 3, 3).millisecondsSinceEpoch.toString(), DateTime(now.year, now.month, 4, 14, 10, 10).millisecondsSinceEpoch.toString(), 'DEMO helyszín 4', 'DEMO név', false),
          CalendarEntry(DateTime(now.year, now.month, 4, 3, 3, 3).millisecondsSinceEpoch.toString(), DateTime(now.year, now.month, 4, 19, 10, 10).millisecondsSinceEpoch.toString(), 'DEMO helyszín 5', 'DEMO név', false),
          CalendarEntry(DateTime(now.year, now.month, 5, 4, 4, 4).millisecondsSinceEpoch.toString(), DateTime(now.year, now.month, 5, 9, 9, 9).millisecondsSinceEpoch.toString(), 'DEMO helyszín 5', 'DEMO név', false),
          CalendarEntry(DateTime(now.year, now.month, 5, 6, 4, 4).millisecondsSinceEpoch.toString(), DateTime(now.year, now.month, 5, 12, 9, 9).millisecondsSinceEpoch.toString(), 'DEMO helyszín 8', 'DEMO név', false),
          CalendarEntry(DateTime(now.year, now.month, 5, 8, 4, 4).millisecondsSinceEpoch.toString(), DateTime(now.year, now.month, 5, 12, 9, 9).millisecondsSinceEpoch.toString(), 'DEMO helyszín 8', 'DEMO név', false),
          //CalendarEntry(DateTime(now.year, now.month, 6, 5, 5 ,5).millisecondsSinceEpoch.toString(), DateTime(now.year, now.month, 6, 20, 20, 20).millisecondsSinceEpoch.toString(), 'DEMO helyszín 6', 'DEMO név', false),
          CalendarEntry(DateTime(now.year, now.month, 7, 6, 6, 6).millisecondsSinceEpoch.toString(), DateTime(now.year, now.month, 7, 6, 7, 7).millisecondsSinceEpoch.toString(), 'DEMO helyszín 7', 'DEMO név', false),
          CalendarEntry(DateTime(now.year, now.month, now.day, 3, now.hour, 3).millisecondsSinceEpoch.toString(), DateTime(now.year, now.month, now.day, now.hour + 1, 10, 10).millisecondsSinceEpoch.toString(), 'DEMO helyszín', 'DEMO Értesítés Aznap', true),
          CalendarEntry(DateTime(now.year, now.month, now.day + 1, now.hour, 3, 3).millisecondsSinceEpoch.toString(), DateTime(now.year, now.month, now.day + 1, now.hour + 1, 10, 10).millisecondsSinceEpoch.toString(), 'DEMO helyszín', 'DEMO Értesítés 1', true),
          CalendarEntry(DateTime(now.year, now.month, now.day + 3, now.hour, 3, 3).millisecondsSinceEpoch.toString(), DateTime(now.year, now.month, now.day + 3, now.hour + 1, 10, 10).millisecondsSinceEpoch.toString(), 'DEMO helyszín', 'DEMO Értesítés 3', true),
          CalendarEntry(DateTime(now.year, now.month, now.day + 7, now.hour, 3, 3).millisecondsSinceEpoch.toString(), DateTime(now.year, now.month, now.day + 7, now.hour + 1, 10, 10).millisecondsSinceEpoch.toString(), 'DEMO helyszín', 'DEMO Értesítés 7', true),
          CalendarEntry(DateTime(now.year, now.month, now.day + 14, now.hour, 3, 3).millisecondsSinceEpoch.toString(), DateTime(now.year, now.month, now.day + 14, now.hour + 1, 10, 10).millisecondsSinceEpoch.toString(), 'DEMO helyszín', 'DEMO Értesítés 14', true),
  
          CalendarEntry(DateTime(now.year, now.month, now.day, now.hour + 1, now.minute + 11, 4).millisecondsSinceEpoch.toString(), DateTime(now.year, now.month, now.hour + 1, now.minute + 45, 9, 9).millisecondsSinceEpoch.toString(), 'DEMO helyszín 8', 'DEMO Óra', false),
          CalendarEntry(DateTime(now.year, now.month, now.day, now.hour + 1, now.minute + 12, 4).millisecondsSinceEpoch.toString(), DateTime(now.year, now.month, now.hour + 1, now.minute + 45, 9, 9).millisecondsSinceEpoch.toString(), 'DEMO helyszín 8', 'DEMO Óra', false),
          CalendarEntry(DateTime(now.year, now.month, now.day, now.hour + 1, now.minute + 13, 4).millisecondsSinceEpoch.toString(), DateTime(now.year, now.month, now.hour + 1, now.minute + 45, 9, 9).millisecondsSinceEpoch.toString(), 'DEMO helyszín 8', 'DEMO Óra', false),
        ];
      }
      var list = <CalendarEntry>[].toList();
      Map<String, dynamic> map = conv.json.decode(json);
      if(map['calendarData'] == null) {
        list.add(CalendarEntry(DateTime(1970, 1, 6).millisecondsSinceEpoch.toString(), DateTime.now().millisecondsSinceEpoch.toString(), 'ERROR', 'ERROR', false));
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
      if(storage.DataCache.getIsDemoAccount()!){
        return '';
      }
      final url = Uri.parse(storage.DataCache.getInstituteUrl()! + URLs.CALENDAR_URL);
      final request = await _APIRequest.postRequest(url, calendarJson);
      return request;
    }
  
    static String getCalendarOneWeekJSON(String username, String password, int weekOffset){
      if(storage.DataCache.getIsDemoAccount()!){
        return '';
      }
      final DateTime now = DateTime.now();
      DateTime previousMonday = now.subtract(Duration(days: now.weekday));
      if (previousMonday.weekday == 7) {
        previousMonday = previousMonday.subtract(const Duration(days: 7));
      }
      previousMonday = DateTime(previousMonday.year, previousMonday.month, previousMonday.day, 0, 0);
  
      DateTime nextFriday = previousMonday.add(const Duration(days: 6, hours: 23, minutes: 59));
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
      if(storage.DataCache.getIsDemoAccount()!){
        return '';
      }
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
      if(storage.DataCache.getIsDemoAccount()!){
        return <Subject>[
          Subject(false, 1, 'DEMO tantárgy 1', 0, 4, 0),
          Subject(false, 1, 'DEMO tantárgy 12', 0, 0, 0),
          Subject(true, 2, 'DEMO tantárgy 2', 0, 4, 0),
          Subject(true, 4, 'DEMO tantárgy 3', 0, 2, 0),
          Subject(true, 1, 'DEMO tantárgy 4', 0, 1, 0),
          Subject(true, 2, 'DEMO tantárgy 5', 0, 2, 0),
          Subject(true, 3, 'DEMO tantárgy 6', 0, 3, 0),
          Subject(true, 4, 'DEMO tantárgy 7', 0, 4, 0),
          Subject(true, 5, 'DEMO tantárgy 8', 0, 5, 0),
          Subject(true, 0, 'DEMO tantárgy 9', 0, 1, 0),
          Subject(true, 0, 'DEMO tantárgy 10', 0, 0, 0),
          Subject(false, 0, 'DEMO tantárgy 11', 0, 1, 0),
          Subject(false, 10, 'DEMO szellemjegy 1', 1, 0, 0),
          Subject(true, 2, 'DEMO szellemjegy 2', 1, 0, 0),
        ];
      }
      List<Term> terms = await _APIRequest._getTermIDs();
      if(terms.isEmpty){
        return <Subject>[
          Subject(false, 0, 'Hiba a jegyzetfüzet betöltésekor!\nNincs term id', 0, 0, 1),
        ];
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
      if(storage.DataCache.getIsDemoAccount()!){
        final now = DateTime.now();
        return <CashinEntry>[
          CashinEntry(10000, DateTime(now.year + 1, now.month).millisecondsSinceEpoch, 'DEMO befizetés 1', 1, 'aktív'),
          CashinEntry(70, DateTime(now.year + 1, now.month).millisecondsSinceEpoch, 'DEMO befizetés 2', 1, 'teljesített'),
          CashinEntry(-1, DateTime(now.year - 1, now.month).millisecondsSinceEpoch, 'DEMO befizetés 3', 0, 'aktív'),
          CashinEntry(-1, DateTime(now.year - 1, now.month).millisecondsSinceEpoch, 'DEMO befizetés 4', 0, 'teljesített'),
          CashinEntry(1000, 0, 'DEMO befizetés 5', 0, 'aktív'),
        ];
      }
      final username = storage.DataCache.getUsername();
      final password = storage.DataCache.getPassword();
      String requestBody = _APIRequest.getGenericPostData(username!, password!);
  
      final url = Uri.parse(storage.DataCache.getInstituteUrl()! + URLs.GETCASHIN_URL);
  
      List<CashinEntry> entries = CashinRequest._jsonToCashinEntry(await _APIRequest.postRequest(url, requestBody));
      return entries;
    }
  
  
    static List<CashinEntry> _jsonToCashinEntry(String json){
      if(storage.DataCache.getIsDemoAccount()!){
        return <CashinEntry>[CashinEntry(87878, 999999999, 'DEMO befizetés', 0, 'teljesítve')];
      }
      List<CashinEntry> ls = List.empty(growable: true);
      final List<dynamic> cashins = conv.json.decode(json)['CashinDataRows'];
      for (var cashin in cashins){
        ls.add(CashinEntry(
            cashin['amount'],
            int.parse(cashin['deadline'] == null ? '0' : cashin['deadline'].toString().replaceAll('/Date(', '').replaceAll(')/', '')),
            cashin['appellation'],
            cashin['ID'],
            cashin['status_name']
        ));
      }
      return ls;
    }
  }
  
  class PeriodsRequest{
  
    static Future<List<PeriodEntry>?> getPeriods() async{
      if(storage.DataCache.getIsDemoAccount()!){
        final now = DateTime.now();
        return <PeriodEntry>[
          PeriodEntry('lejárt időszak', DateTime(now.year - 1, now.month, now.day - 2).millisecondsSinceEpoch, DateTime(now.year - 1, now.month, now.day + 1).millisecondsSinceEpoch, 1),
          PeriodEntry('előzetes tárgyjelentkezés', DateTime(now.year, now.month, now.day - 2).millisecondsSinceEpoch, DateTime(now.year, now.month, now.day + 1).millisecondsSinceEpoch, 1),
          PeriodEntry('jegybeírási időszak', DateTime(now.year, now.month, now.day - 2).millisecondsSinceEpoch, DateTime(now.year, now.month, now.day + 2).millisecondsSinceEpoch, 1),
          PeriodEntry('bejelentkezési időszak', DateTime(now.year, now.month, now.day - 2).millisecondsSinceEpoch, DateTime(now.year, now.month, now.day +7).millisecondsSinceEpoch, 1),
          PeriodEntry('megajánlott jegy beírási időszak', DateTime(now.year, now.month, now.day - 2).millisecondsSinceEpoch, DateTime(now.year, now.month, now.day + 14).millisecondsSinceEpoch, 1),
          PeriodEntry('végleges tárgyjelentkezés', DateTime(now.year, now.month, now.day - 2).millisecondsSinceEpoch, DateTime(now.year, now.month + 1, now.day).millisecondsSinceEpoch, 1),
          PeriodEntry('kurzusjelentkezési időszak', DateTime(now.year, now.month, now.day - 2).millisecondsSinceEpoch, DateTime(now.year, now.month + 2, now.day).millisecondsSinceEpoch, 2),
          PeriodEntry('szorgalmi időszak', DateTime(now.year, now.month, now.day + 1).millisecondsSinceEpoch, DateTime(now.year, now.month + 3, now.day).millisecondsSinceEpoch, 2),
          PeriodEntry('vizsgajelentkezési időszak', DateTime(now.year, now.month, now.day + 20).millisecondsSinceEpoch, DateTime(now.year + 1, now.month, now.day).millisecondsSinceEpoch, 3),
          PeriodEntry('none', DateTime(now.year, now.month + 1, now.day).millisecondsSinceEpoch, DateTime(now.year + 1, now.month, now.day).millisecondsSinceEpoch, 4),
        ];
      }
      final terms = await _APIRequest._getTermIDs();
      if(terms.isEmpty){
        return <PeriodEntry>[
          PeriodEntry('Hiba lépett fel!\nNincs term id.', DateTime.now().millisecondsSinceEpoch, DateTime.now().millisecondsSinceEpoch, 1)
        ];
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
      if(storage.DataCache.getIsDemoAccount()!){
        return '';
      }
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
    late int ID;
    late int ammount;
    late int dueDateMs;
    late String comment;
    late bool completed = false;
  
    CashinEntry(this.ammount, this.dueDateMs, this.comment, this.ID, String completed){
      if(completed.toLowerCase() == 'teljesített' || completed.toLowerCase() == 'törölt'){
        this.completed = true;
      }
    }
  
    @override
    String toString() {
      return '$ammount\n$dueDateMs\n$comment\n$completed\n$ID';
    }
  
    CashinEntry fillWithExisting(String existing){
      var data = existing.split('\n');
      if(data.isEmpty || data.length < 5){
        return this;
      }
      ammount = int.parse(data[0]);
      dueDateMs = int.parse(data[1]);
      comment = data[2];
      completed = bool.parse(data[3]);
      ID = int.parse(data[4]);
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
  
    PeriodEntry(this.name, int startEpoch, int endEpoch, this.partofSemester){
      final startEp = DateTime.fromMillisecondsSinceEpoch(startEpoch);
      final correctedStartEpoch = DateTime(startEp.year, startEp.month, startEp.day);
      this.startEpoch = correctedStartEpoch.millisecondsSinceEpoch;
  
      final endEp = DateTime.fromMillisecondsSinceEpoch(endEpoch).add(const Duration(days: 1)); // last day counts too
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
      final now = DateTime.now().millisecondsSinceEpoch;
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
  
    static String capitalizePeriodText(String periodName){
      final chars = periodName.toLowerCase().trim().characters.toList();
      String str = '';
      int idx = 0;
      bool setNexttoCapitalize = false;
      for(var item in chars){
        if(idx == 0 || setNexttoCapitalize) {
          str += item.toUpperCase();
          idx++;
          setNexttoCapitalize = false;
          continue;
        }
        if(item == ' '){
          setNexttoCapitalize = true;
        }
        str += item;
        idx++;
      }
      return str;
    }
  
    static String randomLoadingComment(bool familyFriendlyMode){
      if(!familyFriendlyMode){
        final gen = Random().nextInt(100) % 7;
        switch (gen){
          case 0:
            return 'Elfüstölne a telefonod, ha gyorsabb lenne...';
          case 1:
            return 'Még mindíg, jobb mint a nem létező Neptun...';
          case 2:
            return 'Már bármelyik milleniumban betölthet...';
          case 3:
            return 'Áramszünet van az SDA Informatikánál...';
          case 4:
            return 'Az SDA Informatika egy nagyon jó cég...';
          case 5:
            return 'Tudtad? A "Neptun 2" alapja csupán 1 hét alatt készült...';
          case 6:
            return 'Túl lassú? Panaszkodj az SDA Informatikának...';
          default:
            return 'Neptun 2';
        }
      }
      final gen = Random().nextInt(100) % 12;
      switch(gen){
        case 0:
          return 'Úgy dolgoznak a Neptun szerverek, mint egy átlagos államilag finanszírozott útépítés...';
        case 1:
          return 'Megvárjuk, amíg az SDA Informatika főnöke kávéba fullad...';
        case 2:
          return 'Légy türelmes, egy patkány miatt zárlatos lett az egyik szerver...';
        case 3:
          return 'Előbb hiszem el, hogy az Északi-sarkon is vannak pingvinek, minthogy a Neptun szervereire pénzt költöttek..';
        case 4:
          return 'Neptun szerverei olyan megbízhatóak, bankolni is lehet rajtuk...';
        case 5:
          return 'SDA jelentése: Sok Dagadt Analfabéta. Egy normális mobilappot nem sikerült összehoziuk...';
        case 6:
          return 'Fogadni merek, mire ezt elolvasod, még mindíg a Neptun szervereire vársz...';
        case 7:
          return '(ChatGPT)\nHa az SDA Informatika supportja egy GPS lenne, egyenesen egy tóba vezetne – irányvesztés a specialitásuk, és az problémákban való fuldoklás az erősségük...';
        case 8:
          return '(ChatGPT)\nAz SDA Informatika csapata olyan, mintha egy viziló lenne a pilóta egy tüzijátékkal, amivel próbálja elérni a Holdat – nem csak nevetséges, de az egészet rossz nézni...';
        case 9:
          return '(ChatGPT)\nAz SDA Informatika supportja olyan, mint az UFO-k – az emberek állítják, hogy létezik, de bizonyíték nincs...';
        case 10:
          return '(ChatGPT)\nAz SDA Informatika technológiai fejlesztései olyanok, mintha egy bohóc próbálna csúcstechnológiát kitalálni – a végeredmény kaotikus, és nem éppen az innováció csúcsa...';
        case 11:
          return '(ChatGPT)\nAz SDA Informatika munkakultúrája olyan, mintha egy bohóciskolában lenne az ember – kacagás és zűrzavar mindenütt, de az értékes eredmények hiányoznak...';
        default:
          return 'Neptun 2';
      }
    }
  }
  
  class NeptunCerts extends HttpOverrides {
    static NeptunCerts? _instance;
    static bool hasValidCertificate = true;
  
    static NeptunCerts getCerts(){
      if(_instance != null){
        return _instance!;
      }
      return NeptunCerts();
    }
  
    NeptunCerts(){
      _instance = this;
    }
  
    @override
    HttpClient createHttpClient(SecurityContext? context) {
      return super.createHttpClient(context)
        ..badCertificateCallback = (X509Certificate cert, String host, int port) {
          final validCertSha1 = [165, 169, 244, 23, 233, 182, 23, 197, 14, 55, 39, 250, 69, 216, 89, 8, 179, 251, 103, 19];
          //debug.log(cert.sha1.toString());
          //debug.log(validCertSha1.toString());
          hasValidCertificate = cert.sha1.toString() == validCertSha1.toString(); // list comparison doesnt always work for some reason...
          return hasValidCertificate;
        };
    }
  }