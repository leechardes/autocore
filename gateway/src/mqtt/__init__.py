"""
Módulo MQTT para AutoCore Gateway
Implementa protocolo MQTT v2.2.0
"""

from .protocol import (
    MQTT_PROTOCOL_VERSION,
    MessageType,
    QoSLevel,
    create_base_payload,
    create_gateway_status_payload,
    create_lwt_payload,
    create_telemetry_payload,
    create_error_payload,
    validate_protocol_version,
    extract_device_uuid_from_topic,
    get_message_qos,
    parse_topic_structure,
    serialize_payload,
    deserialize_payload,
    get_topic_pattern,
    TOPIC_PATTERNS
)

from .error_handler import (
    ErrorCode,
    ErrorSeverity,
    ErrorHandler,
    quick_error
)

from .rate_limiter import (
    RateLimiter,
    RateLimitStats,
    GlobalRateLimiter
)

__all__ = [
    # Protocol
    'MQTT_PROTOCOL_VERSION',
    'MessageType',
    'QoSLevel',
    'create_base_payload',
    'create_gateway_status_payload',
    'create_lwt_payload',
    'create_telemetry_payload',
    'create_error_payload',
    'validate_protocol_version',
    'extract_device_uuid_from_topic',
    'get_message_qos',
    'parse_topic_structure',
    'serialize_payload',
    'deserialize_payload',
    'get_topic_pattern',
    'TOPIC_PATTERNS',
    
    # Error Handler
    'ErrorCode',
    'ErrorSeverity',
    'ErrorHandler',
    'quick_error',
    
    # Rate Limiter
    'RateLimiter',
    'RateLimitStats',
    'GlobalRateLimiter'
]