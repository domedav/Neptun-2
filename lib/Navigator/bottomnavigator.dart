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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(decelerationRate: ScrollDecelerationRate.fast),
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildNavigationButton(0, Icons.calendar_month_rounded, Icons.calendar_month_outlined),
                _buildNavigationButton(1, Icons.backpack_rounded, Icons.backpack_outlined),
                _buildNavigationButton(3, Icons.timer_rounded, Icons.timer_outlined),
                _buildNavigationButton(2, Icons.price_change_rounded, Icons.price_change_outlined),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButton(int index, IconData filledIcon, IconData outlinedIcon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: IconButton(
        onPressed: () {
          homePage.switchView(index);
        },
        style: ButtonStyle(
          backgroundColor: homePage.currentView == index
              ? MaterialStateProperty.all(const Color.fromRGBO(0xFF, 0xFF, 0xFF, 0.15))
              : MaterialStateProperty.all(const Color.fromRGBO(0xFF, 0xFF, 0xFF, 0.05)),
          padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
        ),
        icon: Icon(
          homePage.currentView == index ? filledIcon : outlinedIcon,
          color: homePage.currentView == index ? const Color.fromRGBO(0x6D, 0xC2, 0xD3, 1.0) : const Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
          size: homePage.currentView == index ? 32 : 28,
        ),
      ),
    );
  }
}
