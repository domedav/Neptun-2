import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import '../API/api_coms.dart' as api;
import '../storage.dart' as storage;
import '../storage.dart';
import 'main_page.dart' as main_page;

class Page1 extends StatefulWidget {
  Page1({super.key, required this.fetchData});

  final bool fetchData;
  final PageDTO DTO = PageDTO(null, null, null, null);

  @override
  State<Page1> createState() => _Page1State();
}
class _Page1State extends State<Page1> {

  late List<api.Institute> _institutes;

  final List<String> _filteredValues = <String>[].toList();

  late String _selectedValue;
  int _hasData = 0;
  bool _canProceed = true;

  bool drawNoInternet = false;


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
        drawNoInternet = hasNetwork;
      });
    });

    if(widget.fetchData) {
      if(!storage.DataCache.getHasNetwork()){
        return;
      }
      api.InstitutesRequest.fetchInstitudesJSON().then((value) {
        setState(() {
          _institutes = api.InstitutesRequest.getDataFromInstitudesJSON(value);

          for(var item in _institutes){
            _filteredValues.add(item.Name);
          }

          _selectedValue = _filteredValues[0];
          _hasData++;
        });
      });
    }
    else{
      setState(() {
        drawNoInternet = false;
        _institutes = widget.DTO.Institutes!;

        for(var item in _institutes){
          _filteredValues.add(item.Name);
        }

        _selectedValue = widget.DTO.Selected!;
        _hasData++;
      });
    }
  }

  Future<void> fetchDataFromStorage() async {
    PageDTO.Instance.Username = storage.DataCache.getUsername() ?? "";
    PageDTO.Instance.Password = storage.DataCache.getPassword() ?? "";
  }

  @override
  void dispose() {
    _institutes.clear();
    _filteredValues.clear();
    super.dispose();
  }

  void goToPage2(){
    PageDTO.Instance.Institutes = _institutes;
    PageDTO.Instance.Selected = _selectedValue;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Page2()),
    );
  }

  double _horizontalDrag = 0;
  bool _dragDebounce = false;

  @override
  Widget build(BuildContext context) {
    if(_hasData < 2) { // not has network and data
      return Scaffold(
        body: Container(
          color: const Color.fromRGBO(0x17, 0x17, 0x17, 1.0),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(
                decelerationRate: ScrollDecelerationRate.fast
            ),
            scrollDirection: Axis.vertical,
            child: SizedBox(
              height: MediaQuery.of(context).size.height + 0.001,
              child: Center(
                child: drawNoInternet ?
                Text("Nincs Internet...", style: Theme.of(context).textTheme.headlineLarge) :
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.width < MediaQuery.of(context).size.height ? MediaQuery.of(context).size.width * 0.20 : MediaQuery.of(context).size.height * 0.20, width: MediaQuery.of(context).size.width < MediaQuery.of(context).size.height ? MediaQuery.of(context).size.width * 0.20 : MediaQuery.of(context).size.height * 0.20, child: const CircularProgressIndicator(color: Colors.white)),
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
              )
            ),
          ),
        ),
      );
    }
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
          if(_horizontalDrag <= -50 && !_dragDebounce){
            _horizontalDrag = 0;
            _dragDebounce = true;

            if(!_canProceed){
              return;
            }

            goToPage2();
          }
        },
        child: Container(
          color: const Color.fromRGBO(0x17, 0x17, 0x17, 1.0),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              decelerationRate: ScrollDecelerationRate.fast
            ),
            scrollDirection: Axis.vertical,
            child: SizedBox(
              height: MediaQuery.of(context).size.height + 0.001,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      'Válaszd ki az iskoládat!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.77,
                            child: TextField(
                              decoration: const InputDecoration(
                                suffixIcon: Icon(Icons.search_rounded),
                                hintText: 'Keresés...',
                                border: null
                              ),
                              enableSuggestions: false,
                              autocorrect: false,
                              onChanged: (value) {
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
                                    _filteredValues.add("Nincs Találat...");
                                    _selectedValue = _filteredValues[0];
                                    _canProceed = false;
                                  }
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.80,  // only take up 80% of the screen
                            child: DropdownButtonFormField<String>(
                                borderRadius: BorderRadius.circular(16),
                                menuMaxHeight: MediaQuery.of(context).size.height * 0.60,
                                isExpanded: true,
                                itemHeight: null,
                                value: _selectedValue, // The currently selected value.
                                padding: const EdgeInsets.all(8.0),
                                items: _filteredValues.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                          value,
                                          style: Theme.of(context).textTheme.labelLarge,
                                          overflow: TextOverflow.ellipsis,
                                      )
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  setState(() {
                                    _selectedValue = value!;
                                  });
                                }),
                            )
                      ]
                    ),
                    ElevatedButton(
                      onPressed: _canProceed ? () {
                          goToPage2();
                        } : null,
                        style: ButtonStyle(
                          backgroundColor: _canProceed ? MaterialStateProperty.all(const Color.fromRGBO(0x25, 0x31, 0x33, 1.0)) : MaterialStateProperty.all(const Color.fromRGBO(0x1C, 0x25, 0x26, 1.0)),
                          padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 35, vertical: 20))
                        ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Tovább',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const Icon(Icons.arrow_forward_rounded, color: Colors.white)
                        ],
                      )
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Page2 extends StatefulWidget{
  const Page2({super.key});

  @override
  State<Page2> createState() => _Page2State();
}
class _Page2State extends State<Page2>{

  late String _username;
  late String _password;

  late TextEditingController _usernameController;
  late TextEditingController _passwordController;

  bool _obscureText = true;
  bool _canProceed = false;
  bool _canGoBack = true;

  bool _isLoading = false;

  bool _paintRed = false;

  Timer? _loadingTimer;

  @override
  void initState(){
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color.fromRGBO(0x17, 0x17, 0x17, 1.0), // navigation bar color
      statusBarColor: Color.fromRGBO(0x17, 0x17, 0x17, 1.0), // status bar color
    ));

    _username = PageDTO.Instance.Username ?? "";
    _password = PageDTO.Instance.Password ?? "";

    _usernameController = TextEditingController(text: _username);
    _passwordController = TextEditingController(text: _password);

    _canProceed = _password.isNotEmpty && _username.isNotEmpty;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void goToPage1(){
    setState(() {
      _dontTriggerPop = true;
    });
    storage.DataCache.setUsername(_username);
    storage.DataCache.setPassword(_password);
    PageDTO.Instance.Username = _username;
    PageDTO.Instance.Password = _password;
    Navigator.pop(context);
  }

  void finishLogin(){
    api.Institute selected = PageDTO.Instance.Institutes![0];
    for(var item in PageDTO.Instance.Institutes!){
      if(item.Name == PageDTO.Instance.Selected!){
        selected = item;
        break;
      }
    }

    setState(() {
      _canProceed = false;
      _canGoBack = false;
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

    api.InstitutesRequest.validateLoginCredentials(selected, _username, _password).then((value)
    {
      if(value){ // logged in
        storage.DataCache.setUsername(_username);
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
      setState(() {
        _paintRed = true;
        _canProceed = true;
        _canGoBack = true;
        _isLoading = false;
        _showNeptunServerError = false;
      });
    });
  }

  void _showSnackbar(BuildContext context, String text, int displayDurationSec){
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.question_mark_rounded,
            size: 24,
            color: Color.fromRGBO(0x4F, 0x69, 0x6E, 1.0),
          ),
          const SizedBox(width: 15),
          Expanded(
              child: Text(
                text,
                textAlign: TextAlign.start,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400
                ),
              )
          )
        ],
      ),
      backgroundColor: const Color.fromRGBO(0x22, 0x22, 0x22, 1.0),
      dismissDirection: DismissDirection.horizontal,
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: displayDurationSec),
    ));
  }

  double _horizontalDrag = 0;
  bool _dragDebounce = false;

  bool _dontTriggerPop = false;
  bool _showNeptunServerError = false;

  @override
  Widget build(BuildContext context){
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
          if(_horizontalDrag >= 50 && !_dragDebounce){
            _horizontalDrag = 0;
            _dragDebounce = true;

            if(!_canGoBack){
              return;
            }

            goToPage1();
          }
          else if(_horizontalDrag <= -50 && !_dragDebounce){
            _horizontalDrag = 0;
            _dragDebounce = true;

            if(!_canProceed){
              return;
            }

            finishLogin();
          }
        },
        child: PopScope(
          onPopInvoked: (_){
            if(_isLoading || _dontTriggerPop){
              return;
            }
            Navigator.pop(context);
          },
          canPop: false,
          child: Stack(
            children: [
              Container(
                color: const Color.fromRGBO(0x17, 0x17, 0x17, 1.0),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                      decelerationRate: ScrollDecelerationRate.fast
                  ),
                  scrollDirection: Axis.vertical,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height + 0.001,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(
                            'Jelentkezz be!',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.80,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                                          PageDTO.Instance.Selected ?? 'NULL',
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
                                ),
                                const SizedBox(height: 30),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.80,
                                  child: TextField(
                                    decoration: InputDecoration(
                                        suffixIcon: Icon(
                                            Icons.person_2_rounded,
                                            color: _paintRed ? Colors.red : Colors.white),
                                        hintText: 'Neptun Kód...',
                                        border: null
                                    ),
                                    controller: _usernameController,
                                    enableSuggestions: false,
                                    autocorrect: false,
                                    style: TextStyle(
                                        color: _paintRed ? const Color.fromRGBO(0xFF, 0xB0, 0xB0, 1.0) : Colors.white
                                    ),
                                    onChanged: (value) {
                                      _username = value;
                                      setState(() {
                                        _canProceed = _password.isNotEmpty && _username.isNotEmpty;
                                        _paintRed = false;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.80,
                                  child: TextField(
                                    decoration: InputDecoration(
                                        suffixIcon: IconButton(
                                            icon: Icon(
                                                _obscureText ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                                color: _paintRed ? Colors.red : Colors.white),
                                            onPressed: () {
                                              setState(() {
                                                _obscureText = !_obscureText; // Toggle the password visibility
                                              });
                                            }),
                                        hintText: 'Jelszó...',
                                        border: null
                                    ),
                                    controller: _passwordController,
                                    obscureText: _obscureText,
                                    enableSuggestions: false,
                                    autocorrect: false,
                                    style: TextStyle(
                                        color: _paintRed ? const Color.fromRGBO(0xFF, 0xB0, 0xB0, 1.0) : Colors.white
                                    ),
                                    onChanged: (value) {
                                      _password = value;
                                      setState(() {
                                        _canProceed = _password.isNotEmpty && _username.isNotEmpty;
                                        _paintRed = false;
                                      });
                                    },
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  width: MediaQuery.of(context).size.width * 0.60,
                                  child: Text(
                                    _paintRed ? "Hibás felhasználónév vagy jelszó!" : "",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: _paintRed ? Colors.red : Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12
                                    ),
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
                                          'Ha van 2 lépcsős azonosítás van a fiókodon, nem fogsz tudni bejelenzkezni!',
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
                                          _showSnackbar(context, 'A Neptun2 a régi Neptun mobilapp API-jait használja, amiben nem volt 2 lépcsős azonosítás. Így, ha a fiókod 2 lépcsős azonosítással van védve, a Neptun2 nem fogja tudni értelmezni ezt.\nViszont ha kikapcsolod, hiba nélkül tudod használni a Neptun2-t.\nKikapcsolni a "Saját Adatok/Beállítások"-ban tudod.', 18);
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
                              ]
                          ),
                          SingleChildScrollView(
                            physics: const BouncingScrollPhysics(decelerationRate: ScrollDecelerationRate.fast),
                            scrollDirection: Axis.horizontal,
                            child: Row(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  ElevatedButton(
                                      onPressed: _canGoBack ? () {
                                        goToPage1();
                                      } : null,
                                      style: ButtonStyle(
                                          backgroundColor: _canGoBack ? MaterialStateProperty.all(const Color.fromRGBO(0x25, 0x31, 0x33, 1.0)) : MaterialStateProperty.all(const Color.fromRGBO(0x1C, 0x25, 0x26, 1.0)),
                                          padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 35, vertical: 20))
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Vissza',
                                            style: Theme.of(context).textTheme.bodyLarge,
                                          ),
                                          const Icon(Icons.arrow_back_rounded, color: Colors.white)
                                        ],
                                      )
                                  ),
                                  const SizedBox(width: 40),
                                  ElevatedButton(
                                      onPressed: _canProceed ? () {
                                        finishLogin();
                                      } : null,
                                      style: ButtonStyle(
                                          backgroundColor: _canProceed ? MaterialStateProperty.all(const Color.fromRGBO(0x25, 0x31, 0x33, 1.0)) : MaterialStateProperty.all(const Color.fromRGBO(0x1C, 0x25, 0x26, 1.0)),
                                          padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 35, vertical: 20))
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Kész',
                                            style: Theme.of(context).textTheme.bodyLarge,
                                          ),
                                          const Icon(Icons.check_rounded, color: Colors.white)
                                        ],
                                      )
                                  ),
                                ]
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                          const Text(
                            'Bejelentkezés...',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 26
                            ),
                          ),
                          const SizedBox(height: 60),
                          Center(
                            child: SizedBox(
                              height: MediaQuery.of(context).size.width < MediaQuery.of(context).size.height ? MediaQuery.of(context).size.width * 0.10 : MediaQuery.of(context).size.height * 0.10,
                              width: MediaQuery.of(context).size.width < MediaQuery.of(context).size.height ? MediaQuery.of(context).size.width * 0.10 : MediaQuery.of(context).size.height * 0.10,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            api.Generic.randomLoadingComment(DataCache.getNeedFamilyFriendlyComments()!),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white.withOpacity(.6),
                                fontWeight: FontWeight.w300,
                                fontSize: 10
                            ),
                          ),
                          const SizedBox(height: 60),
                          Visibility(
                            visible: _showNeptunServerError,
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
                        ],
                      )
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//Data transfer object between the Pages
class PageDTO{
  static late PageDTO Instance;
  late List<api.Institute>? Institutes;
  late String? Selected;
  late String? Username;
  late String? Password;
  PageDTO(List<api.Institute>? institutes, String? selected, String? username, String? password){
    Instance = this;
    Institutes = institutes;
    Selected = selected;
    Username = username;
    Password = password;
  }
}