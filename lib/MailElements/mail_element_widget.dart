import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neptun2/API/api_coms.dart';

import '../Misc/emojirich_text.dart';

class MailElementWidget extends StatelessWidget{
  final subject;
  final details;
  final sender;
  final sendTime;
  final isRead;

  const MailElementWidget({super.key, required this.subject, required this.details, required this.sender, required this.sendTime, required this.isRead});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.fromMillisecondsSinceEpoch(sendTime);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              EmojiRichText(
                text: isRead ? '📭' : '📬',
                defaultStyle: const TextStyle(
                  color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
                  fontWeight: FontWeight.w900,
                  fontSize: 20.0,
                ),
                emojiStyle: const TextStyle(
                    color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
                    fontSize: 20.0,
                    fontFamily: "Noto Color Emoji"
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Érkezett: ${date.year}. ${Generic.monthToText(date.month)}. ${date.day}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400
                  ),
                )
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Feladó: $sender',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400
                  ),
                )
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            subject,
            textAlign: TextAlign.start,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700
            ),
          ),
        ],
      ),
    );
  }
}