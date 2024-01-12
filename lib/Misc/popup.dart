import 'package:flutter/material.dart';
import 'package:neptun2/Pages/main_page.dart';

import 'emojirich_text.dart';

class PopupWidgetHandler{
  static PopupWidgetHandler? _instance;
  static bool _inUse = false;
  BuildContext? _prevContext;
  final HomePageState homePage;

  PopupWidgetHandler({required this.homePage}){
    _instance = this;
  }

  static doPopup(BuildContext context){
    if(_inUse){
      return;
    }
    _inUse = true;
    _instance!._prevContext = context;
    Navigator.of(context).push(
      PageRouteBuilder(
          pageBuilder: (context, anim, anim2) => const PopupWidgetState(),
          opaque: false,
        barrierDismissible: true,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero
      )
    ).then((value) => _instance!._doPopup());
  }

  _doPopup(){
    homePage.setBlurComplex(true);
  }

  static closePopup(bool needPop){
    if(!_inUse){
      return;
    }
    _inUse = false;
    if(needPop){
      Navigator.of(_instance!._prevContext!).pop();
    }
    _instance!._closePopup();
  }

  _closePopup(){
    homePage.setBlurComplex(false);
  }
}

class PopupWidgetState extends StatefulWidget{
  const PopupWidgetState({super.key});

  @override
  State<StatefulWidget> createState() => PopupWidget();
}

class PopupWidget extends State<PopupWidgetState>{

  double sliderValue = 1;

  List<Widget> getWidgets(int mode){
    List<Widget> list = <Widget>[];
    switch (mode){
      case 0:
        list.add(const EmojiRichText(
          text: "👻 Szellemjegy 👻",
          defaultStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 22.0,
          ),
          emojiStyle: TextStyle(
              color: Colors.white,
              fontSize: 19.0,
              fontFamily: "Noto Color Emoji"
          ),
        ));

        list.add(Container(
          color: Colors.white.withOpacity(0.3),
          margin: const EdgeInsets.symmetric(vertical: 10),
          height: 2,
        ));

        list.add(
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(
                  decelerationRate: ScrollDecelerationRate.fast
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Slider(
                      min: 1,
                      max: 5,
                      divisions: 4,
                      value: sliderValue,
                      onChanged: (value){
                        if(sliderValue == value){
                          return;
                        }
                        sliderValue = value;
                      }
                  ),
                ],
              ),
            )
        );

        list.add(FilledButton(
          onPressed: PopupWidgetHandler.closePopup(true),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(const Color.fromRGBO(0xFF, 0xFF, 0xFF, 0.05)),
          ),
          child: Container(
            padding: const EdgeInsets.all(5),
            child: const Text('Ok',
              style: TextStyle(
                color: Color.fromRGBO(0x6D, 0xC2, 0xD3, 1.0),
                fontWeight: FontWeight.w900,
                fontSize: 16.0,
              ),
            ),
          ),
        ));

        return list;
      default:
        return list;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onTap: () => PopupWidgetHandler.closePopup(true),
        behavior: HitTestBehavior.deferToChild,
        child: PopScope(
          onPopInvoked: (_bool) {
            PopupWidgetHandler.closePopup(false);
          },
          child: Container(
            alignment: Alignment.center,
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(50),
              margin: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color.fromRGBO(0x22, 0x22, 0x22, 1.0),
                borderRadius: BorderRadius.all(Radius.circular(40)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: getWidgets(0),
              ),
            )
          ),
        ),
      ),
    );
  }
}