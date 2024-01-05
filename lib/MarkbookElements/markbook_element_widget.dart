import 'package:flutter/material.dart';
import '../Misc/emojirich_text.dart';

class MarkbookElementWidget extends StatelessWidget{
  final String name;
  final int credit;
  final bool completed;
  final int grade;
  final bool isFailed;

  Color getGradeColor(){
    if(grade < 2){
      return Colors.transparent;
    }
    switch (grade){
      case 5:
        return Colors.green.shade200;
      case 4:
        return Colors.lightGreen.shade200;
      case 3:
        return Colors.yellow.shade200;
      case 2:
        return Colors.red.shade200;
      default:
        return Colors.transparent;
    }
  }

  const MarkbookElementWidget({super.key, required this.name, required this.credit, required this.completed, required this.grade, required this.isFailed});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Leftmost position
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 30, 0),
                child: EmojiRichText(
                  text: "$credit🎖️",
                  defaultStyle: const TextStyle(
                      color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
                      fontWeight: FontWeight.w900,
                      fontSize: 26.0,
                    ),
                  emojiStyle: const TextStyle(
                    color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
                    fontSize: 19.0,
                    fontFamily: "Noto Color Emoji"
                  ),
                  ),
                ),
              // Center
              Expanded(
                flex: 2,
                child: Text.rich(
                  TextSpan(
                    text: name,
                    style: TextStyle(
                      fontSize: 17.0,
                      decoration: completed ? TextDecoration.lineThrough : TextDecoration.none,
                      fontWeight: completed ? FontWeight.w300 : FontWeight.normal,
                      decorationColor: Colors.white
                    ),
                  ),
                )
              ),
              Visibility(
                visible: !completed && isFailed,
                  child: Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.close_rounded,
                          color: Colors.red.shade200,
                          size: 26.0,
                        )
                      ],
                    )
                  )
              ),
              Visibility(
                visible: completed,
                child: Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      grade < 2 || credit == 0 ?
                      Icon(
                        Icons.check_rounded,
                        color: Colors.green.shade200,
                        size: 26.0,
                      ) : Text(
                        '$grade',
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