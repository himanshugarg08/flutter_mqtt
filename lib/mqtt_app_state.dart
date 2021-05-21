import 'package:flutter/material.dart';

enum MQTTAppConnectionState { connected, connecting, disconnected }

class MQTTAppState with ChangeNotifier {
  MQTTAppConnectionState _appState = MQTTAppConnectionState.disconnected;

  String receivedText = "";
  String historyText = "";

  void setReceivedText(String text) {
    receivedText = text;
    historyText = historyText + '\n' + receivedText;
    notifyListeners();
  }

  void setAppConnectionState(MQTTAppConnectionState state) {
    _appState = state;
    notifyListeners();
  }

  String get getReceivedText => receivedText;
  String get getHistoryText => historyText;
  MQTTAppConnectionState get getAppState => _appState;
}
