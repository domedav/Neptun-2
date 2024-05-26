import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:neptun2/haptics.dart';
import 'package:neptun2/language.dart';
import 'package:url_launcher/url_launcher.dart';
import '../API/api_coms.dart' as api;
import '../Misc/custom_snackbar.dart';
import '../Misc/emojirich_text.dart';
import '../app_analitics.dart';
import '../storage.dart' as storage;
import '../storage.dart';
import 'main_page.dart' as main_page;

class SetupPageLoginTypeSelection extends StatefulWidget{
  const SetupPageLoginTypeSelection({super.key});
  @override
  State<StatefulWidget> createState() => _SetupPageLoginTypeSelectionState();
}
class _SetupPageLoginTypeSelectionState extends State<SetupPageLoginTypeSelection>{
  bool _obtainFreshData = true;

  void changeFreshDataVal(bool val) => _obtainFreshData = val;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color.fromRGBO(0x17, 0x17, 0x17, 1.0), // navigation bar color
      statusBarColor: Color.fromRGBO(0x17, 0x17, 0x17, 1.0), // status bar color
    ));

    FlutterNativeSplash.remove();
  }

  bool _analiticsDebounce = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Text(
                  AppStrings.getLanguagePack().setupPage_selectLoginTypeHeader_RootPage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white
                  ),
                ),
                const SizedBox(height: 50),
                Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: (){
                        AppHaptics.lightImpact();
                        if(!_analiticsDebounce){
                          _analiticsDebounce = true;
                          AppAnalitics.sendAnaliticsData(AppAnalitics.INFO, 'setup_page.dart => _SetupPageLoginTypeSelectionState.build() Info: Institude selection login');
                        }
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SetupPageInstitudeSelection(fetchData: _obtainFreshData, callback: changeFreshDataVal)));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(0x22, 0x22, 0x22, 1.0),
                          borderRadius: const BorderRadius.all(Radius.circular(30)),
                          border: Border.all(
                            color: Colors.white.withOpacity(.3),
                            width: 1
                          )
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Icon(
                                  Icons.list_rounded,
                                  color: Colors.white,
                                  size: 40,
                                ),
                                Flexible(
                                  child: Text(
                                    AppStrings.getLanguagePack().setupPage_institutesSelection_RootPage,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              AppStrings.getLanguagePack().setupPage_institutesSelectionDescription_RootPage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white.withOpacity(.6),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        AppHaptics.lightImpact();
                        if(!_analiticsDebounce){
                          _analiticsDebounce = true;
                          AppAnalitics.sendAnaliticsData(AppAnalitics.INFO, 'setup_page.dart => _SetupPageLoginTypeSelectionState.build() Info: URL input login');
                        }
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SetupPageURLInput()));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: const Color.fromRGBO(0x22, 0x22, 0x22, 1.0),
                            borderRadius: const BorderRadius.all(Radius.circular(30)),
                            border: Border.all(
                                color: Colors.white.withOpacity(.3),
                                width: 1
                            )
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Icon(
                                  Icons.link_rounded,
                                  color: Colors.white,
                                  size: 40,
                                ),
                                Flexible(
                                  child: Text(
                                    AppStrings.getLanguagePack().setupPage_urlLogin_RootPage,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              AppStrings.getLanguagePack().setupPage_urlLoginDescription_RootPage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white.withOpacity(.6),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 50),
                Container(
                    margin: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Flexible(
                          child: EmojiRichText(
                            text: AppStrings.getLanguagePack().setupPage_appProblemReporting_RootPage,
                            defaultStyle: TextStyle(
                              color: Colors.white.withOpacity(.6),
                              fontWeight: FontWeight.w700,
                              fontSize: 14.0,
                            ),
                            emojiStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                                fontFamily: "Noto Color Emoji"
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.06),
                              borderRadius: const BorderRadius.all(Radius.circular(90))
                          ),
                          child: IconButton(
                            onPressed: (){
                              if(!Platform.isAndroid){
                                return;
                              }

                              final url = Uri.parse('https://github.com/domedav/Neptun-2/issues/new/choose');
                              launchUrl(url);
                            },
                            icon: Icon(
                              Icons.feed_rounded,
                              color: Colors.white.withOpacity(.4),
                              size: 32,
                            ),
                          ),
                        )
                      ],
                    )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SetupPageInstitudeSelection extends StatefulWidget{
  const SetupPageInstitudeSelection({super.key, required this.fetchData, required this.callback});
  final bool fetchData;
  final Function(bool) callback;

  @override
  State<StatefulWidget> createState() => _SetupPageInstitudeSelectionState();
}
class _SetupPageInstitudeSelectionState extends State<SetupPageInstitudeSelection>{

  void proceedToLogin(){
    if(!_canProceed){
      return;
    }

    PageDTO.validatedURL = false;
    PageDTO.selected = _selectedValue;

    Navigator.push(context, MaterialPageRoute(builder: (context) => const SetupPageLogin()));
  }

  int _hasData = 0;
  bool _drawNoInternet = false;

  final List<String> _filteredValues = [];
  late List<api.Institute> _institutes = [];
  String _selectedValue = "Betöltés...";

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color.fromRGBO(0x17, 0x17, 0x17, 1.0), // navigation bar color
      statusBarColor: Color.fromRGBO(0x17, 0x17, 0x17, 1.0), // status bar color
    ));

    fetchDataFromStorage();

    if(storage.DataCache.getHasNetwork()){
      _hasData++;
    }

    FlutterNativeSplash.remove();

    Future.delayed(Duration.zero,()async{
      final hasNetwork = await Connectivity().checkConnectivity() == ConnectivityResult.none;
      setState(() {
        _drawNoInternet = hasNetwork;
      });
    });

    if(widget.fetchData) {
      if(!storage.DataCache.getHasNetwork()){
        return;
      }
      api.InstitutesRequest.fetchInstitudesJSON().then((value) {
        if(value == null){
          return;
        }
        setState(() {
          final data = api.InstitutesRequest.getDataFromInstitudesJSON(value);
          PageDTO.institutes = data;
          _institutes = data;

          for(var item in data){
            _filteredValues.add(item.Name);
          }

          _selectedValue = _filteredValues[Random().nextInt(1000) % _filteredValues.length];
          _hasData++;
        });

        widget.callback(false);
      });
    }
    else{
      setState(() {
        _drawNoInternet = false;
        _institutes = PageDTO.institutes!;

        for(var item in _institutes){
          _filteredValues.add(item.Name);
        }

        _selectedValue = _filteredValues[Random().nextInt(_filteredValues.length)];

        _hasData++;
      });
    }
  }
  
  Future<void> fetchDataFromStorage() async {
    PageDTO.username = storage.DataCache.getUsername() ?? "";
    PageDTO.password = storage.DataCache.getPassword() ?? "";
  }

  String _snackbarMessage = "";
  Duration _displayDuration = Duration.zero;
  bool _shouldShowSnackbar = false;

  void _showSnackbar(String text, int displayDurationSec){
    if(!mounted){
      return;
    }
    setState(() {
      _shouldShowSnackbar = true;
      _displayDuration = Duration(seconds: displayDurationSec);
      _snackbarMessage = text;
    });
  }
  
  double _horizontalDrag = 0;
  bool _dragDebounce = false;
  bool _canProceed = true;

  final GlobalKey _dropdownSelectionGK = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return (_hasData < 2) ? Scaffold(
      body: GestureDetector(
        onHorizontalDragStart: (_){
          _horizontalDrag = 0;
          _dragDebounce = false;
        },
        onHorizontalDragEnd: (_){
          _horizontalDrag = 0;
          _dragDebounce = false;
        },
        onHorizontalDragUpdate: (e){
          _horizontalDrag += e.delta.dx;
          if(_horizontalDrag >= 25 && !_dragDebounce){
            _horizontalDrag = 0;
            _dragDebounce = true;

            AppHaptics.lightImpact();
            Navigator.pop(context);
          }
        },
        child: Container(
          margin: const EdgeInsets.all(20),
          child: Center(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: _drawNoInternet ?
              const Text(
                "Nincs Internet...",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 38
                ),
              ) :
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Text(
                    "Betöltés...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 24
                    ),
                  ),
                  const SizedBox(height: 50),
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 20),
                  Text(
                    api.Generic.randomLoadingComment(storage.DataCache.getNeedFamilyFriendlyComments()!),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white.withOpacity(.2),
                        fontWeight: FontWeight.w300,
                        fontSize: 10
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    ) : Scaffold(
        body: GestureDetector(
          onHorizontalDragStart: (_){
            _horizontalDrag = 0;
            _dragDebounce = false;
          },
          onHorizontalDragEnd: (_){
            _horizontalDrag = 0;
            _dragDebounce = false;
          },
          onHorizontalDragUpdate: (e){
            _horizontalDrag += e.delta.dx;
            if(_horizontalDrag <= -25 && !_dragDebounce){
              _horizontalDrag = 0;
              _dragDebounce = true;

              if(!_canProceed){
                _showSnackbar('Válassz ki egy érvényes egyetemet! 😡', 5);
                AppHaptics.attentionLightImpact();
                return;
              }

              AppHaptics.lightImpact();
              proceedToLogin();
            }
            else if(_horizontalDrag >= 25 && !_dragDebounce){
              _horizontalDrag = 0;
              _dragDebounce = true;

              AppHaptics.lightImpact();
              Navigator.pop(context);
            }
          },
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Center(
                child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      const Text(
                        'Válassz intézményt',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white
                        ),
                      ),
                      const SizedBox(height: 60),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: TextField(
                              keyboardType: TextInputType.name,
                              decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(18),
                                  suffixIcon: Icon(Icons.search_rounded),
                                  labelText: 'Keresés',
                                  labelStyle: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(.6),
                                      fontWeight: FontWeight.w400
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(12)),
                                      borderSide: BorderSide.none
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(.05)
                              ),
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600
                              ),
                              autofocus: true,
                              enableSuggestions: false,
                              autocorrect: false,
                              onChanged: (value) {
                                AppHaptics.textEditingImpact();
                                setState(() {
                                  _filteredValues.clear();
                                  for(var item in _institutes){
                                    if(item.Name.toLowerCase().contains(value.toLowerCase())){
                                      _filteredValues.add(item.Name);
                                    }
                                  }
                                  if(_filteredValues.isNotEmpty) {
                                    _selectedValue = _filteredValues[0];
                                    _canProceed = true;
                                  } else{
                                    AppHaptics.attentionLightImpact();
                                    _filteredValues.add("Nincs találat...");
                                    _selectedValue = _filteredValues[0];
                                    _canProceed = false;
                                  }
                                });
                              },
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            child: DropdownButtonFormField<String>(
                              key: _dropdownSelectionGK,
                              borderRadius: BorderRadius.circular(12),
                              value: _selectedValue, // The currently selected value.
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
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(12)),
                                      borderSide: BorderSide.none
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(.05)
                              ),
                              items: _filteredValues.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                    value: value,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
                                      child: Text(
                                        value,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400
                                        ),
                                      ),
                                    )
                                );
                              }).toList(),
                              selectedItemBuilder: (context){
                                return _filteredValues.map<Widget>((String value){
                                  return Container(
                                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 105),
                                    child: Text(
                                      value,
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400
                                      ),
                                    ),
                                  );
                                }).toList();
                              },
                              onChanged: (String? value) {
                                AppHaptics.lightImpact();
                                setState(() {
                                  _selectedValue = value!;
                                });
                              }
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 35),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Container(
                              margin: const EdgeInsets.all(15),
                              child: Text(
                                'Nem találod az iskolád a listában?',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(.6)
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(90)),
                                color: Colors.white.withOpacity(.06)
                            ),
                            child: IconButton(
                              onPressed: (){
                                _showSnackbar('A fenti listában szereplő elemek manuálisan lettek felvéve! 😅 Így előfordulhat, hogy egyes iskolák nincsenek benne a listában.\nJelentkezz be URL használatával, ha nem találod a sulid. 😉', 12);
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
                        ],
                      ),
                      const SizedBox(height: 50),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ElevatedButton(
                                onPressed: (){
                                  AppHaptics.lightImpact();
                                  Navigator.pop(context);
                                },
                                style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(const Color.fromRGBO(0x25, 0x31, 0x33, 1.0)),
                                    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 35, vertical: 20))
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.arrow_back_ios_rounded,
                                      color: Colors.white.withOpacity(.6),
                                    ),
                                    const Text(
                                      'Vissza',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        color: Colors.white
                                      ),
                                    )
                                  ],
                                )
                            ),
                            SizedBox(width: MediaQuery.of(context).size.width / 10),
                            ElevatedButton(
                                onPressed: _canProceed ? (){
                                  AppHaptics.lightImpact();
                                  proceedToLogin();
                                } : (){
                                  _showSnackbar('Válassz ki egy érvényes egyetemet! 😡', 5);
                                  AppHaptics.attentionLightImpact();
                                },
                                style: ButtonStyle(
                                    backgroundColor: _canProceed ? WidgetStateProperty.all(const Color.fromRGBO(0x25, 0x31, 0x33, 1.0)) : WidgetStateProperty.all(const Color.fromRGBO(0x1B, 0x24, 0x25, 1.0)),
                                    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 35, vertical: 20))
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Tovább',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color: Colors.white
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: Colors.white.withOpacity(.6),
                                    ),
                                  ],
                                )
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
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
            ),
          ],
        ),
      ),
    );
  }
}

class SetupPageURLInput extends StatefulWidget{
  const SetupPageURLInput({super.key});
  @override
  State<StatefulWidget> createState() => _SetupPageURLInputState();
}
class _SetupPageURLInputState extends State<SetupPageURLInput>{

  bool _canProceed = false;

  void proceedToLogin(){
    if(!_canProceed){
      return;
    }

    PageDTO.customURL = _rawNeptunURL;

    Navigator.push(context, MaterialPageRoute(builder: (context) => const SetupPageLogin()));
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color.fromRGBO(0x17, 0x17, 0x17, 1.0), // navigation bar color
      statusBarColor: Color.fromRGBO(0x17, 0x17, 0x17, 1.0), // status bar color
    ));

    FlutterNativeSplash.remove();
  }

  String _snackbarMessage = "";
  Duration _displayDuration = Duration.zero;
  bool _shouldShowSnackbar = false;

  void _showSnackbar(String text, int displayDurationSec){
    if(!mounted){
      return;
    }
    setState(() {
      _shouldShowSnackbar = true;
      _displayDuration = Duration(seconds: displayDurationSec);
      _snackbarMessage = text;
    });
  }

  double _horizontalDrag = 0;
  bool _dragDebounce = false;
  String _rawNeptunURL = "";
  Timer? _warnTimer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragStart: (_){
          _horizontalDrag = 0;
          _dragDebounce = false;
        },
        onHorizontalDragEnd: (_){
          _horizontalDrag = 0;
          _dragDebounce = false;
        },
        onHorizontalDragUpdate: (e){
          _horizontalDrag += e.delta.dx;
          if(_horizontalDrag <= -25 && !_dragDebounce){
            _horizontalDrag = 0;
            _dragDebounce = true;

            if(!_canProceed){
              _showSnackbar('Írj be egy érvényes neptun URL-t! 😡', 5);
              AppHaptics.attentionLightImpact();
              return;
            }

            AppHaptics.lightImpact();
            proceedToLogin();
          }
          else if(_horizontalDrag >= 25 && !_dragDebounce){
            _horizontalDrag = 0;
            _dragDebounce = true;

            AppHaptics.lightImpact();
            Navigator.pop(context);
          }
        },
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Center(
                child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      const Text(
                        'Belépés URL-el',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white
                        ),
                      ),
                      const SizedBox(height: 60),
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: TextField(
                          keyboardType: TextInputType.url,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(18),
                            suffixIcon: Icon(Icons.link_rounded),
                            labelText: 'Egyetem neptun URL-je',
                            labelStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(.6),
                              fontWeight: FontWeight.w400
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                              borderSide: BorderSide.none
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(.05)
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600
                          ),
                          autofocus: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          onChanged: (value) {
                            AppHaptics.textEditingImpact();
                            setState(() {
                              _canProceed = false;
                              PageDTO.validatedURL = false;
                            });
                            _rawNeptunURL = value.trim();
                            if(_warnTimer != null){
                              _warnTimer!.cancel();
                            }
                            RegExp regex = RegExp(r'/hallgato/login\.aspx');
                            PageDTO.validatedURL = _rawNeptunURL.toLowerCase().contains(regex);
                            if(_rawNeptunURL.isEmpty){
                              return;
                            }
                            if(_rawNeptunURL.toLowerCase().contains(regex)){
                              setState(() {
                                _canProceed = true;
                                PageDTO.validatedURL = true;
                              });
                              return;
                            }
                            _warnTimer = Timer(const Duration(seconds: 2),(){
                              _showSnackbar('Ez nem egy jó neptun URL! 😡\n\nValami ilyesmit másolj ide:\nhttps://neptun-ws01.uni-pannon.hu/hallgato/login.aspx 🤫', 18);
                              AppHaptics.attentionLightImpact();
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 50),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ElevatedButton(
                                onPressed: (){
                                  AppHaptics.lightImpact();
                                  Navigator.pop(context);
                                },
                                style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(const Color.fromRGBO(0x25, 0x31, 0x33, 1.0)),
                                    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 35, vertical: 20))
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.arrow_back_ios_rounded,
                                      color: Colors.white.withOpacity(.6),
                                    ),
                                    const Text(
                                      'Vissza',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color: Colors.white
                                      ),
                                    )
                                  ],
                                )
                            ),
                            SizedBox(width: MediaQuery.of(context).size.width / 10),
                            ElevatedButton(
                                onPressed: _canProceed ? (){
                                  AppHaptics.lightImpact();
                                  proceedToLogin();
                                } : (){
                                  _showSnackbar('Írj be egy érvényes neptun URL-t! 😡', 5);
                                  AppHaptics.attentionLightImpact();
                                },
                                style: ButtonStyle(
                                    backgroundColor: _canProceed ? WidgetStateProperty.all(const Color.fromRGBO(0x25, 0x31, 0x33, 1.0)) : WidgetStateProperty.all(const Color.fromRGBO(0x1B, 0x24, 0x25, 1.0)),
                                    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 35, vertical: 20))
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Tovább',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color: Colors.white
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: Colors.white.withOpacity(.6),
                                    ),
                                  ],
                                )
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 60),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Container(
                              margin: const EdgeInsets.all(15),
                              child: Text(
                                'Hol találom meg az URL-t?',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(.6)
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(90)),
                                color: Colors.white.withOpacity(.06)
                            ),
                            child: IconButton(
                              onPressed: (){
                                _showSnackbar('Keresd meg weben az egyetemed neptun weboldalát és másold be ide a fenti linket. 🔗\n\nPld: https://neptun-ws01.uni-pannon.hu/hallgato/login.aspx', 18);
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
                        ],
                      ),
                    ],
                  ),
                )
              ),
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
            ),
          ],
        ),
      ),
    );
  }
}

class SetupPageLogin extends StatefulWidget{
  const SetupPageLogin({super.key});
  @override
  State<StatefulWidget> createState() => _SetupPageLoginState();
}
class _SetupPageLoginState extends State<SetupPageLogin>{

  String _username = '';
  String _password = '';

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool _obscureText = true;
  bool _canProceed = false;
  //bool _canGoBack = true;

  bool _isLoading = false;

  bool _paintRed = false;

  Timer? _loadingTimer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color.fromRGBO(0x17, 0x17, 0x17, 1.0), // navigation bar color
      statusBarColor: Color.fromRGBO(0x17, 0x17, 0x17, 1.0), // status bar color
    ));

    FlutterNativeSplash.remove();

    _username = PageDTO.username ?? "";
    _password = PageDTO.password ?? "";

    _usernameController = TextEditingController(text: _username);
    _passwordController = TextEditingController(text: _password);

    _canProceed = _password.isNotEmpty && _username.isNotEmpty;
  }

  bool _showNeptunServerError = false;

  void finishLogin(){
    api.Institute selected = api.Institute('ERROR', '');
    if(PageDTO.validatedURL){
      if(PageDTO.customURL != null && PageDTO.customURL!.isNotEmpty){
        RegExp regex = RegExp(r'/hallgato/login\.aspx');
        var correctedURL = PageDTO.customURL!.trim().toLowerCase();
        if(correctedURL.contains(regex)){
          correctedURL = correctedURL.replaceAll(regex, '/hallgato/MobileService.svc');
          PageDTO.customURL = correctedURL;
        }

        selected = api.Institute('URL', PageDTO.customURL!);
      }
    }
    else{
      for(var item in PageDTO.institutes!){
        if(item.Name == PageDTO.selected!){
          selected = item;
          break;
        }
      }
    }

    setState(() {
      _canProceed = false;
      //_canGoBack = false;
      _isLoading = true;
      _showNeptunServerError = false;
    });

    _loadingTimer?.cancel();

    _loadingTimer = Timer(const Duration(seconds: 7), (){
      if(!_isLoading || !mounted){
        return;
      }
      setState(() {
        _showNeptunServerError = true;
      });
    });

    AppAnalitics.sendAnaliticsData(AppAnalitics.INFO, 'api_coms.dart => SetupPageLogin.finishLogin() Info: Login: ${selected.Name} - ${selected.URL}');
    api.InstitutesRequest.validateLoginCredentials(selected, _username.toUpperCase(), _password).then((value)
    {
      if(value){ // logged in
        storage.DataCache.setUsername(_username.toUpperCase());
        storage.DataCache.setPassword(_password);
        storage.DataCache.setInstituteUrl(selected.URL);
        storage.DataCache.setHasLogin(1);
        // proceed logic
        Navigator.popUntil(context, (route) => route.willHandlePopInternally);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const main_page.HomePage()),
        );
        return;
      }
      AppHaptics.attentionLightImpact();
      setState(() {
        _paintRed = true;
        _canProceed = true;
        //_canGoBack = true;
        _isLoading = false;
        _showNeptunServerError = false;
      });
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _snackbarMessage = "";
  Duration _displayDuration = Duration.zero;
  bool _shouldShowSnackbar = false;

  void _showSnackbar(String text, int displayDurationSec){
    if(!mounted){
      return;
    }
    setState(() {
      _shouldShowSnackbar = true;
      _displayDuration = Duration(seconds: displayDurationSec);
      _snackbarMessage = text;
    });
  }

  double _horizontalDrag = 0;
  bool _dragDebounce = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragStart: (_){
          _horizontalDrag = 0;
          _dragDebounce = false;
        },
        onHorizontalDragEnd: (_){
          _horizontalDrag = 0;
          _dragDebounce = false;
        },
        onHorizontalDragUpdate: (e){
          _horizontalDrag += e.delta.dx;
          if(_horizontalDrag <= -25 && !_dragDebounce){
            _horizontalDrag = 0;
            _dragDebounce = true;

            if(!_canProceed){
              _showSnackbar('Írj be egy érvényes neptun URL-t! 😡', 5);
              AppHaptics.attentionLightImpact();
              return;
            }

            AppHaptics.lightImpact();
            finishLogin();
          }
          else if(_horizontalDrag >= 25 && !_dragDebounce){
            _horizontalDrag = 0;
            _dragDebounce = true;

            AppHaptics.lightImpact();
            Navigator.pop(context);
          }
        },
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Center(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      const Text(
                        'Jelentkezz be',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white
                        ),
                      ),
                      const SizedBox(height: 60),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.house_rounded,
                            color: Colors.white.withOpacity(.2),
                            size: 22,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              PageDTO.validatedURL ? PageDTO.customURL!.replaceAll(RegExp(r'/hallgato/login\.aspx'), '').replaceAll(RegExp(r'/hallgato/MobileService\.svc'), "").replaceAll("https://", '') : (PageDTO.selected ?? 'HIBA! Lépj egyet vissza!'),
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  color: Colors.white.withOpacity(.2),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600
                              ),
                            ),
                          )
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: TextField(
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(18),
                                suffixIcon: Icon(
                                    Icons.person_2_rounded,
                                    color: _paintRed ? Colors.red : Colors.white),
                                labelText: 'Neptun kód',
                                labelStyle: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(.6),
                                    fontWeight: FontWeight.w400
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(12)),
                                    borderSide: BorderSide.none
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(.05)
                            ),
                              autofocus: true,
                              enableSuggestions: false,
                              autocorrect: false,
                              controller: _usernameController,
                              style: TextStyle(
                                color: _paintRed ? const Color.fromRGBO(0xFF, 0xB0, 0xB0, 1.0) : Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              onChanged: (value) {
                                AppHaptics.textEditingImpact();
                                _username = value;
                                setState(() {
                                  _canProceed = _password.isNotEmpty && _username.isNotEmpty;
                                  _paintRed = false;
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: TextField(
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(18),
                                suffixIcon: IconButton(
                                    icon: Icon(
                                        _obscureText ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                        color: _paintRed ? Colors.red : Colors.white),
                                    onPressed: () {
                                      AppHaptics.lightImpact();
                                      setState(() {
                                        _obscureText = !_obscureText; // Toggle the password visibility
                                      });
                                    }),
                                labelText: 'Jelszó',
                                labelStyle: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(.6),
                                    fontWeight: FontWeight.w400
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(12)),
                                    borderSide: BorderSide.none
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(.05)
                              ),
                              controller: _passwordController,
                              obscureText: _obscureText,
                              enableSuggestions: false,
                              autocorrect: false,
                              style: TextStyle(
                                color: _paintRed ? const Color.fromRGBO(0xFF, 0xB0, 0xB0, 1.0) : Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              onChanged: (value) {
                                AppHaptics.textEditingImpact();
                                _password = value;
                                setState(() {
                                  _canProceed = _password.isNotEmpty && _username.isNotEmpty;
                                  _paintRed = false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _paintRed ? "Hibás felhasználónév vagy jelszó!" : "",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: _paintRed ? Colors.red : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12
                            ),
                          ),
                          const SizedBox(height: 45),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Container(
                                  margin: const EdgeInsets.all(15),
                                  child: Text(
                                    'Ha két lépcsős azonosítás van a fiókodon, nem fogsz tudni bejelenzkezni!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withOpacity(.6)
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(Radius.circular(90)),
                                    color: Colors.white.withOpacity(.06)
                                ),
                                child: IconButton(
                                  onPressed: (){
                                    _showSnackbar('❌ A Neptun2 a régi Neptun mobilapp API-jait használja, amiben nem volt 2 lépcsős azonosítás. Így, ha a fiókod 2 lépcsős azonosítással van védve, a Neptun2 nem fog tudni bejelentkeztetni.\n\n🤓 Viszont, ha kikapcsolod, hiba nélkül tudod használni a Neptun2-t.\nKikapcsolni a Neptunban, a "Saját Adatok/Beállítások"-ban tudod.', 18);
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
                            ],
                          ),
                          const SizedBox(height: 50),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                    onPressed: (){
                                      AppHaptics.lightImpact();
                                      Navigator.pop(context);
                                    },
                                    style: ButtonStyle(
                                        backgroundColor: WidgetStateProperty.all(const Color.fromRGBO(0x25, 0x31, 0x33, 1.0)),
                                        padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 35, vertical: 20))
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.arrow_back_ios_rounded,
                                          color: Colors.white.withOpacity(.6),
                                        ),
                                        const Text(
                                          'Vissza',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                              color: Colors.white
                                          ),
                                        )
                                      ],
                                    )
                                ),
                                SizedBox(width: MediaQuery.of(context).size.width / 11),
                                ElevatedButton(
                                    onPressed: _canProceed ? (){
                                      AppHaptics.lightImpact();
                                      finishLogin();
                                    } : (){
                                      _showSnackbar('Érvényes adatokat adj meg! 😡', 5);
                                      AppHaptics.attentionLightImpact();
                                    },
                                    style: ButtonStyle(
                                        backgroundColor: _canProceed ? WidgetStateProperty.all(const Color.fromRGBO(0x25, 0x31, 0x33, 1.0)) : WidgetStateProperty.all(const Color.fromRGBO(0x1B, 0x24, 0x25, 1.0)),
                                        padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 35, vertical: 20))
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'Belépés',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                              color: Colors.white
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: Colors.white.withOpacity(.6),
                                        ),
                                      ],
                                    )
                                )
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
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
            ),
            Visibility(
              visible: _isLoading,
              child: Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                      color: Colors.black.withOpacity(0.4),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Text(
                              'Bejelentkezés...',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 28
                              ),
                            ),
                          ),
                          const SizedBox(height: 60),
                          Center(
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              api.Generic.randomLoadingComment(DataCache.getNeedFamilyFriendlyComments()!),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white.withOpacity(.6),
                                  fontWeight: FontWeight.w300,
                                  fontSize: 10
                              ),
                            ),
                          ),
                          const SizedBox(height: 60),
                          Visibility(
                            visible: _showNeptunServerError,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                'Neptun szervereivel lehet problémák vannak...',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white.withOpacity(.3),
                                    fontWeight: FontWeight.w300,
                                    fontSize: 14
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class PageDTO{
  static List<api.Institute>? institutes;
  static String? selected;
  static String? username;
  static String? password;
  static String? customURL;
  static bool validatedURL = false;
}