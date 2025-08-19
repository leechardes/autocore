"""
Funções de normalização para garantir compatibilidade com tipos em lowercase.
Padronização: TODOS os tipos em minúsculo com underscores.
"""

def normalize_device_type(device_type) -> str:
    """
    Normaliza device_type para lowercase padrão.
    
    Args:
        device_type: Tipo do dispositivo (pode estar em qualquer formato ou ser um Enum)
        
    Returns:
        str: Tipo normalizado em lowercase com underscores
        
    Examples:
        normalize_device_type("ESP32-RELAY") -> "esp32_relay"
        normalize_device_type("ESP32_DISPLAY") -> "esp32_display"
        normalize_device_type("sensor_board") -> "sensor_board"
    """
    if not device_type:
        return ""
    
    # Se for um Enum, pega o valor
    if hasattr(device_type, 'value'):
        device_type = device_type.value
    
    # Converte para lowercase e substitui hífen por underscore
    normalized = str(device_type).lower().replace("-", "_")
    
    # Mapeamento de valores antigos para novos
    mapping = {
        "esp32_relay_board": "esp32_relay",
        "esp32_display_board": "esp32_display",
        "esp32_display_small": "sensor_board",
        "esp32_display_large": "gateway",
        "relay": "esp32_relay",
        "display": "esp32_display",
    }
    
    return mapping.get(normalized, normalized)


def normalize_item_type(item_type) -> str:
    """
    Normaliza item_type para lowercase padrão.
    
    Args:
        item_type: Tipo do item (pode estar em qualquer formato ou ser um Enum)
        
    Returns:
        str: Tipo normalizado em lowercase
        
    Examples:
        normalize_item_type("BUTTON") -> "button"
        normalize_item_type("Switch") -> "switch"
        normalize_item_type("GAUGE") -> "gauge"
    """
    if not item_type:
        return ""
    
    # Se for um Enum, pega o valor
    if hasattr(item_type, 'value'):
        item_type = item_type.value
    
    normalized = str(item_type).lower()
    
    # Mapeamento de valores antigos para novos
    mapping = {
        "text": "display",
        "label": "display",
    }
    
    return mapping.get(normalized, normalized)


def normalize_action_type(action_type) -> str:
    """
    Normaliza action_type para lowercase padrão.
    
    Args:
        action_type: Tipo da ação (pode estar em qualquer formato ou ser um Enum)
        
    Returns:
        str: Tipo normalizado em lowercase ou None se vazio
        
    Examples:
        normalize_action_type("RELAY_TOGGLE") -> "relay_control"
        normalize_action_type("relay_pulse") -> "relay_control"
        normalize_action_type("COMMAND") -> "command"
    """
    if not action_type:
        return None
    
    # Se for um Enum, pega o valor
    if hasattr(action_type, 'value'):
        action_type = action_type.value
    
    # Mapeamento de valores antigos para novos
    mapping = {
        "relay_toggle": "relay_control",
        "relay_pulse": "relay_control", 
        "toggle": "relay_control",
        "pulse": "relay_control",
        "navigate": "navigation",
    }
    
    normalized = str(action_type).lower()
    result = mapping.get(normalized, normalized)
    
    return result


def normalize_status(status: str) -> str:
    """
    Normaliza status para lowercase padrão.
    
    Args:
        status: Status (pode estar em qualquer formato)
        
    Returns:
        str: Status normalizado em lowercase
        
    Examples:
        normalize_status("ACTIVE") -> "online"
        normalize_status("OFFLINE") -> "offline"
    """
    if not status:
        return ""
    
    # Mapeamento de valores antigos para novos
    mapping = {
        "active": "online",
        "connected": "online",
        "inactive": "offline",
        "disconnected": "offline",
        "fault": "error",
        "maint": "maintenance",
    }
    
    normalized = str(status).lower()
    return mapping.get(normalized, normalized)


def compare_device_types(type1, type2) -> bool:
    """
    Compara dois device types após normalização.
    
    Args:
        type1: Primeiro tipo
        type2: Segundo tipo
        
    Returns:
        bool: True se os tipos são equivalentes
    """
    return normalize_device_type(type1) == normalize_device_type(type2)


def compare_item_types(type1, type2) -> bool:
    """
    Compara dois item types após normalização.
    
    Args:
        type1: Primeiro tipo
        type2: Segundo tipo
        
    Returns:
        bool: True se os tipos são equivalentes
    """
    return normalize_item_type(type1) == normalize_item_type(type2)


def compare_action_types(type1, type2) -> bool:
    """
    Compara dois action types após normalização.
    
    Args:
        type1: Primeiro tipo
        type2: Segundo tipo
        
    Returns:
        bool: True se os tipos são equivalentes
    """
    return normalize_action_type(type1) == normalize_action_type(type2)


def enum_to_str(value):
    """
    Converte valor para string lowercase, se necessário.
    Função para garantir consistência nos valores de retorno.
    
    Args:
        value: Valor que pode ser um Enum ou string
        
    Returns:
        str ou None: Valor como string em lowercase
        
    Examples:
        enum_to_str("BUTTON") -> "button"
        enum_to_str("Display") -> "display"
        enum_to_str(None) -> None
    """
    if value is None:
        return None
    
    # Verifica se é um Enum (tem atributo 'value')
    if hasattr(value, 'value'):
        return str(value.value).lower()
    
    # Já é string ou outro tipo
    return str(value).lower() if value else None