import 'package:flutter/material.dart';
import '../API/api_coms.dart' as api;

typedef Callback = Future<void> Function();

class TimetableElementWidget extends StatelessWidget{

  late String title = "NULL";
  late String location = "NULL";
  late String displayStartTime = "NULL";
  late String displayEndTime = "NULL";
  late bool isExam = false;

  TimetableElementWidget({super.key, required this.entry, required this.position}){
    title = entry.title;
    location = entry.location;

    var date = DateTime.fromMillisecondsSinceEpoch(entry.startEpoch);
    var hour = date.hour.toString().padLeft(2, '0');
    var minute = date.minute.toString().padLeft(2, '0');

    displayStartTime = "$hour:$minute";

    date = DateTime.fromMillisecondsSinceEpoch(entry.endEpoch).subtract(Duration(hours: date.hour, minutes: date.minute));
    hour = date.hour.toString().padLeft(2, '0');
    minute = date.minute.toString().padLeft(2, '0');

    var totalMins = date.hour * 60 + date.minute;

    var realMinutes = 0;
    var realHours = 0;
    var i = 1;
    for (realMinutes = 0; realMinutes < totalMins && realMinutes + 45 < totalMins; realMinutes += 45){
      if(i % 2 == 0){
        realHours++;
      }
      i++;
    }
    realMinutes -= realHours * 60;

    date = DateTime.fromMillisecondsSinceEpoch(entry.startEpoch).add(Duration(hours: realHours, minutes: realMinutes));
    hour = date.hour.toString().padLeft(2, '0');
    minute = date.minute.toString().padLeft(2, '0');
    displayEndTime =  "$hour:$minute";

    isExam = entry.isExam;
  }

  final api.CalendarEntry entry;
  final int position;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      padding: isExam ? const EdgeInsets.symmetric(vertical: 20, horizontal: 10) : null,
      decoration: isExam ? BoxDecoration(
        border: Border.all(
          color: const Color.fromRGBO(0xBF, 0x86, 0x86, .5),
          width: .75
        ),
        borderRadius: const BorderRadius.all(Radius.circular(20.0)),
        color: const Color.fromRGBO(0xBF, 0x86, 0x86, .05)
      ) : null,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Leftmost position
            Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 30, 0),
              child: !isExam ? Text(
                "$position.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
                  fontWeight: FontWeight.w900,
                  fontSize: 26.0,
                ),
                maxLines: 1,
              ) : const Icon(
                  Icons.warning_rounded,
                  color: Color.fromRGBO(0xBF, 0x86, 0x86, 1.0),
                  size: 28.0,
              ),
            ),
            // Center
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    location,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ),

            // Rightmost position
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    displayStartTime,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                      fontSize: !isExam ? 14.0 : 16.0,
                    ),
                  ),
                  !isExam ?
                  Text(
                    displayEndTime,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontWeight: FontWeight.w300,
                      fontSize: 12.0,
                    ),
                  ) : const SizedBox(),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }

}

class FreedayElementWidget extends StatelessWidget{
  const FreedayElementWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: const Center(
            child: Text(
              "🥳 Szabadnap! 🥳",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
                fontWeight: FontWeight.w900,
                fontSize: 34.0,
              ),
              maxLines: 1,
            ),
        ),
      )
    );
  }
}

class WeekoffseterElementWidget extends StatelessWidget{
  WeekoffseterElementWidget({super.key, required this.week, required this.from, required this.to, required this.onBackPressed, required this.onForwardPressed, required this.canDoPaging}){
    final startMonth = from != null ? _monthToText(from!.month) : "_";
    final startDay = from != null ? from!.day : "";

    final endMonth = _monthToText(to.month);
    final endDay = to.day;

    if(startMonth == "_"){
      displayString = "$week. Hét";
      return;
    }

    displayString = "$week. Hét\n($startMonth $startDay. - $endMonth $endDay.)";
  }

  final bool canDoPaging;

  final int week;
  final DateTime? from;
  final DateTime to;

  final Callback onBackPressed;
  final Callback onForwardPressed;

  late String displayString = "NULL";

  String _monthToText(int month){
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
                onPressed: week <= 1 || !canDoPaging ? null : onBackPressed,
                icon: const Icon(Icons.arrow_back_rounded)
            ),
            Expanded(
                child: Text(
                  displayString,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16.0,
                  ),
                ),
            ),
            IconButton(
                onPressed: week >= 52 || !canDoPaging ? null : onForwardPressed,
                icon: const Icon(Icons.arrow_forward_rounded)
            ),
          ],
        ),
      ),
    );
  }
}