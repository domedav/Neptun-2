import 'package:flutter/material.dart';
import '../Misc/emojirich_text.dart';

class MarkbookElementWidget extends StatelessWidget{
  final String name;
  final int credit;
  final bool completed;

  const MarkbookElementWidget({super.key, required this.name, required this.credit, required this.completed});

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
                    fontSize: 18.0,
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
                      fontSize: 16.0,
                      decoration: completed ? TextDecoration.lineThrough : TextDecoration.none,
                      decorationColor: Colors.white
                    ),
                  ),
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
                      Icon(
                        Icons.check_rounded,
                        color: Colors.green.shade200,
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