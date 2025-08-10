// Configuração dinâmica da API
// Usa o mesmo host de onde o frontend foi carregado

const getApiConfig = () => {
  // Se tiver variável de ambiente, usar
  if (import.meta.env.VITE_API_URL && import.meta.env.VITE_API_URL !== 'http://localhost:8081') {
    return {
      baseUrl: import.meta.env.VITE_API_URL,
      wsUrl: import.meta.env.VITE_WS_URL || import.meta.env.VITE_API_URL.replace('http', 'ws')
    };
  }
  
  // Caso contrário, usar o mesmo host de onde o frontend foi carregado
  const protocol = window.location.protocol;
  const hostname = window.location.hostname;
  const apiPort = 8081; // Porta da API backend
  
  return {
    baseUrl: `${protocol}//${hostname}:${apiPort}`,
    wsUrl: `${protocol === 'https:' ? 'wss:' : 'ws:'}//${hostname}:${apiPort}`,
    apiPort: apiPort
  };
};

const config = getApiConfig();

export const API_URL = config.baseUrl;
export const WS_URL = config.wsUrl;
export const API_BASE_URL = `${config.baseUrl}/api`;

// Função helper para fazer requests
export const apiRequest = async (endpoint, options = {}) => {
  const url = endpoint.startsWith('http') ? endpoint : `${API_BASE_URL}${endpoint}`;
  
  const response = await fetch(url, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...options.headers
    }
  });
  
  if (!response.ok) {
    throw new Error(`API Error: ${response.statusText}`);
  }
  
  return response.json();
};

export default {
  API_URL,
  WS_URL,
  API_BASE_URL,
  apiRequest
};