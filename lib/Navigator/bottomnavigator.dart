import 'dart:developer';
import 'package:flutter/material.dart';
import '../Pages/main_page.dart';

class BottomNavigatorWidget extends StatelessWidget {
  final HomePageState homePage;
  const BottomNavigatorWidget({super.key, required this.homePage});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: const Color.fromRGBO(0x22, 0x22, 0x22, 1.0),
      child: Center(
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
            controller: homePage.bottomnavController,
            physics: const BouncingScrollPhysics(decelerationRate: ScrollDecelerationRate.fast),
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildNavigationButton(0, Icons.calendar_month_rounded, Icons.calendar_month_outlined),
                _buildNavigationButton(1, Icons.backpack_rounded, Icons.backpack_outlined),
                _buildNavigationButton(2, Icons.price_change_rounded, Icons.price_change_outlined),
                _buildNavigationButton(3, Icons.timer_rounded, Icons.timer_outlined),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getNameOfMenu(int idx){
    switch(idx){
      case 0:
        return 'Órarend';
      case 1:
        return 'Tantárgyak';
      case 2:
        return 'Befizetendők';
      case 3:
        return 'Időszakok';
      default:
        return 'Not Impl';
    }
  }

  Widget _buildNavigationButton(int index, IconData filledIcon, IconData outlinedIcon) {
    return GestureDetector(
      onTap: (){
        homePage.switchView(index);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        decoration: BoxDecoration(
          color: homePage.currentView == index
              ? const Color.fromRGBO(0xFF, 0xFF, 0xFF, 0.15)
              : const Color.fromRGBO(0xFF, 0xFF, 0xFF, 0.05),
          borderRadius: const BorderRadius.all(Radius.circular(20))
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            /*IconButton(
              onPressed: () {
                homePage.switchView(index);
              },
              style: ButtonStyle(
                backgroundColor: homePage.currentView == index
                    ? MaterialStateProperty.all(const Color.fromRGBO(0xFF, 0xFF, 0xFF, 0.15))
                    : MaterialStateProperty.all(const Color.fromRGBO(0xFF, 0xFF, 0xFF, 0.05)),
                padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 8)),
              ),
              icon: Icon(
                homePage.currentView == index ? filledIcon : outlinedIcon,
                color: homePage.currentView == index ? const Color.fromRGBO(0x6D, 0xC2, 0xD3, 1.0) : const Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
                size: homePage.currentView == index ? 32 : 28,
              ),
            ),*/
            Icon(
              homePage.currentView == index ? filledIcon : outlinedIcon,
              color: homePage.currentView == index ? const Color.fromRGBO(0x6D, 0xC2, 0xD3, 1.0) : const Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
              size: 28,
            ),
            Text(
              _getNameOfMenu(index),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(homePage.currentView == index ? .6 : .4),
                fontWeight: FontWeight.w300,
                fontSize: 8.0
              ),
            ),
          ],
        ),
      ),
    );
  }
}
