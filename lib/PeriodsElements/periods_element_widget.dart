import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neptun2/Misc/emojirich_text.dart';

import '../API/api_coms.dart';

class PeriodsElementWidget extends StatelessWidget{
  final String displayName;
  final String formattedStartTime;
  final String formattedStartTimeYear;
  final String formattedEndTime;
  final String formattedEndTimeYear;
  final bool isActive;
  final PeriodType periodType;
  final int endTime;
  final int startTime;
  final bool expired;

  const PeriodsElementWidget({super.key, required this.displayName, required this.formattedStartTime, required this.formattedEndTime, required this.formattedEndTimeYear, required this.formattedStartTimeYear, required this.isActive, required this.periodType, required this.startTime, required this.endTime, required this.expired});

  EmojiRichText? getIconFromType(PeriodType periodType){
    switch (periodType) {
      case PeriodType.timetableRegistration:
        return const EmojiRichText(
          text: '📄',
          defaultStyle: TextStyle(
            color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
            fontWeight: FontWeight.w900,
            fontSize: 20.0,
          ),
          emojiStyle: TextStyle(
              color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
              fontSize: 20.0,
              fontFamily: "Noto Color Emoji"
          ),
        );
      case PeriodType.gradingTime:
        return const EmojiRichText(
          text: '⭐',
          defaultStyle: TextStyle(
            color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
            fontWeight: FontWeight.w900,
            fontSize: 20.0,
          ),
          emojiStyle: TextStyle(
              color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
              fontSize: 20.0,
              fontFamily: "Noto Color Emoji"
          ),
        );
      case PeriodType.loginTime:
        return const EmojiRichText(
          text: '🪪',
          defaultStyle: TextStyle(
            color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
            fontWeight: FontWeight.w900,
            fontSize: 20.0,
          ),
          emojiStyle: TextStyle(
              color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
              fontSize: 20.0,
              fontFamily: "Noto Color Emoji"
          ),
        );
      case PeriodType.pregivenGradingAccepting:
        return const EmojiRichText(
          text: '📑',
          defaultStyle: TextStyle(
            color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
            fontWeight: FontWeight.w900,
            fontSize: 20.0,
          ),
          emojiStyle: TextStyle(
              color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
              fontSize: 20.0,
              fontFamily: "Noto Color Emoji"
          ),
        );
      case PeriodType.timetableFinalization:
        return const EmojiRichText(
          text: '📝',
          defaultStyle: TextStyle(
            color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
            fontWeight: FontWeight.w900,
            fontSize: 20.0,
          ),
          emojiStyle: TextStyle(
              color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
              fontSize: 20.0,
              fontFamily: "Noto Color Emoji"
          ),
        );
      case PeriodType.coursesRegistration:
        return const EmojiRichText(
          text: '📚',
          defaultStyle: TextStyle(
            color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
            fontWeight: FontWeight.w900,
            fontSize: 20.0,
          ),
          emojiStyle: TextStyle(
              color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
              fontSize: 20.0,
              fontFamily: "Noto Color Emoji"
          ),
        );
      case PeriodType.nerdTime:
        return const EmojiRichText(
            text: '🤓',
          defaultStyle: TextStyle(
            color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
            fontWeight: FontWeight.w900,
            fontSize: 20.0,
          ),
          emojiStyle: TextStyle(
              color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
              fontSize: 20.0,
              fontFamily: "Noto Color Emoji"
          ),
        );
      case PeriodType.examTime:
        return const EmojiRichText(
          text: '🎓',
          defaultStyle: TextStyle(
            color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
            fontWeight: FontWeight.w900,
            fontSize: 20.0,
          ),
          emojiStyle: TextStyle(
              color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
              fontSize: 20.0,
              fontFamily: "Noto Color Emoji"
          ),
        );
      default:
        return const EmojiRichText(
          text: '❓',
          defaultStyle: TextStyle(
            color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
            fontWeight: FontWeight.w900,
            fontSize: 20.0,
          ),
          emojiStyle: TextStyle(
              color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
              fontSize: 20.0,
              fontFamily: "Noto Color Emoji"
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currVal = Duration(milliseconds: endTime - DateTime.now().millisecondsSinceEpoch).inDays + 0.0;
    final maxVal = Duration(milliseconds: endTime-startTime).inDays + 0.0;
    final now = DateTime.now().millisecondsSinceEpoch;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      width: MediaQuery.of(context).size.width,
      decoration: isActive ? BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.transparent
          ],
          stops: [1 - (currVal / maxVal), 1 - (currVal / maxVal)]
        )
      ) : null,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            displayName,
            style: TextStyle(
              color: expired ? Colors.red : Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 17.0,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          isActive ? Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              getIconFromType(periodType) ?? const SizedBox(),
              Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        formattedStartTimeYear,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.55),
                          fontWeight: FontWeight.w400,
                          fontSize: 11.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        formattedStartTime,
                        style: const TextStyle(
                          color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
                          fontWeight: FontWeight.w700,
                          fontSize: 14.0,
                        ),
                        textAlign: TextAlign.center,
                      )
                    ],
                  )
              ),
              const Expanded(flex: 1, child: SizedBox()),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      formattedEndTimeYear,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontWeight: FontWeight.w400,
                        fontSize: 11.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      formattedEndTime,
                      style: const TextStyle(
                        color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
                        fontWeight: FontWeight.w700,
                        fontSize: 14.0,
                      ),
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
            ],
          ) :
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              getIconFromType(periodType) ?? const SizedBox(),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Flexible(
                      child: Text(
                        expired ? 'Lejárt: ' : 'Kezdődik: ',
                        style: TextStyle(
                          color: expired ? Colors.redAccent : Colors.white.withOpacity(0.6),
                          fontWeight: FontWeight.normal,
                          fontSize: 14.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        expired ? '$formattedEndTimeYear $formattedEndTime' : '$formattedStartTimeYear $formattedStartTime',
                        style: TextStyle(
                          color: expired ? Colors.redAccent : Colors.white.withOpacity(0.6),
                          fontWeight: FontWeight.w600,
                          fontSize: 14.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Text(
            expired ? '(${-(Duration(milliseconds: endTime - now).inDays + 1)} napja)' : (!isActive ? '(${Duration(milliseconds: startTime - now).inDays + 1} nap múlva)' : '(${Duration(milliseconds: endTime - now).inDays + 1} nap van hátra)'),
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontWeight: FontWeight.w400,
              fontSize: 11.0,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}