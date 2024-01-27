import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neptun2/Pages/main_page.dart';
import 'package:neptun2/storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'emojirich_text.dart';

typedef Callback = void Function(dynamic);

class PopupWidgetHandler{
  static PopupWidgetHandler? _instance;
  bool _inUse = false;
  BuildContext? _prevContext;
  final int mode;
  static const Duration animTime = Duration(milliseconds: 500);

  double animValue = 0.0;

  PopupWidget? pwidget;
  PackageInfo? pinfo;

  final Callback callback;

  PopupWidgetHandler({required this.mode, required this.callback}){
    _instance = this;
    Future.delayed(Duration.zero, ()async{
      pinfo = await PackageInfo.fromPlatform();
    });
  }

  bool hasListener = false;
  static void doPopup(BuildContext context){
    if(_instance!._inUse){
      return;
    }
    _instance!._inUse = true;
    _instance!._prevContext = context;
    //_instance!.homePage.setBlurComplex(true);
    HomePageState.showBlurPopup(true);

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, anim, anim2) => const PopupWidgetState(),
        opaque: false,
        barrierDismissible: true,
        transitionDuration: animTime,
        reverseTransitionDuration: animTime,
        fullscreenDialog: true,
        transitionsBuilder: (_, anim1, __, widget){
          return animateTransition(anim1, widget);
        }
      )
    );
  }

  static void _anim(Animation<double> anim1){
    if(anim1.isCompleted){
      _instance!.animValue = 0.0;
      _instance!.pwidget = null;
    }
  }

  static Widget animateTransition(Animation<double> anim1, Widget widget){
    if(!_instance!.hasListener){
      _instance!.hasListener = true;
      anim1.addStatusListener((status) {
        if(anim1.isCompleted){
          _anim(anim1);
        }
      });
    }

    var curve = _instance!._inUse ? Curves.bounceOut : Curves.easeOutExpo;
    var tween = Tween<double>(begin: 0.0, end: 1.0).chain(
      CurveTween(curve: curve),
    );

    var scaleAnimation = anim1.drive(tween);
    _instance!.animValue = scaleAnimation.value;
    if(_instance!.pwidget == null){
      return widget;
    }
    return _instance!.pwidget!.getPopup(_instance!.animValue);
  }

  static closePopup(bool needPop){
    if(!_instance!._inUse){
      return;
    }
    _instance!._inUse = false;
    if(needPop){
      Navigator.of(_instance!._prevContext!).pop();
    }
    Future.delayed(animTime, (){
      //_instance!.homePage.setBlurComplex(false);
      HomePageState.showBlurPopup(false);
    });
  }
}

class PopupWidgetState extends StatefulWidget{
  const PopupWidgetState({super.key});

  @override
  State<StatefulWidget> createState() => PopupWidget();
}

class PopupWidget extends State<PopupWidgetState>{

  PopupWidget(){
    PopupWidgetHandler._instance!.pwidget = this;
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color.fromRGBO(0x0C, 0x0C, 0x0C, 1.0), // navigation bar color
      statusBarColor: Color.fromRGBO(0x1A, 0x1A, 0x1A, 1.0), // status bar color
    ));
  }

  int selectionValue = -1;

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
        list.add(const SizedBox(height: 3));
        list.add(Container(
          color: Colors.white.withOpacity(0.3),
          margin: const EdgeInsets.symmetric(vertical: 10),
          height: 2,
        ));
        list.add(const SizedBox(height: 20));
        if(selectionValue == -1) {
          list.add(Text(
            'Válassz jegyet...',
            style: TextStyle(
                color: Colors.white.withOpacity(.4),
                fontSize: 15,
                fontWeight: FontWeight.w300
            ),
          ));
        }
        list.add(
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(
                decelerationRate: ScrollDecelerationRate.fast
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: (){
                      if(!PopupWidgetHandler._instance!._inUse || !mounted){
                        return;
                      }
                      setState(() {
                        selectionValue = 0;
                      });
                    },
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    icon: Text(
                      '1',
                      style: TextStyle(
                        color: selectionValue == -1 || selectionValue == 0 ? Colors.redAccent.shade200 : Colors.redAccent.shade200.withOpacity(.4),
                        fontSize: 30,
                        fontWeight: selectionValue != -1 && selectionValue == 0 ? FontWeight.w800 : FontWeight.normal
                      ),
                    ),
                    color: Colors.redAccent.shade200,
                    enableFeedback: true,
                  ),
                  IconButton(
                    onPressed: (){
                      if(!PopupWidgetHandler._instance!._inUse || !mounted){
                        return;
                      }
                      setState(() {
                        selectionValue = 1;
                      });
                    },
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    icon: Text(
                      '2',
                      style: TextStyle(
                          color: selectionValue == -1 || selectionValue == 1 ? Colors.red.shade200 : Colors.red.shade200.withOpacity(.4),
                          fontSize: 30,
                          fontWeight: selectionValue != -1 && selectionValue == 1 ? FontWeight.w800 : FontWeight.normal
                      ),
                    ),
                    color: Colors.red.shade200,
                    enableFeedback: true,
                  ),
                  IconButton(
                    onPressed: (){
                      if(!PopupWidgetHandler._instance!._inUse || !mounted){
                        return;
                      }
                      setState(() {
                        selectionValue = 2;
                      });
                    },
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    icon: Text(
                      '3',
                      style: TextStyle(
                          color: selectionValue == -1 || selectionValue == 2 ? Colors.yellow.shade200 : Colors.yellow.shade200.withOpacity(.4),
                          fontSize: 30,
                          fontWeight: selectionValue != -1 && selectionValue == 2 ? FontWeight.w800 : FontWeight.normal
                      ),
                    ),
                    color: Colors.yellow.shade200,
                    enableFeedback: true,
                  ),
                  IconButton(
                    onPressed: (){
                      if(!PopupWidgetHandler._instance!._inUse || !mounted){
                        return;
                      }
                      setState(() {
                        selectionValue = 3;
                      });
                    },
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    icon: Text(
                      '4',
                      style: TextStyle(
                          color: selectionValue == -1 || selectionValue == 3 ? Colors.lightGreen.shade200 : Colors.lightGreen.shade200.withOpacity(.4),
                          fontSize: 30,
                          fontWeight: selectionValue != -1 && selectionValue == 3 ? FontWeight.w800 : FontWeight.normal
                      ),
                    ),
                    color: Colors.lightGreen.shade200,
                    enableFeedback: true,
                  ),
                  IconButton(
                    onPressed: (){
                      if(!PopupWidgetHandler._instance!._inUse || !mounted){
                        return;
                      }
                      setState(() {
                        selectionValue = 4;
                      });
                    },
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    icon: Text(
                      '5',
                      style: TextStyle(
                          color: selectionValue == -1 || selectionValue == 4 ? Colors.green.shade200 : Colors.green.shade200.withOpacity(.4),
                          fontSize: 30,
                          fontWeight: selectionValue != -1 && selectionValue == 4 ? FontWeight.w800 : FontWeight.normal
                      ),
                    ),
                    color: Colors.green.shade200,
                    enableFeedback: true,
                  ),
                ],
              ),
            )
        );
        list.add(const SizedBox(height: 20));
        list.add(FilledButton(
          onPressed: (){
            if(!PopupWidgetHandler._instance!._inUse || !mounted){
              return;
            }
            PopupWidgetHandler._instance!.callback(selectionValue);
            PopupWidgetHandler.closePopup(true);
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(const Color.fromRGBO(0xFF, 0xFF, 0xFF, 0.05)),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 15),
            child: const Text('Ok',
              style: TextStyle(
                color: Color.fromRGBO(0x6D, 0xC2, 0xD3, 1.0),
                fontWeight: FontWeight.w900,
                fontSize: 18.0,
              ),
            ),
          ),
        ));

        return list;
      case 1:
        list.add(const EmojiRichText(
          text: "⚙ Beállítások ⚙",
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
        list.add(const SizedBox(height: 3));
        list.add(Container(
          color: Colors.white.withOpacity(0.3),
          margin: const EdgeInsets.symmetric(vertical: 10),
          height: 2,
        ));
        list.add(Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(flex: 2, child: Container(
              margin: const EdgeInsets.all(10),
              child: const Text(
                'Családbarát Betöltő Szövegek',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white
                ),
              ),
            )),
            Container(
              margin: const EdgeInsets.all(10),
              child: Switch(
                value: DataCache.getNeedFamilyFriendlyComments()!,
                onChanged: (b){
                  DataCache.setNeedFamilyFriendlyComments(b ? 1 : 0);
                  if(mounted) {setState((){});}
                },
                activeColor: Colors.white,
                activeTrackColor: const Color.fromRGBO(0x4F, 0x69, 0x6E, 1.0),
                hoverColor: Colors.white.withOpacity(.1),
              ),
            )
          ],
        ));
        list.add(const SizedBox(height: 6));
        final pinfo = PopupWidgetHandler._instance!.pinfo ?? PackageInfo(appName: 'neptun2', packageName: 'com.domedav.neptun2', version: '1.1.2', buildNumber: '7', buildSignature: '');
        list.add(Container(
          alignment: Alignment.bottomLeft,
          margin: const EdgeInsets.all(10),
          child: Text(
            'v${pinfo.version} (${pinfo.buildNumber}) - Telepítve Innen: ${pinfo.installerStore ?? "Csomagtelepítő"}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 9,
              color: Colors.white.withOpacity(.3)
            ),
          ),
        ));
        return list;
      default:
        return list;
    }
  }

  Widget getPopup(double scale){
    return Transform.scale(
      scale: scale,
      child: Material(
        type: MaterialType.transparency,
        child: GestureDetector(
          onTap: (){
            PopupWidgetHandler.closePopup(true);
          },
          behavior: HitTestBehavior.deferToChild,
          child: PopScope(
            onPopInvoked: (_) {
              PopupWidgetHandler.closePopup(false);
            },
            child: Container(
                alignment: Alignment.center,
                color: Colors.transparent,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                    margin: const EdgeInsets.all(15),
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(0x22, 0x22, 0x22, 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: getWidgets(PopupWidgetHandler._instance!.mode),
                    ),
                  ),
                )
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return getPopup(PopupWidgetHandler._instance!.animValue);
  }
}