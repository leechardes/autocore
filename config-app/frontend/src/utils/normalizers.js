/**
 * Funções de normalização para garantir compatibilidade com tipos em lowercase.
 * Padronização: TODOS os tipos em minúsculo com underscores.
 */

/**
 * Normaliza device_type para lowercase padrão.
 * @param {string} deviceType - Tipo do dispositivo (pode estar em qualquer formato)
 * @returns {string} Tipo normalizado em lowercase com underscores
 */
export const normalizeDeviceType = (deviceType) => {
  if (!deviceType) return '';
  
  // Converte para lowercase e substitui hífen por underscore
  const normalized = deviceType.toLowerCase().replace(/-/g, '_');
  
  // Mapeamento de valores antigos para novos
  const mapping = {
    'esp32_relay_board': 'esp32_relay',
    'esp32_display_board': 'esp32_display',
    'hmi_display': 'esp32_display',
    'esp32_display_small': 'sensor_board',
    'esp32_display_large': 'gateway',
    'relay': 'esp32_relay',
    'display': 'esp32_display',
  };
  
  return mapping[normalized] || normalized;
};

/**
 * Normaliza item_type para lowercase padrão.
 * @param {string} itemType - Tipo do item (pode estar em qualquer formato)
 * @returns {string} Tipo normalizado em lowercase
 */
export const normalizeItemType = (itemType) => {
  if (!itemType) return '';
  
  const normalized = itemType.toLowerCase();
  
  // Mapeamento de valores antigos para novos
  const mapping = {
    'text': 'display',
    'label': 'display',
  };
  
  return mapping[normalized] || normalized;
};

/**
 * Normaliza action_type para lowercase padrão.
 * @param {string} actionType - Tipo da ação (pode estar em qualquer formato)
 * @returns {string|null} Tipo normalizado em lowercase ou null se vazio
 */
export const normalizeActionType = (actionType) => {
  if (!actionType) return null;
  
  // Mapeamento de valores antigos para novos
  const mapping = {
    'relay_toggle': 'relay_control',
    'relay_pulse': 'relay_control',
    'toggle': 'relay_control',
    'pulse': 'relay_control',
    'navigate': 'navigation',
  };
  
  const normalized = actionType.toLowerCase();
  const result = mapping[normalized] || normalized;
  
  return result;
};

/**
 * Normaliza status para lowercase padrão.
 * @param {string} status - Status (pode estar em qualquer formato)
 * @returns {string} Status normalizado em lowercase
 */
export const normalizeStatus = (status) => {
  if (!status) return '';
  
  // Mapeamento de valores antigos para novos
  const mapping = {
    'active': 'online',
    'connected': 'online',
    'inactive': 'offline',
    'disconnected': 'offline',
    'fault': 'error',
    'maint': 'maintenance',
  };
  
  const normalized = status.toLowerCase();
  return mapping[normalized] || normalized;
};

/**
 * Compara dois device types após normalização.
 * @param {string} type1 - Primeiro tipo
 * @param {string} type2 - Segundo tipo
 * @returns {boolean} True se os tipos são equivalentes
 */
export const compareDeviceTypes = (type1, type2) => {
  return normalizeDeviceType(type1) === normalizeDeviceType(type2);
};

/**
 * Compara dois item types após normalização.
 * @param {string} type1 - Primeiro tipo
 * @param {string} type2 - Segundo tipo
 * @returns {boolean} True se os tipos são equivalentes
 */
export const compareItemTypes = (type1, type2) => {
  return normalizeItemType(type1) === normalizeItemType(type2);
};

/**
 * Compara dois action types após normalização.
 * @param {string} type1 - Primeiro tipo
 * @param {string} type2 - Segundo tipo
 * @returns {boolean} True se os tipos são equivalentes
 */
export const compareActionTypes = (type1, type2) => {
  return normalizeActionType(type1) === normalizeActionType(type2);
};

// Constantes para dropdowns e selects (todos em lowercase)
export const ITEM_TYPES = [
  { value: 'button', label: 'Botão' },
  { value: 'switch', label: 'Switch' },
  { value: 'gauge', label: 'Medidor' },
  { value: 'display', label: 'Display' }
];

export const ACTION_TYPES = [
  { value: 'relay_control', label: 'Controle de Relé' },
  { value: 'command', label: 'Comando' },
  { value: 'macro', label: 'Macro' },
  { value: 'navigation', label: 'Navegação' },
  { value: 'preset', label: 'Preset' }
];

export const DEVICE_TYPES = [
  { value: 'esp32_relay', label: 'ESP32 Relay' },
  { value: 'esp32_display', label: 'ESP32 Display' },
  { value: 'sensor_board', label: 'Sensor Board' },
  { value: 'gateway', label: 'Gateway' }
];

// Helper para validar se um tipo é válido
export const isValidItemType = (type) => {
  return ITEM_TYPES.some(item => item.value === normalizeItemType(type));
};

export const isValidActionType = (type) => {
  return ACTION_TYPES.some(item => item.value === normalizeActionType(type));
};

export const isValidDeviceType = (type) => {
  return DEVICE_TYPES.some(item => item.value === normalizeDeviceType(type));
};