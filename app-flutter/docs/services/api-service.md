# 🔗 AutoCore Flutter - Integração com Backend

## 🎯 Visão Geral

Este documento detalha a integração entre o app Flutter **execution-only** e o backend do AutoCore, incluindo mapeamento de modelos (read-only), comunicação MQTT para execução e estados, sistema de heartbeat para botões momentâneos, e cache offline. O app Flutter **NÃO** faz configuração ou edição - apenas executa comandos e recebe estados.

### Arquitetura de Comunicação (Execution-Only)

```
┌─────────────────┐    MQTT     ┌─────────────────┐    HTTP GET   ┌─────────────────┐
│                 │ ◄─────────► │                 │ ◄───────────► │                 │
│  Flutter App    │  Heartbeat  │  MQTT Broker    │               │  Backend API    │
│ (Execution Only)│   500ms     │  (Mosquitto)    │               │  (FastAPI)      │
└─────────────────┘             └─────────────────┘               └─────────────────┘
         │                               │                                 │
         │                               │                                 │
         ▼                               ▼                                 ▼
┌─────────────────┐             ┌─────────────────┐               ┌─────────────────┐
│  Local Cache    │             │  Message Queue  │               │   Database      │
│  (Read-Only)    │             │   (Redis)       │               │  (Read-Only)    │
└─────────────────┘             └─────────────────┘               └─────────────────┘
```

**Responsabilidades do Flutter App**:
- ✅ **EXECUTA** comandos via MQTT (relés, macros)
- ✅ **RECEBE** estados via MQTT (read-only)
- ✅ **ENVIA** heartbeats para botões momentâneos
- ✅ **CACHEIA** configurações para offline
- ❌ **NÃO** cria, edita ou deleta configurações
- ❌ **NÃO** faz CRUD operations

---

## 🎯 SISTEMA DE HEARTBEAT PARA BOTÕES MOMENTÂNEOS

### Conceito e Importância

Botões momentâneos (buzina, guincho, lampejo) devem permanecer ativos apenas enquanto pressionados. O sistema de heartbeat garante segurança, desligando automaticamente em caso de:
- Perda de conexão de rede
- Travamento do aplicativo  
- Fechamento inesperado do app
- Falha no cliente MQTT

### Implementação no Flutter

```dart
class HeartbeatService {
  static const Duration HEARTBEAT_INTERVAL = Duration(milliseconds: 500);
  static const int TIMEOUT_MS = 1000; // ESP32 desliga após 1s sem heartbeat
  
  final Map<int, Timer?> _activeHeartbeats = {};
  final MqttService _mqtt;
  String? _deviceUuid;
  
  HeartbeatService(this._mqtt);
  
  /// Inicia heartbeat para botão momentâneo
  void startHeartbeat(int channel, String deviceUuid) {
    _deviceUuid = deviceUuid;
    
    // Envia comando inicial de ON
    _mqtt.publish(
      'autocore/devices/$deviceUuid/relays/set',
      jsonEncode({
        'channel': channel,
        'state': true,
        'function_type': 'momentary',
        'momentary': true,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );
    
    // Inicia timer de heartbeat
    int sequence = 0;
    _activeHeartbeats[channel] = Timer.periodic(
      HEARTBEAT_INTERVAL,
      (_) {
        sequence++;
        _mqtt.publish(
          'autocore/devices/$deviceUuid/relays/heartbeat',
          jsonEncode({
            'channel': channel,
            'sequence': sequence,
            'timestamp': DateTime.now().toIso8601String(),
          }),
        );
        AppLogger.debug('Heartbeat sent: ch$channel seq$sequence');
      },
    );
    
    AppLogger.info('Heartbeat started for channel $channel');
  }
  
  /// Para heartbeat e envia comando OFF
  void stopHeartbeat(int channel) {
    // Cancela timer
    _activeHeartbeats[channel]?.cancel();
    _activeHeartbeats.remove(channel);
    
    // Envia comando OFF
    if (_deviceUuid != null) {
      _mqtt.publish(
        'autocore/devices/$_deviceUuid/relays/set',
        jsonEncode({
          'channel': channel,
          'state': false,
          'function_type': 'momentary',
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
    }
    
    AppLogger.info('Heartbeat stopped for channel $channel');
  }
  
  /// Para todos os heartbeats (cleanup)
  void stopAll() {
    for (final channel in _activeHeartbeats.keys.toList()) {
      stopHeartbeat(channel);
    }
  }
  
  /// Verifica se heartbeat está ativo
  bool isActive(int channel) => _activeHeartbeats.containsKey(channel);
}
```

### Widget de Botão Momentâneo

```dart
class MomentaryButton extends StatefulWidget {
  final int channel;
  final String deviceUuid;
  final String label;
  final IconData icon;
  final VoidCallback? onStateChanged;
  
  const MomentaryButton({
    Key? key,
    required this.channel,
    required this.deviceUuid,
    required this.label,
    required this.icon,
    this.onStateChanged,
  }) : super(key: key);
  
  @override
  State<MomentaryButton> createState() => _MomentaryButtonState();
}

class _MomentaryButtonState extends State<MomentaryButton> {
  final HeartbeatService _heartbeat = GetIt.I<HeartbeatService>();
  bool _isPressed = false;
  
  void _onPressStart() {
    setState(() => _isPressed = true);
    _heartbeat.startHeartbeat(widget.channel, widget.deviceUuid);
    HapticFeedback.lightImpact();
    widget.onStateChanged?.call();
  }
  
  void _onPressEnd() {
    setState(() => _isPressed = false);
    _heartbeat.stopHeartbeat(widget.channel);
    HapticFeedback.lightImpact();
    widget.onStateChanged?.call();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = context.acTheme;
    
    return GestureDetector(
      // Mouse events (desktop)
      onTapDown: (_) => _onPressStart(),
      onTapUp: (_) => _onPressEnd(),
      onTapCancel: () => _onPressEnd(),
      
      // Touch events (mobile)
      onLongPressStart: (_) => _onPressStart(),
      onLongPressEnd: (_) => _onPressEnd(),
      
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        decoration: BoxDecoration(
          color: _isPressed 
            ? theme.successColor
            : theme.surfaceColor,
          borderRadius: BorderRadius.circular(theme.borderRadiusMedium),
          boxShadow: _isPressed
            ? theme.depressedShadow
            : theme.elevatedShadow,
        ),
        padding: EdgeInsets.all(theme.spacingMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.icon,
              color: _isPressed ? Colors.white : theme.textPrimary,
              size: 32,
            ),
            SizedBox(height: theme.spacingXs),
            Text(
              widget.label,
              style: TextStyle(
                color: _isPressed ? Colors.white : theme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_isPressed) ...[
              SizedBox(height: theme.spacingXs),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'ATIVO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    // Garante que heartbeat seja parado se widget for destruído
    if (_isPressed) {
      _heartbeat.stopHeartbeat(widget.channel);
    }
    super.dispose();
  }
}
```

### Tópicos MQTT para Heartbeat

```
# Comando inicial/final
autocore/devices/{uuid}/relays/set
{
  "channel": 1,
  "state": true/false,
  "function_type": "momentary",
  "momentary": true,
  "timestamp": "2025-01-09T10:30:00Z"
}

# Heartbeat contínuo (cada 500ms)
autocore/devices/{uuid}/relays/heartbeat
{
  "channel": 1,
  "sequence": 42,
  "timestamp": "2025-01-09T10:30:00.500Z"
}

# Evento de safety shutoff (do ESP32)
autocore/telemetry/{uuid}/safety
{
  "event": "safety_shutoff",
  "channel": 1,
  "reason": "heartbeat_timeout",
  "timeout_ms": 1000,
  "last_heartbeat": "2025-01-09T10:30:00.500Z"
}
```

### Parâmetros de Segurança

| Parâmetro | Valor | Descrição |
|-----------|-------|-----------|
| `HEARTBEAT_INTERVAL` | 500ms | Frequência de envio do heartbeat |
| `HEARTBEAT_TIMEOUT` | 1000ms | Tempo máximo sem heartbeat antes do ESP32 desligar |
| `RETRY_COUNT` | 3 | Tentativas antes de considerar falha |
| `HAPTIC_FEEDBACK` | true | Vibração ao pressionar/soltar |

---

## 📊 MAPEAMENTO DE MODELOS

### Device - Dispositivo

**Backend Model** (`database/src/models/models.py`):
```python
class Device(Base):
    __tablename__ = 'devices'
    
    id = Column(Integer, primary_key=True)
    uuid = Column(String(36), unique=True, nullable=False)
    name = Column(String(100), nullable=False)
    type = Column(String(50), nullable=False)
    mac_address = Column(String(17), unique=True, nullable=True)
    ip_address = Column(String(15), nullable=True)
    firmware_version = Column(String(20), nullable=True)
    hardware_version = Column(String(20), nullable=True)
    status = Column(String(20), default='offline')
    last_seen = Column(DateTime, nullable=True)
    configuration_json = Column(Text, nullable=True)
    capabilities_json = Column(Text, nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())
```

**Flutter Model**:
```dart
@freezed
class DeviceModel with _$DeviceModel {
  const factory DeviceModel({
    required int id,
    required String uuid,
    required String name,
    required DeviceType type,
    String? macAddress,
    String? ipAddress,
    String? firmwareVersion,
    String? hardwareVersion,
    required DeviceStatus status,
    DateTime? lastSeen,
    Map<String, dynamic>? configuration,
    List<String>? capabilities,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    
    // Campos calculados
    @Default(false) bool isOnline,
    @Default(0) int signalStrength,
    Duration? uptime,
    
    // Relacionamentos
    @Default([]) List<RelayBoardModel> relayBoards,
    @Default([]) List<TelemetryDataModel> telemetryData,
  }) = _DeviceModel;

  factory DeviceModel.fromJson(Map<String, dynamic> json) =>
      _$DeviceModelFromJson(json);
      
  factory DeviceModel.fromBackend(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'],
      uuid: json['uuid'],
      name: json['name'],
      type: DeviceType.fromString(json['type']),
      macAddress: json['mac_address'],
      ipAddress: json['ip_address'],
      firmwareVersion: json['firmware_version'],
      hardwareVersion: json['hardware_version'],
      status: DeviceStatus.fromString(json['status']),
      lastSeen: json['last_seen'] != null 
          ? DateTime.parse(json['last_seen']) 
          : null,
      configuration: json['configuration_json'] != null 
          ? jsonDecode(json['configuration_json'])
          : null,
      capabilities: json['capabilities_json'] != null 
          ? List<String>.from(jsonDecode(json['capabilities_json']))
          : null,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      
      // Calculados
      isOnline: json['status'] == 'online',
      signalStrength: _calculateSignalStrength(json),
      uptime: _calculateUptime(json),
    );
  }
  
  // toBackend() removido - Flutter app é read-only
  // Toda configuração é feita no Config-App web
}

enum DeviceType {
  esp32Relay('esp32_relay'),
  esp32Display('esp32_display'),
  esp32Controls('esp32_controls'),
  esp32Can('esp32_can'),
  raspberry('raspberry_pi'),
  gateway('gateway');

  const DeviceType(this.value);
  final String value;
  
  static DeviceType fromString(String value) {
    return DeviceType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => DeviceType.esp32Relay,
    );
  }
}

enum DeviceStatus {
  online('online'),
  offline('offline'),
  connecting('connecting'),
  error('error'),
  updating('updating');

  const DeviceStatus(this.value);
  final String value;
  
  static DeviceStatus fromString(String value) {
    return DeviceStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => DeviceStatus.offline,
    );
  }
}
```

### RelayBoard - Placa de Relés

**Backend Model**:
```python
class RelayBoard(Base):
    __tablename__ = 'relay_boards'
    
    id = Column(Integer, primary_key=True)
    device_id = Column(Integer, ForeignKey('devices.id', ondelete='CASCADE'), nullable=False)
    total_channels = Column(Integer, default=16, nullable=False)
    board_model = Column(String(50), nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=func.now())
```

**Flutter Model**:
```dart
@freezed
class RelayBoardModel with _$RelayBoardModel {
  const factory RelayBoardModel({
    required int id,
    required int deviceId,
    required int totalChannels,
    String? boardModel,
    required bool isActive,
    required DateTime createdAt,
    
    // Relacionamentos
    @Default([]) List<RelayChannelModel> channels,
    
    // Estado em tempo real
    @Default({}) Map<int, bool> channelStates,
    DateTime? lastUpdate,
  }) = _RelayBoardModel;

  factory RelayBoardModel.fromJson(Map<String, dynamic> json) =>
      _$RelayBoardModelFromJson(json);
      
  factory RelayBoardModel.fromBackend(Map<String, dynamic> json) {
    return RelayBoardModel(
      id: json['id'],
      deviceId: json['device_id'],
      totalChannels: json['total_channels'] ?? 16,
      boardModel: json['board_model'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      channels: (json['channels'] as List?)
          ?.map((ch) => RelayChannelModel.fromBackend(ch))
          .toList() ?? [],
    );
  }
  
  Map<String, dynamic> toBackend() {
    return {
      'id': id,
      'device_id': deviceId,
      'total_channels': totalChannels,
      'board_model': boardModel,
      'is_active': isActive,
    };
  }
}
```

### RelayChannel - Canal de Relé

**Backend Model**:
```python
class RelayChannel(Base):
    __tablename__ = 'relay_channels'
    
    id = Column(Integer, primary_key=True)
    board_id = Column(Integer, ForeignKey('relay_boards.id', ondelete='CASCADE'), nullable=False)
    channel_number = Column(Integer, nullable=False)
    name = Column(String(100), nullable=False)
    description = Column(Text, nullable=True)
    function_type = Column(String(50), nullable=True)
    icon = Column(String(50), nullable=True)
    color = Column(String(7), nullable=True)
    protection_mode = Column(String(20), nullable=True)
    max_activation_time = Column(Integer, nullable=True)
    allow_in_macro = Column(Boolean, default=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())
```

**Flutter Model**:
```dart
@freezed
class RelayChannelModel with _$RelayChannelModel {
  const factory RelayChannelModel({
    required int id,
    required int boardId,
    required int channelNumber,
    required String name,
    String? description,
    required RelayFunctionType functionType,
    String? icon,
    String? color,
    required RelayProtectionMode protectionMode,
    int? maxActivationTime,
    required bool allowInMacro,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    
    // Estado em tempo real
    @Default(false) bool currentState,
    DateTime? lastStateChange,
    DateTime? lastActivation,
    int? activationCount,
    
    // Configuração de UI
    ACControlTileStyle? tileStyle,
    ACButtonSize? buttonSize,
  }) = _RelayChannelModel;

  factory RelayChannelModel.fromJson(Map<String, dynamic> json) =>
      _$RelayChannelModelFromJson(json);
      
  factory RelayChannelModel.fromBackend(Map<String, dynamic> json) {
    return RelayChannelModel(
      id: json['id'],
      boardId: json['board_id'],
      channelNumber: json['channel_number'],
      name: json['name'],
      description: json['description'],
      functionType: RelayFunctionType.fromString(json['function_type'] ?? 'toggle'),
      icon: json['icon'],
      color: json['color'],
      protectionMode: RelayProtectionMode.fromString(json['protection_mode'] ?? 'none'),
      maxActivationTime: json['max_activation_time'],
      allowInMacro: json['allow_in_macro'] ?? true,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  
  Map<String, dynamic> toBackend() {
    return {
      'id': id,
      'board_id': boardId,
      'channel_number': channelNumber,
      'name': name,
      'description': description,
      'function_type': functionType.value,
      'icon': icon,
      'color': color,
      'protection_mode': protectionMode.value,
      'max_activation_time': maxActivationTime,
      'allow_in_macro': allowInMacro,
      'is_active': isActive,
    };
  }
  
  // Métodos utilitários
  IconData get iconData {
    return IconHelper.fromString(icon) ?? Icons.electrical_services;
  }
  
  Color get colorData {
    return ColorHelper.fromString(color) ?? Colors.blue;
  }
  
  bool get needsConfirmation {
    return protectionMode == RelayProtectionMode.confirm ||
           protectionMode == RelayProtectionMode.password;
  }
}

enum RelayFunctionType {
  toggle('toggle'),
  momentary('momentary'),
  pulse('pulse'),
  dimmer('dimmer');

  const RelayFunctionType(this.value);
  final String value;
  
  static RelayFunctionType fromString(String value) {
    return RelayFunctionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => RelayFunctionType.toggle,
    );
  }
}

enum RelayProtectionMode {
  none('none'),
  confirm('confirm'),
  password('password');

  const RelayProtectionMode(this.value);
  final String value;
  
  static RelayProtectionMode fromString(String value) {
    return RelayProtectionMode.values.firstWhere(
      (mode) => mode.value == value,
      orElse: () => RelayProtectionMode.none,
    );
  }
}
```

### Screen - Configuração de Telas

**Backend Model**:
```python
class Screen(Base):
    __tablename__ = 'screens'
    
    id = Column(Integer, primary_key=True)
    name = Column(String(100), nullable=False)
    title = Column(String(100), nullable=False)
    icon = Column(String(50), nullable=True)
    screen_type = Column(String(50), nullable=True)
    parent_id = Column(Integer, ForeignKey('screens.id'), nullable=True)
    position = Column(Integer, default=0, nullable=False)
    
    columns_mobile = Column(Integer, default=2)
    columns_display_small = Column(Integer, default=2)
    columns_display_large = Column(Integer, default=4)
    columns_web = Column(Integer, default=4)
    
    is_visible = Column(Boolean, default=True)
    required_permission = Column(String(50), nullable=True)
    
    show_on_mobile = Column(Boolean, default=True)
    show_on_display_small = Column(Boolean, default=True)
    show_on_display_large = Column(Boolean, default=True)
    show_on_web = Column(Boolean, default=True)
    show_on_controls = Column(Boolean, default=False)
    
    created_at = Column(DateTime, default=func.now())
```

**Flutter Model**:
```dart
@freezed
class ScreenConfigModel with _$ScreenConfigModel {
  const factory ScreenConfigModel({
    required int id,
    required String name,
    required String title,
    String? icon,
    required ScreenType screenType,
    int? parentId,
    required int position,
    
    // Layout por dispositivo
    required int columnsMobile,
    required int columnsDisplaySmall,
    required int columnsDisplayLarge,
    required int columnsWeb,
    
    // Visibilidade
    required bool isVisible,
    String? requiredPermission,
    
    // Visibilidade por dispositivo
    required bool showOnMobile,
    required bool showOnDisplaySmall,
    required bool showOnDisplayLarge,
    required bool showOnWeb,
    required bool showOnControls,
    
    required DateTime createdAt,
    
    // Relacionamentos
    @Default([]) List<ScreenItemModel> items,
    @Default([]) List<ScreenConfigModel> children,
    
    // Configuração de layout
    ScreenLayoutConfig? layoutConfig,
  }) = _ScreenConfigModel;

  factory ScreenConfigModel.fromJson(Map<String, dynamic> json) =>
      _$ScreenConfigModelFromJson(json);
      
  factory ScreenConfigModel.fromBackend(Map<String, dynamic> json) {
    return ScreenConfigModel(
      id: json['id'],
      name: json['name'],
      title: json['title'],
      icon: json['icon'],
      screenType: ScreenType.fromString(json['screen_type'] ?? 'control'),
      parentId: json['parent_id'],
      position: json['position'] ?? 0,
      
      columnsMobile: json['columns_mobile'] ?? 2,
      columnsDisplaySmall: json['columns_display_small'] ?? 2,
      columnsDisplayLarge: json['columns_display_large'] ?? 4,
      columnsWeb: json['columns_web'] ?? 4,
      
      isVisible: json['is_visible'] ?? true,
      requiredPermission: json['required_permission'],
      
      showOnMobile: json['show_on_mobile'] ?? true,
      showOnDisplaySmall: json['show_on_display_small'] ?? true,
      showOnDisplayLarge: json['show_on_display_large'] ?? true,
      showOnWeb: json['show_on_web'] ?? true,
      showOnControls: json['show_on_controls'] ?? false,
      
      createdAt: DateTime.parse(json['created_at']),
      
      items: (json['items'] as List?)
          ?.map((item) => ScreenItemModel.fromBackend(item))
          .toList() ?? [],
    );
  }
  
  Map<String, dynamic> toBackend() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'icon': icon,
      'screen_type': screenType.value,
      'parent_id': parentId,
      'position': position,
      
      'columns_mobile': columnsMobile,
      'columns_display_small': columnsDisplaySmall,
      'columns_display_large': columnsDisplayLarge,
      'columns_web': columnsWeb,
      
      'is_visible': isVisible,
      'required_permission': requiredPermission,
      
      'show_on_mobile': showOnMobile,
      'show_on_display_small': showOnDisplaySmall,
      'show_on_display_large': showOnDisplayLarge,
      'show_on_web': showOnWeb,
      'show_on_controls': showOnControls,
    };
  }
  
  // Método para obter colunas baseado no dispositivo
  int getColumnsForDevice(ACDeviceType deviceType) {
    switch (deviceType) {
      case ACDeviceType.mobile:
        return columnsMobile;
      case ACDeviceType.tablet:
        return columnsDisplaySmall;
      case ACDeviceType.desktop:
        return columnsWeb;
      default:
        return columnsMobile;
    }
  }
  
  // Método para verificar se deve mostrar no dispositivo
  bool shouldShowOnDevice(ACDeviceType deviceType) {
    if (!isVisible) return false;
    
    switch (deviceType) {
      case ACDeviceType.mobile:
        return showOnMobile;
      case ACDeviceType.tablet:
        return showOnDisplaySmall;
      case ACDeviceType.desktop:
        return showOnWeb;
      default:
        return showOnMobile;
    }
  }
}

enum ScreenType {
  dashboard('dashboard'),
  control('control'),
  settings('settings'),
  monitoring('monitoring'),
  macro('macro');

  const ScreenType(this.value);
  final String value;
  
  static ScreenType fromString(String value) {
    return ScreenType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ScreenType.control,
    );
  }
}
```

### Theme - Configuração de Tema

**Backend Model**:
```python
class Theme(Base):
    __tablename__ = 'themes'
    
    id = Column(Integer, primary_key=True)
    name = Column(String(100), nullable=False)
    description = Column(Text, nullable=True)
    theme_data = Column(Text, nullable=False)
    is_default = Column(Boolean, default=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())
```

**Flutter Model**:
```dart
@freezed
class ThemeConfigModel with _$ThemeConfigModel {
  const factory ThemeConfigModel({
    required int id,
    required String name,
    String? description,
    required Map<String, dynamic> themeData,
    required bool isDefault,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    
    // Campos computados
    String? preview,
    List<Color>? colorPalette,
  }) = _ThemeConfigModel;

  factory ThemeConfigModel.fromJson(Map<String, dynamic> json) =>
      _$ThemeConfigModelFromJson(json);
      
  factory ThemeConfigModel.fromBackend(Map<String, dynamic> json) {
    final themeDataJson = jsonDecode(json['theme_data']);
    
    return ThemeConfigModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      themeData: themeDataJson,
      isDefault: json['is_default'] ?? false,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      
      colorPalette: _extractColorPalette(themeDataJson),
    );
  }
  
  Map<String, dynamic> toBackend() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'theme_data': jsonEncode(themeData),
      'is_default': isDefault,
      'is_active': isActive,
    };
  }
  
  // Converter para ACTheme
  ACTheme toACTheme() {
    return ACTheme.fromJson(themeData);
  }
  
  static List<Color> _extractColorPalette(Map<String, dynamic> themeData) {
    final colors = <Color>[];
    
    // Extrair cores principais
    final primaryHex = themeData['primaryColor'] as String?;
    if (primaryHex != null) {
      colors.add(ColorHelper.fromHex(primaryHex));
    }
    
    final secondaryHex = themeData['secondaryColor'] as String?;
    if (secondaryHex != null) {
      colors.add(ColorHelper.fromHex(secondaryHex));
    }
    
    // Extrair cores de estado
    final stateColors = themeData['stateColors'] as Map<String, dynamic>?;
    if (stateColors != null) {
      for (final colorHex in stateColors.values) {
        if (colorHex is String) {
          colors.add(ColorHelper.fromHex(colorHex));
        }
      }
    }
    
    return colors;
  }
}
```

---

## 🔄 COMUNICAÇÃO MQTT

### Estrutura de Tópicos

```dart
class MqttTopics {
  static const String PREFIX = 'autocore';
  
  // === CONFIGURAÇÃO ===
  static const String CONFIG = '$PREFIX/config';
  static const String THEME = '$CONFIG/theme';
  static const String SCREENS = '$CONFIG/screens';
  static const String DEVICES_CONFIG = '$CONFIG/devices';
  
  // === DISPOSITIVOS ===
  static const String DEVICES = '$PREFIX/devices';
  
  // Status de dispositivos
  static String deviceStatus(String deviceId) => '$DEVICES/$deviceId/status';
  static String deviceHeartbeat(String deviceId) => '$DEVICES/$deviceId/heartbeat';
  static String deviceConfig(String deviceId) => '$DEVICES/$deviceId/config';
  
  // Comandos para dispositivos
  static String deviceCommand(String deviceId) => '$DEVICES/$deviceId/cmd';
  static String deviceResponse(String deviceId) => '$DEVICES/$deviceId/response';
  
  // === RELÉS ===
  static const String RELAYS = '$PREFIX/relays';
  
  // Estado dos relés
  static String relayState(String boardId, int channel) => 
      '$RELAYS/$boardId/$channel/state';
  static String relayStates(String boardId) => '$RELAYS/$boardId/states';
  
  // Comandos para relés
  static String relayCommand(String boardId, int channel) => 
      '$RELAYS/$boardId/$channel/cmd';
  static String relayBatchCommand(String boardId) => '$RELAYS/$boardId/batch';
  
  // === TELEMETRIA ===
  static const String TELEMETRY = '$PREFIX/telemetry';
  
  static String deviceTelemetry(String deviceId) => '$TELEMETRY/$deviceId';
  static String systemTelemetry() => '$TELEMETRY/system';
  static String networkTelemetry() => '$TELEMETRY/network';
  
  // === EVENTOS ===
  static const String EVENTS = '$PREFIX/events';
  
  static String deviceEvents(String deviceId) => '$EVENTS/devices/$deviceId';
  static String systemEvents() => '$EVENTS/system';
  static String userEvents() => '$EVENTS/user';
  
  // === LOGS ===
  static const String LOGS = '$PREFIX/logs';
  
  static String errorLogs() => '$LOGS/error';
  static String warningLogs() => '$LOGS/warning';
  static String debugLogs() => '$LOGS/debug';
  
  // === MACROS ===
  static const String MACROS = '$PREFIX/macros';
  
  static String macroExecute(int macroId) => '$MACROS/$macroId/execute';
  static String macroStatus(int macroId) => '$MACROS/$macroId/status';
  static String macroResult(int macroId) => '$MACROS/$macroId/result';
}
```

### Message Handlers

```dart
abstract class MqttMessageHandler {
  String get topicPattern;
  Future<void> handleMessage(String topic, String payload);
}

class DeviceStatusHandler extends MqttMessageHandler {
  final DeviceRepository _deviceRepository;
  
  DeviceStatusHandler(this._deviceRepository);
  
  @override
  String get topicPattern => MqttTopics.deviceStatus('*');
  
  @override
  Future<void> handleMessage(String topic, String payload) async {
    try {
      // Extrair device ID do tópico
      final deviceId = _extractDeviceId(topic);
      
      // Parsear payload
      final data = json.decode(payload);
      
      // Criar modelo de status
      final status = DeviceStatus.fromMqtt(data);
      
      // Atualizar repositório
      await _deviceRepository.updateStatus(deviceId, status);
      
      // Emitir evento para UI
      GetIt.instance<EventBus>().fire(DeviceStatusChangedEvent(
        deviceId: deviceId,
        status: status,
      ));
      
    } catch (e, stackTrace) {
      Logger.error('Erro ao processar status do dispositivo', e, stackTrace);
    }
  }
  
  String _extractDeviceId(String topic) {
    final parts = topic.split('/');
    return parts[2]; // autocore/devices/{deviceId}/status
  }
}

class RelayStateHandler extends MqttMessageHandler {
  final RelayRepository _relayRepository;
  
  RelayStateHandler(this._relayRepository);
  
  @override
  String get topicPattern => MqttTopics.relayState('*', '*');
  
  @override
  Future<void> handleMessage(String topic, String payload) async {
    try {
      final (boardId, channel) = _extractBoardAndChannel(topic);
      
      final data = json.decode(payload);
      final state = RelayState.fromMqtt(data);
      
      await _relayRepository.updateChannelState(boardId, channel, state);
      
      GetIt.instance<EventBus>().fire(RelayStateChangedEvent(
        boardId: boardId,
        channel: channel,
        state: state,
      ));
      
    } catch (e, stackTrace) {
      Logger.error('Erro ao processar estado do relé', e, stackTrace);
    }
  }
  
  (String, int) _extractBoardAndChannel(String topic) {
    final parts = topic.split('/');
    return (parts[2], int.parse(parts[3])); // autocore/relays/{boardId}/{channel}/state
  }
}

class ThemeUpdateHandler extends MqttMessageHandler {
  final ThemeProvider _themeProvider;
  
  ThemeUpdateHandler(this._themeProvider);
  
  @override
  String get topicPattern => MqttTopics.THEME;
  
  @override
  Future<void> handleMessage(String topic, String payload) async {
    try {
      final themeData = json.decode(payload);
      final themeConfig = ThemeConfigModel.fromJson(themeData);
      final acTheme = themeConfig.toACTheme();
      
      await _themeProvider.updateTheme(acTheme, saveToStorage: true);
      
      Logger.info('Tema atualizado via MQTT: ${themeConfig.name}');
      
    } catch (e, stackTrace) {
      Logger.error('Erro ao processar atualização de tema', e, stackTrace);
    }
  }
}

class ConfigurationHandler extends MqttMessageHandler {
  final ConfigService _configService;
  
  ConfigurationHandler(this._configService);
  
  @override
  String get topicPattern => MqttTopics.SCREENS;
  
  @override
  Future<void> handleMessage(String topic, String payload) async {
    try {
      final configData = json.decode(payload);
      
      if (configData is List) {
        // Lista de telas
        final screens = configData
            .map((screenData) => ScreenConfigModel.fromJson(screenData))
            .toList();
            
        await _configService.updateScreens(screens);
      } else {
        // Tela única
        final screen = ScreenConfigModel.fromJson(configData);
        await _configService.updateScreen(screen);
      }
      
      GetIt.instance<EventBus>().fire(ConfigurationUpdatedEvent());
      
    } catch (e, stackTrace) {
      Logger.error('Erro ao processar configuração', e, stackTrace);
    }
  }
}
```

### MQTT Service Implementation

```dart
class MqttService {
  static MqttService? _instance;
  static MqttService get instance => _instance ??= MqttService._internal();
  
  MqttService._internal();
  
  MqttServerClient? _client;
  final Map<String, StreamController<MqttMessage>> _topicControllers = {};
  final Map<String, MqttMessageHandler> _handlers = {};
  final Queue<PendingMessage> _pendingMessages = Queue();
  
  bool _isConnected = false;
  String? _currentBroker;
  int? _currentPort;
  
  final _connectionController = StreamController<MqttConnectionStatus>.broadcast();
  final _messageController = StreamController<MqttMessage>.broadcast();
  
  // Streams públicos
  Stream<MqttConnectionStatus> get connectionStatus => _connectionController.stream;
  Stream<MqttMessage> get messages => _messageController.stream;
  
  Future<void> initialize({
    String broker = 'localhost',
    int port = 1883,
    String clientId = 'autocore_flutter',
  }) async {
    _currentBroker = broker;
    _currentPort = port;
    
    _client = MqttServerClient(broker, clientId);
    _client!.port = port;
    
    // Configurações
    _client!.keepAlivePeriod = 30;
    _client!.connectTimeoutPeriod = 5000;
    _client!.autoReconnect = true;
    _client!.logging(on: true);
    
    // Callbacks
    _client!.onConnected = _onConnected;
    _client!.onDisconnected = _onDisconnected;
    _client!.onAutoReconnect = _onAutoReconnect;
    _client!.onSubscribed = _onSubscribed;
    
    // Registrar handlers
    _registerHandlers();
  }
  
  Future<void> connect() async {
    if (_client == null) {
      throw Exception('MQTT client not initialized');
    }
    
    try {
      _connectionController.add(MqttConnectionStatus.connecting);
      
      final connectionMessage = MqttConnectMessage()
          .withClientIdentifier('autocore_flutter_${DateTime.now().millisecondsSinceEpoch}')
          .withWillTopic('autocore/clients/autocore_flutter/status')
          .withWillMessage('offline')
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);
      
      _client!.connectionMessage = connectionMessage;
      
      await _client!.connect();
      
    } catch (e) {
      Logger.error('Erro ao conectar MQTT', e);
      _connectionController.add(MqttConnectionStatus.error);
      rethrow;
    }
  }
  
  Future<void> disconnect() async {
    if (_client != null && _isConnected) {
      _client!.disconnect();
    }
  }
  
  void subscribe(String topic, {MqttQos qos = MqttQos.atMostOnce}) {
    if (!_isConnected) {
      Logger.warning('MQTT não conectado, adicionando tópico à fila: $topic');
      return;
    }
    
    _client!.subscribe(topic, qos);
    Logger.debug('Subscrito ao tópico: $topic');
  }
  
  void unsubscribe(String topic) {
    if (_isConnected) {
      _client!.unsubscribe(topic);
    }
  }
  
  void publish(
    String topic, 
    String message, {
    MqttQos qos = MqttQos.atMostOnce,
    bool retain = false,
  }) {
    if (!_isConnected) {
      Logger.warning('MQTT não conectado, enfileirando mensagem: $topic');
      _pendingMessages.add(PendingMessage(
        topic: topic,
        message: message,
        qos: qos,
        retain: retain,
      ));
      return;
    }
    
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    
    _client!.publishMessage(topic, qos, builder.payload!, retain: retain);
    Logger.debug('Mensagem publicada: $topic -> $message');
  }
  
  Stream<String> subscribeToTopic(String topic) {
    if (!_topicControllers.containsKey(topic)) {
      _topicControllers[topic] = StreamController<MqttMessage>.broadcast();
      subscribe(topic);
    }
    
    return _topicControllers[topic]!.stream
        .where((msg) => msg.topic == topic)
        .map((msg) => msg.payload);
  }
  
  void _registerHandlers() {
    _handlers[MqttTopics.deviceStatus('+')] = GetIt.instance<DeviceStatusHandler>();
    _handlers[MqttTopics.relayState('+', '+')] = GetIt.instance<RelayStateHandler>();
    _handlers[MqttTopics.THEME] = GetIt.instance<ThemeUpdateHandler>();
    _handlers[MqttTopics.SCREENS] = GetIt.instance<ConfigurationHandler>();
  }
  
  void _onConnected() {
    Logger.info('MQTT conectado');
    _isConnected = true;
    _connectionController.add(MqttConnectionStatus.connected);
    
    // Processar mensagens pendentes
    _processPendingMessages();
    
    // Subscrever tópicos dos handlers
    for (final topicPattern in _handlers.keys) {
      subscribe(_convertPatternToWildcard(topicPattern));
    }
    
    // Publicar status online
    publish(
      'autocore/clients/autocore_flutter/status',
      'online',
      retain: true,
    );
  }
  
  void _onDisconnected() {
    Logger.warning('MQTT desconectado');
    _isConnected = false;
    _connectionController.add(MqttConnectionStatus.disconnected);
  }
  
  void _onAutoReconnect() {
    Logger.info('MQTT reconectando...');
    _connectionController.add(MqttConnectionStatus.reconnecting);
  }
  
  void _onSubscribed(String topic) {
    Logger.debug('Subscrito: $topic');
  }
  
  void _processPendingMessages() {
    while (_pendingMessages.isNotEmpty) {
      final pending = _pendingMessages.removeFirst();
      publish(
        pending.topic,
        pending.message,
        qos: pending.qos,
        retain: pending.retain,
      );
    }
  }
  
  String _convertPatternToWildcard(String pattern) {
    return pattern.replaceAll('+', '+').replaceAll('*', '#');
  }
}

enum MqttConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

class MqttMessage {
  const MqttMessage({
    required this.topic,
    required this.payload,
    required this.qos,
    required this.retain,
    required this.timestamp,
  });

  final String topic;
  final String payload;
  final MqttQos qos;
  final bool retain;
  final DateTime timestamp;
}

class PendingMessage {
  const PendingMessage({
    required this.topic,
    required this.message,
    required this.qos,
    required this.retain,
  });

  final String topic;
  final String message;
  final MqttQos qos;
  final bool retain;
}
```

---

## 🗄️ REPOSITORIES E DATA LAYER

### Base Repository

```dart
abstract class BaseRepository<T, ID> {
  Future<List<T>> getAll();
  Future<T?> getById(ID id);
  Future<T> create(T item);
  Future<T> update(T item);
  Future<void> delete(ID id);
  Future<void> deleteAll();
  
  // Métodos para cache
  Future<void> cacheItem(T item);
  Future<T?> getCachedItem(ID id);
  Future<List<T>> getCachedItems();
  Future<void> clearCache();
  
  // Métodos para sync
  Future<void> syncWithServer();
  Future<bool> needsSync();
  DateTime? getLastSyncTime();
}

class BaseRepositoryImpl<T, ID> implements BaseRepository<T, ID> {
  final ApiClient _apiClient;
  final LocalStorage _localStorage;
  final String _entityName;
  final T Function(Map<String, dynamic>) _fromJson;
  final Map<String, dynamic> Function(T) _toJson;
  
  BaseRepositoryImpl({
    required ApiClient apiClient,
    required LocalStorage localStorage,
    required String entityName,
    required T Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> Function(T) toJson,
  }) : _apiClient = apiClient,
       _localStorage = localStorage,
       _entityName = entityName,
       _fromJson = fromJson,
       _toJson = toJson;
       
  @override
  Future<List<T>> getAll() async {
    try {
      // Tentar buscar do servidor primeiro
      final response = await _apiClient.get('/api/$_entityName');
      final items = (response.data as List)
          .map((json) => _fromJson(json))
          .toList();
      
      // Cachear localmente
      await _localStorage.saveList('${_entityName}_all', 
          items.map(_toJson).toList());
      
      return items;
    } catch (e) {
      Logger.warning('Erro ao buscar $_entityName do servidor, usando cache', e);
      
      // Fallback para cache local
      final cachedData = await _localStorage.getList('${_entityName}_all');
      if (cachedData != null) {
        return cachedData.map((json) => _fromJson(json)).toList();
      }
      
      return [];
    }
  }
  
  @override
  Future<T?> getById(ID id) async {
    try {
      final response = await _apiClient.get('/api/$_entityName/$id');
      final item = _fromJson(response.data);
      
      // Cachear item individual
      await _localStorage.save('${_entityName}_$id', _toJson(item));
      
      return item;
    } catch (e) {
      Logger.warning('Erro ao buscar $_entityName $id do servidor, usando cache', e);
      
      final cachedData = await _localStorage.get('${_entityName}_$id');
      if (cachedData != null) {
        return _fromJson(cachedData);
      }
      
      return null;
    }
  }
  
  // CREATE removido - Flutter app é read-only
  // UPDATE removido - Flutter app é read-only  
  // DELETE removido - Flutter app é read-only
  // Toda configuração é feita no Config-App web
  
  // Apenas operações de LEITURA e EXECUÇÃO são permitidas
  
  Future<void> _markForSync(String operation, T item) async {
    final pendingOps = await _localStorage.getList('pending_operations') ?? [];
    pendingOps.add({
      'operation': operation,
      'entity': _entityName,
      'data': _toJson(item),
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    await _localStorage.saveList('pending_operations', pendingOps);
  }
  
  @override
  Future<void> syncWithServer() async {
    final pendingOps = await _localStorage.getList('pending_operations') ?? [];
    final completedOps = <Map<String, dynamic>>[];
    
    for (final op in pendingOps) {
      if (op['entity'] != _entityName) continue;
      
      try {
        switch (op['operation']) {
          case 'create':
            await _apiClient.post('/api/$_entityName', data: op['data']);
            break;
          case 'update':
            final id = op['data']['id'];
            await _apiClient.put('/api/$_entityName/$id', data: op['data']);
            break;
          case 'delete':
            final id = op['data']['id'];
            await _apiClient.delete('/api/$_entityName/$id');
            break;
        }
        
        completedOps.add(op);
        Logger.info('Sincronizada operação ${op['operation']} para $_entityName');
        
      } catch (e) {
        Logger.error('Erro ao sincronizar operação ${op['operation']}', e);
      }
    }
    
    // Remover operações completadas
    final remainingOps = pendingOps
        .where((op) => !completedOps.contains(op))
        .toList();
    
    await _localStorage.saveList('pending_operations', remainingOps);
    await _localStorage.save('${_entityName}_last_sync', DateTime.now().toIso8601String());
  }
}
```

### Device Repository

```dart
class DeviceRepository extends BaseRepositoryImpl<DeviceModel, int> {
  DeviceRepository({
    required ApiClient apiClient,
    required LocalStorage localStorage,
  }) : super(
         apiClient: apiClient,
         localStorage: localStorage,
         entityName: 'devices',
         fromJson: DeviceModel.fromBackend,
         toJson: (device) => device.toBackend(),
       );
  
  // Métodos específicos para dispositivos
  Future<List<DeviceModel>> getOnlineDevices() async {
    final allDevices = await getAll();
    return allDevices.where((device) => device.isOnline).toList();
  }
  
  Future<List<DeviceModel>> getDevicesByType(DeviceType type) async {
    final allDevices = await getAll();
    return allDevices.where((device) => device.type == type).toList();
  }
  
  Future<void> updateStatus(String uuid, DeviceStatus status) async {
    final device = await getByUuid(uuid);
    if (device != null) {
      final updatedDevice = device.copyWith(
        status: status,
        lastSeen: DateTime.now(),
        isOnline: status == DeviceStatus.online,
      );
      
      await cacheItem(updatedDevice);
      
      // Emitir evento
      GetIt.instance<EventBus>().fire(DeviceStatusChangedEvent(
        deviceId: uuid,
        status: status,
      ));
    }
  }
  
  Future<DeviceModel?> getByUuid(String uuid) async {
    try {
      final response = await _apiClient.get('/api/devices/uuid/$uuid');
      return DeviceModel.fromBackend(response.data);
    } catch (e) {
      // Buscar no cache
      final cachedDevices = await getCachedItems();
      return cachedDevices.firstWhereOrNull((d) => d.uuid == uuid);
    }
  }
  
  Future<void> sendCommand(String deviceId, Map<String, dynamic> command) async {
    final topic = MqttTopics.deviceCommand(deviceId);
    GetIt.instance<MqttService>().publish(topic, jsonEncode(command));
  }
  
  Stream<DeviceStatus> watchDeviceStatus(String deviceId) {
    final topic = MqttTopics.deviceStatus(deviceId);
    return GetIt.instance<MqttService>()
        .subscribeToTopic(topic)
        .map((payload) {
      final data = jsonDecode(payload);
      return DeviceStatus.fromString(data['status']);
    });
  }
}
```

### Relay Repository

```dart
class RelayRepository extends BaseRepositoryImpl<RelayChannelModel, int> {
  final DeviceRepository _deviceRepository;
  
  RelayRepository({
    required ApiClient apiClient,
    required LocalStorage localStorage,
    required DeviceRepository deviceRepository,
  }) : _deviceRepository = deviceRepository,
       super(
         apiClient: apiClient,
         localStorage: localStorage,
         entityName: 'relays',
         fromJson: RelayChannelModel.fromBackend,
         toJson: (relay) => relay.toBackend(),
       );
  
  Future<List<RelayChannelModel>> getChannelsByBoard(int boardId) async {
    try {
      final response = await _apiClient.get('/api/relays/board/$boardId');
      return (response.data as List)
          .map((json) => RelayChannelModel.fromBackend(json))
          .toList();
    } catch (e) {
      final cachedChannels = await getCachedItems();
      return cachedChannels.where((ch) => ch.boardId == boardId).toList();
    }
  }
  
  Future<void> toggleChannel(int boardId, int channel) async {
    final currentState = await getChannelState(boardId, channel);
    await setChannelState(boardId, channel, !currentState);
  }
  
  Future<void> setChannelState(int boardId, int channel, bool state) async {
    final command = {
      'action': 'set_state',
      'channel': channel,
      'state': state,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    final topic = MqttTopics.relayCommand(boardId.toString(), channel);
    GetIt.instance<MqttService>().publish(topic, jsonEncode(command));
    
    // Atualizar cache local imediatamente para UI responsiva
    await _updateLocalChannelState(boardId, channel, state);
  }
  
  Future<bool> getChannelState(int boardId, int channel) async {
    final cachedStates = await _localStorage.get('relay_states_$boardId') 
        as Map<String, dynamic>?;
    
    if (cachedStates != null) {
      return cachedStates[channel.toString()] ?? false;
    }
    
    return false;
  }
  
  Future<void> updateChannelState(String boardId, int channel, bool state) async {
    await _updateLocalChannelState(int.parse(boardId), channel, state);
    
    // Emitir evento para UI
    GetIt.instance<EventBus>().fire(RelayStateChangedEvent(
      boardId: boardId,
      channel: channel,
      state: state,
    ));
  }
  
  Future<void> _updateLocalChannelState(int boardId, int channel, bool state) async {
    final statesKey = 'relay_states_$boardId';
    final currentStates = await _localStorage.get(statesKey) 
        as Map<String, dynamic>? ?? {};
    
    currentStates[channel.toString()] = state;
    await _localStorage.save(statesKey, currentStates);
  }
  
  Stream<bool> watchChannelState(String boardId, int channel) {
    final topic = MqttTopics.relayState(boardId, channel);
    return GetIt.instance<MqttService>()
        .subscribeToTopic(topic)
        .map((payload) {
      final data = jsonDecode(payload);
      return data['state'] as bool;
    });
  }
  
  Future<Map<int, bool>> getAllChannelStates(int boardId) async {
    final statesKey = 'relay_states_$boardId';
    final currentStates = await _localStorage.get(statesKey) 
        as Map<String, dynamic>? ?? {};
    
    return currentStates.map((key, value) => 
        MapEntry(int.parse(key), value as bool));
  }
}
```

---

## 🚀 PERFORMANCE E OTIMIZAÇÃO

### Estratégias de Cache

```dart
class CacheStrategy {
  static const Duration DEFAULT_TTL = Duration(minutes: 30);
  static const Duration DEVICE_STATUS_TTL = Duration(seconds: 30);
  static const Duration THEME_TTL = Duration(days: 7);
  static const Duration CONFIG_TTL = Duration(hours: 6);
  
  static Duration getTTL(String entityType) {
    switch (entityType) {
      case 'device_status':
        return DEVICE_STATUS_TTL;
      case 'theme':
        return THEME_TTL;
      case 'config':
        return CONFIG_TTL;
      default:
        return DEFAULT_TTL;
    }
  }
}

class CacheManager {
  final HiveInterface _hive;
  final Map<String, Timer> _ttlTimers = {};
  
  CacheManager(this._hive);
  
  Future<void> set(String key, dynamic value, {Duration? ttl}) async {
    final box = await _hive.openBox('cache');
    
    final cacheEntry = CacheEntry(
      value: value,
      timestamp: DateTime.now(),
      ttl: ttl ?? CacheStrategy.DEFAULT_TTL,
    );
    
    await box.put(key, cacheEntry.toJson());
    
    // Configurar timer de expiração
    _setExpirationTimer(key, ttl ?? CacheStrategy.DEFAULT_TTL);
  }
  
  Future<T?> get<T>(String key, {T Function(dynamic)? decoder}) async {
    final box = await _hive.openBox('cache');
    final data = box.get(key);
    
    if (data == null) return null;
    
    final cacheEntry = CacheEntry.fromJson(data);
    
    // Verificar expiração
    if (cacheEntry.isExpired) {
      await box.delete(key);
      return null;
    }
    
    return decoder != null ? decoder(cacheEntry.value) : cacheEntry.value as T;
  }
  
  void _setExpirationTimer(String key, Duration ttl) {
    _ttlTimers[key]?.cancel();
    _ttlTimers[key] = Timer(ttl, () async {
      final box = await _hive.openBox('cache');
      await box.delete(key);
      _ttlTimers.remove(key);
    });
  }
}

@freezed
class CacheEntry with _$CacheEntry {
  const factory CacheEntry({
    required dynamic value,
    required DateTime timestamp,
    required Duration ttl,
  }) = _CacheEntry;

  factory CacheEntry.fromJson(Map<String, dynamic> json) =>
      _$CacheEntryFromJson(json);
}

extension CacheEntryExtension on CacheEntry {
  bool get isExpired {
    return DateTime.now().difference(timestamp) > ttl;
  }
}
```

### Connection Manager

```dart
class ConnectionManager {
  static ConnectionManager? _instance;
  static ConnectionManager get instance => _instance ??= ConnectionManager._internal();
  
  ConnectionManager._internal();
  
  ConnectivityResult _currentConnectivity = ConnectivityResult.none;
  final _connectivityController = StreamController<ConnectivityResult>.broadcast();
  
  Timer? _healthCheckTimer;
  bool _isServerReachable = false;
  
  Stream<ConnectivityResult> get connectivityStream => _connectivityController.stream;
  bool get isOnline => _currentConnectivity != ConnectivityResult.none;
  bool get isServerReachable => _isServerReachable;
  
  Future<void> initialize() async {
    // Verificar conectividade atual
    _currentConnectivity = await Connectivity().checkConnectivity();
    
    // Escutar mudanças de conectividade
    Connectivity().onConnectivityChanged.listen((result) {
      _currentConnectivity = result;
      _connectivityController.add(result);
      
      if (result != ConnectivityResult.none) {
        _startHealthCheck();
      } else {
        _stopHealthCheck();
        _isServerReachable = false;
      }
    });
    
    // Iniciar health check se online
    if (isOnline) {
      _startHealthCheck();
    }
  }
  
  void _startHealthCheck() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = Timer.periodic(Duration(seconds: 30), (_) async {
      await _checkServerHealth();
    });
    
    // Verificação inicial
    _checkServerHealth();
  }
  
  void _stopHealthCheck() {
    _healthCheckTimer?.cancel();
  }
  
  Future<void> _checkServerHealth() async {
    try {
      final response = await Dio().get(
        'http://${Config.serverHost}:${Config.serverPort}/api/health',
        options: Options(
          connectTimeout: Duration(seconds: 5),
          receiveTimeout: Duration(seconds: 5),
        ),
      );
      
      _isServerReachable = response.statusCode == 200;
    } catch (e) {
      _isServerReachable = false;
    }
  }
  
  Future<bool> waitForConnection({Duration timeout = const Duration(seconds: 30)}) async {
    if (isOnline && isServerReachable) return true;
    
    final completer = Completer<bool>();
    late StreamSubscription subscription;
    
    subscription = connectivityStream.listen((connectivity) async {
      if (connectivity != ConnectivityResult.none) {
        await _checkServerHealth();
        if (isServerReachable) {
          subscription.cancel();
          completer.complete(true);
        }
      }
    });
    
    Timer(timeout, () {
      subscription.cancel();
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    });
    
    return completer.future;
  }
}
```

Esta integração com backend garante:
- **Sincronização Robusta**: Dados sempre atualizados entre app e servidor
- **Operação Offline**: Funcionalidade completa sem conexão  
- **Performance Otimizada**: Cache inteligente e lazy loading
- **Comunicação em Tempo Real**: MQTT para updates instantâneos
- **Tratamento de Erros**: Fallbacks e recovery automático
- **Escalabilidade**: Arquitetura preparada para crescimento