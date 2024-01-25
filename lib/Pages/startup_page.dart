import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neptun2/API/api_coms.dart' as api;
import '../storage.dart';
import 'main_page.dart' as main_page;
import 'setup_page.dart' as setup_page;

class Splitter extends StatefulWidget{
  const Splitter({super.key});
  @override
  State<StatefulWidget> createState() => _SplitterState();
}
class _SplitterState extends State<Splitter>{
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color.fromRGBO(0x22, 0x22, 0x22, 1.0), // navigation bar color
      statusBarColor: Color.fromRGBO(0x22, 0x22, 0x22, 1.0), // status bar color
    ));

    DataCache.loadData().then((value) async {
      final flag = DataCache.getHasCachedFirstWeekEpoch();

      if(flag != null && !flag && DataCache.getHasNetwork() && DataCache.getHasLogin()!){
        Future.delayed(Duration.zero, () async{
          final firstWeekOfSemester = await api.InstitutesRequest.getFirstStudyweek();
          DataCache.setHasCachedFirstWeekEpoch(1);
          DataCache.setFirstWeekEpoch(firstWeekOfSemester);
        });
      }
      else if(flag != null && !flag){
        DataCache.setFirstWeekEpoch(-1);
      }
    }).then((value) {
      Navigator.popUntil(context, (route) => route.willHandlePopInternally);
      if (DataCache.getHasLogin() != null && DataCache.getHasLogin()!) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const main_page.HomePage()),
        );
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => setup_page.Page1(fetchData: true)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.width < MediaQuery.of(context).size.height ? MediaQuery.of(context).size.width * 0.20 : MediaQuery.of(context).size.height * 0.20,
                width: MediaQuery.of(context).size.width < MediaQuery.of(context).size.height ? MediaQuery.of(context).size.width * 0.20 : MediaQuery.of(context).size.height * 0.20,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              api.Generic.randomLoadingComment(),
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withOpacity(.2),
                  fontWeight: FontWeight.w300,
                  fontSize: 10
              ),
            )
          ],
        )
    );
  }
}