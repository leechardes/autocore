// AutoCore Config App - Preview Data Adapter
// Adapta dados do endpoint /api/config/full para o formato esperado pelo preview

/**
 * Adapta a resposta do config/full para o formato do preview
 * @param {Object} configData - Dados do endpoint /api/config/full
 * @returns {Object} Dados adaptados para o preview
 */
export function adaptConfigToPreview(configData) {
  if (!configData) {
    return {
      screens: [],
      telemetry: {},
      preview_mode: true
    }
  }

  return {
    screens: adaptScreens(configData.screens || [], configData.telemetry || {}),
    telemetry: configData.telemetry || {},
    theme: configData.theme || null,
    devices: configData.devices || [],
    relay_boards: configData.relay_boards || [],
    preview_mode: true,
    timestamp: configData.timestamp || new Date().toISOString()
  }
}

/**
 * Adapta as telas do config/full
 * @param {Array} screens - Array de telas
 * @param {Object} telemetry - Dados de telemetria
 * @returns {Array} Telas adaptadas
 */
function adaptScreens(screens, telemetry) {
  return screens.map(screen => ({
    ...screen,
    items: adaptScreenItems(screen.items || [], telemetry)
  }))
}

/**
 * Adapta os itens de uma tela
 * @param {Array} items - Array de itens da tela
 * @param {Object} telemetry - Dados de telemetria
 * @returns {Array} Itens adaptados
 */
function adaptScreenItems(items, telemetry) {
  return items.map(item => {
    const adaptedItem = {
      ...item,
      // Garantir que campos obrigatórios existam
      is_active: item.is_active !== false, // default true
      position: item.position || 0,
      icon: item.icon || 'circle',
      label: item.label || item.name || 'Item',
    }

    // Para itens de display e gauge, calcular valor baseado na telemetria
    if (item.item_type === 'display' || item.item_type === 'gauge') {
      adaptedItem.currentValue = getCurrentValue(item, telemetry)
      adaptedItem.formattedValue = formatDisplayValue(
        adaptedItem.currentValue,
        item.unit,
        item.display_format
      )
    }

    // Para itens com relés, incluir informações expandidas
    if (item.relay_board_id && item.relay_channel_id) {
      adaptedItem.deviceName = item.relay_board?.device_name || 'Dispositivo'
      adaptedItem.channelName = item.relay_channel?.name || item.label
      adaptedItem.relayFunction = item.relay_channel?.function_type || 'toggle'
    }

    return adaptedItem
  })
}

/**
 * Obtém o valor atual para um item baseado na telemetria
 * @param {Object} item - Item da tela
 * @param {Object} telemetry - Dados de telemetria
 * @returns {number|string} Valor atual
 */
function getCurrentValue(item, telemetry) {
  if (!item.value_source) {
    return item.default_value || 0
  }

  // Suporte para diferentes formatos de value_source
  let value = null

  if (item.value_source.startsWith('telemetry.')) {
    // Formato: "telemetry.speed"
    const key = item.value_source.replace('telemetry.', '')
    value = telemetry[key]
  } else if (telemetry[item.value_source]) {
    // Formato direto: "speed"
    value = telemetry[item.value_source]
  }

  // Se não encontrou valor na telemetria, usar valor padrão ou gerar valor demo
  if (value === null || value === undefined) {
    if (item.default_value !== null && item.default_value !== undefined) {
      return item.default_value
    }
    
    // Gerar valores demo baseados no tipo
    return generateDemoValue(item)
  }

  return value
}

/**
 * Gera valores demo para preview quando não há telemetria
 * @param {Object} item - Item da tela
 * @returns {number} Valor demo
 */
function generateDemoValue(item) {
  const min = item.min_value || 0
  const max = item.max_value || 100
  
  // Valores específicos baseados no nome do item
  const demoValues = {
    'speed': 45.5,
    'rpm': 3200,
    'temp': 89.5,
    'temperature': 89.5,
    'engine_temp': 89.5,
    'oil_pressure': 4.2,
    'fuel': 75.8,
    'fuel_level': 75.8,
    'battery': 13.8,
    'battery_voltage': 13.8,
    'boost': 0.8,
    'boost_pressure': 0.8,
    'lambda': 0.95,
    'tps': 35.2,
    'ethanol': 27.5,
    'gear': 3
  }

  // Tentar encontrar valor demo baseado no nome
  const itemName = (item.name || '').toLowerCase()
  for (const [key, value] of Object.entries(demoValues)) {
    if (itemName.includes(key)) {
      return value
    }
  }

  // Valor aleatório dentro do range se não encontrou específico
  return Math.floor(Math.random() * (max - min + 1)) + min
}

/**
 * Formata valor para exibição
 * @param {number|string} value - Valor a ser formatado
 * @param {string} unit - Unidade
 * @param {string} format - Formato de exibição
 * @returns {string} Valor formatado
 */
function formatDisplayValue(value, unit = '', format = 'text') {
  if (value === null || value === undefined) {
    return '--'
  }

  let formattedValue = value

  // Aplicar formato
  switch (format) {
    case 'percentage':
      formattedValue = `${value}%`
      break
    case 'decimal':
      formattedValue = typeof value === 'number' ? value.toFixed(1) : value
      break
    case 'integer':
      formattedValue = typeof value === 'number' ? Math.round(value) : value
      break
    case 'currency':
      formattedValue = typeof value === 'number' ? value.toLocaleString('pt-BR', {
        style: 'currency',
        currency: 'BRL'
      }) : value
      break
    default:
      // Formato padrão - aplicar locale se for número
      if (typeof value === 'number') {
        formattedValue = value.toLocaleString('pt-BR')
      }
  }

  // Adicionar unidade se especificada
  if (unit && !String(formattedValue).includes(unit)) {
    formattedValue = `${formattedValue} ${unit}`
  }

  return String(formattedValue)
}

/**
 * Obtém cor baseada no valor e ranges de cor definidos
 * @param {number} value - Valor atual
 * @param {Array} colorRanges - Array de ranges de cor
 * @returns {string} Cor hexadecimal
 */
export function getColorForValue(value, colorRanges) {
  if (!colorRanges || !Array.isArray(colorRanges)) {
    return '#3B82F6' // Cor padrão azul
  }

  // Encontrar range apropriado
  for (const range of colorRanges) {
    if (value >= range.min && value <= range.max) {
      return range.color
    }
  }

  return '#3B82F6' // Cor padrão se não encontrou range
}

/**
 * Determina se um item deve ser mostrado baseado no tipo de dispositivo
 * @param {Object} item - Item da tela
 * @param {string} deviceType - Tipo do dispositivo (mobile, display_small, etc.)
 * @returns {boolean} Se deve mostrar o item
 */
export function shouldShowItem(item, deviceType) {
  if (!item.is_active) return false

  // Mapeamento de tipos de dispositivo para campos de visibilidade
  const visibilityFields = {
    'mobile': 'show_on_mobile',
    'display_small': 'show_on_display_small',
    'display_large': 'show_on_display_large',
    'web': 'show_on_web'
  }

  const field = visibilityFields[deviceType]
  if (field && item[field] !== undefined) {
    return item[field]
  }

  // Se não tem campo específico, mostrar por padrão
  return true
}

/**
 * Obtém configurações de tamanho baseadas no tipo de dispositivo
 * @param {Object} item - Item da tela
 * @param {string} deviceType - Tipo do dispositivo
 * @returns {string} Classe de tamanho
 */
export function getItemSize(item, deviceType) {
  const sizeFields = {
    'mobile': 'size_mobile',
    'display_small': 'size_display_small',
    'display_large': 'size_display_large',
    'web': 'size_web'
  }

  const field = sizeFields[deviceType]
  return item[field] || item.size || 'normal'
}

/**
 * Obtém número de colunas para o dispositivo
 * @param {Object} screen - Tela atual
 * @param {string} deviceType - Tipo do dispositivo
 * @returns {number} Número de colunas
 */
export function getScreenColumns(screen, deviceType) {
  const columnFields = {
    'mobile': 'columns_mobile',
    'display_small': 'columns_display_small',
    'display_large': 'columns_display_large',
    'web': 'columns_web'
  }

  const field = columnFields[deviceType]
  return screen[field] || 2 // Default 2 colunas
}

export default {
  adaptConfigToPreview,
  getColorForValue,
  shouldShowItem,
  getItemSize,
  getScreenColumns,
  formatDisplayValue
}