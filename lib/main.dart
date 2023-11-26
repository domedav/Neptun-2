import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'Pages/startup_page.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const NeptunApp());
}

class NeptunApp extends StatelessWidget {
  const NeptunApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neptun 2',
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
            primary: Color.fromRGBO(0x6C, 0x8F, 0x96, 1.0),
            onPrimary: Colors.white,
            onPrimaryContainer: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
            secondary: Color.fromRGBO(0x4F, 0x69, 0x6E, 1.0),
            onSecondary: Color.fromRGBO(0xB6, 0xB6, 0xB6, 1.0),
            onSecondaryContainer: Color.fromRGBO(0x6C, 0x8F, 0x96, 1.0),
        ),
        useMaterial3: true,
      ),
      home:const Splitter(),
      );
  }
}