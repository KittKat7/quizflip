import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kittkatflutterlibrary/theming/kkfl_theming.dart';

import 'pref_storage.dart';

String appVersion = "";

int dataVersion = 202401251632;
String varDataVersion = 'version';
String varTheme = 'theme';
String varDarkMode = 'darkMode';

AppTheme theme = AppTheme();

/// `version` The version the app was last running.\
/// `theme` Is any basic color RED, ORANGE, YELLOW, GREEN, BLUE, PURPLE, or a custom theme name.\
/// `darkMode` Is either FALSE, TRUE, or SYSTEM.\
Map<String, dynamic> get appData => Map<String, dynamic>.from(_appData);

/// `version` The version the app was last running.\
/// `theme` Is any basic color RED, ORANGE, YELLOW, GREEN, BLUE, PURPLE, or a custom theme name.\
/// `darkMode` Is either FALSE, TRUE, or SYSTEM.\
Map<String, dynamic> _appData = {};

/// `version` The version the app was last running.\
/// `theme` Is any basic color RED, ORANGE, YELLOW, GREEN, BLUE, PURPLE, or a custom theme name.\
/// `darkMode` Is either FALSE, TRUE, or SYSTEM.\
final Map<String, dynamic> _defaultAppData = {
  varDataVersion: dataVersion,
  varTheme: 'RED',
  varDarkMode: 'SYSTEM',
};

/// Loads the app data from the data stored in shared preferences. If there is no existing app data,
/// or the existing data is corrupt, [_appData] will be set to the default values in
/// [_defaultAppData], and then these values will be saved to shared preferences for next time the
/// data is loaded.
void loadAppData() {
  Map<String, dynamic> appData;
  // Get the previously stored app data. If it is null, use the default app data.
  String? appDataStr = prefs.getString('appdata');
  if (appDataStr == null) {
    appData = Map<String, dynamic>.from(_defaultAppData);
  } else {
    appData = json.decode(appDataStr);
  } //if/else

  // Try to load all the data into _appData. If an exception is thrown, use the default app data.
  try {
    _appData = {
      varDataVersion:
          appData[varDataVersion] ?? _defaultAppData[varDataVersion],
      varTheme: appData[varTheme] ?? _defaultAppData[varTheme],
      varDarkMode: appData[varDarkMode] ?? _defaultAppData[varDarkMode],
    };
  } catch (e) {
    _appData = Map.from(_defaultAppData);
  } //try/catch

  // TODO version mismatch code?

  // Save the app data. This is useful if this is the first time the app has run, or if the previous
  // app data was corupt, and this was loaded from defaults. If that was the case, this will
  // overwrite the corrupt data with new clean data.
  saveAppData();

  switch (_appData[varTheme]) {
    case 'RED':
      theme.setColor(Colors.red);
      break;
    case 'GREEN':
      theme.setColor(Colors.green);
      break;
    case 'BLUE':
      theme.setColor(Colors.blue);
      break;
    case 'CYAN':
      theme.setColor(Colors.cyan);
      break;
  }

  switch (_appData[varDarkMode]) {
    case 'FALSE':
      theme.setLightMode();
    case 'TRUE':
      theme.setDarkMode();
    case 'SYSTEM':
      theme.setSystemMode();
  }
} //loadAppData

void saveAppData() {
  prefs.setString('appdata', json.encode(_appData));
}

void cycleThemeColor() {
  switch (_appData[varTheme]) {
    case 'RED':
      _appData[varTheme] = 'GREEN';
      theme.setColor(Colors.green);
      break;
    case 'GREEN':
      _appData[varTheme] = 'BLUE';
      theme.setColor(Colors.blue);
      break;
    case 'BLUE':
      _appData[varTheme] = 'CYAN';
      theme.setColor(Colors.cyan);
      break;
    case 'CYAN':
      _appData[varTheme] = 'RED';
      theme.setColor(Colors.red);
      break;
  }
  saveAppData();
}

void cycleThemeMode() {
  switch (_appData[varDarkMode]) {
    case 'FALSE':
      _appData[varDarkMode] = 'TRUE';
      theme.setDarkMode();
    case 'TRUE':
      _appData[varDarkMode] = 'SYSTEM';
      theme.setSystemMode();
    case 'SYSTEM':
      _appData[varDarkMode] = 'FALSE';
      theme.setLightMode();
  }
  saveAppData();
}
