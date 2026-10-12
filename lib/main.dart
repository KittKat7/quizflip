import 'package:flutter/material.dart';
import 'package:kittkatflutterlibrary/kittkatflutterlibrary.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '/models/fileio.dart';
import 'lang/en_us.dart' as en_us;
import 'models/cardlist.dart';
import 'pages/home_page.dart';

late PackageInfo packageInfo;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setLangMap(en_us.en_us);
  AppTheme appTheme = AppTheme();
  Aspect.aspectWidth = 3;
  Aspect.aspectHeight = 4;
  await initializeFileStorage();
  packageInfo = await PackageInfo.fromPlatform();
  CardList.getMaster().addCards(loadFlashcards());
  runApp(ThemedWidget(widget: MyApp(), theme: appTheme));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      title: getLang('titleApp'),
      theme: appTheme.getThemeDataLight(context),
      darkTheme: appTheme.getThemeDataDark(context),
      themeMode: appTheme.getThemeMode(context),
      home: HomePage(version: packageInfo.version),
    );
  }
}
