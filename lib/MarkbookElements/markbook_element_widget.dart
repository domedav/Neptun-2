import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:neptun2/Misc/popup.dart';
import '../Misc/emojirich_text.dart';
import '../colors.dart';

typedef Callback = void Function(int, int);

class MarkbookElementWidget extends StatelessWidget{
  final String name;
  final int credit;
  final bool completed;
  final int grade;
  final bool isFailed;
  final Callback onPopupResult;
  final int listIndex;
  final int ghostGrade;

  Color getGradeColor(){
    if(ghostGrade != -1){
      return AppColors.getTheme().textColor.withOpacity(.4);
    }
    switch (grade){
      case 5:
        return AppColors.getTheme().grade5;
      case 4:
        return AppColors.getTheme().grade4;
      case 3:
        return AppColors.getTheme().grade3;
      case 2:
        return AppColors.getTheme().grade2;
      case 1:
        return AppColors.getTheme().grade1;
      default:
        return Colors.transparent;
    }
  }

  const MarkbookElementWidget({super.key, required this.name, required this.credit, required this.completed, required this.grade, required this.isFailed, required this.onPopupResult, required this.listIndex, required this.ghostGrade});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: grade >= 2 || credit == 0 ? null : () {
          PopupWidgetHandler(mode: 0, callback: (r){
            onPopupResult(r as int, listIndex);
          });
          PopupWidgetHandler.doPopup(context);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Leftmost position
              Container(
                child: EmojiRichText(
                  text: "$credit🎖️",
                  defaultStyle: TextStyle(
                      color: AppColors.getTheme().onPrimaryContainer,
                      fontWeight: FontWeight.w900,
                      fontSize: 26.0,
                    ),
                  emojiStyle: TextStyle(
                    color: AppColors.getTheme().onPrimaryContainer,
                    fontSize: 19.0,
                    fontFamily: "Noto Color Emoji"
                    ),
                  ),
                ),
              // Center
              Expanded(
                flex: 2,
                child: Container(
                  margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                  child: Text.rich(
                    TextSpan(
                      text: name,
                      style: TextStyle(
                          fontSize: 14.0,
                          decoration: completed ? TextDecoration.lineThrough : TextDecoration.none,
                          fontWeight: completed ? FontWeight.w400 : FontWeight.w600,
                          decorationColor: AppColors.getTheme().textColor
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: (!completed && isFailed || grade == 1) && ghostGrade == -1,
                  child: Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.close_rounded,
                          color: AppColors.getTheme().grade2,
                          size: 26.0,
                        )
                      ],
                    )
                  )
              ),
              Visibility(
                visible: completed || ghostGrade != -1,
                child: Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      grade < 2 && ghostGrade == -1 || credit == 0 ?
                      Icon(
                        Icons.check_rounded,
                        color: AppColors.getTheme().grade5,
                        size: 26.0,
                      ) : Text(
                        ghostGrade == -1 ? '$grade' : '$ghostGrade',
                        style: TextStyle(
                            color: getGradeColor(),
                            fontSize: 21.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Noto Sans"
                        ),
                      ),
                    ],
                  )
                ),
              )
            ],
          ),
        )
    );
  }
}