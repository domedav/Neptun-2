import 'dart:convert';
import 'dart:developer' as d;
import 'dart:math';

import 'package:neptun2/API/api_coms.dart';
import 'package:neptun2/storage.dart';

import '../local_file_actions.dart';

class ICSCalendar{
  static bool _hasInit = false;
  static void initialize(){
    ICSStreamConverter.calendarEntries.clear();
    IcsImportHelper.streamIcsFileContent(ICSCalendar.icsStream).then((status){
      if(!status){
        return;
      }
      _hasInit = status;
    });
  }

  static bool isReady(){
    return _hasInit && !_streamingIcs;
  }

  static bool _streamingIcs = false;
  static void icsStream(Stream<List<int>> stream, {bool? firstLine}){
    _streamingIcs = true;
    final converter = ICSStreamConverter();
    stream.transform(utf8.decoder).transform(new LineSplitter()).listen(cancelOnError: false, onError: (_){}, onDone: (){
      _streamingIcs = false;
    }, firstLine != null && firstLine ? converter.takeLineFirstEvent : converter.takeLine);
  }

  static int _cachedFirstMs = 0;
  static Future<int> getFirstEventStartMs()async{
    if(_cachedFirstMs != 0){
      return _cachedFirstMs;
    }
    await IcsImportHelper.streamIcsFileContent((stream){
      icsStream(stream, firstLine: true);
    }).whenComplete((){
      _cachedFirstMs = ICSStreamConverter.calendarEntries[0].startEpoch;
    });
    ICSStreamConverter.calendarEntries.clear();
    return _cachedFirstMs;
  }

  static List<CalendarEntry> getCalendarInterval(int startMs, int endMs){
    List<CalendarEntry> list = [];
    for(var item in ICSStreamConverter.calendarEntries){
      if(item.startEpoch < startMs || item.endEpoch > endMs){
        continue;
      }
      list.add(item);
    }
    //sort
    for(int i = 0; i < list.length; i++){
      for(int j = i; j < list.length -1; j++){
        if(list[i].startEpoch > list[j].startEpoch){
          final tmp = list[j];
          list[j] = list[i];
          list[i] = tmp;
        }
      }
    }
    return list;
  }
}

class ICSStreamConverter{
  static List<CalendarEntry> calendarEntries = [];

  List<String> _buffer = ['', '', '', ''];
  bool _isReading = false;

  static const String startKeyword = 'BEGIN:VEVENT';
  static const String startTimeKeyword = r'DTSTART:(.*)';
  static const String endTimeKeyword = r'DTEND:(.*)';
  static const String locationKeyword = r'LOCATION:(.*)';
  static const String summaryKeyword = r'SUMMARY:(.*)';
  static const List<String> rexpressions = [startTimeKeyword, endTimeKeyword, locationKeyword, summaryKeyword];
  static const String endKeyword = 'END:VEVENT';

  void takeLine(String line){
    if(line.contains(startKeyword)){
      _isReading = true;
      return;
    }
    else if(line.contains(endKeyword)){
      _isReading = false;
      final startMs = DateTime.parse(_buffer[0]).millisecondsSinceEpoch;
      final finishMs = DateTime.parse(_buffer[1]).millisecondsSinceEpoch;
      calendarEntries.add(CalendarEntry(startMs.toString(), finishMs.toString(), _buffer[2], RegExp(r'^[^\(]+').firstMatch(_buffer[3])?.group(0) ?? 'ERROR', false));
      _buffer.clear();
      _buffer.addAll(['', '', '', '']);
      return;
    }
    else if(!_isReading){
      return;
    }

    for(int i = 0; i < 4; i++){
      final rexpression = rexpressions[i];
      if(RegExp(rexpression).hasMatch(line)){
        final value = RegExp(rexpression).firstMatch(line)?.group(1);
        _buffer[i] = value ?? '0';
        return;
      }
    }
  }

  void takeLineFirstEvent(String line){
    if(calendarEntries.isNotEmpty){
      return;
    }
    takeLine(line);
  }
}