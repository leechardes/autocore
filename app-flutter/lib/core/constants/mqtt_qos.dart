import 'package:mqtt_client/mqtt_client.dart';

class MqttQosLevels {
  // QoS 0 - Fire and forget (telemetria, heartbeat)
  static const MqttQos telemetry = MqttQos.atMostOnce;
  static const MqttQos heartbeat = MqttQos.atMostOnce;

  // QoS 1 - At least once (comandos, eventos)
  static const MqttQos commands = MqttQos.atLeastOnce;
  static const MqttQos events = MqttQos.atLeastOnce;

  // QoS 2 - Exactly once (crítico - não usado atualmente)
  static const MqttQos critical = MqttQos.exactlyOnce;

  static MqttQos getQosForTopic(String topic) {
    if (topic.contains('/telemetry/') || topic.contains('/heartbeat')) {
      return telemetry;
    } else if (topic.contains('/relays/set') || topic.contains('/preset')) {
      return commands;
    } else if (topic.contains('/safety') || topic.contains('/emergency')) {
      return events;
    }
    return MqttQos.atLeastOnce; // default
  }
}
