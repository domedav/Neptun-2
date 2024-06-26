import 'package:flutter/material.dart';
import 'package:neptun2/colors.dart';
import 'package:neptun2/language.dart';
import '../Pages/main_page.dart';
import '../haptics.dart';

class BottomNavigatorWidget extends StatelessWidget {
  final HomePageState homePage;
  const BottomNavigatorWidget({super.key, required this.homePage});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: AppColors.getTheme().rootBackground,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
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
          child: Column(
            children: [
              const SizedBox(height: 4),
              Text(
                _getNameOfMenu(homePage.currentView),
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.getTheme().onPrimaryContainer,
                    fontWeight: FontWeight.w800,
                    fontSize: 12.0
                ),
              ),
              const SizedBox(height: 2),
              SingleChildScrollView(
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
                    _buildNavigationButton(4, Icons.email_rounded, Icons.email_outlined),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  String _getNameOfMenu(int idx){
    switch(idx){
      case 0:
        return AppStrings.getLanguagePack().view_header_Calendar;
      case 1:
        return AppStrings.getLanguagePack().view_header_Subjects;
      case 2:
        return AppStrings.getLanguagePack().view_header_Payments;
      case 3:
        return AppStrings.getLanguagePack().view_header_Periods;
      case 4:
        return AppStrings.getLanguagePack().view_header_Messages;
      default:
        return 'Not Impl';
    }
  }

  Widget _buildNavigationButton(int index, IconData filledIcon, IconData outlinedIcon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
          color: homePage.currentView == index
              ? AppColors.getTheme().textColor.withOpacity(.15)
              : AppColors.getTheme().textColor.withOpacity(.05),
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(12), bottomRight: Radius.circular(16), bottomLeft: Radius.circular(12)),
          border: Border.all(
            width: 1,
            color: homePage.currentView == index ? AppColors.getTheme().primary : Colors.transparent
          )
      ),
      child: IconButton(
        onPressed: (){
          homePage.switchView(index);
          AppHaptics.lightImpact();
        },
        color: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        disabledColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 13),
        icon: Icon(
          homePage.currentView == index ? filledIcon : outlinedIcon,
          color: homePage.currentView == index ?
          AppColors.getTheme().onPrimaryContainer :
          AppColors.getTheme().onPrimaryContainer.withOpacity(.3),
          size: 28,
        ),
      ),
    );
  }
}
