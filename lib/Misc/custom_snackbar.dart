import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';

typedef ChangeCallback = void Function(double, bool);

class AppSnackbar extends StatelessWidget{

  static Timer? selfdestructTimer;

  static void cancelTimer(){
    if(selfdestructTimer != null){
      selfdestructTimer!.cancel();
    }
  }

  final String text;
  final Duration displayDuration;

  final double dragAmmount;
  final ChangeCallback changer;
  final bool state;

  AppSnackbar({super.key, required this.text, required this.displayDuration, required this.dragAmmount, required this.changer, required this.state}){
    if(state == false){
      return;
    }
    if(selfdestructTimer != null){
      selfdestructTimer!.cancel();
    }
    selfdestructTimer = Timer(displayDuration, (){
      changer(999, false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if(state == false || displayDuration.inMilliseconds == 0){
      return const SizedBox();
    }
    return Transform.translate(
      offset: Offset(dragAmmount, 0),
      child: Container(
        padding: const EdgeInsets.only(left: 22, right: 22, top: 10, bottom: 10),
        margin: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(0x22, 0x22, 0x22, 1.0),
          borderRadius: const BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30), bottomRight: Radius.circular(15), bottomLeft: Radius.circular(15)),
          border: Border.all(
            color: Colors.white.withOpacity(.1),
            width: 1,
          )
        ),
        child: GestureDetector(
          onHorizontalDragStart: (_){
            changer(0, true);
          },

          onHorizontalDragEnd: (_){
            changer(0, false);
          },

          onHorizontalDragUpdate: (e){
            changer(dragAmmount + e.delta.dx, true);
          },
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.question_mark_rounded,
                size: 24,
                color: Color.fromRGBO(0x4F, 0x69, 0x6E, 1.0),
              ),
              const SizedBox(width: 15),
              Expanded(
                  child: Text(
                    text,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400
                    ),
                  )
              )
            ],
          ),
        ),
      ),
    );
  }
}