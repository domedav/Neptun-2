import 'package:flutter/material.dart';
import '../Pages/main_page.dart';
import '../storage.dart' as storage;
import '../Pages/startup_page.dart' as root_page;
import '../Misc/emojirich_text.dart';

class TopNavigatorWidget extends StatelessWidget{
  final HomePageState homePage;
  final String displayString;
  final String smallHintText;
  const TopNavigatorWidget({super.key, required this.homePage, required this.displayString, required this.smallHintText});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(0x22, 0x22, 0x22, 1.0),
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
            return;
          }
          else if(homePage.bottomNavSwitchValue > 50){
            homePage.bottomNavCanNavigate = false;
            final val = homePage.currentView - 1 < 0 ? HomePageState.maxBottomNavWidgets - 1 : homePage.currentView - 1;
            homePage.switchView(val);
            return;
          }
          homePage.bottomNavSwitchValue += e.delta.dx;
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
                  margin: const EdgeInsets.fromLTRB(10, 0, 30, 6),
                  child: IconButton(
                    onPressed: (){
                      homePage.setBlurComplex(true);
                      showMenu(
                        context: context,
                        position: RelativeRect.fromDirectional(textDirection: TextDirection.ltr, start: 25, top: 30 + MediaQuery.of(context).padding.top, end: 100, bottom: 100),
                        items: <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'logout',
                            child: Text('Kijelentkezés'),
                          ),
                        ],
                      ).then((selectedValue) {
                        homePage.setBlurComplex(false);
                        if(selectedValue == 'logout'){
                          storage.DataCache.dataWipe();
                          Navigator.popUntil(context, (route) => route.willHandlePopInternally);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const root_page.Splitter()),
                          );
                        }
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(const Color.fromRGBO(0xFF, 0xFF, 0xFF, 0.05)),
                      padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
                    ),
                    icon: const Icon(
                      Icons.person_outline_rounded,
                      color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
                      size: 28,
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 22.0
                            ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(10, 0, 10, 6),
                        child: EmojiRichText(
                            text: smallHintText,
                            defaultStyle: const TextStyle(
                                fontSize: 12.0
                            ),
                            emojiStyle: const TextStyle(
                              fontSize: 13.5,
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