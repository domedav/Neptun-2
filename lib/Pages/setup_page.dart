import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:neptun2/colors.dart';
import 'package:neptun2/haptics.dart';
import 'package:neptun2/language.dart';
import 'package:url_launcher/url_launcher.dart';
import '../API/api_coms.dart' as api;
import '../Misc/custom_snackbar.dart';
import '../Misc/emojirich_text.dart';
import '../app_analitics.dart';
import '../app_update.dart';
import '../storage.dart' as storage;
import '../storage.dart';
import 'main_page.dart' as main_page;

class SetupPageLoginTypeSelection extends StatefulWidget{
  const SetupPageLoginTypeSelection({super.key});
  @override
  State<StatefulWidget> createState() => _SetupPageLoginTypeSelectionState();
}
class _SetupPageLoginTypeSelectionState extends State<SetupPageLoginTypeSelection> with TickerProviderStateMixin{
  bool _obtainFreshData = true;

  void changeFreshDataVal(bool val) => _obtainFreshData = val;

  late AnimationController blurController;
  late Animation<double> blurAnimation;
  bool _showBlur = false;

  void blurPage(bool state){
    setState(() {
      if(state) {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarIconBrightness: AppColors.isDarktheme() ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: AppColors.getTheme().navbarNavibarColor, // navigation bar color
          statusBarColor: AppColors.getTheme().navbarStatusBarColor, // status bar color
        ));
        blurController.forward();
        _showBlur = true;
        return;
      }
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.getTheme().rootBackground, // navigation bar color
        statusBarColor: AppColors.getTheme().rootBackground, // status bar color
      ));
      blurController.reverse().whenComplete((){
        setState(() {
          _showBlur = false;
        });
      });
    });
  }

  bool _hasAskedLang = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: AppColors.isDarktheme() ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: AppColors.getTheme().rootBackground, // navigation bar color
      statusBarColor: AppColors.getTheme().rootBackground, // status bar color
    ));

    blurController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    blurAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: blurController, curve: Curves.linear),
    );

    FlutterNativeSplash.remove();

    if(!_hasAskedLang){
      Future.delayed(Duration(seconds: 1),()async{
        _hasAskedLang = true;
        await LanguageManager.suggestLang(context, ()=>blurPage(true), ()=>blurPage(false));
      });
    }
    Future.delayed(Duration(seconds: 1),()async{
      await AppUpdate.doUpdateRequest(context, ()=>blurPage(true), ()=>blurPage(false));
    });
    Future.delayed(Duration(seconds: 1),()async{
      await LanguageManager.refreshAllDownloadedLangs();
    });
  }

  bool _analiticsDebounce = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
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
                    Text(
                      AppStrings.getLanguagePack().rootpage_setupPage_SelectLoginTypeHeader,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.getTheme().textColor
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
                              color: AppColors.getTheme().rootBackground,
                              borderRadius: const BorderRadius.all(Radius.circular(30)),
                              border: Border.all(
                                color: AppColors.getTheme().textColor.withOpacity(.3),
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
                                      color: AppColors.getTheme().textColor,
                                      size: 40,
                                    ),
                                    Flexible(
                                      child: Text(
                                        AppStrings.getLanguagePack().rootpage_setupPage_InstitutesSelection,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: AppColors.getTheme().textColor,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  AppStrings.getLanguagePack().rootpage_setupPage_InstitutesSelectionDescription,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: AppColors.getTheme().textColor.withOpacity(.6),
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
                                color: AppColors.getTheme().rootBackground,
                                borderRadius: const BorderRadius.all(Radius.circular(30)),
                                border: Border.all(
                                    color: AppColors.getTheme().textColor.withOpacity(.3),
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
                                      color: AppColors.getTheme().textColor,
                                      size: 40,
                                    ),
                                    Flexible(
                                      child: Text(
                                        AppStrings.getLanguagePack().rootpage_setupPage_UrlLogin,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: AppColors.getTheme().textColor,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  AppStrings.getLanguagePack().rootpage_setupPage_UrlLoginDescription,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: AppColors.getTheme().textColor.withOpacity(.6),
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
                                text: AppStrings.getLanguagePack().rootpage_setupPage_AppProblemReporting,
                                defaultStyle: TextStyle(
                                  color: AppColors.getTheme().textColor.withOpacity(.6),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.0,
                                ),
                                emojiStyle: TextStyle(
                                    color: AppColors.getTheme().textColor,
                                    fontSize: 14.0,
                                    fontFamily: "Noto Color Emoji"
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Container(
                              decoration: BoxDecoration(
                                  color: AppColors.getTheme().textColor.withOpacity(.06),
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
                                  color: AppColors.getTheme().textColor.withOpacity(.4),
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
          Visibility(
            visible: _showBlur,
            child: AnimatedBuilder(
              animation: blurController,
              builder: (context, widget) {
                return Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: blurAnimation.value * 15, sigmaY: blurAnimation.value * 15),
                    child: Container(
                      color: Colors.black.withOpacity(blurAnimation.value * 0.4),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
  String _selectedValue = AppStrings.getLanguagePack().instituteSelection_setupPage_LoadingText;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: AppColors.isDarktheme() ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: AppColors.getTheme().rootBackground, // navigation bar color
      statusBarColor: AppColors.getTheme().rootBackground, // status bar color
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
              Text(
                AppStrings.getLanguagePack().instituteSelection_setupPage_NoNetwork,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.getTheme().textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 38
                ),
              ) :
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    AppStrings.getLanguagePack().instituteSelection_setupPage_LoadingText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.getTheme().textColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 24
                    ),
                  ),
                  const SizedBox(height: 50),
                  CircularProgressIndicator(color: AppColors.getTheme().textColor),
                  const SizedBox(height: 20),
                  Text(
                    api.Generic.randomLoadingComment(storage.DataCache.getNeedFamilyFriendlyComments()!),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.getTheme().textColor.withOpacity(.2),
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
                _showSnackbar(AppStrings.getLanguagePack().instituteSelection_setupPage_SelectValidInstitute, 5);
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
                      Text(
                        AppStrings.getLanguagePack().instituteSelection_setupPage_SelectInstitute,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.getTheme().textColor
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
                                  labelText: AppStrings.getLanguagePack().instituteSelection_setupPage_Search,
                                  labelStyle: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.getTheme().textColor.withOpacity(.6),
                                      fontWeight: FontWeight.w400
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(12)),
                                      borderSide: BorderSide.none
                                  ),
                                  filled: true,
                                  fillColor: AppColors.getTheme().textColor.withOpacity(.05)
                              ),
                              style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.getTheme().textColor,
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
                                    _filteredValues.add(AppStrings.getLanguagePack().instituteSelection_setupPage_SearchNotFound);
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
                              style: TextStyle(
                                  color: AppColors.getTheme().textColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600
                              ),
                              enableFeedback: true,
                              onTap: AppHaptics.lightImpact,
                              focusColor: Colors.transparent,
                              dropdownColor: AppColors.getTheme().rootBackground,
                              decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(18),
                                  suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
                                  labelStyle: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.getTheme().textColor.withOpacity(.6),
                                      fontWeight: FontWeight.w400
                                  ),
                                  border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(12)),
                                      borderSide: BorderSide.none
                                  ),
                                  filled: true,
                                  fillColor: AppColors.getTheme().textColor.withOpacity(.05)
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
                                        style: TextStyle(
                                          color: AppColors.getTheme().textColor,
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
                                      style: TextStyle(
                                        color: AppColors.getTheme().textColor,
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
                                AppStrings.getLanguagePack().instituteSelection_setupPage_InstituteCantFindHelpText,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.getTheme().textColor.withOpacity(.6)
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(90)),
                                color: AppColors.getTheme().textColor.withOpacity(.06)
                            ),
                            child: IconButton(
                              onPressed: (){
                                _showSnackbar(AppStrings.getLanguagePack().instituteSelection_setupPage_InstituteCantFindHelpTextDescription, 12);
                                AppHaptics.attentionLightImpact();
                              },
                              icon: Icon(
                                Icons.question_mark_rounded,
                                color: AppColors.getTheme().textColor.withOpacity(.4),
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
                                    backgroundColor: WidgetStateProperty.all(AppColors.getTheme().buttonEnabled),
                                    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 35, vertical: 20))
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.arrow_back_ios_rounded,
                                      color: AppColors.getTheme().textColor.withOpacity(.6),
                                    ),
                                    Text(
                                      AppStrings.getLanguagePack().any_setupPage_GoBack,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        color: AppColors.getTheme().textColor
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
                                  _showSnackbar(AppStrings.getLanguagePack().instituteSelection_setupPage_SelectValidInstitute, 5);
                                  AppHaptics.attentionLightImpact();
                                },
                                style: ButtonStyle(
                                    backgroundColor: _canProceed ? WidgetStateProperty.all(AppColors.getTheme().buttonEnabled) : WidgetStateProperty.all(AppColors.getTheme().buttonDisabled),
                                    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 35, vertical: 20))
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      AppStrings.getLanguagePack().any_setupPage_ProceedLogin,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color: AppColors.getTheme().textColor
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: AppColors.getTheme().textColor.withOpacity(.6),
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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: AppColors.isDarktheme() ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: AppColors.getTheme().rootBackground, // navigation bar color
      statusBarColor: AppColors.getTheme().rootBackground, // status bar color
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
              _showSnackbar(AppStrings.getLanguagePack().urlLogin_setupPage_InvalidUrl, 5);
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
                      Text(
                        AppStrings.getLanguagePack().urlLogin_setupPage_LoginViaURlHeader,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.getTheme().textColor
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
                            labelText: AppStrings.getLanguagePack().urlLogin_setupPage_InstituteNeptunUrl,
                            labelStyle: TextStyle(
                              fontSize: 14,
                              color: AppColors.getTheme().textColor.withOpacity(.6),
                              fontWeight: FontWeight.w400
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                              borderSide: BorderSide.none
                            ),
                            filled: true,
                            fillColor: AppColors.getTheme().textColor.withOpacity(.05)
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.getTheme().textColor,
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
                              _showSnackbar(AppStrings.getLanguagePack().urlLogin_setupPage_InstituteNeptunUrlInvalid, 18);
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
                                    backgroundColor: WidgetStateProperty.all(AppColors.getTheme().buttonEnabled),
                                    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 35, vertical: 20))
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.arrow_back_ios_rounded,
                                      color: AppColors.getTheme().textColor.withOpacity(.6),
                                    ),
                                    Text(
                                      AppStrings.getLanguagePack().any_setupPage_GoBack,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color: AppColors.getTheme().textColor
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
                                  _showSnackbar(AppStrings.getLanguagePack().urlLogin_setupPage_InvalidUrl, 5);
                                  AppHaptics.attentionLightImpact();
                                },
                                style: ButtonStyle(
                                    backgroundColor: _canProceed ? WidgetStateProperty.all(AppColors.getTheme().buttonEnabled) : WidgetStateProperty.all(AppColors.getTheme().buttonDisabled),
                                    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 35, vertical: 20))
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      AppStrings.getLanguagePack().any_setupPage_ProceedLogin,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color: AppColors.getTheme().textColor
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: AppColors.getTheme().textColor.withOpacity(.6),
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
                                AppStrings.getLanguagePack().urlLogin_setupPage_WhereIsURLHelper,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.getTheme().textColor.withOpacity(.6)
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(90)),
                                color: AppColors.getTheme().textColor.withOpacity(.06)
                            ),
                            child: IconButton(
                              onPressed: (){
                                _showSnackbar(AppStrings.getLanguagePack().urlLogin_setupPage_WhereIsURLHelperDescription, 18);
                                AppHaptics.attentionLightImpact();
                              },
                              icon: Icon(
                                Icons.question_mark_rounded,
                                color: AppColors.getTheme().textColor.withOpacity(.4),
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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: AppColors.isDarktheme() ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: AppColors.getTheme().rootBackground, // navigation bar color
      statusBarColor: AppColors.getTheme().rootBackground, // status bar color
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
              _showSnackbar(AppStrings.getLanguagePack().loginPage_setupPage_InvalidCredentials, 5);
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
                      Text(
                        AppStrings.getLanguagePack().loginPage_setupPage_LoginHeaderText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.getTheme().textColor
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
                            color: AppColors.getTheme().textColor.withOpacity(.2),
                            size: 22,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              PageDTO.validatedURL ? PageDTO.customURL!.replaceAll(RegExp(r'/hallgato/login\.aspx'), '').replaceAll(RegExp(r'/hallgato/MobileService\.svc'), "").replaceAll("https://", '') : (PageDTO.selected ?? AppStrings.getLanguagePack().loginPage_setupPage_ActivityCacheInvalidHelper),
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  color: AppColors.getTheme().textColor.withOpacity(.2),
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
                                    color: _paintRed ?AppColors.getTheme().errorRed : AppColors.getTheme().textColor),
                                labelText: AppStrings.getLanguagePack().loginPage_setupPage_NeptunCode,
                                labelStyle: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.getTheme().textColor.withOpacity(.6),
                                    fontWeight: FontWeight.w400
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(12)),
                                    borderSide: BorderSide.none
                                ),
                                filled: true,
                                fillColor: AppColors.getTheme().textColor.withOpacity(.05)
                            ),
                              autofocus: true,
                              enableSuggestions: false,
                              autocorrect: false,
                              controller: _usernameController,
                              style: TextStyle(
                                color: _paintRed ? AppColors.getTheme().errorRed : AppColors.getTheme().textColor,
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
                                        color: _paintRed ? AppColors.getTheme().errorRed : AppColors.getTheme().textColor),
                                    onPressed: () {
                                      AppHaptics.lightImpact();
                                      setState(() {
                                        _obscureText = !_obscureText; // Toggle the password visibility
                                      });
                                    }),
                                labelText: AppStrings.getLanguagePack().loginPage_setupPage_Password,
                                labelStyle: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.getTheme().textColor.withOpacity(.6),
                                    fontWeight: FontWeight.w400
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(12)),
                                    borderSide: BorderSide.none
                                ),
                                filled: true,
                                fillColor: AppColors.getTheme().textColor.withOpacity(.05)
                              ),
                              controller: _passwordController,
                              obscureText: _obscureText,
                              enableSuggestions: false,
                              autocorrect: false,
                              style: TextStyle(
                                color: _paintRed ? AppColors.getTheme().errorRed : AppColors.getTheme().textColor,
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
                            _paintRed ? AppStrings.getLanguagePack().loginPage_setupPage_InvalidCredentialsEntered : "",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: _paintRed ? AppColors.getTheme().errorRed : AppColors.getTheme().textColor,
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
                                    AppStrings.getLanguagePack().loginPage_setupPage_2faWarning,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.getTheme().textColor.withOpacity(.6)
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(Radius.circular(90)),
                                    color: AppColors.getTheme().textColor.withOpacity(.06)
                                ),
                                child: IconButton(
                                  onPressed: (){
                                    _showSnackbar(AppStrings.getLanguagePack().loginPage_setupPage_2faWarningDescription, 18);
                                    AppHaptics.attentionLightImpact();
                                  },
                                  icon: Icon(
                                    Icons.question_mark_rounded,
                                    color: AppColors.getTheme().textColor.withOpacity(.4),
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
                                        backgroundColor: WidgetStateProperty.all(AppColors.getTheme().buttonEnabled),
                                        padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 35, vertical: 20))
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.arrow_back_ios_rounded,
                                          color: AppColors.getTheme().textColor.withOpacity(.6),
                                        ),
                                        Text(
                                          AppStrings.getLanguagePack().any_setupPage_GoBack,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                              color: AppColors.getTheme().textColor
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
                                      _showSnackbar(AppStrings.getLanguagePack().loginPage_setupPage_InvalidCredentials, 5);
                                      AppHaptics.attentionLightImpact();
                                    },
                                    style: ButtonStyle(
                                        backgroundColor: _canProceed ? WidgetStateProperty.all(AppColors.getTheme().buttonEnabled) : WidgetStateProperty.all(AppColors.getTheme().buttonDisabled),
                                        padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 35, vertical: 20))
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          AppStrings.getLanguagePack().loginPage_setupPage_LogInButton,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                              color: AppColors.getTheme().textColor
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: AppColors.getTheme().textColor.withOpacity(.6),
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
                            child: Text(
                              AppStrings.getLanguagePack().loginPage_setupPage_LoginInProgress,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: AppColors.getTheme().textColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 28
                              ),
                            ),
                          ),
                          const SizedBox(height: 60),
                          Center(
                            child: CircularProgressIndicator(
                              color: AppColors.getTheme().textColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              api.Generic.randomLoadingComment(DataCache.getNeedFamilyFriendlyComments()!),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: AppColors.getTheme().textColor.withOpacity(.6),
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
                                AppStrings.getLanguagePack().loginPage_setupPage_LoginInProgressSlow,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: AppColors.getTheme().textColor.withOpacity(.3),
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