"""
Funções de normalização para garantir compatibilidade com enums UPPERCASE do database.
Mantém compatibilidade com valores antigos em lowercase/hífen.
"""

def normalize_device_type(device_type) -> str:
    """
    Normaliza device_type para uppercase padrão.
    
    Args:
        device_type: Tipo do dispositivo (pode estar em qualquer formato ou ser um Enum)
        
    Returns:
        str: Tipo normalizado em UPPERCASE com underscores
        
    Examples:
        normalize_device_type("esp32-relay") -> "ESP32_RELAY"
        normalize_device_type("esp32_display") -> "ESP32_DISPLAY"
        normalize_device_type("ESP32_RELAY") -> "ESP32_RELAY"
    """
    if not device_type:
        return ""
    
    # Se for um Enum, pega o valor
    if hasattr(device_type, 'value'):
        device_type = device_type.value
    
    # Converte para uppercase e substitui hífen por underscore
    normalized = str(device_type).upper().replace("-", "_")
    
    # Mapeamento de valores antigos para novos (se necessário)
    mapping = {
        "ESP32_RELAY_BOARD": "ESP32_RELAY",
        "ESP32_DISPLAY_BOARD": "ESP32_DISPLAY",
    }
    
    return mapping.get(normalized, normalized)


def normalize_item_type(item_type) -> str:
    """
    Normaliza item_type para uppercase padrão.
    
    Args:
        item_type: Tipo do item (pode estar em qualquer formato ou ser um Enum)
        
    Returns:
        str: Tipo normalizado em UPPERCASE
        
    Examples:
        normalize_item_type("button") -> "BUTTON"
        normalize_item_type("switch") -> "SWITCH"
        normalize_item_type("GAUGE") -> "GAUGE"
    """
    if not item_type:
        return ""
    
    # Se for um Enum, pega o valor
    if hasattr(item_type, 'value'):
        item_type = item_type.value
    
    normalized = str(item_type).upper()
    
    # Mapeamento de valores antigos para novos (se necessário)
    mapping = {
        "TEXT": "DISPLAY",
        "LABEL": "DISPLAY",
    }
    
    return mapping.get(normalized, normalized)


def normalize_action_type(action_type) -> str:
    """
    Normaliza action_type para uppercase padrão.
    
    Args:
        action_type: Tipo da ação (pode estar em qualquer formato ou ser um Enum)
        
    Returns:
        str: Tipo normalizado em UPPERCASE ou None se vazio
        
    Examples:
        normalize_action_type("relay_toggle") -> "RELAY_CONTROL"
        normalize_action_type("relay_pulse") -> "RELAY_CONTROL"
        normalize_action_type("command") -> "COMMAND"
    """
    if not action_type:
        return None
    
    # Se for um Enum, pega o valor
    if hasattr(action_type, 'value'):
        action_type = action_type.value
    
    # Mapeamento de valores antigos para novos
    mapping = {
        "relay_toggle": "RELAY_CONTROL",
        "relay_pulse": "RELAY_CONTROL", 
        "relay_control": "RELAY_CONTROL",
        "toggle": "RELAY_CONTROL",
        "pulse": "RELAY_CONTROL",
        "command": "COMMAND",
        "macro": "MACRO",
        "navigation": "NAVIGATION",
        "navigate": "NAVIGATION",
    }
    
    normalized = str(action_type).lower()
    result = mapping.get(normalized, str(action_type).upper())
    
    return result


def normalize_status(status: str) -> str:
    """
    Normaliza status para uppercase padrão.
    
    Args:
        status: Status (pode estar em qualquer formato)
        
    Returns:
        str: Status normalizado em UPPERCASE
        
    Examples:
        normalize_status("active") -> "ACTIVE"
        normalize_status("inactive") -> "INACTIVE"
    """
    if not status:
        return ""
    
    return status.upper()


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
    Converte enum value para string, se necessário.
    Função essencial para serializar os Enums do SQLAlchemy.
    
    Args:
        value: Valor que pode ser um Enum ou string
        
    Returns:
        str ou None: Valor como string
        
    Examples:
        enum_to_str(ItemType.BUTTON) -> "BUTTON"
        enum_to_str("DISPLAY") -> "DISPLAY"
        enum_to_str(None) -> None
    """
    if value is None:
        return None
    
    # Verifica se é um Enum (tem atributo 'value')
    if hasattr(value, 'value'):
        return value.value
    
    # Já é string ou outro tipo
    return str(value) if value else None