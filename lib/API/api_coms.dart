import 'dart:async';
import 'dart:convert' as conv;
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:neptun2/Misc/clickable_text_span.dart';
import 'package:neptun2/language.dart';
import '../app_analitics.dart';
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
    static const String MESSAGES_URL = "/GetMessages";
    static const String MESSAGE_SET_READ = "/SetReadedMessage";
  }
  
  class _APIRequest{
    static Future<String> postRequest(Uri url, String requestBody) async{
      HttpOverrides.global = NeptunCerts.getCerts();
  
      final client = http.Client();
      final request = http.Request('POST', url);
      request.headers['Content-Type'] = 'application/json';
      request.body = requestBody;

      var response;
      try{
        response = await client.send(request).then((response) {
          // Read and return the response
          return response.stream.bytesToString();
        });
      }
      catch(error){
        AppAnalitics.sendAnaliticsData(AppAnalitics.ERROR, 'api_coms.dart => _APIRequest.postRequest() NeptunError: PostRequest Error: $error');
      }

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
      var json;
      try{
        json = await getRawJsonWithNameUrlPairs();
      }
      catch(error){
        AppAnalitics.sendAnaliticsData(AppAnalitics.ERROR, 'api_coms.dart => InstitudesRequest.fetchInstitudesJSON() Error: $error');
      }
      return json;
    }

    static Future<List<dynamic>?> getRawJsonWithNameUrlPairs() async{
      final url = Uri.parse('https://raw.githubusercontent.com/domedav/Neptun-2/main/universityNameUrlPairs.json');
      final response = await http.get(url);

      if (response.statusCode != 200) {
        AppAnalitics.sendAnaliticsData(AppAnalitics.ERROR, 'api_coms.dart => InstitudesRequest.getRawJsonWithNameUrlPairs() Error: Failed to fetch universityNameUrlPairs.json');
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
      return validateLoginCredentialsUrl(institute.URL, username, password);
    }

    static Future<bool> validateLoginCredentialsUrl(String url, String username, String password)async{
      if(username == 'DEMO' && password == 'DEMO'){
        await storage.DataCache.setIsDemoAccount(1);
        AppAnalitics.sendAnaliticsData(AppAnalitics.INFO, 'api_coms.dart => InstitudesRequest.validateLoginCredentials() Info: Login on demo account');
        return true;
      }
      final request = await _APIRequest.postRequest(Uri.parse(url + URLs.TRAININGS_URL), _APIRequest.getGenericPostData(username, password));
      if(conv.json.decode(request)["ErrorMessage"] != null){
        AppAnalitics.sendAnaliticsData(AppAnalitics.ERROR, 'api_coms.dart => InstitudesRequest.validateLoginCredentials() NeptunError: ${conv.json.decode(request)["ErrorMessage"]}');
      }
      return conv.json.decode(request)["ErrorMessage"] == null;
    }

    static Future<int?> getFirstStudyweek() async{
      final periods = await PeriodsRequest.getPeriods();
      if(storage.DataCache.getIsDemoAccount()!){
        return DateTime(2023, 9, 1).millisecondsSinceEpoch;
      }
      final now = DateTime.now().millisecondsSinceEpoch;
      if(periods == null){
        AppAnalitics.sendAnaliticsData(AppAnalitics.ERROR, 'api_coms.dart => InstitudesRequest.getFirstStudyweek() Error: No period available');
        return null;
      }
  
      PeriodEntry? period;
      int neededExtraWeeks = 0;
      for (var item in periods){
        if(item.name.toLowerCase().contains('végleges tárgyjelentkezés')){
          if(item.startEpoch <= now || period != null && item.startEpoch <= now && item.startEpoch > period.startEpoch){
            period = item;
            neededExtraWeeks = 0;
          }
        }
      }
      if(period == null){
        for (var item in periods){
          if(item.name.toLowerCase().contains('bejelentkezési időszak')){
            if(item.startEpoch <= now || period != null && item.startEpoch <= now && item.startEpoch > period.startEpoch){
              period = item;
              neededExtraWeeks = 1;
            }
          }
        }
        if(period == null){
          AppAnalitics.sendAnaliticsData(AppAnalitics.ERROR, 'api_coms.dart => InstitudesRequest.getFirstStudyweek() Error: No "végleges tárgyjelenkezés" or "bejelentkezési időszak" period available, ${periods.toString()}');
          return null;
        }
      }
  
      //final startDate = DateTime.fromMillisecondsSinceEpoch(period.startEpoch);
      final date = DateTime.fromMillisecondsSinceEpoch(period.endEpoch);
      int difference = date.weekday - DateTime.monday;

      final roundedDate = date.subtract(Duration(days: difference)).add(Duration(days: 7 * neededExtraWeeks));

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

          CalendarEntry(DateTime(now.year, now.month, now.day, 17, 00).millisecondsSinceEpoch.toString(), DateTime(now.year, now.month, now.day, 18, 30).millisecondsSinceEpoch.toString(), 'Clipping', '1...', false),
          CalendarEntry(DateTime(now.year, now.month, now.day, 18, 30).millisecondsSinceEpoch.toString(), DateTime(now.year, now.month, now.day, 20, 00).millisecondsSinceEpoch.toString(), 'Clipping', '2...', false),
          CalendarEntry(DateTime(now.year, now.month, now.day + 1, 08, 00).millisecondsSinceEpoch.toString(), DateTime(now.year, now.month, now.day + 1, 09, 30).millisecondsSinceEpoch.toString(), 'Clipping', '3...', false),
          CalendarEntry(DateTime(now.year, now.month, now.day + 1, 08, 00).millisecondsSinceEpoch.toString(), DateTime(now.year, now.month, now.day + 1, 09, 30).millisecondsSinceEpoch.toString(), 'Clipping', '4...', false),
          CalendarEntry(DateTime(now.year, now.month, now.day+ 1, 09, 45).millisecondsSinceEpoch.toString(), DateTime(now.year, now.month, now.day + 1, 11, 15).millisecondsSinceEpoch.toString(), 'Clipping', '3...', false),
          CalendarEntry(DateTime(now.year, now.month, now.day + 1, 09, 45).millisecondsSinceEpoch.toString(), DateTime(now.year, now.month, now.day + 1, 11, 15).millisecondsSinceEpoch.toString(), 'Clipping', '4...', false),

        ];
      }
      var list = <CalendarEntry>[].toList();
      Map<String, dynamic> map = conv.json.decode(json);
      if(map['calendarData'] == null) {
        list.add(CalendarEntry(DateTime(1970, 1, 6).millisecondsSinceEpoch.toString(), DateTime.now().millisecondsSinceEpoch.toString(), 'ERROR', 'ERROR', false));
        AppAnalitics.sendAnaliticsData(AppAnalitics.ERROR, 'api_coms.dart => CalendarRequest.getCalendarEntriesFromJSON() NeptunError: No Calendar data ${map["ErrorMessage"]}');
        return list;
      }
      List<dynamic> sublist = map['calendarData'];
      //debug.log(sublist.toString());
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
      //debug.log(request);
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
  
      DateTime nextSunday = previousMonday.add(const Duration(days: 6, hours: 23, minutes: 59));
      if (nextSunday.weekday == 7) {
        nextSunday = nextSunday.subtract(const Duration(days: 7));
      }
  
      DateTime startOfTargetWeek = previousMonday.add(Duration(days: weekOffset * 7));
      DateTime endOfTargetWeek = nextSunday.add(Duration(days: weekOffset * 7));//.add(Duration(days: 7));
  
      final epochStart = startOfTargetWeek.millisecondsSinceEpoch;
      final epochEnd = endOfTargetWeek.millisecondsSinceEpoch;
  
      return
        '{'
          '"UserLogin":"$username",'
          '"Password":"$password",'
          '"Time":true,'
          '"Exam":true,'
          '"startDate":"/Date($epochStart)/",'
          '"endDate":"/Date($epochEnd)/",'
          '"TotalRowCount":-1'
        '}';
    }
  }
  
  class MarkbookRequest{
    static Future<String> _getMarkbookJSon() async{
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
            '"filter":{"TermID": 0},'
            '"TotalRowCount":-1'
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
      /*List<Term> terms = await _APIRequest._getTermIDs();
      if(terms.isEmpty){
        AppAnalitics.sendAnaliticsData(AppAnalitics.ERROR, 'api_coms.dart => MarkbookRequest._getMarkbookJSon() Error: No Terms');
        return <Subject>[
          Subject(false, 0, 'Hiba a jegyzetfüzet betöltésekor!\nNincs term id', 0, 0, 1),
        ];
      }*/
  
      String responseJson = await _getMarkbookJSon();
      List<dynamic> markbooklistRaw = [];
      markbooklistRaw = conv.json.decode(responseJson)['MarkBookList'];
  
      if(responseJson.isEmpty || markbooklistRaw.isEmpty){    // if we went thru all possible markbooks, but non was valid
        AppAnalitics.sendAnaliticsData(AppAnalitics.ERROR, 'api_coms.dart => MarkbookRequest._getMarkbookJSon() Error: No reponsejson, and markbooklist is empty');
        return null;
      }
  
      List<Subject> subjects = [];
  
      for (var markbook in markbooklistRaw){
        final markbookMap = markbook as Map<String, dynamic>;
        subjects.add(Subject(markbookMap['Completed'], markbookMap['Credit'], markbookMap['SubjectName'], markbookMap['ID'], parseTextToGrade(markbookMap['Values']), parseTextToFailstate(markbookMap['Signer'])));
      }

      return subjects;
    }
  
    static int parseTextToFailstate(String failstate){
      RegExp regex = RegExp(r'(aláírva|megtagadva)');
      final matches = regex.allMatches(failstate.toLowerCase());
      if(matches.isEmpty){
        return 0;
      }

      int best = 99;
      for(var match in matches){
        final result = (match.group(1) ?? '').trim().toLowerCase();
        if(result.isEmpty){
          return 0;
        }
        switch (result){
          case "megtagadva":
            if(best > 1){
              best = 1;
            }
          default:
            if(best > 0){
              best = 0;
            }
        }
      }
      return best;
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
      RegExp regex = RegExp(r'(elégtelen|elégséges|közepes|jó|jeles)');
      final matches = regex.allMatches(gradeTxt.toLowerCase());
      if(matches.isEmpty){
        return 0;
      }

      int best = 0;
      for(var match in matches){
        final result = (match.group(1) ?? '').trim().toLowerCase();
        if(result.isEmpty){
          return 0;
        }
        switch (result){
          case 'jeles':
            if(best < 5){
              best = 5;
            }
            break;
          case 'jó':
            if(best < 4){
              best = 4;
            }
            break;
          case 'közepes':
            if(best < 3){
              best = 3;
            }
            break;
          case 'elégséges':
            if(best < 2){
              best = 2;
            }
            break;
          case 'elégtelen':
            if(best < 1){
              best = 1;
            }
            break;
        }
      }
      return best;
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
      final json =
          '{'
          '"UserLogin":"$username",'
          '"Password":"$password",'
          '"TotalRowCount":-1'
          '}';
  
      final url = Uri.parse(storage.DataCache.getInstituteUrl()! + URLs.GETCASHIN_URL);
  
      List<CashinEntry> entries = CashinRequest._jsonToCashinEntry(await _APIRequest.postRequest(url, json));
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

          //PeriodEntry('bejelentkezési időszak', DateTime(2024, 01, 15, 00, 00).millisecondsSinceEpoch, DateTime(2024, 02, 09, 24, 59, 59).millisecondsSinceEpoch, 1),
        ];
      }
      final terms = await _APIRequest._getTermIDs();
      if(terms.isEmpty){
        AppAnalitics.sendAnaliticsData(AppAnalitics.ERROR, 'api_coms.dart => PeriodsRequest.getPeriods() Error: No Terms');
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
          '"TotalRowCount":-1'
          '}';
      final request = await _APIRequest.postRequest(url, json);
      return request;
    }
  }

  class MailRequest{
    static Future<List<int>> getUnreadMessagesAndAllMessages()async{
      List<int> list = [];
      final json = await _getMailJson(0);
      var result = conv.json.decode(json)['NewMessagesNumber'];
      list.add(result);
      result = conv.json.decode(json)['TotalRowCount'];
      list.add(result);
      return list;
    }
    static Future<List<MailEntry>?> getMails(int page) async{
      if(storage.DataCache.getIsDemoAccount()!){
        final now = DateTime.now();
        return <MailEntry>[
          MailEntry('Tárgy', 'Szöveg', 'DEMO feladó', now.subtract(const Duration(hours: 1)).millisecondsSinceEpoch, false, 0),
          MailEntry('DEMO', 'Demo Demo Demo\n\n\nDEmo demo', 'DEMO feladó', now.subtract(const Duration(hours: 2)).millisecondsSinceEpoch, false, 0),
          MailEntry('DEMO', 'Demo Demo Demo\n\n\nDEmo demo', 'DEMO feladó', now.subtract(const Duration(hours: 23)).millisecondsSinceEpoch, true, 0),
          MailEntry('DEMO', 'Demo Demo Demo\n\n\nDEmo demo', 'DEMO feladó', now.subtract(const Duration(days: 10)).millisecondsSinceEpoch, true, 0),
          MailEntry('DEMO', 'Demo Demo Demo\n\n\nDEmo demo', 'DEMO feladó', now.subtract(const Duration(days: 100)).millisecondsSinceEpoch, false, 0),
          MailEntry('DEMO', 'Demo Demo Demo\n\n\nDEmo demo', 'DEMO feladó', now.subtract(const Duration(days: 370)).millisecondsSinceEpoch, true, 0),
        ];
      }

      final request = await _getMailJson(page);
      List<MailEntry> mails = getMailEntrysJson(request);
      return mails;
    }

    static Future<String> _getMailJson(int page)async{
      final username = storage.DataCache.getUsername();
      final password = storage.DataCache.getPassword();
      final url = Uri.parse(storage.DataCache.getInstituteUrl()! + URLs.MESSAGES_URL);
      //final json = _APIRequest.getGenericPostData(username!, password!);
      final json =
      '{'
      '"UserLogin":"$username",'
      '"Password":"$password",'
      '"CurrentPage":$page,'
      '"TotalRowCount":-1,'
      '"MessageID":0,'
      '"MessageSortEnum":0'
      '}';
      final request = await _APIRequest.postRequest(url, json);
      return request;
    }

    static List<MailEntry> getMailEntrysJson(String json){
      List<MailEntry> mails = [];
      final result = conv.json.decode(json)['MessagesList'] as List<dynamic>;
      for(var item in result){
        mails.add(MailEntry(item['Subject'], removeBloatFromMail(item['Detail']), item['Name'], int.parse(item['SendDate'].toString().replaceAll('\/Date(', '').replaceAll(')\/', '')), !item['IsNew'], item['PersonMessageId']));
      }
      return mails;
    }

    static String removeBloatFromMail(String raw){
      var sanitised = raw.trim();
      sanitised = sanitised.replaceAll(RegExp(r'\.\w+\{[^}]*\}'), '');
      return sanitised.trim();
    }

    static Future<void> setMailRead(int id)async{
      if(storage.DataCache.getIsDemoAccount()!){
        return;
      }
      final username = storage.DataCache.getUsername();
      final password = storage.DataCache.getPassword();
      final url = Uri.parse(storage.DataCache.getInstituteUrl()! + URLs.MESSAGE_SET_READ);
      final json =
          '{'
          '"UserLogin":"$username",'
          '"Password":"$password",'
          '"PersonMessageId":$id,'
          '}';
      await _APIRequest.postRequest(url, json);
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
    late String subjectCode;
    late String teacher;

    CalendarEntry(String start, String end, String loc, String rawTitle, this.isExam){
      startEpoch = int.parse(start);
      startEpoch = DateTime.fromMillisecondsSinceEpoch(startEpoch).subtract(Duration(hours: (Generic.isDaylightSavings(DateTime.fromMillisecondsSinceEpoch(startEpoch)) ? 2 : 1))).millisecondsSinceEpoch;
  
      endEpoch = int.parse(end);
      endEpoch = DateTime.fromMillisecondsSinceEpoch(endEpoch).subtract(Duration(hours: (Generic.isDaylightSavings(DateTime.fromMillisecondsSinceEpoch(endEpoch)) ? 2 : 1))).millisecondsSinceEpoch;
  
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
      
      final regex2 = RegExp(r'\((.*?)\)');
      final match2 = regex2.firstMatch(rawTitle);

      if(match2 != null){
        subjectCode = match2.group(1)!.trim().replaceAll('(', '').replaceAll(')', '');
      }
      else{
        subjectCode = 'Nincs Adat';
      }

      var regex3 = RegExp(r'\([^)]+\)(?=\s*\([^)]+\)*$)'); //igen... egy jéghideg olyat kérünk
      var match3 = regex3.firstMatch(rawTitle);

      if(match3 != null){
        teacher = match3.group(0)!.trim().replaceAll('(', '').replaceAll(')', '');
      }
      else{
        regex3 = RegExp(r'(?<=Minden hét\s)\((.*?)\)');
        match3 = regex3.firstMatch(rawTitle);
        if(match3 != null){
          teacher = match3.group(1)!.trim().replaceAll('(', '').replaceAll(')', '');
        }
        else{
          teacher = 'Nincs Adat';
        }
      }
    }
  
    @override
    String toString() {
      return '$startEpoch\n$endEpoch\n$location\n$title\n$isExam\n$teacher\n$subjectCode';
    }
  
    CalendarEntry fillWithExisting(String existing){
      var data = existing.split('\n');
      if(data.isEmpty || data.length < 7){
        return this;
      }
      startEpoch = int.parse(data[0]);
      endEpoch = int.parse(data[1]);
      location = data[2];
      title = data[3];
      isExam = bool.parse(data[4]);
      teacher = data[5];
      subjectCode = data[6];
      return this;
    }

    bool isIdentical(CalendarEntry other){
      if(this.title == other.title && this.subjectCode == other.subjectCode && this.location == other.location && this.teacher == other.teacher && this.isExam == other.isExam){
        return true;
      }
      return false;
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
      var correctedEndEpoch = DateTime(endEp.year, endEp.month, endEp.day);
      final isOverflowedByOneDay = endEp.add(Duration(minutes: 1)).hour == 1;
      if(isOverflowedByOneDay){
        correctedEndEpoch = correctedEndEpoch.subtract(Duration(days: 1));
      }
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

  class MailEntry{
    String subject;
    String detail;
    String senderName;
    int sendDateMs;
    bool isRead;
    int ID;
    MailEntry(this.subject, this.detail, this.senderName, this.sendDateMs, this.isRead, this.ID);

    @override
    String toString() {
      return '$subject\u0000$detail\u0000$senderName\u0000$sendDateMs\u0000$isRead\u0000$ID';
    }

    MailEntry fillWithExisting(String existing){
      var data = existing.split('\u0000');
      if(data.isEmpty || data.length < 6){
        return this;
      }
      subject = data[0];
      detail = data[1];
      senderName = data[2];
      sendDateMs = int.parse(data[3]);
      isRead = bool.parse(data[4]);
      ID = int.parse(data[5]);
      return this;
    }
  }
  
  class Generic {
    static String reactionForAvg(double avg) {
      if (avg >= 5.0) {
        return "💀";
      }
      else if (avg >= 4.25) {
        return "🤓";
      }
      else if (avg >= 3.75) {
        return "😌";
      }
      else if (avg >= 2.75) {
        return "😐";
      }
      else if (avg >= 2) {
        return "😬";
      }
      else if (avg > 0) {
        return "🤡";
      }
      else {
        return '🤗';
      }
    }

    static String monthToText(int month) {
      switch (month) {
        case 1:
          return AppStrings.getLanguagePack().api_monthJan_Universal;
        case 2:
          return AppStrings.getLanguagePack().api_monthFeb_Universal;
        case 3:
          return AppStrings.getLanguagePack().api_monthMar_Universal;
        case 4:
          return AppStrings.getLanguagePack().api_monthApr_Universal;
        case 5:
          return AppStrings.getLanguagePack().api_monthMay_Universal;
        case 6:
          return AppStrings.getLanguagePack().api_monthJun_Universal;
        case 7:
          return AppStrings.getLanguagePack().api_monthJul_Universal;
        case 8:
          return AppStrings.getLanguagePack().api_monthAug_Universal;
        case 9:
          return AppStrings.getLanguagePack().api_monthSep_Universal;
        case 10:
          return AppStrings.getLanguagePack().api_monthOkt_Universal;
        case 11:
          return AppStrings.getLanguagePack().api_monthNov_Universal;
        case 12:
          return AppStrings.getLanguagePack().api_monthDec_Universal;
      }
      return "NULL";
    }

    static String dayToText(int day){
      switch(day){
        case 1:
          return AppStrings.getLanguagePack().api_dayMon_Universal;
        case 2:
          return AppStrings.getLanguagePack().api_dayTue_Universal;
        case 3:
          return AppStrings.getLanguagePack().api_dayWed_Universal;
        case 4:
          return AppStrings.getLanguagePack().api_dayThu_Universal;
        case 5:
          return AppStrings.getLanguagePack().api_dayFri_Universal;
        case 6:
          return AppStrings.getLanguagePack().api_daySat_Universal;
        case 7:
          return AppStrings.getLanguagePack().api_daySun_Universal;
        default:
          return '';
      }
    }

    static String capitalizePeriodText(String periodName) {
      final chars = periodName
          .toLowerCase()
          .trim()
          .characters
          .toList();
      String str = '';
      int idx = 0;
      bool setNexttoCapitalize = false;
      for (var item in chars) {
        if (idx == 0 || setNexttoCapitalize) {
          str += item.toUpperCase();
          idx++;
          setNexttoCapitalize = false;
          continue;
        }
        if (item == ' ') {
          setNexttoCapitalize = true;
        }
        str += item;
        idx++;
      }
      return str;
    }

    static String randomLoadingComment(bool familyFriendlyMode) {
      if (!familyFriendlyMode) {
        final gen = Random().nextInt(100) % 7;
        switch (gen) {
          case 0:
            return AppStrings.getLanguagePack().api_loadingScreenHintFriendly1_Universal;
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
      switch (gen) {
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
    static String randomLoadingCommentMini(bool familyFriendlyMode) {
      if (!familyFriendlyMode) {
        final gen = Random().nextInt(100) % 4;
        switch (gen) {
          case 0:
            return 'Egy pillanat...';
          case 1:
            return 'Alakul a molekula...';
          case 2:
            return 'Csak szépen lassan...';
          case 3:
            return 'Tölt valamit nagyon...';
          default:
            return 'Neptun 2';
        }
      }
      final gen = Random().nextInt(100) % 3;
      switch (gen) {
        case 0:
          return 'Na, megvan?...';
        case 1:
          return 'Várjál! Nem megy ez ilyen gyorsan...';
        case 2:
          return 'Nem emlékszel mit olvastál? Szedj B6 vitamint!...';
        default:
          return 'Neptun 2';
      }
    }

    static List<InlineSpan> textToInlineSpan(String text) {
      List<InlineSpan> spans = [];

      final htmlLink = RegExp(r'<a[^>]*>(.*?)</a>|https?://\S+|mailto:\S+');

      // Split the text at anchor tags using the regex pattern
      List<String> matches = htmlLink.allMatches(text)
          .map((m) => m.group(0)!)
          .toList();
      List<String> parts = text.split(htmlLink);

      for (int i = 0; i < parts.length; i++) {
        spans.add(TextSpan(text: parts[i]));
        if (i < matches.length) {
          if (matches[i].startsWith('<a')) {
            final htmlLink2 = RegExp(r'>(.*?)</a>');
            final match = htmlLink2.firstMatch(matches[i]);
            if (match == null) {
              continue;
            }
            final newText = match.group(1)!;

            final isMailTo = newText.contains('@') &&
                !(newText.contains('https://') || newText.contains('http://'));

            spans.add(ClickableTextSpan.getNewClickableSpan(
                ClickableTextSpan.getNewOpenLinkCallback(
                    isMailTo ? 'mailto:$newText' : newText), newText,
                ClickableTextSpan.getStockStyle()));
          } else {
            // Handle URLs
            final url = matches[i];
            spans.add(ClickableTextSpan.getNewClickableSpan(
                ClickableTextSpan.getNewOpenLinkCallback(url), url,
                ClickableTextSpan.getStockStyle()));
          }
        }
      }

      return spans;
    }

    static void setupDaylightSavingsTime(){
      final now = DateTime.now();
      var probableSunday = DateTime(now.year, 3, 31, 0, 0, 0);
      if(probableSunday.weekday == 7){
        daylightSavingsTimeFrom = probableSunday;
      }
      else{
        daylightSavingsTimeFrom = probableSunday.subtract(Duration(days: probableSunday.weekday));
        if(daylightSavingsTimeFrom.hour != 0){
          daylightSavingsTimeFrom = DateTime(daylightSavingsTimeFrom.year, daylightSavingsTimeFrom.month, daylightSavingsTimeFrom.day + 1);
        }
      }

      probableSunday = DateTime(now.year, 10, 31, 0, 0, 0);
      if(probableSunday.weekday == 7){
        daylightSavingsTimeTo = probableSunday;
      }
      else{
        daylightSavingsTimeTo = probableSunday.subtract(Duration(days: probableSunday.weekday));
      }
    }

    static DateTime daylightSavingsTimeFrom = DateTime(DateTime.now().year, 3, 31, 0, 0, 0);
    static DateTime daylightSavingsTimeTo = DateTime(DateTime.now().year, 10, 27, 0, 0, 0);

    static bool isDaylightSavings(DateTime time){
      return (daylightSavingsTimeFrom.microsecondsSinceEpoch < time.microsecondsSinceEpoch && time.microsecondsSinceEpoch < daylightSavingsTimeTo.microsecondsSinceEpoch);
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
          if(!hasValidCertificate){
            AppAnalitics.sendAnaliticsData(AppAnalitics.ERROR, 'api_coms.dart => NeptunCerts.createHttpClient() Error: app found an invalid cert');
            AppAnalitics.sendAnaliticsData(AppAnalitics.INFO, 'api_coms.dart => NeptunCerts.createHttpClient() CERT: "' + cert.sha1.toString() + '" Needed: "' + validCertSha1.toString() + '"');
          }
          return hasValidCertificate;
        };
    }
  }