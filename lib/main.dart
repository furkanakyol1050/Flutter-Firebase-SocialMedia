//* Flutter Kütüphanesi
import 'package:flutter/material.dart';
//* Yardimci Kütüphaneler
import 'package:flutter_riverpod/flutter_riverpod.dart';
//* Firebase Kütüphanesi
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:smproject3/screens/home/pages/pagechat.dart';
import 'package:smproject3/screens/home/pages/pageselectedprofile.dart';
import 'package:smproject3/screens/home/pages/pageupdateprofile.dart';
import 'firebase_options.dart';
//* Dosya Uzantilari
import 'package:smproject3/screens/entry/pages/pagereset.dart';
import 'package:smproject3/screens/entry/pages/pageregister.dart';
import 'package:smproject3/screens/entry/widgets.dart';
import 'screens/home/pages/pagesinglepostview.dart';

void main() async {
  initializeDateFormatting('tr', null);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    precacheImage(const AssetImage("assets/bg1.png"), context);
    precacheImage(const AssetImage("assets/bg2.png"), context);
    precacheImage(const AssetImage("assets/bg3.png"), context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: const ScrollBehavior(),
      theme: ThemeData(
        useMaterial3: false,
        snackBarTheme: const SnackBarThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
        ),
      ),
      routes: {
        '/': (context) => check(context),
        '/register': (context) => RegisterPage(),
        '/reset': (context) => PasswordResPage(),
        '/postview': (context) => SinglePostView(),
        '/selecteduser': (context) => const SelectedProfile(),
        '/chat': (context) => const ChatWidget(),
        '/update': (context) => UpdatePage(),
      },
    );
  }
}
