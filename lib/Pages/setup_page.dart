import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import '../API/api_coms.dart' as api;
import '../storage.dart' as storage;
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
                        PageDTO.Instance.Institutes = _institutes;
                        PageDTO.Instance.Selected = _selectedValue;
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Page2()),
                        );
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

  bool _paintRed = false;

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

  @override
  Widget build(BuildContext context){
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
                              Text(
                                PageDTO.Instance.Selected ?? 'NULL',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(.2),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600
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
                            style: TextStyle(
                              color: _paintRed ? Colors.red : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12
                            ),
                          ),
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
                            onPressed: () {
                              storage.DataCache.setUsername(_username);
                              storage.DataCache.setPassword(_password);
                              PageDTO.Instance.Username = _username;
                              PageDTO.Instance.Password = _password;
                              Navigator.pop(context);
                              /*Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Page1(fetchData: false, DTO: PageDTO(widget.DTO.Institutes, widget.DTO.Selected, _username, _password))),
                              );*/
                            },
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(const Color.fromRGBO(0x25, 0x31, 0x33, 1.0)),
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
                              api.Institute selected = PageDTO.Instance.Institutes![0];
                              for(var item in PageDTO.Instance.Institutes!){
                                if(item.Name == PageDTO.Instance.Selected!){
                                  selected = item;
                                  break;
                                }
                              }

                              setState(() {
                                _canProceed = false;
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
                                });
                              });
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