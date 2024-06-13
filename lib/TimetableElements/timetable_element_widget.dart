import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:neptun2/language.dart';
import '../API/api_coms.dart' as api;
import '../Misc/emojirich_text.dart';
import '../Misc/popup.dart';
import '../Pages/main_page.dart';
import '../colors.dart';

typedef Callback = Future<void> Function();

class TimetableCurrentlySelected{
  static api.CalendarEntry? entry;
}

class TimetableElementWidget extends StatelessWidget{

  late final String title;
  late final String location;
  late final String displayStartTime;
  late final String displayEndTime;
  late final bool isExam;
  final bool isCurrent;

  TimetableElementWidget({super.key, required this.entry, required this.position, required this.isCurrent}){
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
    for (realMinutes = 0; realMinutes <= totalMins && realMinutes + 45 <= totalMins; realMinutes += 45){
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
    return GestureDetector(
      onTap: (){
        if(isExam){
          TimetableCurrentlySelected.entry = entry;
          PopupWidgetHandler(mode: 5, callback: (_){});
          PopupWidgetHandler.doPopup(context);
          return;
        }
        TimetableCurrentlySelected.entry = entry;
        PopupWidgetHandler(mode: 4, callback: (_){});
        PopupWidgetHandler.doPopup(context);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: isCurrent ? 10 : 25),
        padding: isExam || isCurrent ? const EdgeInsets.symmetric(vertical: 20, horizontal: 15) : null,
        decoration: isExam || isCurrent ? BoxDecoration(
          border: Border.all(
            color: isExam ? AppColors.getTheme().errorRed.withOpacity(.5) : AppColors.getTheme().currentClassGreen.withOpacity(.5),
            width: .75
          ),
          borderRadius: const BorderRadius.all(Radius.circular(20.0)),
          color: isExam ? AppColors.getTheme().errorRed.withOpacity(.05) : AppColors.getTheme().currentClassGreen.withOpacity(.05)
        ) : const BoxDecoration(
          color: Colors.transparent
        ),
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
                  style: TextStyle(
                    color: AppColors.getTheme().onPrimaryContainer,
                    fontWeight: FontWeight.w900,
                    fontSize: 26.0,
                  ),
                  maxLines: 1,
                ) : Icon(
                    Icons.warning_rounded,
                    color: AppColors.getTheme().errorRed,
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
                        color: AppColors.getTheme().textColor.withOpacity(0.7),
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
                        color: AppColors.getTheme().textColor.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                        fontSize: !isExam ? 14.0 : 16.0,
                      ),
                    ),
                    !isExam ?
                    Text(
                      displayEndTime,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: AppColors.getTheme().textColor.withOpacity(0.4),
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
      ),
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
        child: Center(
            child: EmojiRichText(
              text: AppStrings.getLanguagePack().calendarPage_FreeDay,
              defaultStyle: TextStyle(
                color: AppColors.getTheme().onPrimaryContainer,
                fontWeight: FontWeight.w900,
                fontSize: 34.0,
              ),
              emojiStyle: TextStyle(
                  color: AppColors.getTheme().onPrimaryContainer,
                  fontSize: 34.0,
                  fontFamily: "Noto Color Emoji"
              ),
            ),
        ),
      )
    );
  }
}

class WeekoffseterElementWidget extends StatelessWidget{
  final HomePageState homePage;

  WeekoffseterElementWidget({super.key, required this.week, required this.from, required this.to, required this.onBackPressed, required this.onForwardPressed, required this.canDoPaging, required this.homePage, required this.isLoading}){
    final startMonth = from != null ? api.Generic.monthToText(from!.month) : "_";
    final startDay = from != null ? from!.day : "";

    final endMonth = api.Generic.monthToText(to.month);
    final endDay = to.day;

    displayString = AppStrings.getStringWithParams(AppStrings.getLanguagePack().calendarPage_weekNav_StudyWeek, [week]);

    if(isLoading){
      displayString2 = AppStrings.getLanguagePack().calendarPage_weekNav_ClassesThisWeekLoading;
      return;
    }

    if(startMonth == "_"){
      displayString2 = AppStrings.getLanguagePack().calendarPage_weekNav_ClassesThisWeekEmpty;
      return;
    }
    if("$startMonth $startDay" == "$endMonth $endDay"){
      displayString2 = AppStrings.getStringWithParams(AppStrings.getLanguagePack().calendarPage_weekNav_ClassesThisWeekOneDay, [endMonth, endDay, api.Generic.dayToText(to.weekday)]);
    }
    else{
      displayString2 = AppStrings.getStringWithParams(AppStrings.getLanguagePack().calendarPage_weekNav_ClassesThisWeekFull, [startMonth, startDay, endMonth, endDay]);
    }
  }

  final bool canDoPaging;

  final int week;
  final DateTime? from;
  final DateTime to;

  final Callback onBackPressed;
  final Callback onForwardPressed;

  late final String displayString;
  late final String displayString2;

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (_){
        homePage.calendarWeekCanNavigate = true;
        homePage.calendarWeekSwitchValue = 0.0;
      },
      onHorizontalDragEnd: (_){
        homePage.calendarWeekCanNavigate = false;
        homePage.calendarWeekSwitchValue = 0.0;
      },
      onHorizontalDragUpdate: (e){
        if(!homePage.calendarWeekCanNavigate || !canDoPaging){
          return;
        }
        if(homePage.calendarWeekSwitchValue < -20 && week < 52){
          if(homePage.weeksSinceStart + 1 > 52){
            homePage.calendarWeekCanNavigate = false;
            homePage.calendarWeekSwitchValue = 0.0;
            return;
          }
          //homePage.calendarWeekCanNavigate = false;
          homePage.calendarWeekSwitchValue = -5.0;
          onForwardPressed();
          return;
        }
        else if(homePage.calendarWeekSwitchValue > 20 && week > 1){
          if(homePage.weeksSinceStart - 1 < 1){
            homePage.calendarWeekCanNavigate = false;
            homePage.calendarWeekSwitchValue = 0.0;
            return;
          }
          //homePage.calendarWeekCanNavigate = false;
          homePage.calendarWeekSwitchValue = 5.0;
          onBackPressed();
          return;
        }
        homePage.calendarWeekSwitchValue += e.delta.dx;
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 2),
        color: Colors.black.withOpacity(0.01),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                margin: const EdgeInsets.only(top: 3),
                decoration: BoxDecoration(
                  color: AppColors.getTheme().textColor.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(21),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: week <= 1 || !canDoPaging ? null : onBackPressed,
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    Expanded(
                      child: Text(
                        displayString,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.getTheme().textColor,
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
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                margin: const EdgeInsets.only(bottom: 3),
                decoration: BoxDecoration(
                  color: AppColors.getTheme().textColor.withOpacity(0.03),
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(12), bottomLeft: Radius.circular(12)),
                ),
                child: EmojiRichText(
                  text: displayString2,
                  defaultStyle: TextStyle(
                    color: AppColors.getTheme().textColor.withOpacity(.6),
                    fontWeight: FontWeight.w300,
                    fontSize: 12.0,
                  ),
                  emojiStyle: TextStyle(
                      color: AppColors.getTheme().textColor,
                      fontSize: 12.0,
                      fontFamily: "Noto Color Emoji"
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}