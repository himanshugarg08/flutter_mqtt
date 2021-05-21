import 'package:flutter/material.dart';
import 'package:flutter_mqtt/mqtt_app_state.dart';
import 'package:mqtt_client/mqtt_client.dart';

class MQTTManager {
  MQTTAppState currentState;
  MqttClient client;
  String identifier;
  String host;
  String topic;

  MQTTManager({
    @required this.host,
    @required this.topic,
    @required this.identifier,
    @required this.currentState,
  });

  void initializeMQTTClient() {
    client = MqttClient(host, identifier)
      ..port = 1883
      ..keepAlivePeriod = 20
      ..onDisconnected = onDisconnected
      ..logging(on: true)
      ..onConnected = onConnected
      ..onSubscribed = onSubscribed;

    final MqttConnectMessage message = MqttConnectMessage()
      ..withClientIdentifier(identifier)
      ..withWillTopic('willtopic')
      ..withWillMessage('My will Message')
      ..startClean()
      ..withWillQos(MqttQos.atLeastOnce);
    print("Mosquitto Client Connecting...");
    client.connectionMessage = message;
  }

  void connect() async {
    assert(client != null);
    try {
      print("Mosquitto Start Client Connecting...");
      currentState.setAppConnectionState(MQTTAppConnectionState.connecting);
      await client.connect();
    } on Exception catch (e) {
      print("Client exception - $e");
      disconnect();
    }
  }

  void disconnect() {
    print("Disconnect");
    client.disconnect();
  }

  void publish(String msg) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();

    builder.addString(msg);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload);
  }

  void onSubscribed(String topic) {
    print("Subscrption Confirmed for topic $topic");
  }

  void onDisconnected() {
    print("client callback - client disconnection");

    currentState.setAppConnectionState(MQTTAppConnectionState.disconnected);
  }

  void onConnected() {
    currentState.setAppConnectionState(MQTTAppConnectionState.connected);
    print("Mosquitto Client Connected");

    client.subscribe(topic, MqttQos.atLeastOnce);
    client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload;
      final String pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      currentState.setReceivedText(pt);
    });
  }
}
