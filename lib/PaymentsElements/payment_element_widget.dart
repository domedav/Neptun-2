import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neptun2/API/api_coms.dart';

import '../Misc/emojirich_text.dart';

class PaymentElementWidget extends StatelessWidget{
  final int ID;
  final int ammount;
  final int dueDateMs;
  final String name;
  const PaymentElementWidget({super.key, required this.ammount, required this.dueDateMs, required this.name, required this.ID});

  @override
  Widget build(BuildContext context) {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final dueDate = DateTime.fromMillisecondsSinceEpoch(dueDateMs);
    final isNonTimed = dueDateMs <= 0;
    final isMissed = dueDateMs < nowMs && !isNonTimed;

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: isMissed ? BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(20.0)),
        color: const Color.fromRGBO(0xBF, 0x86, 0x86, .05),
        border: Border.all(
          color: Colors.redAccent.withOpacity(.4),
          width: 1
        ),
      ) : null,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15.0,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              EmojiRichText(
                text: isMissed ? '🙉' : '💰',
                defaultStyle: const TextStyle(
                  color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
                  fontWeight: FontWeight.w900,
                  fontSize: 20.0,
                ),
                emojiStyle: TextStyle(
                    color: const Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
                    fontSize: isMissed ? 26.1 : 20.0,
                    fontFamily: "Noto Color Emoji"
                ),
              ),
              Expanded(
                  flex: 2,
                  child: Text(
                    '${ammount}Ft',
                    style: const TextStyle(
                      color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
                      fontWeight: FontWeight.w800,
                      fontSize: 16.0,
                    ),
                    textAlign: TextAlign.center,
                  )
              ),
              !isNonTimed ? const Expanded(flex: 1, child: SizedBox()) : const SizedBox(),
              !isNonTimed ? Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      dueDate.year.toString(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontWeight: FontWeight.w400,
                        fontSize: 11.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '${Generic.monthToText(dueDate.month)} ${dueDate.day}',
                      style: const TextStyle(
                        color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
                        fontWeight: FontWeight.w700,
                        fontSize: 14.0,
                      ),
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ) : const SizedBox(),
            ],
          ),
          !isNonTimed ? Text(
            isMissed ? '(${-(Duration(milliseconds: dueDateMs - nowMs).inDays + 1)} nappal lekésve)' : '(${Duration(milliseconds: dueDateMs - nowMs).inDays + 1} nap van hátra)',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontWeight: FontWeight.w400,
              fontSize: isMissed ? 14.0 : 11.0,
            ),
            textAlign: TextAlign.center,
          ) : const SizedBox(),
        ],
      ),
    );
  }
}