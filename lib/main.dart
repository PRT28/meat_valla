import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meat_delivery/pages/Base.dart';
import 'package:meat_delivery/pages/Login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    Map<int, Color> getSwatch(Color color) {
      final hslColor = HSLColor.fromColor(color);
      final lightness = hslColor.lightness;
      const lowDivisor = 6;
      const highDivisor = 5;

      final lowStep = (1.0 - lightness) / lowDivisor;
      final highStep = lightness / highDivisor;

      return {
        50: (hslColor.withLightness(lightness + (lowStep * 5))).toColor(),
        100: (hslColor.withLightness(lightness + (lowStep * 4))).toColor(),
        200: (hslColor.withLightness(lightness + (lowStep * 3))).toColor(),
        300: (hslColor.withLightness(lightness + (lowStep * 2))).toColor(),
        400: (hslColor.withLightness(lightness + lowStep)).toColor(),
        500: (hslColor.withLightness(lightness)).toColor(),
        600: (hslColor.withLightness(lightness - highStep)).toColor(),
        700: (hslColor.withLightness(lightness - (highStep * 2))).toColor(),
        800: (hslColor.withLightness(lightness - (highStep * 3))).toColor(),
        900: (hslColor.withLightness(lightness - (highStep * 4))).toColor(),
      };
    }


    return MaterialApp(
      title: "Meat Wala",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF850E35)),
        primarySwatch: MaterialColor(0xFF850E35, getSwatch(Color(0xFF850E35))),
        focusColor: Color(0xFF850E35),
        fontFamily: "Poppins",
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFF850E35),
          selectionColor: Color(0xFF850E35),
          selectionHandleColor: Color(0xFF850E35),
        ),
      ),
      home: AuthStateWidget(),
    );
  }
}

class AuthStateWidget extends StatefulWidget {
  @override
  _AuthStateWidgetState createState() => _AuthStateWidgetState();
}

class _AuthStateWidgetState extends State<AuthStateWidget> {
  User? _user;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Login();
    } else {
      return const Base();
    }
  }
}
