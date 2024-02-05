
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences _prefs;

SharedPreferences get prefs => _prefs;

Future<void> initializePrefs() async {
  SharedPreferences.setPrefix('quizflip-');
  _prefs = await SharedPreferences.getInstance();
}//initializePrefs

