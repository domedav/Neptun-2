import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:neptun2/Misc/custom_snackbar.dart';
import 'package:neptun2/Pages/main_page.dart';
import 'package:neptun2/haptics.dart';
import 'package:neptun2/language.dart';
import 'package:neptun2/storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../API/api_coms.dart';
import '../MailElements/mail_element_widget.dart';
import '../Pages/startup_page.dart';
import '../TimetableElements/timetable_element_widget.dart';
import 'emojirich_text.dart';

typedef Callback = void Function(dynamic);

class PopupWidgetHandler{
  static bool _hasPopupActive = false;
  static PopupWidgetHandler? _instance;
  bool _inUse = false;
  final linkedScroller = LinkedScrollControllerGroup();
  late ScrollController scrollController;

  final Callback callback;
  final VoidCallback? onCloseCallback;

  int? _settingsLanguagePrevious;
  int? _settingsLanguageCurrent;

  final int mode;

  AnimationController? widgetAnimController;

  static Duration animDuration = Duration(milliseconds: 350);

  PopupWidgetHandler({required this.mode, required this.callback, this.onCloseCallback}){
    if(_hasPopupActive){
      return;
    }
    _instance = this;
    scrollController = linkedScroller.addAndGet();
  }

  bool hasListener = false;
  VoidCallback? _closeBlurCallback;

  static void doPopup(BuildContext context, {VoidCallback? blur = null, VoidCallback? closeBlur = null}){
    if(_instance!._inUse || PopupWidgetHandler._hasPopupActive){
      return;
    }
    _instance!._closeBlurCallback = closeBlur;
    PopupWidgetHandler._hasPopupActive = true;
    _instance!._inUse = true;
    _instance!._settingsLanguagePrevious = DataCache.getUserSelectedLanguage()!;
    _instance!._settingsLanguageCurrent = DataCache.getUserSelectedLanguage()!;
    //_instance!.homePage.setBlurComplex(true);
    if(blur == null){
      HomePageState.showBlurPopup(true);
    }
    else{
      blur();
    }
    AppHaptics.lightImpact();

    Future<PackageInfo>.delayed(Duration.zero, ()async{
      return await PackageInfo.fromPlatform();
    }).then((value){
      Navigator.of(context).push(
          PageRouteBuilder(
              pageBuilder: (context, anim, anim2) => PopupWidgetState(topPadding: MediaQuery.of(context).padding, mode: _instance!.mode, pinfo: value),
              opaque: false,
              barrierDismissible: true,
              transitionDuration: PopupWidgetHandler.animDuration,
              reverseTransitionDuration: Duration.zero,
              fullscreenDialog: true,
              transitionsBuilder: (_, __, ___, widget){
                return widget;
              }
          )
      );
    });
  }

  /*static Widget animateTransition(Animation<double> anim1, Widget widget, BuildContext context){
    if(!_instance!.hasListener){
      _instance!.hasListener = true;
      anim1.addStatusListener((status) {
        if(anim1.isCompleted){
          _instance!.pwidget = null;
          _instance!.animValue = 1.0;
        }
      });
    }

    var curve = _instance!._inUse ? Curves.easeInOutCubicEmphasized : Curves.ease;
    var tween = Tween<double>(begin: 0.0, end: 1.0).chain(
      CurveTween(curve: curve),
    );

    var scaleAnimation = anim1.drive(tween);
    _instance!.animValue = scaleAnimation.value;
    if(_instance!.pwidget == null){
      return widget;
    }
    return _instance!.pwidget!.getPopup(_instance!.animValue, context);
  }*/

  static closePopup(BuildContext context){
    if(!_instance!._inUse){
      return;
    }
    _instance!._inUse = false;
    if(_instance!.widgetAnimController != null){
      _instance!.widgetAnimController!.reverse(from: 1).whenComplete((){
        PopupWidgetHandler._hasPopupActive = false;
        Future.delayed(Duration.zero, (){ // needed, so when the user spams the back button, the app doesnt get a brainfuck, and turns black
          Navigator.of(context).pop();
        });
        if(_instance!._settingsLanguageCurrent != _instance!._settingsLanguagePrevious){
          Navigator.popUntil(context, (route) => route.willHandlePopInternally);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Splitter()),
          );
        }
        _instance!.widgetAnimController!.dispose();
      });
    }

    if(_instance!._closeBlurCallback == null){
      HomePageState.showBlurPopup(false);
    }
    else{
      _instance!._closeBlurCallback!();
    }

    if(PopupWidgetHandler._instance!.onCloseCallback != null){
      PopupWidgetHandler._instance!.onCloseCallback!();
    }
  }
}

class PopupWidgetState extends StatefulWidget{
  PopupWidgetState({super.key, required this.topPadding, required this.mode, required this.pinfo});

  final EdgeInsets topPadding;
  final int mode;
  final PackageInfo? pinfo;

  @override
  State<StatefulWidget> createState() => PopupWidget();
}

class PopupWidget extends State<PopupWidgetState> with TickerProviderStateMixin{

  late AnimationController popupController;
  late Animation<double> poppuAnimation;
  int _languageDropdownMenuIndexer = -1;
  int _languageCurrSelect = 0;
  GlobalKey _languageDropdownGlobalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color.fromRGBO(0x0C, 0x0C, 0x0C, 1.0), // navigation bar color
      statusBarColor: Color.fromRGBO(0x1A, 0x1A, 0x1A, 1.0), // status bar color
    ));

    popupController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    poppuAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: popupController, curve: Curves.easeInOutCubic),
    );
    PopupWidgetHandler._instance!.widgetAnimController = popupController;
    popupController.forward(from: 0);

    _languageCurrSelect = DataCache.getUserSelectedLanguage()!;
    if(_languageCurrSelect == -1){
      _languageCurrSelect = AppStrings.getAllLangCodes().indexOf(Platform.localeName.split('_')[0].toLowerCase());
    }
  }

  int selectionValue = -1;

  List<Widget> getWidgets(int mode){
    _languageDropdownMenuIndexer = -1;
    List<Widget> list = <Widget>[];
    switch (mode){
      case 0:
        list.add(EmojiRichText(
          text: AppStrings.getLanguagePack().popup_case0_GhostGradeHeader,
          defaultStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 22.0,
          ),
          emojiStyle: const TextStyle(
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
            AppStrings.getLanguagePack().popup_case0_SelectGrade,
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
                      AppHaptics.lightImpact();
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
                      AppHaptics.lightImpact();
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
                      AppHaptics.lightImpact();
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
                      AppHaptics.lightImpact();
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
                      AppHaptics.lightImpact();
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
        list.add(TextButton(
          onPressed: (){
            if(!PopupWidgetHandler._instance!._inUse || !mounted){
              return;
            }
            PopupWidgetHandler._instance!.callback(selectionValue);
            PopupWidgetHandler.closePopup(context);
            AppHaptics.lightImpact();
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(const Color.fromRGBO(0xFF, 0xFF, 0xFF, 0.05)),
            overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(.05)),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 15),
            child: Text(AppStrings.getLanguagePack().popup_caseAll_OkButton,
              style: const TextStyle(
                color: Color.fromRGBO(0x6D, 0xC2, 0xD3, 1.0),
                fontWeight: FontWeight.w900,
                fontSize: 18.0,
              ),
            ),
          ),
        ));

        return list;
      case 1:
        list.add(EmojiRichText(
          text: AppStrings.getLanguagePack().popup_case1_SettingsHeader,
          defaultStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 22.0,
          ),
          emojiStyle: const TextStyle(
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
              child: Text(
                AppStrings.getLanguagePack().popup_case1_settingOption1_FamilyFriendlyLoadingText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white
                ),
              ),
            )),
            Container(
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(90)),
                  color: Colors.white.withOpacity(.06)
              ),
              child: IconButton(
                onPressed: (){
                  _showSnackbar(AppStrings.getLanguagePack().popup_case1_settingOption1_FamilyFriendlyLoadingTextDescription, 8);
                  AppHaptics.attentionLightImpact();
                },
                icon: Icon(
                  Icons.question_mark_rounded,
                  color: Colors.white.withOpacity(.4),
                ),
                enableFeedback: true,
                iconSize: 24,
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child: Switch(
                value: DataCache.getNeedFamilyFriendlyComments()!,
                onChanged: (b){
                  DataCache.setNeedFamilyFriendlyComments(b ? 1 : 0);
                  AppHaptics.lightImpact();
                  if(mounted) {setState((){});}
                },
                activeColor: Colors.white,
                activeTrackColor: const Color.fromRGBO(0x4F, 0x69, 0x6E, 1.0),
                hoverColor: Colors.white.withOpacity(.1),
              ),
            )
          ],
        ));
        list.add(Container(
          height: 1,
          color: Colors.white.withOpacity(.1),
        ));
        list.add(Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(flex: 2, child: Container(
              margin: const EdgeInsets.all(10),
              child: Text(
                AppStrings.getLanguagePack().popup_case1_settingOption2_ExamNotifications,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white
                ),
              ),
            )),
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(90)),
                color: Colors.white.withOpacity(.06)
              ),
              child: IconButton(
                onPressed: (){
                  _showSnackbar(AppStrings.getLanguagePack().popup_case1_settingOption2_ExamNotificationsDescription, 12);
                  AppHaptics.attentionLightImpact();
                },
                icon: Icon(
                  Icons.question_mark_rounded,
                  color: Colors.white.withOpacity(.4),
                ),
                enableFeedback: true,
                iconSize: 24,
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child: Switch(
                value: DataCache.getNeedExamNotifications()!,
                onChanged: (b){
                  DataCache.setNeedExamNotifications(b ? 1 : 0);
                  AppHaptics.lightImpact();
                  if(b){
                    HomePageState.setupExamNotifications();
                  }
                  else{
                    HomePageState.cancelExamNotifications();
                  }
                  if(mounted) {setState((){});}
                },
                activeColor: Colors.white,
                activeTrackColor: const Color.fromRGBO(0x4F, 0x69, 0x6E, 1.0),
                hoverColor: Colors.white.withOpacity(.1),
              ),
            )
          ],
        ));
        list.add(Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(flex: 2, child: Container(
              margin: const EdgeInsets.all(10),
              child: Text(
                AppStrings.getLanguagePack().popup_case1_settingOption3_ClassNotifications,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white
                ),
              ),
            )),
            Container(
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(90)),
                  color: Colors.white.withOpacity(.06)
              ),
              child: IconButton(
                onPressed: (){
                  _showSnackbar(AppStrings.getLanguagePack().popup_case1_settingOption3_ClassNotificationsDescription, 12);
                  AppHaptics.attentionLightImpact();
                },
                icon: Icon(
                  Icons.question_mark_rounded,
                  color: Colors.white.withOpacity(.4),
                ),
                enableFeedback: true,
                iconSize: 24,
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child: Switch(
                value: DataCache.getNeedClassNotifications()!,
                onChanged: (b){
                  DataCache.setNeedClassNotifications(b ? 1 : 0);
                  AppHaptics.lightImpact();
                  if(b){
                    HomePageState.setupClassesNotifications();
                  }
                  else{
                    HomePageState.cancelClassesNotifications();
                  }
                  if(mounted) {setState((){});}
                },
                activeColor: Colors.white,
                activeTrackColor: const Color.fromRGBO(0x4F, 0x69, 0x6E, 1.0),
                hoverColor: Colors.white.withOpacity(.1),
              ),
            )
          ],
        ));
        list.add(Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(flex: 2, child: Container(
              margin: const EdgeInsets.all(10),
              child: Text(
                AppStrings.getLanguagePack().popup_case1_settingOption4_PaymentNotifications,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white
                ),
              ),
            )),
            Container(
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(90)),
                  color: Colors.white.withOpacity(.06)
              ),
              child: IconButton(
                onPressed: (){
                  _showSnackbar(AppStrings.getLanguagePack().popup_case1_settingOption4_PaymentNotificationsDescription, 8);
                  AppHaptics.attentionLightImpact();
                },
                icon: Icon(
                  Icons.question_mark_rounded,
                  color: Colors.white.withOpacity(.4),
                ),
                enableFeedback: true,
                iconSize: 24,
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child: Switch(
                value: DataCache.getNeedPaymentsNotifications()!,
                onChanged: (b){
                  DataCache.setNeedPaymentsNotifications(b ? 1 : 0);
                  AppHaptics.lightImpact();
                  if(b){
                    HomePageState.setupPaymentsNotifications();
                  }
                  else{
                    HomePageState.cancelPaymentsNotifications();
                  }
                  if(mounted) {setState((){});}
                },
                activeColor: Colors.white,
                activeTrackColor: const Color.fromRGBO(0x4F, 0x69, 0x6E, 1.0),
                hoverColor: Colors.white.withOpacity(.1),
              ),
            )
          ],
        ));
        list.add(Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(flex: 2, child: Container(
              margin: const EdgeInsets.all(10),
              child: Text(
                AppStrings.getLanguagePack().popup_case1_settingOption5_PeriodsNotifications,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white
                ),
              ),
            )),
            Container(
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(90)),
                  color: Colors.white.withOpacity(.06)
              ),
              child: IconButton(
                onPressed: (){
                  _showSnackbar(AppStrings.getLanguagePack().popup_case1_settingOption5_PeriodsNotificationsDescription, 8);
                  AppHaptics.attentionLightImpact();
                },
                icon: Icon(
                  Icons.question_mark_rounded,
                  color: Colors.white.withOpacity(.4),
                ),
                enableFeedback: true,
                iconSize: 24,
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child: Switch(
                value: DataCache.getNeedPeriodsNotifications()!,
                onChanged: (b){
                  DataCache.setNeedPeriodsNotifications(b ? 1 : 0);
                  AppHaptics.lightImpact();
                  if(b){
                    HomePageState.setupPeriodsNotifications();
                  }
                  else{
                    HomePageState.cancelPeriodsNotifications();
                  }
                  if(mounted) {setState((){});}
                },
                activeColor: Colors.white,
                activeTrackColor: const Color.fromRGBO(0x4F, 0x69, 0x6E, 1.0),
                hoverColor: Colors.white.withOpacity(.1),
              ),
            )
          ],
        ));
        list.add(Container(
          height: 1,
          color: Colors.white.withOpacity(.1),
        ));
        list.add(Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(flex: 2, child: Container(
              margin: const EdgeInsets.all(10),
              child: Text(
                AppStrings.getLanguagePack().popup_case1_settingOption6_AppHaptics,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white
                ),
              ),
            )),
            Container(
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(90)),
                  color: Colors.white.withOpacity(.06)
              ),
              child: IconButton(
                onPressed: (){
                  _showSnackbar(AppStrings.getLanguagePack().popup_case1_settingOption6_AppHapticsDescription, 6);
                  AppHaptics.attentionLightImpact();
                },
                icon: Icon(
                  Icons.question_mark_rounded,
                  color: Colors.white.withOpacity(.4),
                ),
                enableFeedback: true,
                iconSize: 24,
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child: Switch(
                value: DataCache.getNeedsHaptics()!,
                onChanged: (b){
                  DataCache.setNeedsHaptics(b ? 1 : 0);
                  AppHaptics.lightImpact();
                  if(mounted) {setState((){});}
                },
                activeColor: Colors.white,
                activeTrackColor: const Color.fromRGBO(0x4F, 0x69, 0x6E, 1.0),
                hoverColor: Colors.white.withOpacity(.1),
              ),
            )
          ],
        ));
        /*list.add(Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(flex: 2, child: Container(
              margin: const EdgeInsets.all(10),
              child: const Text(
                'Appal kapcsolatos adatok küldése',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white
                ),
              ),
            )),
            Container(
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(90)),
                  color: Colors.white.withOpacity(.06)
              ),
              child: IconButton(
                onPressed: (){
                  _showSnackbar('Elküldi az esetleges API-val, és appal kapcsolatos problémákat / felhaszálói tevékenységeket nekem, így könnyebben ki tudom javítani a hibákat, és az app jobban fog működni neked, és másoknak is.\nCsak WIFI-n küldi, úgyhogy nem kell aggódni a mobilneted miatt.\nAz elküldött adatok névtelenek!', 24);
                },
                icon: Icon(
                  Icons.question_mark_rounded,
                  color: Colors.white.withOpacity(.4),
                ),
                enableFeedback: true,
                iconSize: 24,
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child: Switch(
                value: DataCache.getNeedPeriodsNotifications()!,
                onChanged: (b){
                  DataCache.setNeedPeriodsNotifications(b ? 1 : 0);
                  AppHaptics.lightImpact();
                  if(b){
                    HomePageState.setupPeriodsNotifications();
                  }
                  else{
                    HomePageState.cancelPeriodsNotifications();
                  }
                  if(mounted) {setState((){});}
                },
                activeColor: Colors.white,
                activeTrackColor: const Color.fromRGBO(0x4F, 0x69, 0x6E, 1.0),
                hoverColor: Colors.white.withOpacity(.1),
              ),
            )
          ],
        ));*/
        list.add(Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(flex: 2, child: Container(
              margin: const EdgeInsets.all(10),
              child: Text(
                AppStrings.getLanguagePack().popup_case1_settingOption8_LangaugeSelection,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white
                ),
              ),
            )),
            Container(
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(90)),
                  color: Colors.white.withOpacity(.06)
              ),
              child: IconButton(
                onPressed: (){
                  _showSnackbar(AppStrings.getLanguagePack().popup_case1_settingOption8_LangaugeSelectionDescription, 4);
                  AppHaptics.attentionLightImpact();
                },
                icon: Icon(
                  Icons.question_mark_rounded,
                  color: Colors.white.withOpacity(.4),
                ),
                enableFeedback: true,
                iconSize: 24,
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(10),
                child: DropdownButtonFormField<int>(
                    key: _languageDropdownGlobalKey,
                    borderRadius: BorderRadius.circular(12),
                    value: _languageCurrSelect, // The currently selected value.
                    icon: const SizedBox(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600
                    ),
                    enableFeedback: true,
                    onTap: AppHaptics.lightImpact,
                    focusColor: Colors.transparent,
                    dropdownColor: Color.fromRGBO(0x22, 0x22, 0x22, 1.0),
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(18),
                        suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
                        labelStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(.6),
                            fontWeight: FontWeight.w400
                        ),
                        border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide.none
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(.05)
                    ),
                    items: AppStrings.getLanguageNamesWithFlag().map<DropdownMenuItem<int>>((String value) {
                      return DropdownMenuItem<int>(
                          value: ++_languageDropdownMenuIndexer,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
                            child: EmojiRichText(
                              text: value,
                              defaultStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 14.0,
                              ),
                              emojiStyle: const TextStyle(
                                  color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
                                  fontSize: 18.0,
                                  fontFamily: "Noto Color Emoji"
                              ),
                            ),
                          )
                      );
                    }).toList(),
                    selectedItemBuilder: (context){
                      return AppStrings.getLanguageNamesWithFlag().map<Widget>((String value){
                        return Container(
                          constraints: BoxConstraints(maxWidth: _languageDropdownGlobalKey.currentContext?.findRenderObject() == null ? MediaQuery.of(context).size.width : ((_languageDropdownGlobalKey.currentContext!.findRenderObject() as RenderBox).size.width - 60) < 0 ? 0 : ((_languageDropdownGlobalKey.currentContext!.findRenderObject() as RenderBox).size.width - 60)),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: EmojiRichText(
                              text: value,
                              defaultStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 16.0,
                              ),
                              emojiStyle: const TextStyle(
                                  color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
                                  fontSize: 20.0,
                                  fontFamily: "Noto Color Emoji"
                              ),
                            ),
                          ),
                        );
                      }).toList();
                    },
                    onChanged: (int? value) {
                      AppHaptics.lightImpact();
                      if(value == null){
                        return;
                      }
                      DataCache.setUserSelectedLanguage(value);
                      final langPackId = Language.getAllLanguagesWithNative()[value].langId;
                      if(!AppStrings.hasLanguageDownloaded(langPackId)){
                        Future.delayed(Duration.zero, ()async{
                          if(!DataCache.getHasNetwork()){
                            if(Platform.isAndroid){
                              Fluttertoast.showToast(
                                msg: AppStrings.getLanguagePack().popup_case1_langSwap_DownloadingLangFail, // dont have the new lang, can speak with it
                                toastLength: Toast.LENGTH_SHORT,
                                fontSize: 14,
                                gravity: ToastGravity.SNACKBAR,
                                backgroundColor: const Color.fromRGBO(0x1A, 0x1A, 0x1A, 1.0),
                                textColor: Colors.white,
                              );
                            }
                            return;
                          }
                          final pack = await Language.getAllLanguages();
                          await Language.getLanguagePackById(pack, langPackId).then((value)async{
                            AppStrings.setupPopupPreviews(value!);
                            if(Platform.isAndroid){
                              Fluttertoast.showToast(
                                msg: AppStrings.popupLangPrev_ObtainingLang,
                                toastLength: Toast.LENGTH_SHORT,
                                fontSize: 14,
                                gravity: ToastGravity.SNACKBAR,
                                backgroundColor: const Color.fromRGBO(0x1A, 0x1A, 0x1A, 1.0),
                                textColor: Colors.white,
                              );
                            }
                            AppStrings.saveDownloadedLanguageData();
                            Navigator.popUntil(context, (route) => route.willHandlePopInternally);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const Splitter()),
                            );
                          });
                          return;
                        });
                      }
                      setState(() {
                        _languageCurrSelect = value;
                        PopupWidgetHandler._instance!._settingsLanguageCurrent = value;
                      });
                    }
                ),
              ),
            ),
            /*GestureDetector(
              key: _settingsLanguageWidgetGlobalKey,
              onTap: (){
                if(!mounted){
                  return;
                }
                AppHaptics.lightImpact();
                showMenu(
                  context: context,
                  position: RelativeRect.fromLTRB(
                    (_settingsLanguageWidgetGlobalKey.currentContext!.findRenderObject() as RenderBox).localToGlobal(Offset.zero).dx + 13,
                    (_settingsLanguageWidgetGlobalKey.currentContext!.findRenderObject() as RenderBox).localToGlobal(Offset.zero).dy + (_settingsLanguageWidgetGlobalKey.currentContext!.findRenderObject() as RenderBox).size.height,
                    (_settingsLanguageWidgetGlobalKey.currentContext!.findRenderObject() as RenderBox).localToGlobal(Offset.zero).dx + (_settingsLanguageWidgetGlobalKey.currentContext!.findRenderObject() as RenderBox).size.width,
                    (_settingsLanguageWidgetGlobalKey.currentContext!.findRenderObject() as RenderBox).localToGlobal(Offset.zero).dy,
                  ),
                  items: AppStrings.getAllLangFlags().map<PopupMenuEntry<int>>((String value){
                    return PopupMenuItem(
                      value: ++_settingsLanguageItemsIdx,
                      child: EmojiRichText(
                        text: value,
                        defaultStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 18.0,
                        ),
                        emojiStyle: const TextStyle(
                            color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
                            fontSize: 22.0,
                            fontFamily: "Noto Color Emoji"
                        ),
                      ),
                    );
                  }).toList(),
                  color: Color.fromRGBO(0x2F, 0x2F, 0x2F, 1.0)
                ).then((val){
                  _settingsLanguageItemsIdx = -1;
                  if(val == null){
                    return;
                  }
                  AppHaptics.lightImpact();
                  DataCache.setUserSelectedLanguage(val);

                  setState(() {
                    PopupWidgetHandler._instance!._settingsLanguageCurrent = val;
                  });
                });
              },
              child: Container(
                width: 120,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.05),
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: EmojiRichText(
                        text: AppStrings.getLanguagePack().language_flag,
                        defaultStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 18.0,
                        ),
                        emojiStyle: const TextStyle(
                          color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
                          fontSize: 22.0,
                          fontFamily: "Noto Color Emoji"
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down_rounded,
                      color: Colors.white.withOpacity(.5),
                    )
                  ],
                )
              ),
            )*/
          ],
        ));
        list.add(Container(
          height: 1,
          color: Colors.white.withOpacity(.1),
        ));
        list.add(const SizedBox(height: 6));
        list.add(
          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 4, child: Container(
                    margin: const EdgeInsets.all(10),
                    child: Text(
                      AppStrings.getLanguagePack().popup_case1_settingOption7_WeekOffset,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white
                      ),
                    ),
                  )),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(90)),
                        color: Colors.white.withOpacity(.06)
                    ),
                    child: IconButton(
                      onPressed: (){
                        _showSnackbar(AppStrings.getLanguagePack().popup_case1_settingOption7_WeekOffsetDescription, 6);
                        AppHaptics.attentionLightImpact();
                      },
                      icon: Icon(
                        Icons.question_mark_rounded,
                        color: Colors.white.withOpacity(.4),
                      ),
                      enableFeedback: true,
                      iconSize: 24,
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(right: 16)),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.05),
                      borderRadius: BorderRadius.all(Radius.circular(14))
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 65,
                          child: TextField(
                            controller: HomePageState.getUserWeekOffsetTextController(),
                            scrollPhysics: const AlwaysScrollableScrollPhysics(),
                            keyboardType: TextInputType.numberWithOptions(decimal: false, signed: true),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600
                            ),
                            maxLines: 1,
                            decoration: InputDecoration(
                              isCollapsed: true,
                              isDense: true,
                              hintText: AppStrings.getLanguagePack().popup_case1_settingOption7_WeekOffsetAuto,
                              hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(.4),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12))
                              ),
                              contentPadding: const EdgeInsets.all(6),
                              filled: false,
                            )
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 26,
                              height: 26,
                              child: GestureDetector(
                                onLongPressStart: (_){
                                  HomePageState.settingsUserWeekOffsetPeriodicLooper = Timer.periodic(Duration(milliseconds: 100), (timer) {
                                    AppHaptics.lightImpact();
                                    HomePageState.settingsUserWeekOffsetAdd(1);
                                  });
                                },
                                onLongPressEnd: (_){
                                  HomePageState.settingsUserWeekOffsetPeriodicLooper!.cancel();
                                  HomePageState.settingsUserWeekOffsetPeriodicLooper = null;
                                },
                                child: IconButton(
                                  onPressed: () {
                                    AppHaptics.lightImpact();
                                    HomePageState.settingsUserWeekOffsetAdd(1);
                                  },
                                  icon: Icon(
                                    Icons.arrow_drop_up_rounded,
                                    color: Colors.white.withOpacity(.5),
                                    size: 16,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 26,
                              height: 26,
                              child: GestureDetector(
                                onLongPressStart: (_){
                                  HomePageState.settingsUserWeekOffsetPeriodicLooper = Timer.periodic(Duration(milliseconds: 100), (timer) {
                                    AppHaptics.lightImpact();
                                    HomePageState.settingsUserWeekOffsetAdd(-1);
                                  });
                                },
                                onLongPressEnd: (_){
                                  HomePageState.settingsUserWeekOffsetPeriodicLooper!.cancel();
                                  HomePageState.settingsUserWeekOffsetPeriodicLooper = null;
                                },
                                child: IconButton(
                                  onPressed: () {
                                    AppHaptics.lightImpact();
                                    HomePageState.settingsUserWeekOffsetAdd(-1);
                                  },
                                  icon: Icon(
                                    Icons.arrow_drop_down_rounded,
                                    color: Colors.white.withOpacity(.5),
                                    size: 16,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          )
        );
        list.add(const SizedBox(height: 6));
        final pinfo = widget.pinfo ?? PackageInfo(appName: 'neptun2', packageName: 'com.domedav.neptun2', version: '1.1.2', buildNumber: '7', buildSignature: '');
        list.add(Container(
          alignment: Alignment.bottomLeft,
          margin: const EdgeInsets.all(10),
          child: Text(
            AppStrings.getStringWithParams(AppStrings.getLanguagePack().popup_case1_settingBottomText_InstallOrigin, ['v${pinfo.version} (${pinfo.buildNumber})']) + (DataCache.getIsInstalledFromGPlay()! != 0 ? AppStrings.getLanguagePack().popup_case1_settingBottomText_InstallOriginGPlay : AppStrings.getLanguagePack().popup_case1_settingBottomText_InstallOrigin3rdParty),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 9,
              color: Colors.white.withOpacity(.3)
            ),
          ),
        ));
        list.add(const SizedBox(height: 20));
        list.add(TextButton(
          onPressed: (){
            if(!PopupWidgetHandler._instance!._inUse || !mounted){
              return;
            }
            PopupWidgetHandler._instance!.callback(null);
            PopupWidgetHandler.closePopup(context);
            AppHaptics.lightImpact();
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(const Color.fromRGBO(0xFF, 0xFF, 0xFF, 0.05)),
            overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(.05)),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 15),
            child: Text(AppStrings.getLanguagePack().popup_caseAll_OkButton,
              style: const TextStyle(
                color: Color.fromRGBO(0x6D, 0xC2, 0xD3, 1.0),
                fontWeight: FontWeight.w900,
                fontSize: 18.0,
              ),
            ),
          ),
        ));
        /*list.add(TextButton(
          onPressed: (){
            if(!PopupWidgetHandler._instance!._inUse || !mounted){
              return;
            }
            AppHaptics.lightImpact();
            DataCache.dataWipeNoKeep();
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(const Color.fromRGBO(0xFF, 0xFF, 0xFF, 0.05)),
            overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(.05)),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 15),
            child: Text('dev_WipeAll',
              style: const TextStyle(
                color: Color.fromRGBO(0x6D, 0xC2, 0xD3, 1.0),
                fontWeight: FontWeight.w900,
                fontSize: 18.0,
              ),
            ),
          ),
        ));*/
        return list;

      case 2:
        list.add(EmojiRichText(
          text: AppStrings.getLanguagePack().popup_case2_RateAppPopup,
          defaultStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 22.0,
          ),
          emojiStyle: const TextStyle(
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
        list.add(Text(
          AppStrings.getLanguagePack().popup_case2_RateAppPopupDescription,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w400
          ),
        ));
        list.add(const SizedBox(height: 20));
        list.add(TextButton(
          onPressed: (){
            if(!PopupWidgetHandler._instance!._inUse || !mounted){
              return;
            }
            PopupWidgetHandler._instance!.callback(null);
            PopupWidgetHandler.closePopup(context);
            AppHaptics.lightImpact();
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(const Color.fromRGBO(0xFF, 0xFF, 0xFF, 0.05)),
            overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(.05)),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 15),
            child: Text(AppStrings.getLanguagePack().popup_case2_RateButton,
              style: const TextStyle(
                color: Color.fromRGBO(0x6D, 0xC2, 0xD3, 1.0),
                fontWeight: FontWeight.w900,
                fontSize: 18.0,
              ),
            ),
          ),
        ));
        return list;
      case 3:
        list.add(EmojiRichText(
          text: AppStrings.getLanguagePack().popup_case3_MessagesHeader,
          defaultStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 22.0,
          ),
          emojiStyle: const TextStyle(
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

        list.add(SelectableText.rich(
          TextSpan(
            text: MailPopupDisplayTexts.title,
            style: const TextStyle(
              color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
              fontWeight: FontWeight.w600,
              fontSize: 20
            ),
          ),
          textAlign: TextAlign.start,
        ));
        list.add(const SizedBox(height: 20));
        list.add(SelectableText.rich(
          TextSpan(
            text: '',
            children: MailPopupDisplayTexts.description,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 14
            ),
          ),
          textAlign: TextAlign.start,
        ));

        list.add(const SizedBox(height: 20));
        list.add(TextButton(
          onPressed: (){
            if(!PopupWidgetHandler._instance!._inUse || !mounted){
              return;
            }
            PopupWidgetHandler._instance!.callback(null);
            PopupWidgetHandler.closePopup(context);
            AppHaptics.lightImpact();
            Future.delayed(Duration.zero, ()async{
              await MailRequest.setMailRead(MailPopupDisplayTexts.mailID);
            });
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(const Color.fromRGBO(0xFF, 0xFF, 0xFF, 0.05)),
            overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(.05)),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 15),
            child: Text(AppStrings.getLanguagePack().popup_caseAll_OkButton,
              style: const TextStyle(
                color: Color.fromRGBO(0x6D, 0xC2, 0xD3, 1.0),
                fontWeight: FontWeight.w900,
                fontSize: 18.0,
              ),
            ),
          ),
        ));
        return list;
      case 4:
        list.add(EmojiRichText(
          text: AppStrings.getLanguagePack().popup_case4_SubjectInfo,
          defaultStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 22.0,
          ),
          emojiStyle: const TextStyle(
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
        final entry = TimetableCurrentlySelected.entry;
        list.add(SelectableText.rich(
            TextSpan(
              text: entry!.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 20
              ),
            )
        ));
        list.add(const SizedBox(height: 20));
        list.add(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                AppStrings.getLanguagePack().popup_case4_TeachedBy,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
            Flexible(
              child: SelectableText.rich(
                TextSpan(
                  text: entry.teacher,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 14
                  ),
                ),
              )
            )
          ],
        ));
        list.add(const SizedBox(height: 4));
        list.add(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                AppStrings.getLanguagePack().popup_case4_5_SubjectCode,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
            Flexible(
              child: SelectableText.rich(
                TextSpan(
                  text: entry.subjectCode,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 14
                  ),
                ),
              )
            )
          ],
        ));
        list.add(const SizedBox(height: 4));
        list.add(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                AppStrings.getLanguagePack().popup_case4_5_SubjectLocation,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
            Flexible(
              child: SelectableText.rich(
                TextSpan(
                  text: entry.location,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 14
                  ),
                ),
              )
            )
          ],
        ));
        final timeStart = DateTime.fromMillisecondsSinceEpoch(entry.startEpoch);
        list.add(const SizedBox(height: 4));
        list.add(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                AppStrings.getLanguagePack().popup_case4_SubjectStartTime,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
            Flexible(
              child: SelectableText.rich(
                  TextSpan(
                    text: '${timeStart.hour.toString().padLeft(2, '0')}:${timeStart.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 14
                    ),
                  ),
                )
            )
          ],
        ));
        list.add(const SizedBox(height: 20));
        list.add(TextButton(
          onPressed: (){
            if(!PopupWidgetHandler._instance!._inUse || !mounted){
              return;
            }
            PopupWidgetHandler._instance!.callback(null);
            PopupWidgetHandler.closePopup(context);
            AppHaptics.lightImpact();
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(const Color.fromRGBO(0xFF, 0xFF, 0xFF, 0.05)),
            overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(.05)),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 15),
            child: Text(AppStrings.getLanguagePack().popup_caseAll_OkButton,
              style: const TextStyle(
                color: Color.fromRGBO(0x6D, 0xC2, 0xD3, 1.0),
                fontWeight: FontWeight.w900,
                fontSize: 18.0,
              ),
            ),
          ),
        ));
        return list;
      case 5:
        list.add(EmojiRichText(
          text: AppStrings.getLanguagePack().popup_case5_ExamInfo,
          defaultStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 22.0,
          ),
          emojiStyle: const TextStyle(
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
        final entry = TimetableCurrentlySelected.entry;
        list.add(SelectableText.rich(
            TextSpan(
              text: entry!.title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 20
              ),
            )
        ));
        list.add(const SizedBox(height: 20));
        list.add(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                AppStrings.getLanguagePack().popup_case4_TeachedBy,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
            Flexible(
                child: SelectableText.rich(
                  TextSpan(
                    text: entry.subjectCode,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 14
                    ),
                  ),
                )
            )
          ],
        ));
        list.add(const SizedBox(height: 4));
        list.add(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                AppStrings.getLanguagePack().popup_case4_5_SubjectLocation,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
            Flexible(
                child: SelectableText.rich(
                  TextSpan(
                    text: entry.location,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 14
                    ),
                  ),
                )
            )
          ],
        ));
        final timeStart = DateTime.fromMillisecondsSinceEpoch(entry.startEpoch);
        list.add(const SizedBox(height: 4));
        list.add(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                AppStrings.getLanguagePack().popup_case5_ExamStartTime,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
            Flexible(
                child: SelectableText.rich(
                  TextSpan(
                    text: '${timeStart.hour.toString().padLeft(2, '0')}:${timeStart.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 14
                    ),
                  ),
                )
            )
          ],
        ));
        list.add(const SizedBox(height: 20));
        list.add(TextButton(
          onPressed: (){
            if(!PopupWidgetHandler._instance!._inUse || !mounted){
              return;
            }
            PopupWidgetHandler._instance!.callback(null);
            PopupWidgetHandler.closePopup(context);
            AppHaptics.lightImpact();
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(const Color.fromRGBO(0xFF, 0xFF, 0xFF, 0.05)),
            overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(.05)),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 15),
            child: Text(AppStrings.getLanguagePack().popup_caseAll_OkButton,
              style: const TextStyle(
                color: Color.fromRGBO(0x6D, 0xC2, 0xD3, 1.0),
                fontWeight: FontWeight.w900,
                fontSize: 18.0,
              ),
            ),
          ),
        ));
        return list;
      case 6:
        list.add(EmojiRichText(
          text: AppStrings.getLanguagePack().popup_case6_AccountError,
          defaultStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 22.0,
          ),
          emojiStyle: const TextStyle(
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
        list.add(Text(
          AppStrings.getLanguagePack().popup_case6_AccountErrorDescription,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400
          ),
        ));
        list.add(const SizedBox(height: 20));
        list.add(TextButton(
          onPressed: (){
            if(!PopupWidgetHandler._instance!._inUse || !mounted){
              return;
            }
            PopupWidgetHandler._instance!.callback(null);
            PopupWidgetHandler.closePopup(context);
            AppHaptics.lightImpact();
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(const Color.fromRGBO(0xFF, 0xFF, 0xFF, 0.05)),
            overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(.05)),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 15),
            child: Text(AppStrings.getLanguagePack().popup_case6_AccountErrorLogoutButton,
              style: const TextStyle(
                color: Color.fromRGBO(0x6D, 0xC2, 0xD3, 1.0),
                fontWeight: FontWeight.w900,
                fontSize: 18.0,
              ),
            ),
          ),
        ));
        return list;
      case 7:
        list.add(EmojiRichText(
          text: AppStrings.getLanguagePack().popup_case7_ObsolteAppVersion,
          defaultStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 22.0,
          ),
          emojiStyle: const TextStyle(
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
        list.add(EmojiRichText(
          text: AppStrings.getLanguagePack().popup_case7_ObsolteAppVersionDescription,
          defaultStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 14.0,
          ),
          emojiStyle: const TextStyle(
              color: Colors.white,
              fontSize: 14.0,
              fontFamily: "Noto Color Emoji"
          ),
        ));
        list.add(const SizedBox(height: 20));
        list.add(TextButton(
          onPressed: (){
            if(!PopupWidgetHandler._instance!._inUse || !mounted){
              return;
            }
            PopupWidgetHandler._instance!.callback(null);
            PopupWidgetHandler.closePopup(context);
            AppHaptics.lightImpact();
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(const Color.fromRGBO(0xFF, 0xFF, 0xFF, 0.05)),
            overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(.05)),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 15),
            child: Text(AppStrings.getLanguagePack().popup_case7_ButtonUpdateNow,
              style: const TextStyle(
                color: Color.fromRGBO(0x6D, 0xC2, 0xD3, 1.0),
                fontWeight: FontWeight.w900,
                fontSize: 18.0,
              ),
            ),
          ),
        ));
        return list;
      case 8:
        list.add(EmojiRichText(
          text: AppStrings.popupLangPrev_Header,
          defaultStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 22.0,
          ),
          emojiStyle: const TextStyle(
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
        list.add(EmojiRichText(
          text: AppStrings.popupLangPrev_Description,
          defaultStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 14.0,
          ),
          emojiStyle: const TextStyle(
              color: Colors.white,
              fontSize: 14.0,
              fontFamily: "Noto Color Emoji"
          ),
        ));
        list.add(const SizedBox(height: 20));
        list.add(TextButton(
          onPressed: (){
            if(!PopupWidgetHandler._instance!._inUse || !mounted){
              return;
            }
            PopupWidgetHandler._instance!.callback(null);
            PopupWidgetHandler.closePopup(context);
            AppHaptics.lightImpact();
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(const Color.fromRGBO(0xFF, 0xFF, 0xFF, 0.05)),
            overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(.05)),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 15),
            child: Text(AppStrings.popupLangPrev_Button,
              style: const TextStyle(
                color: Color.fromRGBO(0x6D, 0xC2, 0xD3, 1.0),
                fontWeight: FontWeight.w900,
                fontSize: 18.0,
              ),
            ),
          ),
        ));
        return list;
      default:
        list.add(EmojiRichText(
          text: AppStrings.getLanguagePack().popup_caseDefault_InvalidPopupState,
          defaultStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 22.0,
          ),
          emojiStyle: const TextStyle(
              color: Colors.white,
              fontSize: 19.0,
              fontFamily: "Noto Color Emoji"
          ),
        ));
        list.add(const SizedBox(height: 20));
        list.add(TextButton(
          onPressed: (){
            if(!PopupWidgetHandler._instance!._inUse || !mounted){
              return;
            }
            PopupWidgetHandler._instance!.callback(null);
            PopupWidgetHandler.closePopup(context);
            AppHaptics.lightImpact();
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(const Color.fromRGBO(0xFF, 0xFF, 0xFF, 0.05)),
            overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(.05)),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 15),
            child: Text(AppStrings.getLanguagePack().popup_caseAll_OkButton,
              style: const TextStyle(
                color: Color.fromRGBO(0x6D, 0xC2, 0xD3, 1.0),
                fontWeight: FontWeight.w900,
                fontSize: 18.0,
              ),
            ),
          ),
        ));
        return list;
    }
  }

  String _snackbarMessage = "";
  Duration _displayDuration = Duration.zero;
  bool _shouldShowSnackbar = false;
  //double _snackbarDelta = 0;

  void _showSnackbar(String text, int displayDurationSec){
    if(!mounted){
      return;
    }
    setState(() {
      _shouldShowSnackbar = true;
      _displayDuration = Duration(seconds: displayDurationSec);
      _snackbarMessage = text;
      //_snackbarDelta = 0;
    });
  }


  Widget getPopup(BuildContext context){
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onTap: (){
          PopupWidgetHandler.closePopup(context);
        },
        behavior: HitTestBehavior.deferToChild,
        child: PopScope(
          canPop: false,
          onPopInvoked: (_) {
            PopupWidgetHandler.closePopup(context);
          },
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                alignment: Alignment.center,
                color: Colors.transparent,
                padding: widget.topPadding,
                margin: EdgeInsets.only(bottom: mounted ? MediaQuery.of(context).viewInsets.bottom : 0),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: PopupWidgetHandler._instance!.scrollController,
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
              Visibility(
                visible: _shouldShowSnackbar,
                child: AppSnackbar(text: _snackbarMessage, displayDuration: _displayDuration, /*dragAmmount: _snackbarDelta,*/ changer: (){
                  if(!mounted){
                    return;
                  }
                  AppSnackbar.cancelTimer();
                  setState(() {
                    _shouldShowSnackbar = false;
                  });
                }, state: _shouldShowSnackbar,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: popupController,
      builder: (context, _) {
        return Transform.scale(
          scale: poppuAnimation.value,
          child: getPopup(context)
        );
      }
    );
  }
}