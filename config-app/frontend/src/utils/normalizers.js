/**
 * Funções de normalização para garantir compatibilidade com enums UPPERCASE do database.
 * Mantém compatibilidade com valores antigos em lowercase/hífen.
 */

/**
 * Normaliza device_type para uppercase padrão.
 * @param {string} deviceType - Tipo do dispositivo (pode estar em qualquer formato)
 * @returns {string} Tipo normalizado em UPPERCASE com underscores
 */
export const normalizeDeviceType = (deviceType) => {
  if (!deviceType) return '';
  
  // Converte para uppercase e substitui hífen por underscore
  const normalized = deviceType.toUpperCase().replace(/-/g, '_');
  
  // Mapeamento de valores antigos para novos (se necessário)
  const mapping = {
    'ESP32_RELAY_BOARD': 'ESP32_RELAY',
    'ESP32_DISPLAY_BOARD': 'ESP32_DISPLAY',
    'HMI_DISPLAY': 'ESP32_DISPLAY',
  };
  
  return mapping[normalized] || normalized;
};

/**
 * Normaliza item_type para uppercase padrão.
 * @param {string} itemType - Tipo do item (pode estar em qualquer formato)
 * @returns {string} Tipo normalizado em UPPERCASE
 */
export const normalizeItemType = (itemType) => {
  if (!itemType) return '';
  
  const normalized = itemType.toUpperCase();
  
  // Mapeamento de valores antigos para novos (se necessário)
  const mapping = {
    'TEXT': 'DISPLAY',
    'LABEL': 'DISPLAY',
  };
  
  return mapping[normalized] || normalized;
};

/**
 * Normaliza action_type para uppercase padrão.
 * @param {string} actionType - Tipo da ação (pode estar em qualquer formato)
 * @returns {string|null} Tipo normalizado em UPPERCASE ou null se vazio
 */
export const normalizeActionType = (actionType) => {
  if (!actionType) return null;
  
  // Mapeamento de valores antigos para novos
  const mapping = {
    'relay_toggle': 'RELAY_CONTROL',
    'relay_pulse': 'RELAY_CONTROL',
    'relay_control': 'RELAY_CONTROL',
    'toggle': 'RELAY_CONTROL',
    'pulse': 'RELAY_CONTROL',
    'command': 'COMMAND',
    'macro': 'MACRO',
    'navigation': 'NAVIGATION',
    'navigate': 'NAVIGATION',
  };
  
  const normalized = actionType.toLowerCase();
  const result = mapping[normalized] || actionType.toUpperCase();
  
  return result;
};

/**
 * Normaliza status para uppercase padrão.
 * @param {string} status - Status (pode estar em qualquer formato)
 * @returns {string} Status normalizado em UPPERCASE
 */
export const normalizeStatus = (status) => {
  if (!status) return '';
  return status.toUpperCase();
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

// Constantes para dropdowns e selects (todos em UPPERCASE)
export const ITEM_TYPES = [
  { value: 'BUTTON', label: 'Botão' },
  { value: 'SWITCH', label: 'Switch' },
  { value: 'GAUGE', label: 'Medidor' },
  { value: 'DISPLAY', label: 'Display' }
];

export const ACTION_TYPES = [
  { value: 'RELAY_CONTROL', label: 'Controle de Relé' },
  { value: 'COMMAND', label: 'Comando' },
  { value: 'MACRO', label: 'Macro' },
  { value: 'NAVIGATION', label: 'Navegação' }
];

export const DEVICE_TYPES = [
  { value: 'ESP32_RELAY', label: 'ESP32 Relay' },
  { value: 'ESP32_DISPLAY', label: 'ESP32 Display' },
  { value: 'ESP32_DISPLAY_SMALL', label: 'ESP32 Display P' },
  { value: 'ESP32_DISPLAY_LARGE', label: 'ESP32 Display G' }
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