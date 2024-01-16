import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musicapp/Model/model/record_model.dart';
import 'package:musicapp/firebase_options.dart';
import 'package:musicapp/screens/SignInAndSignUp/splash.dart';
import 'package:musicapp/screens/refactoring/bottom_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: constant_identifier_names
const SAVE_KEY_NAME = 'USER LOGGED IN';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(RecordModelAdapter().typeId)) {
    Hive.registerAdapter(RecordModelAdapter());
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SALUZZY',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: FutureBuilder<bool>(
        future: isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final bool userLoggedIn = snapshot.data ?? false;
            return userLoggedIn ? const BottomNavigation() : const SplashPage();
          } else {
            return const CircularProgressIndicator(
              color: Colors.white,
            );
          }
        },
      ),
    );
  }

  Future<bool> isLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(SAVE_KEY_NAME) ?? false;
  }
}
