import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:neptun2/Misc/popup.dart';
import 'package:neptun2/language.dart';
import 'package:neptun2/notifications.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Pages/main_page.dart';
import '../colors.dart';
import '../haptics.dart';
import '../storage.dart' as storage;
import '../Pages/startup_page.dart' as root_page;
import '../Misc/emojirich_text.dart';

class TopNavigatorWidget extends StatelessWidget{
  final HomePageState homePage;
  final String displayString;
  final String smallHintText;

  final String loggedInUsername;
  final String loggedInURL;
  const TopNavigatorWidget({super.key, required this.homePage, required this.displayString, required this.smallHintText, required this.loggedInUsername, required this.loggedInURL});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.getTheme().rootBackground,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10),
      child: GestureDetector(
        onHorizontalDragStart: (_){
          homePage.bottomNavCanNavigate = true;
          homePage.bottomNavSwitchValue = 0.0;
        },
        onHorizontalDragEnd: (_){
          homePage.bottomNavCanNavigate = false;
          homePage.bottomNavSwitchValue = 0.0;
        },
        onHorizontalDragUpdate: (e){
          if(!homePage.bottomNavCanNavigate){
            return;
          }
          if(homePage.bottomNavSwitchValue < -50){
            homePage.bottomNavCanNavigate = false;
            final val = homePage.currentView + 1 > HomePageState.maxBottomNavWidgets - 1 ? 0 : homePage.currentView + 1;
            homePage.switchView(val);
            AppHaptics.lightImpact();
            return;
          }
          else if(homePage.bottomNavSwitchValue > 50){
            homePage.bottomNavCanNavigate = false;
            final val = homePage.currentView - 1 < 0 ? HomePageState.maxBottomNavWidgets - 1 : homePage.currentView - 1;
            homePage.switchView(val);
            AppHaptics.lightImpact();
            return;
          }
          homePage.bottomNavSwitchValue -= e.delta.dx;
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
              decelerationRate: ScrollDecelerationRate.fast
          ),
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.fromLTRB(10, 0, 18, 6),
                  child: IconButton(
                    onPressed: (){
                      homePage.setBlurComplex(true);
                      AppHaptics.lightImpact();
                      showMenu(
                        context: context,
                        position: RelativeRect.fromDirectional(textDirection: TextDirection.ltr, start: 25, top: 30 + MediaQuery.of(context).padding.top, end: 100, bottom: 100),
                        items: <PopupMenuEntry<String>>[
                          PopupMenuItem(
                            value: 'null',
                            enabled: false,
                            child: EmojiRichText(
                              text: AppStrings.getStringWithParams(AppStrings.getLanguagePack().topmenu_Greet, [loggedInUsername]),
                              defaultStyle: TextStyle(
                                color: AppColors.getTheme().onPrimaryContainer,
                                fontWeight: FontWeight.w700,
                                fontSize: 18.0,
                              ),
                              emojiStyle: TextStyle(
                                color: AppColors.getTheme().onPrimaryContainer,
                                fontSize: 23.0,
                                fontFamily: "Noto Color Emoji"
                              ),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'null',
                            enabled: false,
                            child: EmojiRichText(
                              text: AppStrings.getStringWithParams(AppStrings.getLanguagePack().topmenu_LoginPlace, [loggedInURL]),
                              defaultStyle: TextStyle(
                                color: AppColors.getTheme().onPrimaryContainer,
                                fontWeight: FontWeight.w700,
                                fontSize: 16.0,
                              ),
                              emojiStyle: TextStyle(
                                color: AppColors.getTheme().onPrimaryContainer,
                                fontSize: 16.0,
                                fontFamily: "Noto Color Emoji"
                              ),
                            ),
                          ),
                          const PopupMenuDivider(height: 20),
                          PopupMenuItem(
                            value: 'settings',
                            child: EmojiRichText(
                              text: AppStrings.getLanguagePack().topmenu_buttons_Settings,
                              defaultStyle: TextStyle(
                                color: AppColors.getTheme().textColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 14.0,
                              ),
                              emojiStyle: TextStyle(
                                  color: AppColors.getTheme().textColor,
                                  fontSize: 20.0,
                                  fontFamily: "Noto Color Emoji"
                              ),
                            ),
                          ),
                          const PopupMenuDivider(height: 20),
                          PopupMenuItem(
                            value: 'donate',
                            child: EmojiRichText(
                              text: AppStrings.getLanguagePack().topmenu_buttons_SupportDev,
                              defaultStyle: TextStyle(
                                color: AppColors.getTheme().textColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 14.0,
                              ),
                              emojiStyle: TextStyle(
                                  color: AppColors.getTheme().textColor,
                                  fontSize: 20.0,
                                  fontFamily: "Noto Color Emoji"
                              ),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'bugreport',
                            child: EmojiRichText(
                              text: AppStrings.getLanguagePack().topmenu_buttons_Bugreport,
                              defaultStyle: TextStyle(
                                color: AppColors.getTheme().textColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 14.0,
                              ),
                              emojiStyle: TextStyle(
                                  color: AppColors.getTheme().textColor,
                                  fontSize: 20.0,
                                  fontFamily: "Noto Color Emoji"
                              ),
                            ),
                          ),
                          const PopupMenuDivider(height: 20),
                          PopupMenuItem<String>(
                            value: 'logout',
                            child: EmojiRichText(
                              text:  AppStrings.getLanguagePack().topmenu_buttons_Logout,
                              defaultStyle: TextStyle(
                                color: AppColors.getTheme().textColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 14.0,
                              ),
                              emojiStyle: TextStyle(
                                  color: AppColors.getTheme().textColor,
                                  fontSize: 20.0,
                                  fontFamily: "Noto Color Emoji"
                              ),
                            ),
                          ),
                        ],
                      ).then((selectedValue) {
                        homePage.setBlurComplex(false);
                        if(selectedValue == 'logout'){
                          AppHaptics.lightImpact();
                          Future.delayed(Duration.zero, ()async{
                            await storage.DataCache.dataWipe();
                            await AppNotifications.cancelScheduledNotifs();
                          }).whenComplete((){
                            Navigator.popUntil(context, (route) => route.willHandlePopInternally);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const root_page.Splitter()),
                            );
                          });
                          if(!Platform.isAndroid){
                            return;
                          }
                          Fluttertoast.showToast(
                            msg: AppStrings.getLanguagePack().topmenu_buttons_LogoutSuccessToast,
                            toastLength: Toast.LENGTH_SHORT,
                            fontSize: 14,
                            gravity: ToastGravity.SNACKBAR,
                            backgroundColor: AppColors.getTheme().rootBackground,
                            textColor: AppColors.getTheme().textColor,
                          );
                        }
                        else if(selectedValue == 'donate'){
                          AppHaptics.lightImpact();
                          if(!Platform.isAndroid){
                            return;
                          }
                          final url = Uri.parse('https://www.buymeacoffee.com/domedav');
                          launchUrl(url).whenComplete(() {
                            Fluttertoast.showToast(
                              msg: '❤️',
                              toastLength: Toast.LENGTH_SHORT,
                              fontSize: 14,
                              gravity: ToastGravity.SNACKBAR,
                              backgroundColor: AppColors.getTheme().rootBackground,
                              textColor: AppColors.getTheme().textColor,
                            );
                          });
                        }
                        else if(selectedValue == 'settings'){
                          AppHaptics.lightImpact();
                          PopupWidgetHandler(mode: 1, callback: (res){
                            //log('PopupComplete');
                          }, onCloseCallback: (){
                            HomePageState.settingsUserWeekOffsetChangeDetect();
                          });
                          PopupWidgetHandler.doPopup(context);
                        }
                        else if(selectedValue == 'bugreport'){
                          AppHaptics.lightImpact();
                          if(!Platform.isAndroid){
                            return;
                          }
                          final url = Uri.parse('https://github.com/domedav/Neptun-2/issues/new/choose');
                          launchUrl(url);
                        }
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(AppColors.getTheme().textColor.withOpacity(.1)),
                      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                    ),
                    icon: Icon(
                      Icons.menu_rounded,
                      color: AppColors.getTheme().onPrimaryContainer,
                      size: 24,
                    ),
                  ),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(10, 0, 10, 1),
                        child: Text(
                            displayString,
                            style: TextStyle(
                              color: AppColors.getTheme().onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                              fontSize: 22.0
                            ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(10, 0, 10, 6),
                        child: EmojiRichText(
                          text: smallHintText,
                          defaultStyle: TextStyle(
                            fontSize: 12.0,
                            color: AppColors.getTheme().textColor,
                          ),
                          emojiStyle: TextStyle(
                            fontSize: 13.5,
                            color: AppColors.getTheme().textColor,
                            fontFamily: "Noto Color Emoji"
                          )
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}