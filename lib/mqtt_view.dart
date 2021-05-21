import 'package:flutter/material.dart';
import 'package:flutter_mqtt/mqtt_app_state.dart';
import 'package:flutter_mqtt/mqtt_manager.dart';
import 'package:provider/provider.dart';

class MQTTView extends StatefulWidget {
  @override
  _MQTTViewState createState() => _MQTTViewState();
}

class _MQTTViewState extends State<MQTTView> {
  final TextEditingController hostController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final TextEditingController topicController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  MQTTAppState currentAppState;
  MQTTManager manager;

  @override
  void dispose() {
    hostController.dispose();
    messageController.dispose();
    topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MQTTAppState>(context);
    currentAppState = appState;
    return Scaffold(
      appBar: AppBar(
        title: Text("MQTT"),
      ),
      body: SingleChildScrollView(child: buildColumn()),
    );
  }

  Widget buildColumn() {
    return Column(
      children: [
        _buildConnectionStateText(
            prepareStateMessageFrom(currentAppState.getAppState)),
        _buildEditableColumn(),
        _buildScrollableTextWith(currentAppState.getHistoryText),
      ],
    );
  }

  Widget _buildEditableColumn() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          _buildTextFieldWith(hostController, 'Enter broker address',
              currentAppState.getAppState),
          const SizedBox(height: 10),
          _buildTextFieldWith(
              nameController, 'Enter Name', currentAppState.getAppState),
          const SizedBox(height: 10),
          _buildTextFieldWith(
              topicController,
              'Enter a topic to subscribe or listen',
              currentAppState.getAppState),
          const SizedBox(height: 10),
          _buildPublishMessageRow(),
          const SizedBox(height: 10),
          _buildConnecteButtonFrom(currentAppState.getAppState)
        ],
      ),
    );
  }

  Widget _buildPublishMessageRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          child: _buildTextFieldWith(messageController, 'Enter a message',
              currentAppState.getAppState),
        ),
        _buildSendButtonFrom(currentAppState.getAppState)
      ],
    );
  }

  Widget _buildConnectionStateText(String status) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
              color: Colors.deepOrangeAccent,
              child: Text(
                status,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              )),
        ),
      ],
    );
  }

  Widget _buildTextFieldWith(TextEditingController controller, String hintText,
      MQTTAppConnectionState state) {
    bool shouldEnable = false;
    if (controller == messageController &&
        state == MQTTAppConnectionState.connected) {
      shouldEnable = true;
    } else if ((controller == hostController &&
            state == MQTTAppConnectionState.disconnected) ||
        (controller == topicController &&
            state == MQTTAppConnectionState.disconnected) ||
        (controller == nameController &&
            state == MQTTAppConnectionState.disconnected)) {
      shouldEnable = true;
    }
    return TextField(
        enabled: shouldEnable,
        controller: controller,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.only(left: 0, bottom: 0, top: 0, right: 0),
          labelText: hintText,
        ));
  }

  Widget _buildScrollableTextWith(String text) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        width: 400,
        height: 200,
        child: SingleChildScrollView(
          child: Text(text),
        ),
      ),
    );
  }

  Widget _buildConnecteButtonFrom(MQTTAppConnectionState state) {
    return Row(
      children: <Widget>[
        Expanded(
          child: ElevatedButton(
            //color: Colors.lightBlueAccent,
            child: const Text('Connect'),
            onPressed: state == MQTTAppConnectionState.disconnected
                ? _configureAndConnect
                : null, //
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            //color: Colors.redAccent,
            child: const Text('Disconnect'),
            onPressed: state == MQTTAppConnectionState.connected
                ? _disconnect
                : null, //
          ),
        ),
      ],
    );
  }

  Widget _buildSendButtonFrom(MQTTAppConnectionState state) {
    return ElevatedButton(
      //color: Colors.green,
      child: const Text('Send'),
      onPressed: state == MQTTAppConnectionState.connected
          ? () {
              _publishMessage(messageController.text);
            }
          : null, //
    );
  }

  // Utility functions
  String prepareStateMessageFrom(MQTTAppConnectionState state) {
    switch (state) {
      case MQTTAppConnectionState.connected:
        return 'Connected';
      case MQTTAppConnectionState.connecting:
        return 'Connecting';
      case MQTTAppConnectionState.disconnected:
        return 'Disconnected';
      default:
        return "Waiting";
    }
  }

  void _configureAndConnect() {
    manager = MQTTManager(
        host: hostController.text,
        topic: topicController.text,
        identifier: nameController.text,
        currentState: currentAppState);
    manager.initializeMQTTClient();
    manager.connect();
  }

  void _disconnect() {
    manager.disconnect();
  }

  void _publishMessage(String text) {
    final String message = nameController.text + ' says: ' + text;
    manager.publish(message);
    messageController.clear();
  }
}
