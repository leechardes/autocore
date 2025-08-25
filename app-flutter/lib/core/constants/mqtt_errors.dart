enum MqttErrorCode {
  mqtt001('Connection failed'),
  mqtt002('Subscribe failed'),
  mqtt003('Publish timeout'),
  mqtt004('Invalid message format'),
  mqtt005('Heartbeat timeout'),
  mqtt006('Device offline'),
  mqtt007('Permission denied'),
  mqtt008('Invalid command');

  final String description;
  const MqttErrorCode(this.description);

  String get code => name;
}
